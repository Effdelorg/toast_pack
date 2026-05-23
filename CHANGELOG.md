## 0.1.2

- Added `ToastIconClip` for `ToastLeading.appIcon`.
- `ToastLeading.appIcon()` now uses a circular leading shape by default.
- Added `ToastIconClip.none` for showing the resolved app icon without circular
  clipping.
- Improved iOS app icon rendering so the icon is padded inside the circular
  leading badge instead of cropping edge artwork.
- Preserved the previous `defaultIconAsset` behavior: asset overrides remain
  unclipped unless `clip: ToastIconClip.circle` is explicitly passed.
- Added test coverage for default app-icon clipping, iOS badge rendering, and
  unclipped native and asset app icons.

## 0.1.1

Initial release.

- `ToastPack.success` / `.error` / `.warning` / `.info` variant API
- Single active toast with configurable replacement (`instantReplace` / `gracefulCrossfade`)
- Leading visuals: `ToastLeading.none` (default), `.icon`, `.image`, `.appIcon`
- Percentage sizing for `ToastLeading.image` and `ToastLeading.appIcon` via
  `heightPercentage` and `widthPercentage`
- Native launcher icon lookup on Android, iOS, and macOS; optional
  `ToastPack.init(defaultIconAsset: ...)` override
- Animations: slide + fade (default), fade, scale + fade
- Gravity: top / bottom / center; respects `SafeArea`
- Optional `overlayState` — show toasts without a `BuildContext`
- Per-toast `padding`, defaulting to
  `EdgeInsets.symmetric(horizontal: 10, vertical: 10)`
- Web-specific: gradient/hex background string, close button, horizontal position
- Zero runtime dependencies
- Requires Flutter `>=3.41.0`
