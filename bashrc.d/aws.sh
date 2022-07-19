#!/usr/bin/env bash

init_aws() {
    
    eval "$(gp env -e)"
    
    aws sso login
    
    if ! [[ -z "$EKS_CLUSTER" ]]; then
        aws eks update-kubeconfig --name "$EKS_CLUSTER"
    fi
}