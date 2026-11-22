# PRD — Rename Peek (Flutter Windows Desktop)

Status: Draft 1 · Tanggal: 2026-11-22 · Platform target: Windows 10/11 (Flutter desktop)

## 1. Latar belakang

Saat mengunduh banyak dokumen dari sumber yang sama, browser memberi nama yang sama dengan suffix angka: `dokumen.pdf`, `dokumen (1).pdf`, `dokumen (2).pdf`, dan seterusnya. Pengguna harus membuka file satu per satu hanya untuk tahu isinya lalu mengganti namanya secara manual. Preview bawaan File Explorer tidak cukup besar/jelas dan tidak mendukung semua tipe file.

Sudah ada prototipe berbasis Node.js + browser (`D:\Coding\windows\rename-peek`) yang membuktikan alurnya. Versi Flutter ini menggantikannya menjadi aplikasi desktop mandiri (satu `.exe`), tanpa perlu Node.js, dan dengan preview PDF yang tidak bergantung pada browser.

## 2. Tujuan

1. Pengguna bisa melihat isi tiap file duplikat dalam satu layar tanpa membuka aplikasi lain, lalu mengetik nama baru dan lanjut ke file berikutnya.
2. Waktu per file turun menjadi: lihat preview, ketik nama, Enter (target kurang dari 10 detik per file dibanding membuka aplikasi satu per satu).
3. Aman: tidak ada file yang hilang atau tertimpa, semua rename bisa di-undo.

### Bukan tujuan (v1)

- Rename otomatis berbasis isi/AI/OCR (kandidat v2).
- Mode pemantau folder otomatis (watcher) (kandidat v2).
- Platform selain Windows (macOS/Linux/mobile).
- Mengedit isi dokumen, memindahkan file antar folder, atau mengunggah ke cloud.
- Rename massal berbasis pola (find/replace), di luar kebutuhan alur peek.

## 3. Pengguna & skenario

Pengguna tunggal: individu yang sering mengunduh banyak dokumen (PDF, Word, Excel, gambar) ke folder Downloads dan perlu menamainya sesuai isi.

Skenario utama:
1. Buka aplikasi, pilih folder Downloads (atau seret folder ke jendela).
2. Aplikasi mengelompokkan file bernama sama (`dokumen`, `dokumen (1)`, `dokumen (2)`).
3. File pertama otomatis tampil di panel preview. Pengguna membaca, mengetik nama baru, menekan Enter.
4. File di-rename, daftar diperbarui, file berikutnya tampil. Ulangi sampai selesai.
5. Salah ketik, tekan Ctrl+Z untuk mengembalikan nama sebelumnya.

## 4. Kebutuhan fungsional

### F1. Pemilihan folder
- Tombol "Pilih folder" memakai dialog folder native Windows.
- Folder bisa diseret ke jendela (drag & drop).
- Folder terakhir diingat dan dimuat otomatis saat aplikasi dibuka; bila folder sudah tidak ada, tampilkan empty state dan minta pilih ulang.
- Tombol "Muat ulang" (F5) untuk memindai ulang folder.

### F2. Deteksi & pengelompokan duplikat
- Hanya file langsung di folder (non-rekursif) pada v1.
- Nama dasar = nama file tanpa ekstensi dan tanpa suffix ` (n)` di akhir, dibandingkan tanpa membedakan huruf besar/kecil.
- Satu grup = semua file dengan nama dasar sama. Urut dalam grup: tanpa angka dulu, lalu angka naik.
- Default hanya menampilkan grup dengan 2 file atau lebih. Ada toggle "Tampilkan semua file".
- Abaikan file sementara Office (`~$*`), file tersembunyi, dan file sistem.
- Kasus tepi: `dokumen (1).pdf` tanpa `dokumen.pdf` tetap dianggap satu grup (jumlah 1, hanya tampil bila toggle semua aktif).

