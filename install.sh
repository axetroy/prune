#!/usr/bin/env bash
set -e

downloadFolder="${HOME}/Downloads"

mkdir -p ${downloadFolder}

get_os(){
    echo $(uname -s | awk '{print tolower($0)}')
}

main() {
    local os=$(get_os)
    
    if [[ $os = "darwin" ]]; then
        os="osx"
    fi
    
    local dest_file="${downloadFolder}/prune_${os}.tar.gz"
    
    if [[ $# -eq 0 ]]; then
        asset_path=$(
            command curl -sSf https://github.com/axetroy/prune/releases |
            command grep -o "/axetroy/prune/releases/download/.*/prune_${os}\\.tar.gz" |
            command head -n 1
        )
        if [[ ! "$asset_path" ]]; then exit 1; fi
        asset_uri="https://github.com${asset_path}"
    else
        asset_uri="https://github.com/axetroy/prune/releases/download/${1}/prune_${os}\\.tar.gz"
    fi
    
    mkdir -p ${downloadFolder}
    
    echo "[1/3] Download ${asset_uri} to ${downloadFolder}"
    rm -f ${dest_file}
    # wget -P "${downloadFolder}" "${asset_uri}"
    curl --location --output "${dest_file}" "${asset_uri}"
    
    echo "[2/3] Install prune to the ${HOME}/bin"
    mkdir -p ${HOME}/bin
    tar -xz -f ${dest_file} -C ${HOME}/bin
    exe=${HOME}/bin/prune
    chmod +x ${exe}
    
    echo "[3/3] Set environment variables"
    echo "prune was installed successfully to ${exe}"
    if command -v prune --version >/dev/null; then
        echo "Run 'prune --help' to get started"
    else
        echo "Manually add the directory to your \$HOME/.bash_profile (or similar)"
        echo "  export PATH=${HOME}/bin:\$PATH"
        echo "Run '$exe --help' to get started"
    fi
    
    exit 0
}

main