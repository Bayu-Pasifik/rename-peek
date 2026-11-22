import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Satu catatan rename.
class RenameLogEntry {
  const RenameLogEntry({
    required this.dir,
    required this.from,
    required this.to,
    required this.at,
  });

  factory RenameLogEntry.fromJson(Map<String, dynamic> j) => RenameLogEntry(
        dir: j['dir'] as String,
        from: j['from'] as String,
        to: j['to'] as String,
        at: DateTime.parse(j['at'] as String),
      );

  final String dir;
  final String from;
  final String to;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'dir': dir,
        'from': from,
        'to': to,
        'at': at.toIso8601String(),
      };
}

/// Hasil undo.
class UndoResult {
  const UndoResult.ok(RenameLogEntry this.entry) : error = null;
  const UndoResult.fail(String this.error) : entry = null;

  final RenameLogEntry? entry;
  final String? error;
  bool get isOk => entry != null;
}

/// Riwayat rename yang disimpan di file JSON agar undo tahan restart.
class UndoLog {
  UndoLog(this.file);

  final File file;

  Future<List<RenameLogEntry>> _read() async {
    try {
      if (!await file.exists()) return [];
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [
        for (final e in raw) RenameLogEntry.fromJson(e as Map<String, dynamic>),
      ];
    } on Object {
      // Berkas rusak: mulai dari kosong, jangan menjatuhkan aplikasi.
      return [];
    }
  }

  Future<void> _write(List<RenameLogEntry> list) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode([for (final e in list) e.toJson()]),
      flush: true,
    );
  }

  Future<bool> get canUndo async => (await _read()).isNotEmpty;

  Future<void> push(RenameLogEntry entry) async {
    final list = await _read();
    list.add(entry);
    await _write(list);
  }

  /// Membatalkan rename terakhir. Catatan hanya dihapus bila undo berhasil.
  Future<UndoResult> undoLast() async {
    final list = await _read();
    if (list.isEmpty) return const UndoResult.fail('Tidak ada yang bisa di-undo.');
    final last = list.last;
    final current = File(p.join(last.dir, last.to));
    final original = File(p.join(last.dir, last.from));
    if (!await current.exists()) {
      return UndoResult.fail(
        'File "${last.to}" sudah tidak ada, tidak bisa dikembalikan.',
      );
    }
    final caseOnly = last.from.toLowerCase() == last.to.toLowerCase();
    if (!caseOnly && await original.exists()) {
      return UndoResult.fail(
        'Nama asli "${last.from}" sudah dipakai file lain.',
      );
    }
    try {
      await current.rename(original.path);
    } on FileSystemException catch (e) {
      return UndoResult.fail(
        'Gagal mengembalikan nama (${e.osError?.message ?? e.message}).',
      );
    }
    list.removeLast();
    await _write(list);
    return UndoResult.ok(last);
  }
}
