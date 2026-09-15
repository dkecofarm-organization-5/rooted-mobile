# ROOTED Evergreen v2.0 BGM RC8.6 — Typography Master

## Core decision
All **body prose** now uses one typography token, regardless of:
- image / no image,
- standard split / documentary split,
- text-only,
- statement,
- closing,
- resolution.

Only font size may change for editorial emphasis. The font family does not.

## Intended body typeface
Pretendard Variable v1.3.9.

General title:
- same Pretendard family, weight 600.

Editorial serif is restricted to:
- cover title,
- Part divider,
- Journey opener heading.

## Local/offline preparation
Run `PREPARE_ROOTED_FONTS.cmd` once while internet is available.
It prepares `assets/fonts/PretendardVariable.woff2` locally.
After preparation, the storybook uses the local file offline.

Final visual acceptance should not be performed until
`VERIFY_ROOTED_TYPOGRAPHY_FONT.cmd` reports PASS.
