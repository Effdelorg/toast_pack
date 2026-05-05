import 'package:flutter/material.dart';

import 'toast_config.dart';
import 'toast_enums.dart';
import 'toast_leading.dart';
import 'toast_manager.dart';
import 'toast_variant.dart';
import 'toast_widget.dart';

/// Public entry point for showing toasts.
class ToastPack {
  ToastPack._();

  static const defaultPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );

  /// Optional global configuration. Call once (e.g. in `main()`).
  ///
  /// * [defaultIconAsset] — optional asset override used by
  ///   `ToastLeading.appIcon()`. If unset, the native launcher icon is used
  ///   when available. If icon resolution fails, the variant fallback icon is
  ///   rendered instead.
  /// * [replacementMode] — how a new toast replaces the current one.
  static void init({
    String? defaultIconAsset,
    ReplacementMode replacementMode = ReplacementMode.instantReplace,
  }) {
    ToastPackConfig.defaultIconAsset = defaultIconAsset;
    ToastPackConfig.replacementMode = replacementMode;
  }

  static void success(
    BuildContext? context,
    String message, {
    OverlayState? overlayState,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.bottom,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14,
    String? fontFamily,
    ToastLeading leading = const ToastLeading.none(),
    EdgeInsets margin = const EdgeInsets.all(16),
    EdgeInsets padding = defaultPadding,
    ToastAnimation animation = ToastAnimation.slide,
    Duration animationDuration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOut,
    bool webShowClose = false,
    String? webBgColor,
    ToastWebPosition webPosition = ToastWebPosition.center,
  }) {
    _show(
      context,
      overlayState,
      ToastVariant.success,
      message,
      duration: duration,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      leading: leading,
      margin: margin,
      padding: padding,
      animation: animation,
      animationDuration: animationDuration,
      curve: curve,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }

  static void error(
    BuildContext? context,
    String message, {
    OverlayState? overlayState,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.bottom,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14,
    String? fontFamily,
    ToastLeading leading = const ToastLeading.none(),
    EdgeInsets margin = const EdgeInsets.all(16),
    EdgeInsets padding = defaultPadding,
    ToastAnimation animation = ToastAnimation.slide,
    Duration animationDuration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOut,
    bool webShowClose = false,
    String? webBgColor,
    ToastWebPosition webPosition = ToastWebPosition.center,
  }) {
    _show(
      context,
      overlayState,
      ToastVariant.error,
      message,
      duration: duration,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      leading: leading,
      margin: margin,
      padding: padding,
      animation: animation,
      animationDuration: animationDuration,
      curve: curve,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }

  static void warning(
    BuildContext? context,
    String message, {
    OverlayState? overlayState,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.bottom,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14,
    String? fontFamily,
    ToastLeading leading = const ToastLeading.none(),
    EdgeInsets margin = const EdgeInsets.all(16),
    EdgeInsets padding = defaultPadding,
    ToastAnimation animation = ToastAnimation.slide,
    Duration animationDuration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOut,
    bool webShowClose = false,
    String? webBgColor,
    ToastWebPosition webPosition = ToastWebPosition.center,
  }) {
    _show(
      context,
      overlayState,
      ToastVariant.warning,
      message,
      duration: duration,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      leading: leading,
      margin: margin,
      padding: padding,
      animation: animation,
      animationDuration: animationDuration,
      curve: curve,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }

  static void info(
    BuildContext? context,
    String message, {
    OverlayState? overlayState,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.bottom,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14,
    String? fontFamily,
    ToastLeading leading = const ToastLeading.none(),
    EdgeInsets margin = const EdgeInsets.all(16),
    EdgeInsets padding = defaultPadding,
    ToastAnimation animation = ToastAnimation.slide,
    Duration animationDuration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOut,
    bool webShowClose = false,
    String? webBgColor,
    ToastWebPosition webPosition = ToastWebPosition.center,
  }) {
    _show(
      context,
      overlayState,
      ToastVariant.info,
      message,
      duration: duration,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      leading: leading,
      margin: margin,
      padding: padding,
      animation: animation,
      animationDuration: animationDuration,
      curve: curve,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }

  /// Dismiss the currently visible toast, if any.
  static void dismiss() => ToastManager.instance.dismiss();

  static void _show(
    BuildContext? context,
    OverlayState? overlayState,
    ToastVariant variant,
    String message, {
    required Duration duration,
    required ToastGravity gravity,
    required Color? backgroundColor,
    required Color? textColor,
    required double fontSize,
    required String? fontFamily,
    required ToastLeading leading,
    required EdgeInsets margin,
    required EdgeInsets padding,
    required ToastAnimation animation,
    required Duration animationDuration,
    required Curve curve,
    required bool webShowClose,
    required String? webBgColor,
    required ToastWebPosition webPosition,
  }) {
    // Resolve the web background: on web, default to the PRD gradient when
    // not provided. On non-web, this field is ignored by the widget.
    const defaultWebGradient =
        'linear-gradient(to right, #00b09b, #96c93d)';
    final resolvedWebBg = webBgColor ?? defaultWebGradient;

    ToastManager.instance.show(
      context,
      ResolvedToastConfig(
        variant: variant,
        message: message,
        duration: duration,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        leading: leading,
        margin: margin,
        padding: padding,
        animation: animation,
        animationDuration: animationDuration,
        curve: curve,
        webShowClose: webShowClose,
        webBgColor: resolvedWebBg,
        webPosition: webPosition,
      ),
      overlayState: overlayState,
    );
  }
}
