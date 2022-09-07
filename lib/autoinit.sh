#!/usr/bin/env bash

__LIBDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

__AUTOINIT_DIR="${__LIBDIR}/autoinit.d"

source "${__LIBDIR}/colors.sh"


__autoinit_debug() {
    if [[ -n $__AUTOINIT_DEBUG ]]; then
        echo $@ 1>&2
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


__autoinit_log() {
    echo "$@" 1>&2
}


__autoinit_handle() {
    local argv="$@"
    local cmd="$1"

    # shellcheck disable=2199
    local plugin
    for plugin in "${__autoinit_plugins[@]}"; do
        if [[ "${plugin}" = $cmd ]]; then
            # shellcheck disable=2005
            echo "$(color blue "autoinit: handling $cmd")"
            __autoinit_autorun "$cmd" $argv
            local rc=$?

            echo "$(color blue "autoinit: $cmd auto-installed, run 'autoinit init-plugin $plugin' to update your environment")"

            return $?
        fi
    done
    echo "$(basename "$SHELL"): $cmd: command not found"
    return 127
}

__autoinit_install() {
    local plugin plugins
    plugins=($1)
    for plugin in "${plugins[@]}"; do
      "$__AUTOINIT_DIR/autoinit-$plugin" install
      __autoinit_activate_plugin "$plugin"
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
    local handler="$2"
    __autoinit_debug "autoinit-register: registering '${plugin}' with handler '${handler}'"

    __autoinit_plugins+=("$plugin")
    __autoinit_command_handlers[$plugin]="$handler"

    __autoinit_unloaded_plugins+=("$plugin")
    __autoinit_debug "autoinit-register: registered plugins='${__autoinit_plugins[@]}', unloaded='${__autoinit_unloaded_plugins[@]}'"
}


__autoinit_activate() {
    local plugin

    for plugin in ${__autoinit_unloaded_plugins[*]}; do
        __autoinit_activate_plugin "$plugin"
    done
}


__autoinit_activate_plugin() {
    local plugin="$1"
    __autoinit_debug "autoinit-activate: checking '$plugin'"

    if "${__AUTOINIT_DIR}/autoinit-$plugin" is-ready; then
        __autoinit_debug "autoinit-activate: activating $plugin"

        eval "$("${__AUTOINIT_DIR}/autoinit-$plugin" init)"

        __autoinit_unloaded_plugins=("${__autoinit_unloaded_plugins[@]/$plugin}" )
    else
        __autoinit_debug "autoinit-activate: $plugin already loaded"
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
    declare -Ag __autoinit_command_handlers
    declare -ag __autoinit_unloaded_plugins

    __autoinit_alias_fn "__autoinit_handle" "command_not_found_handle"

    __autoinit_register "asdf"         "${__AUTOINIT_DIR}/autoinit-asdf"
    __autoinit_register "atuin"        "${__AUTOINIT_DIR}/autoinit-atuin"
    __autoinit_register "aws"          "${__AUTOINIT_DIR}/autoinit-aws"
    __autoinit_register "bat"          "${__AUTOINIT_DIR}/autoinit-bat"
    __autoinit_register "cmctl"        "${__AUTOINIT_DIR}/autoinit-cmctl"
    __autoinit_register "direnv"       "${__AUTOINIT_DIR}/autoinit-direnv"
    __autoinit_register "eksctl"       "${__AUTOINIT_DIR}/autoinit-eksctl"
    __autoinit_register "fzf"          "${__AUTOINIT_DIR}/autoinit-fzf"
    __autoinit_register "gcloud"       "${__AUTOINIT_DIR}/autoinit-gcloud"
    __autoinit_register "helm"         "${__AUTOINIT_DIR}/autoinit-helm"
    __autoinit_register "jiq"          "${__AUTOINIT_DIR}/autoinit-jiq"
    __autoinit_register "kubectl"      "${__AUTOINIT_DIR}/autoinit-kubectl"
    __autoinit_register "kubectl-kots" "${__AUTOINIT_DIR}/autoinit-kubectl-kots"
    __autoinit_register "kubectl-krew" "${__AUTOINIT_DIR}/autoinit-kubectl-krew"
    __autoinit_register "lsd"          "${__AUTOINIT_DIR}/autoinit-lsd"
    __autoinit_register "tldr"         "${__AUTOINIT_DIR}/autoinit-tldr"
}


__autoinit_init_plugin() {
    local plugins
    plugins=($@)

    if [[ ${#plugins[@]} -lt 1 ]]; then
        __autoinit_error "No plugins passed to init-plugin"
        __autoinit_log "Usage: autoinit init-plugin PLUGIN ..."
        return 1
    fi

    local plugin
    for plugin in "${plugins[@]}"; do
        eval "$("${__AUTOINIT_DIR}/autoinit-$plugin" init)"
    done
}


__autoinit_exec() {
    local plugin="$1"
    shift
    local argv="$@"

    if [[ -z $plugin ]] || [[ -z $argv ]]; then
        echo "usage: autoinit exec PLUGIN COMMAND" 1>&2
        return 1
    fi

    "${__AUTOINIT_DIR}/autoinit-$plugin" $@
}

__autoinit_edit() {
    local plugin="$1"

    if [[ -z $plugin ]]; then
        echo "usage: autoinit _edit PLUGIN" 1>&2
        return 1
    fi
    
    if [[ -z $EDITOR ]]; then
        __autoinit_error "\$EDITOR is unset, cannot edit '${__AUTOINIT_DIR}/autoinit-$plugin'"
        return 1
    fi

    $EDITOR "${__AUTOINIT_DIR}/autoinit-$plugin"
}


__autoinit_configure() {
    local plugin="$1"

    if [[ -z $plugin ]]; then
        echo "usage: autoinit configure PLUGIN" 1>&2
        return 1
    fi

    "${__AUTOINIT_DIR}/autoinit-$plugin" configure
}


__autoinit_describe() {
    local plugin="$1"

    if [[ -z $plugin ]]; then
        echo "usage: autoinit describe PLUGIN" 1>&2
        return 1
    fi

    "${__AUTOINIT_DIR}/autoinit-$plugin" describe
}


__autoinit_unload() {
    echo "autoinit: unloading"
    __autoinit_clear
}


__autoinit_clear() {
    unset __autoinit_plugins
    unset __autoinit_command_handlers
    unset __autoinit_unloaded_plugins
    unset command_not_found_handle
}


__autoinit_topic() {
    local topic="$1"

    case "$topic" in
        "")
            echo "Available topics: [hooks|lifecycle]"
            ;;

        "hooks")
            cat - <<HOOKS
# autoinit hooks

todo: document 'command_not_found_handle'
todo: document binstubs

HOOKS
            ;;
        "lifecycle")
            cat - <<LIFECYCLE
# autoinit plugin lifecycles

## Lifecycle states

- absent
- installed/inactive/ready
- activated
- shadowed

## Lifecycle operations

    install     Install the plugin binaries onto the system. May not necessarily
                make the plugin binaries available via \$PATH.

    activate    Make a given plugin's binaries available via \$PATH. Only needed
                if a plugin can be present on a system without being on the path;
                installing a package typically services to make that plugin active.

    init        Load shell completions and such. Things that improve quality of life
                when using a plugin but aren't critical.

                In contrast to activation, which should only happen if the plugin
                can't be executed, init should happen whenever the shell is launched.
                An initialization step shouldn't be required to make a plugin 
                operational; required logic should live in activation.

    configure   Fetch application credentials, update local caches, any sort of
                heavyweight operation that is necessary to make a plugin operational
                but shouldn't be run whenever a shell initializes.
                
    autoload    Perform all work needed to make a plugin operational. Install the
                plugin if absent, activate the plugin, run plugin initialization,
                and finally configure the plugin.
LIFECYCLE
          ;;
        *)
          __autoinit_error "Unknown topic '$topic'"
          return 1
          ;;
    esac
}


__autoinit_usage() {
    echo "usage: autoinit [init|init-plugin|install|activate|unload|status|help]"
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
        activate        Activate all installed but inactive plugins
        autoload        Install, initialize, and configure a plugin
        autorun         Run (and initialize if necessary) a plugin command
        configure       Run plugin configuration (such as authorization and heavyweight setup)
        describe        Display plugin configuration information

    Developer commands:
        exec            Run an autoinit plugin subcommand

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
                && __autoinit_activate \
                && __autoinit_status
            ;;

        status|list)
            __autoinit_status
            ;;

        reload)
            __autoinit_clear
            source "${BASH_SOURCE[0]}"
            __autoinit_init \
                && __autoinit_activate \
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
            __autoinit_activate
            ;;

        exec)
            # shellcheck disable=SC2086
            __autoinit_exec $args
            ;;

        _edit)
            __autoinit_edit "${args[0]}"
            ;;

        activate)
            __autoinit_activate
            ;;

        autorun)
            __autoinit_autorun "$cmd" "${args[@]}"
            ;;

        configure)
            __autoinit_configure "${args[0]}"
            ;;

        describe)
            __autoinit_describe "${args[0]}"
            ;;
            
        topic)
            __autoinit_topic "${args[0]}"
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