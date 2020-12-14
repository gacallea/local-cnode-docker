#!/bin/bash

CARDANO_NODE_USER_HOME=$HOME

if [ -f "${CARDANO_NODE_USER_HOME}"/config/mainnet-config.json ]; then
  CARDANO_NODE_CONF_FILE="${CARDANO_NODE_USER_HOME}"/config/mainnet-config.json
fi

if [ -f "${CARDANO_NODE_USER_HOME}"/config/mainnet-topology.json ]; then
  CARDANO_NODE_TOPOLOGY_FILE="${CARDANO_NODE_USER_HOME}"/config/mainnet-topology.json
fi

if [ -f "${CARDANO_NODE_USER_HOME}"/config/mainnet-byron-genesis.json ]; then
  BYRON_GENESIS_FILE="${CARDANO_NODE_USER_HOME}"/config/mainnet-byron-genesis.json
fi

if [ -f "${CARDANO_NODE_USER_HOME}"/config/mainnet-shelley-genesis.json ]; then
  SHELLEY_GENESIS_FILE="${CARDANO_NODE_USER_HOME}"/config/mainnet-shelley-genesis.json
fi

: "${CARDANO_NODE_PORT:=${CARDANO_NODE_PORT:-3000}}"
: "${CARDANO_NODE_MAX_STARTUP_TIME:=${CARDANO_NODE_MAX_STARTUP_TIME:-20}}"
: "${CARDANO_NODE_MAX_FAULT_UPTIME:=${CARDANO_NODE_MAX_FAULT_UPTIME:-600}}"
