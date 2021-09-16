#!/usr/bin/env bash

FETCH_URL="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest-finished"

DOWNLOAD_DIR="$1"
VERSION="$2"

if ! command -v curl >/dev/null; then
    echo "cURL not found. please install curl!"
    exit 1
fi

if ! command -v lynx >/dev/null; then
    echo "lynx not found. please install lynx!"
    exit 2
fi

bin_file=$(lynx -dump -listonly -nonumbers "$FETCH_URL" | grep "tar.gz")

if [[ "$bin_file" =~ cardano-node-"${VERSION}"-linux.tar.gz ]]; then
    if [[ ! -f "$DOWNLOAD_DIR"/cardano-node-"${VERSION}"-linux.tar.gz ]]; then
        curl -sLJ "$bin_file" -o "$DOWNLOAD_DIR"/cardano-node-"${VERSION}"-linux.tar.gz
        tar xzvf "$DOWNLOAD_DIR"/cardano-node-"${VERSION}"-linux.tar.gz -C "$DOWNLOAD_DIR/"
    fi
else
    echo "check the download url"
    exit 1
fi

exit 0
