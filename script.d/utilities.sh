#!/usr/bin/env bash

if ! [[ -d $HOME/.local/bin ]]; then
    mkdir "$HOME/.local/bin"
fi

curl -L https://github.com/fiatjaf/jiq/releases/download/v0.7.2/jiq_linux_amd64 -o "$HOME/.local/bin/jiq"
chmod +x "$HOME/.local/bin/jiq"

install_asdf() {
    if ! [[ -d ~/.asdf ]]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
        source ~/.asdf/asdf.sh
    fi

    if ! [[ -d ~/.asdf/plugins/kubectl ]]; then
        asdf plugin-add kubectl https://github.com/asdf-community/asdf-kubectl.git
    fi

    if ! [[ -d ~/.asdf/plugins/cmctl ]]; then
        asdf plugin-add cmctl https://github.com/asdf-community/asdf-cmctl.git
    fi
}

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
        
        ~/.krew/bin/kubectl-krew install ns
        ~/.krew/bin/kubectl-krew install ctx
        ~/.krew/bin/kubectl-krew install neat
        ~/.krew/bin/kubectl-krew install whoami
        ~/.krew/bin/kubectl-krew install viewnode
    fi
}

install_asdf
install_krew