import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';

/// Membuka dialog pilih folder native lalu memuat folder itu.
Future<void> pickFolder(WidgetRef ref) async {
  final path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Pilih folder');
  if (path != null) {
    await ref.read(browserProvider.notifier).openFolder(path);
  }
}

/// Membuka file aktif dengan aplikasi default Windows.
Future<void> openOriginal(WidgetRef ref) async {
  final f = ref.read(browserProvider).current;
  if (f == null) return;
  await Process.start('explorer.exe', [f.path], mode: ProcessStartMode.detached);
}
