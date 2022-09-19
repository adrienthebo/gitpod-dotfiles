#!/bin/bash

eval "$(gp env -e)"

# TODO: move this to `profile.d` when that directory is wired up.
export BROWSER="/ide/bin/helpers/browser.sh"

if [[ -f "$GITPOD_REPO_ROOT/.env" ]]; then
    echo "Loading environment variables from $GITPOD_REPO_ROOT/.env"
    set -x
    source "$GITPOD_REPO_ROOT/.env"
    set +x
fi

__gitpod_reload_dotfiles() {
    source "$HOME/.dotfiles/script/reload"
}


__gitpod_kotsup() {
    if ! [[ -f /workspace/cluster/license.yaml ]]; then
        echo "Error: KOTS license-file 'license.yaml' absent, cannot install"
        return 1
    fi

    kubectl-kots install gitpod --namespace gitpod --shared-password=gitpod --no-port-forward --license-file /workspace/cluster/license.yaml
}

__gitpod_kotsdash() {
    local __kotsport="$(( ( $RANDOM % 63535 ) + 2000 ))"

    (
        sleep 2
        $BROWSER "http://localhost:$__kotsport"
    ) &

    kubectl kots admin-console --namespace gitpod --port "$__kotsport"
}

__gitpod_license() {
    [[ -d /workspace/cluster ]] || mkdir -p /workspace/cluster
    gsutil cp "gs://adrien-self-hosted-testing-5k4-license-25500/license.yaml" /workspace/cluster/license.yaml
}

__gitpod_backup_certs() {
    [[ -d /workspace/cluster ]] || mkdir -p /workspace/cluster
    kubectl --namespace gitpod get certificate https-certificates -oyaml \
      | kubectl neat \
      > /workspace/cluster/https-certificates.certificate.yaml
    bat --pager=never -lyaml /workspace/cluster/https-certificates.certificate.yaml


    kubectl --namespace gitpod get secret https-certificates -oyaml \
      | kubectl neat \
      > /workspace/cluster/https-certificates.secret.yaml
    bat --pager=never -lyaml /workspace/cluster/https-certificates.secret.yaml
}

__gitpod_restore_certs() {
    kubectl create namespace gitpod

    kubectl --namespace gitpod apply -f /workspace/cluster/https-certificates.secret.yaml
    kubectl --namespace gitpod apply -f /workspace/cluster/https-certificates.certificate.yaml
}


alias gitpod-reload-dotfiles="__gitpod_reload_dotfiles"

alias gitpod-get-license="__gitpod_license"
alias gitpod-kotsup="__gitpod_kotsup"
alias gitpod-kotsdash="__gitpod_kotsdash"