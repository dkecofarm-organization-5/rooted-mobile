$ErrorActionPreference="Stop"
$Root=Split-Path -Parent $MyInvocation.MyCommand.Path
$AudioRoot=Join-Path $Root "assets\audio"
$Languages=@("KR","EN","RU")
$ExpectedTotal=12
$Seen=@{}

function Read-JsonUtf8([string]$Path){
  try{
    $text=[IO.File]::ReadAllText($Path,[Text.Encoding]::UTF8)
    return ($text | ConvertFrom-Json)
  }catch{
    throw "UTF-8 JSON parse failed: $Path"
  }
}

function Test-Mp3Header([string]$Path){
  $fs=[IO.File]::OpenRead($Path)
  try{
    $b=New-Object byte[] 4
    [void]$fs.Read($b,0,4)
  }finally{$fs.Dispose()}
  $id3=([Text.Encoding]::ASCII.GetString($b,0,3) -eq "ID3")
  $frame=($b[0] -eq 0xFF -and (($b[1] -band 0xE0) -eq 0xE0))
  return ($id3 -or $frame)
}

foreach($lang in $Languages){
  $dataPath=Join-Path $Root "runtime\$lang\data.json"
  if(-not(Test-Path -LiteralPath $dataPath -PathType Leaf)){ throw "$lang data.json is missing." }
  $data=Read-JsonUtf8 $dataPath
  $moves=@($data.originalScore.movementMap)
  if($moves.Count -ne 4){ throw "$lang Original Score movement count is $($moves.Count), expected 4." }
  foreach($move in $moves){
    $asset=[string]$move.asset
    if([string]::IsNullOrWhiteSpace($asset)){ throw "$lang $($move.move) has no audio asset." }
    $assetPath=[IO.Path]::GetFullPath((Join-Path (Join-Path $Root "runtime\$lang") $asset))
    if(-not(Test-Path -LiteralPath $assetPath -PathType Leaf)){ throw "$lang $($move.move) audio is missing: $asset" }
    if(-not $assetPath.StartsWith([IO.Path]::GetFullPath($AudioRoot),[StringComparison]::OrdinalIgnoreCase)){ throw "$lang $($move.move) audio resolves outside assets\\audio: $assetPath" }
    $fi=Get-Item -LiteralPath $assetPath
    if($fi.Length -lt 500000){ throw "$lang $($move.move) audio is unexpectedly small: $($fi.Name) / $($fi.Length) bytes" }
    if(-not(Test-Mp3Header $assetPath)){ throw "$lang $($move.move) audio is not a valid MP3 header: $($fi.Name)" }
    $hashProp=$data.originalScore.sha256.PSObject.Properties[$fi.Name]
    $expectedHash=""
    if($null -ne $hashProp){ $expectedHash=[string]$hashProp.Value }
    if([string]::IsNullOrWhiteSpace($expectedHash)){ throw "$lang $($move.move) SHA-256 metadata is missing: $($fi.Name)" }
    $actualHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $assetPath).Hash.ToLowerInvariant()
    if($actualHash -ne $expectedHash.ToLowerInvariant()){ throw "$lang $($move.move) SHA-256 mismatch: $($fi.Name)" }
    $Seen[$fi.Name]=$true
    Write-Host "[PASS] $lang $($move.move): $($fi.Name) / $($fi.Length) bytes / SHA-256 OK" -ForegroundColor Green
  }
}

$allMp3=@(Get-ChildItem -LiteralPath $AudioRoot -File -Filter *.mp3)
if($allMp3.Count -ne $ExpectedTotal){ throw "Active audio count is $($allMp3.Count), expected $ExpectedTotal." }
if($Seen.Keys.Count -ne $ExpectedTotal){ throw "Referenced unique audio count is $($Seen.Keys.Count), expected $ExpectedTotal." }
$unreferenced=@($allMp3 | Where-Object { -not $Seen.ContainsKey($_.Name) })
if($unreferenced.Count -gt 0){ throw "Unreferenced MP3 asset(s): $($unreferenced.Name -join ', ')" }
Write-Host "[PASS] Embedded Original Score: 12/12 active MP3 files verified for KR / EN / RU." -ForegroundColor Green
