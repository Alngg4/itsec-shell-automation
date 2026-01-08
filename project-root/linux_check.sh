#!/bin/bash

output="../data/linux_processes.json"
logfile="../data/anomalies.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$logfile"
}

# Hämta processnamn (Git Bash-kompatibelt)
processes=$(ps | awk 'NR>1 {print $1}')

# Riskprocesser
risk=("nc" "netcat" "hydra" "john")

# Bygg JSON
json='{"processes":['

for p in $processes; do
    json+='{"name":"'"$p"'"}'
    json+=','
done

# ta bort sista kommatecknet
json="${json%,}]}"  

echo "$json" > "$output"

# Detektera riskprocesser
for r in "${risk[@]}"; do
    if echo "$processes" | grep -qw "$r"; then
        log "VARNING – Riskprocess upptäckt: $r"
    fi
done

log "Linux-kontroll klar."
