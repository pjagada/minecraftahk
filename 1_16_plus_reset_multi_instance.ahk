; Minecraft Reset Script for multiple instances (1.16+)
; Author:  Peej, with help/code from jojoe77777, Specnr, Four, onvo, SLTRR, DesktopFolder, and _D4rkS0ul_
; Authors are not liable for any run rejections.
; To use this script, make sure you have autohotkey installed (autohotkey.com), then right click on the script file, and click "Run Script."
; If you make any changes to the script by right clicking and clicking "Edit Script," make sure to reload the script by pressing F5 or by right clicking on the logo in your taskbar and clicking "Reload Script."

; Script Function / Help:
;  The following only apply inside the Minecraft window:
;   1) When on the title screen or in a previous world (whether paused or unpaused), the "PgUp" key will create a world.
;   2) If you are using multiple instances, it will automatically switch to the next instance once the load starts.
;   3) "PgDn" will do the same thing as "PgUp," but it will also delete the previous world if the world folder name starts with an underscore (or move it to another folder if you have that option selected).
;   4) Make sure you have a world in each saves folder, otherwise it's not going to work.
;   5) To open to LAN and make the dragon perch (make sure you're not in an inventory or already paused), press "End"
;   6) To change the "PgDn" and "PgUp" and "End," scroll down to the bottom of this script, change the character before the double colon "::", and reload the script.
;      https://www.autohotkey.com/docs/KeyList.htm Here are a list of the keys you can use.
;   7) If you want to use a different seed, change the difficulty, or change the world name, scroll down to the Options and you can change those.
;   8) If you are in a minecraft world and inside an inventory, close that inventory before activating the script (otherwise, the macro will not function properly).
;      The macro that creates a new world only works from the title screen, from a previous world paused, or from a previous world unpaused.

; Troubleshooting:
;   Press F5 to reload the script and redo all the selections.
;   The switching of instances doesn't work with borderless so either use windowed bordered or fullscreen. borderless users do this ---> peepopogclimbingtreehard4house
;
;   Q: Why is it creating a random seed?
;   A: The first world when you start up Minecraft has a lot of lag associated with it, so it will probably malfunction for that first world but should be fine afterwards.
;
;   Q: Why does it spend so long at the world list screen?
;   A: Go a few lines down and decrease the number after the words "global worldListWait := "
;
;   Q: It doesn't do anything when I click run script / Run script doesn't appear.
;   A: Right click the file, click "Open with" -> "Choose another app" -> "More apps" -> "Look for another app on this PC," then find the AutoHotkey folder (likely in Program Files).
;      Go into that folder, and double click on AutoHotkeyU64.exe. If that's not there, then reinstall AutoHotkey.
;
;   Q: Why is it getting stuck at the title screen?
;   A: You're likely using fast reset mod versions 1.3.3. Try version 1.3.1 found in the 1.16 HQ server.
;      Make sure you also have at least one world in each saves directory that you're using.

 
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; Options:
global savesDirectories := ["C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.16.11\.minecraft\saves"]
global screenDelay := 50 ; Change this value to increase/decrease the number of time (in milliseconds) that each world creation screen is held for. For your run to be verifiable, each of the three screens of world creation must be shown.
global worldListWait := 200 ; The macro will wait for the world list screen to show before proceeding, but sometimes this feature doesn't work, especially if you use fullscreen, and always if you're tabbed out during this part.
                            ; In that case, this number (in milliseconds) defines the hard limit that it will wait after clicking on "Singleplayer" before proceeding.
                            ; This number should basically just be a little longer than your world list screen showing lag.

global difficulty := "Normal" ; Set difficulty here. Options: "Peaceful" "Easy" "Normal" "Hard" "Hardcore"
global mode := "RSG" ; either SSG or RSG
global SEED := "-3294725893620991126" ; Default seed is the current Any% SSG 1.16+ seed, you can change it to whatever seed you want (will not do anything if doing rsg).

global countAttempts := "No" ; Change this to "Yes" if you would like the world name to include the attempt number, otherwise, keep it as "No"
                             ; The script will automatically create a text file to track your attempts starting from 1, but if you already have some attempts,
                             ; you can make a file called SSG_1_16.txt and put the number your attempts there. You can change that file whenever you want if the number ever gets messed up.
