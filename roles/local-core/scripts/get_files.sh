#!/usr/bin/env bash

DOWNLOAD_DIR="$1"
BUILD="$2"
VERSION="$3"
FETCH_URL="https://hydra.iohk.io/build/${BUILD}/download/1/cardano-node-${VERSION}-linux.tar.gz"
CNODE_TAR="cardano-node-${VERSION}-linux.tar.gz"

if ! command -v curl >/dev/null; then
    echo "cURL not found. please install curl!"
    exit 1
fi

if ! command -v lynx >/dev/null; then
    echo "lynx not found. please install lynx!"
    exit 2
fi

if [[ ! -d "${DOWNLOAD_DIR}/" ]]; then
    mkdir -p "${DOWNLOAD_DIR}"
fi

if [[ ! -f "$DOWNLOAD_DIR"/"$CNODE_TAR" ]]; then
    curl -sLJ "$FETCH_URL" -o "$DOWNLOAD_DIR"/"$CNODE_TAR"
    tar xzvf "$DOWNLOAD_DIR"/"$CNODE_TAR" -C "$DOWNLOAD_DIR/" cardano-cli
    tar xzvf "$DOWNLOAD_DIR"/"$CNODE_TAR" -C "$DOWNLOAD_DIR/" cardano-node
else
    echo "you already have downloaded the latest cardano binaries"
fi

exit 0
