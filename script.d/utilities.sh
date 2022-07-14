#!/usr/bin/env bash

if ! [[ -d $HOME/.local/bin ]]; then
    mkdir "$HOME/.local/bin"
fi

curl -L https://github.com/fiatjaf/jiq/releases/download/v0.7.2/jiq_linux_amd64 -o "$HOME/.local/bin/jiq"
chmod +x "$HOME/.local/bin/jiq"

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2

source ~/.asdf/asdf.sh
asdf plugin-add kubectl https://github.com/asdf-community/asdf-kubectl.git

