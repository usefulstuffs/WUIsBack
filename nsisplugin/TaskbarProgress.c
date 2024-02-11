// Based on https://nsis.sourceforge.io/TaskbarProgress_plug-in - zlib licensed
// Cleaned up and refactored into C by Legacy Update
#define CINTERFACE
#define COBJMACROS
#include <windows.h>
#include <nsis/pluginapi.h>
#include <commctrl.h>
#include <objbase.h>
#include <shobjidl.h>
#include "main.h"

static const GUID our_CLSID_ITaskbarList = { 0x56fdf344, 0xfd6d, 0x11d0, { 0x95, 0x8a, 0x00, 0x60, 0x97, 0xc9, 0xa0, 0x90 } };
static const GUID our_IID_ITaskbarList3  = { 0xea1afb91, 0x9e28, 0x4b86, { 0x90, 0xe9, 0x9e, 0x9f, 0x8a, 0x5e, 0xef, 0xaf } };

ITaskbarList3 *g_taskbarList;
UINT g_totalRange;
WNDPROC g_origWndProc;

LRESULT ProgressBarWndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	if (g_origWndProc == NULL) {
		return 0;
	}

	switch (uMsg) {
	case PBM_SETRANGE:
		g_totalRange = LOWORD(lParam) + HIWORD(lParam);
		break;

	case PBM_SETRANGE32:
		g_totalRange = wParam + lParam;
		break;

	case PBM_SETPOS:
		if (g_taskbarList != NULL) {
			ITaskbarList3_SetProgressValue(g_taskbarList, g_hwndParent, wParam, g_totalRange);
		}
		break;

	case WM_DESTROY:
		SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR)g_origWndProc);

		if (g_taskbarList != NULL) {
			ITaskbarList3_SetProgressState(g_taskbarList, g_hwndParent, TBPF_NOPROGRESS);
			ITaskbarList3_Release(g_taskbarList);
			g_taskbarList = NULL;
		}

		g_origWndProc = NULL;
		break;
	}

	return CallWindowProc(g_origWndProc, hwnd, uMsg, wParam, lParam);
}

UINT_PTR NSISPluginCallback(enum NSPIM event) {
	// Does nothing, but keeping a callback registered prevents NSIS from unloading the plugin
	return 0;
}

EXTERN_C __declspec(dllexport)
void __cdecl InitTaskbarProgress(HWND hwndParent, int string_size, TCHAR *variables, stack_t **stacktop, extra_parameters *extra) {
	EXDLL_INIT();
	g_hwndParent = hwndParent;

	extra->RegisterPluginCallback(g_hInstance, NSISPluginCallback);

	if (g_taskbarList != NULL && g_origWndProc != NULL) {
		// Already initialised
		return;
	}

	HWND innerWindow = FindWindowEx(g_hwndParent, NULL, L"#32770", NULL);
	HWND progressBar = FindWindowEx(innerWindow, NULL, L"msctls_progress32", NULL);
	PBRANGE range;
	HRESULT hr;

	if (progressBar == NULL) {
		goto fail;
	}

	hr = CoCreateInstance(our_CLSID_ITaskbarList, NULL, CLSCTX_INPROC_SERVER, our_IID_ITaskbarList3, (void**)&g_taskbarList);
	if (!SUCCEEDED(hr)) {
		goto fail;
	}

	hr = ITaskbarList3_HrInit(g_taskbarList);
	if (!SUCCEEDED(hr)) {
		goto fail;
	}

	// Get the initial progress bar range
	SendMessage(progressBar, PBM_GETRANGE, 0, (LPARAM)&range);
	g_totalRange = range.iLow + range.iHigh;

	// Add our own window procedure so we can respond to progress bar updates
	g_origWndProc = (WNDPROC)SetWindowLongPtr(progressBar, GWLP_WNDPROC, (LONG_PTR)ProgressBarWndProc);
	if (g_origWndProc == NULL) {
		goto fail;
	}
	return;

fail:
	if (g_taskbarList != NULL) {
		ITaskbarList3_Release(g_taskbarList);
		g_taskbarList = NULL;
	}

	g_origWndProc = NULL;
}
