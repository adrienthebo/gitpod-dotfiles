#!/bin/bash

init_gcloud() {
    echo -e "Initializing GCP and gcloud\n"

    eval "$(gp env -e)"
    local gcp_vars
    gcp_vars=(GCLOUD_ACCOUNT GCLOUD_PROJECT GCLOUD_COMPUTE_REGION GCLOUD_COMPUTE_ZONE GKE_CLUSTER)

    for evar in "${gcp_vars[@]}"; do
        echo "${evar}=${!evar}"
    done

    if ! command -v gcloud 1>/dev/null 2>/dev/null; then
        if ! [[ -d "$HOME/.asdf/plugins/gcloud" ]]; then
            asdf plugin add gcloud
        fi

        local gcloud_version
        gcloud_version="$(asdf list all gcloud | tail -n1)"
        asdf install gcloud "$gcloud_version"
        asdf global gcloud "$gcloud_version"
    fi

    if [[ -f "$HOME/.config/gcloud/configurations/config_gitpod" ]]; then
        gcloud config configurations activate gitpod
    else
        gcloud config configurations create gitpod
    # Or activate
    fi

    if gcloud auth print-access-token 1>/dev/null 2>/dev/null; then
        echo "GCP credentials already present (account: "$(gcloud auth list --format='get(account)')")"
    else
        gcloud auth login --update-adc
    fi

    if [[ -n "$GCLOUD_ACCOUNT" ]]; then
        gcloud config set account "$(gp env | awk -F =  '/GCLOUD_ACCOUNT/ { print $2 }')"
    fi

    if [[ -n "$GCLOUD_PROJECT" ]]; then
        gcloud config set core/project "$(gp env | awk -F =  '/GCLOUD_PROJECT/ { print $2 }')"
    fi

    if [[ -n "$GCLOUD_COMPUTE_REGION" ]]; then
        gcloud config set compute/region "$(gp env | awk -F =  '/GCLOUD_COMPUTE_REGION/ { print $2 }')"
    fi

    if [[ -n "$GCLOUD_COMPUTE_ZONE" ]]; then
        gcloud config set compute/zone "$(gp env | awk -F =  '/GCLOUD_COMPUTE_ZONE/ { print $2 }')"
    fi

    if ! gcloud auth list --format=json | grep -q ACTIVE; then
        gcloud auth login
    fi

    if [[ -n "$GKE_CLUSTER" ]]; then
        if ! command -v gke-gcloud-auth-plugin 1>/dev/null 2>/dev/null; then
            gcloud components install gke-gcloud-auth-plugin --quiet
            asdf reshim gcloud
        fi

        gcloud container clusters get-credentials "${GKE_CLUSTER}"
    fi
}

# gp env GCP_CREDENTIALS="$(sqlite3 ~/.config/gcloud/credentials.db .dump | base64 --wrap=0)"
if gp env |grep -q 'GCP_CREDENTIALS' && ! [[ -f ~/.config/gcloud/credentials.db ]]; then
    echo "Restoring GCP credentials"
    mkdir -p ~/.config/gcloud
    gp env \
        | sed -ne '/GCP_CREDENTIALS/s/^[^=]\+=\(.*\)$/\1/p' \
        | base64 -d \
        | sqlite3 ~/.config/gcloud/credentials.db
fi

sleep 1

#  gp env GCP_ACCESS_TOKENS="$(sqlite3 ~/.config/gcloud/access_tokens.db .dump | base64 --wrap=0)"
if gp env |grep -q 'GCP_ACCESS_TOKENS' && ! [[ -f ~/.config/gcloud/access_tokens.db ]]; then
    mkdir -p ~/.config/gcloud
    echo "Restoring GCP access tokens"
    gp env \
        | sed -ne '/GCP_ACCESS_TOKENS/s/^[^=]\+=\(.*\)$/\1/p' \
        | base64 -d \
        | sqlite3 ~/.config/gcloud/access_tokens.db
fi