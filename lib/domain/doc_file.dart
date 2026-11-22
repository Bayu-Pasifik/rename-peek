import 'name_rules.dart';

/// Satu file di folder yang dipindai.
class DocFile {
  DocFile({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  }) : parsed = parseName(name);

  final String path;
  final String name;
  final int size;
  final DateTime modified;
  final ParsedName parsed;

  String get ext => parsed.ext;
  String get extLower => parsed.ext.toLowerCase();
  String get groupKey => parsed.key;
  int get number => parsed.number;

  @override
  bool operator ==(Object other) =>
      other is DocFile &&
      other.path == path &&
      other.size == size &&
      other.modified == modified;

  @override
  int get hashCode => Object.hash(path, size, modified);
}

/// Kumpulan file dengan nama dasar yang sama.
class DupGroup {
  DupGroup(this.key, this.files);

  final String key;
  final List<DocFile> files;

  bool get isDuplicate => files.length > 1;
}

/// Mengelompokkan [files] per nama dasar.
///
/// Grup diurutkan menurut kunci; isi grup: tanpa angka dulu, lalu angka naik
/// (numerik, bukan alfabet), lalu nama.
List<DupGroup> groupFiles(Iterable<DocFile> files) {
  final map = <String, List<DocFile>>{};
  for (final f in files) {
    map.putIfAbsent(f.groupKey, () => []).add(f);
  }
  final groups = map.entries.map((e) {
    final list = [...e.value]
      ..sort((a, b) {
        final c = a.number.compareTo(b.number);
        return c != 0
            ? c
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return DupGroup(e.key, list);
  }).toList()..sort((a, b) => a.key.compareTo(b.key));
  return groups;
}

/// Daftar datar untuk ditampilkan; [onlyDuplicates] menyembunyikan grup tunggal.
List<DocFile> flattenGroups(
  List<DupGroup> groups, {
  required bool onlyDuplicates,
}) => [
  for (final g in groups)
    if (!onlyDuplicates || g.isDuplicate) ...g.files,
];
