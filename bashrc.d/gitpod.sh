#!/bin/bash

eval "$(gp env -e)"

if [[ -f "$GITPOD_REPO_ROOT/.env" ]]; then
    echo "Loading environment variables from $GITPOD_REPO_ROOT/.env"
    set -x
    source "$GITPOD_REPO_ROOT/.env"
    set +x
fi

reload_dotfiles() {
    source "$HOME/.dotfiles/script/reload"
}