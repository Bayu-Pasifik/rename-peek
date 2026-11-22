import 'package:flutter_test/flutter_test.dart';
import 'package:rename_peek/domain/name_rules.dart';

void main() {
  group('parseName', () {
    test('nama biasa tanpa suffix', () {
      final p = parseName('dokumen.pdf');
      expect(p.key, 'dokumen');
      expect(p.number, 0);
      expect(p.ext, '.pdf');
    });
    test('suffix dengan spasi dan tanpa spasi', () {
      expect(parseName('dokumen (1).pdf').number, 1);
      expect(parseName('dokumen(2).pdf').number, 2);
      expect(parseName('dokumen (1).pdf').key, 'dokumen');
      expect(parseName('dokumen(2).pdf').key, 'dokumen');
    });
    test('kunci tidak peka huruf besar/kecil', () {
      expect(parseName('Dokumen (1).PDF').key, parseName('dokumen.pdf').key);
    });
    test('kurung bukan suffix angka tidak dibuang', () {
      final p = parseName('laporan (final) v2.pdf');
      expect(p.key, 'laporan (final) v2');
      expect(p.number, 0);
    });
    test('angka dua digit', () => expect(parseName('a (10).pdf').number, 10));
    test('tanpa ekstensi', () {
      final p = parseName('catatan (3)');
      expect(p.ext, '');
      expect(p.key, 'catatan');
      expect(p.number, 3);
    });
    test('file titik di awal bukan ekstensi', () {
      expect(parseName('.gitignore').ext, '');
    });
    test('Unicode dan emoji', () {
      expect(
        parseName('Laporan Keuangan 📄 (2).docx').key,
        'laporan keuangan 📄',
      );
    });
  });

  group('sanitizeName', () {
    test('membuang karakter ilegal', () {
      expect(sanitizeName('Laporan: A/B?*.pdf', '.pdf').name, 'Laporan AB');
    });
    test('merapikan spasi ganda dan tepi', () {
      expect(sanitizeName('  a    b  ', '.pdf').name, 'a b');
    });
    test('titik dan spasi di akhir dibuang', () {
      expect(sanitizeName('nama. . ', '.pdf').name, 'nama');
    });
    test('ekstensi yang sama tidak digandakan', () {
      expect(sanitizeName('a.PDF', '.pdf').name, 'a');
      expect(sanitizeName('a.pdf.pdf', '.pdf').name, 'a');
    });
    test('ekstensi berbeda dipertahankan sebagai bagian nama', () {
      expect(sanitizeName('v1.2', '.pdf').name, 'v1.2');
    });
    test('kosong atau hanya ekstensi ditolak', () {
      expect(sanitizeName('', '.pdf').isOk, isFalse);
      expect(sanitizeName('   ', '.pdf').isOk, isFalse);
      expect(sanitizeName('.pdf', '.pdf').isOk, isFalse);
      expect(sanitizeName('<>:', '.pdf').isOk, isFalse);
    });
    test('nama reserved Windows ditolak', () {
      for (final n in ['CON', 'nul', 'Com1', 'LPT9', 'aux.txt']) {
        expect(sanitizeName(n, '.pdf').isOk, isFalse, reason: n);
      }
      expect(sanitizeName('console', '.pdf').isOk, isTrue);
    });
    test('Unicode dipertahankan', () {
      expect(
        sanitizeName('Surat Pajak 2024 😀', '.pdf').name,
        'Surat Pajak 2024 😀',
      );
    });
  });

  group('uniqueName', () {
    test('tidak bentrok', () {
      expect(uniqueName(['a.pdf'], 'b', '.pdf'), 'b.pdf');
    });
    test('bentrok menambah (1), (2)', () {
      expect(uniqueName(['a.pdf'], 'a', '.pdf'), 'a (1).pdf');
      expect(uniqueName(['a.pdf', 'a (1).pdf'], 'a', '.pdf'), 'a (2).pdf');
    });
    test('tidak peka huruf besar/kecil', () {
      expect(uniqueName(['A.PDF'], 'a', '.pdf'), 'a (1).pdf');
    });
  });
}
