import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../state/browser_controller.dart';
import '../../state/providers.dart';

/// Bar status: pesan terakhir (sukses hilang setelah 6 detik) + pengingat pintasan.
class StatusBar extends ConsumerStatefulWidget {
  const StatusBar({
    super.key,
    this.successDuration = const Duration(seconds: 6),
  });

  final Duration successDuration;

  @override
  ConsumerState<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends ConsumerState<StatusBar> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final status = ref.watch(browserProvider.select((s) => s.status));

    ref.listen<StatusMessage?>(browserProvider.select((s) => s.status), (
      prev,
      next,
    ) {
      _timer?.cancel();
      if (next != null && !next.isError) {
        final id = next.id;
        _timer = Timer(widget.successDuration, () {
          if (ref.read(browserProvider).status?.id == id) {
            ref.read(browserProvider.notifier).clearStatus();
          }
        });
      }
    });

    final Color color;
    final IconData? icon;
    if (status == null) {
      color = scheme.onSurfaceVariant;
      icon = null;
    } else if (status.isError) {
      color = colors.warning;
      icon = Icons.warning_amber_rounded;
    } else {
      color = colors.success;
      icon = Icons.check_circle_outline;
    }

    return Container(
      height: 28,
      color: scheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              status?.text ?? S.ready,
              key: const ValueKey('statusText'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            S.shortcutsHint,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
