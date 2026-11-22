import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rename_peek/data/office_converter.dart';
import 'package:rename_peek/data/settings_store.dart';
import 'package:rename_peek/data/undo_log.dart';
import 'package:rename_peek/state/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service uji yang memakai folder sementara [root].
Future<AppServices> testServices(
  Directory root, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  return AppServices(
    settings: SettingsStore(await SharedPreferences.getInstance()),
    undoLog: UndoLog(File(p.join(root.path, 'data', 'log.json'))),
    converter: OfficeConverter(
      scriptPath: p.join(
        Directory.current.path,
        'assets',
        'scripts',
        'convert.ps1',
      ),
      cacheDir: Directory(p.join(root.path, 'cache')),
    ),
  );
}