global worldName := "New World" ; you can name the world whatever you want, put the name inside the quotation marks.
                                ; If you selected "Yes" in the above option to counting attempts, this name will be the prefix.
                                ; For example, if you leave this as "New World" and you're on attempt 343, then the world will be named "New World343"
                                ; To just show the attempt number, change this variable to ""

global previousWorldOption := "move" ; What to do with the previous world (either "delete" or "move") when the Page Down hotkey is used. If it says "move" then worlds will be moved to a folder called oldWorlds in your .minecraft folder. This does not apply to worlds whose files start with an "_" (without the quotes)
global inputMethod := "click" ; either "click" or "key" (click is theoretically faster but kinda experimental at this point and may not work properly depending on your resolution)
global fullscreenOnLoad = "No" ; change this to "Yes" if you would like the macro ensure that you are in fullscreen mode when the world is ready (a little experimental so I would recommend not using this in case of verification issues)
global pauseOnLoad := "No" ; change this to "No" if you would like the macro to not automatically pause when the world loads in
global unpauseOnSwitch := "No" ; change this to "Yes" if you would like the macro to automatically unpause when you switch to the next instance

fastResetModExist(savesDirectory)
{
   modsFolder := StrReplace(savesDirectory, "saves", "mods")
   Loop, Files, %modsFolder%\*.*, F
   {
      if(InStr(A_LoopFileName, "fast-reset"))
      {
         return True
      }
   }
}

WaitForHost(savesDirectory)
{
   logFile := StrReplace(savesDirectory, "saves", "logs\latest.log")
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
      ControlSend, ahk_parent, {Shift down}, ahk_pid %thePID%
      Loop, %n%
      {
         ControlSend, ahk_parent, {Tab}, ahk_pid %thePID%
      }
      ControlSend, ahk_parent, {Shift up}, ahk_pid %thePID%
   }
}

getSavesDirectory()
{
   WinGet, thePID, PID, A
   OutputDebug, getting saves directory of PID number %thePID%
   if (numInstances > 1)
   {
      OutputDebug, have to select saves directory from PID since we are on more than one instance
      OutputDebug, current PID: %thePID%
      Loop, %numInstances%
      {
         if (thePID = PIDs[A_Index])
         {
            OutputDebug, we are on instance %A_Index%
            savesDirectory := savesDirectories[A_Index]
         }
      }
      return (savesDirectory)
   }
   else
   {
      OutputDebug, only using one instance so saves directory is saves directory
      return (savesDirectories[1])
   }
}

Perch()
{
   WinGet, thePID, PID, A
   savesDirectory := getSavesDirectory()
   SetKeyDelay, 1
   if (version = 17)
   {
      OutputDebug, 1.17 perch
      Send, {Esc} ; pause
      ShiftTab(thePID, 2)
      if (fastResetModExist(savesDirectory))
      {
         ShiftTab(thePID, 1)
      }
      Send, {enter} ; open to LAN
      Send, {tab}{tab}{enter} ; cheats on
      Send, `t
      Send, {enter} ; open to LAN
      WaitForHost(savesDirectory)
      Send, /
      Sleep, 70
      SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
      Send, {enter}
   }
   else
   {
      OutputDebug, 1.16 perch
      Send, {Esc} ; pause
      ShiftTab(thePID, 2)
      if (fastResetModExist(savesDirectory))
      {
         ShiftTab(thePID, 1)
      }
      Send, {enter} ; open to LAN
      ShiftTab(thePID, 1)
      Send, {enter} ; cheats on
      Send, `t
      Send, {enter} ; open to LAN
      WaitForHost(savesDirectory)
      Send, /
      Sleep, 70
      SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
      Send, {enter}
   }
   SetKeyDelay, 1
}

