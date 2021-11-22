; Multi instance AHK resetting script for set seed
; Original author Specnr, modified for set seed by Peej

; Follow setup video (mainly for OBS setup) https://youtu.be/0gaG-P2XxrE
; Run the setup script https://gist.github.com/Specnr/b13dae781f1b70bb6592027205870c7e
; Follow extra instructions https://gist.github.com/Specnr/c851a92a258dd1fdbe3eee588f3f14d8#gistcomment-3810003

#NoEnv
#SingleInstance Force

SetKeyDelay, 0
SetWinDelay, 1
SetTitleMatchMode, 2

; Variables to configure
global instanceFreezing := True
global unpauseOnSwitch := False
global fullscreen := True
global disableTTS := False
global countAttempts := True
global autoReset := False ; Resets idle worlds after 5 minutes
global beforeFreezeDelay := 4000 ; increase if doesnt join world
global fullScreenDelay := 270 ; increse if fullscreening issues
global obsDelay := 100 ; increase if not changing scenes in obs
global restartDelay := 200 ; increase if saying missing instanceNumber in .minecraft (and you ran setup)
global maxLoops := 20 ; increase if macro regularly locks
global oldWorldsFolder := "C:\Users\prana\OneDrive\Desktop\Minecraft\oldWorlds\" ; Old Worlds folder, make it whatever you want

; Don't configure these
global currInst := -1
global pauseAuto := False
global SavesDirectories := []
global instances := 0
global rawPIDs := []
global PIDs := []
global titles := []
global resetStates := []
global resetTimes := []

if (instanceFreezing) {
  UnsuspendAll()
  sleep, %restartDelay%
}
GetAllPIDs()
SetTitles()

tmptitle := ""
for i, tmppid in PIDs{
  WinGetTitle, tmptitle, ahk_pid %tmppid%
  titles.Push(tmptitle)
  resetStates.push(0)
  resetTimes.push(0)
  WinSet, AlwaysOnTop, Off, ahk_pid %tmppid%
}
IfNotExist, %oldWorldsFolder%
  FileCreateDir %oldWorldsFolder%
if (!disableTTS)
  ComObjCreate("SAPI.SpVoice").Speak("Ready")

global version = getVersion(SavesDirectories[1])

#Persistent
SetTimer, Repeat, 20
return

Repeat:
  Critical
  for i, pid in PIDs {
    HandleResetState(pid, i)
    WinGetTitle, title, ahk_pid %pid%
    if (title <> titles[i]) {
      titles[i] := title
      if (currInst > 0 && IsInGame(title)) {
        if (i != currInst) {
          IfWinNotActive, title
          {
            while (True) {
              if (HasGameSaved(i) || A_Index > maxLoops)
                break
            }
            ControlSend, ahk_parent, {Blind}{F3 Down}{Esc}{F3 Up}, ahk_pid %pid%
            if (instanceFreezing) {
              sleep, %beforeFreezeDelay%
              SuspendInstance(pid)
            }
            resetTimes[i] := A_TickCount
          }
        }
      }
    }
    if (autoReset && !pauseAuto) {
      timeDelta := 300000 ; 5 minutes
      if (IsInGame(title) && resetStates[i] == 0 && currInst != i && resetTimes[i] > 0) {
        if ((A_TickCount - resetTimes[i]) >= timeDelta)
          ResetInstance(i)
      }
    }
  }
return

HandleResetState(pid, idx) {
  if (resetStates[idx] == 0) ; Not resetting
    return
  if (resetStates[idx] == 1 && instanceFreezing) ; Need to resume
    ResumeInstance(pid)
  else if (resetStates[idx] == 2) ; Exit world
    ControlSend, ahk_parent, {Blind}{Shift down}{Tab}{Shift up}{Enter}, ahk_pid %pid%
  else if (resetStates[idx] == 3) { ; Move worlds
    MoveWorlds(idx) 
    if (countAttempts)
    {
      FileRead, WorldNumber, SSG_1_16.txt
      if (ErrorLevel)
        WorldNumber = 0
      else
        FileDelete, SSG_1_16.txt
      WorldNumber += 1
      FileAppend, %WorldNumber%, SSG_1_16.txt
    }
    resetStates[i] := False
  } else { ; Done
    resetStates[idx] := -1
  }
  resetStates[idx] += 1 ; Progress State
}

