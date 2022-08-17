#!/usr/bin/env bash

__LIBDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

__AUTOINIT_DIR="${__LIBDIR}/autoinit.d"

source "${__LIBDIR}/colors.sh"


__autoinit_debug() {
    if [[ -n $__AUTOINIT_DEBUG ]]; then
        echo $@ 1>&2
    fi
}

__autoinit_handle() {
    local argv="$@"
    local cmd="$1"

    # shellcheck disable=2199
    local plugin
    for plugin in "${__autoinit_plugins[@]}"; do
        if [[ "${plugin}" = $cmd ]]; then
            # shellcheck disable=2068
            echo "$(color blue "autoinit: handling $cmd")"
            __autoinit_autorun "$cmd" $argv
            local rc=$?

            if [[ $(type -t "$plugin") = "function" ]]; then
                echo "$(color blue "autoinit: $cmd auto-installed, run 'autoinit autoload' to update your environment")"
            fi

            return $?
        fi
    done
    echo "$(basename $SHELL): $cmd: command not found"
    return 127
}

__autoinit_install() {
    local plugin plugins
    plugins=($1)
    for plugin in "${plugins[@]}"; do
      "$__AUTOINIT_DIR/autoinit-$plugin" install
      __autoinit_autoload_plugin "$plugin"
    done
}


__autoinit_autorun() {
    local cmd="$1"
    shift

    "$__AUTOINIT_DIR/autoinit-$cmd" autorun $@
}


__autoinit_alias_fn() {
    declare -F $1 > /dev/null || return 1
    eval "$(echo "${2}()"; declare -f ${1} | tail -n +2)"
}


__autoinit_register() {
    local plugin="$1"
    __autoinit_debug "autoinit-register: registering '${plugin}'"

    __autoinit_plugins+=("$plugin")
    __autoinit_unloaded_plugins+=("$plugin")
    __autoinit_debug "autoinit-register: registered plugins='${__autoinit_plugins[@]}', unloaded='${__autoinit_unloaded_plugins[@]}'"
}


__autoinit_autoload() {
    local plugin

    for plugin in ${__autoinit_unloaded_plugins[*]}; do
        __autoinit_autoload_plugin "$plugin"
    done
}


__autoinit_autoload_plugin() {
    local plugin="$1"
    __autoinit_debug "autoinit-autoload: checking '$plugin'"

    if "${__AUTOINIT_DIR}/autoinit-$plugin" is-ready; then
        __autoinit_debug "autoinit-autoload: initializing $plugin"

        eval "$("${__AUTOINIT_DIR}/autoinit-$plugin" init)"

        __autoinit_unloaded_plugins=("${__autoinit_unloaded_plugins[@]/$plugin}" )
    else
        __autoinit_debug "autoinit-autoload: $plugin already loaded"
    fi
}

__autoinit_status() {
    local plugin

    (
        echo "Name Status Loaded Shadowed"
        for plugin in ${__autoinit_plugins[*]}; do
            echo " \
                $plugin \
                $(
                    "${__AUTOINIT_DIR}/autoinit-$plugin" is-installed \
                        && color green bold "installed" \
                        || color grey italic "not-installed"
                ) \
                $(
                    "${__AUTOINIT_DIR}/autoinit-$plugin" is-active \
                        && color green bold "active" \
                        || color grey italic "inactive"
                ) \
                $(
                    "${__AUTOINIT_DIR}/autoinit-$plugin" is-shadowed \
                        && color grey bold "ok" \
                        || color yellow bold "shadowed"
                ) \
            "

        done | sort
    ) | sed -e 's/ \+/ /g' | column -t

}

__autoinit_init() {
    echo "autoinit: enabling shell hooks"

    declare -ag __autoinit_plugins
    declare -ag __autoinit_unloaded_plugins

    __autoinit_alias_fn "__autoinit_handle" "command_not_found_handle"

    __autoinit_register "asdf"
    __autoinit_register "kubectl-krew"
    __autoinit_register "gcloud"
    __autoinit_register "kubectl-kots"
    __autoinit_register "helm"
    __autoinit_register "cmctl"
    __autoinit_register "aws"
}


__autoinit_init_plugin() {
    local plugin plugins
    plugins=($@)
    for plugin in "${plugins[@]}"; do
        eval "$("${__AUTOINIT_DIR}/autoinit-$plugin" init)"
    done
}


__autoinit_exec() {
    local plugin="$1"
    shift
    local argv="$@"

    "${__AUTOINIT_DIR}/autoinit-$plugin" $@
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


__autoinit_usage() {
    echo "usage: autoinit [init|init-plugin|install|autoload|unload|status|help]"
}


__autoinit_help() {
    cat - <<EOD
$(__autoinit_usage)

Commands:
EOD

    cat - <<EOD
    Manage autoinit:
        init            Initialize autoinit
        list            List all plugins
        reload          Reload autoinit and autoinit plugins
        unload          Unload autoinit from the environment

    Interact with autoinit plugins:
        init-plugin     Initialize an installed autoinit plugin
        install         Install an autoinit plugin
        autoload        Initialize all plugins that are ready for use
        autorun         Run (and initialize if necessary) a plugin command

    Other commands:
        help            Show this help

EOD
}

autoinit() {
    local cmd=$1
    shift
    local args="$@"

    case "$cmd" in
        init)
            __autoinit_clear
            __autoinit_init \
                && __autoinit_autoload \
                && __autoinit_status
            ;;

        status|list)
            __autoinit_status
            ;;

        reload)
            __autoinit_clear
            source "${BASH_SOURCE[0]}"
            __autoinit_init \
                && __autoinit_autoload \
                && __autoinit_status
            ;;

        unload)
            __autoinit_unload
            ;;

        init-plugin)
            __autoinit_init_plugin "${args[@]}"
            ;;

        install)
            __autoinit_install "${args[@]}"
            __autoinit_autoload
            ;;

        exec)
            # shellcheck disable=SC2086
            __autoinit_exec $args
            ;;

        autoload)
            __autoinit_autoload
            ;;

        autorun)
            __autoinit_autorun "$cmd" "${args[@]}"
            ;;

        help|"")
            __autoinit_help
            ;;
        *)
            echo "Error: unknown command ${cmd}" 1>&2
            echo "$(__autoinit_usage)" 1>&2
            ;;
    esac
}

__autoinit_clear