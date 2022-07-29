#!/usr/bin/env bash

if [[ -f "$HOME/.dotfiles/lib/autoinit.sh" ]]; then
    source "$HOME/.dotfiles/lib/autoinit.sh"
    autoinit init
fi