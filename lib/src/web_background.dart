import 'package:flutter/material.dart';

/// Parses a CSS-like background string (hex color or `linear-gradient(...)`)
/// into a [Decoration].
///
/// Supported inputs:
///   * Hex color: `#RRGGBB` or `#RRGGBBAA`
///   * Linear gradient: `linear-gradient(<direction>, <stop1>, <stop2>[, ...])`
///     Directions: `to left`, `to right`, `to top`, `to bottom`,
///     `to top left`, `to top right`, `to bottom left`, `to bottom right`.
///
/// On parse failure: debug asserts, release returns a transparent decoration
/// so the toast still renders.
Decoration parseWebBgColor(String raw, double radius) {
  final borderRadius = BorderRadius.circular(radius);
  final s = raw.trim();

  try {
    if (s.startsWith('#')) {
      return BoxDecoration(
        color: _parseHex(s),
        borderRadius: borderRadius,
      );
    }
    if (s.startsWith('linear-gradient(') && s.endsWith(')')) {
      final inner = s.substring('linear-gradient('.length, s.length - 1).trim();
      final parts = _splitTopLevel(inner);
      if (parts.length < 3) {
        throw const FormatException('linear-gradient needs a direction and 2+ stops');
      }
      final alignments = _parseDirection(parts.first.trim());
      final colors = parts.skip(1).map((p) => _parseHex(p.trim())).toList(growable: false);
      return BoxDecoration(
        gradient: LinearGradient(
          begin: alignments.$1,
          end: alignments.$2,
          colors: colors,
        ),
        borderRadius: borderRadius,
      );
    }
    throw FormatException('Unrecognized webBgColor: "$raw"');
  } catch (e) {
    assert(false, 'Unparseable webBgColor "$raw": $e');
    return BoxDecoration(color: Colors.transparent, borderRadius: borderRadius);
  }
}

Color _parseHex(String hex) {
  var h = hex.replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) {
    throw FormatException('Invalid hex color: #$h');
  }
  return Color(int.parse(h, radix: 16));
}

(Alignment, Alignment) _parseDirection(String dir) {
  switch (dir) {
    case 'to right':
      return (Alignment.centerLeft, Alignment.centerRight);
    case 'to left':
      return (Alignment.centerRight, Alignment.centerLeft);
    case 'to bottom':
      return (Alignment.topCenter, Alignment.bottomCenter);
    case 'to top':
      return (Alignment.bottomCenter, Alignment.topCenter);
    case 'to top left':
      return (Alignment.bottomRight, Alignment.topLeft);
    case 'to top right':
      return (Alignment.bottomLeft, Alignment.topRight);
    case 'to bottom left':
      return (Alignment.topRight, Alignment.bottomLeft);
    case 'to bottom right':
      return (Alignment.topLeft, Alignment.bottomRight);
    default:
      throw FormatException('Unsupported gradient direction: "$dir"');
  }
}

/// Split a comma-separated list at the top level (ignores commas inside
/// nested parentheses — future-proofing for rgb()/hsl() if ever added).
List<String> _splitTopLevel(String s) {
  final result = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '(') depth++;
    if (c == ')') depth--;
    if (c == ',' && depth == 0) {
      result.add(s.substring(start, i));
      start = i + 1;
    }
  }
  result.add(s.substring(start));
  return result;
}
