$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$FontRoot = Join-Path $Root "assets\fonts"
$GoogleDir = Join-Path $FontRoot "google"
$GoogleCss = Join-Path $FontRoot "google-fonts.css"
$Pretendard = Join-Path $FontRoot "PretendardVariable.woff2"

New-Item -ItemType Directory -Force -Path $FontRoot | Out-Null
New-Item -ItemType Directory -Force -Path $GoogleDir | Out-Null

function Get-FontMagic {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return ""
    }

    $stream = [System.IO.File]::OpenRead($Path)
    try {
        $buffer = New-Object byte[] 4
        [void]$stream.Read($buffer, 0, 4)
        return [System.Text.Encoding]::ASCII.GetString($buffer)
    }
    finally {
        $stream.Dispose()
    }
}

function Test-WebFont {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }

    $item = Get-Item -LiteralPath $Path

    # Google Fonts uses unicode-range subsets. Some valid subsets are very small.
    if ($item.Length -lt 256) {
        return $false
    }

    $magic = Get-FontMagic -Path $Path
    return ($magic -eq "wOF2" -or $magic -eq "wOFF")
}

function Download-ValidFont {
    param(
        [string]$Url,
        [string]$Destination,
        [hashtable]$Headers
    )

    Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue

    if ($null -eq $Headers) {
        Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Destination -TimeoutSec 60
    }
    else {
        Invoke-WebRequest -UseBasicParsing -Headers $Headers -Uri $Url -OutFile $Destination -TimeoutSec 60
    }

    if (-not (Test-WebFont -Path $Destination)) {
        $size = 0
        $magic = ""
        if (Test-Path -LiteralPath $Destination) {
            $size = (Get-Item -LiteralPath $Destination).Length
            $magic = Get-FontMagic -Path $Destination
        }
        throw "Invalid webfont: $Url (bytes=$size, magic=$magic)"
    }
}

# ------------------------------------------------------------------
# 1. Pretendard Variable
# ------------------------------------------------------------------
if (-not (Test-WebFont -Path $Pretendard)) {
    $pretendardUrls = @(
        "https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/packages/pretendard/dist/web/variable/woff2/PretendardVariable.woff2",
        "https://unpkg.com/pretendard@1.3.9/dist/web/variable/woff2/PretendardVariable.woff2",
        "https://raw.githubusercontent.com/orioncactus/pretendard/v1.3.9/packages/pretendard/dist/web/variable/woff2/PretendardVariable.woff2"
    )

    $ok = $false
    foreach ($url in $pretendardUrls) {
        try {
            Download-ValidFont -Url $url -Destination $Pretendard -Headers $null
            $ok = $true
            break
        }
        catch {
            Remove-Item -LiteralPath $Pretendard -Force -ErrorAction SilentlyContinue
        }
    }

    if (-not $ok) {
        throw "Pretendard download failed."
    }
}

# ------------------------------------------------------------------
# 2. Google Fonts: A+ Korean typography + ending handwriting
# ------------------------------------------------------------------
$cssUrl = "https://fonts.googleapis.com/css2?family=Gowun+Batang:wght@400;700&family=Gowun+Dodum&family=Nanum+Pen+Script&family=Caveat:wght@400;500;600&display=swap"

$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/140 Safari/537.36"
}

$response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $cssUrl -TimeoutSec 60
$css = [string]$response.Content

# Chrome response uses gstatic webfont URLs. We intentionally accept WOFF or WOFF2.
$regex = [regex]'https://fonts\.gstatic\.com/[^)\s]+'
$matches = $regex.Matches($css)

if ($matches.Count -eq 0) {
    throw "No Google Fonts download URLs were found."
}

$urlMap = @{}
$fileIndex = 0

foreach ($match in $matches) {
    $fontUrl = $match.Value

    if ($urlMap.ContainsKey($fontUrl)) {
        continue
    }

    $fileIndex++
    $fileName = "gf_{0:D2}.woff2" -f $fileIndex
    $destination = Join-Path $GoogleDir $fileName

    Download-ValidFont -Url $fontUrl -Destination $destination -Headers $headers
    $urlMap[$fontUrl] = "google/$fileName"
}

foreach ($fontUrl in $urlMap.Keys) {
    $css = $css.Replace($fontUrl, $urlMap[$fontUrl])
}

if ($css -match "https://fonts\.gstatic\.com") {
    throw "Google Fonts CSS still contains remote font URLs."
}

$pretendardCss = @"
@font-face {
  font-family: 'PretendardVariable';
  src: url('PretendardVariable.woff2') format('woff2');
  font-weight: 45 920;
  font-style: normal;
  font-display: swap;
}
"@

Set-Content -LiteralPath $GoogleCss -Value ($pretendardCss + "`r`n" + $css) -Encoding UTF8

Write-Host "[PASS] ROOTED fonts prepared locally." -ForegroundColor Green
Write-Host "Google webfont files:" $urlMap.Count
exit 0
