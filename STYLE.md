# STYLE — Rename Peek (Flutter Windows Desktop)

Panduan desain visual, interaksi, dan konvensi kode. Acuan untuk semua layar dan komponen.

## 1. Prinsip desain

1. **Preview adalah bintangnya.** Panel preview mendapat ruang terbesar; semua elemen lain mendukung alur "lihat, ketik, Enter".
2. **Keyboard dulu.** Seluruh alur utama bisa dilakukan tanpa mouse; fokus tidak pernah hilang dari kolom nama setelah aksi.
3. **Tenang dan fungsional.** Alat kerja untuk sesi panjang: warna netral, satu warna aksen, tanpa dekorasi berlebih (tanpa gradien, bayangan berat, atau animasi pamer).
4. **Umpan balik jelas.** Setiap aksi (rename, undo, error) punya respons terlihat singkat di bar status.

## 2. Tata letak

Jendela minimum 960 x 600, default 1280 x 800. Tiga area:

```
┌───────────────────────────────────────────────────────────────┐
│ Toolbar: [Folder ▸ path........] [Muat ulang] [Semua file ☐] [Undo] [⚙] │
├───────────────┬───────────────────────────────────────────────┤
│ Daftar file   │ Bar rename: nama file saat ini · 3/12          │
│ (300 px)      │ [ input nama baru .............. ].pdf [Simpan]│
│               │ [Lewati] [Buka asli]                           │
│ ▸ master_inh… ├───────────────────────────────────────────────┤
│   master_inh… │                                               │
│   master_inh… │              PREVIEW (mengisi sisa)            │
│               │                                               │
├───────────────┴───────────────────────────────────────────────┤
│ Status: ✓ master_inhouse (1).pdf → Laporan A.pdf    Enter · Alt+↓ · Ctrl+Z │
└───────────────────────────────────────────────────────────────┘
```

- Daftar kiri lebar tetap 300 px, bisa diubah ukuran dengan pemisah (min 220, maks 480). Di lebar jendela di bawah 1100 px, daftar menyusut ke 240 px.
- Bar rename menempel di atas preview agar mata tidak berpindah jauh dari input ke dokumen.
- Gunakan spasi berbasis kelipatan 4 px: 4, 8, 12, 16, 24, 32.
- Radius sudut: 8 px untuk kontrol dan kartu, 12 px untuk dialog.

## 3. Warna (token)

Material 3 dengan skema warna kustom; seluruh warna diambil dari `ColorScheme` dan `ThemeExtension`, tidak ada hex di dalam widget.

| Token | Terang | Gelap | Pemakaian |
|---|---|---|---|
| `surface` | `#F6F6F4` | `#161615` | latar jendela |
| `surfaceContainer` | `#FFFFFF` | `#1F1F1E` | toolbar, daftar, bar rename |
| `outline` | `#E3E1DB` | `#33322F` | garis pembatas 1 px |
| `onSurface` | `#1D1D1B` | `#ECEBE6` | teks utama |
| `onSurfaceVariant` | `#6B6963` | `#98958D` | teks sekunder, ukuran file |
| `primary` | `#2A5BD7` | `#7AA2FF` | aksen: item aktif, tombol utama, fokus |
| `success` | `#187A41` | `#4CC784` | konfirmasi rename |
| `warning` | `#B4540A` | `#F0A35A` | error/peringatan di status |
| `previewBackdrop` | `#8A8A87` | `#0E0E0D` | latar di belakang halaman PDF/gambar |

Aturan:
- Satu warna aksen (`primary`). Jangan menambah warna dekoratif.
- Kontras teks terhadap latar minimal 4.5:1 (AA); diperiksa untuk kedua tema.
- Item aktif di daftar: latar `primary` 14% + garis kiri 3 px `primary`.
- Tema mengikuti sistem secara default, bisa dipaksa terang/gelap di pengaturan.

## 4. Tipografi

- Font: **Segoe UI Variable** (bawaan Windows 11) dengan fallback Segoe UI; font monospace untuk preview teks: **Cascadia Mono** fallback Consolas. Tidak menyertakan font tambahan agar rilis ringan.
- Skala:

| Peran | Ukuran / berat | Dipakai di |
|---|---|---|
| Judul bagian | 12 / 600, huruf kapital, letter-spacing 0.04 | header grup di daftar |
| Isi | 14 / 400 | item daftar, label |
| Input nama | 16 / 500 | kolom nama baru |
| Sekunder | 12 / 400 | ukuran file, status, kbd hint |
| Judul dialog | 18 / 600 | pengaturan |

- Nama file panjang dipotong dengan elipsis di tengah-akhir (`overflow: ellipsis`) dan tooltip menampilkan nama penuh.

## 5. Komponen

### Toolbar
- Tinggi 48 px. Kolom path folder menampilkan path (read-only, klik = pilih folder). Tombol ikon dengan tooltip dan label semantik.

### Daftar file
- Header grup: nama dasar + jumlah file ("master_inhouse · 6 file"), sticky saat scroll.
- Item: tinggi 36 px, nama file kiri (elipsis), ukuran kanan (sekunder). Hover: latar `onSurface` 6%. Aktif: lihat aturan warna.
- File yang baru saja di-rename menghilang dari daftar duplikat dengan transisi pudar 150 ms.
- Empty state: ikon folder besar, teks "Tidak ada file duplikat di folder ini", tombol "Tampilkan semua file" dan "Pilih folder lain".

