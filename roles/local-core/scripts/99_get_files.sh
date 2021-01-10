#!/usr/bin/env bash -x

SCRIPTNAME="${0##*/}"
FETCH_URL="https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html"
RELAYS_URL="https://explorer.mainnet.cardano.org/relays/topology.json"

## this was added to use this script in the local-core ansible playbook
## only $1 (mainnet) is used when running this script directly.
[[ -n "$2" ]] && DOWNLOAD_DIR="$2" || DOWNLOAD_DIR="../build_files"
[[ -n "$3" ]] && FILES_DEST_DIR="$3" || FILES_DEST_DIR="../commons/"

if ! command -v curl >/dev/null; then
    echo "cURL not found. please install curl!"
    exit 1
fi

if ! command -v lynx >/dev/null; then
    echo "lynx not found. please install lynx!"
    exit 2
fi

function usage() {
    echo "Please provide the desired testnet. E.g:"
    echo "./$SCRIPTNAME mainnet"
}

function mkTmpFile() {
    tmpFile="$CONFIG_PREFIX.html"
    touch "$tmpFile"
}

function fetchList() {
    lynx -dump -listonly "$FETCH_URL" > "$tmpFile"
}

function shelleyURLs() {
    BUILD_ID=$(awk "/$CONFIG_PREFIX/ {print \$2}" "$tmpFile" | cut -d'/' -f5 | sort -u)
    CONFIG_URL=$(awk "/$CONFIG_PREFIX-config/ {print \$2}" "$tmpFile")
    TOPOLOGY_URL=$(awk "/$CONFIG_PREFIX-topology/ {print \$2}" "$tmpFile")
    SHELLEY_GENESIS_URL=$(awk "/$CONFIG_PREFIX-shelley-genesis/ {print \$2}" "$tmpFile")
}

function byronURLs() {
    BYRON_GENESIS_URL=$(awk "/$CONFIG_PREFIX-byron-genesis/ {print \$2}" "$tmpFile")
}

function mkDownloadDir() {
    if [[ ! -d "${DOWNLOAD_DIR}/${CONFIG_PREFIX}/${BUILD_ID}" ]]; then
        mkdir -p "${DOWNLOAD_DIR}/${CONFIG_PREFIX}/${BUILD_ID}"
    fi
}

function shelleyFiles() {
    CONFIG_FILE="${DOWNLOAD_DIR}/${CONFIG_PREFIX}/${BUILD_ID}/$CONFIG_PREFIX-config.json"
    TOPOLOGY_FILE="${DOWNLOAD_DIR}/${CONFIG_PREFIX}/${BUILD_ID}/$CONFIG_PREFIX-topology.json"
    SHELLEY_GENESIS_FILE="${DOWNLOAD_DIR}/${CONFIG_PREFIX}/${BUILD_ID}/$CONFIG_PREFIX-shelley-genesis.json"
}

function byronFiles() {
    BYRON_GENESIS_FILE="${DOWNLOAD_DIR}/${CONFIG_PREFIX}/${BUILD_ID}/$CONFIG_PREFIX-byron-genesis.json"
}

function shelleyChecks() {
    if [[ -f "$CONFIG_FILE" ]] && [[ -f "$SHELLEY_GENESIS_FILE" ]] && [[ -f "$TOPOLOGY_FILE" ]]; then
        echo "You already have the latest configurations: ${BUILD_ID}. Nothing to do here"
        cleanUp
        ## this was added to use this script in the local-core ansible playbook
        [[ $- == *i* ]] && exit 3 || exit 0
    fi
}

function byronChecks() {
    if [[ -f "$CONFIG_FILE" ]] && [[ -f "$BYRON_GENESIS_FILE" ]] && [[ -f "$SHELLEY_GENESIS_FILE" ]] && [[ -f "$TOPOLOGY_FILE" ]]; then
        echo "You already have the latest configurations: ${BUILD_ID}. Nothing to do here"
        cleanUp
        ## this was added to use this script in the local-core ansible playbook
        [[ $- == *i* ]] && exit 4 || exit 0
    fi
}

function shelleyFetch() {
    echo "Fetching the latest $CONFIG_FILE"
    curl -sLJ "${CONFIG_URL}" -o "$CONFIG_FILE"
    echo "Fetching the latest $SHELLEY_GENESIS_FILE"
    curl -sLJ "${SHELLEY_GENESIS_URL}" -o "$SHELLEY_GENESIS_FILE"
    echo "Fetching the latest $TOPOLOGY_FILE"
    curl -sLJ "${TOPOLOGY_URL}" -o "$TOPOLOGY_FILE"
}

function byronFetch() {
    echo "Fetching the latest $BYRON_GENESIS_FILE"
    curl -sLJ "${BYRON_GENESIS_URL}" -o "$BYRON_GENESIS_FILE"
}

function copyToFiles() {
    echo "Copying the latest $CONFIG_FILE"
    \cp -af "$CONFIG_FILE" "$FILES_DEST_DIR"
    echo "Copying the latest $SHELLEY_GENESIS_FILE"
    \cp -af "$SHELLEY_GENESIS_FILE" "$FILES_DEST_DIR"
    echo "Copying the latest $TOPOLOGY_FILE"
    \cp -af "$TOPOLOGY_FILE" "$FILES_DEST_DIR"
    if [ -f "$BYRON_GENESIS_FILE" ]; then
        echo "Copying the latest $BYRON_GENESIS_FILE"
        \cp -af "$BYRON_GENESIS_FILE" "$FILES_DEST_DIR"
    fi
}

function cleanUp() {
    rm -f "$tmpFile"
}

function fetchRelays(){
    echo "Fetching the latest relays"
    curl -sLJ "${RELAYS_URL}" -o "${FILES_DEST_DIR}/${CONFIG_PREFIX}-relays.json"
}

while true; do
    case "$1" in
    '')
        echo -e "\\n$SCRIPTNAME: no testnet supplied. run '$SCRIPTNAME --help' for usage \\n"
        exit 0
        ;;
    mainnet)
        CONFIG_PREFIX="mainnet"
        mkTmpFile
        fetchList
        shelleyURLs
        byronURLs
        mkDownloadDir
        shelleyFiles
        byronFiles
        shelleyChecks
        byronChecks
        shelleyFetch
        byronFetch
        fetchRelays
        copyToFiles
        cleanUp
        exit 0
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo -e "\\n$SCRIPTNAME: unknown command '$1'\\n"
        exit 127
        ;;
    esac
done

exit 127
