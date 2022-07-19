#!/usr/bin/env bash


source "$(realpath $(dirname $0))/00_core.sh"


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

main() {

    install_asdf_plugin yq latest
    install_asdf_plugin bat latest

    install_http_binary tldr "https://github.com/dbrgn/tealdeer/releases/download/v1.5.0/tealdeer-linux-x86_64-musl"

    $HOME/.local/bin/tldr --update
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi