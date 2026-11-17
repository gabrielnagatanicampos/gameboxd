# Baixa as capas dos jogos para assets/covers/<id>.jpg
# Uso (na raiz do projeto):  powershell -ExecutionPolicy Bypass -File tools\baixar_capas.ps1
# Fontes, nesta ordem: Steam (library_600x900) ou Wikipedia (imagem da infobox), depois Steam (header).
# Jogos que falharem ficam sem arquivo e o app mostra o placeholder.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = 'Continue'
$destino = Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\covers'
New-Item -ItemType Directory -Force -Path $destino | Out-Null
$ua = 'GameBoxdSchoolProject/1.0 (trabalho academico)'

# id, appid da Steam (0 = nao tem), titulo na Wikipedia, preferir Wikipedia?
$jogos = @(
  @{ id='cx33';        steam=1903340; wiki='Clair Obscur: Expedition 33';               wikiPrimeiro=$false },
  @{ id='astro';       steam=0;       wiki='Astro Bot';                                 wikiPrimeiro=$true  },
  @{ id='bg3';         steam=1086940; wiki="Baldur's Gate 3";                           wikiPrimeiro=$false },
  @{ id='elden';       steam=1245620; wiki='Elden Ring';                                wikiPrimeiro=$false },
  @{ id='ittakestwo';  steam=1426210; wiki='It Takes Two (video game)';                 wikiPrimeiro=$false },
  @{ id='tlou2';       steam=2531310;      wiki='The Last of Us Part II';                    wikiPrimeiro=$true  },
  @{ id='sekiro';      steam=814380;  wiki='Sekiro: Shadows Die Twice';                 wikiPrimeiro=$false },
  @{ id='gow';         steam=1593500; wiki='God of War (2018 video game)';              wikiPrimeiro=$false },
  @{ id='botw';        steam=0;       wiki='The Legend of Zelda: Breath of the Wild';   wikiPrimeiro=$true  },
  @{ id='ow';          steam=2357570;      wiki='Overwatch (video game)';                    wikiPrimeiro=$true  },
  @{ id='w3';          steam=292030;  wiki='The Witcher 3: Wild Hunt';                  wikiPrimeiro=$false },
  @{ id='dai';         steam=0;       wiki='Dragon Age: Inquisition';                   wikiPrimeiro=$true  },
  @{ id='hollow';      steam=367520;  wiki='Hollow Knight';                             wikiPrimeiro=$false },
  @{ id='celeste';     steam=504230;  wiki='Celeste (video game)';                      wikiPrimeiro=$false },
  @{ id='hades';       steam=1145360; wiki='Hades (video game)';                        wikiPrimeiro=$false },
  @{ id='stardew';     steam=413150;  wiki='Stardew Valley';                            wikiPrimeiro=$false },
  @{ id='portal2';     steam=620;     wiki='Portal 2';                                  wikiPrimeiro=$false },
  @{ id='undertale';   steam=391540;  wiki='Undertale';                                 wikiPrimeiro=$false },
  @{ id='disco';       steam=632470;  wiki='Disco Elysium';                             wikiPrimeiro=$false },
  @{ id='rdr2'; steam=1174180; wiki='Red Dead Redemption 2'; wikiPrimeiro=$false },
  @{ id='rdr1'; steam=2668510; wiki='Red Dead Redemption'; wikiPrimeiro=$false },
  @{ id='gta5'; steam=271590; wiki='Grand Theft Auto V'; wikiPrimeiro=$false },
  @{ id='cyberpunk'; steam=1091500; wiki='Cyberpunk 2077'; wikiPrimeiro=$false },
  @{ id='re4'; steam=2050650; wiki='Resident Evil 4 (2023 video game)'; wikiPrimeiro=$false },
  @{ id='silenthill2'; steam=2124490; wiki='Silent Hill 2 (2024 video game)'; wikiPrimeiro=$false },
  @{ id='doometernal'; steam=782330; wiki='Doom Eternal'; wikiPrimeiro=$false },
  @{ id='p5r'; steam=1687950; wiki='Persona 5 Royal'; wikiPrimeiro=$false },
  @{ id='deathstranding'; steam=1190460; wiki='Death Stranding'; wikiPrimeiro=$false },
  @{ id='outerwilds'; steam=753640; wiki='Outer Wilds'; wikiPrimeiro=$false },
  @{ id='gta6'; steam=0; wiki='Grand Theft Auto VI'; wikiPrimeiro=$true }
)

function Salvar-Se-Imagem($url, $arquivo) {
  try {
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -UserAgent $ua -TimeoutSec 30
    $b = $r.Content
    if ($b.Length -lt 5000) { return $false }
    $jpeg = ($b[0] -eq 0xFF -and $b[1] -eq 0xD8)
    $png  = ($b[0] -eq 0x89 -and $b[1] -eq 0x50)
    if (-not ($jpeg -or $png)) { return $false }
    [IO.File]::WriteAllBytes($arquivo, $b)
    return $true
  } catch { return $false }
}

function Url-Wikipedia($titulo) {
  try {
    $q = [uri]::EscapeDataString(($titulo -replace ' ', '_'))
    $u = "https://en.wikipedia.org/api/rest_v1/page/summary/$q"
    $j = Invoke-RestMethod -Uri $u -UserAgent $ua -TimeoutSec 30
    return $j.thumbnail.source
  } catch { return $null }
}

$falhas = @()
foreach ($g in $jogos) {
  $arq = Join-Path $destino "$($g.id).jpg"
  if ((Test-Path $arq) -and (Get-Item $arq).Length -gt 5000) { Write-Host "ok (ja existe)  $($g.id)"; continue }
  $fontes = @()
  $steamRetrato = if ($g.steam) { "https://cdn.akamai.steamstatic.com/steam/apps/$($g.steam)/library_600x900.jpg" }
  $steamHeader  = if ($g.steam) { "https://cdn.akamai.steamstatic.com/steam/apps/$($g.steam)/header.jpg" }
  $wiki = { Url-Wikipedia $g.wiki }
  $feito = $false
  $ordem = if ($g.wikiPrimeiro) { 'wiki','steam','header' } else { 'steam','wiki','header' }
  foreach ($f in $ordem) {
    $url = switch ($f) { 'steam' { $steamRetrato } 'wiki' { & $wiki } 'header' { $steamHeader } }
    if ($url -and (Salvar-Se-Imagem $url $arq)) { Write-Host "ok ($f)  $($g.id)"; $feito = $true; break }
  }
  if (-not $feito) { Write-Host "FALHOU  $($g.id)"; $falhas += $g.id }
}
if ($falhas.Count) { Write-Host "`nSem capa (vao usar placeholder): $($falhas -join ', ')" } else { Write-Host "`nTodas as capas baixadas." }
