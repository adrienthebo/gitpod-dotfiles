#!/usr/bin/env bash

source "$HOME/.dotfiles/lib/functions.sh"

if [[ -f "$HOME/.dotfiles/lib/autoinit.sh" ]]; then
    source "$HOME/.dotfiles/lib/autoinit.sh"
    autoinit init
    
    if autoinit exec atuin is-installed; then
        autoinit init-plugin atuin
    fi
fi

pathmunge "$HOME/.local/bin" after
pathmunge "$HOME/.krew/bin" after

[[ -f $HOME/.asdf/asdf.sh ]] && source $HOME/.asdf/asdf.sh

alias k="kubectl"
alias tf="terraform"

if command -v direnv 1>/dev/null; then
    eval "$(direnv hook "$(basename "$SHELL")")"
fi