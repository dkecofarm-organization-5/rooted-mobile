$ErrorActionPreference="Stop"
$Root=Split-Path -Parent $MyInvocation.MyCommand.Path
$Font=Join-Path $Root "assets\fonts\PretendardVariable.woff2"

if(-not (Test-Path -LiteralPath $Font -PathType Leaf)){
  Write-Host "[FAIL] PretendardVariable.woff2 is missing." -ForegroundColor Red
  Write-Host "Run PREPARE_ROOTED_FONTS.cmd before final visual acceptance."
  exit 1
}
$size=(Get-Item -LiteralPath $Font).Length
if($size -le 1000000){
  Write-Host "[FAIL] Font file looks incomplete ($size bytes)." -ForegroundColor Red
  exit 1
}
Write-Host "[PASS] Pretendard local webfont is ready ($size bytes)." -ForegroundColor Green
exit 0
