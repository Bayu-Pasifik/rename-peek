import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/strings.dart';

/// Placeholder Fase 6; diisi lengkap di Fase 7.
class RenameBar extends ConsumerWidget {
  const RenameBar({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(12),
      child: TextField(
        focusNode: focusNode,
        decoration: const InputDecoration(hintText: S.newNameHint),
      ),
    );
  }
}
