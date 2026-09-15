@echo off
setlocal
set "STATE=%LOCALAPPDATA%\DK EcoFarm\ROOTED RU Exhibition\State"
if exist "%STATE%\server.pid" (
  for /f "usebackq delims=" %%P in ("%STATE%\server.pid") do (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
      "$p=Get-CimInstance Win32_Process -Filter 'ProcessId=%%P' -ErrorAction SilentlyContinue; if($p -and $p.CommandLine -match 'ROOTED_RU_LocalServer\.ps1'){Stop-Process -Id %%P -Force -ErrorAction SilentlyContinue}"
  )
)
if exist "%STATE%" rmdir /s /q "%STATE%"
echo ROOTED RU runtime state reset.
pause
