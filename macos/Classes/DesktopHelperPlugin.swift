import Cocoa
import FlutterMacOS

public class DesktopHelperPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.youngfeng.desktop/desktop_helper", binaryMessenger: registrar.messenger)
    let instance = DesktopHelperPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let methodName = call.method
    let args = call.arguments as? [String: Any] ?? [:]
    switch methodName {
    case "openFile":
      if let path = args["path"] as? String,
        let isDir = args["isDir"] as? Bool
      {
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
      break
    case "getAppsForFile":
      if let path = args["path"] as? String {
        let cURL = URL(fileURLWithPath: path) as CFURL
        let appURLs = LSCopyApplicationURLsForURL(cURL, LSRolesMask.all)?.takeRetainedValue()

        var apps: [[String: Any]] = []

        if appURLs != nil {
          for appURL in appURLs as! [NSURL] {
            if let appPath = appURL.path {
              let iconImage = NSWorkspace.shared.icon(forFile: appPath)
              let appName = FileManager.default.displayName(atPath: appPath)
              var bundleId = ""

              if let bundle = Bundle(url: URL(fileURLWithPath: appPath)),
                let bundleIdentifier = bundle.bundleIdentifier
              {
                bundleId = bundleIdentifier
              }

              let imageData = convertImageToBytes(image: iconImage)

              apps.append([
                "url": appPath, "name": appName, "icon": imageData, "bundleId": bundleId,
              ])
            }
          }
        }
        result(apps)
      } else {
        result(FlutterError.init(code: "Bad args", message: nil, details: nil))
      }
      break
    case "openFileWithApp":
      if let filePath = args["filePath"] as? String,
        let appUrl = args["appUrl"] as? String
      {
        if #available(macOS 10.15, *) {
          AppKit.NSWorkspace.shared.open(
            [URL(fileURLWithPath: filePath)],
            withApplicationAt: URL(fileURLWithPath: appUrl),
            configuration: NSWorkspace.OpenConfiguration()
          ) { app, error in
            result(error == nil)
          }
        } else {
          // Get app name from appUrl.
          var appUrlStr: String = appUrl
          if appUrlStr.hasSuffix("/") {
            appUrlStr.removeLast()
          }
          let index = appUrlStr.lastIndex(of: "/") ?? appUrlStr.startIndex

          if let appName = String(appUrlStr[index..<appUrlStr.endIndex].dropFirst())
            .removingPercentEncoding
          {
            let isSuccess = AppKit.NSWorkspace.shared.openFile(filePath, withApplication: appName)
            result(isSuccess)
          } else {
            result(false)
          }
        }
      } else {
        result(FlutterError.init(code: "Bad args", message: nil, details: nil))
      }
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func convertImageToBytes(image: NSImage) -> [UInt8] {
    var rect = NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage!)

    if let imageData = bitmapRep.representation(
      using: NSBitmapImageRep.FileType.png, properties: [:])
    {
      let bytes = [UInt8](imageData)
      return bytes
    }

    return [UInt8]()
  }
}
