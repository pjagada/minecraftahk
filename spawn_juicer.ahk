; Multi instance AHK resetting script for set seed
; Original author Specnr, modified for set seed by Peej

; Follow setup video (mainly for OBS setup) https://youtu.be/0gaG-P2XxrE
; Run the setup script https://gist.github.com/Specnr/b13dae781f1b70bb6592027205870c7e
; Follow extra instructions https://gist.github.com/Specnr/c851a92a258dd1fdbe3eee588f3f14d8#gistcomment-3810003

; When you run this, make sure all instances are in a world and paused or on the title screen. If they are on a loading screen, this will probably break.

; Autoresetter use:
;   1) By default, the autoresetter will reset all spawns outside of the set radius of the set focal point and will alert you of any spawns inside or equal to the set radius of the set focal point.
;   2) If there are only a few spawns that you're going to reset, create a file (in same folder as this script) called blacklist.txt and set the autoresetter radius to something very large like 1000.
;   3) If there are only a few spawns that you're going to play, crate a file (in same folder as this script) called whitelist.txt and set the autoresetter radius to a negative number like -1.
;   4) You can also use the blacklist and whitelist features in combination with each other and in combination with the radius.
;      For example, if the radius is mostly good but some spawns within it put you in like a hole, you can blacklist those spawns.
;      Apply the inverse concept for a whitelist.
;   5) In your blacklist.txt and/or whitelist.txt, each line should be of the following format:
;      X1,Z1;X2,Z2
;      Those coordinates should be opposite corners of a rectangle. Any spawns within that rectangle will be automatically counted as a good spawn if that rectangle was obtained from whitelist.txt.
;      Similarly, if that rectangle is obtained from blacklist.txt, any spawns within that rectangle will be resetted automatically. The whitelist is consulted first, the blacklist second, and the radius last.
;   6) If the autoresetter gives you a spawn that you don't like, you can add it to the blacklist by pressing Ctrl B (the same thing you would press to bold text).
;      It will blacklist the most recent spawn of the active instance, so keep that in mind when pressing Ctrl B.
;   7) Because of this feature, I recommend starting out with a higher radius than you would need, then just add bad spawns to the blacklist.
;   8) If no spawns are available, then you can tab out, and it will continue to run and will activate the next instance that has a good spawn.
;   9) If you reset and multiple spawns are available, then it will activate the instance with the closest spawn to the focal point.

#NoEnv
#SingleInstance Force
;#Warn

SetKeyDelay, 0
SetWinDelay, 1
SetTitleMatchMode, 2

; macro options:
global instanceFreezing := True ; you probably want to keep this on (true)
global unpauseOnSwitch := False
global fullscreen := False ; all resets will be windowed, this will automatically fullscreen the instance that's about to be played
global playSound := True ; will play a windows sound or the sound stored as spawnready.mp3 whenever a spawn is ready
global disableTTS := False ; this is the "ready" sound that plays when the macro is ready to go
global countAttempts := True
global beforeFreezeDelay := 2000 ; increase if doesnt join world
global fullScreenDelay := 270 ; increse if fullscreening issues
global obsDelay := 100 ; increase if not changing scenes in obs
global restartDelay := 200 ; increase if saying missing instanceNumber in .minecraft (and you ran setup)
global maxLoops := 20 ; increase if macro regularly locks
global screenDelay := 1000 ; normal delay of each world creation screen, increase if random seeds are being created1, decrease for faster resets
global oldWorldsFolder := "C:\Users\prana\OneDrive\Desktop\Minecraft\oldWorlds\" ; Old Worlds folder, make it whatever you want

