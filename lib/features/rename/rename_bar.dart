import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/strings.dart';
import '../../state/providers.dart';
import '../browser/actions.dart';

/// Bar di atas preview: nama file aktif, input nama baru, tombol aksi.
class RenameBar extends ConsumerStatefulWidget {
  const RenameBar({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  ConsumerState<RenameBar> createState() => _RenameBarState();
}

class _RenameBarState extends ConsumerState<RenameBar> {
  final TextEditingController _text = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final value = _text.text.trim();
    if (value.isEmpty) {
      setState(() => _error = S.emptyNameError);
      widget.focusNode.requestFocus();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ref.read(browserProvider.notifier).save(value);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ctl = ref.read(browserProvider.notifier);
    final current = ref.watch(browserProvider.select((s) => s.current));
    final index = ref.watch(browserProvider.select((s) => s.index));
    final total = ref.watch(browserProvider.select((s) => s.view.length));

    // Setiap pindah file: kosongkan input dan kembalikan fokus ke sana.
    ref.listen(browserProvider.select((s) => s.current?.path), (prev, next) {
      if (prev == next) return;
      _text.clear();
      if (_error != null) setState(() => _error = null);
      // Tunda: saat folder baru dimuat, input masih disabled sampai frame ini selesai.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.focusNode.requestFocus();
      });
    });

    final enabled = current != null;
    return Container(
      color: scheme.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  current?.name ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (enabled)
                Text(
                  S.position(index + 1, total),
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  focusNode: widget.focusNode,
                  enabled: enabled,
                  autofocus: true,
                  onSubmitted: (_) => _submit(),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: S.newNameHint,
                    errorText: _error,
                    suffixText: current?.ext,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: enabled && !_busy ? _submit : null,
                child: const Text(S.saveNext),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: enabled ? ctl.next : null,
                child: const Text(S.skip),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: enabled ? () => openOriginal(ref) : null,
                child: const Text(S.openOriginal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
