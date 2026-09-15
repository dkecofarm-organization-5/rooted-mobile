@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0VERIFY_ROOTED_VISUALS.ps1"
exit /b %ERRORLEVEL%
