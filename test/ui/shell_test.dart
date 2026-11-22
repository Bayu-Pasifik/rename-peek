import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rename_peek/app.dart';
import 'package:rename_peek/state/providers.dart';

import '../helpers.dart';

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('rp_ui_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<void> pumpApp(
    WidgetTester t,
    Size size, {
    Map<String, Object> prefs = const {},
  }) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    final s = await testServices(tmp, prefs: prefs);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWithValue(s),
          dropEnabledProvider.overrideWithValue(false),
        ],
        child: const RenamePeekApp(),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('kerangka tampil tanpa overflow pada ukuran minimum (terang)', (
    t,
  ) async {
    await pumpApp(t, const Size(960, 600), prefs: {'themeMode': 'light'});
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('listPane')), findsOneWidget);
  });

  testWidgets('kerangka tampil tanpa overflow pada ukuran minimum (gelap)', (
    t,
  ) async {
    await pumpApp(t, const Size(960, 600), prefs: {'themeMode': 'dark'});
    expect(t.takeException(), isNull);
    expect(
      t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('pemisah menggeser daftar dengan batas 220-480', (t) async {
    await pumpApp(t, const Size(1280, 800));
    final list = find.byKey(const ValueKey('listPane'));
    final splitter = find.byWidgetPredicate(
      (w) => w is MouseRegion && w.cursor == SystemMouseCursors.resizeColumn,
    );
    expect(t.getSize(list).width, 300);
    await t.drag(splitter, const Offset(900, 0));
    await t.pumpAndSettle();
    expect(t.getSize(list).width, 480);
    await t.drag(splitter, const Offset(-900, 0));
    await t.pumpAndSettle();
    expect(t.getSize(list).width, 220);
  });

  testWidgets('lebar jendela sempit memakai daftar 240', (t) async {
    await pumpApp(t, const Size(1000, 700));
    expect(t.getSize(find.byKey(const ValueKey('listPane'))).width, 240);
  });

  test('pintasan terdaftar', () {
    expect(appShortcuts.length, 8);
  });
}
