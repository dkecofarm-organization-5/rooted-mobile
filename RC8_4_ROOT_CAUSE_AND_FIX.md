# ROOTED Evergreen v2.0 BGM RC8.4 — Root Cause Fix

## Confirmed root cause
RC8.3 already contained Previous / Next buttons in the package HTML.

However, `ROOTED_Launcher.ps1` still reused the old state folder:

`%LOCALAPPDATA%\DK EcoFarm\ROOTED Integrated Exhibition v1.1.9\State`

and its health check only accepted the generic token:

`ROOTED_MANAGER_V119_OK`

Therefore, if an older ROOTED local server was still running, the launcher could reuse that old server even when RC8.3 was launched from a new folder. The old server continued serving the old command bar, exactly matching the user's screenshot.

## RC8.4 fix
- New release-specific state folder:
  `%LOCALAPPDATA%\DK EcoFarm\ROOTED Evergreen v2.0 RC8.4\State`
- Health response:
  `ROOTED_RC84_OK|<exact package root path>`
- The launcher only reuses a server when both the release and exact extracted folder match.
- `CLEAN_LAUNCH_ROOTED_RC8_4.cmd` stops known old ROOTED servers and launches this exact package.
- `VERIFY_RUNNING_ROOTED_RC8_4.cmd` proves that the running local server is serving this exact folder and that the served player HTML contains both Previous and Next controls.
