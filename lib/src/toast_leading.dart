import 'package:flutter/material.dart';

/// Controls the leading visual of a toast.
///
/// Defaults to [ToastLeading.none]. Use [ToastLeading.icon], [ToastLeading.image],
/// or [ToastLeading.appIcon] to explicitly render a leading visual.
sealed class ToastLeading {
  const ToastLeading();

  /// Do not render any leading visual.
  const factory ToastLeading.none() = ToastLeadingNone;

  /// Render an asset image at [assetPath].
  const factory ToastLeading.image(String assetPath) = ToastLeadingImage;

  /// Render an [IconData] with optional [color] and [size].
  const factory ToastLeading.icon(
    IconData icon, {
    Color? color,
    double? size,
  }) = ToastLeadingIcon;

  /// Render the native launcher/app icon by default.
  ///
  /// If `SnapToast.init(defaultIconAsset: ...)` is set, that asset is used as
  /// an override. Falls back to the variant icon when no app icon can be
  /// resolved.
  const factory ToastLeading.appIcon() = ToastLeadingAppIcon;
}

class ToastLeadingNone extends ToastLeading {
  const ToastLeadingNone();
}

class ToastLeadingImage extends ToastLeading {
  final String assetPath;
  const ToastLeadingImage(this.assetPath);
}

class ToastLeadingIcon extends ToastLeading {
  final IconData icon;
  final Color? color;
  final double? size;
  const ToastLeadingIcon(this.icon, {this.color, this.size});
}

class ToastLeadingAppIcon extends ToastLeading {
  const ToastLeadingAppIcon();
}
