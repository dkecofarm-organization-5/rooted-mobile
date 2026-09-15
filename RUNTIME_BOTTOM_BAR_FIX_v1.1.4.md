# Runtime Bottom Bar Fix v1.1.4

## Root cause
The integrated wrapper's bottom bar had been converted to icon controls,
but each embedded KR / EN / RU runtime still rendered its own internal
`READ / STORY / 5S / back / play / forward` footer.

That made the lower UI appear unchanged.

## Fix
When the child runtime is opened with:

`?integrated=1`

it now adds:

`html.integrated-mode`

and visually hides only:

`.bottom.chrome`

The DOM remains present, so the integrated parent player can still trigger
the hidden `#play`, navigation, and playback controls programmatically.

## Result in integrated mode
Visible lower UI:
- floating `•••` controller button
- icon-only playback bar when invoked
  - Pause / Resume
  - Restart
  - Stop
  - Fullscreen

Not visible:
- child `READ / STORY / 5S` bar
- duplicate child back/forward/play buttons

## Standalone runtimes
Standalone KR / EN / RU players are unchanged because `integrated-mode`
is activated only when `?integrated=1` is present.
