## Unreleased

- Add optional `overlayState` support to `ToastPack.success`, `.error`,
  `.warning`, and `.info`, and allow `context` to be nullable when an explicit
  overlay is provided.
- Add per-toast `padding`, defaulting to
  `EdgeInsets.symmetric(horizontal: 20, vertical: 14)`.
- Add percentage sizing controls to `ToastLeading.image` and
  `ToastLeading.appIcon` with `heightPercentage` and `widthPercentage`.
- Fix percentage-based leading sizing so wrapped text measurement reserves the
  resolved leading width and gap before calculating toast height.
- Add readable percentage fields to `ToastLeadingImage` and
  `ToastLeadingAppIcon`.

## 0.1.1

- Rename the published package to `toast_pack`.
- Update the public import path to `package:toast_pack/toast_pack.dart`.
- Require Flutter `>=3.41.0` for strict Swift Package Manager support.
- Fix `ToastLeading.appIcon()` to resolve native launcher icon by default.
- Keep `ToastPack.init(defaultIconAsset: ...)` as an explicit override.
- Add Android/iOS/macOS platform-channel implementations for app icon bytes.
- Add iOS/macOS Swift Package Manager `Package.swift` plugin manifests.

## 0.1.0

Initial release.

- `ToastPack.success` / `.error` / `.warning` / `.info` variant API
- Single active toast with configurable replacement (`instantReplace` / `gracefulCrossfade`)
- Leading visuals: `ToastLeading.none` (default), `.icon`, `.image`, `.appIcon`
- Animations: slide + fade (default), fade, scale + fade
- Gravity: top / bottom / center; respects `SafeArea`
- Web-specific: gradient/hex background string, close button, horizontal position
- Zero runtime dependencies