WaitForWorldList(previousErrorLevel)
{
   if (previousErrorLevel = 0)
   {
      WinGetPos, X, Y, W, H, Minecraft
      X1 := Floor(W / 2) - 1
      Y1 := Floor(H / 25)
      X2 := Ceil(W / 2) + 1
      Y2 := Ceil(H / 3)
      start := A_TickCount
      elapsed := A_TickCount - start
      PixelSearch, Px, Py, X1, Y1, X2, Y2, 0xADAFB7, 0, Fast
      while ((elapsed < worldListWait) && (ErrorLevel = 0))
      {
         PixelSearch, Px, Py, X1, Y1, X2, Y2, 0xADAFB7, 0, Fast
         elapsed := A_TickCount - start
      }
   }
   else
   {
      Sleep, worldListWait
   }
}

EnterSingleplayer(thePID)
{
   Sleep, %screenDelay%
   if ((inputMethod = "key") or (!WinActive("ahk_pid" thePID)))
   {
      SetKeyDelay, 0
      ControlSend, ahk_parent, `t, ahk_pid %thePID%
      WinGetPos, X, Y, W, H, Minecraft
      X1 := Floor(W / 2) - 1
      Y1 := Floor(H / 25)
      X2 := Ceil(W / 2) + 1
      Y2 := Ceil(H / 3)
      PixelSearch, Px, Py, X1, Y1, X2, Y2, 0xADAFB7, 0, Fast
      previousError := ErrorLevel
      ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
      SetKeyDelay, 1
   }
   else
   {
      WinGetPos, X, Y, W, H, Minecraft
      X1 := Floor(W / 2) - 1
      Y1 := Floor(H / 25)
      X2 := Ceil(W / 2) + 1
      Y2 := Ceil(H / 3)
      PixelSearch, Px, Py, X1, Y1, X2, Y2, 0xADAFB7, 0, Fast
      previousError := ErrorLevel
      if (GUIscale = 4)
         MouseClick, L, W * 963 // 1936, H * 515 // 1056, 1
      else
         MouseClick, L, W * 963 // 1936, H * 460 // 1056, 1
   }
   WaitForWorldList(previousError)
}

CreateWorld(thePID, savesDirectory)
{
   EnterSingleplayer(thePID)
   WorldListScreen(thePID)
   CreateNewWorldScreen(thePID, savesDirectory)
   if (mode = "SSG")
      MoreWorldOptionsScreen(thePID)
}

WorldListScreen(thePID)
{
   if ((inputMethod = "key") or (!WinActive("ahk_pid" thePID)))
   {
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}, ahk_pid %thePID%
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
      SetKeyDelay, 1
   }
   else
   {
      Sleep, %screenDelay%
      WinGetPos, X, Y, W, H, Minecraft
      if (GUIscale = 4)
         MouseClick, L, W * 1282 // 1936, H * 879 // 1056, 1
      else
         MouseClick, L, W * 1200 // 1936, H * 935 // 1056, 1
   }
}

CreateNewWorldScreen(thePID, savesDirectory)
{
   NameWorld(thePID)
   if ((inputMethod = "key") or (!WinActive("ahk_pid" thePID)))
   {
      SetKeyDelay, 0
      if (difficulty = "Normal")
      {
         ControlSend, ahk_parent, {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}, ahk_pid %thePID%
      }
      else
      {
         ControlSend, ahk_parent, `t, ahk_pid %thePID%
         if (difficulty = "Hardcore")
         {
            ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
         }
         ControlSend, ahk_parent, `t, ahk_pid %thePID%
         if (difficulty != "Hardcore")
         {
            ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
            if (difficulty != "Hard")
            {
               ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
               if (difficulty != "Peaceful")
               {
                  ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
               }
            }
         }
         if (difficulty != "Hardcore")
         {
            ControlSend, ahk_parent, {Tab}{Tab}, ahk_pid %thePID%
         }
         ControlSend, ahk_parent, {Tab}{Tab}, ahk_pid %thePID%
      }
      if (mode = "RSG")
         ControlSend, ahk_parent, {Tab}, ahk_pid %thePID%
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
      SetKeyDelay, 1
   }
   else
   {
      WinGetPos, X, Y, W, H, Minecraft
      if (difficulty = "Hardcore")
      {
         if (GUIscale = 4)
         {
            if (InFullscreen(savesDirectory))
               MouseClick, L, W * 653 // 1936, H * 450 // 1056, 1
            else
               MouseClick, L, W * 653 // 1936, H * 480 // 1056, 1
         }
         else
         {
            MouseClick, L, W * 735 // 1936, H * 350 // 1056, 1
         }
      }
      else if (difficulty != "Normal")
      {
         if (GUIscale = 4)
         {
            if (InFullscreen(savesDirectory))
               MouseClick, L, W * 1303 // 1936, H * 450 // 1056, 1
            else
               MouseClick, L, W * 1303 // 1936, H * 480 // 1056, 1
         }
         else
         {
            MouseClick, L, W * 1200 // 1936, H * 350 // 1056, 1
         }
         if (difficulty != "Hard")
         {
            if (GUIscale = 4)
            {
               if (InFullscreen(savesDirectory))
                  MouseClick, L, W * 1303 // 1936, H * 450 // 1056, 1
               else
                  MouseClick, L, W * 1303 // 1936, H * 480 // 1056, 1
            }
            else
            {
               MouseClick, L, W * 1200 // 1936, H * 350 // 1056, 1
            }
            if (difficulty != "Peaceful")
            {
               if (GUIscale = 4)
               {
                  if (InFullscreen(savesDirectory))
                     MouseClick, L, W * 1303 // 1936, H * 450 // 1056, 1
                  else
                     MouseClick, L, W * 1303 // 1936, H * 480 // 1056, 1
               }
               else
               {
                  MouseClick, L, W * 1200 // 1936, H * 350 // 1056, 1
               }
            }
         }
      }
      Sleep, %screenDelay%
      if (mode = "SSG")
      {
         if (GUIscale = 4)
         {
            if (InFullscreen(savesDirectory))
               MouseClick, L, W * 1295 // 1936, H * 780 // 1056, 1
            else
               MouseClick, L, W * 1295 // 1936, H * 830 // 1056, 1
         }
         else
         {
            MouseClick, L, W * 1200 // 1936, H * 600 // 1056, 1
         }
      }
      else
      {
         if (GUIscale = 4)
            MouseClick, L, W * 653 // 1936, H * 978 // 1056, 1
         else
            MouseClick, L, W * 725 // 1936, H * 1012 // 1056, 1
      }
   }
}

MoreWorldOptionsScreen(thePID)
{
   if ((inputMethod = "key") or (!WinActive("ahk_pid" thePID)))
   {
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}, ahk_pid %thePID%
      SetKeyDelay, 1
      Sleep, 1
      InputSeed(thePID)
      Sleep, 1
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}, ahk_pid %thePID%
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
      SetKeyDelay, 1
   }
   else
   {
      WinGetPos, X, Y, W, H, Minecraft
      if (GUIscale = 4)
         MouseClick, L, W * 963 // 1936, H * 310 // 1056, 1
      else
         MouseClick, L, W * 963 // 1936, H * 225 // 1056, 1
      InputSeed(thePID)
      Sleep, %screenDelay%
      if (GUIscale = 4)
         MouseClick, L, W * 653 // 1936, H * 978 // 1056, 1
      else
         MouseClick, L, W * 725 // 1936, H * 1012 // 1056, 1
   }
}

NameWorld(thePID)
{
   if (worldName != "New World")
   {
      if WinActive("ahk_pid" thePID)
      {
         SendInput, ^a
         Sleep, 1
         SendInput, %worldName%
         Sleep, 1
      }
      else
      {
         ControlSend, ahk_parent, {Control down}, ahk_pid %thePID%
         ControlSend, ahk_parent, a, ahk_pid %thePID%
         ControlSend, ahk_parent, {Control up}, ahk_pid %thePID%
         ControlSend, ahk_parent, {BackSpace}, ahk_pid %thePID%
         ControlSend, ahk_parent, %worldName%, ahk_pid %thePID%
      }
   }
   if (countAttempts = "Yes")
   {
      if (mode = "SSG")
         FileRead, WorldNumber, SSG_1_16.txt
      else
         FileRead, WorldNumber, RSG_1_16.txt
      if (ErrorLevel)
         WorldNumber = 0
      else
      {
         if (mode = "SSG")
            FileDelete, SSG_1_16.txt
         else
            FileDelete, RSG_1_16.txt
      }
      WorldNumber += 1
      if (mode = "SSG")
         FileAppend, %WorldNumber%, SSG_1_16.txt
      else
         FileAppend, %WorldNumber%, RSG_1_16.txt
      if WinActive("ahk_pid" thePID)
      {
         Sleep, 1
         SendInput, %WorldNumber%
         Sleep, 1
      }
      else
      {
         ControlSend, ahk_parent, %WorldNumber%, ahk_pid %thePID%
      }
   }
}

InputSeed(thePID)
{
   if WinActive("ahk_pid" thePID)
   {
      SendInput, %SEED%
   }
   else
   {
      ControlSend, ahk_parent, %SEED%, ahk_pid %thePID%
   }
}

ExitWorld(thePID, fromPause := false)
{
   if (!fromPause)
   {
      ShiftTab(thePID)
      ControlSend, ahk_parent, {Enter}, ahk_pid %thePID%
      ControlSend, ahk_parent, {Esc}, ahk_pid %thePID%
   }
   ShiftTab(thePID)
   ControlSend, ahk_parent, {Enter}, ahk_pid %thePID%
   
}

getMostRecentFile(savesDirectory)
{
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

DoEverything(thePID, savesDirectory, fromPause := false, switchInMiddle := false)
{
   WinGetTitle, Title, ahk_pid %thePID%
   if (InStr(Title, "player") or InStr(Title, "Instance"))
      ExitWorld(thePID, fromPause)
   if (InFullscreen(savesDirectory))
   {
      ControlSend, ahk_parent, {F11}, ahk_pid %thePID%
      Sleep, 50
   }
   if (switchInMiddle)
   {
      Switch(thePID)
   }
   startTime := A_TickCount
   confirmedExit := False
   lastWorld := getMostRecentFile(savesDirectory)
   lockFile := lastWorld . "\session.lock"
   Loop
   {
      FileRead, sessionlockfile, %lockFile%
      Sleep, 10
      if (ErrorLevel = 0)
      {
         Sleep, 50
         break
      }
      if (!confirmedExit && (A_TickCount > (startTime + 100)))
      {
         WinGetTitle, theTitle, ahk_pid %thePID%
         if (InStr(Title, "player") or InStr(Title, "Instance"))
            ControlSend, ahk_parent, {Enter}, ahk_pid %thePID%
         confirmedExit := True
      }
   }
   return (lastWorld)
}

DeleteOrMove(lastWorld, savesDirectory)
{
   array := StrSplit(lastWorld, "\saves\")
   justTheWorld := array[2]
   if (InStr(justTheWorld, "_") != 1)
   {
      if (previousWorldOption = "delete")
         FileRemoveDir, %lastWorld%, 1
      else if(previousWorldOption = "move")
      {
         newDir := StrReplace(savesDirectory, "saves", "oldWorlds")
         if !FileExist(newDir)
         {
            FileCreateDir, %newDir%
         }
         newLocation := StrReplace(lastWorld, "saves", "oldWorlds")
         FileCopyDir, %lastWorld%, %newLocation%%A_Now%
         FileRemoveDir, %lastWorld%, 1
      }
   }
}

InFullscreen(savesDirectory)
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, fullscreenLine, %optionsFile%, 17
   if (InStr(fullscreenLine, "true"))
      return 1
   else
      return 0
}

DoAReset(thePID, savesDirectory, removePrevious, fromPause := false, switchInMiddle := false)
{
   lastWorld := DoEverything(thePID, savesDirectory, fromPause, switchInMiddle)
   OutputDebug, reached title screen
   CreateWorld(thePID, savesDirectory)
   OutputDebug, created world
   if (removePrevious)
   {
      DeleteOrMove(lastWorld, savesDirectory)
      OutputDebug, removed previous world
   }
}

ResetAndSwitch(removePrevious := True)
{
   ;PIDFileCheck()
   savesDirectory := getSavesDirectory()
   OutputDebug, saves directory is %savesDirectory%
   WinGet, thePID, PID, A
   OutputDebug, thePID is %thePID%
   /*
   if (FastResetModExist(savesDirectory) or (numInstances = 1))
   {
      OutputDebug, fast reset mod exists or 1 instance only, first resetting then switching
      DoAReset(thePID, savesDirectory, removePrevious)
      OutputDebug, menuing done
      if (numInstances > 1)
      {
         OutputDebug, old pid: %thePID%
         thePID := PIDs[Switch(thePID)]
      }
   }
   else
   {
   */
      ;OutputDebug, fast reset mod does not exist, first switching then resetting
      DoAReset(thePID, savesDirectory, removePrevious, false, true)
      WinGet, thePID, PID, A
   ;}
   OutputDebug, new pid: %thePID%
   savesDirectory := getSavesDirectory()
   OutputDebug, new saves directory: %savesDirectory%
   worldLoadStuff(thePID, savesDirectory)
   OutputDebug, finished world load stuff
}

worldLoadStuff(thePID, savesDirectory)
{
   lastWorld := getMostRecentFile(savesDirectory)
   lockFile := lastWorld . "\session.lock"
   FileRead, sessionlockfile, %lockFile%
   if (ErrorLevel = 0)
      return
   if ((pauseOnLoad = "Yes") or (fullscreenOnLoad = "Yes"))
   {
      Loop
      {
         WinGetActiveTitle, Title
         if (InStr(Title, "player") or InStr(Title, "Instance"))
         {
            if ((InStr(previousTitle, "Minecraft")) && (!InStr(previousTitle, "player") && !InStr(previousTitle, "Instance")))
            {
               if (WinActive("Minecraft"))
               {
                  if (pauseOnLoad = "Yes")
                     Send, {Esc}
                  if ((fullscreenOnLoad = "Yes") && !(InFullscreen(savesDirectory)))
                     Send, {F11}
               }
            }
            break
         }
         Sleep, 20
         previousTitle := Title
      }
   }
}

getIGT(savesDirectory) ;unused
{
   currentWorld := getMostRecentFile(savesDirectory)
   statsFolder := currentWorld . "\stats"
   Loop, Files, %statsFolder%\*.*, F
   {
      statsFile := A_LoopFileLongPath
   }
   FileReadLine, fileText, %statsFile%, 1
   if (version = 17)
   {
      statLocation := InStr(fileText, "play_time")
   }
   else
   {
      statLocation := InStr(fileText, "play_one_minute")
   }
   cutOutPrevious := SubStr(fileText, statLocation)
   statArray := StrSplit(cutOutPrevious, ",")
   theStat := statArray[1]
   justTheTwo := StrSplit(theStat, ":")
   justTheNumber := justTheTwo[2]
   OutputDebug, IGT is %justTheNumber% ticks
   return (justTheNumber)
}

Switch(thePID)
{
   Loop, %numInstances%
   {
      if (thePID = PIDs[A_Index])
      {
         currentInstanceNum := A_Index
      }
   }
   newInstanceNum := currentInstanceNum + 1
   if (currentInstanceNum = numInstances)
   {
      newInstanceNum := 1
   }
   OutputDebug, %newInstanceNum%
   SwitchTo(newInstanceNum)
   if (unpauseOnSwitch = "Yes")
   {
      Send, {Esc}
   }
   return (newInstanceNum)
}

SwitchTo(instanceNum)
{
   WinActivate, OBS
   thePID := PIDs[instanceNum]
   WinActivate, ahk_pid %thePID%
}

DeletePIDsFile()
{
   FileSetAttrib, -R, PIDs.txt
   FileDelete, PIDs.txt
   if (FileExist("PIDs.txt"))
      OutputDebug, file still not deleted for some reason
}

global GUIscale
getGUIscale(savesDirectory) ;used on script startup
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   if (version = 16)
      FileReadLine, guiScaleLine, %optionsFile%, 26
   else
      FileReadLine, guiScaleLine, %optionsFile%, 29
   if (InStr(guiScaleLine, 4) or InStr(guiScaleLine, 0))
   {
      GUIscale := 4
      return 4
   }
   else if (InStr(guiScaleLine, 3))
   {
      GUIscale := 3
      return 3
   }
   else
      return 0
}

global version = getVersion()
OutputDebug, we are on 1.%version%
getVersion()
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, versionLine, %optionsFile%, 1
   arr := StrSplit(versionLine, ":")
   dataVersion := arr[2]
   if (dataVersion > 2600)
      return (17)
   else
      return (16)
}

BackgroundReset(n)
{
   resetAboutToHappen[n] := True
   ;PIDFileCheck()
   thePID := PIDs[n]
   savesDirectory := savesDirectories[n]
   if (!WinActive("ahk_pid" thePID))
   {
      DoAReset(thePID, savesDirectory, true, true)
   }
   resetAboutToHappen[n] := False
}

getPID(n)
{
   MsgBox, Close this message, click on Instance %n%, and press the F key after you have clicked on that instance.
   Loop
   {
      if GetKeyState("F", "P")
      {
         WinGetActiveTitle, title
         if (InStr(title, "Minecraft"))
         {
            WinGet, thePID, PID, A
            if (n > 1)
            {
               m := n - 1
               Loop, %m%
               {
                  PIDcheck := PIDs[A_Index]
                  if (PIDcheck = thePID)
                  {
                     MsgBox, You clicked on the same window for Instance %n% as you did for Instance %A_Index%. Close this message to start over.
                     Reload
                  }
               }
            }
            FileAppend, %thePID%`n, PIDs.txt
            PIDs.Push(thePID)
            OutputDebug, wrote PID number %thePID% to the file and appended it to the array.
            return (thePID)
         }
         else
            MsgBox, This is not a Minecraft window. Close this message, click on Instance %n%, and press the P key after you have clicked on that instance.
      }
   }
}

