import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Hasil konversi Office ke PDF.
class ConvertResult {
  const ConvertResult.ok(String this.pdfPath)
    : error = null,
      officeMissing = false;
  const ConvertResult.fail(String this.error, {this.officeMissing = false})
    : pdfPath = null;

  final String? pdfPath;
  final String? error;

  /// True bila aplikasi Office yang dibutuhkan tidak terpasang.
  final bool officeMissing;
  bool get isOk => pdfPath != null;
}

enum OfficeApp {
  word('Word', 'Word.Application'),
  excel('Excel', 'Excel.Application'),
  powerPoint('PowerPoint', 'PowerPoint.Application');

  const OfficeApp(this.label, this.progId);
  final String label;
  final String progId;
}

const _wordExts = {'.doc', '.docx', '.rtf', '.odt'};
const _excelExts = {'.xls', '.xlsx', '.xlsm', '.ods'};
const _pptExts = {'.ppt', '.pptx', '.odp'};

/// Aplikasi Office untuk [ext] (huruf kecil, dengan titik), null bila bukan Office.
OfficeApp? officeAppFor(String ext) {
  if (_wordExts.contains(ext)) return OfficeApp.word;
  if (_excelExts.contains(ext)) return OfficeApp.excel;
  if (_pptExts.contains(ext)) return OfficeApp.powerPoint;
  return null;
}

bool isOfficeExt(String ext) => officeAppFor(ext) != null;

/// Mengonversi dokumen Office ke PDF memakai Word/Excel/PowerPoint terpasang.
///
/// Konversi berjalan satu per satu (antrean), hasilnya di-cache berdasar
/// hash(path + waktu ubah + ukuran). File asli tidak pernah disentuh.
class OfficeConverter {
  OfficeConverter({
    required this.scriptPath,
    required this.cacheDir,
    this.timeout = const Duration(seconds: 120),
  });

  final String scriptPath;
  final Directory cacheDir;
  final Duration timeout;

  Future<void> _queue = Future<void>.value();
  final Map<String, Future<ConvertResult>> _inflight = {};
  final Map<OfficeApp, bool> _availability = {};

  /// Cek registry apakah [app] terpasang (hasil di-cache selama sesi).
  Future<bool> isAvailable(OfficeApp app) async {
    final cached = _availability[app];
    if (cached != null) return cached;
    final r = await Process.run('reg', ['query', 'HKCR\\${app.progId}\\CLSID']);
    return _availability[app] = r.exitCode == 0;
  }

  String _cacheKey(File src, FileStat st) => sha1
      .convert(
        utf8.encode(
          '${src.path}|${st.modified.millisecondsSinceEpoch}|${st.size}',
        ),
      )
      .toString();

  Future<ConvertResult> convertToPdf(String srcPath) async {
    final ext = p.extension(srcPath).toLowerCase();
    final app = officeAppFor(ext);
    if (app == null) {
      return const ConvertResult.fail('Tipe file ini bukan dokumen Office.');
    }
    final src = File(srcPath);
    if (!await src.exists()) {
      return const ConvertResult.fail('File tidak ditemukan.');
    }
    final st = await src.stat();
    final out = File(p.join(cacheDir.path, '${_cacheKey(src, st)}.pdf'));
    if (await out.exists() && await out.length() > 0) {
      return ConvertResult.ok(out.path);
    }
    return _inflight[out.path] ??= _enqueue(app, src, out)
      ..whenComplete(() => _inflight.remove(out.path));
  }

  Future<ConvertResult> _enqueue(OfficeApp app, File src, File out) {
    final completer = Completer<ConvertResult>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await _run(app, src, out));
      } on Object catch (e) {
        completer.complete(ConvertResult.fail('Konversi gagal: $e'));
      }
    });
    return completer.future;
  }

  Future<ConvertResult> _run(OfficeApp app, File src, File out) async {
    if (!await isAvailable(app)) {
      return ConvertResult.fail(
        'Microsoft ${app.label} tidak terpasang, preview tidak tersedia.',
        officeMissing: true,
      );
    }
    await cacheDir.create(recursive: true);
    final part = File(
      p.join(cacheDir.path, '${p.basenameWithoutExtension(out.path)}.part.pdf'),
    );
    if (await part.exists()) await part.delete();

    final proc = await Process.start('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      scriptPath,
      '-Src',
      src.path,
      '-Dst',
      part.path,
    ]);
    final stderrBuf = StringBuffer();
    final errDone = proc.stderr
        .transform(utf8.decoder)
        .forEach(stderrBuf.write);
    unawaited(proc.stdout.drain<void>());

    int code;
    try {
      code = await proc.exitCode.timeout(timeout);
    } on TimeoutException {
      await _killTree(proc.pid);
      await errDone.catchError((Object _) {});
      if (await part.exists()) await part.delete();
      return const ConvertResult.fail(
        'Konversi terlalu lama (lebih dari 2 menit). File mungkin dilindungi password atau terlalu besar.',
      );
    }
    await errDone;
    if (code != 0 || !await part.exists() || await part.length() == 0) {
      if (await part.exists()) await part.delete();
      final msg = stderrBuf.toString().trim();
      return ConvertResult.fail(
        msg.isEmpty
            ? 'Konversi gagal (kode $code). File mungkin rusak atau dilindungi password.'
            : 'Konversi gagal: ${msg.split('\n').first}',
      );
    }
    await part.rename(out.path);
    return ConvertResult.ok(out.path);
  }

  Future<void> _killTree(int pid) async {
    await Process.run('taskkill', ['/PID', '$pid', '/T', '/F']);
  }

  // ---- cache ----

  Future<int> cacheSize() async {
    if (!await cacheDir.exists()) return 0;
    var total = 0;
    await for (final e in cacheDir.list()) {
      if (e is File) total += await e.length();
    }
    return total;
  }

  Future<void> clearCache() async {
    if (!await cacheDir.exists()) return;
    await for (final e in cacheDir.list()) {
      if (e is File) {
        try {
          await e.delete();
        } on FileSystemException {
          // sedang dipakai; biarkan
        }
      }
    }
  }

  /// Hapus berkas lebih tua dari [maxAge], lalu yang tertua sampai di bawah [maxBytes].
  Future<void> trimCache({
    int maxBytes = 500 * 1024 * 1024,
    Duration maxAge = const Duration(days: 7),
  }) async {
    if (!await cacheDir.exists()) return;
    final files = <(File, FileStat)>[];
    await for (final e in cacheDir.list()) {
      if (e is File) files.add((e, await e.stat()));
    }
    final now = DateTime.now();
    files.sort((a, b) => a.$2.modified.compareTo(b.$2.modified));
    var total = files.fold<int>(0, (s, f) => s + f.$2.size);
    for (final (file, st) in files) {
      final old = now.difference(st.modified) > maxAge;
      if (old || total > maxBytes) {
        try {
          await file.delete();
          total -= st.size;
        } on FileSystemException {
          // lewati
        }
      }
    }
  }
}
