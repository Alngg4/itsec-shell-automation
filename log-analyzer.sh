#!/bin/bash
# Anger att skriptet ska köras med Bash

# Filen som ska analyseras
inputfile="sample.log"

# Fil där analysresultatet sparas
logfile="analysis.log"

# Funktion för att skriva loggposter
log() {

    # Skriver datum, tid och meddelande
    # Visar i terminalen och sparar i loggfilen
    echo "$(date) - $1" | tee -a "$logfile"
}

# Räknare för misslyckade inloggningar
failed_count=0

# Räknare för felmeddelanden
error_count=0

# Räknare för obehöriga försök
unauth_count=0

# Läser loggfilen rad för rad
while read -r line; do

    # Kontrollerar om raden innehåller "failed" (skiftlägesokänsligt)
    if echo "$line" | grep -qi "failed"; then

        # Loggar misslyckat inloggningsförsök
        log "Misslyckat inloggningsförsök: $line"

        # Ökar räknaren
        ((failed_count++))
    fi

    # Kontrollerar om raden innehåller "error"
    if echo "$line" | grep -qi "error"; then

        # Loggar hittat fel
        log "Error hittad: $line"

        # Ökar räknaren
        ((error_count++))
    fi

    # Kontrollerar om raden innehåller "unauthorized"
    if echo "$line" | grep -qi "unauthorized"; then

        # Loggar obehörigt försök
        log "Obehörigt försök: $line"

        # Ökar räknaren
        ((unauth_count++))
    fi

# Avslutar loopen efter att hela filen har lästs
done < "$inputfile"

# Loggar att analysen är klar
log "ANALYS KLAR"

# Skriver slutlig sammanfattning
log "Antal misslyckade inloggningar: $failed_count"
log "Antal errors: $error_count"
log "Antal obehöriga försök: $unauth_count"
