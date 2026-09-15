$ErrorActionPreference="SilentlyContinue"
$Root=Split-Path -Parent $MyInvocation.MyCommand.Path

$Font=Join-Path $Root "assets\fonts\PretendardVariable.woff2"
if(-not (Test-Path -LiteralPath $Font -PathType Leaf)){
  Write-Host "[WARN] Pretendard webfont is not prepared." -ForegroundColor Yellow
  Write-Host "Run PREPARE_ROOTED_FONTS.cmd before final typography acceptance."
}

$local = Join-Path $env:LOCALAPPDATA "DK EcoFarm"
$states = @(
  (Join-Path $local "ROOTED Integrated Exhibition v1.1.9\State"),
  (Join-Path $local "ROOTED Evergreen v2.0 RC8.4\State"),
  (Join-Path $local "ROOTED Evergreen v2.0 RC8.5\State"),
  (Join-Path $local "ROOTED Evergreen v2.0 RC8.6\State"),
  (Join-Path $local "ROOTED Evergreen v2.0 RC8.7\State"),
  (Join-Path $local "ROOTED Evergreen v2.0 V9.0.5\State")
)
foreach($state in $states){
  $pidFile=Join-Path $state "server.pid"
  if(Test-Path $pidFile){
    try{
      $pid=[int](Get-Content $pidFile | Select-Object -First 1)
      $proc=Get-CimInstance Win32_Process -Filter "ProcessId=$pid"
      if($proc -and $proc.CommandLine -match 'ROOTED_Integrated_Server\.ps1'){
        Stop-Process -Id $pid -Force
      }
    }catch{}
  }
  Remove-Item (Join-Path $state "server.port") -Force -ErrorAction SilentlyContinue
  Remove-Item (Join-Path $state "server.pid") -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Milliseconds 300
& (Join-Path $Root "ROOTED_Launcher.ps1") -Mode player
