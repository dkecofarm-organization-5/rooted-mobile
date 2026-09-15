@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0VERIFY_ROOTED_FONTS.ps1"
if errorlevel 1 pause
