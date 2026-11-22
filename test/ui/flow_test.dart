import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:rename_peek/app.dart';
import 'package:rename_peek/state/providers.dart';

import '../helpers.dart';

void main() {
  late Directory tmp;
  late Directory work;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('rp_flow_');
    work = Directory(p.join(tmp.path, 'work'))..createSync();
  });
  tearDown(() {
    try {
      tmp.deleteSync(recursive: true);
    } on FileSystemException {
      // Handle preview yang belum sempat ditutup saat test berakhir; folder temp, abaikan.
    }
  });

  File make(String name, [String? content]) =>
      File(p.join(work.path, name))..writeAsStringSync(content ?? 'isi $name');

  bool exists(String name) => File(p.join(work.path, name)).existsSync();

  /// I/O nyata dan FakeAsync berjalan bergantian: beri waktu I/O lalu pump,
  /// diulang agar rantai await (scan, undo log, dst.) tuntas.
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 40; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpApp(WidgetTester t, {bool openWork = true}) async {
    t.view.physicalSize = const Size(1280, 800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    final s = await testServices(
      tmp,
      prefs: {if (openWork) 'lastFolder': work.path},
    );
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(s),
          dropEnabledProvider.overrideWithValue(false),
        ],
        child: const RenamePeekApp(),
      ),
    );
    await settle(t);
  }

  Future<void> type(WidgetTester t, String text) async {
    await t.enterText(find.byType(TextField), text);
    await t.testTextInput.receiveAction(TextInputAction.done);
    await settle(t);
  }

  Finder tile(String name) => find.text(name);

  testWidgets('daftar menampilkan grup duplikat saja', (t) async {
    make('dokumen.txt');
    make('dokumen (1).txt');
    make('dokumen (2).txt');
    make('lain.txt');
    await pumpApp(t);
    expect(tile('dokumen.txt'), findsWidgets);
    expect(tile('dokumen (1).txt'), findsOneWidget);
    expect(tile('lain.txt'), findsNothing);
    expect(find.text('DOKUMEN · 3 FILE'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets(
    'ketik nama + Enter: rename, status sukses, pindah ke file berikutnya',
    (t) async {
      make('dokumen.txt');
      make('dokumen (1).txt');
      make('dokumen (2).txt');
      await pumpApp(t);

      await type(t, 'Laporan A');

      expect(exists('Laporan A.txt'), isTrue);
      expect(exists('dokumen.txt'), isFalse);
      expect(
        find.textContaining('dokumen.txt  →  Laporan A.txt'),
        findsOneWidget,
      );
      // sekarang file aktif = dokumen (1).txt (1 / 2)
      expect(find.text('1 / 2'), findsOneWidget);
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    },
  );

  testWidgets('seluruh grup bisa di-rename hanya dengan keyboard', (t) async {
    make('a.txt');
    make('a (1).txt');
    make('a (2).txt');
    await pumpApp(t);
    await type(t, 'satu');
    await type(t, 'dua');
    expect(exists('satu.txt'), isTrue);
    expect(exists('dua.txt'), isTrue);
    expect(exists('a (2).txt'), isTrue); // sisa 1 file: bukan duplikat lagi
  });

  testWidgets('nama kosong menampilkan error inline dan tidak mengubah file', (
    t,
  ) async {
    make('a.txt');
    make('a (1).txt');
    await pumpApp(t);
    await t.testTextInput.receiveAction(TextInputAction.done);
    await settle(t);
    expect(find.text('Isi nama baru dulu, atau klik Lewati.'), findsOneWidget);
    expect(exists('a.txt'), isTrue);
  });

  testWidgets('nama ilegal dibersihkan dan bentrok diberi suffix', (t) async {
    make('a.txt');
    make('a (1).txt');
    make('tujuan.txt');
    await pumpApp(t);
    await type(t, 'tujuan');
    expect(exists('tujuan (1).txt'), isTrue);
    expect(find.textContaining('→  tujuan (1).txt'), findsOneWidget);
  });

  testWidgets('Alt+Panah bawah/atas melewati dan kembali', (t) async {
    make('a.txt');
    make('a (1).txt');
    make('a (2).txt');
    await pumpApp(t);
    expect(find.text('1 / 3'), findsOneWidget);
    await t.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await t.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await t.pump();
    expect(find.text('2 / 3'), findsOneWidget);
    await t.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await t.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await t.pump();
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('tombol Lewati dan klik item memindah pilihan', (t) async {
    make('a.txt');
    make('a (1).txt');
    await pumpApp(t);
    await t.tap(find.text('Lewati'));
    await t.pump();
    expect(find.text('2 / 2'), findsOneWidget);
    await t.tap(tile('a.txt').first);
    await t.pump();
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('Undo mengembalikan nama lama', (t) async {
    make('a.txt');
    make('a (1).txt');
    await pumpApp(t);
    await type(t, 'baru');
    expect(exists('baru.txt'), isTrue);
    await t.tap(find.text('Undo'));
    await settle(t);
    expect(exists('a.txt'), isTrue);
    expect(exists('baru.txt'), isFalse);
    expect(find.textContaining('Dikembalikan'), findsOneWidget);
  });

  testWidgets('pesan sukses hilang otomatis setelah 6 detik, error menetap', (
    t,
  ) async {
    make('a.txt');
    make('a (1).txt');
    await pumpApp(t);
    await type(t, 'baru');
    expect(find.textContaining('→'), findsOneWidget);
    await t.pump(const Duration(seconds: 7));
    expect(find.textContaining('a.txt  →'), findsNothing);
    expect(find.text('Siap.'), findsOneWidget);
  });

  testWidgets('empty state: tanpa folder dan tanpa duplikat', (t) async {
    await pumpApp(t, openWork: false);
    expect(find.text('Belum ada folder dipilih'), findsOneWidget);
    expect(find.text('Pilih folder untuk mulai.'), findsOneWidget);
  });

  testWidgets('folder tanpa duplikat: pesan kosong dan toggle semua file', (
    t,
  ) async {
    make('sendiri.txt');
    await pumpApp(t);
    expect(find.text('Tidak ada file duplikat di folder ini'), findsOneWidget);
    await t.tap(find.widgetWithText(FilledButton, 'Tampilkan semua file'));
    await settle(t);
    expect(tile('sendiri.txt'), findsWidgets);
  });

  testWidgets('preview teks tampil untuk file .txt', (t) async {
    make('a.txt', 'halo preview');
    make('a (1).txt', 'kedua');
    await pumpApp(t);
    expect(find.text('halo preview'), findsOneWidget);
    await t.tap(find.text('Lewati'));
    await settle(t);
    expect(find.text('kedua'), findsOneWidget);
  });

  testWidgets('tipe tak dikenal menampilkan kartu info', (t) async {
    make('a.xyz');
    make('a (1).xyz');
    await pumpApp(t);
    expect(find.text('Preview tidak tersedia'), findsOneWidget);
    expect(find.text('Buka asli'), findsWidgets);
  });

  testWidgets('dialog pengaturan: ganti tema ke gelap', (t) async {
    await pumpApp(t, openWork: false);
    await t.tap(find.byIcon(Icons.settings_outlined));
    await t.pumpAndSettle();
    expect(find.text('Pengaturan'), findsWidgets);
    await t.tap(find.text('Gelap'));
    await t.pumpAndSettle();
    expect(
      t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    await t.tap(find.text('Tutup'));
    await t.pumpAndSettle();
    expect(find.text('Tema'), findsNothing);
  });
}
