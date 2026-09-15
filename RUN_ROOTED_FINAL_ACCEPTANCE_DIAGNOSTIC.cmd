@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================================
echo ROOTED v2.1.20 RC1 - Final Acceptance Diagnostic
echo ============================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ROOTED_Final_Acceptance_Diagnostic.ps1"
set "ERR=%ERRORLEVEL%"
echo.
if "%ERR%"=="0" (
  echo Static diagnostic PASS.
  echo.
  echo Next: double-click ROOTED_Exhibition.vbs and complete
  echo WINDOWS_FINAL_ACCEPTANCE_CHECKLIST.md.
) else (
  echo Static diagnostic FAILED. Do not promote to FINAL RELEASE.
)
echo.
pause
exit /b %ERR%
