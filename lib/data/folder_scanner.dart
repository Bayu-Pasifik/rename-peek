import 'dart:io';

import 'package:path/path.dart' as p;

import '../domain/doc_file.dart';

/// Error saat memindai folder; [message] siap ditampilkan ke pengguna.
class ScanException implements Exception {
  const ScanException(this.message);
  final String message;
  @override
  String toString() => message;
}

const _ignoredNames = {'desktop.ini', 'thumbs.db'};

/// True bila [name] adalah file yang harus diabaikan (sementara/tersembunyi).
bool isIgnoredFileName(String name) =>
    name.startsWith('~\$') ||
    name.startsWith('.') ||
    _ignoredNames.contains(name.toLowerCase());

/// Memindai satu folder (non-rekursif) dan mengembalikan file yang relevan.
class FolderScanner {
  const FolderScanner();

  Future<List<DocFile>> scan(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      throw ScanException('Folder tidak ditemukan: $dirPath');
    }
    final result = <DocFile>[];
    try {
      await for (final e in dir.list(followLinks: false)) {
        if (e is! File) continue;
        final name = p.basename(e.path);
        if (isIgnoredFileName(name)) continue;
        try {
          final st = await e.stat();
          result.add(
            DocFile(
              path: e.path,
              name: name,
              size: st.size,
              modified: st.modified,
            ),
          );
        } on FileSystemException {
          // File hilang saat dipindai; lewati saja.
        }
      }
    } on FileSystemException catch (e) {
      throw ScanException(
        'Tidak bisa membaca folder (${e.osError?.message ?? e.message}).',
      );
    }
    return result;
  }
}
