!macro SetFont font parent control
	GetDlgItem $0 ${parent} ${control}
	SendMessage $0 ${WM_SETFONT} ${font} 0
!macroend

!macro SetControlColor parent control color
	GetDlgItem $0 ${parent} ${control}
	SetCtlColors $0 ${color} SYSCLR:WINDOW
!macroend

!macro SetBackground parent control
	!insertmacro SetControlColor ${parent} ${control} SYSCLR:WINDOWTEXT
!macroend

Var /GLOBAL ChildHwnd

!macro -AeroWizardOnShow
	; Get the child window where the wizard page is
	FindWindow $ChildHwnd "#32770" "" $HWNDPARENT

	; Set font
	${If} ${AtLeastWinVista}
		; Aero wizard style
		${If} ${AtLeastWin11}
			; Semi-Fluent style
			CreateFont $3 "Segoe UI Variable Display Semibold" 14 600
			!insertmacro SetControlColor $HWNDPARENT 1037 SYSCLR:WINDOWTEXT
		${Else}
			CreateFont $3 "Segoe UI" 12 400
			!insertmacro SetControlColor $HWNDPARENT 1037 0x003399
		${EndIf}
		CreateFont $2 "Segoe UI" 8 400
		!insertmacro SetFont $3 $HWNDPARENT 1037
		!insertmacro SetFont $2 $HWNDPARENT 1
		!insertmacro SetFont $2 $HWNDPARENT 2
		!insertmacro SetFont $2 $HWNDPARENT 3
		!insertmacro SetFont $2 $HWNDPARENT 1028
		!insertmacro SetFont $2 $ChildHwnd 1000
		!insertmacro SetFont $2 $ChildHwnd 1004
		!insertmacro SetFont $2 $ChildHwnd 1006
		!insertmacro SetFont $2 $ChildHwnd 1016
		!insertmacro SetFont $2 $ChildHwnd 1022
		!insertmacro SetFont $2 $ChildHwnd 1023
		!insertmacro SetFont $2 $ChildHwnd 1029
		!insertmacro SetFont $2 $ChildHwnd 1027
		!insertmacro SetFont $2 $ChildHwnd 1032
		!insertmacro SetFont $2 $ChildHwnd 1043
	${Else}
		; Wizard97 style
		${If} ${FileExists} "$FONTS\framd.ttf"
			CreateFont $2 "Franklin Gothic Medium" 13 400
			!insertmacro SetFont $2 $HWNDPARENT 1037
			!insertmacro SetControlColor $HWNDPARENT 1037 0x003399
		${Else}
			CreateFont $2 "Verdana" 12 800
			!insertmacro SetFont $2 $HWNDPARENT 1037
			!insertmacro SetControlColor $HWNDPARENT 1037 SYSCLR:WINDOWTEXT
		${EndIf}
	${EndIf}

	; Set white background
	SetCtlColors $HWNDPARENT SYSCLR:WINDOWTEXT SYSCLR:WINDOW
	SetCtlColors $ChildHwnd  SYSCLR:WINDOWTEXT SYSCLR:WINDOW
	!insertmacro SetBackground $ChildHwnd 1020
	!insertmacro SetBackground $ChildHwnd 1028
	!insertmacro SetBackground $ChildHwnd 1006
	!insertmacro SetBackground $ChildHwnd 1022
	!insertmacro SetBackground $ChildHwnd 1023
	!insertmacro SetBackground $ChildHwnd 1027
	!insertmacro SetBackground $ChildHwnd 1029
	!insertmacro SetBackground $ChildHwnd 1032
	!insertmacro SetBackground $ChildHwnd 1043

	; Activate taskbar progress bar plugin
	${If} ${AtLeastWin7}
		LegacyUpdateNSIS::InitTaskbarProgress
	${EndIf}
!macroend

Function AeroWizardOnShow
	!insertmacro -AeroWizardOnShow
FunctionEnd

Function un.AeroWizardOnShow
	!insertmacro -AeroWizardOnShow
FunctionEnd
