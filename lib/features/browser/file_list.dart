import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/strings.dart';

/// Placeholder Fase 6; diisi lengkap di Fase 7.
class FileList extends ConsumerWidget {
  const FileList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      alignment: Alignment.center,
      child: const Text(S.emptyNoFolder),
    );
  }
}
