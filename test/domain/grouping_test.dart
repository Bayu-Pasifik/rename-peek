import 'package:flutter_test/flutter_test.dart';
import 'package:rename_peek/domain/doc_file.dart';

DocFile f(String n) =>
    DocFile(path: 'C:\\x\\$n', name: n, size: 1, modified: DateTime(2026));

void main() {
  test('mengelompokkan duplikat dan mengurutkan numerik', () {
    final groups = groupFiles([
      f('dokumen (10).pdf'),
      f('dokumen (2).pdf'),
      f('dokumen.pdf'),
      f('dokumen (1).pdf'),
      f('lain.pdf'),
    ]);
    expect(groups.map((g) => g.key), ['dokumen', 'lain']);
    expect(groups.first.files.map((e) => e.name), [
      'dokumen.pdf',
      'dokumen (1).pdf',
      'dokumen (2).pdf',
      'dokumen (10).pdf',
    ]);
    expect(groups.first.isDuplicate, isTrue);
    expect(groups.last.isDuplicate, isFalse);
  });

  test('tipe berbeda dengan nama dasar sama satu grup', () {
    final g = groupFiles([f('a.docx'), f('a (1).pdf')]);
    expect(g.length, 1);
    expect(g.first.files.length, 2);
  });

  test('flatten hanya duplikat vs semua', () {
    final groups = groupFiles([f('a.pdf'), f('a (1).pdf'), f('b.pdf')]);
    expect(flattenGroups(groups, onlyDuplicates: true).length, 2);
    expect(flattenGroups(groups, onlyDuplicates: false).length, 3);
  });

  test('grup dengan satu file bernomor tetap satu grup', () {
    final groups = groupFiles([f('dokumen (1).pdf')]);
    expect(groups.single.key, 'dokumen');
    expect(groups.single.isDuplicate, isFalse);
  });
}
