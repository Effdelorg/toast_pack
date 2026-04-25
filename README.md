# snap_toast_flutter

A lightweight, zero-dependency Flutter package for displaying toast notifications via `Overlay`.

- Variant-first API: `SnapToast.success`, `.error`, `.warning`, `.info`
- Works on Android, iOS, Web, macOS, Windows, Linux
- iOS/macOS Swift Package Manager (SPM) compatible plugin layout
- Only one toast visible at a time; configurable replacement behavior
- Slide + fade, fade, or scale entrance animations
- Optional leading visual: icon, image asset, app icon, or none (default)
- Web-specific gradient background, close button, and horizontal position

## Install

```yaml
dependencies:
  snap_toast_flutter: ^0.1.1
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:snap_toast_flutter/snap_toast_flutter.dart';

void main() {
  SnapToast.init(
    // Optional: override asset for ToastLeading.appIcon().
    // If omitted, the package will try the native launcher icon.
    defaultIconAsset: 'assets/app_icon.png',
    // Optional: how new toasts replace the current one. Default: instantReplace.
    replacementMode: ReplacementMode.instantReplace,
  );
  runApp(const MyApp());
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => SnapToast.success(context, 'Item added'),
        child: const Text('Show toast'),
      ),
    );
  }
}
```

## Variants

```dart
SnapToast.success(context, 'Saved');
SnapToast.error(context, 'Something went wrong');
SnapToast.warning(context, 'Double-check this');
SnapToast.info(context, 'Just FYI');
SnapToast.dismiss(); // clear the current toast
```

## Leading visual

The leading visual defaults to **none**. Set one explicitly:

```dart
// Icon
SnapToast.info(context, 'Hi', leading: ToastLeading.icon(Icons.star));

// Asset image (falls back to variant icon if the asset fails to load)
SnapToast.success(context, 'Uploaded', leading: ToastLeading.image('assets/check.png'));

// Uses native app icon by default (or your init override asset, if set)
SnapToast.info(context, 'New update', leading: ToastLeading.appIcon());

// Explicitly no leading visual (the default)
SnapToast.warning(context, 'Heads up', leading: ToastLeading.none());
```

## Parameters

All variant methods share the same named parameters:

| Param | Type | Default |
| --- | --- | --- |
| `duration` | `Duration` | `Duration(seconds: 2)` |
| `gravity` | `ToastGravity` | `ToastGravity.bottom` |
| `backgroundColor` | `Color?` | variant default |
| `textColor` | `Color?` | variant default |
| `fontSize` | `double` | `14` |
| `fontFamily` | `String?` | inherits ambient theme |
| `leading` | `ToastLeading` | `ToastLeading.none()` |
| `margin` | `EdgeInsets` | `EdgeInsets.all(16)` |
| `animation` | `ToastAnimation` | `ToastAnimation.slide` |
| `animationDuration` | `Duration` | `250 ms` |
| `curve` | `Curve` | `Curves.easeOut` |
| `webShowClose` | `bool` | `false` |
| `webBgColor` | `String?` | defaults to `linear-gradient(to right, #00b09b, #96c93d)` on web |
| `webPosition` | `ToastWebPosition` | `ToastWebPosition.center` |

## Variant defaults

| Variant | Background | Text | Fallback icon |
| --- | --- | --- | --- |
| success | `#4CAF50` | white | `Icons.check_circle` |
| error | `#F44336` | white | `Icons.error` |
| warning | `#FFC107` | black | `Icons.warning` |
| info | `#2196F3` | white | `Icons.info` |

## Web-specific styling

`webBgColor` accepts either:

- a hex color: `#RRGGBB` or `#RRGGBBAA`
- a CSS `linear-gradient(...)` string with `to right | left | top | bottom | top left | top right | bottom left | bottom right`

```dart
SnapToast.info(
  context,
  'Ready',
  webBgColor: 'linear-gradient(to right, #2193b0, #6dd5ed)',
  webShowClose: true,
  webPosition: ToastWebPosition.right,
);
```

Web-specific parameters are silently ignored on non-web platforms.

## Animations

```dart
SnapToast.success(context, 'Hi', animation: ToastAnimation.slide); // slide + fade (default)
SnapToast.success(context, 'Hi', animation: ToastAnimation.fade);
SnapToast.success(context, 'Hi', animation: ToastAnimation.scale); // scale + fade
```

## Replacement behavior

```dart
// Kill the current toast immediately, then show the new one (default).
SnapToast.init(replacementMode: ReplacementMode.instantReplace);

// Animate the current toast out while the new one animates in.
SnapToast.init(replacementMode: ReplacementMode.gracefulCrossfade);
```

## Example

See [`example/`](example/) for a demo app that exercises every parameter.
