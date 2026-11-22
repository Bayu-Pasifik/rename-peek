import 'package:shared_preferences/shared_preferences.dart';

/// Preferensi pengguna yang disimpan lokal.
class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kFolder = 'lastFolder';
  static const _kTheme = 'themeMode';
  static const _kShowAll = 'showAll';

  String? get lastFolder => _prefs.getString(_kFolder);
  Future<void> setLastFolder(String v) => _prefs.setString(_kFolder, v);

  /// 'system' | 'light' | 'dark'
  String get themeMode => _prefs.getString(_kTheme) ?? 'system';
  Future<void> setThemeMode(String v) => _prefs.setString(_kTheme, v);

  bool get showAll => _prefs.getBool(_kShowAll) ?? false;
  Future<void> setShowAll(bool v) => _prefs.setBool(_kShowAll, v);
}
