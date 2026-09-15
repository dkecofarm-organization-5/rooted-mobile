# Volume Launch Fix v1.1.9

## Confirmed root cause
The v1.1.8 HTML/JS already contained the new volume controls:
- mute/unmute
- volume down
- current %
- volume up

However, `ROOTED_Launcher.ps1` still reused the v1.1.7 state directory and release URL.
A healthy v1.1.7 server could therefore be reused, displaying the old UI without volume controls.

## Fix
- state directory changed to `ROOTED Integrated Exhibition v1.1.9`
- URL release query changed to `1.1.9`
- health marker changed to `ROOTED_MANAGER_V119_OK`
- v1.1.9 reset utility added

This prevents any v1.1.7/v1.1.8 server instance from being reused.
