import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme.dart';
import 'features/browser/home_page.dart';
import 'l10n/strings.dart';
import 'state/theme_controller.dart';

class RenamePeekApp extends ConsumerWidget {
  const RenamePeekApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ref.watch(themeModeProvider),
      home: const HomePage(),
    );
  }
}

// ---- Intent untuk pintasan keyboard (STYLE.md bagian 6) ----

class NextFileIntent extends Intent {
  const NextFileIntent();
}

class PrevFileIntent extends Intent {
  const PrevFileIntent();
}

class UndoRenameIntent extends Intent {
  const UndoRenameIntent();
}

class ReloadIntent extends Intent {
  const ReloadIntent();
}

class PickFolderIntent extends Intent {
  const PickFolderIntent();
}

class OpenOriginalIntent extends Intent {
  const OpenOriginalIntent();
}

class FocusNameIntent extends Intent {
  const FocusNameIntent();
}

/// Peta pintasan. Shortcut ini kalah dari TextField yang sedang fokus
/// (mis. Ctrl+Z di dalam input tetap undo teks, bukan undo rename).
final Map<ShortcutActivator, Intent> appShortcuts = {
  const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true): const NextFileIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true): const PrevFileIntent(),
  const SingleActivator(LogicalKeyboardKey.keyZ, control: true): const UndoRenameIntent(),
  const SingleActivator(LogicalKeyboardKey.f5): const ReloadIntent(),
  const SingleActivator(LogicalKeyboardKey.keyO, control: true): const PickFolderIntent(),
  const SingleActivator(LogicalKeyboardKey.enter, control: true): const OpenOriginalIntent(),
  const SingleActivator(LogicalKeyboardKey.keyL, control: true): const FocusNameIntent(),
  const SingleActivator(LogicalKeyboardKey.escape): const FocusNameIntent(),
};
