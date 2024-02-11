#include "stdafx.h"
#include <comdef.h>
#include <ShellAPI.h>
#include <ShlObj.h>
#include <ExDisp.h>
#include <strsafe.h>
#include "Utils.h"
#include "LegacyUpdate_i.h"
#include "dllmain.h"

const LPCSTR UpdateSiteHostname     = "legacyupdate.net";
const LPWSTR UpdateSiteURLHttp      = L"http://legacyupdate.net/windowsupdate/v6/";
const LPWSTR UpdateSiteURLHttps     = L"https://legacyupdate.net/windowsupdate/v6/";
const LPWSTR UpdateSiteFirstRunFlag = L"?firstrun=true";

static BOOL CanUseSSLConnection() {
	// Get the Windows Update website URL set by Legacy Update setup
	LPWSTR data;
	DWORD size;
	HRESULT hr = GetRegistryString(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate", L"URL", NULL, &data, &size);
	if (!SUCCEEDED(hr)) {
		goto end;
	}

	// Return based on the URL value
	if (StrCmpW(data, UpdateSiteURLHttps) == 0) {
		return TRUE;
	} else if (StrCmpW(data, UpdateSiteURLHttp) == 0) {
		return FALSE;
	}

end:
	// Fallback: Use SSL only on Vista and up
	OSVERSIONINFOEX *versionInfo = GetVersionInfo();
	return versionInfo->dwMajorVersion > 5;
}

// Function signature required by Rundll32.exe.
void CALLBACK LaunchUpdateSite(HWND hwnd, HINSTANCE hInstance, LPSTR lpszCmdLine, int nCmdShow) {
	HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
	CComPtr<IWebBrowser2> browser;
	CComVariant url;
	CComVariant flags(0);
	CComVariant nullVariant;
	if (!SUCCEEDED(hr)) {
		goto end;
	}

	// If running on 2k/XP, make sure we're elevated. If not, show Run As prompt.
	if (GetVersionInfo()->dwMajorVersion < 6 && !IsUserAnAdmin()) {
		LPWSTR filename;
		DWORD filenameSize;
		GetOwnFileName(&filename, &filenameSize);
		WCHAR args[MAX_PATH + 20];
		StringCchPrintfW(args, filenameSize + 20, L"\"%ls\",LaunchUpdateSite", filename);

		// Ignore C4311 and C4302, which is for typecasts. It is due to ShellExec and should be safe to bypass.
		#pragma warning(disable: 4311 4302)
		int execResult = (int)ShellExecute(NULL, L"runas", L"rundll32.exe", args, NULL, SW_SHOWDEFAULT);
		#pragma warning(default: 4311 4302)

		// Access denied happens when the user clicks No/Cancel.
		if (execResult <= 32 && execResult != SE_ERR_ACCESSDENIED) {
			hr = E_FAIL;
		}
		goto end;
	}

	// Spawn an IE window via the COM interface. This ensures the page opens in IE (ShellExecute uses
	// default browser), and avoids hardcoding a path to iexplore.exe. Also conveniently allows testing
	// on Windows 11 (iexplore.exe redirects to Edge, but COM still works). Same strategy as used by
	// Wupdmgr.exe and Muweb.dll,LaunchMUSite.
	hr = browser.CoCreateInstance(CLSID_InternetExplorer, NULL, CLSCTX_LOCAL_SERVER);
	if (hr == REGDB_E_CLASSNOTREG) {
		// Handle case where the user has uninstalled Internet Explorer using Programs and Features.
		OSVERSIONINFOEX *versionInfo = GetVersionInfo();

		// Windows 8+: Directly prompt to reinstall IE using Fondue.exe.
		SYSTEM_INFO systemInfo;
		GetSystemInfo(&systemInfo);
		LPWSTR archSuffix = systemInfo.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64 ? L"amd64" : L"x86";

		WCHAR fondueArgs[256];
		StringCchPrintfW(fondueArgs, 256, L"/enable-feature:Internet-Explorer-Optional-%ls", archSuffix);
		#pragma warning(disable: 4311 4302)
		int execResult = (int)ShellExecute(NULL, L"open", L"fondue.exe", fondueArgs, NULL, SW_SHOWDEFAULT);
		#pragma warning(default: 4311 4302)

		if (execResult <= 32) {
			// Tell the user what they need to do, then open the Optional Features dialog.
			WCHAR message[4096];
			LoadString(g_hInstance, IDS_IENOTINSTALLED, message, ARRAYSIZE(message));
			MessageBox(hwnd, message, L"Legacy Update", MB_OK | MB_ICONEXCLAMATION);
			ShellExecute(NULL, L"open", L"OptionalFeatures.exe", NULL, NULL, SW_SHOWDEFAULT);
		}
		hr = S_OK;
		goto end;
	} else if (!SUCCEEDED(hr)) {
		goto end;
	}

	// Can we connect with https? WinInet will throw an error if not.
	LPWSTR siteURL = CanUseSSLConnection() ? UpdateSiteURLHttps : UpdateSiteURLHttp;

	// Is this a first run launch? Append first run flag if so.
	if (strcmp(lpszCmdLine, "firstrun") == 0) {
		WCHAR newSiteURL[256];
		StringCchPrintfW(newSiteURL, 256, L"%s%s", siteURL, UpdateSiteFirstRunFlag);
		siteURL = newSiteURL;
	}

	url = siteURL;
	hr = browser->Navigate2(&url, &flags, &nullVariant, &nullVariant, &nullVariant);
	if (!SUCCEEDED(hr)) {
		goto end;
	}

	HWND ieHwnd;
	hr = browser->get_HWND((SHANDLE_PTR *)&ieHwnd);
	if (!SUCCEEDED(hr)) {
		goto end;
	}

	// Are we on a small display? If so, resize and maximise the window.
	HMONITOR monitor = MonitorFromWindow(ieHwnd, MONITOR_DEFAULTTONEAREST);
	MONITORINFO monitorInfo;
	monitorInfo.cbSize = sizeof(MONITORINFO);

	if (GetMonitorInfo(monitor, &monitorInfo) > 0) {
		LONG workWidth = monitorInfo.rcWork.right - monitorInfo.rcWork.left;
		LONG workHeight = monitorInfo.rcWork.bottom - monitorInfo.rcWork.top;

		LONG width, height;
		browser->get_Width(&width);
		browser->get_Height(&height);

		if (width < 800) {
			width = min(800, workWidth);
			browser->put_Width(width);
		}
		if (height < 600) {
			height = min(600, workHeight);
			browser->put_Height(height);
		}

		LONG left, top;
		browser->get_Left(&left);
		browser->get_Top(&top);

		if (left + width > workWidth) {
			browser->put_Left(0);
		}
		if (top + height > workHeight) {
			browser->put_Top(0);
		}

		if (workWidth <= 1152) {
			ShowWindow(ieHwnd, SW_MAXIMIZE);
		}
	}

	browser->put_Visible(TRUE);

	// Focus the window, since it seems to not always get focus as it should.
	SetForegroundWindow(ieHwnd);

end:
	if (!SUCCEEDED(hr)) {
		MessageBox(NULL, GetMessageForHresult(hr), L"Legacy Update", MB_OK | MB_ICONEXCLAMATION);
	}

	browser = NULL;
	CoUninitialize();
}
