$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$FontRoot = Join-Path $Root "assets\fonts"
$GoogleDir = Join-Path $FontRoot "google"
$GoogleCss = Join-Path $FontRoot "google-fonts.css"
$Pretendard = Join-Path $FontRoot "PretendardVariable.woff2"

if (-not (Test-Path -LiteralPath $Pretendard -PathType Leaf)) {
    throw "PretendardVariable.woff2 is missing."
}

if (-not (Test-Path -LiteralPath $GoogleCss -PathType Leaf)) {
    throw "google-fonts.css is missing."
}

$css = Get-Content -LiteralPath $GoogleCss -Raw

foreach ($family in @("Gowun Batang", "Gowun Dodum", "Nanum Pen Script", "Caveat")) {
    if ($css -notmatch [regex]::Escape($family)) {
        throw "Font family missing from local CSS: $family"
    }
}

if ($css -match "https://fonts\.gstatic\.com") {
    throw "Remote Google Fonts URL still remains in local CSS."
}

$fontFiles = @(Get-ChildItem -LiteralPath $GoogleDir -File -ErrorAction Stop)

if ($fontFiles.Count -lt 4) {
    throw "Too few local Google font files: $($fontFiles.Count)"
}

Write-Host "[PASS] ROOTED local fonts verified." -ForegroundColor Green
Write-Host "Local Google font files:" $fontFiles.Count
exit 0
