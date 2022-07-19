#!/usr/bin/env bash


install_asdf() {
    if ! [[ -d ~/.asdf ]]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
        source ~/.asdf/asdf.sh
    fi
}


install_asdf_plugin() {
    local plugin version
    plugin="$1"
    version="$2"

    if command -v $plugin 1>/dev/null && ! command -v $plugin | grep -q ".asdf/shims"; then
        echo "install-asdf-plugin: $plugin already exists at $(command -v $plugin), the asdf installed binary may be shadowed."
    fi

    if ! [[ -d "$HOME/.asdf/plugins/$plugin" ]]; then
        asdf plugin add "$plugin"
    fi

    if ! [[ -z "$version" ]]; then
        asdf install "$plugin" "$version"
        asdf global "$plugin" "$version"
    fi
}


main() {
    if ! [[ -d $HOME/.local/bin ]]; then
        mkdir "$HOME/.local/bin"
    fi

    eval "$(gp env -e)"

    install_asdf
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi