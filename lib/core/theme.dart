import 'package:material_ui/material_ui.dart';

/// Warna tambahan di luar ColorScheme (lihat STYLE.md bagian 3).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.warning,
    required this.previewBackdrop,
  });

  final Color success;
  final Color warning;
  final Color previewBackdrop;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({Color? success, Color? warning, Color? previewBackdrop}) =>
      AppColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        previewBackdrop: previewBackdrop ?? this.previewBackdrop,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      previewBackdrop: Color.lerp(previewBackdrop, other.previewBackdrop, t)!,
    );
  }
}

const _fontFallback = ['Segoe UI Variable Text', 'Segoe UI'];
const monoFontFallback = ['Cascadia Mono', 'Consolas'];

ThemeData _build(Brightness b) {
  final dark = b == Brightness.dark;
  final primary = dark ? const Color(0xFF7AA2FF) : const Color(0xFF2A5BD7);
  final surface = dark ? const Color(0xFF161615) : const Color(0xFFF6F6F4);
  final container = dark ? const Color(0xFF1F1F1E) : const Color(0xFFFFFFFF);
  final outline = dark ? const Color(0xFF33322F) : const Color(0xFFE3E1DB);
  final onSurface = dark ? const Color(0xFFECEBE6) : const Color(0xFF1D1D1B);
  final variant = dark ? const Color(0xFF98958D) : const Color(0xFF77756F);

  final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: b).copyWith(
    primary: primary,
    onPrimary: dark ? const Color(0xFF0B1B44) : Colors.white,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: variant,
    surfaceContainer: container,
    surfaceContainerLow: container,
    surfaceContainerHigh: container,
    outline: outline,
    outlineVariant: outline,
    error: dark ? const Color(0xFFF0A35A) : const Color(0xFFB4540A),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    fontFamilyFallback: _fontFallback,
    dividerColor: outline,
    visualDensity: VisualDensity.compact,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12),
    ).apply(bodyColor: onSurface, displayColor: onSurface),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(32, 36),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: outline),
        minimumSize: const Size(32, 36),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: container,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    extensions: [
      AppColors(
        success: dark ? const Color(0xFF4CC784) : const Color(0xFF1F8A4C),
        warning: dark ? const Color(0xFFF0A35A) : const Color(0xFFB4540A),
        previewBackdrop: dark ? const Color(0xFF0E0E0D) : const Color(0xFF8A8A87),
      ),
    ],
  );
}

final ThemeData lightTheme = _build(Brightness.light);
final ThemeData darkTheme = _build(Brightness.dark);
