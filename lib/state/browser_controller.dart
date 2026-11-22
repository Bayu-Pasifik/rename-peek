import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logger.dart';
import '../data/folder_scanner.dart';
import '../data/office_converter.dart';
import '../domain/doc_file.dart';
import 'preview.dart';
import 'providers.dart';
import 'services.dart';

/// Pesan di bar status.
class StatusMessage {
  const StatusMessage(this.text, {this.isError = false, this.id = 0});
  final String text;
  final bool isError;

  /// Naik tiap pesan baru; dipakai UI untuk mengatur timer hilang otomatis.
  final int id;
}

class BrowserState {
  BrowserState({
    this.dir,
    this.files = const [],
    this.showAll = false,
    this.index = 0,
    this.loading = false,
    this.canUndo = false,
    this.status,
  });

  final String? dir;
  final List<DocFile> files;
  final bool showAll;
  final int index;
  final bool loading;
  final bool canUndo;
  final StatusMessage? status;

  /// Dihitung sekali per state (daftar bisa ribuan file).
  late final List<DupGroup> groups = groupFiles(files);

  /// Daftar yang tampil di panel kiri (duplikat saja, atau semua).
  late final List<DocFile> view = flattenGroups(
    groups,
    onlyDuplicates: !showAll,
  );

  DocFile? get current {
    final v = view;
    return index >= 0 && index < v.length ? v[index] : null;
  }

  BrowserState copyWith({
    String? dir,
    List<DocFile>? files,
    bool? showAll,
    int? index,
    bool? loading,
    bool? canUndo,
    StatusMessage? status,
    bool clearStatus = false,
  }) => BrowserState(
    dir: dir ?? this.dir,
    files: files ?? this.files,
    showAll: showAll ?? this.showAll,
    index: index ?? this.index,
    loading: loading ?? this.loading,
    canUndo: canUndo ?? this.canUndo,
    status: clearStatus ? null : (status ?? this.status),
  );
}

class BrowserController extends Notifier<BrowserState> {
  int _statusId = 0;

  AppServices get _s => ref.read(servicesProvider);

  @override
  BrowserState build() => BrowserState(showAll: _s.settings.showAll);

  StatusMessage _msg(String text, {bool isError = false}) =>
      StatusMessage(text, isError: isError, id: ++_statusId);

  /// Memuat folder terakhir dari pengaturan (bila ada).
  Future<void> init() async {
    final last = _s.settings.lastFolder;
    state = state.copyWith(canUndo: await _s.undoLog.canUndo);
    if (last != null) await openFolder(last);
  }

  Future<void> openFolder(String path) async {
    state = state.copyWith(
      dir: path,
      index: 0,
      loading: true,
      clearStatus: true,
    );
    await _scan();
    if (state.status == null || !state.status!.isError) {
      await _s.settings.setLastFolder(path);
    }
  }

  Future<void> reload() async {
    if (state.dir == null) return;
    final keep = state.current?.name;
    state = state.copyWith(loading: true);
    await _scan(select: keep);
  }

  /// Memindai ulang; [select] = nama file yang ingin tetap dipilih.
  Future<void> _scan({String? select}) async {
    final dir = state.dir;
    if (dir == null) return;
    try {
      final files = await _s.scanner.scan(dir);
      final canUndo = await _s.undoLog.canUndo;
      var next = state.copyWith(files: files, loading: false, canUndo: canUndo);
      var idx = next.index;
      if (select != null) {
        final i = next.view.indexWhere((f) => f.name == select);
        if (i >= 0) idx = i;
      }
      final len = next.view.length;
      idx = len == 0 ? 0 : idx.clamp(0, len - 1);
      state = next.copyWith(index: idx);
      _prefetchNext();
    } on ScanException catch (e) {
      state = state.copyWith(
        files: const [],
        loading: false,
        index: 0,
        status: _msg(e.message, isError: true),
      );
    }
  }

  void setShowAll(bool v) {
    _s.settings.setShowAll(v);
    state = state.copyWith(showAll: v, index: 0);
    _prefetchNext();
  }

  void select(int i) {
    final len = state.view.length;
    if (len == 0) return;
    state = state.copyWith(index: i.clamp(0, len - 1));
    _prefetchNext();
  }

  void next() => select(state.index + 1);
  void previous() => select(state.index - 1);

  /// Rename file aktif; bila sukses, pindah ke file berikutnya.
  /// Mengembalikan pesan error (null bila sukses) agar UI bisa menampilkannya inline.
  Future<String?> save(String input) async {
    final f = state.current;
    final dir = state.dir;
    if (f == null || dir == null) return 'Tidak ada file yang dipilih.';

    final view = state.view;
    final following = state.index + 1 < view.length
        ? view[state.index + 1].name
        : null;

    final r = await _s.renamer.rename(file: f, input: input, rootDir: dir);
    if (!r.isOk) {
      Log.error('Rename gagal: ${f.name} | ${r.error}');
      state = state.copyWith(status: _msg(r.error!, isError: true));
      return r.error;
    }
    state = state.copyWith(status: _msg('✓ ${r.oldName}  →  ${r.newName}'));
    await _scan(select: following);
    return null;
  }

  Future<void> undo() async {
    final r = await _s.undoLog.undoLast();
    if (!r.isOk) {
      state = state.copyWith(status: _msg(r.error!, isError: true));
      return;
    }
    final e = r.entry!;
    state = state.copyWith(
      status: _msg('↶ Dikembalikan: ${e.to}  →  ${e.from}'),
    );
    // Undo bisa terjadi di folder lain dari yang sedang dibuka.
    await _scan(select: e.from);
  }

  void clearStatus() => state = state.copyWith(clearStatus: true);

  /// Siapkan preview file berikutnya (terutama konversi Office yang lambat).
  void _prefetchNext() {
    final v = state.view;
    final i = state.index + 1;
    // Hanya file aktif dan berikutnya yang layak dikonversi; sisanya basi.
    _s.converter.setWanted({
      if (state.current != null) state.current!.path,
      if (i < v.length) v[i].path,
    });
    if (i >= v.length) return;
    final f = v[i];
    if (!isOfficeExt(f.extLower)) return;
    // Memanggil .future memulai konversi dan mengisi cache disk.
    ref.read(previewProvider(f).future).then((_) {}, onError: (Object _) {});
  }
}