; Autoresetter Options:
; The autoresetter will automatically reset if your spawn is greater than a certain number of blocks away from a certain point (ignoring y)
global centerPointX := 162.7 ; this is the x coordinate of that certain point (by default it's the x coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global centerPointZ := 194.5 ; this is the z coordinate of that certain point (by default it's the z coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global radius := 13 ; if this is 10 for example, the autoresetter will not reset if you are within 10 blocks of the point specified above. Set this smaller for better spawns but more resets
; if you would only like to reset the blacklisted spawns or don't want automatic resets, then just set this number really large (1000 should be good enough), and if you would only like to play out whitelisted spawns, then just make this number negative
global difficulty := "Normal" ; Set difficulty here. Options: "Peaceful" "Easy" "Normal" "Hard" "Hardcore"
global SEED := "-3294725893620991126" ; Default seed is the current Any% SSG 1.16+ seed, you can change it to whatever seed you want.
global giveAngle := True ; Give the angle (TTS) that you need to travel at to get to your starting point

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
global startTimes := []
global reachedSave := []
global xCoords := []
global zCoords := []
global distances := []
global playerState := 0 ; needs spawn

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
  if (inWorld(i))
  {
    resetStates.push(2) ; need to exit
  }
  else
  {
    resetStates.push(4) ; on title screen
  }
  resetTimes.push(0)
  xCoords.Push(0)
  zCoords.Push(0)
  distances.Push(0)
  startTimes.Push(A_TickCount)
  reachedSave.Push(false)
  WinSet, AlwaysOnTop, Off, ahk_pid %tmppid%
}
if ((difficulty != "Peaceful") and (difficulty != "Easy") and (difficulty != "Normal") and (difficulty != "Hard") and (difficulty != "Hardcore"))
{
   MsgBox, Difficulty entered is invalid. Please check your spelling and enter a valid difficulty. Options are "Peaceful" "Easy" "Normal" "Hard" or "Hardcore"
   ExitApp
}
global version = getVersion()

for k, saves_directory in SavesDirectories
{
    ;OutputDebug, [macro] k is %k% saves_directory is %saves_directory%
	if (PauseOnLostFocus(saves_directory))
	{
		MsgBox, Instance %k% has pause on lost focus enabled. Disable this feature by pressing F3 + P in-game, then start the script again.
		ExitApp
	}
}

IfNotExist, %oldWorldsFolder%
  FileCreateDir %oldWorldsFolder%
if (!disableTTS)
  ComObjCreate("SAPI.SpVoice").Speak("Ready")
MsgBox, resetting will start when you close this box

#Persistent
SetTimer, Repeat, 20
return

Repeat:
  Critical
  for i, pid in PIDs {
    HandleResetState(pid, i)
  }
  HandlePlayerState()
return

HandlePlayerState()
{
  if (playerState == 0) ; needs spawn
  {
    instancesWithGoodSpawns := []
    for r, state in resetStates
    {
      if (state >= 13)
      {
        instancesWithGoodSpawns.Push(r)
      }
    }
    bestSpawn := -1
    counter = 0
    for p, q in instancesWithGoodSpawns
    {
      counter += 1
      if (counter = 1)
      {
        minDist := distances[q]
        bestSpawn := q
      }
      theDistance := distances[q]
      if (theDistance <= minDist)
      {
        minDist := distances[q]
		bestSpawn := q
      }
	}
	if (counter > 0)
	{
      resetStates[bestSpawn] := 0 ; running
      SwitchInstance(bestSpawn)
      AlertUser(bestSpawn)
      playerState := 1 ; running
      
    }
  }
}

