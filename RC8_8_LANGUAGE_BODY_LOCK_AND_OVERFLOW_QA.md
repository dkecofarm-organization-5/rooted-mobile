# ROOTED Evergreen v2.0 BGM RC8.8
## Language-Specific Body Maximum Lock + 94-Scene Overflow QA

### Body hard lock
| Language | 1920-class | 1366-class |
|---|---:|---:|
| KR | **40px** | **27px** |
| EN | **38px** | **26px** |
| RU | **32px** | **22px** |

Within one language, the body size is identical for image pages, documentary pages, text-only pages, statements, closings, resolutions, and opener body copy. There is no per-scene body downsizing.

### Browser-rendered overflow QA
Chromium layout inspection was run across **94 scenes × 3 languages × 4 viewport conditions = 1,128 rendered scene-layout cases**.

Tested:
- 1920×1080
- 1366×768
- 1920×1004 (integrated-frame effective height)
- 1366×702 (integrated-frame effective height)

Result:
- KR: **0 overflow**
- EN: **0 overflow**
- RU: **0 overflow**

Computed body sizes matched the locks exactly.

### One layout-only correction
The KR Prologue initially overflowed only at the stricter integrated-frame heights. Its font remained 40/27px. Text-only paragraph spacing was changed to `0.72em`, after which every tested viewport passed.

### Font QA disclosure
The artifact does not distribute the font binary. Sandbox browser QA therefore used the available fallback stack. Before final Windows visual acceptance:
1. run `PREPARE_ROOTED_FONTS.cmd`
2. run `VERIFY_ROOTED_TYPOGRAPHY_FONT.cmd`
3. visually verify the package on the target Windows display.
