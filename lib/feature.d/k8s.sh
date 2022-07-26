#!/usr/bin/env bash


source "$HOME/.dotfiles/lib/functions.sh"
source "$(realpath $(dirname $0))/00_core.sh"


install_krew() {
    if ! [[ -d ~/.krew ]]; then
        (
          set -x; cd "$(mktemp -d)" &&
          OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
          ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
          KREW="krew-${OS}_${ARCH}" &&
          curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
          tar zxvf "${KREW}.tar.gz" &&
          ./"${KREW}" install krew
        )

    fi
}


install_krew_plugin() {
    local plugin
    plugin=$1

    if ! kubectl-krew list | grep -q "$plugin"; then
        kubectl-krew install "$plugin"
    fi
}


main() {
    install_krew
    pathmunge "$HOME/.krew/bin" after


    install_krew_plugin ns
    install_krew_plugin ns
    install_krew_plugin ctx
    install_krew_plugin neat
    install_krew_plugin whoami
    install_krew_plugin viewnode
    install_krew_plugin service-tree
    install_krew_plugin sick-pods
    install_krew_plugin evict-pod
    install_krew_plugin resource-capacity

    install_asdf_plugin cmctl
    # KUBECTL_VERSION will be supplied by `gp env`
    install_asdf_plugin kubectl "$KUBECTL_VERSION"

    if ! command -v kubectl-kots 1>/dev/null; then
        curl https://kots.io/install | bash
    fi
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi