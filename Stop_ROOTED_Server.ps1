$ErrorActionPreference="SilentlyContinue"
$State=Join-Path $env:LOCALAPPDATA "DK EcoFarm\ROOTED Integrated Exhibition v1.1.9\State"
$PidFile=Join-Path $State "server.pid"
$PortFile=Join-Path $State "server.port"
if(Test-Path $PidFile){
  try{
    $pidValue=[int](Get-Content $PidFile|Select-Object -First 1)
    $proc=Get-CimInstance Win32_Process -Filter "ProcessId=$pidValue" -ErrorAction SilentlyContinue
    if($proc -and $proc.CommandLine -match 'ROOTED_Integrated_Server\.ps1'){
      Stop-Process -Id $pidValue -Force -ErrorAction SilentlyContinue
    }
  }catch{}
}
Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
Remove-Item $PortFile -Force -ErrorAction SilentlyContinue
