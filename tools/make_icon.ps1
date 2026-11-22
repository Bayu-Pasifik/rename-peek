# Membuat ikon aplikasi (PNG 512 + ICO multi-ukuran) tanpa dependensi eksternal.
# Pakai: powershell -ExecutionPolicy Bypass -File tools\make_icon.ps1
# Konsep: dua halaman bertumpuk (file duplikat) dan kotak nama dengan kursor ketik (rename).
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$icoPath = Join-Path $root 'windows\runner\resources\app_icon.ico'
$pngDir = Join-Path $root 'assets\icon'
New-Item -ItemType Directory -Force $pngDir | Out-Null

function C([string]$hex, [int]$a = 255) {
  [System.Drawing.Color]::FromArgb($a, [Convert]::ToInt32($hex.Substring(0, 2), 16),
    [Convert]::ToInt32($hex.Substring(2, 2), 16), [Convert]::ToInt32($hex.Substring(4, 2), 16))
}

function RoundRect([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

function Render([int]$s) {
  $bmp = New-Object System.Drawing.Bitmap $s, $s, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.PixelOffsetMode = 'HighQuality'
  $g.Clear([System.Drawing.Color]::Transparent)
  function U([double]$v) { [single]($v * $s) }

  # Latar: kotak membulat dengan gradasi biru
  $bg = RoundRect 0 0 $s $s (U 0.22)
  $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush (
    (New-Object System.Drawing.PointF 0, 0), (New-Object System.Drawing.PointF 0, $s), (C '4A78F5'), (C '1E46B5'))
  $g.FillPath($grad, $bg)

  # Halaman belakang (duplikat)
  $back = RoundRect (U 0.30) (U 0.15) (U 0.44) (U 0.54) (U 0.045)
  $g.FillPath((New-Object System.Drawing.SolidBrush (C 'B4CBFF')), $back)

  # Halaman depan dengan sudut terlipat
  $front = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pts = @(
    (New-Object System.Drawing.PointF (U 0.22), (U 0.25)),
    (New-Object System.Drawing.PointF (U 0.54), (U 0.25)),
    (New-Object System.Drawing.PointF (U 0.67), (U 0.38)),
    (New-Object System.Drawing.PointF (U 0.67), (U 0.80)),
    (New-Object System.Drawing.PointF (U 0.22), (U 0.80)))
  $front.AddPolygon($pts)
  $shadow = New-Object System.Drawing.SolidBrush (C '0B1F5C' 70)
  $g.TranslateTransform((U 0.012), (U 0.016))
  $g.FillPath($shadow, $front)
  $g.ResetTransform()
  $g.FillPath((New-Object System.Drawing.SolidBrush (C 'FFFFFF')), $front)
  $fold = New-Object System.Drawing.Drawing2D.GraphicsPath
  $fold.AddPolygon(@(
      (New-Object System.Drawing.PointF (U 0.54), (U 0.25)),
      (New-Object System.Drawing.PointF (U 0.67), (U 0.38)),
      (New-Object System.Drawing.PointF (U 0.54), (U 0.38))))
  $g.FillPath((New-Object System.Drawing.SolidBrush (C 'CFDDFF')), $fold)

  if ($s -ge 48) {
    # Dua baris teks
    $line = New-Object System.Drawing.SolidBrush (C 'C3CFEA')
    $g.FillPath($line, (RoundRect (U 0.28) (U 0.42) (U 0.20) (U 0.03) (U 0.015)))
    $g.FillPath($line, (RoundRect (U 0.28) (U 0.48) (U 0.30) (U 0.03) (U 0.015)))
  }

  # Kotak nama + kursor ketik
  $field = RoundRect (U 0.28) (U 0.57) (U 0.33) (U 0.13) (U 0.03)
  $g.FillPath((New-Object System.Drawing.SolidBrush (C 'EAF0FF')), $field)
  $pen = New-Object System.Drawing.Pen (C '2A5BD7'), ([Math]::Max(1.0, (U 0.016)))
  $g.DrawPath($pen, $field)
  $caret = New-Object System.Drawing.SolidBrush (C '2A5BD7')
  $g.FillRectangle($caret, (U 0.335), (U 0.595), (U 0.024), (U 0.055))
  if ($s -ge 32) {
    $g.FillPath($caret, (RoundRect (U 0.39) (U 0.62) (U 0.14) (U 0.025) (U 0.012)))
  }

  $g.Dispose()
  return $bmp
}

function PngBytes($bmp) {
  $ms = New-Object System.IO.MemoryStream
  $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
  return , $ms.ToArray()
}

# PNG 512 untuk README/installer
$big = Render 512
$big.Save((Join-Path $pngDir 'app_icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$big.Dispose()

# ICO dengan entri PNG (didukung Windows Vista+)
$sizes = 16, 24, 32, 48, 64, 128, 256
$images = foreach ($sz in $sizes) { $b = Render $sz; , (PngBytes $b); $b.Dispose() }
$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ms
$bw.Write([uint16]0); $bw.Write([uint16]1); $bw.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
  $sz = $sizes[$i]; $data = $images[$i]
  $dim = if ($sz -ge 256) { 0 } else { $sz }
  $bw.Write([byte]$dim); $bw.Write([byte]$dim); $bw.Write([byte]0); $bw.Write([byte]0)
  $bw.Write([uint16]1); $bw.Write([uint16]32)
  $bw.Write([uint32]$data.Length); $bw.Write([uint32]$offset)
  $offset += $data.Length
}
foreach ($data in $images) { $bw.Write($data) }
$bw.Flush()
[System.IO.File]::WriteAllBytes($icoPath, $ms.ToArray())
"ICO: $icoPath ($((Get-Item $icoPath).Length) bytes), ukuran: $($sizes -join ', ')"
