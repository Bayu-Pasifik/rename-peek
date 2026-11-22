import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../domain/doc_file.dart';
import '../../l10n/strings.dart';
import '../browser/actions.dart';

IconData iconForExt(String ext) {
  switch (ext) {
    case '.pdf':
      return Icons.picture_as_pdf_outlined;
    case '.doc':
    case '.docx':
    case '.rtf':
    case '.odt':
      return Icons.description_outlined;
    case '.xls':
    case '.xlsx':
    case '.xlsm':
    case '.ods':
    case '.csv':
      return Icons.table_chart_outlined;
    case '.ppt':
    case '.pptx':
    case '.odp':
      return Icons.slideshow_outlined;
    case '.png':
    case '.jpg':
    case '.jpeg':
    case '.gif':
    case '.webp':
    case '.bmp':
      return Icons.image_outlined;
    default:
      return Icons.insert_drive_file_outlined;
  }
}

/// Kartu fallback: ikon tipe file, info dasar, alasan, dan tombol "Buka asli".
class InfoCard extends ConsumerWidget {
  const InfoCard({
    super.key,
    required this.file,
    required this.reason,
    this.title,
  });

  final DocFile file;
  final String reason;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconForExt(file.extLower),
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title ?? S.noPreviewTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              file.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${formatSize(file.size)} · ${formatDate(file.modified)}',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => openOriginal(ref),
              child: const Text(S.openOriginal),
            ),
          ],
        ),
      ),
    );
  }
}
