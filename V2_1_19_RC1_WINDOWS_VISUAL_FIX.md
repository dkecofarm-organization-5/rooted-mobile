# ROOTED v2.1.20 RC1 — Windows Visual Acceptance Correction

This candidate reopens v2.1.18 R2 after physical Windows review identified Russian visual/typography defects and EN/RU closing sign-off rotation.

## Corrections
- RU standard body: 34px optical enlargement removed; safe desktop baseline restored to 32px.
- RU integrated-window height tiers: 32px on tall desktop, 28px at 901–1040px height, 26px at <=900px height; 1366-class short-height fallback is 20px.
- RU prose uses one Segoe UI stack for Cyrillic and embedded Latin words to avoid mixed-font metrics.
- RU now loads the prepared local Google-font CSS, including Caveat for the final sign-off.
- EN/RU final sign-off rotation removed.
- RU final sign-off x-position aligned to the RU resolution text column.
- KR/EN/RU prose/title transforms explicitly locked to horizontal geometry.
- RU image scenes route to the EN visual copies, which were verified byte-identical to RU/KR in v2.1.18 R2.
- Added VERIFY_ROOTED_VISUALS.ps1/cmd and installer visual-asset gates.
- Runtime/player cache-buster changed to `v2.1.20-rc1`, and launcher release query changed to `2.1.20-RC1`, preventing an older browser resource set from being reused.
- RU image elements are explicitly locked visible (`display/opacity/visibility/filter`) in addition to canonical image routing.

## Preserved
- 94 scenes per language
- scene order and text content
- 12 Original Score MP3 files and 4-Move mapping
- KR/EN image files and all existing audio files byte-for-byte

## Promotion rule
This is RC1, not FINAL LOCK. Run TEST_INSTALL_WITHOUT_EXE.cmd on the target Windows PC and visually check RU bridge-who-we-are / bridge-what-we-build, representative later image scenes, all-language body geometry, and EN/RU final sign-off.
