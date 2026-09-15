# ROOTED Evergreen v2.0 BGM RC8.2 — Recheck Fix

## User-reported issues
1. Low-quality FarmTOS monitor / meeting visual.
2. Low-quality following indoor controller-assembly visual.
3. Previous / next screen icons not visible in the bottom command bar.

## Fixes
- J12-03 replaced with the user's higher-resolution field-knowledge conceptual image (`J2-2.png`).
- J12-05 replaced with the user's higher-resolution experience/data-transfer image (`ChatGPT Image 2026년 8월 12일 오후 03_50_47.png`).
- Old `p097.jpg` / `p098.jpg` compatibility assets now point to those new visuals.
- Obsolete `IMAGE_TEXT_RENDER_QA.html` removed from KR/EN/RU distribution to prevent confusion with old QA imagery.
- Bottom integrated command bar Previous/Next controls rebuilt with inline SVG chevrons and persistent visual styling.
- Root and runtime CSS/JS/iframe URLs cache-busted as `rc8.2` to prevent an older browser cache from showing stale scene data or controls.

## Scope
- 94 scenes per language retained.
- BGM-only release retained.
- Passing Hope retained.
- No narration added.
