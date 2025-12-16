$InputFile = "sample.log"
$LogFile = "analysis.log"

function Write-Log {
    param([string]$Message)
    $entry = "$(Get-Date) - $Message"
    $entry | Tee-Object -FilePath $LogFile -Append
}

$failed = 0
$error = 0
$unauth = 0

foreach ($line in Get-Content $InputFile) {

    if ($line -match "failed") {
        Write-Log "Misslyckat inloggningsförsök: $line"
        $failed++
    }

    if ($line -match "error") {
        Write-Log "Error hittad: $line"
        $error++
    }

    if ($line -match "unauthorized") {
        Write-Log "Obehörigt försök: $line"
        $unauth++
    }
}

Write-Log "ANALYS KLAR"
Write-Log "Antal misslyckade inloggningar: $failed"
Write-Log "Antal errors: $error"
Write-Log "Antal obehöriga försök: $unauth"
