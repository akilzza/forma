# Снимки сайта по частям (для проверки): анимация появления выключена.
# Запуск: powershell -File tools\parts.ps1 -w 1440 -h 1800 -n 6 -name d
param([int]$w = 1440, [int]$h = 1800, [int]$n = 6, [string]$name = "d")
$d = Split-Path $PSScriptRoot
$e = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$o = "$d\_shots"
New-Item -ItemType Directory -Force $o | Out-Null
$html = Get-Content "$d\index.html" -Raw -Encoding UTF8
$utf8 = [Text.UTF8Encoding]::new($false)
$url = "file:///" + ($d -replace '\\', '/') + "/_shot.html"
for ($i = 0; $i -lt $n; $i++) {
    $css = ".reveal{opacity:1!important;transform:none!important}.hero{min-height:900px!important}header{position:absolute!important}body{margin-top:-$($i*$h)px}"
    [IO.File]::WriteAllText("$d\_shot.html", $html.Replace("</style>", "$css</style>"), $utf8)
    Start-Process $e -ArgumentList "--headless=new", "--disable-gpu", "--hide-scrollbars", "--user-data-dir=$env:TEMP\edgeshot",
        "--virtual-time-budget=6000", "--window-size=$w,$h", "--screenshot=$o\$name$i.png", $url -Wait -RedirectStandardError "$o\err.txt"
}
$probe = '<script>setTimeout(function(){document.body.setAttribute("data-w", innerWidth + "/" + document.documentElement.scrollWidth + "/" + document.documentElement.scrollHeight)}, 500)</script></body>'
[IO.File]::WriteAllText("$d\_shot.html", $html.Replace("</body>", $probe), $utf8)
$dom = & $e --headless=new --disable-gpu "--user-data-dir=$env:TEMP\edgeshot" --virtual-time-budget=3000 "--window-size=$w,900" --dump-dom $url 2>$null | Out-String
if ($dom -match 'data-w="([0-9/]+)"') { "window/page width/height: $($Matches[1])" }
Remove-Item "$d\_shot.html"
