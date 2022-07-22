#!/usr/bin/env bash

declare -A _features

register_feature() {
    name="$1"
    init_fn="$2"
    load_fn="$3"
    status_fn="$4"
    
    _features[$name]="$name $init_fn $load_fn $status_fn"
}

announce_features() {
    echo "Available features"
    for key in "${!_features[@]}"; do
        local _feature f_name init_fn load_fn status_fn

        declare -a _feature
        read -ra _feature <<< "${_features[$key]}"
        
        f_name="${_feature[0]}"
        status_fn="${_feature[3]}"
        
        status=$($status_fn)
        echo -e "\t$f_name: $status"
    done
}

_f_init_gcloud() {
    echo "Initializing gcloud"
}

_f_load_gcloud() {
    echo "Loading gcloud"
}

_f_status_gcloud() {
    echo "ready"
    return 0
}

register_feature "gcloud" "_f_init_gcloud" "_f_load_gcloud" "_f_status_gcloud"