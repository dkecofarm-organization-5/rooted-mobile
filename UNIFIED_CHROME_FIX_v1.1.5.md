# UNIFIED CHROME FIX v1.1.5

## Root cause
There were two UI layers:
1. the integrated parent UI
2. each KR / EN / RU runtime's own top/bottom chrome

In normal mode, the child runtime footer could remain visible.
If the child runtime's own Fullscreen button was used, only the iframe entered fullscreen,
so the parent DK EcoFarm / FarmTOS-ON header disappeared.

## Fix
The parent now forces every loaded child runtime into integrated mode from the outside.

In integrated playback, child UI forcibly hidden:
- child top chrome
- child bottom chrome
- child drawer
- child build marker

The child playback DOM is still present so parent controls can operate it.

## Fullscreen
Only the integrated parent `#app` is allowed to enter fullscreen through the visible UI.

Therefore both normal and fullscreen modes retain:
- DK EcoFarm logo
- FarmTOS-ON logo
- KR / EN / RU top selector
- integrated playback controls

## Launcher cleanup
Old/conflicting exhibition launchers were removed.
Use only:
- `START_ROOTED_EXHIBITION.bat`
- `START_ROOTED_TIMING_MANAGER.bat`
