$ErrorActionPreference = "Continue"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$FontRoot = Join-Path $Root "assets\fonts"

Write-Host "==============================================="
Write-Host "ROOTED FONT DIAGNOSTIC v2.1.3"
Write-Host "==============================================="
Write-Host "Font root:" $FontRoot
Write-Host ""

if (Test-Path -LiteralPath $FontRoot) {
    Get-ChildItem -LiteralPath $FontRoot -Recurse -File |
        Sort-Object FullName |
        ForEach-Object {
            $magic = ""
            try {
                $stream = [System.IO.File]::OpenRead($_.FullName)
                $buffer = New-Object byte[] 4
                [void]$stream.Read($buffer, 0, 4)
                $stream.Dispose()
                $magic = [System.Text.Encoding]::ASCII.GetString($buffer)
            }
            catch {}

            Write-Host ("{0,10} bytes  {1,-4}  {2}" -f $_.Length, $magic, $_.FullName)
        }
}
else {
    Write-Host "Font directory not found."
}

Write-Host ""
pause
