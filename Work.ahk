#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#WinActivateForce
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, RegEx
SetNumlockState, AlwaysOn
SetCapsLockState, AlwaysOff
CoordMode, Mouse, Screen
DetectHiddenWindows, On
SetScrollLockState, Off

Menu, Tray, Tip, Work Script

If (FileExist(A_ScriptDir "\lib\images\testing.ico"))
	Menu, Tray, Icon, % A_ScriptDir "\lib\images\testing.ico"

; Globals
SysGet, MonitorCount, MonitorCount
SysGet, MonitorWorkArea, MonitorWorkArea
EnvGet, Domain, USERDOMAIN
UserDir := "C:\Users\" A_UserName
Editor := "C:\Program Files\Microsoft VS Code\Code.exe"
kbdIndex := 17 ; GMMK

Notify(A_ScriptName " Started!","",-3,"Style=Win10")

SetTimer, IntroSound, -1
SetTimer, IntroLights, -1

CheckAdmin()

RunIfExist(A_ScriptDir "\Utilities\VolumeScroll\VolumeScroll.ahk")
RunIfExist(A_ScriptDir "\Core\AutoCorrect.ahk")
Run, %A_ScriptDir%\Utilities\WindowPadX\WindowPadX.ahk %A_ScriptDir%\WindowPadX.Custom.ini

IfWinNotExist, ahk_exe clipx.exe
	RunProgFiles("ClipX\clipx.exe")

CreateStartupShortcut()
Return ; End Auto-Execute

IntroSound:
	SoundPlay, lib\sounds\signon.wav
	Return

IntroLights:
	Loop, 4 ; Single controllable LED on GMMK
	{
		KeyboardLED(4,"switch", kbdIndex)
		Sleep, 100
		KeyboardLED(0,"off", kbdIndex)
		Sleep, 100
	}
	KeyboardLED(0,"off", kbdIndex)
	Return

#Include %A_ScriptDir%\Core\Functions.ahk
#Include %A_ScriptDir%\Core\Shortcuts.ahk
#Include %A_ScriptDir%\Core\AppSpecific.ahk
#Include %A_ScriptDir%\Core\Hotstrings.ahk

#Include *i %A_ScriptDir%\Utilities\FormatAHK.ahk
; #Include *i %A_ScriptDir%\Core\WinControl.ahk

^!r::	Reload
^!e::	Edit(".", Editor)
^!t::	Edit("test.ahk", Editor)
^!h::	Edit("Core\Hotstrings.ahk", Editor)
^!a::	Edit("Core\AppSpecific.ahk", Editor)
^!m::	Edit("Core\Functions.ahk", Editor)
!t::	Run, Test.ahk

^NumpadEnter::Edit("Core\Shortcuts.ahk", Editor)

+Pause::Suspend

^!x::AHKPanic(1,0,0,1)

#Include %A_ScriptDir%\lib\VA.ahk
#Include %A_ScriptDir%\lib\TF.ahk
#Include %A_ScriptDir%\lib\Notify.ahk
#Include %A_ScriptDir%\lib\Explorer.ahk
#Include %A_ScriptDir%\lib\Ledcontrol.ahk
