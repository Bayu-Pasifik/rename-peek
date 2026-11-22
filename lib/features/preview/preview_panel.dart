import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/theme.dart';
import '../../domain/doc_file.dart';
import '../../l10n/strings.dart';
import '../../data/office_converter.dart';
import '../../state/preview.dart';
import '../../state/providers.dart';
import 'info_card.dart';

/// Panel preview: PDF, gambar, teks, hasil konversi Office, atau kartu info.
class PreviewPanel extends ConsumerWidget {
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(browserProvider.select((s) => s.current));
    final backdrop = AppColors.of(context).previewBackdrop;

    if (file == null) {
      return Container(
        color: backdrop,
        alignment: Alignment.center,
        child: const Text(S.selectFile, style: TextStyle(color: Colors.white)),
      );
    }

    final spec = ref.watch(previewProvider(file));
    return Container(
      color: backdrop,
      child: spec.when(
        loading: () => _Loading(office: isOfficeExt(file.extLower)),
        error: (e, _) => InfoCard(file: file, reason: '$e'),
        data: (p) => switch (p) {
          PdfPreview() => PdfPane(
            key: ValueKey(p.path),
            file: file,
            path: p.path,
          ),
          ImagePreview() => _ImagePane(
            key: ValueKey(p.path),
            file: file,
            path: p.path,
          ),
          TextPreview() => _TextPane(spec: p),
          InfoPreview() => InfoCard(file: file, reason: p.reason),
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.office});
  final bool office;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.topCenter,
          child: LinearProgressIndicator(minHeight: 2),
        ),
        if (office)
          const Center(
            child: Text(
              S.preparingPreview,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
      ],
    );
  }
}

/// Viewer PDF dengan fit-width dan tombol zoom melayang.
class PdfPane extends StatefulWidget {
  const PdfPane({super.key, required this.file, required this.path});

  final DocFile file;
  final String path;

  @override
  State<PdfPane> createState() => _PdfPaneState();
}

class _PdfPaneState extends State<PdfPane> {
  final PdfViewerController _controller = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    final backdrop = AppColors.of(context).previewBackdrop;
    return Stack(
      children: [
        PdfViewer.file(
          widget.path,
          controller: _controller,
          params: PdfViewerParams(
            backgroundColor: backdrop,
            layoutStrategy: const SequentialPagesLayout(
              fitMode: PdfFitMode.fill,
            ),
            errorBannerBuilder: (context, error, stack, ref) => InfoCard(
              file: widget.file,
              reason: 'PDF tidak bisa dibuka. File mungkin rusak atau dilindungi password.',
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Perkecil',
                  onPressed: _controller.isReady ? _controller.zoomDown : null,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  tooltip: 'Perbesar',
                  onPressed: _controller.isReady ? _controller.zoomUp : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePane extends StatelessWidget {
  const _ImagePane({super.key, required this.file, required this.path});

  final DocFile file;
  final String path;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.2,
      maxScale: 8,
      child: Center(
        child: Image.file(
          File(path),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              InfoCard(file: file, reason: 'Gambar tidak bisa dibuka.'),
        ),
      ),
    );
  }
}

class _TextPane extends StatelessWidget {
  const _TextPane({required this.spec});
  final TextPreview spec;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 900),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            spec.truncated
                ? '${spec.text}\n\n… (dipotong, buka file asli untuk selengkapnya)'
                : spec.text,
            style: const TextStyle(
              fontFamilyFallback: monoFontFallback,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
