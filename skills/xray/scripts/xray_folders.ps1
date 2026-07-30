<#
Query the Xray test repository folder tree via GraphQL.
Requires xray_auth.ps1 to have been run first (token cached in $env:TEMP\xray_token.txt).

Note: GraphQL requires the NUMERIC project id, not the project key.
  CXIFW = 13458
#>
param(
    [string]$ProjectId = "13458",
    [string]$Path = "/",
    [string]$OutFile
)

$ErrorActionPreference = "Stop"

$tokenFile = Join-Path $env:TEMP "xray_token.txt"
if (-not (Test-Path $tokenFile)) { throw "No cached token. Run xray_auth.ps1 first." }
$token = (Get-Content $tokenFile -Raw).Trim()

# Plain quotes here — ConvertTo-Json below does the JSON escaping.
$query = "{ getFolder(projectId: `"$ProjectId`", path: `"$Path`") { name path testsCount folders } }"
$gql = @{ query = $query } | ConvertTo-Json -Compress
$gqlFile = Join-Path $env:TEMP "xray_gql.json"
$gql | Set-Content $gqlFile -Encoding UTF8

$result = curl.exe -s -X POST "https://xray.cloud.getxray.app/api/v2/graphql" `
    -H "Content-Type: application/json" -H "Authorization: Bearer $token" `
    --data-binary "@$gqlFile"

Remove-Item $gqlFile -ErrorAction SilentlyContinue

if ($OutFile) {
    # Windows PowerShell's -Encoding UTF8 emits a BOM, which breaks strict JSON
    # parsers downstream. Write BOM-less UTF-8 explicitly.
    [System.IO.File]::WriteAllText($OutFile, ($result -join "`n"), (New-Object System.Text.UTF8Encoding $false))
    Write-Host "Wrote response to $OutFile"
}
Write-Output $result
