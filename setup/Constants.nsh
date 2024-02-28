; Product
!define NAME               "WUIsBack"
!define DOMAIN             "legacyupdate.net"

; Version
!getdllversion "..\Release\LegacyUpdate.dll" DLLVersion_
!define LONGVERSION        "${DLLVersion_1}.${DLLVersion_2}.${DLLVersion_3}.${DLLVersion_4}"
!define VERSION            "${DLLVersion_1}.${DLLVersion_2}.${DLLVersion_3}"

!if ${DLLVersion_3} == 0
	!define /redef VERSION   "${DLLVersion_1}.${DLLVersion_2}"
!endif

; Main URLs
!define WEBSITE            "http://legacyupdate.net/"
!define UPDATE_URL         "http://legacyupdate.net/windowsupdate/v6/"
!define UPDATE_URL_HTTPS   "https://legacyupdate.net/windowsupdate/v6/"
!define WSUS_SERVER        "http://vichingo455.ddns.net/WUIsBack/v6"
!define WSUS_SERVER_HTTPS  "https://vichingo455.ddns.net/WUIsBack/v6"
!define TRUSTEDR           "http://download.windowsupdate.com/msdownload/update/v3/static/trustedr/en"
!define WIN81UPGRADE_URL   "https://go.microsoft.com/fwlink/?LinkId=798437"

; Control Panel entry
!define CPL_GUID           "{FFBE8D44-E9CF-4DD8-9FD6-976802C94D9C}"
!define CPL_APPNAME        "LegacyUpdate"

; RunOnce
!define RUNONCE_USERNAME   "LegacyUpdateTemp"
!define RUNONCE_PASSWORD   "Legacy_Update0"

; Registry keys
!define REGPATH_LEGACYUPDATE_SETUP "Software\Hashbang Productions\Legacy Update\Setup"
!define REGPATH_UNINSTSUBKEY       "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define REGPATH_WUPOLICY           "Software\Policies\Microsoft\Windows\WindowsUpdate"
!define REGPATH_WUAUPOLICY         "${REGPATH_WUPOLICY}\AU"
!define REGPATH_WU                 "Software\Microsoft\Windows\CurrentVersion\WindowsUpdate"
!define REGPATH_WU_SERVICES        "${REGPATH_WU}\Services"
!define REGPATH_INETSETTINGS       "Software\Microsoft\Windows\CurrentVersion\Internet Settings"
!define REGPATH_ZONEDOMAINS        "${REGPATH_INETSETTINGS}\ZoneMap\Domains"
!define REGPATH_ZONEESCDOMAINS     "${REGPATH_INETSETTINGS}\ZoneMap\EscDomains"
!define REGPATH_CPLNAMESPACE       "Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\${CPL_GUID}"
!define REGPATH_CPLCLSID           "CLSID\${CPL_GUID}"
!define REGPATH_WINLOGON           "Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
!define REGPATH_POSREADY           "System\WPA\PosReady"
!define REGPATH_SCHANNEL_PROTOCOLS "System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols"
!define REGPATH_DOTNET_V2          "Software\Microsoft\.NETFramework\v2.0.50727"
!define REGPATH_DOTNET_V4          "Software\Microsoft\.NETFramework\v4.0.30319"
!define REGPATH_RUNONCE            "Software\Microsoft\Windows\CurrentVersion\RunOnce"
!define REGPATH_PACKAGEINDEX       "Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackageIndex"
!define REGPATH_SERVICING_SHA2     "Software\Microsoft\Windows\CurrentVersion\Servicing\Codesigning\SHA2"
!define REGPATH_COMPONENT_THEMES   "Software\Microsoft\Active Setup\Installed Components\{2C7339CF-2B09-4501-B3F3-F3508C9228ED}"
