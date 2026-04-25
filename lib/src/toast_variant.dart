import 'package:flutter/material.dart';

/// Predefined toast variants with sensible color + icon defaults.
enum ToastVariant { success, error, warning, info }

class ToastVariantDefaults {
  final Color backgroundColor;
  final Color textColor;
  final IconData fallbackIcon;

  const ToastVariantDefaults({
    required this.backgroundColor,
    required this.textColor,
    required this.fallbackIcon,
  });

  static const _success = ToastVariantDefaults(
    backgroundColor: Color(0xFF4CAF50),
    textColor: Colors.white,
    fallbackIcon: Icons.check_circle,
  );

  static const _error = ToastVariantDefaults(
    backgroundColor: Color(0xFFF44336),
    textColor: Colors.white,
    fallbackIcon: Icons.error,
  );

  static const _warning = ToastVariantDefaults(
    backgroundColor: Color(0xFFFFC107),
    textColor: Colors.black,
    fallbackIcon: Icons.warning,
  );

  static const _info = ToastVariantDefaults(
    backgroundColor: Color(0xFF2196F3),
    textColor: Colors.white,
    fallbackIcon: Icons.info,
  );

  static ToastVariantDefaults of(ToastVariant variant) {
    switch (variant) {
      case ToastVariant.success:
        return _success;
      case ToastVariant.error:
        return _error;
      case ToastVariant.warning:
        return _warning;
      case ToastVariant.info:
        return _info;
    }
  }
}
