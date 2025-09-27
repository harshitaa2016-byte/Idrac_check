# Force TLS 1.2 or 1.3
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Trust all SSL certificates (not safe for production)
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Credentials
$username = "root"
$password = "password"
$secPassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secPassword)

# Domain suffix
$domainSuffix = "FQDN"

# Site list
$siteFile = "C:\Users\user\scripts\sites.txt"
if (-not (Test-Path $siteFile)) {
    Write-Error "Input file '$siteFile' not found."
    exit 1
}

$siteIDs = Get-Content $siteFile | Where-Object { $_.Trim() -and ($_ -notmatch "^Site_ID") }

Write-Output "Starting iDRAC Redfish batch operations..."

foreach ($siteID in $siteIDs) {
    $fqdn = "$siteID$domainSuffix"
    Write-Output "Processing $fqdn"

    try {
        # Get system info (check power state)
        $systemUri = "https://$fqdn/redfish/v1/Systems/System.Embedded.1"
        $systemInfo = Invoke-RestMethod -Uri $systemUri -Credential $cred -UseBasicParsing -ErrorAction Stop
        $powerState = $systemInfo.PowerState

        if ($powerState -ne "On") {
            $powerUri = "https://$fqdn/redfish/v1/Systems/System.Embedded.1/Actions/ComputerSystem.Reset"
            $body = @{ "ResetType" = "On" } | ConvertTo-Json
            Invoke-RestMethod -Uri $powerUri -Method POST -Credential $cred -Body $body -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
            Write-Output "Power On command sent to $fqdn"
        } else {
            Write-Output "$fqdn is already powered on."
        }

        Start-Sleep -Seconds 10

        # Reboot iDRAC
        $idracResetUri = "https://$fqdn/redfish/v1/Managers/iDRAC.Embedded.1/Actions/Manager.Reset"
        $resetBody = @{ "ResetType" = "GracefulRestart" } | ConvertTo-Json
        Invoke-RestMethod -Uri $idracResetUri -Method POST -Credential $cred -Body $resetBody -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
        Write-Output "iDRAC reboot command sent to $fqdn"

    } catch {
        $errorMessage = $_.Exception.Message
        Write-Warning ("Failed to process ${fqdn}: $errorMessage")
    }

    Write-Output "Completed $fqdn"
    Write-Output "-----------------------------"
}

Write-Output "All sites processed."


