#!/bin/bash

init_gcloud() {
    echo -e "Initializing GCP and gcloud\n"

    eval "$(gp env -e)"
    local gcp_vars
    gcp_vars=(GCLOUD_ACCOUNT GCLOUD_PROJECT GCLOUD_COMPUTE_REGION GCLOUD_COMPUTE_ZONE)

    for evar in "${gcp_vars[@]}"; do
        echo "${evar}=${!evar}"
    done

    if ! command -v gcloud; then
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
}