#!/usr/bin/env bash

source "$HOME/.dotfiles/lib/functions.sh"

if [[ -f "$HOME/.dotfiles/lib/autoinit.sh" ]]; then
    source "$HOME/.dotfiles/lib/autoinit.sh"
    autoinit init
    
    declare -a autoinit_plugins=(direnv atuin lsd)

    for plugin in "${autoinit_plugins[@]}"; do
        # TODO: `autoinit exec` is an internal tool; replace the dev call with something smarter
            autoinit init-plugin "$plugin"
        fi
    done
fi

pathmunge "$HOME/.local/bin" after
pathmunge "$HOME/.krew/bin" after

alias k="kubectl"
alias tf="terraform"

if command -v direnv 1>/dev/null; then
    eval "$(direnv hook "$(basename "$SHELL")")"
fi