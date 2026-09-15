param(
  [ValidateSet("player","manager")][string]$Mode="player"
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$State = Join-Path $env:LOCALAPPDATA "DK EcoFarm\ROOTED Evergreen v2.0 V9.0.5\State"
$PortFile = Join-Path $State "server.port"
$PidFile = Join-Path $State "server.pid"
$ServerScript = Join-Path $Root "ROOTED_Integrated_Server.ps1"

New-Item -ItemType Directory -Force -Path $State | Out-Null

function Test-Health([int]$Port) {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$Port/__health" -TimeoutSec 1
    $expected = "ROOTED_V905_OK|" + $Root
    return ($r.StatusCode -eq 200 -and $r.Content -eq $expected)
  } catch {
    return $false
  }
}

function Clear-StaleState {
  if(Test-Path $PidFile){
    try {
      $oldPid = [int](Get-Content $PidFile -ErrorAction Stop | Select-Object -First 1)
      $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$oldPid" -ErrorAction SilentlyContinue
      if($proc -and $proc.CommandLine -and
         $proc.CommandLine -match 'ROOTED_Integrated_Server\.ps1'){
        Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 200
      }
    } catch {}
  }
  Remove-Item $PortFile -Force -ErrorAction SilentlyContinue
  Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}

function Get-FreePort {
  for($i=0; $i -lt 40; $i++){
    $candidate = Get-Random -Minimum 18000 -Maximum 45000
    $listener = $null
    try {
      $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$candidate)
      $listener.Start()
      $listener.Stop()
      return $candidate
    } catch {
      if($listener){ try{$listener.Stop()}catch{} }
    }
  }
  throw "No free local TCP port could be allocated."
}

$port = $null

# Reuse only a server that is genuinely healthy in THIS release's state folder.
if(Test-Path $PortFile){
  try {
    $saved = [int](Get-Content $PortFile -ErrorAction Stop | Select-Object -First 1)
    if(Test-Health $saved){
      $port = $saved
    } else {
      Clear-StaleState
    }
  } catch {
    Clear-StaleState
  }
}

if($null -eq $port){
  if(-not (Test-Path -LiteralPath $ServerScript)){
    throw "ROOTED_Integrated_Server.ps1 is missing."
  }

  $port = Get-FreePort

  $server = Start-Process powershell.exe `
    -WindowStyle Hidden `
    -PassThru `
    -ArgumentList @(
      '-NoProfile',
      '-ExecutionPolicy','Bypass',
      '-File',('"' + $ServerScript + '"'),
      '-Root',('"' + $Root + '"'),
      '-Port',$port
    )

  Set-Content -Path $PidFile -Value $server.Id -Encoding ASCII
  Set-Content -Path $PortFile -Value $port -Encoding ASCII

  $ready = $false
  for($i=0; $i -lt 40; $i++){
    if(Test-Health $port){
      $ready = $true
      break
    }
    Start-Sleep -Milliseconds 100
  }

  if(-not $ready){
    try { Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue } catch {}
    Clear-StaleState
    throw "ROOTED local server failed to start or did not pass health check."
  }
}

if($Mode -eq "manager"){
  $url = "http://127.0.0.1:$port/manager/?release=2.1.20-RC1"
} else {
  $url = "http://127.0.0.1:$port/player/?release=2.1.20-RC1"
}

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
