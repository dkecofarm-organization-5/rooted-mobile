@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DIAGNOSE_ROOTED_FONTS.ps1"
