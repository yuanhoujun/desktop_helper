#include <Windows.h>
#include <atlbase.h>

#include <iostream>
#include <vector>
#include <ShlObj.h>
#include <commoncontrols.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <list>

#pragma comment(lib, "Comctl32.lib")

using namespace std;

namespace
{
    class WindowsUtil
    {
    public:
        static flutter::EncodableList GetAssociateAppsWithFile(string path);
        static LPCWSTR StringToLPCWSTR(std::string origin);
        static char *WcharToChar(wchar_t *str);
    };

    flutter::EncodableList WindowsUtil::GetAssociateAppsWithFile(string path)
    {
        string extension = path.substr(path.find_last_of("."));
        LPCWSTR lpExt = WindowsUtil::StringToLPCWSTR(extension);

        IEnumAssocHandlers *enumAssocHandler = NULL;

        IAssocHandler *assocHandler = NULL;
        HRESULT result = SHAssocEnumHandlers(lpExt, ASSOC_FILTER_RECOMMENDED, &enumAssocHandler);

        flutter::EncodableList apps;

        if (SUCCEEDED(result))
        {
            ULONG celtFetched = 0;

            while (SUCCEEDED(enumAssocHandler->Next(1, &assocHandler, &celtFetched)))
            {
                if (assocHandler == NULL)
                    break;

                flutter::EncodableMap app = flutter::EncodableMap();

                WCHAR *pFilePath = NULL;
                WCHAR *pFileName = NULL;

                if (SUCCEEDED(assocHandler->GetName(&pFilePath)) && SUCCEEDED(assocHandler->GetUIName(&pFileName)))
                {
                    char *filePath = WindowsUtil::WcharToChar(pFilePath);
                    char *fileName = WindowsUtil::WcharToChar(pFileName);

                    cout << string(filePath) << endl;
                    cout << string(fileName) << endl;

                    app[flutter::EncodableValue("url")] = flutter::EncodableValue(string(filePath));
                    app[flutter::EncodableValue("name")] = flutter::EncodableValue(string(fileName));
                    app[flutter::EncodableValue("bundleId")] = flutter::EncodableValue("");

                    HIMAGELIST hil;

                    result = SHGetImageList(SHIL_JUMBO, IID_IImageList, (void **)&hil);

                    if (SUCCEEDED(result))
                    {
                        SHFILEINFO sfi;
                        SHGetFileInfo(pFilePath, 0, &sfi, sizeof(sfi),
                                      SHGFI_SYSICONINDEX);

                        HICON icon = ImageList_GetIcon(hil, sfi.iIcon, ILD_NORMAL);

                        ICONINFO iconInfo;
                        BOOL isSuccess = GetIconInfo(icon, &iconInfo);

                        if (!isSuccess)
                        {
                            cout << "Get icon info failure." << endl;
                        }

                        HBITMAP hBitmap = iconInfo.hbmColor;

                        BITMAPINFO bmpInfo = {0};
                        bmpInfo.bmiHeader.biSize = sizeof(bmpInfo.bmiHeader);

                        HDC hdc = CreateCompatibleDC(GetDC(0));

                        int ret = GetDIBits(hdc, hBitmap, 0, 0, NULL, &bmpInfo, DIB_RGB_COLORS);

                        if (ret == 0)
                        {
                            cout << "Get bitmap info failure." << endl;
                        }
                        else
                        {
                            BYTE *lpPixels = new BYTE[bmpInfo.bmiHeader.biSizeImage];

                            bmpInfo.bmiHeader.biCompression = BI_RGB;

                            ret = GetDIBits(hdc, hBitmap, 0, bmpInfo.bmiHeader.biHeight, (LPVOID)lpPixels, &bmpInfo, DIB_RGB_COLORS);

                            if (ret == 0)
                            {
                                std::cout << "Get bitmap data failure." << std::endl;
                            }
                            else
                            {
                                flutter::EncodableList iconData;
                                for (unsigned int i = 0; i < bmpInfo.bmiHeader.biSizeImage; i++)
                                {
                                    iconData.push_back(lpPixels[i]);
                                }
                                app[flutter::EncodableValue("icon")] = iconData;
                            }
                        }

                        apps.push_back(app);
                        DestroyIcon(icon);
                    }
                }

                assocHandler->Release();
            }

            enumAssocHandler->Release();
        }

        return apps;
    }

    LPCWSTR WindowsUtil::StringToLPCWSTR(string origin)
    {
        size_t origsize = origin.length() + 1;
        size_t convertedChars = 0;
        wchar_t *wcstring = new wchar_t[sizeof(wchar_t) * (origin.length() - 1)];
        mbstowcs_s(&convertedChars, wcstring, origsize, origin.c_str(), _TRUNCATE);
        return wcstring;
    }

    char *WindowsUtil::WcharToChar(wchar_t *str)
    {
        int bufSize = WideCharToMultiByte(CP_ACP, NULL, str, -1, NULL, 0, NULL, FALSE);
        char *ch = new char[bufSize];
        WideCharToMultiByte(CP_ACP, NULL, str, -1, ch, bufSize, NULL, FALSE);
        std::string(ch, bufSize);
        return ch;
    }
}