#!/bin/bash

eval "$(gp env -e)"

# TODO: move this to `profile.d` when that directory is wired up.
export BROWSER="/ide/bin/helpers/browser.sh"

if [[ -f "$GITPOD_REPO_ROOT/.env" ]]; then
    echo "Loading environment variables from $GITPOD_REPO_ROOT/.env"
    set -x
    source "$GITPOD_REPO_ROOT/.env"
    set +x
fi

__gitpod_reload_dotfiles() {
    source "$HOME/.dotfiles/script/reload"
}
alias gitpod-reload-dotfiles="__gitpod_reload_dotfiles"

alias gitpod-kotsup="kubectl kots install gitpod --namespace gitpod --shared-password=gitpod --no-port-forward"

__gitpod_kotsdash() {
    local __kotsport="$(( ( $RANDOM % 63535 ) + 2000 ))"

    (
        sleep 2
        $BROWSER "http://localhost:$__kotsport"
    ) &

    kubectl kots admin-console --namespace gitpod --port "$__kotsport"
}
alias gitpod-kotsdash="__gitpod_kotsdash"

__gitpod_license() {
    gsutil cp "gs://adrien-self-hosted-testing-5k4-license-25500/license.yaml" .
}

alias gitpod-get-license="__gitpod_license"