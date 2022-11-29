#!/usr/bin/env bash

source "$HOME/.dotfiles/lib/functions.sh"

if [[ -f "$HOME/.dotfiles/lib/autoinit.sh" ]]; then
    source "$HOME/.dotfiles/lib/autoinit.sh"
    autoinit init

    declare -a autoinit_plugins=(direnv atuin lsd fzf)

    for plugin in "${autoinit_plugins[@]}"; do
        # TODO: `autoinit exec` is an internal tool; replace the dev call with something smarter
        autoinit init-plugin "$plugin"
    done
fi

alias k="kubectl"
alias tf="terraform"

export LESS="-iSQR"

cht() {
    curl https://cht.sh/$1 | /usr/bin/env less
}

precmd_stty_sane() {
    stty sane
}

precmd_functions+=(precmd_stty_sane)