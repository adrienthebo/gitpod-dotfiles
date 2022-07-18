#!/usr/bin/env bash

install_http_binary() {
    binary="$1"
    url="$2"
    
    local output_path="$HOME/.local/bin/$binary"
    
    if ! [[ -f "$output_path" ]]; then
        curl -L "$url" > "$output_path" && chmod +x "$output_path"
    fi
}

install_jiq() {
    curl -L https://github.com/fiatjaf/jiq/releases/download/v0.7.2/jiq_linux_amd64 -o "$HOME/.local/bin/jiq"
    chmod +x "$HOME/.local/bin/jiq"
}


install_asdf() {
    if ! [[ -d ~/.asdf ]]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
        source ~/.asdf/asdf.sh
    fi
}


install_asdf_plugin() {
    local plugin
    plugin="$1"
    version="$2"

    if ! [[ -d "$HOME/.asdf/plugins/$plugin" ]]; then
        asdf plugin add "$plugin"
    fi

    if ! [[ -z "$version" ]]; then
        asdf install "$plugin" "$version"
        asdf global "$plugin" "$version"
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

main() {
    if ! [[ -d $HOME/.local/bin ]]; then
        mkdir "$HOME/.local/bin"
    fi

    install_asdf
    install_krew

    install_asdf_plugin cmctl
    install_asdf_plugin kubectl
    install_asdf_plugin yq latest
    install_asdf_plugin bat latest

    install_http_binary tldr "https://github.com/dbrgn/tealdeer/releases/download/v1.5.0/tealdeer-linux-x86_64-musl"
    tldr --update
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi