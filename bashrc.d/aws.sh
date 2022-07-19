#!/usr/bin/env bash

init_aws() {
    
    eval "$(gp env -e)"
    
    aws sso login
    
    if ! [[ -z "$EKS_CLUSTER" ]]; then
        aws eks update-kubeconfig --name "$EKS_CLUSTER"
    fi
}

if command -v aws_completer 1>/dev/null; then
    complete -C '/usr/local/bin/aws_completer' aws
fi