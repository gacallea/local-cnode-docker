#!/bin/bash

poolId="$1"
epoch="$2"
vrfkey="$3"
timezone="$4"
next="$5"
bft="$6"
sigma=""

function getSigma() {
    if [ "$next" == "true" ]; then
        sigma=$(./getSigma.py --pool-id "$poolId" --next | awk '/Sigma/ {print $2}')
    else
        sigma=$(./getSigma.py --pool-id "$poolId" | awk '/Sigma/ {print $2}')
    fi
}

function getLeader() {
    if [ "$bft" == "true" ]; then
        ./leaderLogs.py --pool-id "$poolId" --epoch "$epoch" --vrf-skey "$vrfkey" --tz "$timezone" --sigma "$sigma" -bft
    else
        ./leaderLogs.py --pool-id "$poolId" --epoch "$epoch" --vrf-skey "$vrfkey" --tz "$timezone" --sigma "$sigma"
    fi
}

getSigma
getLeader

exit 0
