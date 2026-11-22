import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/folder_scanner.dart';
import '../data/office_converter.dart';
import '../data/rename_service.dart';
import '../data/settings_store.dart';
import '../data/undo_log.dart';

/// Kumpulan service aplikasi; dibuat sekali saat start (atau di tes).
class AppServices {
  AppServices({
    required this.settings,
    required this.undoLog,
    required this.converter,
    this.scanner = const FolderScanner(),
  }) : renamer = RenameService(undoLog);

  final SettingsStore settings;
  final UndoLog undoLog;
  final OfficeConverter converter;
  final FolderScanner scanner;
  final RenameService renamer;

  /// Membuat service nyata: folder data aplikasi, cache temp, skrip konversi.
  static Future<AppServices> bootstrap() async {
    final support = await getApplicationSupportDirectory();
    await support.create(recursive: true);
    final prefs = await SharedPreferences.getInstance();

    // Skrip diekstrak ke disk karena PowerShell butuh path file nyata.
    // BOM UTF-8 agar PowerShell 5.1 membaca skrip dengan benar.
    final script = File(p.join(support.path, 'convert.ps1'));
    final text = await rootBundle.loadString('assets/scripts/convert.ps1');
    await script.writeAsString('﻿$text', flush: true);

    final converter = OfficeConverter(
      scriptPath: script.path,
      cacheDir: Directory(p.join(Directory.systemTemp.path, 'rename-peek-cache')),
    );
    await converter.trimCache();
    return AppServices(
      settings: SettingsStore(prefs),
      undoLog: UndoLog(File(p.join(support.path, 'rename-log.json'))),
      converter: converter,
    );
  }
}
