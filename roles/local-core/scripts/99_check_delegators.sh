#!/bin/bash

POOL_NAME="SALAD"
POOL_ID="e29b14719f694767d0faf92f654cf66585bcefd8139bf5a33b7ed181"

CCLI=$(command -v cardano-cli)
PROTOCOL_IDENTIFIER="--cardano-mode"
NETWORK_IDENTIFIER="--mainnet"
TMP_FILE="$(mktemp)"

function removeEmptyLines() {
  local -r content="${1}"
  echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString() {
  local -r string="${1}"
  local -r numberToRepeat="${2}"
  if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]; then
    local -r result="$(printf "%${numberToRepeat}s")"
    echo -e "${result// /${string}}"
  fi
}

function isEmptyString() {
  local -r string="${1}"
  if [[ "$(trimString "${string}")" = '' ]]; then
    echo 'true' && return 0
  fi
  echo 'false' && return 1
}

function trimString() {
  local -r string="${1}"
  sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

say() {
    echo -e "$1"
}

formatLovelace() {
  re_int_nbr='^[0-9]+$'
  if [[ $1 =~ ${re_int_nbr} ]]; then
    printf "%'.6f" "${1}"e-6
  else
    say "ERROR${NC}: must be a valid integer number"
    return 1
  fi
}

function printTable() {
  local -r delimiter="${1}"
  local -r data="$(removeEmptyLines "${2}")"
  if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]; then
    local -r numberOfLines="$(wc -l <<< "${data}")"
    if [[ "${numberOfLines}" -gt '0' ]]; then
      local table=''
      local i=1
      for ((i = 1; i <= "${numberOfLines}"; i = i + 1)); do
        local line=''
        line="$(sed "${i}q;d" <<< "${data}")"
        local numberOfColumns='0'
        numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"
        # Add Line Delimiter
        if [[ "${i}" -eq '1' ]]; then
          table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
        fi
        # Add Header Or Body
        table="${table}\n"
        local j=1
        for ((j = 1; j <= "${numberOfColumns}"; j = j + 1)); do
          table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
        done
        table="${table}#|\n"
        # Add Line Delimiter
        if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]; then
          table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
        fi
      done
      if [[ "$(isEmptyString "${table}")" = 'false' ]]; then
        echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
      fi
    fi
  fi
}

say "\nDUMPING LEDGER STATE..."
timeout -k 5 60 "${CCLI}" query ledger-state "${PROTOCOL_IDENTIFIER}" "${NETWORK_IDENTIFIER}" --out-file "${TMP_FILE}"
say "\nPARSING DATA..."
non_myopic_delegators=$(jq -r -c ".esNonMyopic.snapNM._delegations | .[] | select(.[1] == \"${POOL_ID}\") | .[0][\"key hash\"]" "${TMP_FILE}")
snapshot_delegators=$(jq -r -c ".esSnapshots._pstakeSet._delegations | .[] | select(.[1] == \"${POOL_ID}\") | .[0][\"key hash\"]" "${TMP_FILE}")
lstate=$(jq -r -c ".esLState" "${TMP_FILE}")
lstate_dstate=$(jq -r -c "._delegationState._dstate" <<< "${lstate}")
ledger_pool_state=$(jq -r -c '._delegationState._pstate._pParams."'"${POOL_ID}"'" // empty' <<< "${lstate}")
lstate_rewards=$(jq -r -c "._rewards" <<< "${lstate_dstate}")
lstate_utxo=$(jq -r -c "._utxoState._utxo" <<< "${lstate}")
lstate_delegators=$(jq -r -c "._delegations | .[] | select(.[1] == \"${POOL_ID}\") | .[0][\"key hash\"]" <<< "${lstate_dstate}")
delegators=$(echo "${non_myopic_delegators}" "${snapshot_delegators}" "${lstate_delegators}" | tr ' ' '\n' | sort -u)
say "\n$(wc -w <<< "${delegators}") delegators found, gathering data for each:"
pledge="$(jq -c -r '.pledge // 0' <<< "${ledger_pool_state}" | tr '\n' ' ')"
owners="$(jq -c -r '.owners[] // empty' <<< "${ledger_pool_state}" | tr '\n' ' ')"
owner_nbr=$(jq -r '(.owners | length) // 0' <<< "${ledger_pool_state}")
delegators_array=()
delegator_nbr=0
total_stake=0
total_pledged=0
for key in ${delegators}; do
  stake=$(jq -r -c ".[] | select(.address | contains(\"${key}\")) | .amount" <<< "${lstate_utxo}" | awk 'BEGIN{total = 0} {total = total + $1} END{printf "%.0f", total}')
  rewards=$(jq -r -c ".[] | select(.[0][\"key hash\"] == \"${key}\") | .[1]" <<< "${lstate_rewards}")
  total_stake=$((total_stake + stake + rewards))
  say "Delegator $((++delegator_nbr)) processed"
  if echo "${owners}" | grep -q "${key}"; then
    key="${key} (owner)"
    total_pledged=$((total_pledged + stake + rewards))
  fi
  delegators_array+=( "hex_key" "${key}" "stake" "$(formatLovelace "${stake}")" "rewards" "$(formatLovelace "${rewards}")" )
done

# Construct delegator json array
delegators_json=$({
  say '['
  printf '{"%s":"%s","%s":"%s","%s":"%s"},\n' "${delegators_array[@]}" | sed '$s/,$//'
  say ']'
} | jq -c .)

clear
say "RESULTS FOR ${POOL_NAME} DELEGATORS"
say "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
say ""
say "${delegator_nbr}${NC} wallet(s) delegated to ${POOL_NAME}${NC} of which ${owner_nbr}${NC} are owner(s)\n"
say "Total Stake: $(formatLovelace ${total_stake}) ADA [ owners pledge: $(formatLovelace ${total_pledged}) | delegators: $(formatLovelace $((total_stake-total_pledged))) ]\n"

if [[ ${total_pledged} -lt "${pledge}" ]]; then
  say "WARN${NC}: Owners pledge does not cover registered pledge of $(formatLovelace "${pledge}") ADA\n"
fi

printTable ';' "$(say 'Hex Key;Stake;Rewards' | cat - <(jq -r -c '.[] | "\(.hex_key);\(.stake);\(.rewards)"' <<< "${delegators_json}"))"

rm -rf "${TMP_FILE}"
