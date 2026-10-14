@echo off
setlocal EnableExtensions
title Mixed Dark World 0.3.1 - Insan Karakter Kurulumu

set "MDW_ROOT=E:\Mixed Dark World\Mixed Dark World Projesi"
set "MDW_SOURCE=https://raw.githubusercontent.com/lkbilisim/MixedDarkWorld/feature/mdw-0-3-1-character/"

echo.
echo === MIXED DARK WORLD 0.3.1 - INSAN KARAKTER TESTI ===
echo.
if not exist "%MDW_ROOT%\project.godot" (
  echo [HATA] Godot projesi bulunamadi:
  echo "%MDW_ROOT%"
  pause
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop'; ^
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
  $root = $env:MDW_ROOT; ^
  $base = $env:MDW_SOURCE; ^
  $files = @('scripts/character/mdw_player.gd','scripts/character/mdw_character_test.gd','scenes/MDW_Character_Test.tscn'); ^
  $staging = Join-Path $env:TEMP ('MDW_031_' + [guid]::NewGuid().ToString('N')); ^
  $backup = Join-Path 'E:\Mixed Dark World\##SystemDriver\MDW_Yedekler' ('Insan_0_3_1_' + (Get-Date -Format 'yyyyMMdd_HHmmss')); ^
  $done = @(); $existed = @{}; ^
  try { ^
    New-Item -ItemType Directory -Path $staging -Force | Out-Null; ^
    foreach ($rel in $files) { ^
      $tempFile = Join-Path $staging ($rel.Replace('/','\')); ^
      New-Item -ItemType Directory -Path (Split-Path $tempFile -Parent) -Force | Out-Null; ^
      Invoke-WebRequest -Uri ($base + $rel) -OutFile $tempFile -UseBasicParsing; ^
      if ((Get-Item -LiteralPath $tempFile).Length -lt 80) { throw ('Indirilen dosya bos veya gecersiz: ' + $rel) }; ^
      $head = Get-Content -LiteralPath $tempFile -TotalCount 1; ^
      if ($rel.EndsWith('.gd') -and $head -notmatch '^extends ') { throw ('GDScript basligi gecersiz: ' + $rel) }; ^
      if ($rel.EndsWith('.tscn') -and $head -notmatch '^\[gd_scene') { throw ('Sahne basligi gecersiz: ' + $rel) }; ^
    }; ^
    New-Item -ItemType Directory -Path $backup -Force | Out-Null; ^
    foreach ($rel in $files) { ^
      $relativeWin = $rel.Replace('/','\'); ^
      $dest = Join-Path $root $relativeWin; ^
      $save = Join-Path $backup $relativeWin; ^
      $existed[$rel] = Test-Path -LiteralPath $dest; ^
      if ($existed[$rel]) { ^
        New-Item -ItemType Directory -Path (Split-Path $save -Parent) -Force | Out-Null; ^
        Copy-Item -LiteralPath $dest -Destination $save -Force; ^
      }; ^
      New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null; ^
      $done += $rel; ^
      Copy-Item -LiteralPath (Join-Path $staging $relativeWin) -Destination $dest -Force; ^
      Write-Host ('[KURULDU] ' + $rel); ^
    }; ^
    $available = @('Diesel.glb','EMA.glb','fatt tony.glb') | Where-Object { ^
      (Test-Path -LiteralPath (Join-Path $root ('Depo\KarakterModel\' + $_))) -or ^
      (Test-Path -LiteralPath (Join-Path $root $_)) ^
    }; ^
    if ($available.Count -eq 0) { ^
      Write-Warning 'Karakter modelleri proje icinde bulunamadi. GLB dosyalarini Depo\KarakterModel klasorune koymalisin.' ^
    } else { Write-Host ('[MODELLER] ' + ($available -join ', ')) }; ^
    @('Mixed Dark World 0.3.1 kurulum tamamlandi.','Sahne: res://scenes/MDW_Character_Test.tscn',('Tarih: ' + (Get-Date)),('Yedek: ' + $backup)) | Set-Content -LiteralPath (Join-Path $backup 'Kurulum_Ozeti.txt') -Encoding UTF8; ^
    Write-Host '[BASARILI] Ana oyun dosyalarina dokunulmadi.' -ForegroundColor Green; ^
  } catch { ^
    Write-Host ('[HATA] ' + $_.Exception.Message) -ForegroundColor Red; ^
    [array]::Reverse($done); ^
    foreach ($rel in $done) { ^
      $win = $rel.Replace('/','\'); $dest = Join-Path $root $win; ^
      if ($existed[$rel]) { Copy-Item -LiteralPath (Join-Path $backup $win) -Destination $dest -Force -ErrorAction SilentlyContinue } ^
      else { Remove-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue }; ^
    }; ^
    exit 1; ^
  } finally { Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue }"

if errorlevel 1 (
  echo.
  echo Kurulum basarisiz. Eski dosyalar korundu / geri alinmaya calisildi.
  pause
  exit /b 1
)

echo.
echo Godot'ta scenes/MDW_Character_Test.tscn dosyasini acip F6'ya bas.
set "MDW_GODOT=E:\Mixed Dark World\Godot_v4.7.2-stable_win64.exe"
if exist "%MDW_GODOT%" (
  echo Godot editoru aciliyor...
  start "" "%MDW_GODOT%" --path "%MDW_ROOT%" --editor
)
pause
exit /b 0
