import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../domain/doc_file.dart';
import '../../l10n/strings.dart';
import '../../state/providers.dart';
import 'actions.dart';

const double _headerH = 28;
const double _itemH = 36;

/// Daftar file di kiri, dikelompokkan per nama dasar dengan header menempel.
class FileList extends ConsumerStatefulWidget {
  const FileList({super.key});

  @override
  ConsumerState<FileList> createState() => _FileListState();
}

class _FileListState extends ConsumerState<FileList> {
  final ScrollController _scroll = ScrollController();
  int _lastIndex = -1;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Offset vertikal item ke-[index] pada daftar [groups] (header ikut dihitung).
  double _offsetOf(List<DupGroup> groups, int index) {
    var y = 0.0;
    var i = 0;
    for (final g in groups) {
      y += _headerH;
      for (final _ in g.files) {
        if (i == index) return y;
        y += _itemH;
        i++;
      }
    }
    return y;
  }

  void _ensureVisible(double offset) {
    if (!_scroll.hasClients) return;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final dur = reduce ? Duration.zero : const Duration(milliseconds: 120);
    final pos = _scroll.position;
    if (offset - _headerH < pos.pixels) {
      _scroll.animateTo(
        (offset - _headerH).clamp(0, pos.maxScrollExtent),
        duration: dur,
        curve: Curves.easeOut,
      );
    } else if (offset + _itemH > pos.pixels + pos.viewportDimension) {
      _scroll.animateTo(
        (offset + _itemH - pos.viewportDimension).clamp(0, pos.maxScrollExtent),
        duration: dur,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(browserProvider);
    final ctl = ref.read(browserProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final groups = s.groups.where((g) => s.showAll || g.isDuplicate).toList();
    final total = s.view.length;

    Widget body;
    if (s.dir == null) {
      body = _Empty(
        icon: Icons.folder_open,
        title: S.emptyNoFolder,
        actions: [
          FilledButton(
            onPressed: () => pickFolder(ref),
            child: const Text(S.chooseFolder),
          ),
        ],
      );
    } else if (s.loading && s.files.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (total == 0) {
      body = _Empty(
        icon: Icons.check_circle_outline,
        title: S.emptyTitle,
        hint: S.emptyHint,
        actions: [
          FilledButton(
            onPressed: () => ctl.setShowAll(true),
            child: const Text(S.showAll),
          ),
          OutlinedButton(
            onPressed: () => pickFolder(ref),
            child: const Text(S.pickOtherFolder),
          ),
        ],
      );
    } else {
      if (_lastIndex != s.index) {
        _lastIndex = s.index;
        final target = _offsetOf(groups, s.index);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensureVisible(target),
        );
      }
      final starts = <int>[];
      var acc = 0;
      for (final g in groups) {
        starts.add(acc);
        acc += g.files.length;
      }
      body = CustomScrollView(
        controller: _scroll,
        slivers: [
          for (var gi = 0; gi < groups.length; gi++)
            SliverMainAxisGroup(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HeaderDelegate(
                    S.groupHeader(groups[gi].key, groups[gi].files.length),
                  ),
                ),
                SliverList.builder(
                  itemCount: groups[gi].files.length,
                  itemBuilder: (context, i) {
                    final index = starts[gi] + i;
                    return _FileTile(
                      file: groups[gi].files[i],
                      selected: index == s.index,
                      position: index + 1,
                      total: total,
                      onTap: () => ctl.select(index),
                    );
                  },
                ),
              ],
            ),
        ],
      );
    }

    return Container(color: scheme.surfaceContainer, child: body);
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate(this.text);
  final String text;

  @override
  double get minExtent => _headerH;
  @override
  double get maxExtent => _headerH;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.44,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_HeaderDelegate old) => old.text != text;
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.file,
    required this.selected,
    required this.position,
    required this.total,
    required this.onTap,
  });

  final DocFile file;
  final bool selected;
  final int position;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      label: '${file.name}, ${formatSize(file.size)}, $position dari $total',
      child: Tooltip(
        message: file.name,
        waitDuration: const Duration(milliseconds: 600),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: _itemH,
            padding: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
              color: selected ? scheme.primary.withValues(alpha: 0.14) : null,
              border: Border(
                left: BorderSide(
                  color: selected ? scheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(file.name, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Text(
                  formatSize(file.size),
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    this.hint,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String? hint;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 16),
            for (final a in actions)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: a),
          ],
        ),
      ),
    );
  }
}
