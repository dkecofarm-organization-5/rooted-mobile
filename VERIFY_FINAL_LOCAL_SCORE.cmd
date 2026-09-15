@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0VERIFY_FINAL_LOCAL_SCORE.ps1"
if errorlevel 1 pause
