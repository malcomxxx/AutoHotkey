;http://www.autohotkey.com/board/topic/42578-lib-ini-v10-basic-ini-string-functions/
;http://www.autohotkey.com/board/topic/76802-embedded-parsing-loop-and-listview/
;http://www.autohotkey.com/board/topic/63764-load-an-ini-file-in-listview-gui-control-in-autohotkey/
;http://www.autohotkey.com/board/topic/64658-listview-checkboxes/

#NoEnv 
#Singleinstance force
SendMode Input 
SetWorkingDir %A_ScriptDir%

RunNum := 1
DebugFile := "\\draven\Testing\debug.log"
DebugHistFile := "\\draven\Testing\debughist.log"
Testsini := "\\draven\Testing\TestComplete\TestComplete.ini"
TCFile := "\\draven\Testing\TestComplete\TestComplete.ahk"

;Run, newbuildmonitor.ahk

Begin:

Menu, Tray, NoStandard

if ! A_IsCompiled
    Menu, Tray, Icon, lib\images\testing.ico

Menu, Tray, Tip, Test Config
Menu, Tray, Add, Load GUI, Load
Menu, Tray, Add, Always On Top, OnTop
Menu, Tray, Default, Load gui
Menu, Tray, Add
Menu, Tray, Add, Edit Script, EditScript
Menu, Tray, Add, Reload, ReloadMenu
Menu, Tray, Add, Exit, ExitMenu

Menu, FileMenu, Add, &Edit, EditScript
Menu, FileMenu, Add, &Reload , ReloadMenu  ; See remarks below about Ctrl+O.
Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit, ExitMenu
Menu, ScriptMenu, Add, &Reload All, ReloadAll
Menu, ScriptMenu, Add
Menu, ScriptMenu, Add, &TestComplete.ahk, TCFileMenu
Menu, Scriptmenu, Add, &Debug, DebugFileMenu
Menu, Scriptmenu, Add, &Clear Debug, ClearDebugFileMenu
Menu, Scriptmenu, Add
Menu, ScriptMenu, Add, Tests.&ini, TestsiniMenu
Menu, MyMenuBar, Add, &File, :FileMenu
Menu, MyMenuBar, Add, &Scripts, :ScriptMenu
Gui, Menu, MyMenuBar

Notify("Loading Test Config","",-1,"GC=555555 TC=White MC=White Style=Mine")


path := ini_load(ini, "\\draven\Testing\TestComplete\TestComplete.ini")

;Gui, Add, Tab2, x5 y5 w320 h175 0x2000 , Tests|Builds|Monitor|Console
;Gui, Tab, 1
Gui, Add, ListView, x10 y10 w150 h135 r20 hwndHLV Checked NoSort, Branch
Gui, Add, Checkbox, x180 y25 w70 h20 vGP2010, GP 2010
Gui, Add, Checkbox, x180 y45 w70 h20 vGP2010_2, GP 2010_2
Gui, Add, CheckBox, x180 y65 w70 h20 vGP2013, GP 2013
Gui, Add, Checkbox, x180 y85 w70 h20 vGP10, GP 10
Gui, Add, Button, x170 y120 w65 h25 Default, Submit
Gui, Add, Button, x245 y120 w65 h25 gStart, Start Tests
Gui, Add, GroupBox, x170 y5 w140 h110 , Testing Machines
Gui, Font, w600

; Check if environments are online
If IsOnline("TESTING-PC")
    ;Guicontrol,, GP2010, 1
Gui, Add, Text, c%statuscolor% x262 y28 w40 h22 , % statusname
If IsOnline("SMARTBEAR")
   Guicontrol,, GP2010_2, 1
Gui, Add, Text, c%statuscolor% x262 y48 w40 h22 , % statusname
If IsOnline("SQL2005")
   ; Guicontrol,, GP10, 1
Gui, Add, Text, c%statuscolor% x262 y88 w40 h22 , % statusname
If IsOnline("GP2013")
   ; Guicontrol,, GP2013, 1
Gui, Add, Text, c%statuscolor% x262 y68 w40 h20 , % statusname
sections := ini_getAllSectionNames(ini)

