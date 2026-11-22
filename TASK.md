# TASK — Rename Peek (Flutter Windows Desktop)

Urutan kerja dari nol sampai rilis. Setiap fase punya hasil yang bisa diperiksa. Centang `[x]` saat selesai.
Rujukan: `PRD.md` (apa), `STYLE.md` (bagaimana tampilannya).

Prasyarat mesin: Flutter SDK (sudah ada di `D:\program\flutter`) dengan Windows desktop aktif, Visual Studio 2022 workload "Desktop development with C++", Microsoft Office untuk menguji preview Word/Excel.

---

## Fase 0 — Persiapan
- [x] Jalankan `flutter doctor -v`, pastikan toolchain Windows desktop hijau.
- [x] `flutter config --enable-windows-desktop` bila belum aktif.
- [x] Pertanyaan terbuka dijawab dengan default: folder tunggal (non-rekursif), nama murni ketikan pengguna, konversi lewat Microsoft Office, distribusi folder portabel.
- [x] Siapkan folder uji: salin `D:\Coding\windows\docs` + tambah contoh DOCX, XLSX, PPTX, gambar, TXT, PDF rusak, file dengan nama Unicode.

**Selesai bila:** `flutter doctor` tanpa error untuk Windows; folder uji siap.

## Fase 1 — Kerangka proyek
- [x] `flutter create --platforms=windows --org com.renamepeek rename_peek` di dalam `D:\Coding\windows\rename-peek-flutter\`.
- [x] Tambah dependensi (cek versi terbaru di pub.dev): `flutter_riverpod`, `pdfrx`, `file_picker`, `desktop_drop`, `window_manager`, `path`, `path_provider`, `shared_preferences`, `crypto`; dev: `flutter_lints`, `flutter_test`.
- [x] Susun struktur folder sesuai `STYLE.md` bagian 10.
- [x] Atur `analysis_options.yaml` (lint sesuai STYLE).
- [x] Atur jendela: ukuran awal 1280x800, minimum 960x600, judul "Rename Peek" lewat `window_manager`.
- [x] Ikon aplikasi kustom (tools/make_icon.ps1 menghasilkan PNG dan ICO 16-256 px). Nama eksekutabel: rename_peek.exe, judul jendela: Rename Peek.

**Selesai bila:** `flutter run -d windows` membuka jendela kosong berjudul benar; `flutter analyze` bersih.

## Fase 2 — Domain murni + tes (tanpa UI)
- [x] Model `DocFile` (path, name, base, ext, size, modified), `DupGroup`, `RenameLogEntry`.
- [x] `parseName(name)` menghasilkan kunci grup + nomor duplikat (regex ` (n)` di akhir nama dasar, case-insensitive).
- [x] `groupFiles(list)` mengurutkan grup dan isinya (tanpa angka dulu, angka naik).
- [x] `sanitizeName(input, ext)`: buang karakter ilegal, rapikan spasi, buang titik/spasi akhir, cegah ekstensi ganda, tolak nama reserved Windows dan panjang path > 259.
- [x] `uniqueName(existing, desired)` menambah ` (1)`, ` (2)` saat bentrok.
- [x] Unit test: nama biasa, banyak duplikat, `file (10).pdf` vs `file (2).pdf` (urut numerik, bukan alfabet), huruf besar/kecil, nama tanpa ekstensi, nama dengan kurung bukan suffix (`laporan (final) v2.pdf`), Unicode/emoji, nama reserved, ekstensi ganda `a.pdf.pdf`.

**Selesai bila:** `flutter test` lulus dengan cakupan semua kasus di atas.

## Fase 3 — Data layer
- [x] `FolderScanner`: baca folder non-rekursif, filter file `~$*`, tersembunyi, sistem; hasilkan `List<DocFile>`; tangani folder hilang/akses ditolak.
- [x] `RenameService`: validasi nama lewat domain, cek path berada di dalam folder terpilih, `File.rename`, kembalikan hasil bertipe (sukses dengan nama akhir / gagal dengan alasan).
- [x] `UndoLog`: simpan/baca JSON di `getApplicationSupportDirectory()`; push saat rename, pop saat undo; validasi (file hasil ada, nama lama bebas).
- [x] `SettingsStore` (shared_preferences): folder terakhir, tema, toggle "semua file".
- [x] Tes integrasi terhadap folder sementara: rename, bentrok, undo, undo ditolak saat nama lama terpakai, file terkunci.

**Selesai bila:** semua tes data layer lulus tanpa menyentuh folder asli pengguna.

## Fase 4 — Konverter Office (risiko tertinggi, kerjakan dini)
- [x] Salin logika `convert.ps1` dari prototipe (`D:\Coding\windows\rename-peek\convert.ps1`) ke `assets/scripts/convert.ps1`; ekstrak ke folder temp saat start.
- [x] `OfficeConverter.convertToPdf(path)`: salin file ke temp, jalankan PowerShell (`-NoProfile -NonInteractive -ExecutionPolicy Bypass`), timeout 120 detik, antrean serial, cache kunci hash(path+mtime+size).
- [x] Deteksi ketersediaan Office (cek ProgID Word/Excel/PowerPoint di registry atau coba instansiasi); hasilkan status "tidak tersedia" yang jelas.
- [x] Pastikan proses `WINWORD/EXCEL/POWERPNT` tidak menggantung (Quit di finally, bunuh saat timeout dan saat aplikasi ditutup).
- [x] Pembersihan cache otomatis (> 500 MB atau > 7 hari) dan manual.
- [x] Uji manual: DOCX, DOC, XLSX banyak sheet, XLSX sheet lebar, PPTX, file terproteksi password (harus gagal rapi), file sedang dibuka di Word.

**Selesai bila:** DOCX/XLSX/PPTX contoh menghasilkan PDF valid; kegagalan menghasilkan pesan, bukan hang atau crash; tidak ada proses Office tersisa di Task Manager.

## Fase 5 — State (Riverpod)
- [x] `folderProvider` (folder aktif + muat ulang), `filesProvider` (hasil scan), `showAllProvider`, `viewListProvider` (hasil filter + grup), `selectedIndexProvider`.
- [x] `previewProvider` per file (tipe, status loading/siap/error, path PDF hasil konversi).
- [x] `renameControllerProvider` (aksi simpan, lewati, kembali, undo; pesan status).
- [x] Setelah rename: daftar dimuat ulang, indeks menunjuk file berikutnya, fokus ke input.
- [x] Prefetch konversi untuk file berikutnya.
- [x] Tes unit untuk controller dengan service palsu (fake).

**Selesai bila:** alur simpan/lewati/undo benar di tes controller tanpa UI.

## Fase 6 — Tema & kerangka UI
- [x] Implementasi token warna, tipografi, radius sesuai `STYLE.md` bagian 3-4 (terang + gelap + ikut sistem) lewat `ThemeData` dan `ThemeExtension`.
- [x] Tata letak tiga area: toolbar, daftar + pemisah yang bisa digeser, area kanan (bar rename + preview), bar status.
- [x] Registrasi `Shortcuts`/`Actions` untuk semua pintasan STYLE bagian 6.
- [x] `lib/l10n/strings.dart` berisi semua teks UI.

**Selesai bila:** kerangka tampil benar di tema terang dan gelap, ukuran minimum 960x600 tidak overflow.

## Fase 7 — Fitur UI
- [x] Toolbar: pilih folder (dialog native + Ctrl+O), tampilan path, muat ulang (F5), toggle semua file, Undo, pengaturan.
- [x] Drag & drop folder ke jendela dengan overlay.
- [x] Daftar file: header grup sticky, item aktif, scroll otomatis ke item aktif, tooltip nama penuh, empty state.
- [x] Bar rename: input dengan sufiks ekstensi, Enter = simpan, validasi inline, tombol Simpan/Lewati/Buka asli, penghitung "n / total".
- [x] Panel preview PDF (`pdfrx`): fit-width, zoom, scroll semua halaman, kontrol zoom melayang.
- [x] Panel preview gambar (zoom/pan), teks (monospace, batas 200 KB), Office (lewat PDF hasil konversi + indikator loading), fallback kartu info.
- [x] Bar status: pesan sukses/error, hilang otomatis sesuai aturan.
- [x] Dialog pengaturan: tema, default toggle, bersihkan cache.
- [x] Hormati "Kurangi animasi" Windows.

**Selesai bila:** semua alur di PRD bagian 3 bisa dijalankan penuh hanya dengan keyboard.

## Fase 8 — Ketahanan & kualitas
- [x] Uji kasus tepi: folder kosong, folder hilang saat berjalan, 2.000 file, file terkunci, PDF rusak/terenkripsi, nama Unicode/emoji, path panjang, file bertambah/hilang saat aplikasi terbuka (muat ulang aman).
- [x] Pastikan tidak ada operasi di luar folder terpilih dan tidak ada operasi hapus di kode (cari `delete(` dan tinjau).
- [x] Pembersihan sumber daya: tutup dokumen PDF, batalkan konversi yang usang saat pindah file cepat.
- [x] Profiling: daftar 2.000 file (scan + grup) < 1 detik, terukur lewat tes. Pindah PDF < 300 ms dan stabilitas memori setelah 100 file belum diukur dengan alat profil; hanya diamati manual.
- [x] Audit aksesibilitas: urutan Tab, label semantik, kontras (kedua tema), target klik.
- [x] Logger ke file + tampilan lokasi log di pengaturan.
- [x] Widget test untuk alur utama (14 tes) dan tes kontras tema terang/gelap. Golden test tidak dibuat (rapuh antar mesin/font).

**Selesai bila:** semua daftar kriteria penerimaan PRD bagian 8 terpenuhi; `flutter analyze` dan `flutter test` bersih.

## Fase 9 — Rilis
- [x] `flutter build windows --release`; uji folder `build\windows\x64\runner\Release` di mesin bersih (tanpa Flutter).
- [x] README singkat: cara pakai, pintasan, syarat Office untuk preview Word/Excel.
- [x] Installer Inno Setup (installer/build_installer.ps1): per-pengguna tanpa admin, shortcut Start Menu, opsi shortcut Desktop, runtime Visual C++ disertakan, uninstaller. MSIX tidak dibuat (butuh sertifikat penandatangan).
- [x] Tandai versi 1.0.0 (tag v1.0.0), catat perubahan di CHANGELOG.md.

**Selesai bila:** pengguna bisa menyalin folder rilis ke PC lain dan langsung memakai tanpa instalasi tambahan.

---

## Backlog v1.1 / v2 (belum dijadwalkan)
- [ ] Saran nama otomatis dari teks pertama dokumen (PDF/DOCX) — chip satu klik.
- [ ] OCR untuk PDF hasil scan untuk saran nama.
- [ ] Saran nama berbasis AI (opsional, dengan persetujuan eksplisit karena mengirim isi dokumen keluar).
- [ ] Mode pemantau folder Downloads (watcher) dengan notifikasi file baru yang duplikat.
- [ ] Pemindaian rekursif subfolder.
- [ ] Input password untuk PDF terenkripsi.
- [ ] Riwayat rename yang bisa dilihat dan dibatalkan sebagian.
- [ ] Alternatif konversi LibreOffice bila Office tidak ada.
- [ ] Lokalisasi bahasa Inggris.

## Urutan yang disarankan
Fase 0 → 1 → 2 → 3 berurutan. Fase 4 (Office) bisa paralel dengan Fase 3 dan **harus selesai sebelum Fase 7** agar risiko terbesar terbukti lebih dulu. Fase 5 dan 6 bisa paralel setelah Fase 3. Fase 8 dan 9 di akhir.
