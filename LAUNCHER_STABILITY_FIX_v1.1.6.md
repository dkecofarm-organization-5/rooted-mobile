# Launcher Stability Fix v1.1.6

## Symptom
`START_ROOTED_EXHIBITION.bat` briefly opened a shell window and then nothing happened.

## Main correction
The launcher now uses a release-specific runtime state folder:

`%LOCALAPPDATA%\DK EcoFarm\ROOTED Integrated Exhibition v1.1.6\State`

This prevents an older ROOTED server/port state from being reused by the new build.

## Additional safeguards
- stale/unhealthy port state is removed automatically
- previous server PID is stopped only when its command line matches the ROOTED integrated server
- health check retries for up to ~4 seconds
- `.bat` launchers are written without UTF-8 BOM
- diagnostic launcher added:
  `START_ROOTED_EXHIBITION_DIAGNOSTIC.cmd`
- manual state reset:
  `RESET_ROOTED_V116_RUNTIME.cmd`

## UI/content
No content or layout changes were made in this fix.
The v1.1.5 unified chrome/fullscreen behavior is retained.
