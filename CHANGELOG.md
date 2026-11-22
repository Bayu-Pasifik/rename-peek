# Changelog

## 1.1.0 - 2026-11-22

- Ikon aplikasi kustom (dua halaman bertumpuk dan kotak nama dengan kursor), dibuat oleh tools/make_icon.ps1.
- Installer Windows (Inno Setup): instal per-pengguna tanpa admin, shortcut Start Menu, opsi shortcut Desktop, runtime Visual C++ ikut dibundel, uninstaller bersih. Bangun dengan installer/build_installer.ps1.

## 1.0.0 - 2026-11-22

Rilis pertama.

- Pemindaian satu folder, pengelompokan file duplikat (`nama`, `nama (n)`).
- Preview PDF (pdfrx), gambar, teks, dan Office (konversi lewat Word/Excel/PowerPoint, dengan cache, antrean, dan pembatalan antrean basi).
- Rename aman dengan sanitasi nama Windows, nama unik, dan batas path.
- Undo berlapis yang tersimpan di disk.
- UI tiga area dengan daftar yang bisa diubah lebarnya, pintasan keyboard, drag and drop folder, tema terang/gelap, dialog pengaturan.
- Logger ke berkas, kontras warna memenuhi WCAG AA (diuji).
- 102 tes otomatis (domain, data, Office asli, state, widget).

Belum ada: ikon aplikasi kustom, installer/MSIX, rename massal berbasis pola, saran nama otomatis dari isi dokumen.
