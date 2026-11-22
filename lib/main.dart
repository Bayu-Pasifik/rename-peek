// ignore_for_file: deprecated_member_use

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:window_manager/legacy.dart';

import 'app.dart';
import 'core/logger.dart';
import 'state/providers.dart';
import 'state/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdfrxFlutterInitialize();
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(960, 600),
    center: true,
    title: 'Rename Peek',
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  final services = await AppServices.bootstrap();
  FlutterError.onError = (d) => Log.error('FlutterError', d.exception, d.stack);
  PlatformDispatcher.instance.onError = (e, st) {
    Log.error('Error tak tertangani', e, st);
    return true;
  };
  runApp(
    ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const RenamePeekApp(),
    ),
  );
}
