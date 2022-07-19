#!/usr/bin/env bash


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

    ~/.krew/bin/kubectl-krew install ns
    ~/.krew/bin/kubectl-krew install ctx
    ~/.krew/bin/kubectl-krew install neat
    ~/.krew/bin/kubectl-krew install whoami
    ~/.krew/bin/kubectl-krew install viewnode
    ~/.krew/bin/kubectl-krew install service-tree
    ~/.krew/bin/kubectl-krew install sick-pods
    ~/.krew/bin/kubectl-krew install evict-pod
    ~/.krew/bin/kubectl-krew install resource-capacity
}


main() {
    install_krew

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