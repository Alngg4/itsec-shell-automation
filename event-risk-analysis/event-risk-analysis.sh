#!/bin/bash

logfile="event_risk_report_bash.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$logfile"
}

# ------------------------------------
# 1. Läs users.csv (username → status)
# ------------------------------------
declare -A status_map

while IFS=',' read -r username status; do
    [[ "$username" == "username" ]] && continue
    status_map["$username"]="$status"
done < users.csv

# ------------------------------------
# 2. Räkna failed_login per användare
# ------------------------------------
declare -A fail_count

for user in "${!status_map[@]}"; do
    count=$(grep -o "\"user\": \"$user\"[^\n]*\"event\": \"failed_login\"" events.json | wc -l)
    fail_count["$user"]=$count
done

# ------------------------------------
# 3. Riskklassificering (RÄTT LOOP)
# ------------------------------------
for user in "${!status_map[@]}"; do
    fails=${fail_count[$user]}
    status=${status_map[$user]}

    if (( fails >= 1 )) && [[ "$status" == "disabled" ]]; then
        log "$user – CRITICAL RISK (disabled + failed logins)"
    elif (( fails >= 3 )); then
        log "$user – HIGH RISK (3+ failed attempts)"
    elif (( fails >= 1 )); then
        log "$user – MEDIUM RISK (failed attempts)"
    else
        log "$user – LOW RISK"
    fi
done

log "Analys slutförd."