import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rename_peek/data/office_converter.dart';
import 'package:rename_peek/data/settings_store.dart';
import 'package:rename_peek/data/undo_log.dart';
import 'package:rename_peek/state/browser_controller.dart';
import 'package:rename_peek/state/preview.dart';
import 'package:rename_peek/state/providers.dart';
import 'package:rename_peek/state/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tmp;
  late Directory work;
  late ProviderContainer c;

  File make(String name, [String content = 'x']) =>
      File(p.join(work.path, name))..writeAsStringSync(content);

  Future<AppServices> services() async {
    SharedPreferences.setMockInitialValues({});
    return AppServices(
      settings: SettingsStore(await SharedPreferences.getInstance()),
      undoLog: UndoLog(File(p.join(tmp.path, 'data', 'log.json'))),
      converter: OfficeConverter(
        scriptPath: 'tidak-dipakai.ps1',
        cacheDir: Directory(p.join(tmp.path, 'cache')),
      ),
    );
  }

  Future<ProviderContainer> newContainer() async {
    final s = await services();
    final container = ProviderContainer(
      overrides: [servicesProvider.overrideWithValue(s)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('rp_state_');
    work = Directory(p.join(tmp.path, 'work'))..createSync();
    c = await newContainer();
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  BrowserController ctl() => c.read(browserProvider.notifier);
  BrowserState st() => c.read(browserProvider);

  test('membuka folder: hanya grup duplikat yang tampil', () async {
    make('dokumen.pdf');
    make('dokumen (1).pdf');
    make('dokumen (2).pdf');
    make('lain.pdf');
    await ctl().openFolder(work.path);
    expect(st().view.map((f) => f.name), [
      'dokumen.pdf',
      'dokumen (1).pdf',
      'dokumen (2).pdf',
    ]);
    expect(st().index, 0);
    ctl().setShowAll(true);
    expect(st().view.length, 4);
  });

  test('simpan me-rename lalu pindah ke file berikutnya', () async {
    make('dokumen.pdf');
    make('dokumen (1).pdf');
    make('dokumen (2).pdf');
    await ctl().openFolder(work.path);
    final err = await ctl().save('Laporan A');
    expect(err, isNull);
    expect(File(p.join(work.path, 'Laporan A.pdf')).existsSync(), isTrue);
    // dokumen.pdf sudah ganti nama; file aktif sekarang "dokumen (1).pdf"
    expect(st().current?.name, 'dokumen (1).pdf');
    expect(st().status?.isError, isFalse);
    expect(st().canUndo, isTrue);
  });

  test(
    'rename file terakhir di grup: daftar jadi kosong tanpa crash',
    () async {
      make('dokumen.pdf');
      make('dokumen (1).pdf');
      await ctl().openFolder(work.path);
      await ctl().save('satu');
      expect(st().view.length, 0); // sisa 1 file, bukan duplikat lagi
      expect(st().current, isNull);
    },
  );

  test(
    'nama tidak valid mengembalikan error dan tidak mengubah file',
    () async {
      make('a.pdf');
      make('a (1).pdf');
      await ctl().openFolder(work.path);
      final err = await ctl().save('   ');
      expect(err, isNotNull);
      expect(st().status?.isError, isTrue);
      expect(File(p.join(work.path, 'a.pdf')).existsSync(), isTrue);
    },
  );

  test('lewati dan kembali menjaga batas indeks', () async {
    make('a.pdf');
    make('a (1).pdf');
    await ctl().openFolder(work.path);
    ctl().previous();
    expect(st().index, 0);
    ctl().next();
    ctl().next();
    expect(st().index, 1);
  });

  test('undo mengembalikan nama dan memilih file itu lagi', () async {
    make('a.pdf');
    make('a (1).pdf');
    await ctl().openFolder(work.path);
    await ctl().save('baru');
    await ctl().undo();
    expect(File(p.join(work.path, 'a.pdf')).existsSync(), isTrue);
    expect(st().current?.name, 'a.pdf');
    expect(st().canUndo, isFalse);
  });

  test('folder tidak ada menghasilkan status error', () async {
    await ctl().openFolder(p.join(tmp.path, 'nope'));
    expect(st().status?.isError, isTrue);
    expect(st().files, isEmpty);
  });

  test('init memuat folder terakhir dari pengaturan', () async {
    make('a.pdf');
    make('a (1).pdf');
    final s = await services();
    await s.settings.setLastFolder(work.path);
    final c2 = ProviderContainer(
      overrides: [servicesProvider.overrideWithValue(s)],
    );
    addTearDown(c2.dispose);
    await c2.read(browserProvider.notifier).init();
    expect(c2.read(browserProvider).view.length, 2);
  });

  test('muat ulang mempertahankan file terpilih', () async {
    make('a.pdf');
    make('a (1).pdf');
    make('a (2).pdf');
    await ctl().openFolder(work.path);
    ctl().select(1);
    make('a (3).pdf');
    await ctl().reload();
    expect(st().current?.name, 'a (1).pdf');
    expect(st().view.length, 4);
  });

  group('preview', () {
    test('PDF, gambar, teks, dan tipe tak dikenal', () async {
      make('a.pdf');
      make('b.png');
      make('c.txt', 'halo dunia');
      make('d.xyz');
      await ctl().openFolder(work.path);
      ctl().setShowAll(true);
      Future<PreviewSpec> load(String n) => c.read(
        previewProvider(st().files.firstWhere((f) => f.name == n)).future,
      );
      expect(await load('a.pdf'), isA<PdfPreview>());
      expect(await load('b.png'), isA<ImagePreview>());
      final t = await load('c.txt') as TextPreview;
      expect(t.text, 'halo dunia');
      expect(t.truncated, isFalse);
      expect(await load('d.xyz'), isA<InfoPreview>());
    });

    test('teks besar dipotong', () async {
      make('big.txt', 'a' * (textPreviewLimit + 5000));
      await ctl().openFolder(work.path);
      ctl().setShowAll(true);
      final t =
          await c.read(previewProvider(st().current!).future) as TextPreview;
      expect(t.truncated, isTrue);
      expect(t.text.length, textPreviewLimit);
    });
  });
}
