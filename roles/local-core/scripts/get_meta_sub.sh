#!/usr/bin/env bash

FETCH_URL="https://hydra.iohk.io/job/Cardano/cardano-metadata-submitter/native.metadataSubmitterTarball.x86_64-linux/latest-finished"

[[ -n "$1" ]] && DOWNLOAD_DIR="$1" || DOWNLOAD_DIR="../files/bins"

if ! command -v curl >/dev/null; then
    echo "cURL not found. please install curl!"
    exit 1
fi

if ! command -v lynx >/dev/null; then
    echo "lynx not found. please install lynx!"
    exit 2
fi

bin_file=$(lynx -dump -listonly -nonumbers "$FETCH_URL" | grep "tar.gz")

if [[ "$bin_file" =~ cardano-metadata-submitter.tar.gz ]]; then
    curl -sLJ "$bin_file" -o "$DOWNLOAD_DIR"/cardano-metadata-submitter.tar.gz
    tar xzvf "$DOWNLOAD_DIR"/cardano-metadata-submitter.tar.gz -C "$DOWNLOAD_DIR/"
else
    echo "check the download url"
    exit 1
fi

exit 0
