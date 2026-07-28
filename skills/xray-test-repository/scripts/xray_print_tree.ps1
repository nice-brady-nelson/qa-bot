<#
Pretty-print a saved Xray getFolder GraphQL response as an indented tree with test counts.

Usage:
  ./xray_print_tree.ps1 "$env:TEMP\xray_tree.json"
  ./xray_folders.ps1 | ./xray_print_tree.ps1
#>
param(
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string]$InputPath
)

$ErrorActionPreference = "Stop"

if ($InputPath -and (Test-Path $InputPath)) {
    $raw = Get-Content $InputPath -Raw
} elseif ($InputPath) {
    $raw = $InputPath          # piped JSON string
} else {
    $raw = $input | Out-String
}

$json = $raw | ConvertFrom-Json
if ($json.errors) { throw "GraphQL error: $($json.errors | ConvertTo-Json -Depth 5)" }

$root = $json.data.getFolder
if (-not $root) { throw "No getFolder data in response." }

# testsCount is the count of tests filed DIRECTLY in a folder, not a rollup.
$script:Total = 0

function Show-Folders($folders, $indent = 0) {
    foreach ($f in $folders) {
        $pad = "  " * $indent
        $count = if ($f.testsCount) { $f.testsCount } else { 0 }
        $script:Total += $count
        Write-Host "$pad- $($f.name)  [$count tests]"
        if ($f.folders -and $f.folders.Count -gt 0) {
            Show-Folders $f.folders ($indent + 1)
        }
    }
}

Write-Host "=== XRAY TEST REPOSITORY STRUCTURE ==="
Write-Host "Root: $($root.name)"
Write-Host ""
Show-Folders $root.folders
Write-Host ""
Write-Host "Unfiled at root: $($root.testsCount) tests"
Write-Host "In folders:      $($script:Total) tests"
Write-Host "Repository total: $($root.testsCount + $script:Total) tests"
