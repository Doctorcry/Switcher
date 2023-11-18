#!/usr/bin/env sh
# shellcheck shell=sh
# TODO: add strict mode

apiUrl="https://api2.hiveos.farm/api/v2/farms/######/workers/######"
authToken=""
primaryAndZilFs="16805214"
primaryFs="16941023"

switchFs() {
  curl "$apiUrl" -X PATCH -sSL \
    -H "Content-Type: application/json" \
    -H "X-API-Version: 2.8" \
    -H "Authorization: Bearer $authToken" \
    --data-raw "{\"fs_id\":$1}"
}

getTimeUntilNextEpoch() {
  nextEpoch="$(curl -sS 'https://zil.crazypool.org/api/stats/chart' | grep -Eo "\"nextEpochTime\":[0-9]+" | cut -b 17-)"
  now="$(date +%s)"
  diff=$((nextEpoch-now))

  echo $diff
}

while true;
do
  diff=$(getTimeUntilNextEpoch)
  echo "$diff"
  if [ "$diff" -lt 0 ]; then
    # Do nothing
    true
  else
    # The CrazyPool seems to indicate the time when ZIL window ends so we have
    # to switch a few minutes before it. 
    if [ "$diff" -lt 240 ]; then
      echo switching to primaryAndZilFs
      switchFs "$primaryAndZilFs"

      sleep $((diff+40))

      echo switching back to primaryFs
      switchFs "$primaryFs"
    fi
  fi
  
  sleep 20
done