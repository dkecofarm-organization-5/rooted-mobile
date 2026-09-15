# UI + RU Text Layout Fix v1.1.3

## Bottom controls
- duplicate KR / EN / RU buttons removed from bottom bar
- language selection remains only in the fixed top header
- playback bar is icon-only:
  - Pause / Resume
  - Restart
  - Stop
  - Fullscreen
- bar is normally hidden
- moving pointer into lower screen area reveals it
- touch reveals it
- bottom-right `•••` button can explicitly toggle controls
- automatic hide after ~3 seconds

## Russian text-only pages
The text block is now explicitly centered as a block:
- body width = `min(42em, 100%)`
- dense body width = `min(44em, 100%)`
- `align-self:center`
- internal Russian text remains left-aligned

This fixes pages whose content block looked shifted too far to the left.

## Retained
- fixed DK EcoFarm / FarmTOS-ON header
- fullscreen header persistence
- KR / EN / RU runtimes
- Timing Manager
