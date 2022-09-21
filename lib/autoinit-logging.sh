#!/usr/bin/env bash

__LIBDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
source "${__LIBDIR}/colors.sh"


__autoinit_debug() {
    if [[ -n $__AUTOINIT_DEBUG ]]; then
        echo "$(color grey "$@")" 1>&2
    fi
}


__autoinit_warn() {
    # shellcheck disable=SC2005
    echo "$(color yellow bold "Warning: $@")" 1>&2
}


__autoinit_error() {
    # shellcheck disable=SC2005
    echo "$(color red bold "Error: $@")" 1>&2
}


__autoinit_info() {
    # shellcheck disable=SC2005
    echo "$(color green "$@")" 1>&2
}


__autoinit_notice() {
    echo "$(color blue "$@")" 1>&2
}


__autoinit_log() {
    echo "$@" 1>&2
}