### Bar rename
- Baris 1: nama file saat ini (sekunder, elipsis) dan penghitung "3 / 12".
- Baris 2: `TextField` lebar penuh dengan sufiks ekstensi (tak bisa diubah), tombol utama "Simpan & lanjut" (filled), tombol "Lewati" (outlined), "Buka asli" (text).
- Border input 2 px `primary` saat fokus. Input selalu autofocus setelah aksi.
- Validasi inline: pesan error kecil di bawah input (merah/oranye), bukan dialog.

### Preview
- Latar `previewBackdrop`, dokumen tampil seperti kertas putih dengan bayangan sangat tipis.
- PDF: scroll vertikal, fit-width default, Ctrl+scroll untuk zoom, tombol +/−/fit kecil melayang di pojok kanan bawah.
- Gambar: fit-to-view, scroll untuk zoom, drag untuk pan.
- Loading: indikator linear tipis di atas panel + teks "Menyiapkan preview…" di tengah (khusus konversi Office).
- Error/fallback: kartu di tengah dengan ikon tipe file, nama, ukuran, tanggal ubah, penjelasan singkat penyebab, tombol "Buka asli".

### Bar status
- Tinggi 28 px. Kiri: pesan terakhir (sukses hijau dengan ✓, error oranye dengan ⚠). Kanan: pengingat pintasan. Pesan sukses hilang otomatis setelah 6 detik; error menetap sampai aksi berikutnya.

### Dialog pengaturan
- Dialog modal 420 px: pilihan tema (segmented: Sistem / Terang / Gelap), switch "Tampilkan semua file secara default", tombol "Bersihkan cache preview" dengan ukuran cache terlihat.

## 6. Interaksi & pintasan

| Aksi | Pintasan |
|---|---|
| Simpan & lanjut | Enter (di input nama) |
| Lewati ke file berikutnya | Alt+↓ |
| Kembali ke file sebelumnya | Alt+↑ |
| Undo rename | Ctrl+Z (di luar input) atau tombol Undo |
| Muat ulang folder | F5 |
| Pilih folder | Ctrl+O |
| Buka file asli | Ctrl+Enter |
| Fokus ke input nama | Ctrl+L atau Esc |
| Zoom preview | Ctrl+scroll, Ctrl +/− |

- Pintasan didaftarkan lewat `Shortcuts` + `Actions` (bukan listener mentah), sehingga bisa diuji.
- Tidak ada dialog konfirmasi untuk rename (karena ada undo). Dialog konfirmasi hanya untuk tindakan yang tidak bisa di-undo (misalnya membersihkan cache tidak perlu konfirmasi; tidak ada aksi hapus file sama sekali).
- Drag & drop folder ke jendela menampilkan overlay "Lepas untuk membuka folder".

## 7. Gerak

- Durasi 120-180 ms, kurva `easeOut`. Hanya untuk: pudar item daftar, geser sorotan item aktif, muncul/hilang pesan status.
- Hormati pengaturan "Kurangi animasi" Windows (`MediaQuery.disableAnimations`): semua transisi jadi instan.

## 8. Teks UI (Bahasa Indonesia)

- Nada: singkat, langsung, tanpa basa-basi. Kata kerja di awal untuk tombol ("Simpan & lanjut", "Lewati", "Buka asli", "Muat ulang").
- Pesan error menyebut penyebab + tindakan: "File sedang dipakai aplikasi lain. Tutup file itu lalu coba lagi."
- Semua string di satu tempat (`lib/l10n/strings.dart`) agar mudah diubah.

## 9. Aksesibilitas

- Semua kontrol bisa dijangkau Tab dengan urutan logis: toolbar, daftar, input nama, tombol aksi, preview.
- Fokus terlihat jelas (cincin 2 px `primary`, offset 2 px).
- `Semantics` label pada tombol ikon dan pada item daftar ("master_inhouse (1).pdf, 78 KB, 2 dari 6").
- Tidak menyampaikan status hanya lewat warna; selalu disertai ikon/teks.
- Ukuran target klik minimal 32 x 32 px.

## 10. Konvensi kode

- Struktur folder:
  ```
  lib/
    main.dart
    app.dart                 # MaterialApp, tema, shortcuts
    core/                    # tema, token warna, util, konstanta
    domain/                  # model + fungsi murni (parse nama, sanitasi, grup)
    data/                    # scanner, rename service, undo log, office converter, settings
    features/
      browser/               # daftar file + toolbar
      preview/               # panel preview per tipe
      rename/                # bar rename
      settings/
    l10n/strings.dart
  assets/scripts/convert.ps1
  test/
  ```
- Lint: `flutter_lints` + aturan tambahan `prefer_const_constructors`, `avoid_print`, `always_declare_return_types`. `flutter analyze` harus bersih.
- Penamaan: file `snake_case.dart`, kelas `PascalCase`, provider berakhiran `Provider`.
- Widget kecil dan komposabel; logika bisnis tidak boleh ada di widget (taruh di provider/service).
- Operasi I/O dan proses eksternal selalu async, dengan penanganan error eksplisit (hasil sukses/gagal bertipe, bukan melempar sembarang).
- Tidak ada `print`; gunakan logger sederhana ke file di folder data aplikasi.
- Setiap fungsi domain murni wajib punya unit test (lihat `TASK.md`).
- Komentar hanya untuk "kenapa", bukan "apa".
