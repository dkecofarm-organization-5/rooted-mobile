# ROOTED v2.1.20 RC1 — Windows Acceptance

Test on the actual exhibition PC.

## A. Static / installation gate
- [ ] `RUN_ROOTED_FINAL_ACCEPTANCE_DIAGNOSTIC.cmd` = PASS
- [ ] `VERIFY_FINAL_LOCAL_SCORE.cmd` = PASS (KR/EN/RU 4-Move, 12 MP3, SHA-256)
- [ ] `VERIFY_ROOTED_VISUALS.cmd` = PASS
- [ ] installer GUI completes all 14 steps without `Embedded Original Score` error
- [ ] STEP 5 parses KR/EN/RU `data.json` without mojibake or JSON parse error
- [ ] `ROOTED_Exhibition.vbs` launches without visible PowerShell error
- [ ] local server starts
- [ ] Edge/app window opens maximized
- [ ] start screen displays correctly

## B. Language
- [ ] KR loads 94 scenes
- [ ] EN loads 94 scenes
- [ ] RU loads 94 scenes
- [ ] KR → EN → RU → KR switching works
- [ ] switching does not overlap BGM

## C. Audio architecture
- [ ] KR M1/M2/M3/M4 switch at scene boundaries 1/25/59/86
- [ ] EN M1/M2/M3/M4 switch at scene boundaries 1/25/59/86
- [ ] RU M1/M2/M3/M4 switch at scene boundaries 1/25/59/86
- [ ] J3 manual navigation starts/continues M2 correctly
- [ ] J8 manual navigation starts/continues M3 correctly
- [ ] J12 manual navigation starts/continues M4 correctly
- [ ] no legacy single-score audio is requested

## D. Controls
- [ ] Previous
- [ ] Next
- [ ] Pause / Resume
- [ ] BGM ON / OFF
- [ ] Volume 0–100%
- [ ] Fullscreen / maximized display
- [ ] Stop / return flow if used

## E. Visual / typography
- [ ] KR text is not clipped
- [ ] EN image / no-image / closing typography follows the locked sizing rules
- [ ] RU body has no overflow on the actual exhibition display
- [ ] RU `bridge-who-we-are` and `bridge-what-we-build` images render
- [ ] representative RU image scenes after the midpoint render
- [ ] KR/EN/RU body/title baselines are visually horizontal
- [ ] EN/RU final sign-off is horizontal and aligned
- [ ] no broken images
- [ ] documentary photo layouts have no objectionable black dead space
- [ ] actual-photo scenes are acceptably sharp at viewing distance
- [ ] Passing Hope hero displays correctly

## F. Audio / loop
- [ ] BGM plays through actual target speakers
- [ ] no clipping / crackle / abnormal volume jump
- [ ] M1/M2/M3 ending silence is audible as intended
- [ ] Closing fade-out is correct
- [ ] silence interval is correct
- [ ] ROOTS restart / opening is correct
- [ ] no double BGM after language change or loop

## G. Stability
- [ ] complete KR STORY playback
- [ ] complete EN STORY playback
- [ ] complete RU STORY playback
- [ ] at least 2 consecutive auto loops
- [ ] no browser freeze / black screen / server loss

## Promotion rule
Only when every item above passes, promote this candidate to the FINAL RELEASE build. Do not change the 12-file KR/EN/RU 4-Move Original Score architecture during promotion.