BuildArray := []
Loop, Parse, sections, `,
{
    BuildArray[A_Index] := A_LoopField
    ;msgbox % BuildArray[A_Index]
    LV_Add("Check" ini_getValue(ini, A_LoopField, "Run"), A_LoopField)
}

;LV_ModifyCol()  ; Auto-size each column to fit its contents.
LV_ModifyCol(2)  ; For sorting purposes.

Gui, Font, w400

;;; Monitor

Gui, Add, GroupBox, x10 y155 w300 h50 , Monitor

Gui, Add, DDL, x22 y172 w100 h200 Choose1 vBranch, Release|HotFix|Custom|CustomRelease|ServPack


;Gui, Add, Radio, x22 y172 w70 h12 vBranch, Release
;Gui, Add, Radio, x22 y192 w70 h12 , HotFix
;Gui, Add, Radio, x22 y212 w70 h12 , Custom
;Gui, Add, Radio, x22 y232 w70 h12 , ServPack
;Gui, Add, Radio, x122 y172 w100 h12, CustomRelease
Gui, Add, Checkbox, x140 y172 w70 h20 vAutoRun, AutoRun?
Gui, Add, Button, x220 y172 w80 h20 gMonitor, Start Monitor

;;; Console ;;;
GoSub, Console
Gui, Add, Edit, x320 y9 w400 h410 vVar -Wrap ReadOnly
SetTimer, Console, 5000
GuiControl,,Var,%StrTemp%


;;; Latest Builds ;;;

Gui, Add, GroupBox, x10 y210 w300 h200 , Builds

Gui, Add, Text, x20 y230, Release: 
Gui, Add, Text, x20 y250, HotFix: 
Gui, Add, Text, x20 y270, Custom: 
Gui, Add, Text, x20 y290, CustomRel: 
Gui, Add, Text, x20 y310, ServPack: 

Gui, Font, w600
Gui, Add, Text, x90 y230 w100 vLatestRelease, 
Gui, Add, Text, x90 y250 w100 vLatestHotFix, 
Gui, Add, Text, x90 y270 w100 vLatestCustom, 
Gui, Add, Text, x90 y290 w100 vLatestCustomRelease, 
Gui, Add, Text, x90 y310 w100 vLatestServPack, 
Gui, Font, w400
Gui, Add, Text, x180 y230 w100 vLatestReleaseDate
Gui, Add, Text, x180 y250 w100 vLatestHotFixDate
Gui, Add, Text, x180 y270 w100 vLatestCustomDate
Gui, Add, Text, x180 y290 w100 vLatestCustomReleaseDate
Gui, Add, Text, x180 y310 w100 vLatestServPackDate

;Gui, Add, Checkbox, x260 y230 w10 h20 vLatestReleaseTestNeeded,
;Gui, Add, Checkbox, x260 y250 w10 h20 vLatestHotFixTestNeeded,
;Gui, Add, Checkbox, x260 y270 w10 h20 vLatestCustomTestNeeded,
;Gui, Add, Checkbox, x260 y290 w10 h20 vLatestCustomReleaseTestNeeded,
;Gui, Add, Checkbox, x260 y310 w10 h20 vLatestServPackTestNeeded,

Gosub, FindLatest
SetTimer, FindLatest, 30000


;;; Gui Setup ;;;
Gui, Color, White
WinSet, Transparent, 0 , Test Configuration

Gui, Show, h425 w728, Test Configuration
FadeIn("Test Configuration", 1200)
Winset, AlwaysOnTop, on, Test Configuration
SetTimer, TransCheck, 100

countbeforeRelease := countBuilds("Release")
countbeforeHotFix := countBuilds("HotFix")
countbeforeServPack := countBuilds("ServPack")
countbeforeCustom := countBuilds("Custom")
;SetTimer, CheckBuilds, 60000
Return

;;;;;; End Main Prog ;;;;;;

Start:

    Gui, Submit, NoHide

    Loop, % LV_GetCount()
    {
        LV_GetText(Branch, A_Index)
        If LV_IsRowChecked(HLV, A_Index)
            ini_replaceValue(ini, Branch, "Run", 1)
        Else
            ini_replaceValue(ini, Branch, "Run", 0)
    }

    path := ini_save(ini, "\\draven\Testing\TestComplete\TestComplete.ini")

    if GP10 = 1
        FileAppend, , \\draven\Testing\TestComplete\SQL2005.trigger
    if GP2010 = 1
        FileAppend, , \\draven\Testing\TestComplete\TESTING-PC.trigger
    if GP2010_2 = 1
        FileAppend, , \\draven\Testing\TestComplete\SMARTBEAR.trigger
    if GP2013 = 1
        FileAppend, , \\draven\Testing\TestComplete\GP2013.trigger

    ;RunWait, %comspec% /c "schtasks /run /s "gp2013" /tn LaunchTests",, Hide  

Return

Buttonsubmit:

    Gui, Submit, NoHide

    Loop, % LV_GetCount()
    {
        LV_GetText(Branch, A_Index)
        If LV_IsRowChecked(HLV, A_Index)
            ini_replaceValue(ini, Branch, "Run", 1)
        Else
            ini_replaceValue(ini, Branch, "Run", 0)
        ;msgbox % ini_getValue(ini, Branch, "Run")
    }

    path := ini_save(ini, "\\draven\Testing\TestComplete\TestComplete.ini")
    ;Run, %path%
Return

Load:
    Gui, Destroy
    GoSub, Begin
Return

OnTop:

    WinGet, appWindow, ID, Test Configuration
    WinGet, ExStyle, ExStyle, ahk_id %appWindow%
    if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
    {
       Winset, AlwaysOnTop, off, ahk_id %appWindow%
       Menu, Tray, Uncheck, Always On Top
       SplashImage,, x0 y0 b fs12, OFF always on top.
       Sleep, 500
       SplashImage, Off
    }
    else
    {
       WinSet, AlwaysOnTop, on, ahk_id %appWindow%
       Menu, Tray, Check, Always On Top
       SplashImage,,x0 y0 b fs12, ON always on top.
       Sleep, 500
       SplashImage, Off
    }
Return


;ini_replaceValue(ini, "Release", "Run", 1)
;msgbox % ini_getValue(ini, "Release", "Run")



LV_IsRowChecked(HLV, Row) {
   ; HLV  HWND of the ListView control
   ; Row  One-based row number
   Static LVIS_STATEIMAGEMASK := 0xF000   ; http://www.autohotkey.com/community/viewtopic.php?p=530415#p530415
   Static LVM_GETITEMSTATE  := 0x102C   ; http://msdn.microsoft.com/en-us/library/bb761053(VS.85).aspx
   SendMessage, LVM_GETITEMSTATE, Row - 1, LVIS_STATEIMAGEMASK, , ahk_id %HLV%
   Return (((ErrorLevel & LVIS_STATEIMAGEMASK) >> 12) = 2) ? True : False
}

IsOnline(machine)
{
  global
  Runwait,%comspec% /c ping -n 1 -w 50 %machine%>ping.log,,hide 
  FileRead, pingTemp, ping.log
  FileDelete ping.log
  if Instr(pingTemp, "Received = 1")
  {
    statusname = Online
    statuscolor = green
    return 1
  }
  else
  {
    statusname = Offline
    statuscolor = red
    return 0
  }
   
}

Monitor:

    Gui Submit, NoHide
    
    Menu, Tray, Tip, Monitoring: %branch% Auto: %AutoRun% 
    SetTimer, CheckSingleBuild, 60000
    countbefore := countSingleBuild()
    ;countbefore := 0 ; testing

    CheckSingleBuild:

        countafter := countSingleBuild()
        if (countafter > countbefore)
        {

            Notify("New " branch " Build Found","",-10,"Style=Mine BW=0 BC=White GC=Red AC=RunTests")
            Loop 5
            {
                SoundPlay, lib\meta-online.wav
                Sleep 1000
            }
            ;RunWait, %comspec% /c "schtasks /run /s testing-pc /tn LaunchTests",, Hide
            ;FileAppend,, \\draven\Testing\TestComplete\trigger-smartbear.txt
            SetTimer, CheckSingleBuild, Off
            Menu, Tray, Tip, Testing Config
        }
        ;else
            ;Notify("Before- " . countbefore . " After- " . countafter,"",-1,"Style=Mine")
return

GetLatest:

    ;; Define installer and install dir
    setupfile := "C:\SalesPad.Setup.exe"
    installpath := "C:\Program Files (x86)\SalesPad.GP\"

    ;; Find newest installer
    Loop, \\draven\Builds\SalesPad4\SalesPad_4_%A_GuiControl%\*, 2, 0
    {
         FileGetTime, Time, %A_LoopFileFullPath%, C
         If (Time > Time_Orig)
         {
              Time_Orig := Time
              Folder := A_LoopFileName
         }
    }

    Loop, \\draven\Builds\SalesPad4\SalesPad_4_%A_GuiControl%\%Folder%\*WithCardControl.exe, 0, 1
    {
        FileGetTime, thetime, %A_LoopFileFullPath%, C
        ;msgbox % thetime
        ;FormatTime, CreateTime,CreateTime, M/d h:mm tt
        File := A_LoopFileName
        FullFile := A_LoopFileFullPath
        FormatTime, CreationDate, %thetime%, ddd, M/dd, h:mm tt
    }
        
    MsgBox, 36,SalesPad Download, %A_GuiControl%: %Folder% `n`nCreated: %CreationDate%`n`nDo you want to install it?
    IfMsgBox No
    {
        Return
    }       


    ;; Remove old install file
    if FileExist(setupfile)
        FileDelete,  %setupfile%

    ;; Copy and rename installer
    FileCopy, %FullFile%, %setupfile%
    ;; Stop if file was not pulled
    if ! FileExist(setupfile)
    {
        msgbox,,Install Failed, Install file does not exist
        ExitApp
    }
    ;; Run installer
    Run, %setupfile%


    WinWaitActive, SalesPad.GP
    Send, {Enter}
    WinGetTitle, Title, A
    StringReplace, Title, Title, SalesPad.GP
    StringReplace, Title, Title, Setup
    StringReplace, Title, Title, %A_SPACE%,,All
    path := "C:\Program Files (x86)\SalesPad.GP " . A_GuiControl . "\" . Title
    Send % path
    Send {Enter}
    Sleep 50
    Send {Enter}

    Loop 
    {
        ControlGet, OutputVar, Enabled,, Button2, SalesPad.GP
        ;msgbox % OutputVar
        if OutputVar = 1
          break
        Sleep 500   
    }
    Send {Enter}

return

Console:
    If (TF_CountLines("\\draven\Testing\debug.log") >= 30)
        StrTemp := TF_ReadLines("\\draven\Testing\debug.log",TF_CountLines("\\draven\Testing\debug.log") - 30,,1)
    else
        StrTemp := TF_ReadLines("\\draven\Testing\debug.log")
    
    ;FileRead, StrTemp, \\draven\Testing\debug.log
    GuiControl,,Var,%StrTemp%
return

BuildStatus:
    If (TF_CountLines("C:\Users\elliotd\Dropbox\HomeShare\buildstatus.log") >= 14)
        StrTemp2 := TF_ReadLines("C:\Users\elliotd\Dropbox\HomeShare\buildstatus.log",1,14,1)
    else
        StrTemp2 := TF_ReadLines("C:\Users\elliotd\Dropbox\HomeShare\buildstatus.log")
    
    ;FileRead, StrTemp, \\draven\Testing\debug.log
    GuiControl,,Var2,%StrTemp2%
Return

TransCheck:
    IfWinNotActive, Test Configuration
        WinSet, Transparent, 220 , Test Configuration
    else
        WinSet, Transparent, OFF, Test Configuration
Return

BuildsFolder:
    ShowDir("\\draven\Builds\SalesPad4")
return

TestingFolder:
    ShowDir("\\draven\Testing\TestComplete")
return

LogsFolder:
    ShowDir("\\draven\Testing\Logs")
return

EditScript:
    Run C:\Program Files\Sublime Text 2\sublime_text.exe %A_ScriptFullPath%
return

ReloadMenu:
    Reload
Return

ExitMenu:
    ExitApp
Return

ReloadAll:
    FileAppend, , \\draven\Testing\TestComplete\TESTING-PC.reload
    FileAppend, , \\draven\Testing\TestComplete\SMARTBEAR.reload
    FileAppend, , \\draven\Testing\TestComplete\GP2013.reload
    FileAppend, , \\draven\Testing\TestComplete\SQL2005.reload
Return



TCFileMenu:
    Run C:\Program Files\Sublime Text 2\sublime_text.exe %TCFile% 
Return

TestsiniMenu:
    Run C:\Program Files\Sublime Text 2\sublime_text.exe %Testsini% 
Return

DebugFileMenu:
    Run C:\Program Files\Sublime Text 2\sublime_text.exe %DebugFile%
Return

ClearDebugFileMenu:
    TF(DebugFile)
    FileAppend, `n%T%, \\draven\Testing\debughist.log
    FileDelete, %DebugFile%
    FileAppend, `n,%DebugFile%
return


CheckBuilds:

    countafterRelease := countBuilds("Release")
    countafterHotFix := countBuilds("HotFix")
    countafterServPack := countBuilds("ServPack")
    countafterCustom := countBuilds("Custom")

    if (countafterRelease > countbeforeRelease)
        Found("New Release Build - ", "Release")
    if (countafterHotFix > countbeforeHotFix)
        Found("New HotFix Build - ", "HotFix")
    if (countafterServPack > countbeforeServPack)
        Found("New ServPack Build - ", "ServPack")
    if (countafterCustom > countbeforeCustom)
        Found("New Custom Build - ", "Custom")
return


FindLatest:
    FindLatest("Release")
    FindLatest("HotFix")
    FindLatest("Custom")
    FindLatest("CustomRelease")
    FindLatest("ServPack")
Return




FindLatest(build)
{
    Loop, \\draven\Builds\SalesPad4\SalesPad_4_%build%\*WithCardControl.exe, 0, 1
    {
        FileGetTime, Time, %A_LoopFileFullPath%, C
        If (Time > Time_Orig)
        {
            Time_Orig := Time
            Version := A_LoopFileName
        }
    }
    FormatTime, CreationDate,%Time_Orig%, M/dd h:mm
    FormatTime, CreationDay,%Time_Orig%, M/dd
    FormatTime, Today, A_Now, M/dd
    ;msgbox % CreationDate "`n" build "`n" version
    Version := RegExReplace(Version, "(SalesPad.GP.Setup.|.WithCardControl.exe)", "")

    Loop, \\draven\Testing\Logs\%build%\*SMARTBEAR_Pass*, 0, 1
    {
        FileGetTime, Time, %A_LoopFileFullPath%, C
            VersionPassed := A_LoopFileName
    }

    /*
        If RegExMatch(GPVersion, "P)\d+", matchlength)
        GPVersion := "GP" . SubStr(GPVersion, RegExMatch(GPVersion, "P)\d+", matchlength), matchlength)
*/
    ;If RegExMatch(VersionPassed, "P)^[\d+|.]+", matchlength)
    ;    msgbox % SubStr(VersionPassed, RegExMatch(VersionPassed, "P)^[\d+|.]+", matchlength), matchlength)

    VersionPassed := SubStr(VersionPassed, RegExMatch(VersionPassed, "P)^[\d+|.]+", matchlength), matchlength)

    ;msgbox % Version "`n" VersionPassed

    ;If ! (Version = Version_Passed)
    ;    Guicontrol,, Latest%build%TestNeeded, 1
    ;Else
    ;    Guicontrol,, Latest%build%TestNeeded, 0

    ;msgbox % Version

    if (CreationDay = Today)
    {
        Gui, Font, cGreen Bold
        GuiControl, Font, Latest%build%
        GuiControl, Font, Latest%build%Date
        GuiControl,,Latest%build%, % Version
        GuiControl,,Latest%build%Date, % CreationDate
    }        
    Else
    {
        Gui, Font, cBlack w400
        GuiControl, Font, Latest%build%
        GuiControl, Font, Latest%build%Date
        GuiControl,,Latest%build%, % Version
        GuiControl,,Latest%build%Date, % CreationDate
    }
}



