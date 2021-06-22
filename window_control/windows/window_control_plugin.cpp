#include "include/window_control/window_control_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
// #include <unordered_map>

#pragma warning(disable : 4244)
#pragma warning(disable : 4189)

namespace
{

  class WindowControlPlugin : public flutter::Plugin
  {
    RECT normalRect;

  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    WindowControlPlugin();

    // WindowControlPlugin(
    //     std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel);

    virtual ~WindowControlPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void WindowControlPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "window_control",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<WindowControlPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  WindowControlPlugin::WindowControlPlugin() {}

  WindowControlPlugin::~WindowControlPlugin() {}

  void WindowControlPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    std::string method = method_call.method_name();

    if (method.compare("hideTitleBar") == 0)
    {
      HWND hWnd = GetActiveWindow();
      SetMenu(hWnd, NULL);
      LONG lStyle = GetWindowLong(hWnd, GWL_STYLE);
      // lStyle &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU);
      // lStyle &= WS_DLGFRAME;
      lStyle &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU | WS_DLGFRAME);
      SetWindowLong(hWnd, GWL_STYLE, lStyle);
      LONG flags = SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOOWNERZORDER;
      SetWindowPos(hWnd, NULL, 0, 0, 0, 0, flags);
      flutter::EncodableValue response(true);
      result->Success(&response);
    }
    else if (method.compare("showTitleBar") == 0)
    {
      HWND hWnd = GetActiveWindow();
      SetMenu(hWnd, NULL);
      // SetWindowLong(hWnd,GWL_STYLE,WS_EX_LAYERED);
      flutter::EncodableValue response(true);
      result->Success(&response);
    }
    else if (method.compare("getScreenSize") == 0)
    {
      flutter::EncodableMap umap;
      HWND hWnd = GetDesktopWindow();
      RECT rect;
      if (GetWindowRect(hWnd, &rect))
      {
        double width = rect.right;
        double height = rect.bottom;
        umap[flutter::EncodableValue("width")] = flutter::EncodableValue(width);
        umap[flutter::EncodableValue("height")] = flutter::EncodableValue(height);
      }
      flutter::EncodableValue response(umap);
      result->Success(&response);
    }
    else if (method.compare("startResize") == 0)
    {
      const flutter::EncodableValue *args = method_call.arguments();
      const flutter::EncodableMap &map = std::get<flutter::EncodableMap>(*args);
      bool top = std::get<bool>(map.at(flutter::EncodableValue("top")));
      bool bottom = std::get<bool>(map.at(flutter::EncodableValue("bottom")));
      bool left = std::get<bool>(map.at(flutter::EncodableValue("left")));
      bool right = std::get<bool>(map.at(flutter::EncodableValue("right")));
      HWND hWnd = GetActiveWindow();
      ReleaseCapture();
      LONG command = SC_SIZE;
      if (top && !bottom && !right && !left)
      {
        command |= WMSZ_TOP;
      }
      else if (top && left && !bottom && !right)
      {
        command |= WMSZ_TOPLEFT;
      }
      else if (left && !top && !bottom && !right)
      {
        command |= WMSZ_LEFT;
      }
      else if (right && !top && !left && !bottom)
      {
        command |= WMSZ_RIGHT;
      }
      else if (top && right && !left && !bottom)
      {
        command |= WMSZ_TOPRIGHT;
      }
      else if (bottom && !top && !right && !left)
      {
        command |= WMSZ_BOTTOM;
      }
      else if (bottom && left && !top && !right)
      {
        command |= WMSZ_BOTTOMLEFT;
      }
      else if (bottom && right && !top && !left)
      {
        command |= WMSZ_BOTTOMRIGHT;
      }
      SendMessage(hWnd, WM_SYSCOMMAND, command, 0);
      flutter::EncodableValue response(true);
      result->Success(&response);
    }
    else if (method.compare("startDrag") == 0)
    {
      HWND hWnd = GetActiveWindow();
      ReleaseCapture();
      SendMessage(hWnd, WM_SYSCOMMAND, SC_MOVE | HTCAPTION, 0);
      flutter::EncodableValue response(true);
      result->Success(&response);
    }
    else if (method.compare("closeWindow") == 0)
    {
      HWND hWnd = GetActiveWindow();
      SendMessage(hWnd, WM_CLOSE, 0, NULL);
      flutter::EncodableValue response(true);
      result->Success(&response);
    }
    else if (method.compare("minimizeWindow") == 0)
    {
      HWND hWnd = GetActiveWindow();
      ShowWindow(hWnd, SW_MINIMIZE);
      flutter::EncodableValue response(true);
      result->Success(&response);
    }
    else if (method.compare("windowTitleDoubleTap") == 0)
    {
      HWND hWnd = GetActiveWindow();
      HWND hWndScreen = GetDesktopWindow();
      RECT rectScreen;
      GetWindowRect(hWndScreen, &rectScreen);
      double padding = 5.0;
      bool isMaximized = false;
      RECT activeRect;
      GetWindowRect(hWnd, &activeRect);
      if (activeRect.top <= rectScreen.top + padding)
      {
        isMaximized = true;
      }
      if (activeRect.bottom >= rectScreen.bottom - padding)
      {
        isMaximized = true;
      }
      if (activeRect.left <= rectScreen.left + padding)
      {
        isMaximized = true;
      }
      if (activeRect.right >= rectScreen.right - padding)
      {
        isMaximized = true;
      }
      if (!isMaximized)
      {
        GetWindowRect(hWnd, &normalRect);
      }
      if (isMaximized)
      {
        RECT rect = normalRect;
        double width = rect.right - rect.left;
        double height = rect.bottom - rect.top;
        int x = rect.left;
        int y = rect.top;
        MoveWindow(hWnd, x, y, width, height, true);
      }
      else
      {
        RECT rect = rectScreen;
        double width = rect.right - rect.left;
        double height = rect.bottom - rect.top;
        int x = rect.left;
        int y = rect.top;
        MoveWindow(hWnd, x, y, width, height, true);
      }
      //  ReleaseCapture();
      // // InvalidateRect(hWnd, NULL, TRUE);
      // UpdateWindow(hWnd);
      flutter::EncodableValue response(true);
      result->Success(&response);
    }
    else if (method.compare("maximizeWindow") == 0)
    {
      HWND hWnd = GetActiveWindow();
      ShowWindow(hWnd, SW_SHOWMAXIMIZED);
      flutter::EncodableValue response(true);
      result->Success(&response);
    }
    else if (method.compare("centerWindow") == 0)
    {
      HWND hWnd = GetActiveWindow();
      RECT rect;
      bool success = false;
      HWND hWndScreen = GetDesktopWindow();
      RECT rectScreen;
      if (GetWindowRect(hWndScreen, &rectScreen))
      {
        double screenWidth = rectScreen.right;
        double screenHeight = rectScreen.bottom;
        double centerX = screenWidth / 2;
        double centerY = screenHeight / 2;

        if (GetWindowRect(hWnd, &rect))
        {
          double width = rect.right - rect.left;
          double height = rect.bottom - rect.top;
          int x = ((rectScreen.right - rectScreen.left) / 2 - width / 2);
          int y = ((rectScreen.bottom - rectScreen.top) / 2 - height / 2);
          success = MoveWindow(hWnd, x, y, width, height, true);
        }
      }
      flutter::EncodableValue response(success);
      result->Success(&response);
    }
    else if (method.compare("setWindowSize") == 0)
    {
      const flutter::EncodableValue *args = method_call.arguments();
      const flutter::EncodableMap &map = std::get<flutter::EncodableMap>(*args);
      double width = std::get<double>(map.at(flutter::EncodableValue("width")));
      double height = std::get<double>(map.at(flutter::EncodableValue("height")));
      HWND hWnd = GetActiveWindow();
      RECT rect;
      bool success = false;
      if (GetWindowRect(hWnd, &rect))
      {
        double x = rect.left;
        double y = rect.top;
        success = MoveWindow(hWnd, x, y, width, height, true);
      }
      flutter::EncodableValue response(success);
      result->Success(&response);
    }
    else if (method.compare("setWindowPosition") == 0)
    {
      const flutter::EncodableValue *args = method_call.arguments();
      const flutter::EncodableMap &map = std::get<flutter::EncodableMap>(*args);
      double x = std::get<double>(map.at(flutter::EncodableValue("x")));
      double y = std::get<double>(map.at(flutter::EncodableValue("y")));
      HWND hWnd = GetActiveWindow();
      RECT rect;
      bool success = false;
      if (GetWindowRect(hWnd, &rect))
      {
        double width = rect.right - rect.left;
        double height = rect.bottom - rect.top;
        success = MoveWindow(hWnd, x, y, width, height, true);
      }
      flutter::EncodableValue response(success);
      result->Success(&response);
    }
    else if (method.compare("getWindowSize") == 0)
    {
      flutter::EncodableMap umap;
      HWND hWnd = GetActiveWindow();
      RECT rect;
      if (GetWindowRect(hWnd, &rect))
      {
        double width = rect.right - rect.left;
        double height = rect.bottom - rect.top;
        umap[flutter::EncodableValue("width")] = flutter::EncodableValue(width);
        umap[flutter::EncodableValue("height")] = flutter::EncodableValue(height);
      }
      flutter::EncodableValue response(umap);
      result->Success(&response);
    }
    else if (method.compare("getWindowPosition") == 0)
    {
      flutter::EncodableMap umap;
      HWND hWnd = GetActiveWindow();
      RECT rect;
      if (GetWindowRect(hWnd, &rect))
      {
        double x = rect.left;
        double y = rect.top;
        umap[flutter::EncodableValue("x")] = flutter::EncodableValue(x);
        umap[flutter::EncodableValue("y")] = flutter::EncodableValue(y);
      }
      flutter::EncodableValue response(umap);
      result->Success(&response);
    }
    else
    {
      result->NotImplemented();
    }
  }
}

void WindowControlPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  WindowControlPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
