# Credentials come from the environment (or a gitignored .env) - never hardcode them.
if (-not $env:XRAY_CLIENT_ID -or -not $env:XRAY_CLIENT_SECRET) {
    throw "XRAY_CLIENT_ID and XRAY_CLIENT_SECRET must be set."
}
$creds = @{ client_id = $env:XRAY_CLIENT_ID; client_secret = $env:XRAY_CLIENT_SECRET } | ConvertTo-Json -Compress
$creds | Set-Content "$env:TEMP\xray_creds.json" -Encoding UTF8

$tokenRaw = curl.exe -s -X POST "https://xray.cloud.getxray.app/api/v2/authenticate" -H "Content-Type: application/json" --data-binary "@$env:TEMP\xray_creds.json"
Write-Host "AUTH_RESPONSE: $tokenRaw"

# Strip surrounding quotes from the JWT token string
$token = $tokenRaw.Trim('"')
$token | Set-Content "$env:TEMP\xray_token.txt" -Encoding UTF8

# Now fetch CXIFW test repository folder structure
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
Write-Host "`n--- Fetching CXIFW test repository folders ---"
try {
    $folders = Invoke-RestMethod -Uri "https://xray.cloud.getxray.app/api/v2/testrepository/CXIFW/folders" -Headers $headers
    $folders | ConvertTo-Json -Depth 10
} catch {
    Write-Host "REST ERROR: $($_.Exception.Message)"
    # Try GraphQL fallback
    Write-Host "`nTrying GraphQL approach..."
    $gql = '{"query":"{ getTestRepository(projectKey: \"CXIFW\") { folder { id name path folders { id name path folders { id name path } } } } }"}'
    $gql | Set-Content "$env:TEMP\xray_gql.json" -Encoding UTF8
    curl.exe -s -X POST "https://xray.cloud.getxray.app/api/v2/graphql" -H "Content-Type: application/json" -H "Authorization: Bearer $token" --data-binary "@$env:TEMP\xray_gql.json"
}
