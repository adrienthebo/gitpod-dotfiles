#!/usr/bin/env bash

declare -A _features

register_feature() {
    name="$1"
    status_fn="$2"
    init_fn="$3"
    load_fn="$4"
    autoload_fn="$5"

    _features[$name]="$name $status_fn $init_fn $load_fn $autoload_fn"
}

announce_features() {
    echo "Available features"
    for key in "${!_features[@]}"; do
        local _feature f_name status_fn init_fn load_fn autoload_fn

        declare -a _feature
        read -ra _feature <<< "${_features[$key]}"

        f_name="${_feature[0]}"
        status_fn="${_feature[1]}"

        status=$($status_fn)
        echo -e "\t$f_name: $status"
    done
}

load_feature() {
    local key
    key=$1

    local _feature f_name status_fn init_fn load_fn autoload_fn

    f_name="${_feature[0]}"
    status_fn=${_feature[1]}
    load_fn=${_feature[3]}

    $load_fn
    status=$($status_fn)
    echo -e "\t$f_name: ${status}"
}

init_feature() {
    local key
    key=$1

    local _feature f_name status_fn init_fn load_fn autoload_fn


    declare -a _feature
    read -ra _feature <<< "${_features[$key]}"

    f_name="${_feature[0]}"
    status_fn=${_feature[1]}
    init_fn=${_feature[2]}

    $init_fn
    $load_fn
    status=$($status_fn)
    echo -e "\t$f_name: ${status}"
}

autoload_features() {
    echo "autoloading features"
    for key in "${!_features[@]}"; do
        local _feature f_name status_fn init_fn load_fn autoload_fn

        declare -a _feature
        read -ra _feature <<< "${_features[$key]}"

        f_name="${_feature[0]}"
        status_fn=${_feature[1]}
        load_fn=${_feature[3]}
        autoload_fn=${_feature[4]}

        $autoload_fn
        if [[ $? -eq 0 ]]; then
            echo -e "\t$f_name: autoloading"
            $load_fn
            status=$($status_fn)
            echo -e "\t$f_name: ${status}"
        fi
    done
}

_f_status_gcloud() {
    echo "ready"
    return 0
}

_f_init_gcloud() {
    echo "feature/gcloud: initializing plugin"
}

_f_load_gcloud() {
    echo "feature/gcloud: Loading"
}

_f_autoload_gcloud() {
    if [[ -n $AUTOLOAD_GCLOUD ]]; then
        echo "feature/gcloud: should autoload"
        return 0
    else
        echo "feature/gcloud: should not autoload"
        return 1
    fi
}

_f_asdf_status() {
    if ! [[ -d $HOME/.asdf ]]; then
        echo "absent"
        return 1
    elif [[ -z $ASDF_DIR ]]; then
        echo "inactive"
        return 1
    else
        echo "ready"
        return 0
    fi
}

_f_asdf_init() {
    echo "initialing asdf"

    if ! [[ -d ~/.asdf ]]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
        source ~/.asdf/asdf.sh
    fi
}

_f_asdf_load() {
    source ~/.asdf/asdf.sh
    return 0
}

_f_asdf_autoload() {
    if [[ -n $FEATURE_ASDF_DISABLE ]]; then
        return 1
    else
        return 0
    fi
}

register_feature "gcloud" "_f_status_gcloud" "_f_init_gcloud" "_f_load_gcloud" "_f_autoload_gcloud"
register_feature "asdf" "_f_asdf_status" "_f_asdf_init" "_f_asdf_load" "_f_asdf_autoload"