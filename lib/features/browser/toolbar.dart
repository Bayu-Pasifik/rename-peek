import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/strings.dart';
import '../../state/providers.dart';
import '../settings/settings_dialog.dart';
import 'actions.dart';

/// Toolbar atas: folder, muat ulang, tampilkan semua, undo, pengaturan.
class Toolbar extends ConsumerWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(browserProvider);
    final ctl = ref.read(browserProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      color: scheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: '${S.chooseFolder} (Ctrl+O)',
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => pickFolder(ref),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.dir ?? S.noFolder,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: s.dir == null
                                ? scheme.onSurfaceVariant
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: '${S.reload} (F5)',
            onPressed: s.dir == null ? null : ctl.reload,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
          Semantics(
            label: S.showAll,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => ctl.setShowAll(!s.showAll),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: s.showAll,
                      onChanged: (v) => ctl.setShowAll(v ?? false),
                    ),
                    Text(
                      S.showAll,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          OutlinedButton.icon(
            onPressed: s.canUndo ? ctl.undo : null,
            icon: const Icon(Icons.undo, size: 18),
            label: const Text(S.undo),
          ),
          IconButton(
            tooltip: S.settings,
            onPressed: () => showSettingsDialog(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}
