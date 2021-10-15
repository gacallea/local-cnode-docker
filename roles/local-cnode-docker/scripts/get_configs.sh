#!/usr/bin/env bash

FETCH_URL="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html"
CONFIG_PREFIX="mainnet"
DOWNLOAD_DIR="$1"

if ! command -v curl >/dev/null; then
    echo "cURL not found. please install curl!"
    exit 1
fi

if ! command -v lynx >/dev/null; then
    echo "lynx not found. please install lynx!"
    exit 2
fi

function mkTmpFile() {
    tmpFile="$CONFIG_PREFIX.html"
    touch "$tmpFile"
}

function mkDownloadDir() {
    if [[ ! -d "${DOWNLOAD_DIR}/" ]]; then
        mkdir -p "${DOWNLOAD_DIR}"
    fi
}

function fetchList() {
    lynx -dump -listonly "$FETCH_URL" > "$tmpFile"
}

function configsURLs() {
    CONFIG_URL=$(awk "/$CONFIG_PREFIX-config/ {print \$2}" "$tmpFile")
    TOPOLOGY_URL=$(awk "/$CONFIG_PREFIX-topology/ {print \$2}" "$tmpFile")
    BYRON_GENESIS_URL=$(awk "/$CONFIG_PREFIX-byron-genesis/ {print \$2}" "$tmpFile")
    SHELLEY_GENESIS_URL=$(awk "/$CONFIG_PREFIX-shelley-genesis/ {print \$2}" "$tmpFile")
    ALONZO_GENESIS_URL=$(awk "/$CONFIG_PREFIX-alonzo-genesis/ {print \$2}" "$tmpFile")
}

function configsFiles() {
    CONFIG_FILE="${DOWNLOAD_DIR}/$CONFIG_PREFIX-config.json"
    TOPOLOGY_FILE="${DOWNLOAD_DIR}/$CONFIG_PREFIX-topology.json"
    BYRON_GENESIS_FILE="${DOWNLOAD_DIR}/$CONFIG_PREFIX-byron-genesis.json"
    SHELLEY_GENESIS_FILE="${DOWNLOAD_DIR}/$CONFIG_PREFIX-shelley-genesis.json"
    ALONZO_GENESIS_FILE="${DOWNLOAD_DIR}/$CONFIG_PREFIX-alonzo-genesis.json"
}

function configsFetch() {
    echo "Fetching the latest $CONFIG_FILE"
    curl -sLJ "${CONFIG_URL}" -o "$CONFIG_FILE"
    echo "Fetching the latest $TOPOLOGY_FILE"
    curl -sLJ "${TOPOLOGY_URL}" -o "$TOPOLOGY_FILE"
    echo "Fetching the latest $BYRON_GENESIS_FILE"
    curl -sLJ "${BYRON_GENESIS_URL}" -o "$BYRON_GENESIS_FILE"
    echo "Fetching the latest $SHELLEY_GENESIS_FILE"
    curl -sLJ "${SHELLEY_GENESIS_URL}" -o "$SHELLEY_GENESIS_FILE"
    echo "Fetching the latest $ALONZO_GENESIS_FILE"
    curl -sLJ "${ALONZO_GENESIS_URL}" -o "$ALONZO_GENESIS_FILE"
}

function cleanUp() {
    rm -f "$tmpFile"
}

mkTmpFile
mkDownloadDir
fetchList
configsURLs
configsFiles
configsFetch
cleanUp

exit 0
