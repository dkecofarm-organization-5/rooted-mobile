$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Read-JsonUtf8([string]$Path){
  $text=[IO.File]::ReadAllText($Path,[Text.Encoding]::UTF8)
  return ($text | ConvertFrom-Json)
}

$summary=@()
foreach($lang in @('KR','EN','RU')){
  $jsonPath=Join-Path $Root "runtime\$lang\data.json"
  if(-not(Test-Path -LiteralPath $jsonPath)){ throw "Missing runtime data: $jsonPath" }
  $data=Read-JsonUtf8 $jsonPath
  if([string]$data.version -ne 'ROOTED v2.1.20 RC1'){ throw "Unexpected version [$lang]: $($data.version)" }
  if([int]$data.scenes.Count -ne 94){ throw "Unexpected scene count [$lang]: $($data.scenes.Count)" }

  $count=0
  foreach($scene in $data.scenes){
    if([string]::IsNullOrWhiteSpace([string]$scene.image)){ continue }
    $count++
    $base=Join-Path $Root "runtime\$lang"
    $candidate=[IO.Path]::GetFullPath((Join-Path $base ([string]$scene.image).Replace('/',[IO.Path]::DirectorySeparatorChar)))
    if(-not(Test-Path -LiteralPath $candidate -PathType Leaf)){ throw "Missing visual [$lang/$($scene.id)]: $candidate" }
    if((Get-Item -LiteralPath $candidate).Length -lt 1024){ throw "Visual too small [$lang/$($scene.id)]: $candidate" }

    # RU is intentionally routed to the canonical EN visual copy in RC1.
    # Verify that the retained RU-local copy is byte-identical so no visual content changed.
    if($lang -eq 'RU' -and ([string]$scene.image).StartsWith('../EN/assets/')){
      $rel=([string]$scene.image).Substring('../EN/'.Length).Replace('/',[IO.Path]::DirectorySeparatorChar)
      $ruLocal=Join-Path (Join-Path $Root 'runtime\RU') $rel
      if(-not(Test-Path -LiteralPath $ruLocal -PathType Leaf)){ throw "RU local visual missing [$($scene.id)]: $ruLocal" }
      $h1=(Get-FileHash -Algorithm SHA256 -LiteralPath $candidate).Hash
      $h2=(Get-FileHash -Algorithm SHA256 -LiteralPath $ruLocal).Hash
      if($h1 -ne $h2){ throw "RU/EN visual hash mismatch [$($scene.id)]" }
    }
  }
  if($count -ne 36){ throw "Unexpected image-scene count [$lang]: $count (expected 36)" }
  $summary += "$lang=$count"
}
Write-Host "PASS - ROOTED visual asset routes verified:" ($summary -join ', ')
exit 0
