import 'dart:io';

/// Logger sederhana ke file. Aman dipakai sebelum [init] (diam saja).
abstract final class Log {
  static File? _file;
  static const int _maxBytes = 1024 * 1024;

  /// Path berkas log aktif, atau null bila belum diinisialisasi.
  static String? get path => _file?.path;

  static void init(File file) {
    _file = file;
    try {
      file.parent.createSync(recursive: true);
      if (file.existsSync() && file.lengthSync() > _maxBytes) {
        final old = File('${file.path}.1');
        if (old.existsSync()) old.deleteSync();
        file.renameSync(old.path);
      }
    } on FileSystemException {
      // Log tidak boleh menjatuhkan aplikasi.
    }
  }

  static void info(String message) => _write('INFO', message);

  static void error(String message, [Object? error, StackTrace? stack]) {
    final extra = [
      if (error != null) ' | $error',
      if (stack != null) '\n$stack',
    ].join();
    _write('ERROR', '$message$extra');
  }

  static void _write(String level, String message) {
    final f = _file;
    if (f == null) return;
    try {
      f.writeAsStringSync(
        '${DateTime.now().toIso8601String()} $level $message\n',
        mode: FileMode.append,
        flush: true,
      );
    } on FileSystemException {
      // abaikan
    }
  }
}