HasGameSaved(idx) {
  logFile := SavesDirectories[idx] . "logs\latest.log"
  numLines := 0
  Loop, Read, %logFile%
  {
    numLines += 1
  }
  saved := False
  startTime := A_TickCount
  Loop, Read, %logFile%
  {
    if ((numLines - A_Index) < 5)
    {
      if (InStr(A_LoopReadLine, "Loaded 0") || (InStr(A_LoopReadLine, "Saving chunks for level 'ServerLevel") && InStr(A_LoopReadLine, "minecraft:the_end"))) {
        saved := True
        break
      }
    }
  }
return saved
}

RunHide(Command)
{
  dhw := A_DetectHiddenWindows
  DetectHiddenWindows, On
  Run, %ComSpec%,, Hide, cPid
  WinWait, ahk_pid %cPid%
  DetectHiddenWindows, %dhw%
  DllCall("AttachConsole", "uint", cPid)

  Shell := ComObjCreate("WScript.Shell")
  Exec := Shell.Exec(Command)
  Result := Exec.StdOut.ReadAll()

  DllCall("FreeConsole")
  Process, Close, %cPid%
Return Result
}

GetSavesDir(pid)
{
  command := Format("powershell.exe $x = Get-WmiObject Win32_Process -Filter \""ProcessId = {1}\""; $x.CommandLine", pid)
  rawOut := RunHide(command)
  if (InStr(rawOut, "--gameDir")) {
    strStart := RegExMatch(rawOut, "P)--gameDir (?:""(.+?)""|([^\s]+))", strLen, 1)
    return SubStr(rawOut, strStart+10, strLen-10) . "\"
  } else {
    strStart := RegExMatch(rawOut, "P)(?:-Djava\.library\.path=(.+?) )|(?:\""-Djava\.library.path=(.+?)\"")", strLen, 1)
    if (SubStr(rawOut, strStart+20, 1) == "=") {
      strLen -= 1
      strStart += 1
    }
    return StrReplace(SubStr(rawOut, strStart+20, strLen-28) . ".minecraft\", "/", "\")
  }
}

GetInstanceTotal() {
  idx := 1
  global rawPIDs
  WinGet, all, list
  Loop, %all%
  {
    WinGet, pid, PID, % "ahk_id " all%A_Index%
    WinGetTitle, title, ahk_pid %pid%
    if (InStr(title, "Minecraft*")) {
      rawPIDs[idx] := pid
      idx += 1
    }
  }
return rawPIDs.MaxIndex()
}

GetInstanceNumberFromSaves(saves) {
  numFile := saves . "instanceNumber.txt"
  num := -1
  if (saves == "" || saves == ".minecraft") ; Misread something
    Reload
  if (!FileExist(numFile))
    MsgBox, Missing instanceNumber.txt in %saves%. Run the setup script (see instructions)
  else
    FileRead, num, %numFile%
return num
}

GetAllPIDs()
{
  global SavesDirectories
  global PIDs
  global instances := GetInstanceTotal()
  ; Generate saves and order PIDs
  Loop, %instances% {
    saves := GetSavesDir(rawPIDs[A_Index])
    if (num := GetInstanceNumberFromSaves(saves)) == -1
      ExitApp
    PIDS[num] := rawPIDs[A_Index]
    SavesDirectories[num] := saves
  }
}

FreeMemory(pid)
{
  h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
  DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
  DllCall("CloseHandle", "Int", h)
}

UnsuspendAll() {
  currInst := -1
  WinGet, all, list
  Loop, %all%
  {
    WinGet, pid, PID, % "ahk_id " all%A_Index%
    WinGetTitle, title, ahk_pid %pid%
    if (InStr(title, "Minecraft*"))
      ResumeInstance(pid)
  }
}

SuspendInstance(pid) {
  hProcess := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", 0, "Int", pid)
  If (hProcess) {
    DllCall("ntdll.dll\NtSuspendProcess", "Int", hProcess)
    DllCall("CloseHandle", "Int", hProcess)
  }
  FreeMemory(pid)
}

ResumeInstance(pid) {
  hProcess := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", 0, "Int", pid)
  If (hProcess) {
    DllCall("ntdll.dll\NtResumeProcess", "Int", hProcess)
    DllCall("CloseHandle", "Int", hProcess)
  }
}

IsProcessSuspended(pid) {
  WinGetTitle, title, ahk_pid %pid%
return InStr(title, "Not Responding")
}

SwitchInstance(idx)
{
  currInst := idx
  pid := PIDs[idx]
  if (instanceFreezing)
    ResumeInstance(pid)
  WinSet, AlwaysOnTop, On, ahk_pid %pid%
  WinSet, AlwaysOnTop, Off, ahk_pid %pid%
  send {Numpad%idx% down}
  sleep, %obsDelay%
  send {Numpad%idx% up}
  if (fullscreen) {
    ControlSend, ahk_parent, {Blind}{F11}, ahk_pid %pid%
    sleep, %fullScreenDelay%
  }
  Send, {LButton} ; Make sure the window is activated
}

MoveWorlds(idx)
{
  dir := SavesDirectories[idx] . "saves\"
  Loop, Files, %dir%*, D
  {
    If (InStr(A_LoopFileName, "New World") || InStr(A_LoopFileName, "Speedrun #")) {
      tmp := A_NowUTC
      FileMoveDir, %dir%%A_LoopFileName%, %dir%%A_LoopFileName%%tmp%Instance %idx%, R
      FileMoveDir, %dir%%A_LoopFileName%%tmp%Instance %idx%, %oldWorldsFolder%%A_LoopFileName%%tmp%Instance %idx%
    }
  }
}

GetActiveInstanceNum() {
  WinGet, pid, PID, A
  WinGetTitle, title, ahk_pid %pid%
  if (IsInGame(title)) {
    for i, tmppid in PIDs {
      if (tmppid == pid)
        return i
    }
  }
return -1
}

IsInGame(currTitle) { ; If using another language, change Singleplayer and Multiplayer to match game title
return InStr(currTitle, "Singleplayer") || InStr(currTitle, "Multiplayer") || InStr(currTitle, "Instance")
}

ExitWorld()
{
  if (fullscreen) {
    send, {F11}
    sleep, %fullScreenDelay%
  }
  if (idx := GetActiveInstanceNum()) > 0
  {
    WinSet, AlwaysOnTop, Off, ahk_pid %pid%
    nextIdx := Mod(idx, instances) + 1
    nextPID := PIDs[nextIdx]
    pauseAuto := True
    SwitchInstance(nextIdx)
    if (unpauseOnSwitch)
      ControlSend, ahk_parent, {Blind}{Esc}, ahk_pid %nextPID%
    ResetInstance(idx, False)
    pauseAuto := False
  }
}

ResetInstance(idx, bg := True) {
  if (bg) {
    pid := PIDs[idx]
    WinGetTitle, title, ahk_pid %pid%
    if (GetActiveInstanceNum() == idx || !IsInGame(title))
      return
    ControlSend, ahk_parent, {Blind}{Esc 2}, ahk_pid %pid%
    if (instanceFreezing)
      resetStates[idx] := 1 ; Set to Resume Instance
    else
      resetStates[idx] := 2 ; Set to Exit world
  } else {
    pid := PIDs[idx]
    ControlSend, ahk_parent, {Blind}{Esc}, ahk_pid %pid%
    resetStates[idx] := 2 ; Set to Exit world
  }
}

SetTitles() {
  for i, pid in PIDs {
    WinSetTitle, ahk_pid %pid%, , Minecraft* - Instance %i%
  }
}

Perch()
{
   OpenToLAN()
   Send, /
   Sleep, 70
   SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
   Send, {enter}
}

OpenToLAN()
{
  savesDirectory := SavesDirectories[GetActiveInstanceNum()]
  thePID := PIDs[GetActiveInstanceNum()]
   Send, {Esc} ; pause
   ShiftTab(thePID, 2)
   if (fastResetModExist(savesDirectory))
  {
    ShiftTab(thePID)
  }
   Send, {enter} ; open to LAN
   if (version = 17)
   {
      Send, {tab}{tab}{enter} ; cheats on
   }
   else
   {
      ShiftTab(thePID)
      Send, {enter} ; cheats on
   }
   Send, `t
   Send, {enter} ; open to LAN
   WaitForHost(savesDirectory)
}

ShiftTab(thePID, n := 1)
{
   if WinActive("ahk_pid" thePID)
   {
      Loop, %n%
      {
         Send, +`t
      }
   }
   else
   {
      ControlSend, ahk_parent, {Blind}{Shift down}, ahk_pid %thePID%
      Loop, %n%
      {
         ControlSend, ahk_parent, {Blind}{Tab}, ahk_pid %thePID%
      }
      ControlSend, ahk_parent, {Blind}{Shift up}, ahk_pid %thePID%
   }
}