countBuilds(branch)   
{
    global
    count := 0
    ;Loop, C:\Builds\SalesPad4\SalesPad_4_%branch%\*WithCardControl.exe, 0, 1
    Loop, \\draven\Builds\SalesPad4\SalesPad_4_%branch%\*WithCardControl.exe, 0, 1
    {
        count := count+1
        ;msgbox % A_LoopFileName
    }
        
    return count
}

Found(text, build)
{
    global

    Loop, \\draven\Builds\SalesPad4\SalesPad_4_%build%\*, 2, 0
    {
        FileGetTime, Time, %A_LoopFileFullPath%, C
        If (Time > Time_Orig)
        {
            Time_Orig := Time
            Version := A_LoopFileName
        }
    }
    Version := RegExReplace(Version, "(SalesPad.GP.Setup.|.WithCardControl.exe)", "")


    FormatTime, Now,, M/dd [h:mm]
    FileAppend, %Now%`t%text%%Version%`n, \\draven\Testing\debug.log
    countbefore%build% := countBuilds(build)
    Notify("New " build " Build",Version,-15,"Style=Mine BW=2 BC=White GC=Red")
}





ShowDir(title)
{
    SetTitleMatchMode, 3
    IfWinExist, %title% ahk_class CabinetWClass
        WinActivate
    else
    {
        Run, %title%
        WinActivate
    }
    SetTitleMatchMode, 2
}

GetLatest()
{
    global
    Loop, \\draven\Builds\SalesPad4\SalesPad_4_%branch%\*WithCardControl.exe, 0, 1
    {
         FileGetTime, Time, %A_LoopFileFullPath%, C
         If (Time > Time_Orig)
         {
              Time_Orig := Time
              File := A_LoopFileName
              FullFile := A_LoopFileFullPath
         }
    }

}

countSingleBuild()   
{
    global
    count := 0
    Loop, \\draven\Builds\SalesPad4\SalesPad_4_%branch%\*WithCardControl.exe, 0, 1
    {
        count := count+1
        ;msgbox % A_LoopFileName
    }
        
    return count
}

FadeIn(window = "A", TotalTime = 500, transfinal = 255)
{
    StartTime := A_TickCount
    Loop
    {
       Trans := Round(((A_TickCount-StartTime)/TotalTime)*transfinal)
       WinSet, Transparent, %Trans%, %window%
       if (Trans >= transfinal)
          break
       Sleep, 10
    }
}

FadeOut(window = "A", TotalTime = 500)
{
    StartTime := A_TickCount
    Loop
    {
       Trans := ((TimeElapsed := A_TickCount-StartTime) < TotalTime) ? 100*(1-(TimeElapsed/TotalTime)) : 0
       WinSet, Transparent, %Trans%, %window%
       if (Trans = 0)
          break
       Sleep, 10
    }
}



Return

GuiClose:
WinMinimize

Return
















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; BEGIN INI LIBRARY ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


