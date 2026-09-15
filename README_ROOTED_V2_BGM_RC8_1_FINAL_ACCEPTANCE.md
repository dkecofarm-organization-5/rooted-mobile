# ROOTED Digital Storybook v2.1.20 RC1
## KR / EN / RU · 4-Move Original Score · FINAL ACCEPTANCE CANDIDATE

### Current release scope
- KR / EN / RU
- 94 scenes per language
- READ / STORY playback
- previous / next
- pause / resume
- language switching
- BGM on/off and volume
- Original Score: M1 / M2 / M3 / M4 per language
- active MP3 assets: 12 total (4 × 3 languages)
- narration/TTS/voice files: 0

### Audio architecture
- M1: Opening + J0–J2
- M2: J3–J7
- M3: J8–J11
- M4: J12 + Passing Hope + Final
- audio assets are centralized under `assets/audio`
- runtime language `data.json` stores movement mappings and SHA-256 metadata
- legacy single-score and 10-cue-per-language layouts are not part of this release

### R2 Windows compatibility correction
- BOM-less UTF-8 runtime JSON is read with explicit UTF-8 decoding before PowerShell JSON parsing.
- installer STEP 13 re-runs the current 12-file score verifier; no legacy `$Score` variable remains.

### Release status
Static/file-level QA and the corrected installer/acceptance scripts must pass before physical acceptance.
The target Windows exhibition PC still requires the physical gate documented in `WINDOWS_FINAL_ACCEPTANCE_CHECKLIST.md`.

Run `RUN_ROOTED_FINAL_ACCEPTANCE_DIAGNOSTIC.cmd` first on the target Windows PC.