PIDFileCheck()
{
   lineCounter = 0
   willNeedToSetUpPIDs := False
   Loop, Read, PIDs.txt
   {
      lineCounter += 1
      OutputDebug, the PID it read is %A_LoopReadLine%
      WinGetTitle, Title, ahk_pid %A_LoopReadLine%
      if (!InStr(Title, "Minecraft"))
      {
         OutputDebug, PID not found
         willNeedToSetUpPIDs := True
      }
      else
      {
         PIDs.push(A_LoopReadLine)
         thePID := PIDs[lineCounter]
         OutputDebug, PID number %thePID% was found
      }
   }
   if (lineCounter != numInstances)
   {
      OutputDebug, line counter is %lineCounter%
      OutputDebug, number of instances is %numInstances%
      willNeedToSetUpPIDs := True
   }
   if (willNeedToSetUpPIDs)
   {
      OutputDebug, setting up PIDs
      PIDs := []
      SetupPIDs()
   }
   else
      OutputDebug, all PIDs are good and everything and all that
}

SetupPIDs()
{
   if (FileExist("PIDs.txt"))
   {
      OutputDebug, the file exists
      DeletePIDsFile()
   }
   Loop, %numInstances%
   {
      getPID(A_Index)
   }
   if (numInstances > 1)
   {
      MsgBox, Close this message and you're good to go.
   }
}

