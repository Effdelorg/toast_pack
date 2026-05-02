import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_icon_provider.dart';
import 'toast_config.dart';
import 'toast_enums.dart';
import 'toast_leading.dart';
import 'toast_variant.dart';
import 'web_background.dart';

class ResolvedToastConfig {
  final ToastVariant variant;
  final String message;
  final Duration duration;
  final ToastGravity gravity;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final String? fontFamily;
  final ToastLeading leading;
  final EdgeInsets margin;
  final ToastAnimation animation;
  final Duration animationDuration;
  final Curve curve;
  final bool webShowClose;
  final String? webBgColor;
  final ToastWebPosition webPosition;

  const ResolvedToastConfig({
    required this.variant,
    required this.message,
    required this.duration,
    required this.gravity,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.fontFamily,
    required this.leading,
    required this.margin,
    required this.animation,
    required this.animationDuration,
    required this.curve,
    required this.webShowClose,
    required this.webBgColor,
    required this.webPosition,
  });
}

class ToastWidget extends StatefulWidget {
  final ResolvedToastConfig cfg;
  final VoidCallback onDismissed;

  const ToastWidget({
    super.key,
    required this.cfg,
    required this.onDismissed,
  });

  @override
  State<ToastWidget> createState() => ToastWidgetState();
}

class ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _dismissTimer;
  bool _dismissed = false;
  Future<Uint8List?>? _appIconFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.cfg.animationDuration,
    );
    _controller.forward();
    _dismissTimer = Timer(widget.cfg.duration, dismiss);
    if (widget.cfg.leading is ToastLeadingAppIcon &&
        ToastPackConfig.defaultIconAsset == null) {
      _appIconFuture = AppIconProvider.load();
    }
  }

  /// Public — callable by ToastManager to trigger an early exit.
  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (!mounted) {
      widget.onDismissed();
      return;
    }
    _controller.addStatusListener(_onReverseStatus);
    _controller.reverse();
  }

  void _onReverseStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) return;
    _controller.removeStatusListener(_onReverseStatus);
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: IgnorePointer(
          ignoring: !widget.cfg.webShowClose,
          child: Align(
            alignment: _resolveAlignment(),
            child: Padding(
              padding: widget.cfg.margin,
              child: Material(
                color: Colors.transparent,
                child: _wrapAnimation(_buildPill()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Alignment _resolveAlignment() {
    final double vert;
    switch (widget.cfg.gravity) {
      case ToastGravity.top:
        vert = -1.0;
        break;
      case ToastGravity.bottom:
        vert = 1.0;
        break;
      case ToastGravity.center:
        vert = 0.0;
        break;
    }
    double horiz = 0.0;
    if (kIsWeb) {
      switch (widget.cfg.webPosition) {
        case ToastWebPosition.left:
          horiz = -1.0;
          break;
        case ToastWebPosition.center:
          horiz = 0.0;
          break;
        case ToastWebPosition.right:
          horiz = 1.0;
          break;
      }
    }
    return Alignment(horiz, vert);
  }

  Widget _wrapAnimation(Widget child) {
    final curved = CurvedAnimation(parent: _controller, curve: widget.cfg.curve);
    switch (widget.cfg.animation) {
      case ToastAnimation.slide:
        return SlideTransition(
          position: Tween<Offset>(begin: _slideOffset(), end: Offset.zero)
              .animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      case ToastAnimation.fade:
        return FadeTransition(opacity: curved, child: child);
      case ToastAnimation.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
    }
  }

  Offset _slideOffset() {
    switch (widget.cfg.gravity) {
      case ToastGravity.top:
        return const Offset(0, -0.4);
      case ToastGravity.bottom:
        return const Offset(0, 0.4);
      case ToastGravity.center:
        return const Offset(0, 0.2);
    }
  }

  Widget _buildPill() {
    final cfg = widget.cfg;
    final variant = ToastVariantDefaults.of(cfg.variant);
    final bgColor = cfg.backgroundColor ?? variant.backgroundColor;
    final textColor = cfg.textColor ?? variant.textColor;
    const radius = 28.0;

    final Decoration decoration;
    if (kIsWeb && cfg.webBgColor != null) {
      decoration = parseWebBgColor(cfg.webBgColor!, radius);
    } else {
      decoration = BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );
    }

    final leadingWidget = _buildLeading(variant, textColor);

    return Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              cfg.message,
              style: TextStyle(
                color: textColor,
                fontSize: cfg.fontSize,
                fontFamily: cfg.fontFamily,
              ),
            ),
          ),
          if (kIsWeb && cfg.webShowClose) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: dismiss,
              behavior: HitTestBehavior.opaque,
              child: Icon(Icons.close, size: 18, color: textColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildLeading(ToastVariantDefaults variant, Color textColor) {
    final leading = widget.cfg.leading;
    switch (leading) {
      case ToastLeadingNone():
        return null;
      case ToastLeadingImage(:final assetPath):
        return _assetWithFallback(assetPath, variant, textColor);
      case ToastLeadingIcon(:final icon, :final color, :final size):
        return Icon(icon, color: color ?? textColor, size: size ?? 24);
      case ToastLeadingAppIcon():
        final asset = ToastPackConfig.defaultIconAsset;
        if (asset != null) {
          return _assetWithFallback(asset, variant, textColor);
        }
        return _nativeAppIconWithFallback(
          appIconFuture: _appIconFuture ??= AppIconProvider.load(),
          variant: variant,
          textColor: textColor,
        );
    }
  }

  Widget _nativeAppIconWithFallback({
    required Future<Uint8List?> appIconFuture,
    required ToastVariantDefaults variant,
    required Color textColor,
  }) {
    return FutureBuilder<Uint8List?>(
      future: appIconFuture,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return Icon(variant.fallbackIcon, color: textColor, size: 24);
        }
        return Image.memory(
          bytes,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(variant.fallbackIcon, color: textColor, size: 24),
        );
      },
    );
  }

  Widget _assetWithFallback(
    String path,
    ToastVariantDefaults variant,
    Color textColor,
  ) {
    return Image.asset(
      path,
      width: 24,
      height: 24,
      errorBuilder: (context, error, stackTrace) =>
          Icon(variant.fallbackIcon, color: textColor, size: 24),
    );
  }
}
