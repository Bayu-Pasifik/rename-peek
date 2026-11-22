import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../state/providers.dart';
import '../preview/preview_panel.dart';
import '../rename/rename_bar.dart';
import 'actions.dart';
import 'file_list.dart';
import 'status_bar.dart';
import 'toolbar.dart';

const double _minList = 220;
const double _maxList = 480;
const double _narrowBreakpoint = 1100;

/// Kerangka utama: toolbar, [daftar | rename + preview], bar status.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FocusNode _nameFocus = FocusNode(debugLabel: 'nameField');
  double? _listWidth;

  @override
  void initState() {
    super.initState();
    // Muat folder terakhir setelah frame pertama.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(browserProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctl = ref.read(browserProvider.notifier);
    final theme = Theme.of(context);

    return Shortcuts(
      shortcuts: appShortcuts,
      child: Actions(
        actions: {
          NextFileIntent: CallbackAction<NextFileIntent>(onInvoke: (_) => ctl.next()),
          PrevFileIntent: CallbackAction<PrevFileIntent>(onInvoke: (_) => ctl.previous()),
          UndoRenameIntent: CallbackAction<UndoRenameIntent>(onInvoke: (_) => ctl.undo()),
          ReloadIntent: CallbackAction<ReloadIntent>(onInvoke: (_) => ctl.reload()),
          PickFolderIntent:
              CallbackAction<PickFolderIntent>(onInvoke: (_) => pickFolder(ref)),
          OpenOriginalIntent:
              CallbackAction<OpenOriginalIntent>(onInvoke: (_) => openOriginal(ref)),
          FocusNameIntent: CallbackAction<FocusNameIntent>(
            onInvoke: (_) {
              _nameFocus.requestFocus();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, box) {
                final narrow = box.maxWidth < _narrowBreakpoint;
                final width = (_listWidth ?? (narrow ? 240.0 : 300.0))
                    .clamp(_minList, _maxList);
                return Column(
                  children: [
                    const Toolbar(),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(key: const ValueKey('listPane'), width: width, child: const FileList()),
                          _Splitter(
                            onDrag: (dx) => setState(() {
                              _listWidth = (width + dx).clamp(_minList, _maxList);
                            }),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                RenameBar(focusNode: _nameFocus),
                                Divider(height: 1, color: theme.colorScheme.outline),
                                const Expanded(child: PreviewPanel()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    const StatusBar(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Pemisah vertikal yang bisa digeser untuk mengubah lebar daftar.
class _Splitter extends StatelessWidget {
  const _Splitter({required this.onDrag});
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).colorScheme.outline;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
        child: SizedBox(
          width: 7,
          child: Center(child: Container(width: 1, color: line)),
        ),
      ),
    );
  }
}