global numInstances = savesDirectories.MaxIndex()
OutputDebug, %numInstances% instances being used

Loop, %numInstances%
{
   if ((!FileExist(savesDirectories[A_Index])) or (!InStr(savesDirectories[A_Index], "\saves")))
   {
      MsgBox, Your saves directory for instance %A_Index% is invalid. Right click on the script file, click edit script, and put the correct saves directory, then save the script and run it again.
      ExitApp
   }
}
if ((previousWorldOption != "move") and (previousWorldOption != "delete"))
{
   MsgBox, Choose a valid option for what to do with the previous world. Go to the Options section of this script and choose either "move" or "delete" after the words "global previousWorldOption := "
   ExitApp
}
if ((difficulty != "Peaceful") and (difficulty != "Easy") and (difficulty != "Normal") and (difficulty != "Hard") and (difficulty != "Hardcore"))
{
   MsgBox, Difficulty entered is invalid. Please check your spelling and enter a valid difficulty. Options are "Peaceful" "Easy" "Normal" "Hard" or "Hardcore"
   ExitApp
}
if ((inputMethod != "key") and (inputMethod != "click"))
{
   MsgBox, Choose a valid option for what input method to use. Go to the Options section of this script and choose either "key" or "click" after the words "global inputMethod := "
   ExitApp
}
if ((!getGUIscale(savesDirectories[1])) && (inputMethod != "key"))
{
   MsgBox, Your GUI scale is not supported with the click macro. Either change your GUI scale to 0, 3, or 4, or change the input method to "key". Then run the script again.
   ExitApp
}
if ((pauseOnLoad != "Yes") and (pauseOnLoad != "No"))
{
   MsgBox, Choose a valid option for whether or not to pause on world load. Go to the Options section of this script and choose either "Yes" or "No" after the words "global pauseOnLoad := "
   ExitApp
}
if ((fullscreenOnLoad != "Yes") and (fullscreenOnLoad != "No"))
{
   MsgBox, Choose a valid option for whether or not to fullscreen Minecraft when the load is complete. Go to the Options section of this script and choose either "Yes" or "No" after the words "global fullscreenOnLoad := "
   ExitApp
}
if ((unpauseOnSwitch != "Yes") and (unpauseOnSwitch != "No"))
{
   MsgBox, Choose a valid option for whether or not to unpause on instance switch. Go to the Options section of this script and choose either "Yes" or "No" after the words "global unpauseOnSwitch := "
   ExitApp
}
if ((mode != "SSG") and (mode != "RSG"))
{
   MsgBox, Choose a valid option for playing SSG or RSG. Go to the Options section of this script and choose either "SSG" or "RSG" after the words "global mode := "
   ExitApp
}

