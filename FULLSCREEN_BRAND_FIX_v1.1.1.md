# FULLSCREEN BRAND FIX v1.1.1

## Issue fixed
In fullscreen mode, the fixed top branding layer (DK EcoFarm logo + FarmTOS-ON logo + language buttons)
could disappear depending on fullscreen behavior.

## Technical fix
- fullscreen target changed from `document.documentElement` to `#app`
- explicit fullscreen CSS rules added for:
  - `.brand-header`
  - `.book-frame`
  - `.gate`
  - `.controls`
  - `.status`
- fullscreen button now toggles:
  - `Fullscreen`
  - `Exit Fullscreen`

## Unchanged
- KR / EN / RU content
- language timing manager
- per-language timings
- bottom command bar persistence
