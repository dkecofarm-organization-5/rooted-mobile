param(
    [Parameter(Mandatory=$true)][string]$Root,
    [Parameter(Mandatory=$true)][int]$Port
)

$ErrorActionPreference = "Stop"
$Root = [IO.Path]::GetFullPath((Resolve-Path $Root).Path).TrimEnd('\')

function Get-MimeType([string]$Path) {
    switch -Regex ([IO.Path]::GetExtension($Path).ToLowerInvariant()) {
        '\.html?$'      { return 'text/html; charset=utf-8' }
        '\.js$'         { return 'application/javascript; charset=utf-8' }
        '\.css$'        { return 'text/css; charset=utf-8' }
        '\.json$'       { return 'application/json; charset=utf-8' }
        '\.svg$'        { return 'image/svg+xml' }
        '\.png$'        { return 'image/png' }
        '\.webp$'       { return 'image/webp' }
        '\.jpe?g$'      { return 'image/jpeg' }
        '\.gif$'        { return 'image/gif' }
        '\.ico$'        { return 'image/x-icon' }
        '\.mp3$'        { return 'audio/mpeg' }
        '\.wav$'        { return 'audio/wav' }
        '\.woff2$'      { return 'font/woff2' }
        '\.woff$'       { return 'font/woff' }
        default         { return 'application/octet-stream' }
    }
}

function Write-Response(
    [System.Net.Sockets.NetworkStream]$Stream,
    [int]$Status,
    [string]$Reason,
    [byte[]]$Body,
    [string]$ContentType,
    [bool]$HeadOnly = $false
) {
    $headers =
        "HTTP/1.1 $Status $Reason`r`n" +
        "Content-Type: $ContentType`r`n" +
        "Content-Length: $($Body.Length)`r`n" +
        "Cache-Control: no-store, no-cache, must-revalidate, max-age=0`r`n" +
        "Pragma: no-cache`r`n" +
        "Expires: 0`r`n" +
        "X-Content-Type-Options: nosniff`r`n" +
        "Connection: close`r`n`r`n"
    $hb = [Text.Encoding]::ASCII.GetBytes($headers)
    $Stream.Write($hb,0,$hb.Length)
    if(-not $HeadOnly -and $Body.Length -gt 0){
        $Stream.Write($Body,0,$Body.Length)
    }
    $Stream.Flush()
}

$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$Port)
$listener.Start()

try {
    while($true){
        $client = $listener.AcceptTcpClient()
        $client.ReceiveTimeout = 10000
        $client.SendTimeout = 10000
        try {
            $stream = $client.GetStream()
            $reader = New-Object IO.StreamReader(
                $stream,[Text.Encoding]::ASCII,$false,8192,$true
            )

            $requestLine = $reader.ReadLine()
            if([string]::IsNullOrWhiteSpace($requestLine)){ continue }

            while($true){
                $line = $reader.ReadLine()
                if([string]::IsNullOrEmpty($line)){ break }
            }

            $parts = $requestLine.Split(' ')
            if($parts.Count -lt 2){ continue }

            $method = $parts[0].ToUpperInvariant()
            $target = $parts[1]
            $pathOnly = $target.Split('?')[0]
            $pathOnly = [Uri]::UnescapeDataString($pathOnly)

            if($pathOnly -eq '/__health'){
                $body = [Text.Encoding]::UTF8.GetBytes('ROOTED_RU_OK')
                Write-Response $stream 200 'OK' $body 'text/plain; charset=utf-8' ($method -eq 'HEAD')
                continue
            }

            if($pathOnly -eq '/'){ $pathOnly = '/index.html' }

            $relative = $pathOnly.TrimStart('/').Replace('/',[IO.Path]::DirectorySeparatorChar)
            $full = [IO.Path]::GetFullPath((Join-Path $Root $relative))

            # Directory traversal guard.
            if(-not $full.StartsWith($Root,[StringComparison]::OrdinalIgnoreCase)){
                $body = [Text.Encoding]::UTF8.GetBytes('403 Forbidden')
                Write-Response $stream 403 'Forbidden' $body 'text/plain; charset=utf-8' ($method -eq 'HEAD')
                continue
            }

            if(-not (Test-Path -LiteralPath $full -PathType Leaf)){
                $body = [Text.Encoding]::UTF8.GetBytes('404 Not Found')
                Write-Response $stream 404 'Not Found' $body 'text/plain; charset=utf-8' ($method -eq 'HEAD')
                continue
            }

            if($method -ne 'GET' -and $method -ne 'HEAD'){
                $body = [Text.Encoding]::UTF8.GetBytes('405 Method Not Allowed')
                Write-Response $stream 405 'Method Not Allowed' $body 'text/plain; charset=utf-8' $false
                continue
            }

            $bytes = [IO.File]::ReadAllBytes($full)
            Write-Response $stream 200 'OK' $bytes (Get-MimeType $full) ($method -eq 'HEAD')
        }
        catch {
            # A single malformed request must not stop an exhibition session.
        }
        finally {
            try { $client.Close() } catch {}
        }
    }
}
finally {
    try { $listener.Stop() } catch {}
}
