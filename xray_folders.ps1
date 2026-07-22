$token = (Get-Content "$env:TEMP\xray_token.txt" -Raw).Trim()
# Query CXIFW test repository folders using numeric project ID 13458
$gql = '{"query":"{ getFolder(projectId: \"13458\", path: \"/\") { name path testsCount folders } }"}'
$gql | Set-Content "$env:TEMP\xray_gql.json" -Encoding UTF8
$result = curl.exe -s -X POST "https://xray.cloud.getxray.app/api/v2/graphql" -H "Content-Type: application/json" -H "Authorization: Bearer $token" --data-binary "@$env:TEMP\xray_gql.json"
Write-Host $result