/*
Title: Basic ini string functions
    Operate on variables instead of files. An easy to use ini parser.
    
About: License
    New BSD License

Copyright (c) 2010, Tuncay
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Tuncay nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Tuncay BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

About: Introduction

    Ini files are used mostly as configuration files. In general, they have the
    ".ini"-extension. It is a simple standardized organization of text data. 
    Many other simple programs use them for storing text.    
    
    AutoHotkey provides three commands IniDelete, IniRead and IniWrite. These
    commands are stable, but they have some disadvantages. First disadvantage
    is, that they access the file directly. The file on the disk is opened, 
    load into memory and then read or manipulated and then saved with every 
    single command.    

    With the custom functions I wrote here, the user accessess on variables 
    instead of files. This is super fast, in comparison to disk access. Ini 
    files can be created by Ahk just like any other variable. But Ahk itself 
    does not have any function to operate on ini strings (variables). If you 
    read often from ini file, then this might for you. 
    
    No other framework or library is required, no special object files are 
    created; just work on ordinary ini file contents or variables. The load
    and save functions are added for comfort reason and are not really needed.
    
    * *First do this:*
    
    > FileRead, ini, config.ini
    
    * *or load default file with:*
    
    > ini_load(ini)
    
    * *or create the content yourself:*
    
    (Start Code)
    ini =
    (
    [Tip]
    TimeStamp = 20090716194758
    [Recent File List]
    File1=F:\testfile.ahk
    File2=Z:\tempfile.tmp
    )
    (End Code)
    
    In this example "Tip" and "Recent File List" are name of the sections. The
    file consist in this example of 2 sections. Every section contains variables,
    so called "keys". Every key is a part of a section. In this example, the 
    section "Tip" have one key "TimeStamp". And every key has a content, 
    called value. The "TimeStamp" key have the value "20090716194758".
    
    After that, you can access and modify the content of the ini variable with 
    the following functions. But the modifications are only temporary and must 
    me saved to disk. This should be done by overwriting the source (not 
    appending).
    
    *Notes*: A keys content (the value) goes until end of line. Any space 
    surroounding the value is at default lost. For best compatibility, the
    names of section and key should consist of alpha (a-z), num (0-9) and the
    underscore only. In general, the names are case insensitiv.

Links:
    * Lib Home: [http://autohotkey.net/~Tuncay/lib/index.html]
    * Download: [http://autohotkey.net/~Tuncay/lib/ini.zip]
    * Discussion: [http://www.autohotkey.com/forum/viewtopic.php?t=46226]
    * License: [http://autohotkey.net/~Tuncay/licenses/newBSD_tuncay.txt]

Date:
    2010-09-26

Revision:
    1.0

Developers:
    * Tuncay (Author)
    * Mystiq (Tester and Co-Author of an important regex)
    * Fry (Tester)

Category:
    String Manipulation, FileSystem

Type:
    Library

Standalone (such as no need for extern file or library):
    Yes

StdLibConform (such as use of prefix and no globals use):
    Yes

Related:
    *Format Specifications (not strictly implemented)*
    * Wikipedia - INI file [http://en.wikipedia.org/wiki/INI_file]
    * Cloanto Implementation of INI File Format [http://www.cloanto.com/specs/ini.html]
    
    *AutoHotkey Commands*
    * IniRead: [http://www.autohotkey.com/docs/commands/IniRead.htm]
    * IniWrite: [http://www.autohotkey.com/docs/commands/IniWrite.htm]
    * IniDelete: [http://www.autohotkey.com/docs/commands/IniDelete.htm]
    
    *Other Community Solutions*
    * INI Library by Titan: [http://www.autohotkey.com/forum/viewtopic.php?t=26141]
    * [Class] IniFile by bmcclure: [http://www.autohotkey.com/forum/viewtopic.php?t=41506]
    * [module] Ini by majkinetor: [http://www.autohotkey.com/forum/viewtopic.php?t=22495]
    * Auto read,load and save by Superfraggle: [http://www.autohotkey.com/forum/viewtopic.php?t=21346]
    * globalsFromIni by Tuncay: [http://www.autohotkey.com/forum/viewtopic.php?t=27928]
    * Read .INI file in one go by Smurth: [http://www.autohotkey.com/forum/viewtopic.php?t=36601]

About: Examples
    
Usage:
    
    (Code)
    value := ini_getValue(ini, "Section", "Key")                    ; <- Get value of a key.
    value := ini_getValue(ini, "", "Key")                           ; <- Get value of first found key.
    key := ini_getKey(ini, "Section", "Key")                        ; <- Get key/value pair.
    section := ini_getSection(ini, "Section")                       ; <- Get full section with all keys.
    
    ini_replaceValue(ini, "Section", "Key", A_Now)                  ; -> Update value of a key.
    ini_replaceKey(ini, "Section", "Key")                           ; -> Delete a key.
    ini_replaceSection(ini, "Section", "[Section1]Key1=0`nKey2=1")  ; -> Replace a section with all its keys.
    
    ini_insertValue(ini, "Section", "Key" ",ListItem")              ; -> Add a value to existing value.
    ini_insertKey(ini, "Section", "Key=" . A_Now)                   ; -> Add a key/value pair.
    ini_insertSection(ini, "Section", "Key1=ini`nKey2=Tuncay")      ; -> Add a section.
    
    keys := ini_getAllKeyNames(ini, "Section")                      ; <- Get a list of all key names.
    sections := ini_getAllSectionNames(ini)                         ; <- Get a list of all section names.
    (End Code)

About: Functions

Parameters:
    Content         - Content of an ini file (also this can be one section
                        only).
    Section         - Unique name of the section. Some functions support the
                        default empty string "". This leads to look up at 
                        first found section. 
    Key             - Name of the variable under the section.
    Replacement     - New content to use.
    PreserveSpace   - Should be set to 1 if spaces around the value of a key
                        should be saved, otherwise they are lost. The
                        surrounding single or double quotes are also lost.

    The 'get' functions returns the desired contents without touching the 
    variable.
    
    The 'replace' and 'insert' functions changes the desired content directly
    and returns 1 for success and 0 otherwise.
    
    There are some more type of functions and parameters. But these are not listed
    here.

Remarks:
    On success, ErrorLevel is set to '0'. Otherwise ErrorLevel is set to '1' if
    key under desired section is not found.
    
    The functions are not designed to be used in all situations. On rare 
    conditions, the result could be corrupt or not usable. In example, there 
    is no handling of commas inside the key or section names.
    Any "\E" would end the literal sequence and switch back to regex. The
    "\E" sequence is not escaped, because its very uncommon to use backslashes
    inside key and section names. To workaround this, replace at every key or
    section name the "\E" part with "\E\\E\Q":
    
    > Name := "Folder\Edit\Test1"
    > IfInString, Name, \
    > {
    >     StringReplace, Name, Name, \E, \E\\E\Q, All
    > }
    > MsgBox % ini_getValue(ini, "paths", Name)

    This allows us to work with regex, but then at the end it should be closed 
    with "\Q" again.
    > ; Used regex at keyname: "Time.*"
    > value := ini_getValue(ini, "Tip", "\ETime.*\Q")
*/


/*
_______________________________________________________________________________
_______________________________________________________________________________

Section: Parse

About: About

Brief:
    Main functions for getting, setting and updating section or key.
_______________________________________________________________________________
_______________________________________________________________________________
*/


; .............................................................................
; Group: Get
;   Functions for reading data.
; .............................................................................


/*
Func: ini_getValue
    Read and return a value from a key

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section.
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost. The
                        surrounding single or double quotes are also lost.
                        Default is deleting surrounding spaces and quotes.

Returns:
    On success the content of desired key is returned, otherwise an empty string.

Examples:
    > value := ini_getValue(ini, "Tip", "TimeStamp")
    > MsgBox %value%
    *Output:*
    > 20090716194758
*/
ini_getValue(ByRef _Content, _Section, _Key, _PreserveSpace = False)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
    {
         _Section = \[\s*?\Q%_Section%\E\s*?]
    }
    ; Note: The regex of this function was rewritten by Mystiq.
    RegEx = `aiU)(?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*\R\s*\Q%_Key%\E\s*=(.*)(?=\R|$)
/*
    RegEx := "`aiU)"
      . "(?:\R|^)\s*" . _Section . "\s*"         ;-- section
      . "(?:"
      . "\R\s*"                           ;-- empty lines
      . "|\R\s*[\w\s]+\s*=\s*.*?\s*(?=\R)"      ;-- OR other key=value pairs
      . "|\R\s*[;#].*?(?=\R)"                  ;-- OR commented lines
      . ")*"
      . "\R\s*\Q" . _Key . "\E\s*=(.*)(?=\R|$)"   ;-- match
*/
   
    If RegExMatch(_Content, RegEx, Value)
    {
        If Not _PreserveSpace
        {
            Value1 = %Value1% ; Trim spaces.
            FirstChar := SubStr(Value1, 1, 1)
            If (FirstChar = """" AND SubStr(Value1, 0, 1)= """"
                OR FirstChar = "'" AND SubStr(Value1, 0, 1)= "'")
            {
                StringTrimLeft, Value1, Value1, 1
                StringTrimRight, Value1, Value1, 1
            }
        }
        ErrorLevel = 0
    }
    Else
    {
        ErrorLevel = 1
        Value1 =
    }
    Return Value1
}


/*
Func: ini_getKey
    Read and return a complete key with key name and content.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section.

Returns:
    On success the key and value pair in one string is returned, otherwise an empty string.

Examples:
    > key := ini_getKey(ini, "Tip", "TimeStamp")
    > MsgBox %key%
    *Output:*
    > TimeStamp = 20090716194758
*/
ini_getKey(ByRef _Content, _Section, _Key)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
   
    ; Note: The regex of this function was rewritten by Mystiq.
    RegEx = `aiU)(?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*\R(\s*\Q%_Key%\E\s*=.*)(?=\R|$)
    If RegExMatch(_Content, RegEx, Value)
        ErrorLevel = 0
    Else
    {
        ErrorLevel = 1
        Value1 =
    }
    Return Value1
}


/*
Func: ini_getSection
    Read and return a complete section with section name.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. (An enmpty string "" is not
                        working.)

Returns:
    On success the entire section in one string is returned, otherwise an empty string.
    
Examples:
    > section := ini_getSection(ini, "Tip")
    > MsgBox %section% 
    *Output:*
    > [Tip]
    > TimeStamp = 20090716194758
*/
ini_getSection(ByRef _Content, _Section)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    RegEx = `aisUS)^.*(%_Section%\s*\R?.*)(?:\R*\s*(?:\[.*?|\R))?$
    If RegExMatch(_Content, RegEx, Value)
        ErrorLevel = 0
    Else
    {
        ErrorLevel = 1
        Value1 =
    }
    Return Value1
}

/*
Func: ini_getAllValues
    Read and get a new line separated list of all values in one go.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - *Optional* Unique name of the section.
    Count           - *Variable Optional* The number of found values/keys.

Returns:
    On success a newline "`n" separated list with all name of keys is returned, 
    otherwise an empty string. If section is specified, only those from that
    section is returned, otherwise from all sections.

Remarks:
    Other than the other getAll-functions list separator, this function uses
    the new line "`n" character instead the comma "," for separating values.
    Also other than the other getValue functions, this does not provide any
    preserveSpaces option, as it allways preserves surrounding spaces and
    quotes.

Examples:
    > values := ini_getAllValues(ini, "Recent File List")
    > MsgBox %values%
    *Output:*
    > F:\testfile.ahk
    > Z:\tempfile.tmp
*/
ini_getAllValues(ByRef _Content, _Section = "", ByRef _count = "")
{
    RegEx = `aisUmS)^(?=.*)(?:\s*\[\s*?.*\s*?]\s*|\s*?.+\s*?=(.*))(?=.*)$
    If (_Section != "")
        Values := RegExReplace(ini_getSection(_Content, _Section), RegEx, "$1`n", Match)
    Else
        Values := RegExReplace(_Content, RegEx, "$1`n", Match)
    If Match
    {
        Values := RegExReplace(Values, "`aS)\R+", "`n")
        ; Workaround, sometimes it catches sections. Whitespaces only should be eliminated also.
        Values := RegExReplace(Values, "`aS)\[.*?]\R+|\R+$|\R+ +$", "") 
        StringReplace, Values, Values, `n, `n, UseErrorLevel
        _count := ErrorLevel ? ErrorLevel : 0
        StringTrimLeft, Values, Values, 1
        ErrorLevel = 0
    }
    Else
    {
        ErrorLevel = 1
        _count = 0
        Values =
    }
    Return Values
}


