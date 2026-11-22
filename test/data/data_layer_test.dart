import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rename_peek/data/folder_scanner.dart';
import 'package:rename_peek/data/rename_service.dart';
import 'package:rename_peek/data/settings_store.dart';
import 'package:rename_peek/data/undo_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tmp;
  late Directory work;
  late UndoLog log;
  late RenameService svc;
  const scanner = FolderScanner();

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('rp_test_');
    work = Directory(p.join(tmp.path, 'work'))..createSync();
    log = UndoLog(File(p.join(tmp.path, 'data', 'log.json')));
    svc = RenameService(log);
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  File make(String name, [String content = 'x']) =>
      File(p.join(work.path, name))..writeAsStringSync(content);

  Future<dynamic> doc(String name) async =>
      (await scanner.scan(work.path)).firstWhere((f) => f.name == name);

  group('FolderScanner', () {
    test('memindai file dan mengabaikan sementara/tersembunyi', () async {
      make('a.pdf');
      make('a (1).pdf');
      make('~\$temp.docx');
      make('.hidden');
      make('Thumbs.db');
      Directory(p.join(work.path, 'sub')).createSync();
      final files = await scanner.scan(work.path);
      expect(files.map((f) => f.name).toList()..sort(), ['a (1).pdf', 'a.pdf']);
    });
    test('folder tidak ada melempar ScanException', () async {
      expect(
        () => scanner.scan(p.join(tmp.path, 'nope')),
        throwsA(isA<ScanException>()),
      );
    });
    test('folder kosong menghasilkan daftar kosong', () async {
      expect(await scanner.scan(work.path), isEmpty);
    });
  });

  group('RenameService', () {
    test('rename biasa mempertahankan ekstensi', () async {
      make('dokumen (1).pdf');
      final r = await svc.rename(
        file: await doc('dokumen (1).pdf'),
        input: 'Laporan: Q1',
        rootDir: work.path,
      );
      expect(r.isOk, isTrue);
      expect(r.newName, 'Laporan Q1.pdf');
      expect(File(p.join(work.path, 'Laporan Q1.pdf')).existsSync(), isTrue);
      expect(File(p.join(work.path, 'dokumen (1).pdf')).existsSync(), isFalse);
    });

    test('bentrok tidak menimpa file lain', () async {
      make('a.pdf', 'AAA');
      make('b.pdf', 'BBB');
      final r = await svc.rename(
        file: await doc('b.pdf'),
        input: 'a',
        rootDir: work.path,
      );
      expect(r.newName, 'a (1).pdf');
      expect(File(p.join(work.path, 'a.pdf')).readAsStringSync(), 'AAA');
      expect(File(p.join(work.path, 'a (1).pdf')).readAsStringSync(), 'BBB');
    });

    test('nama kosong, reserved, dan tidak berubah ditolak', () async {
      make('a.pdf');
      final f = await doc('a.pdf');
      expect(
        (await svc.rename(file: f, input: '  ', rootDir: work.path)).isOk,
        isFalse,
      );
      expect(
        (await svc.rename(file: f, input: 'CON', rootDir: work.path)).isOk,
        isFalse,
      );
      expect(
        (await svc.rename(file: f, input: 'a', rootDir: work.path)).isOk,
        isFalse,
      );
      expect(File(p.join(work.path, 'a.pdf')).existsSync(), isTrue);
    });

    test('ganti huruf besar/kecil diizinkan', () async {
      make('abc.pdf');
      final r = await svc.rename(
        file: await doc('abc.pdf'),
        input: 'ABC',
        rootDir: work.path,
      );
      expect(r.newName, 'ABC.pdf');
    });

    test('file di luar folder terpilih ditolak', () async {
      make('a.pdf');
      final f = await doc('a.pdf');
      final r = await svc.rename(file: f, input: 'x', rootDir: tmp.path);
      expect(r.isOk, isFalse);
    });

    test('file hilang ditolak dengan pesan', () async {
      make('a.pdf');
      final f = await doc('a.pdf');
      File(f.path).deleteSync();
      final r = await svc.rename(file: f, input: 'x', rootDir: work.path);
      expect(r.isOk, isFalse);
      expect(r.error, contains('sudah tidak ada'));
    });

    test('path terlalu panjang ditolak', () async {
      make('a.pdf');
      final r = await svc.rename(
        file: await doc('a.pdf'),
        input: 'x' * 300,
        rootDir: work.path,
      );
      expect(r.isOk, isFalse);
    });

    test('Unicode/emoji berhasil', () async {
      make('a.pdf');
      final r = await svc.rename(
        file: await doc('a.pdf'),
        input: 'Surat 📄 Pajak',
        rootDir: work.path,
      );
      expect(r.isOk, isTrue);
      expect(
        File(p.join(work.path, 'Surat 📄 Pajak.pdf')).existsSync(),
        isTrue,
      );
    });

    test('file terkunci gagal rapi tanpa melempar', () async {
      final f0 = make('lock.pdf');
      final f = await doc('lock.pdf');
      final raf = f0.openSync(mode: FileMode.append);
      try {
        final r = await svc.rename(file: f, input: 'baru', rootDir: work.path);
        // Pada Windows rename file terbuka gagal; bila lolos, tetap harus konsisten.
        if (!r.isOk) {
          expect(r.error, isNotEmpty);
          expect(File(f.path).existsSync(), isTrue);
        }
      } finally {
        raf.closeSync();
      }
    });
  });

  group('UndoLog', () {
    test('undo mengembalikan nama lama', () async {
      make('a.pdf');
      await svc.rename(
        file: await doc('a.pdf'),
        input: 'baru',
        rootDir: work.path,
      );
      expect(await log.canUndo, isTrue);
      final u = await log.undoLast();
      expect(u.isOk, isTrue);
      expect(File(p.join(work.path, 'a.pdf')).existsSync(), isTrue);
      expect(await log.canUndo, isFalse);
    });

    test('undo berlapis berurutan terbalik', () async {
      make('a.pdf');
      make('b.pdf');
      await svc.rename(
        file: await doc('a.pdf'),
        input: 'a1',
        rootDir: work.path,
      );
      await svc.rename(
        file: await doc('b.pdf'),
        input: 'b1',
        rootDir: work.path,
      );
      await log.undoLast();
      expect(File(p.join(work.path, 'b.pdf')).existsSync(), isTrue);
      expect(File(p.join(work.path, 'a1.pdf')).existsSync(), isTrue);
      await log.undoLast();
      expect(File(p.join(work.path, 'a.pdf')).existsSync(), isTrue);
    });

    test('tahan restart: log dibaca ulang dari disk', () async {
      make('a.pdf');
      await svc.rename(
        file: await doc('a.pdf'),
        input: 'baru',
        rootDir: work.path,
      );
      final reopened = UndoLog(log.file);
      expect((await reopened.undoLast()).isOk, isTrue);
    });

    test(
      'ditolak bila nama lama sudah dipakai; catatan dipertahankan',
      () async {
        make('a.pdf');
        await svc.rename(
          file: await doc('a.pdf'),
          input: 'baru',
          rootDir: work.path,
        );
        make('a.pdf', 'lain');
        final u = await log.undoLast();
        expect(u.isOk, isFalse);
        expect(u.error, contains('sudah dipakai'));
        expect(File(p.join(work.path, 'a.pdf')).readAsStringSync(), 'lain');
        expect(await log.canUndo, isTrue);
      },
    );

    test('ditolak bila hasil rename sudah hilang', () async {
      make('a.pdf');
      await svc.rename(
        file: await doc('a.pdf'),
        input: 'baru',
        rootDir: work.path,
      );
      File(p.join(work.path, 'baru.pdf')).deleteSync();
      final u = await log.undoLast();
      expect(u.isOk, isFalse);
      expect(u.error, contains('sudah tidak ada'));
    });

    test('log kosong dan log rusak aman', () async {
      expect((await log.undoLast()).isOk, isFalse);
      log.file.parent.createSync(recursive: true);
      log.file.writeAsStringSync('{{bukan json');
      expect(await log.canUndo, isFalse);
    });
  });

  group('SettingsStore', () {
    test('menyimpan dan membaca preferensi', () async {
      SharedPreferences.setMockInitialValues({});
      final s = SettingsStore(await SharedPreferences.getInstance());
      expect(s.themeMode, 'system');
      expect(s.showAll, isFalse);
      expect(s.lastFolder, isNull);
      await s.setThemeMode('dark');
      await s.setShowAll(true);
      await s.setLastFolder('C:\\x');
      expect(s.themeMode, 'dark');
      expect(s.showAll, isTrue);
      expect(s.lastFolder, 'C:\\x');
    });
  });
}
