import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'providers.dart';

/// Mode tema yang tersimpan di pengaturan.
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    switch (ref.read(servicesProvider).settings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode m) async {
    state = m;
    await ref.read(servicesProvider).settings.setThemeMode(switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }
}

final themeModeProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
