import 'dart:async';
import 'dart:math' as math;

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
  final EdgeInsets padding;
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
    required this.padding,
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

  const ToastWidget({super.key, required this.cfg, required this.onDismissed});

  @override
  State<ToastWidget> createState() => ToastWidgetState();
}

class ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  static const _leadingGap = 12.0;
  static const _closeIconSize = 18.0;

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
    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.cfg.curve,
    );
    switch (widget.cfg.animation) {
      case ToastAnimation.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: _slideOffset(),
            end: Offset.zero,
          ).animate(curved),
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
    final textStyle = TextStyle(
      color: textColor,
      fontSize: cfg.fontSize,
      fontFamily: cfg.fontFamily,
    );
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final leadingWidget = _buildLeading(
          context,
          variant,
          textColor,
          textStyle,
          constraints.maxWidth,
        );

        return Container(
          decoration: decoration,
          padding: cfg.padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingWidget != null) ...[
                leadingWidget,
                const SizedBox(width: _leadingGap),
              ],
              Flexible(child: Text(cfg.message, style: textStyle)),
              if (kIsWeb && cfg.webShowClose) ...[
                const SizedBox(width: _leadingGap),
                GestureDetector(
                  onTap: dismiss,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    Icons.close,
                    size: _closeIconSize,
                    color: textColor,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget? _buildLeading(
    BuildContext context,
    ToastVariantDefaults variant,
    Color textColor,
    TextStyle textStyle,
    double maxToastWidth,
  ) {
    final leading = widget.cfg.leading;
    switch (leading) {
      case ToastLeadingNone():
        return null;
      case ToastLeadingImage(
        :final assetPath,
        :final color,
        :final heightPercentage,
        :final widthPercentage,
      ):
        final resolvedSize = _resolvePercentageLeadingSize(
          context: context,
          textStyle: textStyle,
          maxToastWidth: maxToastWidth,
          heightPercentage: heightPercentage,
          widthPercentage: widthPercentage,
        );
        return _assetWithFallback(
          assetPath,
          variant,
          textColor,
          resolvedSize,
          color: color,
        );
      case ToastLeadingIcon(:final icon, :final color, :final size):
        return Icon(icon, color: color ?? textColor, size: size ?? 24);
      case ToastLeadingAppIcon(:final heightPercentage, :final widthPercentage):
        final resolvedSize = _resolvePercentageLeadingSize(
          context: context,
          textStyle: textStyle,
          maxToastWidth: maxToastWidth,
          heightPercentage: heightPercentage,
          widthPercentage: widthPercentage,
        );
        final asset = ToastPackConfig.defaultIconAsset;
        if (asset != null) {
          return _assetWithFallback(asset, variant, textColor, resolvedSize);
        }
        return _nativeAppIconWithFallback(
          appIconFuture: _appIconFuture ??= AppIconProvider.load(),
          variant: variant,
          textColor: textColor,
          size: resolvedSize,
        );
    }
  }

  double _resolvePercentageLeadingSize({
    required BuildContext context,
    required TextStyle textStyle,
    required double maxToastWidth,
    required double heightPercentage,
    required double widthPercentage,
  }) {
    final horizontalPadding = widget.cfg.padding.horizontal;
    final verticalPadding = widget.cfg.padding.vertical;
    final availableWidth = maxToastWidth.isFinite
        ? maxToastWidth
        : double.infinity;
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final closeWidth = kIsWeb && widget.cfg.webShowClose
        ? _closeIconSize + _leadingGap
        : 0.0;
    final maxLeadingWidth = math.max(
      0.0,
      availableWidth - horizontalPadding - _leadingGap - closeWidth,
    );
    final widthCap = maxLeadingWidth * widthPercentage;

    var resolvedSize = 0.0;
    for (var index = 0; index < 6; index++) {
      final nextSize = _measurePercentageLeadingSize(
        reservedLeadingWidth: resolvedSize,
        availableWidth: availableWidth,
        horizontalPadding: horizontalPadding,
        verticalPadding: verticalPadding,
        closeWidth: closeWidth,
        widthCap: widthCap,
        heightPercentage: heightPercentage,
        textStyle: textStyle,
        textDirection: textDirection,
      );
      if ((nextSize - resolvedSize).abs() < 0.5) return nextSize;
      if (index == 5) return resolvedSize;
      resolvedSize = nextSize;
    }

    return resolvedSize;
  }

  double _measurePercentageLeadingSize({
    required double reservedLeadingWidth,
    required double availableWidth,
    required double horizontalPadding,
    required double verticalPadding,
    required double closeWidth,
    required double widthCap,
    required double heightPercentage,
    required TextStyle textStyle,
    required TextDirection textDirection,
  }) {
    final textMaxWidth = math.max(
      0.0,
      availableWidth -
          horizontalPadding -
          reservedLeadingWidth -
          _leadingGap -
          closeWidth,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: widget.cfg.message, style: textStyle),
      textDirection: textDirection,
      maxLines: null,
    )..layout(maxWidth: textMaxWidth);
    final baseToastHeight =
        verticalPadding +
        math.max(
          textPainter.height,
          kIsWeb && widget.cfg.webShowClose ? _closeIconSize : 0,
        );

    return math.min(baseToastHeight * heightPercentage, widthCap);
  }

  Widget _nativeAppIconWithFallback({
    required Future<Uint8List?> appIconFuture,
    required ToastVariantDefaults variant,
    required Color textColor,
    required double size,
  }) {
    return FutureBuilder<Uint8List?>(
      future: appIconFuture,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return Icon(variant.fallbackIcon, color: textColor, size: size);
        }
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(variant.fallbackIcon, color: textColor, size: size),
        );
      },
    );
  }

  Widget _assetWithFallback(
    String path,
    ToastVariantDefaults variant,
    Color textColor,
    double size, {
    Color? color,
  }) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.srcIn,
      errorBuilder: (context, error, stackTrace) =>
          Icon(variant.fallbackIcon, color: textColor, size: size),
    );
  }
}
