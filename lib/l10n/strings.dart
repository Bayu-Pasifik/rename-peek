/// Semua teks UI di satu tempat (Bahasa Indonesia).
abstract final class S {
  static const appName = 'Rename Peek';

  // Toolbar
  static const chooseFolder = 'Pilih folder';
  static const noFolder = 'Belum ada folder dipilih';
  static const reload = 'Muat ulang';
  static const showAll = 'Tampilkan semua file';
  static const undo = 'Undo';
  static const settings = 'Pengaturan';

  // Daftar
  static const emptyTitle = 'Tidak ada file duplikat di folder ini';
  static const emptyNoFolder = 'Pilih folder untuk mulai.';
  static const emptyHint =
      'Centang "Tampilkan semua file" untuk melihat semuanya.';
  static const pickOtherFolder = 'Pilih folder lain';
  static String groupHeader(String key, int count) =>
      count > 1 ? '$key · $count file' : key;

  // Rename
  static const newNameHint = 'Nama baru, lalu tekan Enter';
  static const saveNext = 'Simpan & lanjut';
  static const skip = 'Lewati';
  static const openOriginal = 'Buka asli';
  static const emptyNameError = 'Isi nama baru dulu, atau klik Lewati.';
  static String position(int i, int total) => '$i / $total';

  // Preview
  static const preparingPreview = 'Menyiapkan preview…';
  static const noPreviewTitle = 'Preview tidak tersedia';
  static const officeMissing = 'Microsoft Office tidak terpasang.';
  static const selectFile = 'Pilih file di daftar kiri.';

  // Status
  static const ready = 'Siap.';
  static const shortcutsHint =
      'Enter simpan · Alt+↓/↑ lewati/kembali · Ctrl+Z undo';
  static const dropFolder = 'Lepas untuk membuka folder';

  // Pengaturan
  static const themeLabel = 'Tema';
  static const themeSystem = 'Sistem';
  static const themeLight = 'Terang';
  static const themeDark = 'Gelap';
  static const showAllDefault = 'Tampilkan semua file secara default';
  static const clearCache = 'Bersihkan cache preview';
  static const close = 'Tutup';
}
