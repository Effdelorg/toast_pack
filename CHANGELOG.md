## 0.1.1

- Fix `ToastLeading.appIcon()` to resolve native launcher icon by default.
- Keep `SnapToast.init(defaultIconAsset: ...)` as an explicit override.
- Add Android/iOS/macOS platform-channel implementations for app icon bytes.
- Add iOS/macOS Swift Package Manager `Package.swift` plugin manifests.

## 0.1.0

Initial release.

- `SnapToast.success` / `.error` / `.warning` / `.info` variant API
- Single active toast with configurable replacement (`instantReplace` / `gracefulCrossfade`)
- Leading visuals: `ToastLeading.none` (default), `.icon`, `.image`, `.appIcon`
- Animations: slide + fade (default), fade, scale + fade
- Gravity: top / bottom / center; respects `SafeArea`
- Web-specific: gradient/hex background string, close button, horizontal position
- Zero runtime dependencies
