import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/logger.dart';
import '../../l10n/strings.dart';
import '../../state/providers.dart';
import '../../state/theme_controller.dart';

Future<void> showSettingsDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const SettingsDialog());

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  late Future<int> _cacheSize;

  @override
  void initState() {
    super.initState();
    _cacheSize = ref.read(servicesProvider).converter.cacheSize();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    final showAll = ref.watch(browserProvider.select((s) => s.showAll));
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                S.settings,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              const Text(S.themeLabel),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(S.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(S.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(S.themeDark),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (v) =>
                    ref.read(themeModeProvider.notifier).set(v.first),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(S.showAllDefault),
                value: showAll,
                onChanged: (v) =>
                    ref.read(browserProvider.notifier).setShowAll(v),
              ),
              const SizedBox(height: 8),
              FutureBuilder<int>(
                future: _cacheSize,
                builder: (context, snap) => Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        await ref.read(servicesProvider).converter.clearCache();
                        setState(() {
                          _cacheSize = ref
                              .read(servicesProvider)
                              .converter
                              .cacheSize();
                        });
                      },
                      child: const Text(S.clearCache),
                    ),
                    Text(
                      snap.hasData ? formatSize(snap.data!) : '',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (Log.path != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Berkas log',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SelectableText(Log.path!, style: const TextStyle(fontSize: 12)),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(S.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