/*
Func: ini_getAllKeyNames
    Read and get a comma separated list of all key names in one go.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - *Optional* Unique name of the section.
    Count           - *Variable Optional* The number of found keys.

Returns:
    On success a comma separated list with all name of keys is returned, 
    otherwise an empty string. If section is specified, only those from that
    section is returned, otherwise from all sections.
    
Examples:
    > keys := ini_getAllKeyNames(ini, "Recent File List")
    > MsgBox %keys%
    *Output:*
    > File1,File2
*/
ini_getAllKeyNames(ByRef _Content, _Section = "", ByRef _count = "")
{
    RegEx = `aisUmS)^.*(?:\s*\[\s*?.*\s*?]\s*|\s*?(.+)\s*?=.*).*$
    If (_Section != "")
        KeyNames := RegExReplace(ini_getSection(_Content, _Section), RegEx, "$1", Match)
    Else
        KeyNames := RegExReplace(_Content, RegEx, "$1", Match)
    If Match
    {
        KeyNames := RegExReplace(KeyNames, "S)\R+", ",")
        ; Workaround, sometimes it catches sections. Whitespaces only should be eliminated also.
        KeyNames := RegExReplace(KeyNames, "S)\[.*?],+|,+$|,+ +", "") 
        StringReplace, KeyNames, KeyNames, `,, `,, UseErrorLevel
        _count := ErrorLevel ? ErrorLevel : 0
        StringTrimLeft, KeyNames, KeyNames, 1
        ErrorLevel = 0
    }
    Else
    {
        ErrorLevel = 1
        _count = 0
        KeyNames =
    }
    Return KeyNames
}


/*
Func: ini_getAllSectionNames
    Read and get a comma separated list of all section names in one go.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Count           - *Variable Optional* The number of found sections.

Returns:
    On success a comma separated list with all name of sections is returned, 
    otherwise an empty string.
    
Examples:
    > sections := ini_getAllSectionNames(ini)
    > MsgBox %sections%
    *Output:*
    > Tip,Recent File List
*/
ini_getAllSectionNames(ByRef _Content, ByRef _count = "")
{
    RegEx = `aisUmS)^.*(?:\s*\[\s*?(.*)\s*?]\s*|.+=.*).*$
    SectionNames := RegExReplace(_Content, RegEx, "$1", MatchNum)
    If MatchNum
    {
        SectionNames := RegExReplace(SectionNames, "S)\R+", ",", _count)
        ; Workaround, whitespaces only should be eliminated.
        SectionNames := RegExReplace(SectionNames, "S),+ +", "") 
        StringReplace, SectionNames, SectionNames, `,, `,, UseErrorLevel
        _count := ErrorLevel ? ErrorLevel : 0
        _count := _count ? _count : 0
        StringTrimRight, SectionNames, SectionNames, 1
        ErrorLevel = 0
    }
    Else
    {
        ErrorLevel = 1
        _count = 0
        SectionNames =
    }
    Return SectionNames
}


; .............................................................................
; Group: Replace
;   Functions for replacing existing data.
; .............................................................................


/*
Func: ini_replaceValue
    Updates the value of a key.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section. 
    Replacement     - *Optional* New content to use. If not specified, the 
                        content will be replaced with no content. That means
                        it is deleted/set to empty string.
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost. The
                        surrounding single or double quotes are also lost.
                        Default is deleting surrounding spaces.

Returns:
    Returns 1 if key is updated to new value, and 0 otherwise (opposite of 
    ErrorLevel). 
    
Examples:
    > ini_replaceValue(ini, "Tip", "TimeStamp", 2009)
    > value := ini_getValue(ini, "Tip", "TimeStamp")
    > MsgBox %value%
    *Output:*
    > 2009
*/
ini_replaceValue(ByRef _Content, _Section, _Key, _Replacement = "", _PreserveSpace = False)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    If Not _PreserveSpace
    {
        _Replacement = %_Replacement% ; Trim spaces.
        FirstChar := SubStr(_Replacement, 1, 1)
        If (FirstChar = """" AND SubStr(_Replacement, 0, 1)= """"
            OR FirstChar = "'" AND SubStr(_Replacement, 0, 1)= "'")
        {
            StringTrimLeft, _Replacement, _Replacement, 1
            StringTrimRight, _Replacement, _Replacement, 1
        }
    }
    ; Note: The regex of this function was written by Mystiq.
    RegEx = `aiU)((?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*\R\s*\Q%_Key%\E\s*=).*((?=\R|$))
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    If isReplaced
        ErrorLevel = 0
    Else
        ErrorLevel = 1
    Return isReplaced
}


/*
Func: ini_replaceKey
    Changes complete key with its name and value.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section.
    Replacement     - *Optional* New content to use. If not specified, the 
                        content will be replaced with no content. That means
                        it is deleted/set to empty string.
                      The replacement should contain an equality sign.
                      (Expected form: "keyName=value")

Returns:
    Returns 1 if key is updated to new value, and 0 otherwise (opposite of 
    ErrorLevel). 
    
Examples:
    > ini_replaceKey(ini, "Tip", "TimeStamp", "TimeStamp=1980")
    > value := ini_getValue(ini, "Tip", "TimeStamp")
    > MsgBox %value%
    *Output:*
    > 1980
*/
ini_replaceKey(ByRef _Content, _Section, _Key, _Replacement = "")
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    If _Replacement !=
    {
        _Replacement = %_Replacement%
        _Replacement = `n%_Replacement%
    }
    ; Note: The regex of this function was written by Mystiq.
    RegEx = `aiU)((?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*)\R\s*\Q%_Key%\E\s*=.*((?=\R|$))
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    If isReplaced
        ErrorLevel = 0
    Else
        ErrorLevel = 1
    Return isReplaced
}

/*
Func: ini_replaceSection
    Changes complete section with all its keys and contents.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Replacement     - *Optional* New content to use. If not specified, the 
                        content will be replaced with no content. That means
                        it is deleted/set to empty string.
                      The replacement should contain everything what a section
                      contains, like the "[" and "]" before and after section
                      name and all keys with its equality sign and value.
                      (Expected form: "[sectionName]`nkeyName=value")

Returns:
    Returns 1 if key is updated to new value, and 0 otherwise (opposite of 
    ErrorLevel). 
    
Examples:
    > ini_replaceSection(ini, "Tip", "TimeStamp", "[Section1]`nKey1=Hello`nKey2=You!")
    > value := ini_getValue(ini, "Section1", "Key1")
    > MsgBox %value%
    *Output:*
    > Hello
*/
ini_replaceSection(ByRef _Content, _Section, _Replacement = "")
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    RegEx = `aisU)^(\s*?.*)%_Section%\s*\R?.*(\R*\s*(?:\[.*|\R))?$ 
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    If isReplaced
        ErrorLevel = 0
    Else
        ErrorLevel = 1
    Return isReplaced
}


; .............................................................................
; Group: Insert
;   Functions for adding new data.
; .............................................................................


/*
Func: ini_insertValue
    Adds value to the end of existing value of specified key.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section.
    Value           - Value to be inserted at end of currently existing value.
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost. The
                        surrounding single or double quotes are also lost.
                        Default is deleting surrounding spaces.

Returns:
    Returns 1 if value is inserted, and 0 otherwise (opposite of ErrorLevel).
    
Examples:
    > ini_insertValue(ini, "Recent File List", "File1", ", " . A_ScriptName)
    > value := ini_getValue(ini, "Recent File List", "File1")
    > MsgBox %value%
    *Output:*
    > F:\testfile.ahk, ini.ahk
*/
ini_insertValue(ByRef _Content, _Section, _Key, _Value, _PreserveSpace = False)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    If Not _PreserveSpace
    {
        _Value = %_Value% ; Trim spaces.
        FirstChar := SubStr(_Value, 1, 1)
        If (FirstChar = """" AND SubStr(_Value, 0, 1)= """"
            OR FirstChar = "'" AND SubStr(_Value, 0, 1)= "'")
        {
            StringTrimLeft, _Value, _Value, 1
            StringTrimRight, _Value, _Value, 1
        }
    }
    ; Note: The regex of this function was written by Mystiq.
    RegEx = S`aiU)((?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*\R\s*\Q%_Key%\E\s*=.*?)((?=\R|$))
    _Content := RegExReplace(_Content, RegEx, "$1" . _Value . "$2", isInserted, 1)
    If isInserted
        ErrorLevel = 0
    Else
        ErrorLevel = 1
    Return isInserted
}


