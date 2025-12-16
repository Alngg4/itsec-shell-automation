# Anger vilken loggfil som ska analyseras
$InputFile = "sample.log"

# Anger vilken fil analysresultatet ska sparas i
$LogFile = "analysis.log"

# Funktion för att skriva loggposter
function Write-Log {

    # Tar emot ett meddelande som parameter
    param([string]$Message)

    # Skapar en loggrad med datum och meddelande
    $entry = "$(Get-Date) - $Message"

    # Skriver till terminalen och sparar i loggfilen
    $entry | Tee-Object -FilePath $LogFile -Append
}

# Räknare för misslyckade inloggningar
$failed = 0

# Räknare för felmeddelanden
$error = 0

# Räknare för obehöriga försök
$unauth = 0

# Loopar igenom varje rad i loggfilen
foreach ($line in Get-Content $InputFile) {

    # Kontrollerar om raden innehåller "failed"
    if ($line -match "failed") {

        # Loggar misslyckat inloggningsförsök
        Write-Log "Misslyckat inloggningsförsök: $line"

        # Ökar räknaren
        $failed++
    }

    # Kontrollerar om raden innehåller "error"
    if ($line -match "error") {

        # Loggar hittat fel
        Write-Log "Error hittad: $line"

        # Ökar räknaren
        $error++
    }

    # Kontrollerar om raden innehåller "unauthorized"
    if ($line -match "unauthorized") {

        # Loggar obehörigt försök
        Write-Log "Obehörigt försök: $line"

        # Ökar räknaren
        $unauth++
    }
}

# Loggar att analysen är färdig
Write-Log "ANALYS KLAR"

# Skriver slutlig sammanfattning
Write-Log "Antal misslyckade inloggningar: $failed"
Write-Log "Antal errors: $error"
Write-Log "Antal obehöriga försök: $unauth"
