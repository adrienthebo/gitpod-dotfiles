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

alias kotsup="kubectl kots install gitpod --namespace gitpod --shared-password=gitpod --no-port-forward"

kotsdash() {
    local __kotsport="$(( ( $RANDOM % 63535 ) + 2000 ))"

    (
        sleep 2
        $BROWSER "http://localhost:$__kotsport"
    ) &

    kubectl kots admin-console --namespace gitpod --port "$__kotsport"
}
