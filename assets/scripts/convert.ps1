param([string]$Src, [string]$Dst)
# Konversi dokumen Office ke PDF memakai Word/Excel/PowerPoint yang terinstall (read-only, file asli tidak diubah)
$ErrorActionPreference = 'Stop'
$ext = [System.IO.Path]::GetExtension($Src).ToLower()
$tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [guid]::NewGuid().ToString() + $ext)
Copy-Item -LiteralPath $Src -Destination $tmp   # kerja di salinan, hindari lock & perubahan file asli
try {
  if ($ext -in '.doc', '.docx', '.rtf', '.odt') {
    $app = New-Object -ComObject Word.Application
    $app.Visible = $false; $app.DisplayAlerts = 0
    try {
      $d = $app.Documents.Open($tmp, $false, $true)
      $d.ExportAsFixedFormat($Dst, 17)
      $d.Close($false)
    } finally { $app.Quit() }
  }
  elseif ($ext -in '.xls', '.xlsx', '.xlsm', '.ods') {
    $app = New-Object -ComObject Excel.Application
    $app.Visible = $false; $app.DisplayAlerts = $false
    try {
      $wb = $app.Workbooks.Open($tmp, 0, $true)
      foreach ($ws in $wb.Worksheets) {
        try { $ws.PageSetup.Zoom = $false; $ws.PageSetup.FitToPagesWide = 1; $ws.PageSetup.FitToPagesTall = $false } catch {}
      }
      $wb.ExportAsFixedFormat(0, $Dst)
      $wb.Close($false)
    } finally { $app.Quit() }
  }
  elseif ($ext -in '.ppt', '.pptx', '.odp') {
    $app = New-Object -ComObject PowerPoint.Application
    try {
      $p = $app.Presentations.Open($tmp, $true, $false, $false)
      $p.SaveAs($Dst, 32)
      $p.Close()
    } finally { $app.Quit() }
  }
  else { throw "Tipe tidak didukung: $ext" }
}
finally { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
