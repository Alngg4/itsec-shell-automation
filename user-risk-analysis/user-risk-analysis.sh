#!/bin/bash

# Loggfil där rapporten sparas
logfile="user_risk_report.log"

# Funktion för att skriva till logg med tidsstämpel
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$logfile"
}

# Läser CSV-filen rad för rad
while IFS=',' read -r username days status; do

    # Hoppa över rubrikraden i CSV-filen
    [[ "$username" == "username" ]] && continue

    # Regel 4 – KRITISK RISK (högst prioritet)
    if (( days > 180 )) && [[ "$status" == "disabled" ]]; then
        log "$username – KRITISK RISK (inaktiv > 180 dagar & disabled)"

    # Regel 2 – HIGH RISK
    elif (( days > 180 )); then
        log "$username – HIGH RISK (inaktiv > 180 dagar)"

    # Regel 1 – MEDIUM RISK
    elif (( days > 90 )); then
        log "$username – MEDIUM RISK (inaktiv > 90 dagar)"

    # Regel 3 – WARNING
    elif [[ "$status" == "disabled" ]] && (( days < 30 )); then
        log "$username – WARNING (disabled men nyligen inloggad)"

    # Ingen risk
    else
        log "$username – OK"
    fi

done < users.csv

# Slutmeddelande
log "Analys slutförd."