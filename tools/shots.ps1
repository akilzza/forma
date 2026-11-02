# Снимки сайта через Edge без окна: компьютер, «телефон» (500 px — уже Edge не даёт),
# проверка горизонтальной прокрутки.
# Запуск: powershell -File tools\shots.ps1  (из папки сайта)
$d = Split-Path $PSScriptRoot
$e = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$o = "$d\_shots"
$prof = "$env:TEMP\edgeshot"
New-Item -ItemType Directory -Force $o | Out-Null
$html = Get-Content "$d\index.html" -Raw -Encoding UTF8
$utf8 = [Text.UTF8Encoding]::new($false)
$url = "file:///" + ($d -replace '\\', '/') + "/_shot.html"

function Shot($name, $w, $h, $heroH) {
    $t = $html.Replace("</style>", ".hero{min-height:${heroH}px!important}</style>")
    [IO.File]::WriteAllText("$d\_shot.html", $t, $utf8)
    Start-Process $e -ArgumentList "--headless=new", "--disable-gpu", "--hide-scrollbars", "--user-data-dir=$prof",
        "--virtual-time-budget=8000", "--window-size=$w,$h", "--screenshot=$o\$name.png", $url -Wait -RedirectStandardError "$o\err.txt"
}
Shot "desk" 1440 7600 900
Shot "mob" 500 10600 800

# ширина окна и ширина страницы: если вторая больше — страница уезжает вбок
$probe = '<script>setTimeout(function(){document.body.setAttribute("data-w", innerWidth + "/" + document.documentElement.scrollWidth)}, 500)</script></body>'
[IO.File]::WriteAllText("$d\_shot.html", $html.Replace("</body>", $probe), $utf8)
foreach ($w in 500, 800, 1440) {
    $dom = & $e --headless=new --disable-gpu "--user-data-dir=$prof" --virtual-time-budget=3000 "--window-size=$w,900" --dump-dom $url 2>$null | Out-String
    if ($dom -match 'data-w="([0-9/]+)"') { "window $w -> $($Matches[1])" }
}
Remove-Item "$d\_shot.html"
Get-ChildItem $o *.png | Select-Object Name, Length
