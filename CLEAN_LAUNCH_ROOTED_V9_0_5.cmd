@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CLEAN_LAUNCH_ROOTED_V9_0_5.ps1"
