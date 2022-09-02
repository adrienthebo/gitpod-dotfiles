#!/usr/bin/env bash

__LIBDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../lib")"

source "$__LIBDIR/autoinit.sh"

autoinit init

# TODO: `autoinit exec` is an internal tool; replace the dev call with something smarter
if ! autoinit exec direnv is-installed; then
    autoinit install direnv
fi

if ! autoinit exec atuin is-installed; then
    autoinit install atuin
fi