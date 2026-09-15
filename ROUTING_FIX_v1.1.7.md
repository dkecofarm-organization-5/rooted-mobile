# Routing Fix v1.1.7

## Symptom
The player opened, but:
- CSS was not applied
- DK EcoFarm / FarmTOS-ON images were broken
- KR / EN / RU iframe areas showed 404

## Root cause
The launcher opened:

`/player/`

The HTML then requested relative assets as:
- `/player/player.css`
- `/player/assets/...`
- `/player/runtime/KR/...`

The local server handled only `/player/` itself, not files below the `/player/` prefix.

## Fix
The server now treats `/player/` as a virtual prefix and strips it before resolving files.

Examples:
- `/player/player.css` -> `<root>/player.css`
- `/player/assets/...` -> `<root>/assets/...`
- `/player/runtime/RU/index.html` -> `<root>/runtime/RU/index.html`

The same prefix handling is applied to `/manager/`.

## State isolation
v1.1.7 uses its own local state folder, so it will not reuse the broken v1.1.6 server instance.
