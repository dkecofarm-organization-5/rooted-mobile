$ErrorActionPreference="SilentlyContinue"
$AppDir=Split-Path -Parent $MyInvocation.MyCommand.Path
$Desktop=[Environment]::GetFolderPath('Desktop')
$StartMenu=[Environment]::GetFolderPath('StartMenu')
& (Join-Path $AppDir 'Stop_ROOTED_Server.ps1')
Remove-Item (Join-Path $Desktop 'ROOTED Exhibition.lnk') -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $StartMenu 'Programs\DK EcoFarm\ROOTED Exhibition.lnk') -Force -ErrorAction SilentlyContinue
Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ROOTEDExhibition' -Recurse -Force -ErrorAction SilentlyContinue
$cmd='timeout /t 2 /nobreak >nul & rmdir /s /q "'+$AppDir+'"'
Start-Process cmd.exe -WindowStyle Hidden -ArgumentList '/c',$cmd
