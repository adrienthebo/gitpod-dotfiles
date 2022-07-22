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

require_feature() {
    local key
    key=$1

    local _feature f_name status_fn init_fn load_fn autoload_fn
    declare -a _feature
    read -ra _feature <<< "${_features[$key]}"

    f_name="${_feature[0]}"
    status_fn=${_feature[1]}
    load_fn=${_feature[3]}


    $status_fn
    statuscode=$?
    "feature $key status: $status_fn -> $statuscode"

    if [[ $statuscode -ne 0 ]]; then
        init_feature "$key"
    fi

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

_f_asdf_status() {
    echo "asdf status"
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

register_feature "asdf" "_f_asdf_status" "_f_asdf_init" "_f_asdf_load" "_f_asdf_autoload"

_f_gcloud_status() {
    if command -v gcloud 1>/dev/null; then
        echo "ready"
        return 0
    else
        echo "absent"
        return 1
    fi
}

_f_gcloud_init() {
    echo "feature/gcloud: initializing plugin"
}

_f_gcloud_load() {
    echo "feature/gcloud: Loading"
}

_f_gcloud_autoload() {
    if [[ -n $AUTOLOAD_GCLOUD ]]; then
        echo "feature/gcloud: should autoload"
        return 0
    else
        echo "feature/gcloud: should not autoload"
        return 1
    fi
}

register_feature "gcloud" "_f_gcloud_status" "_f_gcloud_init" "_f_gcloud_load" "_f_gcloud_autoload"

_f_kubectl_status() {
    if command -v kubectl 1>/dev/null; then
        echo "ready"
        return 0
    else
        echo "absent"
        return 1
    fi
}

_f_kubectl_init() {
    local _kubectl_version
    _kubectl_version=${KUBECTL_VERSION:-latest}

    echo "requiring feature"
    require_feature asdf

    asdf plugin add kubectl
    asdf install kubectl "$_kubectl_version"
    asdf global kubectl "$_kubectl_version"
}

_f_kubectl_load() {
    asdf global kubectl "$_kubectl_version"
}

_f_kubectl_autoload() {
    if [[ -n $KUBECTL_VERSION ]]; then
        return 0
    else
        return 1
    fi
}

register_feature "kubectl" "_f_kubectl_status" "_f_kubectl_init" "_f_kubectl_load" "_f_kubectl_autoload"