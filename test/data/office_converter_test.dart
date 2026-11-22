@TestOn('windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rename_peek/data/office_converter.dart';

/// Uji integrasi: butuh Microsoft Office terpasang. Dilewati bila tidak ada.
void main() {
  late Directory tmp;
  late OfficeConverter conv;
  final fixtures = p.join(Directory.current.path, 'test', 'fixtures', 'office');
  final script = p.join(
    Directory.current.path,
    'assets',
    'scripts',
    'convert.ps1',
  );

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('rp_office_');
    conv = OfficeConverter(
      scriptPath: script,
      cacheDir: Directory(p.join(tmp.path, 'cache')),
      timeout: const Duration(seconds: 90),
    );
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<void> expectPdf(String name, OfficeApp app) async {
    if (!await conv.isAvailable(app)) {
      markTestSkipped('${app.label} tidak terpasang');
      return;
    }
    final r = await conv.convertToPdf(p.join(fixtures, name));
    expect(r.isOk, isTrue, reason: r.error);
    final bytes = File(r.pdfPath!).readAsBytesSync();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  }

  test(
    'DOCX menjadi PDF valid',
    () => expectPdf('contoh.docx', OfficeApp.word),
  );
  test(
    'XLSX menjadi PDF valid',
    () => expectPdf('contoh.xlsx', OfficeApp.excel),
  );
  test(
    'PPTX menjadi PDF valid',
    () => expectPdf('contoh.pptx', OfficeApp.powerPoint),
  );

  test(
    'cache dipakai pada panggilan kedua dan file asli tidak berubah',
    () async {
      if (!await conv.isAvailable(OfficeApp.word)) {
        markTestSkipped('Word tidak terpasang');
        return;
      }
      final src = File(p.join(fixtures, 'contoh.docx'));
      final before = src.statSync();
      final a = await conv.convertToPdf(src.path);
      final sw = Stopwatch()..start();
      final b = await conv.convertToPdf(src.path);
      sw.stop();
      expect(b.pdfPath, a.pdfPath);
      expect(sw.elapsedMilliseconds, lessThan(500));
      final after = src.statSync();
      expect(after.modified, before.modified);
      expect(after.size, before.size);
    },
  );

  test('permintaan bersamaan untuk file sama dijalankan sekali', () async {
    if (!await conv.isAvailable(OfficeApp.excel)) {
      markTestSkipped('Excel tidak terpasang');
      return;
    }
    final path = p.join(fixtures, 'contoh.xlsx');
    final rs = await Future.wait([
      conv.convertToPdf(path),
      conv.convertToPdf(path),
    ]);
    expect(rs[0].isOk && rs[1].isOk, isTrue);
    expect(rs[0].pdfPath, rs[1].pdfPath);
  });

  test('file rusak gagal dengan pesan, tanpa hang', () async {
    if (!await conv.isAvailable(OfficeApp.word)) {
      markTestSkipped('Word tidak terpasang');
      return;
    }
    final r = await conv.convertToPdf(p.join(fixtures, 'rusak.docx'));
    expect(r.isOk, isFalse);
    expect(r.error, isNotEmpty);
  });

  test('tipe non-Office dan file hilang ditolak', () async {
    expect((await conv.convertToPdf('a.pdf')).isOk, isFalse);
    expect((await conv.convertToPdf(p.join(tmp.path, 'x.docx'))).isOk, isFalse);
  });

  test('pengelolaan cache: ukuran, trim, hapus', () async {
    final dir = Directory(p.join(tmp.path, 'cache'))
      ..createSync(recursive: true);
    File(p.join(dir.path, 'a.pdf')).writeAsBytesSync(List.filled(1000, 1));
    File(p.join(dir.path, 'b.pdf')).writeAsBytesSync(List.filled(1000, 1));
    expect(await conv.cacheSize(), 2000);
    await conv.trimCache(maxBytes: 1500);
    expect(await conv.cacheSize(), 1000);
    await conv.clearCache();
    expect(await conv.cacheSize(), 0);
  });

  test('officeAppFor memetakan ekstensi', () {
    expect(officeAppFor('.docx'), OfficeApp.word);
    expect(officeAppFor('.xlsm'), OfficeApp.excel);
    expect(officeAppFor('.pptx'), OfficeApp.powerPoint);
    expect(officeAppFor('.pdf'), isNull);
  });
}
