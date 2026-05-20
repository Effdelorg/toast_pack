import Flutter
import UIKit

public class ToastPackPlugin: NSObject, FlutterPlugin {
  private static let channelName = "toast_pack/app_icon"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = ToastPackPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getAppIcon" else {
      result(FlutterMethodNotImplemented)
      return
    }
    result(loadAppIcon())
  }

  private func loadAppIcon() -> FlutterStandardTypedData? {
    let iconNames = iconFileNames(from: "CFBundleIcons")
      + iconFileNames(from: "CFBundleIcons~ipad")
    guard !iconNames.isEmpty else {
      return nil
    }

    for iconName in iconNames.reversed() {
      guard let image = UIImage(named: iconName), let pngData = image.pngData() else {
        continue
      }
      return FlutterStandardTypedData(bytes: pngData)
    }
    return nil
  }

  private func iconFileNames(from key: String) -> [String] {
    guard
      let icons = Bundle.main.object(forInfoDictionaryKey: key) as? [String: Any],
      let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
      let iconFiles = primary["CFBundleIconFiles"] as? [String]
    else {
      return []
    }
    return iconFiles
  }
}
