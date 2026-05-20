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
  const factory ToastLeading.image(
    String assetPath, {
    Color? color,
    double heightPercentage,
    double widthPercentage,
  }) = ToastLeadingImage;

  /// Render an [IconData] with optional [color] and [size].
  const factory ToastLeading.icon(
    IconData icon, {
    Color? color,
    double? size,
  }) = ToastLeadingIcon;

  /// Render the native launcher/app icon by default.
  ///
  /// If `ToastPack.init(defaultIconAsset: ...)` is set, that asset is used as
  /// an override. Falls back to the variant icon when no app icon can be
  /// resolved.
  const factory ToastLeading.appIcon({
    double heightPercentage,
    double widthPercentage,
  }) = ToastLeadingAppIcon;
}

class ToastLeadingNone extends ToastLeading {
  const ToastLeadingNone();
}

class ToastLeadingImage extends ToastLeading {
  final String assetPath;
  final Color? color;
  final double heightPercentage;
  final double widthPercentage;

  const ToastLeadingImage(
    this.assetPath, {
    this.color,
    this.heightPercentage = 0.80,
    this.widthPercentage = 0.20,
  }) : assert(
          heightPercentage > 0 && heightPercentage <= 1,
          'heightPercentage must be greater than 0 and less than or equal to 1.',
        ),
        assert(
          widthPercentage > 0 && widthPercentage <= 1,
          'widthPercentage must be greater than 0 and less than or equal to 1.',
        );
}

class ToastLeadingIcon extends ToastLeading {
  final IconData icon;
  final Color? color;
  final double? size;
  const ToastLeadingIcon(this.icon, {this.color, this.size});
}

class ToastLeadingAppIcon extends ToastLeading {
  final double heightPercentage;
  final double widthPercentage;

  const ToastLeadingAppIcon({
    this.heightPercentage = 0.80,
    this.widthPercentage = 0.20,
  }) : assert(
          heightPercentage > 0 && heightPercentage <= 1,
          'heightPercentage must be greater than 0 and less than or equal to 1.',
        ),
        assert(
          widthPercentage > 0 && widthPercentage <= 1,
          'widthPercentage must be greater than 0 and less than or equal to 1.',
        );
}