/*
Func: ini_insertKey
    Adds a key pair with its name and value, if key does not already exists.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. (An enmpty string "" is not
                        working.)
    Key             - Key and value pair splitted by an equality sign.

Returns:
    Returns 1 if key is inserted, and 0 otherwise (opposite of ErrorLevel).

Remarks:
    Currently, it works as a workaround with different function calls instead 
    of one regex call. This makes it slower against the other functions.
    
Examples:
    > ini_insertKey(ini, "Tip", "TimeNow=" . 20090925195317)
    > value := ini_getValue(ini, "Tip", "TimeNow")
    > MsgBox %value%
    *Output:*
    > 20090925195317
*/
ini_insertKey(ByRef _Content, _Section, _Key)
{
    StringLeft, K, _Key, % InStr(_Key, "=") - 1
    sectionCopy := ini_getSection(_Content, _Section)
    keyList := ini_getAllKeyNames(sectionCopy)
    isInserted = 0
    If K Not In %keyList%
    {
        sectionCopy .= "`n" . _Key
        isInserted = 1
    }
    If isInserted
    {
        ini_replaceSection(_Content, _Section, sectionCopy)
        ErrorLevel = 0 
    }
    Else
    {
        ErrorLevel = 1
    } 
    Return isInserted
}

/*
Func: ini_insertSection
    Adds a section and its keys, if section does not exist already.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section to be added and checked if
                        it is already existing.
    Keys            - *Optional* Set of key value pairs. Every key and value 
                        pair should be at its own line divided by a new line 
                        character.

Returns:
    Returns 1 if section and the keys are inserted, and 0 otherwise (opposite 
    of ErrorLevel).
    
Examples:
    > ini_insertSection(ini, "Tip", "Files", "Name1=Programs`nPath1=C:\Program Files")
    > value := ini_getValue(ini, "Files", "Name1")
    > MsgBox %value%
    *Output:*
    > Programs
*/
ini_insertSection(ByRef _Content, _Section, _Keys = "")
{
    RegEx = `aisU)^.*\R*\[\s*?\Q%_Section%\E\s*?]\s*\R+.*$
    If Not RegExMatch(_Content, RegEx)
    {
        _Content = %_Content%`n[%_Section%]`n%_Keys%
        isInserted = 1
        ErrorLevel = 0
    }
    Else
    {
        isInserted = 0
        ErrorLevel = 1
    }
    Return isInserted
}


/*
_______________________________________________________________________________
_______________________________________________________________________________

Section: Additional

About: About

Brief:
    Other functions besides the core ones.
_______________________________________________________________________________
_______________________________________________________________________________

*/

; .............................................................................
; Group: File
;   Related routines about file handling with some comfort.
; .............................................................................

/*
Func: ini_load
    Reads an ini file into a variable and resolves any part of the path.

Parameters:
    Content         - *Variable* On success, the file is loaded into this 
                        variable.
    Path            - *Optional* Source filename or -path to look for. It
                        can contain wildcards. If this is an existing directory 
                        (or contains backslash at the end), then default 
                        filename is appended. Default filename is ScriptName 
                        with ".ini" extension (in example "script.ini").
                        Relative Pathes are solved to current WorkingDir. 
                        Every part of the path (like filename and -extension) 
                        are optional. Default extension is logically ".ini". 
                        Binary files are not loaded. Empty string is resolved 
                        to "ScriptPathNoExt + .ini".
    convertNewLine  - *Optional* If this is true, all "`r`n" (CRLF) new line
                        sequence of files content will be replaced with "`n" 
                        (LF) only. Normally this is not necessary.

Returns:
    The resolved full path which was searched for. If file exists, the full 
    path with correct case from the disk is get.

Remarks:
    This function is not necessary to work with the ini-library. In fact, in 
    the heart, it does nothing else than FileRead. The filled variable is an
    ordinary string. You can work with custom functions other from this library
    on these variables, as if you would do allways.
    
    If file is not found or content is binary, or at any other reason ErrorLevel
    is set to 1 and Content is set to "" (empty).

Examples:
    > ; Load content of default file into variable "ini".
    > path := ini_load(ini)
    > MsgBox %path%
    *Output:*
    > E:\Tuncay\AutoHotkey\scriptname.ini
*/
ini_load(ByRef _Content, _Path = "", _convertNewLine = false)
{
    ini_buildPath(_Path)
    error := true ; If file is found next, then its set to false.
    Loop, %_Path%, 0, 0
    {
        _Path := A_LoopFileLongPath
        error := false
        Break
    }    
    If (error = false)
    {
        FileRead, _Content, %_Path%
        If (ErrorLevel)
        {
            error := true
        }
        Else
        {
            FileGetSize, fileSize, %_Path%
            If (fileSize != StrLen(_Content))
            {
                error := true
            }
        }
    }
    If (error)
    {
        _Content := ""
    }
    Else If (_convertNewLine)
    {
        StringReplace, _Content, _Content, `r`n, `n, All
    }
    ErrorLevel := error
    Return _Path
}


/*
Func: ini_save
    Writes an ini file from variable to disk.

Parameters:
    Content         - *Variable* Ini content to save at given path on disk.
    Path            - *Optional* Source filename or -path to look for. It
                        can contain wildcards. If this is an existing directory 
                        (or contains backslash at the end), then default 
                        filename is appended. Default filename is ScriptName 
                        with ".ini" extension (in example "script.ini").
                        Relative Pathes are solved to current WorkingDir. 
                        Every part of the path (like filename and -extension) 
                        are optional. Default extension is logically ".ini". 
                        Binary files are not loaded. Empty string is resolved 
                        to "ScriptPathNoExt + .ini".
    convertNewLine  - *Optional* If this is true, all "`n" (LF) new line
                        sequence of files content will be replaced with "`r`n"
                        (CRLF). Normally, Windows default new line sequence is
                        "`r`n". (Source is not changed with this option.)
    overwrite       - *Optional* If this mode is enabled (true at default), 
                        the source file will be updated. Otherwise, the
                        file is saved to disk only if source does not exist
                        already.

Returns:
    The resolved full path which was searched for.

Remarks:
    If overwrite mode is enabled and file could not be deleted, then ErrorLevel 
    is set to 1. Otherwise, if overwriting an existing file is not allowed 
    (overwrite = false) and file is existing, then ErrorLevel will be set to 1 
    also.

Examples:
    > ; Write and update content of ini variable to default file.
    > path := ini_save(ini)
    > MsgBox %path%
    *Output:*
    > E:\Tuncay\AutoHotkey\scriptname.ini
*/
ini_save(ByRef _Content, _Path = "", _convertNewLine = true, _overwrite = true)
{
    ini_buildPath(_Path)
    error := false
    If (_overwrite)
    {
        Loop, %_Path%, 0, 0
        {
            _Path := A_LoopFileLongPath
            Break
        }    
        If FileExist(_Path)
        {
            FileDelete, %_Path%
            If (ErrorLevel)
            {
                error := true
            }
        }
    }
    Else If FileExist(_Path)
    {
        error := true
    }
    If (error = false)
    {
        If (_convertNewLine)
        {
            StringReplace, _Content, _Content, `r`n, `n, All
            StringReplace, _Content, _Content, `n, `r`n, All
            FileAppend, %_Content%, %_Path%
        }
        Else
        {
            FileAppend, %_Content%, *%_Path%
        }
        If (ErrorLevel)
        {
            error := true
        }
    }
    ErrorLevel := error
    Return _Path
}

; An internally used function, made not for public.
ini_buildPath(ByRef _path)
{
    ; Set to default wildcard if filename or exension are not set.
    If (_Path = "")
    {
        _Path := RegExReplace(A_ScriptFullPath, "S)\..*?$") . ".ini"
    }
    Else If (SubStr(_Path, 0, 1) = "\")
    {
        _Path .= RegExReplace(A_ScriptName, "S)\..*?$") . ".ini"
    }
    Else
    {
        If (InStr(FileExist(_Path), "D"))
        {
            ; If the current path is a directory, then add default file pattern to the directory.
            _Path .= "\" . RegExReplace(A_ScriptName, "S)\..*?$") . ".ini"
        }
        Else
        {
            ; Check all parts of path and use defaults, if any part is not specified.
            SplitPath, _Path,, fileDir, fileExtension, fileNameNoExt
            If (fileDir = "")
            {
                fileDir := A_WorkingDir
            }
            If (fileExtension = "")
            {
                fileExtension := "ini"
            }
            If (fileNameNoExt = "")
            {
                fileNameNoExt := RegExReplace(A_ScriptName, "S)\..*?$")
            }
            _Path := fileDir . "\" . fileNameNoExt . "." . fileExtension
        }
    }
    Return 0
}

; .............................................................................
; Group: Edit
;   These manipulates the whole ini structure (or an extracted section only).
; .............................................................................

/*
Func: ini_repair
    Repair and build an ini from scratch. Leave out comments and trim unneeded 
    whitespaces.

Parameters:
    Content         - Content of an ini file (also this can be one 
                        section only).
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost. 
                        Default is deleting surrounding spaces.
    CommentSymbols  - *Optional* List of characters which are should be treated 
                        as comment symbols. Every single character in list is 
                        a symbol. Default are ";" and "#", in example defined 
                        as ";#". 
    LineDelim       - *Optional* A sequence of characters which should be the
                        delimiter as the line end symbol. Default is "`n", a
                        new line.

Returns:
    The new formatted ini string with trimmed whitespaces and without comments.

Remarks:
    Other than the most other functions here, the ini Content variable is not
    a byref and will not manipulated directly. The return value is the new ini.
    The LineDelim option can be leaved as is. Internally all commands of 
    AutoHotkey like MsgBox or FileAppend are working correctly with this.
    
    What it does is, building a new ini content string from an existing one.
    The reason to use this function is, if anyone have problems with the 
    source ini because of whitespaces or comments and formatting. The new
    resulting ini is consistently reduced to standard ini format (at least,
    it should).
    Dublicate key entries in same section are merged into one key. The last
    instance overwrites just the one before.

Examples:
    (code)
    ini =
    (
    
        [ malformed section  ]
city   =  Berlin'
whatever='this ; is nasty'

     [bad]
cat    =     'miao'

    )
    ini := ini_repair(ini, true)
    MsgBox %ini%
    (end)

    *Output:*
    (code)
[malformed section]
city=  Berlin'
whatever='this 
[bad]
cat=     'miao'
    (end)
*/
ini_repair(_Content, _PreserveSpace = False, _CommentSymbols = ";#", _LineDelim = "`n")
{
    If (_CommentSymbols != "")
    {
        regex = `aiUSm)(?:\R\s*|(s*|\t*))[%_CommentSymbols%].*?(?=\R)
        _Content := RegExReplace(_Content, regex, "$1")
    }
    Loop, Parse, _Content, `n, `r
    {
        If (RegExMatch(A_LoopField, "`aiSm)\[\s*(.+?)\s*]", Match))
        {
            newIni .= _LineDelim . "[" . Match1 . "]"
            section := Match1
            KeyList := ""
        }
        Else If (RegExMatch(A_LoopField, "`aiSm)\s*(\b(?:.+?|\s?)\b)\s*=(.*)", Match))
        {
            If (_PreserveSpace = false)
            {
                Match2 = %Match2%
            }
            If Match1 Not in %KeyList% ; Disallowes dublicate.
            {
                KeyList .= "," . Match1
            }
            Else
            {
                ; As a workaround it should be just deleted, because if set 
                ; here the surrounding whitespaces are lost.
                ini_replaceKey(newIni, section, Match1, "")
            }
            newIni .= _LineDelim . Match1 . "=" . Match2
        }
    }
    StringReplace, newIni, newIni, %_LineDelim%
    If (newIni != "")
    {
        ErrorLevel := 0
    }
    Else
    {
        ErrorLevel := 1
    }
    Return newIni
}


/*
Func: ini_mergeKeys
    Merge two ini sources into first one. Adds new sections and keys and 
    processess existing keys.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only). This is the destination where new 
                        sections and keys are added into.
    source          - *Variable* This is also an ini content from which to 
                        retrieve the new data. These will be added into Content 
                        variable.
    updateMode      - *Optional* Defines how existing keys should be processed.
                        Default is ('1') overwriting last instance with newest 
                        one. 

        updateMode: '1' - ("Default") Replace existng key with newest/last one
                    from source.
        
        updateMode: '2' - Append everything to existing key in Content.
        
        updateMode: '3' - Replace only if source is higher than destination key
                    in Content.
        
        updateMode: '4' - Exclude keys in Content, which exists in both sources.
        
        updateMode: '0' - ("Or any other value") Does not manipulate existing keys
                    in Content, leaving them in their orginal state. Just add 
                    new unknown keys to Content.
                        
Returns:
    Returns the steps taken to manipulate the destination Content. Every added or 
    manipulated key and section are rising by 1 the return value. 0 if nothing is
    changed.

Remarks:    
    ErrorLevel is set to '1' if something is changed in Content, '0' otherwise.
    
    The Content variable is updated with the content from source. This means, new
    sections and keys are added allways. In a conflict where same key was found 
    in source again, in case it is existing in Content already, then the variable
    updateMode defines how they should be processed. Default is, to use last found
    key.

Examples:
    (code)
    ini1=
    (LTrim
        [vasara]
        tuni=1232
        edg=94545
        k=1
    )
    ini2=
    (LTrim
        [vasara]
        tuni=9999
        c=
        edg=5
        [taitos]
        isa=17
    )
    ini_mergeKeys(ini1, ini2)
    MsgBox %ini1%
    (end)
    *Output:*
    (code)
        [vasara]
        tuni=9999
        edg=5
        k1
        c=
        [taitos]
        isa=17
    (end)
*/
ini_mergeKeys(ByRef _Content, ByRef _source, _updateMode = 1)
{
    steps := 0
    laststep := 0
    destSectionNames := ini_getAllSectionNames(_Content), sourceSectionNames := ini_getAllSectionNames(_source)
    Loop, Parse, sourceSectionNames, `,
    {
        sectionName := A_LoopField
        sourceSection := ini_getSection(_source, sectionName)
        If sectionName Not In %destSectionNames%
        {
            _Content .= "`n" . sourceSection
            steps++
            Continue
        }
        Else
        {
            destSection := ini_getSection(_Content, sectionName), destKeyNames := ini_getAllKeyNames(destSection), sourceKeyNames := ini_getAllKeyNames(sourceSection)
            Loop, Parse, sourceKeyNames, `,
            {
                keyName := A_LoopField
                If keyName Not In %destKeyNames%
                {
                    destSection .= "`n" . ini_getKey(sourceSection, sectionName, keyName)
                    steps++
                    Continue
                }
                Else If (_updateMode = 1)
                {
                    ini_replaceValue(destSection, sectionName, keyName, ini_getValue(sourceSection, sectionName, keyName))
                    steps++
                }
                Else If (_updateMode = 2)
                {
                    ini_replaceValue(destSection, sectionName, keyName, ini_getValue(destSection, sectionName, keyName) . ini_getValue(sourceSection, sectionName, keyName))
                    steps++
                }
                Else If (_updateMode = 3)
                {
                    If ((sourceValue := ini_getValue(sourceSection, sectionName, keyName)) > ini_getValue(destSection, sectionName, keyName))
                    {
                        ini_replaceValue(destSection, sectionName, keyName, sourceValue)
                        steps++
                    }
                }
                Else If (_updateMode = 4)
                {
                    ini_replaceKey(destSection, sectionName, keyName, "")
                    steps++
                }
            }
            If (laststep != steps)
            {
                laststep := steps
                ini_replaceSection(_Content, sectionName, destSection)
            }
        }
    }
    If (steps > 0)
    {
        ErrorLevel := 0
    }
    Else
    {
        ErrorLevel := 1
    }
    Return steps
}


