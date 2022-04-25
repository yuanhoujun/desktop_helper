import Cocoa
import FlutterMacOS

public class DesktopHelperPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.youngfeng.desktop/desktop_helper", binaryMessenger: registrar.messenger)
    let instance = DesktopHelperPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {    
    switch call.method {
      case "openFile":
        if let args = call.arguments as? Dictionary<String, Any>,
           let path = args["path"] as? String,
           let isDir = args["isDir"] as? Bool {
             print("openFile(path: \(path), isDir: \(isDir))")
          let isOpened = NSWorkspace.shared.open(
              URL(
                  fileURLWithPath: path,
                  isDirectory: isDir
              )
          )

          result(isOpened)
        } else {
          result(FlutterError.init(code: "Bad args", message: nil, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
