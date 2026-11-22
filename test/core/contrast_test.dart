import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rename_peek/core/theme.dart';

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final l1 = _lum(a), l2 = _lum(b);
  final hi = math.max(l1, l2), lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final entry in {'terang': lightTheme, 'gelap': darkTheme}.entries) {
    group('kontras WCAG AA (${entry.key})', () {
      final t = entry.value;
      final s = t.colorScheme;
      final x = t.extension<AppColors>()!;
      void atLeast(String name, Color fg, Color bg, [double min = 4.5]) {
        test(name, () {
          final c = contrast(fg, bg);
          expect(
            c,
            greaterThanOrEqualTo(min),
            reason: '$name = ${c.toStringAsFixed(2)}',
          );
        });
      }

      atLeast('teks utama di panel', s.onSurface, s.surfaceContainer);
      atLeast('teks utama di latar', s.onSurface, s.surface);
      atLeast('teks sekunder di panel', s.onSurfaceVariant, s.surfaceContainer);
      atLeast(
        'teks sekunder di latar (header grup)',
        s.onSurfaceVariant,
        s.surface,
      );
      atLeast('aksen sebagai teks di panel', s.primary, s.surfaceContainer);
      atLeast('teks tombol utama', s.onPrimary, s.primary);
      atLeast('sukses di panel', x.success, s.surfaceContainer);
      atLeast('peringatan di panel', x.warning, s.surfaceContainer);
      atLeast(
        'teks di atas backdrop preview',
        previewForeground(x.previewBackdrop),
        x.previewBackdrop,
      );
    });
  }
}
