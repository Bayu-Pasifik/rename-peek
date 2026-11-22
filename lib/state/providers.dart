import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'browser_controller.dart';
import 'services.dart';

/// Wajib di-override saat start (lihat main.dart) dan di tes.
final servicesProvider = Provider<AppServices>(
  (ref) => throw UnimplementedError('servicesProvider belum di-override'),
);

final browserProvider =
    NotifierProvider<BrowserController, BrowserState>(BrowserController.new);
