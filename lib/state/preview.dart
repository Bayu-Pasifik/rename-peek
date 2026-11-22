import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/office_converter.dart';
import '../domain/doc_file.dart';
import 'providers.dart';

/// Batas teks yang dibaca untuk preview.
const int textPreviewLimit = 200 * 1024;

const imageExts = {'.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'};
const textExts = {'.txt', '.csv', '.json', '.md', '.log', '.xml'};

/// Apa yang harus ditampilkan di panel preview.
sealed class PreviewSpec {
  const PreviewSpec();
}

class PdfPreview extends PreviewSpec {
  const PdfPreview(this.path, {this.fromOffice = false});
  final String path;
  final bool fromOffice;
}

class ImagePreview extends PreviewSpec {
  const ImagePreview(this.path);
  final String path;
}

class TextPreview extends PreviewSpec {
  const TextPreview(this.text, {required this.truncated});
  final String text;
  final bool truncated;
}

/// Kartu info (fallback) dengan alasan mengapa tidak ada preview.
class InfoPreview extends PreviewSpec {
  const InfoPreview(this.reason, {this.officeMissing = false});
  final String reason;
  final bool officeMissing;
}

Future<PreviewSpec> loadPreview(DocFile f, OfficeConverter converter) async {
  final ext = f.extLower;
  if (ext == '.pdf') return PdfPreview(f.path);
  if (imageExts.contains(ext)) return ImagePreview(f.path);
  if (textExts.contains(ext)) {
    try {
      final raf = await File(f.path).open();
      try {
        final bytes = await raf.read(textPreviewLimit);
        final truncated = f.size > textPreviewLimit;
        return TextPreview(_decode(bytes), truncated: truncated);
      } finally {
        await raf.close();
      }
    } on FileSystemException catch (e) {
      return InfoPreview(
        'Tidak bisa membaca file (${e.osError?.message ?? e.message}).',
      );
    }
  }
  if (isOfficeExt(ext)) {
    final r = await converter.convertToPdf(f.path);
    if (r.isOk) return PdfPreview(r.pdfPath!, fromOffice: true);
    return InfoPreview(
      r.error ?? 'Konversi gagal.',
      officeMissing: r.officeMissing,
    );
  }
  return const InfoPreview('Tipe file ini belum punya preview.');
}

String _decode(Uint8List bytes) => utf8.decode(bytes, allowMalformed: true);

/// Preview per file; dihentikan otomatis saat tidak ditonton.
final previewProvider = FutureProvider.autoDispose.family<PreviewSpec, DocFile>(
  (ref, file) {
    return loadPreview(file, ref.watch(servicesProvider).converter);
  },
);
