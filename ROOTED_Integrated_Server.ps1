param(
  [Parameter(Mandatory=$true)][string]$Root,
  [Parameter(Mandatory=$true)][int]$Port
)
$ErrorActionPreference="Stop"
$Root=[IO.Path]::GetFullPath((Resolve-Path $Root).Path).TrimEnd('\')
$Manager=Join-Path $Root "timing_manager"

function Read-JsonUtf8([string]$Path){
 try{
  $text=[IO.File]::ReadAllText($Path,[Text.Encoding]::UTF8)
  return ($text | ConvertFrom-Json)
 }catch{
  throw "UTF-8 JSON parse failed: $Path"
 }
}

function Mime([string]$p){
 switch -Regex ([IO.Path]::GetExtension($p).ToLowerInvariant()){
  '\.html?$'{'text/html; charset=utf-8';break}
  '\.js$'{'application/javascript; charset=utf-8';break}
  '\.css$'{'text/css; charset=utf-8';break}
  '\.json$'{'application/json; charset=utf-8';break}
  '\.svg$'{'image/svg+xml';break}
  '\.png$'{'image/png';break}
  '\.jpe?g$'{'image/jpeg';break}
  '\.webp$'{'image/webp';break}
  '\.mp3$'{'audio/mpeg';break}
  '\.wav$'{'audio/wav';break}
  default{'application/octet-stream';break}
 }
}
function Resp($s,[int]$code,[string]$reason,[byte[]]$body,[string]$ct){
 $h="HTTP/1.1 $code $reason`r`nContent-Type: $ct`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`nConnection: close`r`n`r`n"
 $hb=[Text.Encoding]::ASCII.GetBytes($h);$s.Write($hb,0,$hb.Length)
 if($body.Length){$s.Write($body,0,$body.Length)};$s.Flush()
}
function JResp($s,[int]$code,$obj){
 $json=$obj|ConvertTo-Json -Depth 100 -Compress
 Resp $s $code ($(if($code -eq 200){'OK'}else{'Error'})) ([Text.Encoding]::UTF8.GetBytes($json)) 'application/json; charset=utf-8'
}
function ReadBody($stream,[int]$len){
 $buf=New-Object byte[] $len;$read=0
 while($read -lt $len){$n=$stream.Read($buf,$read,$len-$read);if($n-le 0){break};$read+=$n}
 [Text.Encoding]::UTF8.GetString($buf,0,$read)
}

$l=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$Port);$l.Start()
try{
 while($true){
  $c=$l.AcceptTcpClient()
  try{
   $s=$c.GetStream();$r=New-Object IO.StreamReader($s,[Text.Encoding]::ASCII,$false,8192,$true)
   $req=$r.ReadLine();if([string]::IsNullOrWhiteSpace($req)){continue}
   $headers=@{}
   while($true){$line=$r.ReadLine();if([string]::IsNullOrEmpty($line)){break};$p=$line.IndexOf(':');if($p-gt 0){$headers[$line.Substring(0,$p).Trim().ToLowerInvariant()]=$line.Substring($p+1).Trim()}}
   $parts=$req.Split(' ');$method=$parts[0].ToUpperInvariant();$path=$parts[1].Split('?')[0]
   $len=0;if($headers.ContainsKey('content-length')){[int]::TryParse($headers['content-length'],[ref]$len)|Out-Null}

   if($path -eq '/__health'){
    $health = "ROOTED_V905_OK|" + $Root
    Resp $s 200 'OK' ([Text.Encoding]::UTF8.GetBytes($health)) 'text/plain; charset=utf-8';continue
   }

   if($path -match '^/api/data/(KR|EN|RU)$' -and $method -eq 'GET'){
    $lang=$Matches[1];$f=Join-Path $Root "runtime\$lang\data.json"
    Resp $s 200 'OK' ([IO.File]::ReadAllBytes($f)) 'application/json; charset=utf-8';continue
   }
   if($path -match '^/api/recommended/(KR|EN|RU)$' -and $method -eq 'GET'){
    $lang=$Matches[1];$f=Join-Path $Manager "recommended_$lang.json"
    Resp $s 200 'OK' ([IO.File]::ReadAllBytes($f)) 'application/json; charset=utf-8';continue
   }
   if($path -match '^/api/save/(KR|EN|RU)$' -and $method -eq 'POST'){
    $lang=$Matches[1]
    try{
      $obj=(ReadBody $s $len)|ConvertFrom-Json
      $jsonPath=Join-Path $Root "runtime\$lang\data.json"
      $currentRuntime=Read-JsonUtf8 $jsonPath
      $expectedSceneCount=[int]$currentRuntime.scenes.Count
      if(-not $obj.scenes -or $obj.scenes.Count -ne $expectedSceneCount){
        throw "Scene count must match current runtime: $expectedSceneCount."
      }
      foreach($scene in $obj.scenes){
        $d=[double]$scene.duration
        if($d-lt 3 -or $d-gt 60){throw "Duration out of range: $($scene.id)"}
      }
      $jsPath=Join-Path $Root "runtime\$lang\data.js"
      $backup=Join-Path $Root "runtime\$lang\data_before_timing_manager.json"
      if(-not(Test-Path $backup)){Copy-Item $jsonPath $backup -Force}
      $pretty=$obj|ConvertTo-Json -Depth 100
      [IO.File]::WriteAllText($jsonPath,$pretty,(New-Object Text.UTF8Encoding($false)))
      $compact=$obj|ConvertTo-Json -Depth 100 -Compress
      [IO.File]::WriteAllText($jsPath,"window.ROOTED_LANDSCAPE="+$compact+";`n",(New-Object Text.UTF8Encoding($false)))
      $total=0.0;foreach($scene in $obj.scenes){$total += [double]$scene.duration}
      $m=[math]::Floor($total/60);$sec=[math]::Round($total%60)
      JResp $s 200 @{ok=$true;runtime=("{0}:{1:D2}" -f $m,[int]$sec)}
    }catch{JResp $s 400 @{ok=$false;error=$_.Exception.Message}}
    continue
   }

   # Static routes
   # /player/ is a virtual prefix for the integrated player.
   # Strip it for all child assets so relative URLs such as
   # player.css, assets/* and runtime/* resolve correctly.
   if($path -eq '/manager/' -or $path -eq '/manager'){
     $file=Join-Path $Manager 'index.html'
   }
   elseif($path.StartsWith('/manager/')){
     $rel=$path.Substring('/manager/'.Length)
     if([string]::IsNullOrWhiteSpace($rel)){$rel='index.html'}
     $file=Join-Path $Manager ([Uri]::UnescapeDataString($rel).Replace('/',[IO.Path]::DirectorySeparatorChar))
   }
   elseif($path -eq '/player/' -or $path -eq '/player'){
     $file=Join-Path $Root 'index.html'
   }
   elseif($path.StartsWith('/player/')){
     $rel=$path.Substring('/player/'.Length)
     if([string]::IsNullOrWhiteSpace($rel)){$rel='index.html'}
     $file=Join-Path $Root ([Uri]::UnescapeDataString($rel).Replace('/',[IO.Path]::DirectorySeparatorChar))
   }
   else{
     $rel=$path.TrimStart('/')
     if([string]::IsNullOrWhiteSpace($rel)){$rel='index.html'}
     $file=Join-Path $Root ([Uri]::UnescapeDataString($rel).Replace('/',[IO.Path]::DirectorySeparatorChar))
   }
   $file=[IO.Path]::GetFullPath($file)
   if(-not($file.StartsWith($Root,[StringComparison]::OrdinalIgnoreCase)) -or -not(Test-Path $file -PathType Leaf)){
     Resp $s 404 'Not Found' ([Text.Encoding]::UTF8.GetBytes('404')) 'text/plain';continue
   }
   Resp $s 200 'OK' ([IO.File]::ReadAllBytes($file)) (Mime $file)
  }catch{}finally{try{$c.Close()}catch{}}
 }
}finally{try{$l.Stop()}catch{}}
