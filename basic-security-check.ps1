# Anger vilken fil som ska användas som loggfil
$LogFile = "security_log.txt"

# Funktion för att skriva loggmeddelanden
function Write-Log {

    # Tar emot ett meddelande som parameter
    param([string]$Message)

    # Skapar en loggrad med datum och meddelande
    $entry = "$(Get-Date) - $Message"

    # Skriver både till terminalen och till loggfilen (utan att skriva över)
    $entry | Tee-Object -FilePath $LogFile -Append
}

# Funktion som kontrollerar om en fil finns
function Check-File {

    # Tar emot sökvägen till filen som ska kontrolleras
    param([string]$Path)

    # Kontrollerar om filen existerar
    if (Test-Path $Path) {

        # Loggar att filen finns
        Write-Log "Filen '$Path' finns."

        # Hämtar filens attribut och sparar dem i loggfilen
        (Get-Item $Path).Attributes | Out-String | Tee-Object -FilePath $LogFile -Append
    }
    else {

        # Loggar en varning om filen saknas
        Write-Log "VARNING: Filen '$Path' saknas."
    }
}

# Funktion som kontrollerar om en lokal användare finns
function Check-User {

    # Tar emot användarnamnet som ska kontrolleras
    param([string]$User)

    # Försöker hitta användaren
    try {

        # Hämtar användaren, stoppar vid fel
        $exists = Get-LocalUser -Name $User -ErrorAction Stop

        # Loggar att användaren finns
        Write-Log "Användaren '$User' finns."
    }
    catch {

        # Loggar en varning om användaren inte finns
        Write-Log "VARNING: Användaren '$User' saknas."
    }
}

# Frågar användaren vilken fil som ska kontrolleras
$File = Read-Host "Ange fil att kontrollera"

# Kör filkontrollen
Check-File -Path $File

# Frågar användaren vilket användarnamn som ska kontrolleras
$User = Read-Host "Ange användarnamn att kontrollera"

# Kör användarkontrollen
Check-User -User $User

# Loggar att alla kontroller är färdiga
Write-Log "Kontroller slutförda."
