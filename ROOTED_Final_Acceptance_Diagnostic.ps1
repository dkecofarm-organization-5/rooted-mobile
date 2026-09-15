param(
  [switch]$Launch
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Fail = 0

function Read-JsonUtf8([string]$Path){
  try{
    $text=[IO.File]::ReadAllText($Path,[Text.Encoding]::UTF8)
    return ($text | ConvertFrom-Json)
  }catch{
    throw "UTF-8 JSON parse failed: $Path"
  }
}

function Pass([string]$m){ Write-Host "[PASS] $m" -ForegroundColor Green }
function Fail([string]$m){ Write-Host "[FAIL] $m" -ForegroundColor Red; $script:Fail++ }

Write-Host ""
Write-Host "ROOTED v2.1.20 RC1 - FINAL ACCEPTANCE DIAGNOSTIC"
Write-Host "Root: $Root"
Write-Host ""

$required = @(
  "index.html",
  "player.js",
  "player.css",
  "ROOTED_Launcher.ps1",
  "ROOTED_Integrated_Server.ps1",
  "ROOTED_Exhibition.vbs",
  "VERIFY_FINAL_LOCAL_SCORE.ps1",
  "VERIFY_ROOTED_VISUALS.ps1",
  "runtime\KR\index.html",
  "runtime\EN\index.html",
  "runtime\RU\index.html",
  "runtime\KR\data.json",
  "runtime\EN\data.json",
  "runtime\RU\data.json"
)

foreach($rel in $required){
  $p = Join-Path $Root $rel
  if(Test-Path -LiteralPath $p -PathType Leaf){ Pass "Required file: $rel" }
  else { Fail "Missing required file: $rel" }
}

$expectedAudio=@{}
foreach($lang in @("KR","EN","RU")){
  try{
    $runtimeDir = Join-Path $Root "runtime\$lang"
    $dataPath = Join-Path $runtimeDir "data.json"
    $data = Read-JsonUtf8 $dataPath

    if([string]$data.version -eq "ROOTED v2.1.20 RC1"){ Pass "$lang release version = v2.1.20 RC1" }
    else { Fail "$lang release version = $($data.version), expected ROOTED v2.1.20 RC1" }
    if([string]$data.releaseStatus -eq "RC1"){ Pass "$lang releaseStatus = RC1" }
    else { Fail "$lang releaseStatus = $($data.releaseStatus), expected RC1" }

    if($data.scenes.Count -eq 94){ Pass "$lang scene count = 94" }
    else { Fail "$lang scene count = $($data.scenes.Count), expected 94" }

    $ids = @($data.scenes | ForEach-Object { $_.id })
    if(($ids | Select-Object -Unique).Count -eq 94){ Pass "$lang scene IDs unique" }
    else { Fail "$lang has duplicate scene IDs" }

    if($data.scenes[-1].id -eq "final-resolution"){ Pass "$lang final-resolution preserved" }
    else { Fail "$lang final scene is $($data.scenes[-1].id)" }

    $missingImages = @()
    foreach($scene in $data.scenes){
      if($scene.image){
        $img = [IO.Path]::GetFullPath((Join-Path $runtimeDir ([string]$scene.image)))
        if(-not (Test-Path -LiteralPath $img -PathType Leaf)){
          $missingImages += "$($scene.id): $($scene.image)"
        }
      }
    }
    if($missingImages.Count -eq 0){ Pass "$lang all scene image references resolve" }
    else {
      Fail "$lang missing image references:"
      $missingImages | ForEach-Object { Write-Host "       $_" }
    }

    $moves=@($data.originalScore.movementMap)
    if($moves.Count -eq 4){ Pass "$lang Original Score movement count = 4" }
    else { Fail "$lang Original Score movement count = $($moves.Count), expected 4" }

    foreach($move in $moves){
      $asset=[string]$move.asset
      $audioPath=[IO.Path]::GetFullPath((Join-Path $runtimeDir $asset))
      $name=[IO.Path]::GetFileName($audioPath)
      if(Test-Path -LiteralPath $audioPath -PathType Leaf){
        Pass "$lang $($move.move) audio resolves: $name"
        $expectedAudio[$name]=$true
        $hashProp=$data.originalScore.sha256.PSObject.Properties[$name]
        $expectedHash=""
        if($null -ne $hashProp){ $expectedHash=[string]$hashProp.Value }
        if([string]::IsNullOrWhiteSpace($expectedHash)){
          Fail "$lang $($move.move) SHA-256 metadata missing: $name"
        } else {
          $actual=(Get-FileHash -Algorithm SHA256 -LiteralPath $audioPath).Hash.ToLowerInvariant()
          if($actual -eq $expectedHash.ToLowerInvariant()){ Pass "$lang $($move.move) SHA-256 OK" }
          else { Fail "$lang $($move.move) SHA-256 mismatch: $name" }
        }
      } else {
        Fail "$lang $($move.move) audio missing: $asset"
      }
    }
  } catch {
    Fail "$lang runtime parse/check failed: $($_.Exception.Message)"
  }
}

$audioRoot=Join-Path $Root "assets\audio"
$allAudio=@(Get-ChildItem -LiteralPath $audioRoot -File -Filter *.mp3)
if($allAudio.Count -eq 12){ Pass "Active package audio file count = 12" }
else { Fail "Active package audio file count = $($allAudio.Count), expected 12" }
if($expectedAudio.Keys.Count -eq 12){ Pass "Referenced unique Original Score assets = 12" }
else { Fail "Referenced unique Original Score assets = $($expectedAudio.Keys.Count), expected 12" }
$unexpected=@($allAudio | Where-Object { -not $expectedAudio.ContainsKey($_.Name) })
if($unexpected.Count -eq 0){ Pass "No unreferenced MP3 assets in assets\\audio" }
else {
  Fail "Unexpected/unreferenced MP3 assets detected"
  $unexpected | ForEach-Object { Write-Host "       $($_.Name)" }
}

$voiceLike = @($allAudio | Where-Object { $_.Name -match '(?i)voice|narration|tts|narrator|speech' })
if($voiceLike.Count -eq 0){ Pass "No narration/TTS/voice audio assets detected" }
else {
  Fail "Unexpected voice-like audio assets detected"
  $voiceLike | ForEach-Object { Write-Host "       $($_.FullName)" }
}

try{
  & (Join-Path $Root "VERIFY_FINAL_LOCAL_SCORE.ps1")
  if($LASTEXITCODE -and $LASTEXITCODE -ne 0){ throw "VERIFY_FINAL_LOCAL_SCORE returned exit code $LASTEXITCODE" }
  Pass "Independent Original Score verifier completed"
} catch {
  Fail "Original Score verifier failed: $($_.Exception.Message)"
}

try{
  & (Join-Path $Root "VERIFY_ROOTED_VISUALS.ps1")
  if($LASTEXITCODE -and $LASTEXITCODE -ne 0){ throw "VERIFY_ROOTED_VISUALS returned exit code $LASTEXITCODE" }
  Pass "Independent visual-route verifier completed"
} catch {
  Fail "Visual-route verifier failed: $($_.Exception.Message)"
}

Write-Host ""
if($Fail -eq 0){
  Write-Host "STATIC ACCEPTANCE: PASS" -ForegroundColor Green
  Write-Host "Physical Windows fullscreen/BGM/loop test is still required."
  if($Launch){
    Write-Host "Launching ROOTED player..."
    Start-Process (Join-Path $Root "ROOTED_Exhibition.vbs")
  }
  exit 0
}else{
  Write-Host "STATIC ACCEPTANCE: FAIL ($Fail issue(s))" -ForegroundColor Red
  exit 1
}
