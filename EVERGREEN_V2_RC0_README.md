# ROOTED Evergreen Digital Storybook v2.0 — Package Audit & Migration Gate

## 1. What the uploaded package actually is

The uploaded Windows distribution contains a trilingual integrated player and three language runtimes.
The **active runtime is not the 134-scene editorial master**. It is a **World Bank exhibition short derivative with 89 retained scenes**.

- KR runtime: 89 scenes / 13:57
- EN runtime: 89 scenes / 16:31
- RU runtime: 89 scenes / 15:04.5
- KR metadata explicitly states: `purpose = World Bank exhibition continuous booth playback`
- The 89-scene derivative was created from a 111-scene exhibition derivative, which in turn traces to the 134-scene author-approved master.
- Current short metadata states `assetReplacement = false` and `visualRedesign = false`.

### Editorial correction
For the actual operational player, the appropriate Evergreen migration baseline is therefore:
**89 current runtime scenes + 5 evergreen bridge/proof scenes = 94 scenes**, not an immediate rebuild to 139 scenes.

The 134-scene master remains the editorial truth source, but the 94-scene runtime is the more practical reusable delivery core for exhibitions and pre-sales.

## 2. RC0 structural changes applied

1. Added after `j3-close`
   - `bridge-who-we-are`
   - `bridge-what-we-build`
2. Added after `j8-close`
   - `proof-real-environments`
   - `proof-test-adjust`
   - `proof-across-borders`
3. KR FarmTOS-ON terminology patched from **권고** to **추천** in retained scenes where AI recommendation is meant.
4. Integrated browser UI wording changed from **Exhibition Player** to **Digital Storybook**.
5. World Bank-specific content was **not** added to the Evergreen core.
6. J12 closing / Final Resolution remains the last narrative sequence.
7. New five scenes are text-only placeholders in RC0 because verified high-resolution originals are not present in the uploaded ZIP.

## 3. Resulting runtime

- KR: 94 scenes / 14:56
- EN: 94 scenes / 17:36
- RU: 94 scenes / 16:13.5

The RU copy for the five newly added scenes is a structural editorial translation and is flagged for native editorial review before FINAL.

## 4. Image audit

Current package image inventory:
- JPG assets per language: **44**
- Used by the active 94-scene RC0: **31 existing JPGs** (the five new scenes currently have no image)
- Unused legacy JPGs: **13**
- Assets below 1920 px width: **44/44**
- Assets at or below 760 px width: **43/44**
- Largest width in the current asset set: **900 px**

This means the package is not yet a high-resolution visual master for Full-HD/4K exhibition use.

### Visual provenance gate
The packaged JPGs alone do not provide provenance metadata proving which images are documentary DK photos and which are staged/generated concepts.
For factual chapters—especially Uzbekistan, installation/capability transfer, FarmTOS operation, sensor/control verification and PROVEN IN THE FIELD—only verified actual photos should be used in FINAL.

## 5. Priority replacement gates

### P0 — must use verified actual photographs
- Journey 2: Uzbekistan
- Journey 3: installation / training / capability transfer
- Journey 4: actual sensor/control installation
- Journey 5: actual controller / FarmTOS operating architecture
- Journey 8: actual FarmTOS-ON recommendation/review or real operator view
- New PROVEN IN THE FIELD block

### P1 — replace preferred
- Journey 1 field-learning scenes
- Journey 6 safety inspection
- Journey 9 operator workload
- Journey 11 records / inspection / correction
- Journey 12 knowledge-transfer imagery

### P2 — conceptual imagery may remain, but only with high-resolution master
- Opening
- Journey 0 philosophical/climate-pressure scenes
- Journey 6 storm/safety atmosphere
- Journey 9 life/time scene
- Journey 10 name/abundance symbols
- Final Passing Hope hero

## 6. Minimum original-photo set needed for FINAL visual migration

Please supply original high-resolution source files (not screenshots from the print PDF) for these groups:

1. DK greenhouse field work / Who We Are
2. Cultivation space
3. Machine room / nutrient-solution / controller equipment
4. Control & oversight / actual FarmTOS or FarmTOS-ON screen
5. Uzbekistan AKIS greenhouse exterior
6. Uzbekistan installation / sensor mounting
7. Uzbekistan joint work / training / technical dialogue
8. Tomato greenhouse or equivalent real field-proven site
9. Equipment test
10. Field sensor inspection
11. Data validation / engineering review
12. Actual operator using FarmTOS-ON in a greenhouse
13. Field notebook / inspection / correction evidence
14. Approved high-resolution Passing Hope artwork

Preferred target: **2560×1440 or higher** for landscape masters; **1920×1080 minimum** after crop.

## 7. RC0 limitations

- Structural/static QA only. Windows installation and full-screen runtime execution were not executed in this Linux sandbox.
- No high-resolution image replacements were performed because the uploaded package contains only the current low-resolution JPG set.
- No narration was regenerated for the five new scenes.
- Installer shell names still contain the legacy word `Exhibition` for compatibility in RC0; rename should occur in the final distribution build after visual/runtime QA.
