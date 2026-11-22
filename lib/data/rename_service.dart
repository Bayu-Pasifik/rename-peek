import 'dart:io';

import 'package:path/path.dart' as p;

import '../domain/doc_file.dart';
import '../domain/name_rules.dart';
import 'undo_log.dart';

/// Hasil rename: sukses dengan nama akhir, atau gagal dengan pesan.
class RenameResult {
  const RenameResult.ok({required String this.newName, required this.oldName})
      : error = null;
  const RenameResult.fail(String this.error)
      : newName = null,
        oldName = null;

  final String? newName;
  final String? oldName;
  final String? error;
  bool get isOk => error == null;
}

/// Melakukan rename file dengan semua pengamanan; tidak pernah menimpa file.
class RenameService {
  RenameService(this.log);

  final UndoLog log;

  Future<RenameResult> rename({
    required DocFile file,
    required String input,
    required String rootDir,
  }) async {
    final clean = sanitizeName(input, file.ext);
    if (!clean.isOk) return RenameResult.fail(clean.error!);

    final dir = p.dirname(file.path);
    if (!p.equals(dir, rootDir)) {
      return const RenameResult.fail('File berada di luar folder yang dipilih.');
    }
    final source = File(file.path);
    if (!await source.exists()) {
      return RenameResult.fail('File "${file.name}" sudah tidak ada. Muat ulang folder.');
    }

    final desired = '${clean.name}${file.ext}';
    if (desired == file.name) {
      return const RenameResult.fail('Nama tidak berubah.');
    }

    final existing = <String>[];
    await for (final e in Directory(dir).list(followLinks: false)) {
      existing.add(p.basename(e.path));
    }
    // Ganti hanya huruf besar/kecil pada file sendiri diizinkan.
    final others = existing.where((n) => n.toLowerCase() != file.name.toLowerCase());
    final finalName = uniqueName(others, clean.name!, file.ext);
    final target = p.join(dir, finalName);
    if (target.length > maxPathLength) {
      return const RenameResult.fail('Nama terlalu panjang untuk path Windows.');
    }

    try {
      await source.rename(target);
    } on FileSystemException catch (e) {
      return RenameResult.fail(_explain(e));
    }
    await log.push(RenameLogEntry(
      dir: dir,
      from: file.name,
      to: finalName,
      at: DateTime.now(),
    ));
    return RenameResult.ok(newName: finalName, oldName: file.name);
  }

  String _explain(FileSystemException e) {
    switch (e.osError?.errorCode) {
      case 32:
        return 'File sedang dipakai aplikasi lain. Tutup file itu lalu coba lagi.';
      case 5:
        return 'Akses ditolak. File mungkin read-only atau terlindungi.';
      case 2:
      case 3:
        return 'File tidak ditemukan. Muat ulang folder.';
      default:
        return 'Gagal rename (${e.osError?.message ?? e.message}).';
    }
  }
}
