#!/bin/bash

logfile="event_risk_report.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$logfile"
}

declare -A status_map
while IFS=',' read -r username status; do
    [[ "$username" == "username" ]] && continue
    status_map["$username"]="$status"
done < users.csv

declare -A fail_count
for user in "${!status_map[@]}"; do
    count=$(jq --arg usr "$user" '
        .events[] | select(.user == $usr and .event == "failed_login")
    ' events.json | wc -l)
    fail_count["$user"]=$count
done

for user in "${!status_map[@]}"; do
    fails=${fail_count[$user]}
    status=${status_map[$user]}

    if (( fails >= 1 )) && [[ "$status" == "disabled" ]]; then
        log "$user – CRITICAL RISK"
    elif (( fails >= 3 )); then
        log "$user – HIGH RISK"
    elif (( fails >= 1 )); then
        log "$user – MEDIUM RISK"
    else
        log "$user – LOW RISK"
    fi
done

log "Analys slutförd."