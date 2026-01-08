$Output = "..\data\windows_services.csv"
$LogFile = "..\data\anomalies.log"

function Write-Log {
    param([string]$Message)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" | Out-File -Append -FilePath $LogFile
}

# Hämta Windows-tjänster (ignorera PermissionDenied)
$services = Get-Service -ErrorAction SilentlyContinue | Select-Object Name, Status

# Exportera till CSV
$services | Export-Csv -NoTypeInformation -Path $Output

# Riskabla tjänster
$risky = @("Telnet", "RemoteRegistry", "Spooler")

foreach ($svc in $services) {
    if ($risky -contains $svc.Name) {
        Write-Log "VARNING – Riskabel Windows-tjänst upptäckt: $($svc.Name)"
    }
}

Write-Log "Windows-kontroll klar."
