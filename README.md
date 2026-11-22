# Rename Peek

Aplikasi desktop Windows (Flutter) untuk mengganti nama file hasil unduhan yang bernama sama: `dokumen.pdf`, `dokumen (1).pdf`, `dokumen (2).pdf`, dan seterusnya.

Alurnya: pilih folder, aplikasi mengelompokkan file duplikat dan menampilkan preview besar satu per satu, kamu ketik nama baru lalu Enter, dan aplikasi lanjut ke file berikutnya. Tidak perlu membuka tiap file di aplikasi lain.

## Fitur

- Pengelompokan otomatis file bernama sama (`nama`, `nama (1)`, `nama (2)`, urut numerik).
- Preview: PDF, gambar, teks, serta Word/Excel/PowerPoint (dikonversi ke PDF lewat Microsoft Office yang terpasang).
- Rename aman: karakter ilegal dibuang, nama bentrok diberi suffix, tidak pernah menimpa file, tidak ada operasi hapus.
- Undo berlapis yang tetap berfungsi setelah aplikasi ditutup.
- Seret folder ke jendela untuk membukanya. Folder terakhir diingat.
- Tema terang/gelap mengikuti sistem.

## Pemakaian

1. Jalankan `rename_peek.exe`.
2. Klik kolom folder (atau Ctrl+O) dan pilih folder unduhan, atau seret folder ke jendela.
3. Ketik nama baru di kotak, tekan Enter. Ekstensi dipertahankan otomatis.

| Aksi | Pintasan |
|---|---|
| Simpan & lanjut | Enter |
| Lewati / kembali | Alt+↓ / Alt+↑ |
| Undo rename | Ctrl+Z (di luar kotak nama) atau tombol Undo |
| Muat ulang | F5 |
| Pilih folder | Ctrl+O |
| Buka file asli | Ctrl+Enter |
| Fokus ke kotak nama | Ctrl+L atau Esc |

## Persyaratan

- Windows 10/11 64-bit.
- Preview Word/Excel/PowerPoint butuh Microsoft Office terpasang. Tanpa Office, file itu tampil sebagai kartu info dengan tombol "Buka asli"; PDF, gambar, dan teks tetap normal.
- Jika aplikasi gagal start di PC yang sangat bersih, pasang Microsoft Visual C++ Redistributable 2015-2022 (x64).

## Menjalankan dari rilis

Salin seluruh folder `build\windows\x64\runner\Release` (bukan hanya `.exe`) ke PC mana pun, lalu jalankan `rename_peek.exe`.

## Pengembangan

```
flutter pub get
flutter analyze
flutter test
flutter run -d windows
flutter build windows --release
```

Windows Developer Mode harus aktif (Flutter butuh symlink untuk plugin). Uji konversi Office memakai Word/Excel/PowerPoint asli dan otomatis dilewati bila tidak terpasang.

Berkas log: `%APPDATA%\com.renamepeek\rename_peek\rename-peek.log` (lokasinya juga tampil di dialog Pengaturan).

## Dokumen

- [PRD.md](PRD.md): kebutuhan produk
- [STYLE.md](STYLE.md): panduan desain dan kode
- [TASK.md](TASK.md): rencana kerja dan status