### F3. Preview
| Tipe | Cara preview |
|---|---|
| PDF | Render langsung memakai PDFium (paket `pdfrx`), scroll semua halaman, zoom, fit-width default |
| Gambar (png, jpg, jpeg, gif, webp, bmp) | `Image.file` dengan `InteractiveViewer` (zoom/pan) |
| Teks (txt, csv, json, md) | Teks monospace, dibatasi 200 KB pertama |
| Word/Excel/PowerPoint (doc, docx, rtf, odt, xls, xlsx, xlsm, ods, ppt, pptx, odp) | Dikonversi ke PDF di salinan sementara lewat Word/Excel/PowerPoint yang terpasang (PowerShell COM), hasil di-cache, lalu ditampilkan seperti PDF |
| Lainnya | Kartu info: ikon, nama, ukuran, tanggal ubah, tombol "Buka asli" |

Aturan tambahan:
- Konversi Office berjalan antrean satu per satu, di background, tidak memblokir UI. Selama menunggu tampil indikator "Menyiapkan preview".
- File berikutnya dalam daftar di-prefetch (dikonversi lebih dulu) agar terasa instan.
- Cache konversi disimpan di folder temp dengan kunci hash(path + mtime + size), dibersihkan otomatis jika lebih dari 500 MB atau lebih dari 7 hari.
- File asli tidak pernah diubah atau dikunci saat konversi (konversi dikerjakan pada salinan, dibuka read-only).
- Jika Office tidak terpasang atau konversi gagal (timeout 120 detik), tampil pesan jelas + fallback kartu info + tombol "Buka asli".
- Tombol "Buka asli" membuka file dengan aplikasi default Windows.

### F4. Rename
- Kolom input nama baru di atas preview, ekstensi asli tampil sebagai sufiks yang tidak bisa diubah.
- Enter = simpan lalu pindah ke file berikutnya. Jika input kosong, tampilkan pesan, jangan rename.
- Karakter ilegal Windows `< > : " / \ | ? *` dan karakter kontrol dibuang otomatis; spasi ganda dirapikan; titik/spasi di akhir dibuang.
- Jika pengguna mengetik ekstensi yang sama dengan ekstensi asli, tidak digandakan.
- Nama bentrok dengan file lain: otomatis ditambah ` (1)`, ` (2)`, dan seterusnya, dan pengguna diberi tahu nama akhirnya. Tidak pernah menimpa file.
- Nama reserved Windows (CON, PRN, AUX, NUL, COM1-9, LPT1-9) ditolak dengan pesan.
- Panjang path akhir dibatasi 259 karakter; jika lebih, tampil error.
- Saran nama (opsional, v1.1): chip "gunakan teks pertama dokumen" untuk PDF/DOCX; ketik cepat dengan satu klik.

### F5. Navigasi & kontrol
- Daftar file di sisi kiri, dikelompokkan, item aktif disorot.
- Lewati (Alt+↓), kembali (Alt+↑), klik item untuk lompat.
- Setelah rename, fokus otomatis kembali ke kolom input nama.
- Penunjuk progres: "12 dari 40 file".

### F6. Undo
- Setiap rename dicatat (path folder, nama lama, nama baru, waktu) di file JSON di folder data aplikasi.
- Ctrl+Z / tombol Undo membatalkan rename terakhir (berlapis, bisa berulang), bahkan setelah aplikasi ditutup dan dibuka lagi.
- Undo ditolak dengan pesan jelas bila file hasil rename sudah tidak ada atau nama lama sudah dipakai file lain.

### F7. Pengaturan (minimal)
- Tema: ikuti sistem / terang / gelap.
- Toggle default "Tampilkan semua file".
- Tombol "Bersihkan cache preview".

## 5. Kebutuhan non-fungsional

- Performa: daftar 2.000 file dimuat kurang dari 1 detik; PDF 20 halaman tampil halaman pertama kurang dari 1 detik; pindah antar file PDF/gambar kurang dari 300 ms.
- Keamanan data: tidak ada operasi hapus; rename hanya di dalam folder yang dipilih; nama file input tidak boleh berisi path separator.
- Privasi: semua pemrosesan lokal, tidak ada jaringan, tidak ada telemetri.
- Keandalan: error I/O (file terkunci, akses ditolak, file hilang saat rename) ditangani dengan pesan, tidak menutup aplikasi.
- Aksesibilitas: seluruh alur bisa dengan keyboard, kontras teks minimal WCAG AA, label semantik pada tombol ikon.
- Distribusi: build `flutter build windows` menghasilkan folder rilis yang bisa dijalankan tanpa instalasi tambahan; opsional MSIX/installer di fase akhir.
- Bahasa UI: Bahasa Indonesia (string dipusatkan agar mudah ditambah bahasa lain).

