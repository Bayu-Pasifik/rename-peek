import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';

/// Placeholder Fase 6; diisi lengkap di Fase 7.
class PreviewPanel extends ConsumerWidget {
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.of(context).previewBackdrop,
      alignment: Alignment.center,
      child: const Text(S.selectFile, style: TextStyle(color: Colors.white)),
    );
  }
}