; .............................................................................
; Group: Convert
;   Export and import functions to convert ini structure.
; .............................................................................


/*
Func: ini_exportToGlobals
    Creates global variables from the ini structure.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    CreateIndexVars - *Optional* If this is set to 'true', some additional 
                        variables are created. These are variables for indexed
                        access of sections and keys. The scheme how the variables
                        named are described below under Remarks.
    Prefix          - *Optional* This is the leading part of all created variable
                        names. (Default: "ini")
    Seperator       - *Optional* This is part of all created variable names. It
                        is added between every section and key part and the 
                        leading part to separate them. (Default: "_")
    SectionSpaces   - *Optional* Every space inside section name will be replaced
                        by this character or string. This is needed for creating
                        AutoHotkey variables, which cannot hold spaces at name.
                        Default is to delete any space with empty value: "".
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost.
                        Surrounding quotes (" or ') are also lost, if not set
                        to 1. Default is deleting surrounding spaces and quotes.

Returns:
    Gets count of all created keys (attention, keys in sense of ini keys, not variables). 

Remarks:
    Creates global variables from ini source. The scheme for building the variables is
    following: 
    
    > Prefix  +  Seperator  +  SectionName  + Seperator  +  KeyName
    >   ini   +      _      +      Tip      +     _      + TimeStamp
    > --------------------------------------------------------------
    > ini_Tip_TimeStamp := "20090716194758"
    
    Standard prefix to every variable is "ini" and all parts are delimited by the 
    separator "_". The SectionSpaces parameter deletes at default every space from 
    name of section, because spaces inside ahk variable names are not allowed.

CreateIndexVars:    
    These variables are created additionally to the other variables, if option 
    CreateIndexVars is set to true (or 1 or any other value evaluating to true).
    
    Scheme for sections
    > Prefix  +  Seperator  +  Index
    >   ini   +      _      +    1
    > ------------------------------
    > ini_1 := "Tip"
    
    Scheme for keys
    > Prefix  +  Seperator  +  SectionName  + Index
    >   ini   +      _      +      Tip      +   1
    > ---------------------------------------------
    > ini_Tip1 := "20090716194758"
    
    The index "0" contains number of all elements.

Examples:
    > ini_exportToGlobals(ini, 0)
    > ListVars
    > Msgbox % ini_RecentFileList_File2
    *Output:*
    > Z:\tempfile.tmp
    
    The example would create all these variables with following 
    values:
    > ini_RecentFileList_File1 := "F:\testfile.ahk"
    > ini_RecentFileList_File2 := "Z:\tempfile.tmp"
    > ini_Tip_TimeStamp := "20090716194758"
    
    These variables would be created in addition to the above ones, if 
    CreateIndexVars option was set to true:
    > ini_0 := "2"
    > ini_1 := "Tip"
    > ini_2 := "RecentFileList"
    > ini_RecentFileList0 := "2"
    > ini_RecentFileList1 := "File1"
    > ini_RecentFileList2 := "File2"
    > ini_Tip0 := "1"
    > ini_Tip1 := "TimeStamp"
*/
ini_exportToGlobals(ByRef _Content, _CreateIndexVars = false, _Prefix = "ini", _Seperator = "_", _SectionSpaces = "", _PreserveSpace = False)
{
    Global
    Local secCount := 0, keyCount := 0, i := 0, Section, Section1, currSection, Pair, Pair1, Pair2, FirstChar
    If (_Prefix != "")
    {
        _Prefix .= _Seperator
    }
    Loop, Parse, _Content, `n, `r
    {
        If (Not RegExMatch(A_LoopField, "`aiSm)\[\s*(.+?)\s*]", Section))
        {
            If (RegExMatch(A_LoopField, "`aiSm)\s*(\b(?:.+?|\s?)\b)\s*=(.*)", Pair))
            {
                If (!_PreserveSpace)
                {
                    StringReplace, Pair1, Pair1, %A_Space%, , All
                    Pair2 = %Pair2% ; Trim spaces.
                    FirstChar := SubStr(Pair2, 1, 1)
                    If (FirstChar = """" AND SubStr(Pair2, 0, 1)= """"
                        OR FirstChar = "'" AND SubStr(Pair2, 0, 1)= "'")
                    {
                        StringTrimLeft, Pair2, Pair2, 1
                        StringTrimRight, Pair2, Pair2, 1
                    }
                }
                StringReplace, currSection, currSection, %A_Space%, %_SectionSpaces%, All
                %_Prefix%%currSection%%_Seperator%%Pair1% := Pair2 ; ini_section_key := value
                keyCount++
                If (_CreateIndexVars)
                {
                    %_Prefix%%currSection%0++
                    i := %_Prefix%%currSection%0
                    %_Prefix%%currSection%%i% := Pair1
                }
            }
        }
        Else
        {
            currSection := Section1
            If (_CreateIndexVars)
            {
                StringReplace, currSection, currSection, %A_Space%, %_SectionSpaces%, All
                secCount++
                %_Prefix%%secCount% := currSection
            }
        }
    }
    If (_CreateIndexVars)
    {
        %_Prefix%0 := secCount
    }
    If (secCount = 0 AND keyCount = 0)
    {
        ErrorLevel = 1
    }
    Else
    {
        ErrorLevel = 0
    }
    Return keyCount
}


