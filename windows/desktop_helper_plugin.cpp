#include "include/desktop_helper/desktop_helper_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

#include "windows_util.cpp"

namespace
{

  class DesktopHelperPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    DesktopHelperPlugin();

    virtual ~DesktopHelperPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void DesktopHelperPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "com.youngfeng.desktop/desktop_helper",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<DesktopHelperPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  DesktopHelperPlugin::DesktopHelperPlugin() {}

  DesktopHelperPlugin::~DesktopHelperPlugin() {}

  void DesktopHelperPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    const std::string &methodName = method_call.method_name();
    const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());

    if (methodName.compare("openFile") == 0)
    {
      std::string path = std::get<std::string>(args.at(flutter::EncodableValue("path")));

      LPCWSTR wstrPath = WindowsUtil::StringToLPCWSTR(path);
      ShellExecute(NULL, NULL, wstrPath, NULL, NULL, SW_SHOWNORMAL);
      delete wstrPath;
      wstrPath = nullptr;
      result->Success(true);
      return;
    }

    if (methodName.compare("getAppsForFile") == 0)
    {
      std::string path = std::get<std::string>(args.at(flutter::EncodableValue("path")));
      flutter::EncodableList apps = WindowsUtil::GetAssociateAppsWithFile(path);
      result->Success(apps);
      return;
    }

    if (method_call.method_name().compare("getPlatformVersion") == 0)
    {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater())
      {
        version_stream << "10+";
      }
      else if (IsWindows8OrGreater())
      {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater())
      {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    }

    if (methodName.compare("openFileWithApp") == 0)
    {
      std::string filePath = std::get<std::string>(args.at(flutter::EncodableValue("filePath")));
      std::string appUrl = std::get<std::string>(args.at(flutter::EncodableValue("appUrl")));

      std::string path = "\"";
      path += filePath;
      path += "\"";

      std::cout << path << "-" << appUrl << endl;
      LPCWSTR wstrPath = WindowsUtil::StringToLPCWSTR(path);
      LPCWSTR wstrUrl = WindowsUtil::StringToLPCWSTR(appUrl);

      // ShellExecute(NULL, NULL, (LPCWSTR)appUrl.c_str(), (LPCWSTR)filePath.c_str(), NULL, SW_SHOWNORMAL);
      ShellExecute(NULL, NULL, wstrUrl, wstrPath, NULL, SW_SHOWNORMAL);

      delete wstrPath;
      delete wstrUrl;
      wstrPath = nullptr;
      wstrUrl = nullptr;
      result->Success(true);

      return;
    }

    result->NotImplemented();
  }

} // namespace

void DesktopHelperPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  DesktopHelperPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
