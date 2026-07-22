$raw = Get-Content "c:\Users\bradyn\AppData\Roaming\Code\copilot-terminal-output\copilot-terminal-output-ac082061-acfd-41b4-8f5e-36d7b04205d8.txt" -Raw
$json = $raw | ConvertFrom-Json

function Show-Folders($folders, $indent = 0) {
    foreach ($f in $folders) {
        $pad = "  " * $indent
        $count = if ($f.testsCount) { $f.testsCount } else { 0 }
        Write-Host "$pad- $($f.name)  [$count tests]"
        if ($f.folders -and $f.folders.Count -gt 0) {
            Show-Folders $f.folders ($indent + 1)
        }
    }
}

Write-Host "=== CXIFW TEST REPOSITORY STRUCTURE ==="
Write-Host "Root: $($json.data.getFolder.name) [$($json.data.getFolder.testsCount) total tests]"
Write-Host ""
Show-Folders $json.data.getFolder.folders
