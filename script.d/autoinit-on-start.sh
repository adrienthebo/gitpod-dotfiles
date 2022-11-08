#!/usr/bin/env bash

__LIBDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../lib")"

source "$__LIBDIR/autoinit.sh"

autoinit init

declare -a autoinit_plugins=(direnv atuin lsd fzf)

for plugin in "${autoinit_plugins[@]}"; do
    # TODO: `autoinit exec` is an internal tool; replace the dev call with something smarter
    if ! autoinit exec "$plugin" is-installed; then
        autoinit install "$plugin"
    fi
    autoinit init-plugin "$plugin"
done

for plugin in atuin; do
    autoinit configure "$plugin"
done