Test()
{
   
}

SetDefaultMouseSpeed, 0
SetMouseDelay, 0
SetKeyDelay , 1
SetWinDelay, 1
global PIDs := [] ;GetAllPIDs()
global resetQueue := []
for i, thePID in PIDs
{
   OutputDebug, PID number %i% is %thePID%
}
PIDFileCheck()
global resetAboutToHappen := []
Loop, %numInstances%
{
   resetAboutToHappen.Push(False)
}
/*
#Persistent
   SetTimer, CheckChanged, 250
return

CheckChanged:
   for i, thePID in PIDs
   {
      if (!WinActive("ahk_pid" thePID))
      {
         WinGetTitle, title, ahk_pid %thePID%
         if (InStr(Title, "player") or InStr(Title, "Instance"))
         {
            resetHappening := resetAboutToHappen[i]
            if (!resetHappening)
            {
               savesDirectory := savesDirectories[i]
               logFile := StrReplace(savesDirectory, "saves", "logs\latest.log")
               numLines := 0
               Loop, Read, %logFile%
               {
                  numLines += 1
               }
               lastSave := false
               startTime := A_TickCount
               while (!lastSave)
               {
                  if ((A_TickCount - startTime) > 5000)
                  {
                     OutputDebug, last save thing timed out
                     lastSave := True
                  }
                  Loop, Read, %logFile%
                  {
                     if ((A_TickCount - startTime) > 5000)
                     {
                        OutputDebug, last save thing timed out
                        lastSave := True
                     }
                     if ((numLines - A_Index) < 2)
                     {
                        if ((InStr(A_LoopReadLine, "Saving chunks for level 'ServerLevel")) and (InStr(A_LoopReadLine, "minecraft:the_end")))
                        {
                           OutputDebug, found the saving chunks for the end thing
                           lastSave := True
                        }
                     }
                  }
               }
               OutputDebug, instance %i% needs suspending
            }
         }
      }
   }
return
*/
#IfWinActive, Minecraft
{
F5::Reload ; Reload keybind

PgUp:: ; Reset keybind that doesn't remove previous world
   ResetAndSwitch(false)
return

PgDn:: ; Reset keybind.
   ResetAndSwitch()
return

End:: ; This is where the keybind for opening to LAN and perching is set.
   Perch()
return

NumPad1::
   BackgroundReset(1)
return

NumPad2::
   BackgroundReset(2)
return

NumPad3::
   BackgroundReset(3)
return

NumPad4::
   BackgroundReset(4)
return

;continue this pattern above if you have more instances

Home:: ; reset all inactive instances
   Loop, %numInstances%
   {
      BackgroundReset(A_Index)
   }
return

Insert::
   Test()
return
}