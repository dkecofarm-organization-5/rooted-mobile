@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo ================================================
echo ROOTED RU Exhibition - Diagnostic Start v1.1.1
echo ================================================
echo Folder:
echo %CD%
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0START_ROOTED_RU_EXHIBITION.ps1"

set "ERR=%ERRORLEVEL%"
echo.
if "%ERR%"=="0" (
  echo PASS: Launcher returned successfully.
) else (
  echo FAIL: Launcher exit code = %ERR%
  echo Please capture this window.
)
echo.
pause
exit /b %ERR%
