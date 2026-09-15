$ErrorActionPreference = "Stop"

$AppDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StateDir = Join-Path $env:LOCALAPPDATA "DK EcoFarm\ROOTED RU Exhibition\State"
$PidFile = Join-Path $StateDir "server.pid"
$PortFile = Join-Path $StateDir "server.port"
$ServerScript = Join-Path $AppDir "ROOTED_RU_LocalServer.ps1"

New-Item -ItemType Directory -Force -Path $StateDir | Out-Null

function Test-RootedHealth([int]$Port) {
    try {
        $health = "http://127.0.0.1:$Port/__health"
        $r = Invoke-WebRequest -UseBasicParsing -Uri $health -TimeoutSec 1
        return ($r.StatusCode -eq 200 -and $r.Content -match 'ROOTED_RU_OK')
    } catch {
        return $false
    }
}

function Get-FreePort {
    for($i=0; $i -lt 30; $i++){
        $candidate = Get-Random -Minimum 18000 -Maximum 45000
        $test = $null
        try {
            $test = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$candidate)
            $test.Start()
            $test.Stop()
            return $candidate
        } catch {
            if($test){ try { $test.Stop() } catch {} }
        }
    }
    throw "Unable to allocate a local TCP port."
}

# FAST PATH:
# If the server from the previous launch is still alive, reuse it immediately.
$port = $null
if(Test-Path $PortFile){
    try {
        $savedPort = [int](Get-Content $PortFile -ErrorAction Stop | Select-Object -First 1)
        if(Test-RootedHealth $savedPort){
            $port = $savedPort
        }
    } catch {}
}

# COLD PATH:
# Start a new server only when no healthy ROOTED server exists.
if($null -eq $port){
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    Remove-Item $PortFile -Force -ErrorAction SilentlyContinue

    $port = Get-FreePort
    $quotedServer = '"' + $ServerScript + '"'
    $quotedRoot = '"' + $AppDir + '"'

    $server = Start-Process powershell.exe -WindowStyle Hidden -PassThru -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy','Bypass',
        '-File',$quotedServer,
        '-Root',$quotedRoot,
        '-Port',$port
    )

    Set-Content -Path $PidFile -Value $server.Id -Encoding ASCII
    Set-Content -Path $PortFile -Value $port -Encoding ASCII

    $ready = $false
    # 20 x 100ms = max ~2 seconds, normally much faster.
    for($i=0; $i -lt 20; $i++){
        if(Test-RootedHealth $port){
            $ready = $true
            break
        }
        Start-Sleep -Milliseconds 100
    }

    if(-not $ready){
        try { Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue } catch {}
        Add-Type -AssemblyName PresentationFramework
        [System.Windows.MessageBox]::Show(
            "ROOTED Russian Exhibition could not start its local runtime server.",
            "ROOTED Exhibition",
            'OK',
            'Error'
        ) | Out-Null
        exit 1
    }
}

$url = "http://127.0.0.1:$port/?release=ROOTED-RU-EXHIBITION-v1.1.1"

$edgeCandidates = @(
    "$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
)
$edge = $edgeCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if($edge){
    Start-Process $edge -ArgumentList @(
        "--app=$url",
        "--start-maximized",
        "--no-first-run",
        "--disable-features=TranslateUI"
    )
} else {
    Start-Process $url
}
