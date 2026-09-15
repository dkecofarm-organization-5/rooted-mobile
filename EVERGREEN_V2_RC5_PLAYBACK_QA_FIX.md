# ROOTED Evergreen v2.0 RC5 — Playback QA Fix

## Corrections
- Restored Previous / Next buttons in the integrated bottom command bar.
- KR final-loop BGM behavior was aligned with the already-correct EN/RU direct runtime implementation: HOPE fade-out 5.5s → silence 1.75s → ROOTS restart using 5.5s crossfade.
- Removed the obsolete KR helper that attempted to locate a DOM `<audio>` element even though the runtime uses detached `new Audio()` objects.
- Increased dwell time for the five newly inserted Evergreen scenes where screen-reading density was materially higher than the established runtime distribution.
- Tightened English copy in the five inserted Evergreen scenes.
- RC4 Visual Lock and Passing Hope Hero are preserved.

## Audio scope finding
The package contains ten BGM MP3 tracks per language runtime. No narration/voiceover audio assets are present. Therefore this build can be QA'd as a BGM digital storybook, but it is not a completed narrated edition.

## Remaining release gate
Actual Windows full-screen playback on the target PC is still required before the package is named FINAL.
