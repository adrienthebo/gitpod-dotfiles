#!/usr/bin/env bash

FUNCTION_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

AUTOINIT_DIR="$FUNCTION_DIR/autoinit.d"


__autoinit_debug() {
    if [[ -n $__AUTOINIT_DEBUG ]]; then
        echo $@
    fi
}

__autoinit_handle() {
    local ARGV="$@"
    local CMD="$1"
    
    # shellcheck disable=2199
    if [[ ${__autoinit_plugins[@]} =~ $CMD ]]; then
        # shellcheck disable=2068
        echo "$AUTOINIT_DIR/autoinit-$CMD" autorun $@
        "$AUTOINIT_DIR/autoinit-$CMD" autorun $@
    else
        echo "$(basename $SHELL): $CMD: command not found"
    fi
    return 127
}

__autoinit_alias_fn() {
    declare -F $1 > /dev/null || return 1
    eval "$(echo "${2}()"; declare -f ${1} | tail -n +2)"
}

__autoinit_register() {
    local plugin="$1"

    __autoinit_plugins+=("$plugin")
    __autoinit_debug "autoinit-register plugins: '${__autoinit_plugins}'"

    __autoinit_unloaded_plugins+=("$plugin")
    __autoinit_debug "autoinit-register unloaded='${__autoinit_unloaded_plugins}'"
}

__autoinit_autoload() {
    local plugin

    __autoinit_debug "autoinit-autoload: unloaded=${__autoinit_unloaded_plugins[*]}"

    for plugin in ${__autoinit_unloaded_plugins[*]}; do
        __autoinit_debug "autoinit-autoload: checking '$plugin'"

        if "${AUTOINIT_DIR}/autoinit-$plugin" is-ready; then
            __autoinit_debug "autoinit-autoload: initializing $plugin"

            eval "$("${AUTOINIT_DIR}/autoinit-$plugin" init)"
            
            __autoinit_unloaded_plugins=("${__autoinit_unloaded_plugins[@]/$plugin}" )
        else
            __autoinit_debug "autoinit-autoload: $plugin already loaded"
        fi
    done
}

__autoinit_status() {
    local plugin

    (
        echo "Name Status Loaded"
        for plugin in ${__autoinit_plugins[*]}; do
            echo " \
                $plugin \
                $("${AUTOINIT_DIR}/autoinit-$plugin" is-installed && echo "installed" || echo "not-installed") \
                $("${AUTOINIT_DIR}/autoinit-$plugin" is-active && echo "active" || echo "inactive") \
            "

        done
    ) | sed -e 's/ \+/ /g' | column -t

}

__autoinit_init() {
    echo "autoinit: enabling shell hooks"

    declare -ag __autoinit_plugins
    declare -ag __autoinit_unloaded_plugins

    __autoinit_alias_fn "__autoinit_handle" "command_not_found_handle"
    
    __autoinit_register "asdf"
    __autoinit_register "kubectl-krew"
}

__autoinit_unload() {
    echo "autoinit: unloading"
    __autoinit_clear
}

__autoinit_clear() {
    unset __autoinit_plugins
    unset __autoinit_unloaded_plugins
    unset command_not_found_handle
}

__autoinit_run() {
    local plugin=$1
    shift
    "${AUTOINIT_DIR}/autoinit-$plugin" $@
}

autoinit() {
    local cmd=$1
    
    case "$cmd" in
        init)
            __autoinit_clear
            __autoinit_init \
                && __autoinit_autoload \
                && __autoinit_status
            ;;
        unload)
            __autoinit_unload
            ;;
        autoload) __autoinit_autoload ;;
        status|list) __autoinit_status     ;;
        help|*) echo "usage: autoinit [init|autoload|unload|status|help]"
    esac
}

__autoinit_clear