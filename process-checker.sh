#!/bin/bash
# Anger att skriptet ska köras med Bash

# Fil där alla loggmeddelanden sparas
logfile="process_check.log"

# Funktion för att skriva loggposter
log() {

    # Skriver datum, tid och meddelande
    # Visar i terminalen och sparar i loggfilen
    echo "$(date) - $1" | tee -a "$logfile"
}

# Funktion som kontrollerar om en process körs
check_process() {

    # Tar emot processnamnet som parameter
    local p="$1"

    # Kontrollerar om processen finns aktiv i systemet
    if pgrep "$p" &>/dev/null; then

        # Loggar att processen körs
        log "Processen '$p' körs."
    else

        # Loggar en varning om processen inte körs
        log "VARNING: Processen '$p' körs inte."
    fi
}

# Funktion som läser processer från fil och kör kontroller
run_checks() {

    # Tar emot filnamnet som parameter
    local file="$1"

    # Kontrollerar om filen finns
    if [ ! -f "$file" ]; then

        # Loggar fel om filen saknas
        log "FEL: Filen $file saknas."

        # Avslutar skriptet med felkod
        exit 1
    fi

    # Läser filen rad för rad
    while read -r process; do

        # Kontrollerar varje process i listan
        check_process "$process"
    done < "$file"
}

# Startar kontrollerna med filen som innehåller processnamn
run_checks "processlist.txt"

# Loggar att alla kontroller är slutförda
log "Kontroller slutförda."
