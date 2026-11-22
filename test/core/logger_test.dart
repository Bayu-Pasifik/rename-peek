import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rename_peek/core/logger.dart';

void main() {
  test('menulis baris log dan merotasi file besar', () {
    final tmp = Directory.systemTemp.createTempSync('rp_log_');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final file = File(p.join(tmp.path, 'sub', 'a.log'));
    Log.init(file);
    Log.info('halo');
    Log.error('gagal', StateError('x'));
    final text = file.readAsStringSync();
    expect(text, contains('INFO halo'));
    expect(text, contains('ERROR gagal | Bad state: x'));
    expect(Log.path, file.path);

    file.writeAsStringSync('x' * (1024 * 1024 + 10));
    Log.init(file);
    expect(File('${file.path}.1').existsSync(), isTrue);
    Log.info('baru');
    expect(file.readAsStringSync(), contains('baru'));
  });
}
