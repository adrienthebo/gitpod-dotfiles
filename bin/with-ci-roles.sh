#!/usr/bin/env bash
#
# Extract service account credentials for GKE/EKS/AKS and run a command


TMPDIR="$(mktemp -d)"
trap "rm -rf $TMPDIR" EXIT

# https://stackoverflow.com/questions/3338030/multiple-bash-traps-for-the-same-signal
trap_add() {
    trap_add_cmd=$1; shift || fatal "${FUNCNAME} usage error"
    for trap_add_name in "$@"; do
        trap -- "$(
            # helper fn to get existing trap command from output
            # of trap -p
            extract_trap_cmd() { printf '%s\n' "$3"; }
            # print existing trap command with newline
            eval "extract_trap_cmd $(trap -p "${trap_add_name}")"
            # print the new trap command
            printf '%s\n' "${trap_add_cmd}"
        )" "${trap_add_name}" \
            || fatal "unable to add to trap ${trap_add_name}"
    done
}
declare -f -t trap_add

setup_gcloud_sa() {

    kubectl --namespace werft get secret sh-playground-dns-perm -ojson \
        | jq -r '.data["sh-dns-sa.json"] | @base64d' \
        > $TMPDIR/sh-dns-sa.json
    cat $TMPDIR/sh-dns-sa.json
    sleep 10
    export TF_VAR_dns_sa_creds="$TMPDIR/sh-dns-sa.json"

    kubectl --namespace werft get secret sh-playground-sa-perm -ojson \
        | jq -r '.data["sh-sa.json"] | @base64d' \
        > "$TMPDIR/sh-sa.json"

    local current_configuration="$(gcloud config configurations list --format='get(name)' --filter='is_active:true')"

    # Configure application default credentials. Note that this doesn't handle cloudsdk credentials;
    # we'll handle this shortly.
    export GOOGLE_APPLICATION_CREDENTIALS="$TMPDIR/sh-sa.json"

    # Unset any CLOUDSDK environment variables so they don't conflict with our isolated environment
    for var in $(env | awk -F= '/^CLOUDSDK/ { print $1 }'); do
        echo "Clearing GCP variable $var"
        unset "$var"
    done

    # Create an isolated gcloud configuration so that we don't tamper with the current user's configuration.
    gcloud config configurations create with-ci-roles --quiet --no-activate
    export CLOUDSDK_ACTIVE_CONFIG_NAME="with-ci-roles"
    gcloud config set core/project sh-automated-tests
    # Activate the service account credentials for use with
    gcloud auth activate-service-account --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"

    local svc_account_name="$(jq -r .client_email $GOOGLE_APPLICATION_CREDENTIALS)"

    # Activate the original configuration
    trap_add "gcloud config configurations activate $current_configuration" EXIT
    # Delete the temporary configuration
    trap_add "gcloud config configurations delete with-ci-roles --quiet" EXIT
    # And then remove the service account credentials. Apologies if you had this activated already.
    trap_add "gcloud auth revoke '$svc_account_name'" EXIT
}

setup_aws_sa() {
    for var in $(env | awk -F= '/^AWS_/ { print $1 }'); do
        echo "Clearing AWS variable $var"
        unset "$var"
    done

    kubectl --namespace werft get secret aws-credentials -ojson \
        | jq -r '.data | with_entries(.value = (.value | @base64d))' \
        > $TMPDIR/aws-credentials.json


    export AWS_ACCESS_KEY_ID="$(jq -r '.["aws-access-key"]' $TMPDIR/aws-credentials.json)"
    export AWS_SECRET_ACCESS_KEY="$(jq -r '.["aws-secret-key"]' $TMPDIR/aws-credentials.json)"
    export AWS_REGION="$(jq -r '.["aws-region"]' $TMPDIR/aws-credentials.json)"
    export AWS_CONFIG_FILE="$TMPDIR/aws-config"

    # shellcheck disable=SC2209
    PAGER=cat aws sts get-caller-identity || exit 1
}

setup_azure_sa() {
    for var in $(env | awk -F= '/^ARM_/ { print $1 }'); do
        echo "Clearing Azure variable $var"
        unset "$var"
    done

    kubectl --namespace werft get secret aks-credentials -ojson \
        | jq -r '.data | with_entries(.value = (.value | @base64d))' \
        > $TMPDIR/aks-credentials.json

    export ARM_TENANT_ID="$(jq -r '.tenantid' $TMPDIR/aks-credentials.json)"
    export ARM_CLIENT_ID="$(jq -r '.clientid' $TMPDIR/aks-credentials.json)"
    export ARM_CLIENT_SECRET="$(jq -r '.clientsecret' $TMPDIR/aks-credentials.json)"
    export ARM_SUBSCRIPTION_ID="$(jq -r '.subscriptionid' $TMPDIR/aks-credentials.json)"

    export AZURE_CONFIG_DIR="$TMPDIR/azure"
    az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET  --tenant $ARM_TENANT_ID

    trap_add "az logout" EXIT
}

main() {
    command -v az 1>/dev/null || {
        echo "Error: command 'az' missing, cannot continue"
        exit 1
    }

    setup_aws_sa
    setup_azure_sa
    # gcloud has to be configured last since we'll be using GCP credentials to interact with
    # the werft namespace.
    setup_gcloud_sa
    $@
    exit $?
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi