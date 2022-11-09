#!/usr/bin/env bash

brew install chezmoi

chezmoi init --source $HOME/.dotfiles
chezmoi apply -v