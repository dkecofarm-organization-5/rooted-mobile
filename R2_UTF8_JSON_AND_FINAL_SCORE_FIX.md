# ROOTED v2.1.18 FINAL RC R2 — Windows PowerShell UTF-8 JSON Fix

## Root cause confirmed
The R1 installer invoked `VERIFY_FINAL_LOCAL_SCORE.ps1`, which read UTF-8-without-BOM runtime `data.json` files using `Get-Content` without an explicit encoding. Windows PowerShell 5.1 can interpret BOM-less text using the active ANSI code page, corrupting KR/RU text before `ConvertFrom-Json`. This produced the GUI parse error around character 1053 and displayed mojibake in the error dialog.

## R2 corrections
- `VERIFY_FINAL_LOCAL_SCORE.ps1`: explicit strict UTF-8 `File.ReadAllText` before `ConvertFrom-Json`.
- `ROOTED_Final_Acceptance_Diagnostic.ps1`: same explicit UTF-8 reader.
- `ROOTED_Integrated_Server.ps1`: same explicit UTF-8 reader for the timing-manager save path.
- Windows installer STEP 13: removes stale `$Score` check and re-runs `VERIFY_FINAL_LOCAL_SCORE.ps1` for the final audio integrity gate.
- Installer catch block now emits a concise error instead of dumping a full multilingual JSON payload.

No story content, scene order, typography, image assets, or Original Score audio bytes were changed.
