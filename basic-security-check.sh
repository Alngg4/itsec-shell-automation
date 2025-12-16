#!/bin/bash
# Anger att skriptet ska köras med Bash-skalet

# Fil där alla loggar sparas
logfile="security_log.txt"

# Funktion för att skriva loggmeddelanden
log() {

    # Skriver datum, tid och meddelande
    # Visar i terminalen och sparar i loggfilen
    echo "$(date) - $1" | tee -a "$logfile"
}

# Funktion som kontrollerar om en fil finns
check_file() {

    # Tar emot filnamnet som parameter
    local file="$1"

    # Kontrollerar om filen existerar
    if [ -f "$file" ]; then

        # Loggar att filen finns
        log "Filen '$file' finns."

        # Visar filens information och sparar i loggfilen
        stat "$file" | tee -a "$logfile"
    else

        # Loggar en varning om filen saknas
        log "VARNING: Filen '$file' saknas."
    fi
}

# Funktion som kontrollerar om en användare finns
check_user() {

    # Tar emot användarnamnet som parameter
    local user="$1"

    # Kontrollerar om användaren finns i systemet
    if id "$user" &>/dev/null; then

        # Loggar att användaren finns
        log "Användaren '$user' finns."
    else

        # Loggar en varning om användaren saknas
        log "VARNING: Användaren '$user' saknas."
    fi
}

# Frågar användaren vilken fil som ska kontrolleras
read -p "Ange fil att kontrollera: " file_input

# Kör filkontrollen
check_file "$file_input"

# Frågar användaren vilket användarnamn som ska kontrolleras
read -p "Ange användarnamn att kontrollera: " user_input

# Kör användarkontrollen
check_user "$user_input"

# Loggar att alla kontroller är slutförda
log "Kontroller slutförda."

