Function GetUpdateLanguage
	Var /GLOBAL UpdateLanguage
	${If} $UpdateLanguage == ""
		ReadRegStr $UpdateLanguage HKLM "${REGPATH_HARDWARE_SYSTEM}" "Identifier"
		${If} $UpdateLanguage == "NEC PC-98"
			StrCpy $UpdateLanguage "NEC98"
		${Else}
			ReadRegStr $UpdateLanguage HKLM "${REGPATH_CONTROL_LANGUAGE}" "InstallLanguage"
			ReadINIStr $UpdateLanguage $PLUGINSDIR\Patches.ini Language $UpdateLanguage
		${EndIf}
	${EndIf}
	Push $UpdateLanguage
FunctionEnd

!macro NeedsSPHandler name os sp
	Function Needs${name}
		${If} ${Is${os}}
		${AndIf} ${AtMostServicePack} ${sp}
			Push 1
		${Else}
			Push 0
		${EndIf}
	FunctionEnd
!macroend

!macro NeedsFileVersionHandler name file version
	Function Needs${name}
		${GetFileVersion} "$SYSDIR\${file}" $0
		${VersionCompare} $0 ${version} $1
		${If} $1 == 2 ; Less than
			Push 1
		${Else}
			Push 0
		${EndIf}
	FunctionEnd
!macroend

Var /GLOBAL Patch.Key
Var /GLOBAL Patch.File
Var /GLOBAL Patch.Title

Function -PatchHandler
	Call GetUpdateLanguage
	Call GetArch
	Pop $1
	Pop $0
	ClearErrors
	ReadINIStr $0 $PLUGINSDIR\Patches.ini "$Patch.Key" $0-$1
	${If} ${Errors}
		; Language neutral
		ClearErrors
		ReadINIStr $0 $PLUGINSDIR\Patches.ini "$Patch.Key" $1
		${If} ${Errors}
			StrCpy $0 "$Patch.Title"
			MessageBox MB_USERICON "$(MsgBoxPatchNotFound)" /SD IDOK
			SetErrorLevel 1
			Abort
		${EndIf}
	${EndIf}
	ReadINIStr $1 $PLUGINSDIR\Patches.ini "$Patch.Key" Prefix
	!insertmacro Download "$Patch.Title" "$1$0" "$Patch.File" 1
FunctionEnd

!define PATCH_FLAGS_OTHER 0
!define PATCH_FLAGS_NT4   1
!define PATCH_FLAGS_SHORT 2
!define PATCH_FLAGS_LONG  3

!macro -PatchHandlerFlags params cleanup
!if ${DEBUG} == 1
	; To make testing go faster
	StrCpy $R0 "${params} ${cleanup}"
!else
	; NT4 branch will add a SkipSPUninstall setting. For now, we ignore the cleanup param.
	StrCpy $R0 "${params}"
!endif
!macroend

!macro PatchHandler kbid title type params
	Function Download${kbid}
		${If} ${NeedsPatch} ${kbid}
			StrCpy $Patch.Key   "${kbid}"
			StrCpy $Patch.File  "${kbid}.exe"
			StrCpy $Patch.Title "${title}"
			Call -PatchHandler
		${EndIf}
	FunctionEnd

	Function Install${kbid}
		${IfNot} ${NeedsPatch} ${kbid}
			Return
		${EndIf}

		Call Download${kbid}
!if ${type} == ${PATCH_FLAGS_OTHER}
		StrCpy $R0 ""
!endif
!if ${type} == ${PATCH_FLAGS_NT4}
		!insertmacro -PatchHandlerFlags "-z"    "-n -o"
!endif
!if ${type} == ${PATCH_FLAGS_SHORT}
		!insertmacro -PatchHandlerFlags "-u -z" "-n -o"
!endif
!if ${type} == ${PATCH_FLAGS_LONG}
		!insertmacro -PatchHandlerFlags "/passive /norestart" "/n /o"
!endif
		!insertmacro Install "${title}" "${kbid}.exe" "$R0 ${params}"
	FunctionEnd
!macroend

!insertmacro NeedsSPHandler "W2KSP4"  "Win2000"   2
!insertmacro NeedsSPHandler "XPSP1a"  "WinXP2002" 0
!insertmacro NeedsSPHandler "XPSP3"   "WinXP2002" 2
!insertmacro NeedsSPHandler "XPESP3"  "WinXP2002" 2
!insertmacro NeedsSPHandler "2003SP2" "WinXP2003" 1

!insertmacro NeedsFileVersionHandler "W2KUR1" "kernel32.dll" "5.00.2195.7006"
!insertmacro NeedsFileVersionHandler "IE6"    "mshtml.dll"   "6.0.2600.0"

!insertmacro PatchHandler "W2KSP4"  "Windows 2000 $(SP) 4"      ${PATCH_FLAGS_SHORT} ""
!insertmacro PatchHandler "W2KUR1"  "$(SectionW2KUR1)"          ${PATCH_FLAGS_LONG}  ""
!insertmacro PatchHandler "XPSP1a"  "Windows XP $(SP) 1a"       ${PATCH_FLAGS_SHORT} ""
!insertmacro PatchHandler "XPSP3"   "Windows XP $(SP) 3"        ${PATCH_FLAGS_LONG}  ""
!insertmacro PatchHandler "2003SP2" "Windows XP $(P64)/$(SRV) 2003 $(SP) 2" ${PATCH_FLAGS_LONG} ""
!insertmacro PatchHandler "XPESP3"  "Windows XP $(EMB) $(SP) 3" ${PATCH_FLAGS_LONG}  ""

Function DownloadIE6
	${If} ${NeedsPatch} IE6
		StrCpy $Patch.Key   "W2KIE6"
		StrCpy $Patch.File  "ie6sp1.cab"
		StrCpy $Patch.Title "$(IE) 6 $(SP) 1 $(Setup)"
		Call -PatchHandler

		${IfNot} ${FileExists} "$PLUGINSDIR\W2KIE6\ie6setup.exe"
			${DetailPrint} "$(Extracting)$(IE) 6 $(SP) 1 $(Setup)..."
			CreateDirectory "$PLUGINSDIR\W2KIE6"
			!insertmacro ExecWithErrorHandling '$(IE) 6 $(SP) 1' '"$WINDIR\system32\expand.exe" -F:* ie6sp1.cab "$PLUGINSDIR\W2KIE6"'
			${DetailPrint} "$(Downloading)$(IE) 6 $(SP) 1..."
			!insertmacro ExecWithErrorHandling '$(IE) 6 $(SP) 1' '"$PLUGINSDIR\W2KIE6\ie6setup.exe" /c:"ie6wzd.exe /q /d /s:""#e"""'
		${EndIf}
	${EndIf}
FunctionEnd

Function InstallIE6
	${If} ${NeedsPatch} IE6
		Call DownloadIE6
		${DetailPrint} "$(Installing)$(IE) 6 $(SP) 1..."
		StrCpy $RunOnce.UseFallback 1
		!insertmacro ExecWithErrorHandling '$(IE) 6 $(SP) 1' '"$PLUGINSDIR\W2KIE6\ie6setup.exe" /c:"ie6wzd.exe /q /r:n /s:""#e"""'
	${EndIf}
FunctionEnd

Function FixW2KUR1
	; Fix idling on multi-CPU systems when Update Rollup 1 is installed
	WriteRegDWORD HKLM "SYSTEM\CurrentControlSet\Control\HAL" "14140000FFFFFFFF" 0x10
FunctionEnd