fastResetModExist(savesDirectory)
{
   modsFolder := StrReplace(savesDirectory, "saves", "mods") . "mods"
   ;MsgBox, %modsFolder%
   Loop, Files, %modsFolder%\*.*, F
   {
    ;MsgBox, %A_LoopFileName%
      if(InStr(A_LoopFileName, "fast-reset"))
      {
         return True
      }
   }
}

WaitForHost(savesDirectory)
{
   logFile := StrReplace(savesDirectory, "saves", "logs\latest.log") . "logs\latest.log"
   numLines := 0
   Loop, Read, %logFile%
   {
      numLines += 1
   }
   openedToLAN := False
   startTime := A_TickCount
   while (!openedToLAN)
   {
      OutputDebug, reading log file
      if ((A_TickCount - startTime) > 5000)
      {
         OutputDebug, open to lan timed out
         openedToLAN := True
      }
      Loop, Read, %logFile%
      {
         if ((A_TickCount - startTime) > 5000)
         {
            OutputDebug, open to lan timed out
            openedToLAN := True
         }
         if ((numLines - A_Index) < 2)
         {
            OutputDebug, %A_LoopReadLine%
            if (InStr(A_LoopReadLine, "[CHAT] Local game hosted on port"))
            {
               OutputDebug, found the [CHAT] Local game hosted on port
               openedToLAN := True
            }
         }
      }
   }
}

Test()
{
  thePID := PIDs[GetActiveInstanceNum()]
  ShiftTab(thePID, 3)
}


getVersion(savesDirectory)
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt") . "options.txt"
   ;MsgBox, %optionsFile%
   FileReadLine, versionLine, %optionsFile%, 1
   arr := StrSplit(versionLine, ":")
   dataVersion := arr[2]
   ;MsgBox, %dataVersion%
   if (dataVersion > 2600)
      return (17)
   else
      return (16)
}

RAlt::Suspend ; Pause all macros
#IfWinActive, Minecraft
  {
    PgDn:: ExitWorld() ; Reset
    
    End:: ; Perch
		Perch()
	return
    
    Insert::
      Test()
    return

    ; Follow the pattern if you have more instances
    ; Remove keys you dont use to avoid complications
    F5:: ; Reload if macro locks up
      Reload
    return
  }