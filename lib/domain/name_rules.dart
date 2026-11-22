/// Fungsi murni untuk membaca dan membersihkan nama file.
library;

final RegExp _dupSuffix = RegExp(r'\s*\((\d+)\)$');
final RegExp _illegalChars = RegExp(r'[<>:"/\\|?*\x00-\x1f]');
final RegExp _manySpaces = RegExp(r'\s+');
final RegExp _trailing = RegExp(r'[. ]+$');
final RegExp _reserved = RegExp(
  r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])$',
  caseSensitive: false,
);

/// Batas panjang path Windows (MAX_PATH 260 termasuk terminator).
const int maxPathLength = 259;

/// Hasil pembacaan sebuah nama file.
class ParsedName {
  const ParsedName({
    required this.base,
    required this.ext,
    required this.key,
    required this.number,
  });

  /// Nama tanpa ekstensi (suffix duplikat masih ada).
  final String base;

  /// Ekstensi termasuk titik, atau string kosong.
  final String ext;

  /// Kunci grup: nama dasar tanpa suffix ` (n)`, huruf kecil.
  final String key;

  /// Angka dari suffix ` (n)`; 0 bila tidak ada.
  final int number;
}

/// Memisahkan nama file menjadi nama dasar dan ekstensi.
///
/// Titik di awal nama (`.gitignore`) tidak dianggap pemisah ekstensi.
({String base, String ext}) splitExtension(String fileName) {
  final i = fileName.lastIndexOf('.');
  if (i <= 0) return (base: fileName, ext: '');
  return (base: fileName.substring(0, i), ext: fileName.substring(i));
}

ParsedName parseName(String fileName) {
  final parts = splitExtension(fileName);
  final m = _dupSuffix.firstMatch(parts.base);
  final stripped = m == null ? parts.base : parts.base.substring(0, m.start);
  return ParsedName(
    base: parts.base,
    ext: parts.ext,
    key: stripped.trim().toLowerCase(),
    number: m == null ? 0 : int.parse(m.group(1)!),
  );
}

/// Hasil sanitasi nama masukan pengguna.
class SanitizeResult {
  const SanitizeResult.ok(String this.name) : error = null;
  const SanitizeResult.fail(String this.error) : name = null;

  /// Nama dasar bersih (tanpa ekstensi), null bila gagal.
  final String? name;

  /// Pesan error untuk pengguna, null bila sukses.
  final String? error;

  bool get isOk => name != null;
}

String _clean(String s) => s
    .replaceAll(_illegalChars, '')
    .replaceAll(_manySpaces, ' ')
    .trim()
    .replaceAll(_trailing, '');

/// Membersihkan [input] menjadi nama dasar yang aman untuk Windows.
///
/// [ext] adalah ekstensi asli file (dengan titik). Bila pengguna sudah
/// mengetik ekstensi itu, tidak digandakan.
SanitizeResult sanitizeName(String input, String ext) {
  var s = _clean(input);
  if (ext.isNotEmpty) {
    final lowExt = ext.toLowerCase();
    while (s.toLowerCase().endsWith(lowExt) && s.length > lowExt.length) {
      s = _clean(s.substring(0, s.length - ext.length));
    }
    if (s.toLowerCase() == lowExt) s = '';
  }
  if (s.isEmpty) {
    return const SanitizeResult.fail('Nama baru tidak boleh kosong.');
  }
  final firstPart = s.split('.').first;
  if (_reserved.hasMatch(firstPart)) {
    return SanitizeResult.fail(
      '"$firstPart" adalah nama yang dilarang Windows.',
    );
  }
  return SanitizeResult.ok(s);
}

/// Mengembalikan nama file unik di antara [existingNames].
///
/// Perbandingan tidak membedakan huruf besar/kecil (seperti NTFS). Bila
/// bentrok, ditambah ` (1)`, ` (2)`, dan seterusnya sebelum ekstensi.
String uniqueName(Iterable<String> existingNames, String base, String ext) {
  final taken = existingNames.map((e) => e.toLowerCase()).toSet();
  var candidate = '$base$ext';
  var i = 0;
  while (taken.contains(candidate.toLowerCase())) {
    i++;
    candidate = '$base ($i)$ext';
    if (i > 9999) throw StateError('Terlalu banyak nama bentrok');
  }
  return candidate;
}
