@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo =====================================================
echo ROOTED KR/EN/RU Exhibition Diagnostic v1.1.9
echo =====================================================
echo Folder:
echo %CD%
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ROOTED_Launcher.ps1" -Mode player

set "ERR=%ERRORLEVEL%"
echo.
echo PowerShell exit code: %ERR%
if not "%ERR%"=="0" (
  echo.
  echo LAUNCH FAILED.
  echo Please capture this window.
) else (
  echo Launcher completed successfully.
)
echo.
pause
exit /b %ERR%
