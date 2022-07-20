#!/usr/bin/env bash

source "$HOME/.dotfiles/lib/functions.sh"

pathmunge "$HOME/.local/bin" after
pathmunge "$HOME/.krew/bin" after

[[ -f $HOME/.asdf/asdf.sh ]] && source $HOME/.asdf/asdf.sh