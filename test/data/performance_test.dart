import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rename_peek/data/folder_scanner.dart';
import 'package:rename_peek/domain/doc_file.dart';

void main() {
  test('2.000 file: scan + pengelompokan di bawah 1 detik', () async {
    final tmp = Directory.systemTemp.createTempSync('rp_perf_');
    addTearDown(() => tmp.deleteSync(recursive: true));
    for (var g = 0; g < 200; g++) {
      for (var i = 0; i < 10; i++) {
        final name = i == 0 ? 'dokumen$g.pdf' : 'dokumen$g ($i).pdf';
        File(p.join(tmp.path, name)).writeAsStringSync('x');
      }
    }
    final sw = Stopwatch()..start();
    final files = await const FolderScanner().scan(tmp.path);
    final groups = groupFiles(files);
    final view = flattenGroups(groups, onlyDuplicates: true);
    sw.stop();
    expect(files.length, 2000);
    expect(groups.length, 200);
    expect(view.length, 2000);
    expect(
      sw.elapsedMilliseconds,
      lessThan(1000),
      reason: '${sw.elapsedMilliseconds} ms',
    );
  });
}
