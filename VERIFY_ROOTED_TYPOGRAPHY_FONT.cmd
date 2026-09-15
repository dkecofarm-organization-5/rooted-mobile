@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0VERIFY_ROOTED_TYPOGRAPHY_FONT.ps1"
echo.
pause
