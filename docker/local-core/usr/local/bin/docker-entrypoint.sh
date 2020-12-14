#!/usr/bin/env bash
set -e

source /usr/local/lib/cardano-node-set-env-variables.sh

function preExitHook() {
  exec "$@"
  echo 'Exiting...'
}

if [[ ! -f "${SHELLEY_GENESIS_FILE}" ]]; then
  echo "'cardano-node' SHELLEY Genesis file does not exist! 'cardano-node' can NOT start!!!"
  preExitHook "$@"
  exit
elif [[ ! -f "${BYRON_GENESIS_FILE}" ]]; then
  echo "'cardano-node' BYRON Genesis file does not exist! 'cardano-node' can NOT start!!!"
  preExitHook "$@"
  exit
elif [[ ! -f "${CARDANO_NODE_CONF_FILE}" ]]; then
  echo "'cardano-node' Config file does not exists! 'cardano-node' can NOT start!!!"
  preExitHook "$@"
  exit
elif [[ ! -f "${CARDANO_NODE_TOPOLOGY_FILE}" ]]; then
  echo "'cardano-node' Topology file does not exists! 'cardano-node' can NOT start!!!"
  preExitHook "$@"
  exit
else
  cardano-node run \
    --config "${CARDANO_NODE_CONF_FILE}" \
    --topology "${CARDANO_NODE_TOPOLOGY_FILE}" \
    --database-path "${CARDANO_NODE_DB_PATH}" \
    --socket-path "${CARDANO_NODE_SOCKET_PATH}" \
    --host-addr 0.0.0.0 \
    --port "${CARDANO_NODE_PORT}"
fi
