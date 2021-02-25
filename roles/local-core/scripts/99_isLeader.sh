#!/usr/bin/env bash

poolId="$1"
epoch="$2"
vrfkey="$3"
timezone="$4"

function getLeader() {
    ./leaderLogs.py --pool-id "$poolId" --epoch "$epoch" --vrf-skey "$vrfkey" --tz "$timezone"
}

getLeader

exit 0