HandleResetState(pid, idx) {
  if (resetStates[idx] == 0) ; running
    return
  else if (resetStates[idx] == 1) ; needs to reset from play
  {
    WinSet, AlwaysOnTop, Off, ahk_pid %pid%
    ControlSend, ahk_parent, {Blind}{Esc}, ahk_pid %pid%
  }
  else if (resetStates[idx] == 2) ; need to exit world from pause
  {
    ControlSend, ahk_parent, {Blind}{Shift down}{Tab}{Shift up}{Enter}, ahk_pid %pid%
  }
  else if (resetStates[idx] == 3) ; exiting world
  {
    if (inWorld(idx))
      return
  }
  else if (resetStates[idx] == 4) ; on title screen
  {
    EnterSingleplayer(idx)
  }
  else if (resetStates[idx] == 5) ; on world list screen
  {
    WorldListScreen(idx)
  }
  else if (resetStates[idx] == 6) ; on create new world screen
  {
    CreateNewWorldScreen(idx)
  }
  else if (resetStates[idx] == 7) ; on more world options screen
  {
    MoreWorldOptionsScreen(idx)
  }
  else if (resetStates[idx] == 8) { ; Move worlds
    MoveWorlds(idx)
  }
  else if (resetStates[idx] == 9) { ; count attempts
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
  }
  else if (resetStates[idx] == 10) { ; checking if loaded in
    WinGetTitle, title, ahk_pid %pid%
    if (IsInGame(title))
    {
      ControlSend, ahk_parent, {Blind}{Esc}, ahk_pid %pid%
    }
    else
    {
      return
    }
  }
  else if (resetStates[idx] == 11) ; get spawn
  {
    GetSpawn(idx)
  }
  else if (resetStates[idx] == 12) ; check spawn
  {
    if (GoodSpawn(idx)) {
      resetStates[idx] := 13 ; good spawn unfrozen
    }
    else
    {
      resetStates[idx] := 2 ; need to exit world
    }
    return
  }
  else if (resetStates[idx] == 13) ; good spawn waiting to reach final save
  {
    if (playerState == 0) ; needs spawn so this instance about to be used
    {
      return
    }
    if (!(HasGameSaved(idx)))
    {
      return
    }
    startTimes[idx] := A_TickCount
  }
  else if (resetStates[idx] == 14) ; good spawn waiting for freeze delay to finish then freezing
  {
    if ((A_TickCount - startTimes[idx] < beforeFreezeDelay))
    {
      return
    }
    SuspendInstance(pid)
  }
  else if (resetStates[idx] == 15) ; frozen good spawn waiting to be used
  {
    return
  }
  else {
    MsgBox, instance %idx% ended up at some other reset state, exiting script
    ExitApp
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
    WinGet, thePID, PID, % "ahk_id " all%A_Index%
    WinGetTitle, title, ahk_pid %thePID%
    if (InStr(title, "Minecraft*")) {
      rawPIDs[idx] := thePID
      ;OutputDebug, [macro] idx: %idx%, title: %title%, pid: %pid%
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
  ;OutputDebug, [macro] %instances% instances
  ; Generate saves and order PIDs
  Loop, %instances% {
    saves := GetSavesDir(rawPIDs[A_Index])
    if (num := GetInstanceNumberFromSaves(saves)) == -1
      ExitApp
    PIDS[num] := rawPIDs[A_Index]
    SavesDirectories[num] := saves
    ;OutputDebug, [macro] saves: %saves% index: %A_Index%
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
    WinGet, thePID, PID, % "ahk_id " all%A_Index%
    WinGetTitle, title, ahk_pid %thePID%
    if (InStr(title, "Minecraft*"))
      ResumeInstance(thePID)
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
  thePID := PIDs[idx]
  if (instanceFreezing)
    ResumeInstance(thePID)
  WinSet, AlwaysOnTop, On, ahk_pid %thePID%
  WinSet, AlwaysOnTop, Off, ahk_pid %thePID%
  send {Numpad%idx% down}
  sleep, %obsDelay%
  send {Numpad%idx% up}
  if (fullscreen) {
    ControlSend, ahk_parent, {Blind}{F11}, ahk_pid %thePID%
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
  WinGet, thePID, PID, A
  WinGetTitle, title, ahk_pid %thePID%
  if (IsInGame(title)) {
    for r, temppid in PIDs {
      if (temppid == thePID)
        return r
    }
  }
return -1
}

IsInGame(currTitle) { ; If using another language, change Singleplayer and Multiplayer to match game title
return InStr(currTitle, "Singleplayer") || InStr(currTitle, "Multiplayer") || InStr(currTitle, "Instance")
}

ExitWorld()
{
  idx := GetActiveInstanceNum()
  if (inFullscreen(idx)) {
    send, {F11}
    sleep, %fullScreenDelay%
  }
  playerState := 0 ; needs spawn
  resetStates[idx] := 1 ; needs to exit from play
  
}

SetTitles() {
  for g, thePID in PIDs {
    WinSetTitle, ahk_pid %thePID%, , Minecraft* - Instance %g%
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

inWorld(idx)
{
  mcDirectory := SavesDirectories[idx]
  lastWorld := getMostRecentFile(mcDirectory)
  lockFile := lastWorld . "\session.lock"
  FileRead, sessionlockfile, %lockFile%
  if (ErrorLevel = 0)
  {
    return false
  }
  return true
}

getMostRecentFile(mcDirectory)
{
  savesDirectory := mcDirectory . "saves"
  ;MsgBox, %savesDirectory%
	counter := 0
	Loop, Files, %savesDirectory%\*.*, D
	{
		counter += 1
		if (counter = 1)
		{
			maxTime := A_LoopFileTimeModified
			mostRecentFile := A_LoopFileLongPath
		}
		if (A_LoopFileTimeModified >= maxTime)
		{
			maxTime := A_LoopFileTimeModified
			mostRecentFile := A_LoopFileLongPath
		}
	}
   recentFile := mostRecentFile
   return (recentFile)
}

EnterSingleplayer(n)
{
	thePID := PIDs[n]
	Sleep, %screenDelay%
    ControlSend, ahk_parent, {Blind}{Tab}{Enter}, ahk_pid %thePID%
}

WorldListScreen(n)
{
  thePID := PIDs[n]
  ControlSend, ahk_parent, {Blind}{Tab 3}, ahk_pid %thePID%
  Sleep, %screenDelay%
  ControlSend, ahk_parent, {Blind}{enter}, ahk_pid %thePID%
}

CreateNewWorldScreen(n)
{
  thePID := PIDs[n]
  if (difficulty = "Normal")
  {
    ControlSend, ahk_parent, {Blind}{Tab 6}, ahk_pid %thePID%
  }
  else
  {
    ControlSend, ahk_parent, {Blind}{Tab}, ahk_pid %thePID%
    if (difficulty = "Hardcore")
    {
      ControlSend, ahk_parent, {Blind}{enter}, ahk_pid %thePID%
    }
    ControlSend, ahk_parent, {Blind}{Tab}, ahk_pid %thePID%
    if (difficulty != "Hardcore")
    {
      ControlSend, ahk_parent, {Blind}{enter}, ahk_pid %thePID%
      if (difficulty != "Hard")
      {
        ControlSend, ahk_parent, {Blind}{enter}, ahk_pid %thePID%
        if (difficulty != "Peaceful")
        {
          ControlSend, ahk_parent, {Blind}{enter}, ahk_pid %thePID%
        }
      }
    }
    if (difficulty != "Hardcore")
    {
      ControlSend, ahk_parent, {Blind}{Tab}{Tab}, ahk_pid %thePID%
    }
    ControlSend, ahk_parent, {Blind}{Tab}{Tab}, ahk_pid %thePID%
  }
  Sleep, %screenDelay%
  ControlSend, ahk_parent, {Blind}{enter}, ahk_pid %thePID%
}

MoreWorldOptionsScreen(n)
{
	thePID := PIDs[n]
      ControlSend, ahk_parent, {Blind}{Tab 3}, ahk_pid %thePID%
      Sleep, 1
      InputSeed(thePID)
      Sleep, 1
      ControlSend, ahk_parent, {Blind}{Tab 6}, ahk_pid %thePID%
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {Blind}{enter}, ahk_pid %thePID%
}

InputSeed(thePID)
{
  SetKeyDelay, 1
   if WinActive("ahk_pid" thePID)
   {
      SendInput, %SEED%
   }
   else
   {
      ControlSend, ahk_parent, {Blind}%SEED%, ahk_pid %thePID%
   }
   SetKeyDelay, 0
}

Test()
{
  two := inWorld(1)
  MsgBox, %two%
}


getVersion()
{
  savesDirectory := SavesDirectories[1]
  ;OutputDebug, [macro] %savesDirectory%
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt") . "options.txt"
   ;OutputDebug, [macro] options file is %optionsFile%
   FileReadLine, versionLine, %optionsFile%, 1
   arr := StrSplit(versionLine, ":")
   dataVersion := arr[2]
   ;OutputDebug, [macro] data version is %dataVersion%
   if (dataVersion > 2600)
      return (17)
   else
      return (16)
}

PauseOnLostFocus(savesDirectory) ;used on script startup
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt") . "options.txt"
   ;OutputDebug, [macro] %optionsFile% version is %version%
   if (version = 16)
      FileReadLine, optionLine, %optionsFile%, 45
   else
      FileReadLine, optionLine, %optionsFile%, 48
   if (InStr(optionLine, "true"))
      return 1
   else
      return 0
}

inFullscreen(idx)
{
  savesDirectory := SavesDirectories[idx]
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt") . "options.txt"
   FileReadLine, fullscreenLine, %optionsFile%, 17
   if (InStr(fullscreenLine, "true"))
      return 1
   else
      return 0
}

GiveAngle(n)
{
   if (giveAngle == True)
   {
      xDiff := xCoords[n] - centerPointX
      currentX := xCoords[n]
      OutputDebug, [macro] current x coords %currentX% minus destination X %centerPointX% equals %xDiff%
      zDiff := centerPointZ - zCoords[n]
      currentZ := zCoords[n]
      OutputDebug, [macro] destination Z %centerPointZ% minus current z coords %currentZ% equals %zDiff%
      angle := ATan(xDiff / zDiff) * 180 / 3.14159265358979
      OutputDebug, [macro] raw angle is %angle%
      if (zDiff < 0)
      {
         angle := angle - 180
         OutputDebug, [macro] destination is north of spawn so subtracting 180 from angle for new angle of %angle%
      }
      if (zDiff = 0)
      {
         OutputDebug, [macro] z difference is 0 so it's a 90 degree
         if (xDiff < 0)
         {
            OutputDebug, [macro] x difference is negative so angle is -90 degrees
            angle := -90.0
         }
         else if (xDiff > 0)
         {
            OutputDebug, [macro] x difference is positive so angle is 90 degrees
            angle := 90.0
         }
      }
      angleList := StrSplit(angle, ".")
      intAngle := angleList[1]
      OutputDebug, integer angle is %intAngle%
      ComObjCreate("SAPI.SpVoice").Speak(intAngle)
   }
}

GoodSpawn(n)
{
   xCoord := xCoords[n]
   zCoord := zCoords[n]
   OutputDebug, [macro] spawn is %xCoord%, %zCoord%
   xDisplacement := xCoord - centerPointX
   zDisplacement := zCoord - centerPointZ
   distance := Sqrt((xDisplacement * xDisplacement) + (zDisplacement * zDisplacement))
   OutputDebug, [macro] distance of %distance%
   distances[n] := distance
   if (inList(xCoord, zCoord, "whitelist.txt"))
   {
      OutputDebug, [macro] in whitelist
      return True
   }
   if (inList(xCoord, zCoord, "blacklist.txt"))
   {
      OutputDebug, [macro] in blacklist
      return False
   }
   if (distance <= radius)
      return True
   else
      return False
}

inList(xCoord, zCoord, fileName)
{
   if (FileExist(fileName))
   {
      Loop, read, %fileName%
      {
         arr0 := StrSplit(A_LoopReadLine, ";")
         corner1 := arr0[1]
         corner2 := arr0[2]
         arr1 := StrSplit(corner1, ",")
         arr2 := StrSplit(corner2, ",")
         X1 := arr1[1]
         Z1 := arr1[2]
         X2 := arr2[1]
         Z2 := arr2[2]
         if ((((xCoord <= X1) && (xCoord >= X2)) or ((xCoord >= X1) && (xCoord <= X2))) and (((zCoord <= Z1) && (zCoord >= Z2)) or ((zCoord >= Z1) && (zCoord <= Z2))))
            return True
      }
   }
   return False
}

GetSpawn(i)
{
  logFile := StrReplace(savesDirectories[i], "saves", "logs\latest.log") . "logs\latest.log"
  numLines := 0
  Loop, Read, %logFile%
  {
    numLines += 1
  }
  Loop, Read, %logFile%
  {
    if ((numLines - A_Index) <= 15)
	{
      if (InStr(A_LoopReadLine, "logged in with entity id"))
      {
		spawnLine := A_LoopReadLine
		array1 := StrSplit(spawnLine, " at (")
		xyz := array1[2]
		array2 := StrSplit(xyz, ", ")
		xCoord := array2[1]
		zCooord := array2[3]
		array3 := StrSplit(zCooord, ")")
		zCoord := array3[1]
		xCoords[i] := xCoord
		zCoords[i] := zCoord
      }
    }
  }
}

AlertUser(n)
{
   thePID := PIDs[n]
	if (playSound)
	{
		if (FileExist("spawnready.mp3"))
			SoundPlay, spawnready.mp3
		else
			SoundPlay *16
	}
	if (unpauseOnSwitch = true)
	{
		Send, {Esc}
	}
    GiveAngle(n)
}

AddToBlacklist()
{
	t := GetActiveInstanceNum()
   xCoord := xCoords[t]
   zCoord := zCoords[t]
   OutputDebug, [macro] blacklisting %xCoord%, %zCoord%
   theString := xCoord . "," . zCoord . ";" . xCoord . "," . zCoord
   if (!FileExist("blacklist.txt"))
      FileAppend, %theString%, blacklist.txt
   else
      FileAppend, `n%theString%, blacklist.txt
}


#IfWinActive, Minecraft
{
  RAlt::  ; Pause all macros
    Suspend
  return
    PgDn:: ; Reset
      ExitWorld()
    return
    
    End:: ; Perch
		Perch()
	return
    
    Insert::
      Test()
    return

    F5:: ; Reload if macro locks up
      UnsuspendAll()
      Reload
   return 
   
   ^B:: ; This is where the keybind is set for adding a spawn to the blacklisted spawns.
		AddToBlacklist()
	return
    
   ^End:: ; This is where the keybind is set to safely close the script
      UnsuspendAll()
      ExitApp
   return
}