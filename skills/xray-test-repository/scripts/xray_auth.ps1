<#
Authenticate to the Xray Cloud API and cache the bearer token.

Credentials are read from $env:XRAY_CLIENT_ID / $env:XRAY_CLIENT_SECRET, or from a
.env file (searched: -EnvFile, ./.env, then the plugin root).

Token is cached at $env:TEMP\xray_token.txt for the other scripts in this skill.
#>
param(
    [string]$ProjectKey = "CXIFW",
    [string]$EnvFile
)

$ErrorActionPreference = "Stop"

function Import-DotEnv([string]$Path) {
    if (-not (Test-Path $Path)) { return }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $k, $v = $line.Split("=", 2)
            $v = $v.Trim().Trim('"').Trim("'")
            if (-not [Environment]::GetEnvironmentVariable($k.Trim())) {
                [Environment]::SetEnvironmentVariable($k.Trim(), $v, "Process")
            }
        }
    }
}

foreach ($candidate in @(
    $EnvFile,
    (Join-Path (Get-Location) ".env"),
    (Join-Path $PSScriptRoot "..\.env"),
    (Join-Path $PSScriptRoot "..\..\..\.env")
)) {
    if ($candidate) { Import-DotEnv $candidate }
}

if (-not $env:XRAY_CLIENT_ID -or -not $env:XRAY_CLIENT_SECRET) {
    throw "XRAY_CLIENT_ID and XRAY_CLIENT_SECRET must be set (env vars or .env file)."
}

$creds = @{ client_id = $env:XRAY_CLIENT_ID; client_secret = $env:XRAY_CLIENT_SECRET } | ConvertTo-Json -Compress
$credFile = Join-Path $env:TEMP "xray_creds.json"
$creds | Set-Content $credFile -Encoding UTF8

try {
    $tokenRaw = curl.exe -s -X POST "https://xray.cloud.getxray.app/api/v2/authenticate" `
        -H "Content-Type: application/json" --data-binary "@$credFile"
} finally {
    Remove-Item $credFile -ErrorAction SilentlyContinue
}

# Xray returns the JWT as a bare quoted string
$token = $tokenRaw.Trim('"')
if (-not $token -or $token.Length -lt 20) { throw "Authentication failed: $tokenRaw" }

$tokenFile = Join-Path $env:TEMP "xray_token.txt"
$token | Set-Content $tokenFile -Encoding UTF8
Write-Host "Authenticated. Token cached at $tokenFile"

# Try the REST folder listing, fall back to GraphQL
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
Write-Host "`n--- Fetching $ProjectKey test repository folders ---"
try {
    $folders = Invoke-RestMethod -Uri "https://xray.cloud.getxray.app/api/v2/testrepository/$ProjectKey/folders" -Headers $headers
    $folders | ConvertTo-Json -Depth 10
} catch {
    Write-Host "REST unavailable ($($_.Exception.Message)) - use xray_folders.ps1 (GraphQL) instead."
}
