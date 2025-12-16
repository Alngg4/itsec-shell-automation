# Anger vilken loggfil som ska användas
$LogFile = "process_check.log"

# Funktion för att skriva loggmeddelanden
function Write-Log {

    # Tar emot ett meddelande som parameter
    param([string]$Message)

    # Skapar en loggrad med datum och meddelande
    $entry = "$(Get-Date) - $Message"

    # Skriver till terminalen och sparar i loggfilen
    $entry | Tee-Object -FilePath $LogFile -Append
}

# Funktion som kontrollerar om en process körs
function Check-Process {

    # Tar emot processnamnet som parameter
    param([string]$Name)

    # Försöker hämta processen utan att visa fel
    if (Get-Process -Name $Name -ErrorAction SilentlyContinue) {

        # Loggar att processen körs
        Write-Log "Processen '$Name' körs."
    }
    else {

        # Loggar en varning om processen inte körs
        Write-Log "VARNING: Processen '$Name' körs inte."
    }
}

# Funktion som läser processnamn från fil och kör kontroller
function Run-Checks {

    # Tar emot sökvägen till filen som parameter
    param([string]$Path)

    # Kontrollerar om filen finns
    if (-Not (Test-Path $Path)) {

        # Loggar fel om filen saknas
        Write-Log "FEL: Filen $Path saknas."

        # Avslutar skriptet
        exit
    }

    # Loopar igenom varje rad i filen
    foreach ($proc in Get-Content $Path) {

        # Kontrollerar varje process i listan
        Check-Process -Name $proc
    }
}

# Startar kontrollerna med filen som innehåller processnamn
Run-Checks "processlist.txt"

# Loggar att alla kontroller är färdiga
Write-Log "Kontroller slutförda."
