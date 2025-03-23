; Product
!define NAME               "Legacy Update (Vichingo455's Mod)"
!define DOMAIN             "legacyupdate.net"

; Build
!if ${DEBUG} == 1
	!define VSBUILD32        "Debug-VC08"
	!define VSBUILD64        "Debug-VC17"
!else
	!define VSBUILD32        "Release"
	!define VSBUILD64        "Release"
!endif

; NSIS target
!ifdef NSIS_UNICODE
	!define NSIS_CHARSET     "unicode"
!else
	!define NSIS_CHARSET     "ansi"
!endif
!define NSIS_TARGET        "${NSIS_CPU}-${NSIS_CHARSET}"

; Version
!getdllversion "..\${VSBUILD32}\LegacyUpdate.dll" DLLVersion_
!define LONGVERSION        "${DLLVersion_1}.${DLLVersion_2}.${DLLVersion_3}.${DLLVersion_4}"
!define VERSION            "${LONGVERSION}"

!if ${DLLVersion_4} == 0
	!define /redef VERSION   "${DLLVersion_1}.${DLLVersion_2}.${DLLVersion_3}"
!endif

!if ${DLLVersion_3}.${DLLVersion_4} == 0.0
	!define /redef VERSION   "${DLLVersion_1}.${DLLVersion_2}"
!endif

; Main URLs
!define WEBSITE            "http://legacyupdate.net/"
!define UPDATE_URL         "http://legacyupdate.net/windowsupdate/v6/"
!define UPDATE_URL_HTTPS   "https://legacyupdate.net/windowsupdate/v6/"
!define WSUS_SERVER        "http://vichingo455.ddns.net/v6"
!define WSUS_SERVER_HTTPS  "https://vichingo455.ddns.net/v6"
!define WUR_WEBSITE        "http://windowsupdaterestored.com/"
!define TRUSTEDR           "http://download.windowsupdate.com/msdownload/update/v3/static/trustedr/en"

; Control Panel entry
!define CPL_GUID           "{FFBE8D44-E9CF-4DD8-9FD6-976802C94D9C}"
!define CPL_APPNAME        "LegacyUpdate"

; IE elevation policy
!define ELEVATIONPOLICY_GUID "{3D800943-0434-49F2-89A1-472A259AD982}"

; Legacy Update keys
!define REGPATH_LEGACYUPDATE_SETUP "Software\Hashbang Productions\Legacy Update\Setup"
!define REGPATH_UNINSTSUBKEY       "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"

; Control Panel entry
!define REGPATH_CPLNAMESPACE       "Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\${CPL_GUID}"
!define REGPATH_HKCR_CPLCLSID      "CLSID\${CPL_GUID}"

; System
!define REGPATH_HARDWARE_SYSTEM    "Hardware\Description\System"
!define REGPATH_CONTROL_LANGUAGE   "System\CurrentControlSet\Control\Nls\Language"
!define REGPATH_CONTROL_WINDOWS    "System\CurrentControlSet\Control\Windows"

; XP POSReady hack
!define REGPATH_POSREADY           "System\WPA\PosReady"

; RunOnce
!define REGPATH_SETUP              "System\Setup"
!define REGPATH_RUNONCE            "Software\Microsoft\Windows\CurrentVersion\RunOnce"
!define REGPATH_POLICIES_SYSTEM    "Software\Microsoft\Windows\CurrentVersion\Policies\System"
!define REGPATH_SECURITYCENTER     "Software\Microsoft\Security Center"

; Windows Update keys
!define REGPATH_WU                 "Software\Microsoft\Windows\CurrentVersion\WindowsUpdate"
!define REGPATH_WU_SERVICES        "${REGPATH_WU}\Services"

; Windows Update policies
!define REGPATH_WUPOLICY           "Software\Policies\Microsoft\Windows\WindowsUpdate"
!define REGPATH_WUAUPOLICY         "${REGPATH_WUPOLICY}\AU"

; CBS keys
!define REGPATH_CBS                "Software\Microsoft\Windows\CurrentVersion\Component Based Servicing"
!define REGPATH_CBS_REBOOTPENDING  "${REGPATH_CBS}\RebootPending"
!define REGPATH_CBS_PACKAGESPENDING  "${REGPATH_CBS}\PackagesPending"
!define REGPATH_CBS_REBOOTINPROGRESS "${REGPATH_CBS}\RebootInProgress"

; IE zone keys
!define REGPATH_INETSETTINGS       "Software\Microsoft\Windows\CurrentVersion\Internet Settings"
!define REGPATH_ZONEDOMAINS        "${REGPATH_INETSETTINGS}\ZoneMap\Domains"
!define REGPATH_ZONEESCDOMAINS     "${REGPATH_INETSETTINGS}\ZoneMap\EscDomains"

; IE elevation policy keys
!define REGPATH_ELEVATIONPOLICY    "Software\Microsoft\Internet Explorer\Low Rights\ElevationPolicy"

; SChannel protocol keys
!define REGPATH_SCHANNEL_PROTOCOLS "System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols"
!define REGPATH_DOTNET             "Software\Microsoft\.NETFramework"
!define REGPATH_DOTNET_V2          "${REGPATH_DOTNET}\v2.0.50727"
!define REGPATH_DOTNET_V4          "${REGPATH_DOTNET}\v4.0.30319"

; Roots update keys
!define ROOTSUPDATE_GUID           "{EF289A85-8E57-408d-BE47-73B55609861A}"
!define REGPATH_COMPONENTS         "Software\Microsoft\Active Setup\Installed Components"
