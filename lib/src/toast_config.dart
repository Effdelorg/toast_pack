import 'toast_enums.dart';

/// Global configuration set via `SnapToast.init(...)`.
class SnapToastConfig {
  static String? defaultIconAsset;
  static ReplacementMode replacementMode = ReplacementMode.instantReplace;

  /// Exposed for tests.
  static void reset() {
    defaultIconAsset = null;
    replacementMode = ReplacementMode.instantReplace;
  }
}
