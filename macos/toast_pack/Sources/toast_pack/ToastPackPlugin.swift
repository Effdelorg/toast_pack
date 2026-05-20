import Cocoa
import FlutterMacOS

public class ToastPackPlugin: NSObject, FlutterPlugin {
  private static let channelName = "toast_pack/app_icon"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger)
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
    guard
      let tiffData = NSApplication.shared.applicationIconImage.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:])
    else {
      return nil
    }
    return FlutterStandardTypedData(bytes: pngData)
  }
}
