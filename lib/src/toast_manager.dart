import 'package:flutter/widgets.dart';

import 'toast_config.dart';
import 'toast_enums.dart';
import 'toast_widget.dart';

/// Manages the single active toast OverlayEntry. Handles replacement + dismiss.
class ToastManager {
  ToastManager._();
  static final ToastManager instance = ToastManager._();

  OverlayEntry? _current;
  GlobalKey<ToastWidgetState>? _currentKey;

  void show(
    BuildContext? context,
    ResolvedToastConfig cfg, {
    OverlayState? overlayState,
  }) {
    final overlay =
        overlayState ??
        (context == null ? null : Overlay.maybeOf(context, rootOverlay: true));
    if (overlay == null) {
      // PRD §14: "Invalid context → safely handled".
      return;
    }

    final previous = _current;
    final previousKey = _currentKey;

    final key = GlobalKey<ToastWidgetState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) =>
          ToastWidget(key: key, cfg: cfg, onDismissed: () => _remove(entry)),
    );

    _current = entry;
    _currentKey = key;

    if (previous != null) {
      switch (ToastPackConfig.replacementMode) {
        case ReplacementMode.instantReplace:
          _safeRemove(previous);
          overlay.insert(entry);
          break;
        case ReplacementMode.gracefulCrossfade:
          previousKey?.currentState?.dismiss();
          overlay.insert(entry);
          break;
      }
    } else {
      overlay.insert(entry);
    }
  }

  /// Dismiss the currently visible toast (if any) with its exit animation.
  void dismiss() {
    _currentKey?.currentState?.dismiss();
  }

  void _remove(OverlayEntry entry) {
    _safeRemove(entry);
    if (identical(_current, entry)) {
      _current = null;
      _currentKey = null;
    }
  }

  /// `OverlayEntry.mounted` only flips to true once the entry's widget has
  /// built for the first time. Between a synchronous insert + replace call,
  /// the old entry is queued in the overlay but `mounted` is still false —
  /// so guarding on `mounted` skips a real removal. Try the call directly and
  /// swallow the "already removed" path.
  void _safeRemove(OverlayEntry entry) {
    try {
      entry.remove();
    } catch (_) {
      // Entry was already detached (double-remove, or overlay torn down).
    }
  }
}