## 6. Arsitektur singkat

- Flutter desktop (Windows), Dart 3.x, Material 3.
- State management: Riverpod.
- Lapisan:
  - `domain`: model `DocFile`, `DupGroup`, `RenameLogEntry`; fungsi murni (parsing nama, sanitasi nama, pengelompokan) yang mudah diuji.
  - `data`: `FolderScanner` (dart:io), `RenameService`, `UndoLog` (JSON), `OfficeConverter` (Process.run powershell + skrip `convert.ps1` disertakan sebagai asset lalu diekstrak ke temp), `SettingsStore` (shared_preferences).
  - `ui`: halaman utama, daftar, panel preview, bar rename, dialog pengaturan.
- Paket kandidat (versi terbaru diperiksa saat instalasi): `flutter_riverpod`, `pdfrx`, `file_picker`, `desktop_drop`, `window_manager`, `path`, `path_provider`, `shared_preferences`, `url_launcher` atau `Process.run('explorer')` untuk "Buka asli", `crypto` untuk hash cache.
- Lihat `STYLE.md` untuk desain dan `TASK.md` untuk urutan pekerjaan.

## 7. Risiko & mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Office (Word/Excel) tidak terpasang atau versi Store membatasi COM | Preview DOCX/XLSX gagal | Deteksi di awal, fallback kartu info + "Buka asli"; uji dini di Fase 4 |
| Konversi Office lambat | Pengguna menunggu | Cache + prefetch + antrean di background, indikator jelas |
| Word/Excel meninggalkan proses zombie | Memori bocor | `Quit()` di `finally`, timeout, bunuh proses saat aplikasi ditutup |
| File terkunci aplikasi lain saat rename | Rename gagal | Tampilkan pesan, tawarkan coba lagi |
| `pdfrx` gagal pada PDF tertentu (terenkripsi/rusak) | Preview kosong | Tangkap error, fallback kartu info + "Buka asli", dukung input password sebagai v2 |
| Excel dengan sheet sangat lebar terpotong di PDF | Preview kurang akurat | Atur FitToPagesWide=1 pada salinan; tombol "Buka asli" |
| Nama file berisi karakter Unicode/emoji | Rename gagal | Gunakan API Dart (UTF-16) dan uji kasus Unicode |

## 8. Kriteria penerimaan (v1 dianggap selesai bila)

1. Dengan folder `D:\Coding\windows\docs` (6 file `master_inhouse` + 1 `master_domestic`), aplikasi menampilkan satu grup `master_inhouse` berisi 6 file dan preview PDF tiap file.
2. Mengetik nama baru + Enter me-rename file, daftar terperbarui, fokus pindah ke file berikutnya, tanpa menyentuh mouse.
3. Rename ke nama yang sudah ada menghasilkan nama unik, tidak menimpa file lain.
4. Ctrl+Z mengembalikan nama lama; tetap berfungsi setelah aplikasi dibuka ulang.
5. File DOCX dan XLSX contoh tampil sebagai preview (di mesin dengan Office), atau fallback yang jelas bila tidak.
6. Tidak ada crash saat: folder kosong, folder tidak ada, file terkunci, PDF rusak, nama berisi karakter ilegal.
7. `flutter analyze` bersih dan semua unit test domain lulus; `flutter build windows --release` berhasil.

## 9. Pertanyaan terbuka

1. Apakah perlu pemindaian rekursif (subfolder) di v1 atau cukup folder tunggal?
2. Apakah nama akhir perlu pola otomatis (misal prefix tanggal), atau murni ketikan pengguna?
3. Apakah mesin target selalu punya Microsoft Office, atau perlu opsi LibreOffice sebagai alternatif konversi?
4. Perlu distribusi sebagai installer/MSIX, atau cukup folder rilis portabel?
