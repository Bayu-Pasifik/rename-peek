# Membangun installer Rename Peek: flutter build -> staging -> Inno Setup.
# Pakai: powershell -ExecutionPolicy Bypass -File installer\build_installer.ps1 [-SkipBuild]
param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$version = ((Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9.]+)').Matches[0].Groups[1].Value)
Write-Host "Versi: $version"

$iscc = @(
  "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { throw 'Inno Setup 6 tidak ditemukan. Pasang: winget install JRSoftware.InnoSetup' }

if (-not $SkipBuild) {
  flutter build windows --release
  if ($LASTEXITCODE -ne 0) { throw 'flutter build gagal' }
}
$release = Join-Path $root 'build\windows\x64\runner\Release'
if (-not (Test-Path "$release\rename_peek.exe")) { throw "Build rilis tidak ditemukan di $release" }

# Staging: salin rilis + runtime Visual C++ (app-local) agar jalan di PC bersih.
$stage = Join-Path $root 'build\installer_stage'
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
Copy-Item $release $stage -Recurse
foreach ($dll in 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll') {
  $src = Join-Path $env:SystemRoot "System32\$dll"
  if (Test-Path $src) { Copy-Item $src $stage -Force } else { Write-Warning "$dll tidak ditemukan di System32" }
}

& $iscc "/DAppVersion=$version" (Join-Path $root 'installer\rename_peek.iss')
if ($LASTEXITCODE -ne 0) { throw 'ISCC gagal' }

$out = Join-Path $root "build\installer\RenamePeek-Setup-$version.exe"
$mb = [math]::Round((Get-Item $out).Length / 1MB, 1)
Write-Host "Installer: $out ($mb MB)"
