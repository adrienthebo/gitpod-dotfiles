#!/usr/bin/env bash

# Initialize AWS and eks configs.
#
# Environment_variables:
#   - EKS_CLUSTER
#
init_aws() {
    echo -e "Initializing AWS\n"

    eval "$(gp env -e)"

    aws_vars=(EKS_CLUSTER)

    for evar in "${aws_vars[@]}"; do
        echo "${evar}=${!evar}"
    done
    
    aws sso login
    
    if ! [[ -z "$EKS_CLUSTER" ]]; then
        aws eks update-kubeconfig --name "$EKS_CLUSTER"
    fi
}

if command -v aws_completer 1>/dev/null; then
    complete -C '/usr/local/bin/aws_completer' aws
fi