/*
_______________________________________________________________________________
_______________________________________________________________________________

Section: Aliases

About: About

Brief:
    Function wrappers to work with existing commands or functions via "Basic 
    ini string functions". They try to mimic the interface for look and feel of
    original. This can help to migrate others to this library with lesser
    possible work.
_______________________________________________________________________________
_______________________________________________________________________________
*/

; .............................................................................
; Group: AutoHotkey
;   Built-in Commands of AutoHotkey.
; .............................................................................

/*
Func: Ini_Read
    Reads a value. Alias of IniRead.

Parameters:
    OutputVar       - *Variable* The name of the variable in which to store the retrieved 
                        value. If the value cannot be retrieved, the variable 
                        is set to the value indicated by the Default parameter 
                        (described below). 
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section.
    Key             - Name of the variable under the section.
    Default         - *Optional* The value to store in OutputVar if the 
                        requested key is not found. If omitted, it defaults to 
                        the word ERROR.

Returns:
    Does not return anything.
    
Remarks:
    ErrorLevel is not set by this function (backed up and restored).

    In Ahk you had to specify the filename of the ini file. Here you need to 
    give the content, instead of.
    Compared to "Basic ini string functions" the parameter section is not 
    allowed to be set to an empty string anymore.

Related:
    * IniRead: [http://www.autohotkey.com/docs/commands/IniRead.htm]
    
Examples:
    > FileRead, ini, C:\Temp\myfile.ini
    > Ini_Read(OutputVar, ini, "section2", "key")
    > MsgBox %OutputVar%
*/
Ini_Read(ByRef _OutputVar, ByRef _Content, _Section, _Key, _Default = "ERROR")
{
    If (_Section != "")
    {
        BackupErrorLevel := ErrorLevel
        _OutputVar := ini_getValue(_Content, _Section, _Key)
        If ErrorLevel
        {
            _OutputVar := _Default
        }
        ErrorLevel := BackupErrorLevel
    }
    Else
    {
        _OutputVar := _Default
    }
    Return 
}


/*
Func: Ini_Write
    Writes a value. Alias of IniWrite.

Parameters:
    Value           - The string or number that will be written to the right 
                        of Key's equal sign (=).
    Content         - *Variable* Content of an ini file .
    Section         - Unique name of the section.
    Key             - Name of the variable under the section.

Returns:
    Does not return anything.
    
Remarks:
    ErrorLevel is set to 1 if there was a problem or 0 otherwise.

    In Ahk you had to specify the filename of the ini file. Here you need to 
    give the content, instead of.
    Compared to "Basic ini string functions" the parameter section is not 
    allowed to be set to an empty string anymore.

Related:
    * IniWrite: [http://www.autohotkey.com/docs/commands/IniWrite.htm]
    
Examples:
    > FileRead, ini, C:\Temp\myfile.ini
    > Ini_Write("this is a new value", ini, "section2", "key")
    > FileDelete, C:\Temp\myfile.ini
    > FileAppend, %ini%, C:\Temp\myfile.ini
*/
Ini_Write(_Value, ByRef _Content, _Section, _Key)
{
    If (_Section = "")
    {
        ErrorLevel = 1
    }
    Else
    {
        ini_replaceValue(_Content, _Section, _Key, _Value)
    }
    Return 
}


/*
Func: Ini_Delete
    Deletes a value or section. Alias of IniDelete.

Parameters:
    Content         - *Variable* Content of an ini file.
    Section         - Unique name of the section.
    Key             - *Optional* Name of the variable under the section.

Returns:
    Does not return anything.
    
Remarks:
    ErrorLevel is set to 1 if there was a problem or 0 otherwise.

    In Ahk you had to specify the filename of the ini file. Here you need to 
    give the content, instead of.
    Compared to "Basic ini string functions" the parameter section is not 
    allowed to be set to an empty string anymore.

Related:
    * IniDelete: [http://www.autohotkey.com/docs/commands/IniDelete.htm]
    
Examples:
    > FileRead, ini, C:\Temp\myfile.ini
    > Ini_Delete(ini, "section2", "key")
    > FileDelete, C:\Temp\myfile.ini
    > FileAppend, %ini%, C:\Temp\myfile.ini
*/
Ini_Delete(ByRef _Content, _Section, _Key = "")
{
    If (_Section = "")
    {
        ErrorLevel = 1
    }
    Else
    {
        If (_Key != "")
        {
            ini_replaceKey(_Content, _Section, _Key, "")
        }
        Else
        {
            ini_replaceSection(_Content, _Section, "")
        }
    }
    Return 
}


#NumpadSub::WinActivate, Test Configuration