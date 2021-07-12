; Minecraft Reset Script (set seed 1.16)
; Author:  Peej, with help/code from jojoe77777, onvo, SLTRR, DesktopFolder, Four, and _D4rkS0ul_
; Authors are not liable for any run rejections.
; To use this script, make sure you have autohotkey installed (autohotkey.com), then right click on the script file, and click "Run Script."
; If you make any changes to the script by right clicking and clicking "Edit Script," make sure to reload the script by pressing F5 or by right clicking on the logo in your taskbar and clicking "Reload Script."

; Script Function / Help:
;  The following only apply inside the Minecraft window:
;   1) When on the title screen, the "PgUp" key will create a world with the desired seed.
;   2) When in a previous world, "PgUp" will exit the world and then auto create another world.
;   3) "PgDn" will do the same thing as "PgUp," but it will also delete the previous world (or move it to another folder if you have that option selected).
;   4) To just exit the world and not create another world, press "Home" on keyboard.
;   5) To open to LAN and make the dragon perch (make sure you're not in an inventory or already paused), press "End"
;   6) To change the "PgDn" and "PgUp" and "Home" and "End," scroll down to the bottom of this script, change the character before the double colon "::", and reload the script.
;      https://www.autohotkey.com/docs/KeyList.htm Here are a list of the keys you can use.
;   7) If you want to use a different seed, change the difficulty, or change the world name, scroll down to the Options and you can change those.
;   8) If you are in a minecraft world and inside an inventory, close that inventory before activating the script (otherwise, the macro will not function properly).
;      The macro that creates a new world only works from the title screen, from a previous world paused, or from a previous world unpaused.

; Troubleshooting:
;   Q: Why is it creating a random seed?
;   A: Menu lag, try increasing your screenDelay.
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
 
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; Options:
global savesDirectory := "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.17\.minecraft\saves" ; input your minecraft saves directory here. It will probably start with "C:\Users..." and end with "\minecraft\saves"
global screenDelay := 70 ; Change this value to increase/decrease the number of time (in milliseconds) that each world creation screen is held for. For your run to be verifiable, each of the three screens of world creation must be shown.
global worldListWait := 1000 ; The macro will wait for the world list screen to show before proceeding, but sometimes this feature doesn't work, especially if you use fullscreen, and always if you're tabbed out during this part.
                            ; In that case, this number (in milliseconds) defines the hard limit that it will wait after clicking on "Singleplayer" before proceeding.
                            ; This number should basically just be a little longer than your world list screen showing lag.

global difficulty := "Normal" ; Set difficulty here. Options: "Peaceful" "Easy" "Normal" "Hard" "Hardcore"
global SEED := "-3294725893620991126" ; Default seed is the current Any% SSG 1.16+ seed, you can change it to whatever seed you want.

global countAttempts := "No" ; Change this to "Yes" if you would like the world name to include the attempt number, otherwise, keep it as "No"
                             ; The script will automatically create a text file to track your attempts starting from 1, but if you already have some attempts,
                             ; you can make a file called SSG_1_16.txt and put the number your attempts there. You can change that file whenever you want if the number ever gets messed up.
global worldName := "New World" ; you can name the world whatever you want, put the name inside the quotation marks.
                                ; If you selected "Yes" in the above option to counting attempts, this name will be the prefix.
                                ; For example, if you leave this as "New World" and you're on attempt 343, then the world will be named "New World343"
                                ; To just show the attempt number, change this variable to ""

global previousWorldOption := "move" ; What to do with the previous world (either "delete" or "move") when the Page Down hotkey is used. If it says "move" then worlds will be moved to a folder called oldWorlds in your .minecraft folder

global inputMethod := "key" ; either "click" or "key" (click is theoretically faster but kinda experimental at this point and may not work properly depending on your resolution)
global windowedReset := "No" ; change this to "Yes" if you would like to ensure that you are in windowed mode during resets (in other words, it will press f11 every time you reset if you are in fullscreen)
global pauseOnLoad := "Yes" ; change this to "No" if you would like the macro to not automatically pause when the world loads in (this is automatically enabled if you're using the autoresetter)
global activateMCOnLoad := "Yes" ; change this to "No" if you would not like the macro to pull up Minecraft when the world is ready (or when spawn is ready when autoresetter is enabled)
global fullscreenOnLoad = "No" ; change this to "Yes" if you would like the macro ensure that you are in fullscreen mode when the world is ready (the world will be activated to ensure that no recording is lost)
global f3pWarning := "enabled" ; change this to "disabled" once you've seen the warning
global trackFlint := "Yes" ; track flint rates (to make sure that it's not counting gravel from non-run worlds, it will only count it if you run it from a previous world)
                           ; Each run will be logged in a file called SSGstats.csv, and cumulative stats will be stored in a file called SSGstats.txt

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
;      Make sure you're on the exact coordinate that you want to be blacklisted (down to the hundredth of a block), since it will blacklist your current location, not your spawn.
;   7) Because of this feature, I recommend starting out with a higher radius than you would need, then just add bad spawns to the blacklist.

; Autoresetter Options:
global doAutoResets := "No" ; "Yes" or "No" for whether or not to run the autoresetter based on spawns
; The autoresetter will automatically reset if your spawn is greater than a certain number of blocks away from a certain point (ignoring y)
global centerPointX := 162.7 ; this is the x coordinate of that certain point (by default it's the x coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global centerPointZ := 194.5 ; this is the z coordinate of that certain point (by default it's the z coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global radius := 13 ; if this is 10 for example, the autoresetter will not reset if you are within 10 blocks of the point specified above. Set this smaller for better spawns but more resets
; if you would only like to reset the blacklisted spawns, then just set this number really large (1000 should be good enough), and if you would only like to play out whitelisted spawns, then just make this number negative
global message := "" ; what message will pop up when a good spawn is found (if you don't want a message to pop up, change this to "")
global playSound := "No" ; "Yes" or "No" on whether or not to play that Windows sound when good seed is found. To play a custom sound, just save it as spawnready.mp3 in the same folder as this script.

fastResetModStuff()
{
   modsFolder := StrReplace(savesDirectory, "saves", "mods")
   Loop, Files, %modsFolder%\*.*, F
   {
      if(InStr(A_LoopFileName, "fast-reset"))
      {
         ShiftTab(1)
         break
      }
   }
}

ShiftTab(n)
{
   if WinActive("Minecraft")
   {
      Loop, %n%
      {
         Send, +`t
      }
   }
   else
   {
      ControlSend, ahk_parent, {Shift down}, ahk_exe javaw.exe
      Loop, %n%
      {
         ControlSend, ahk_parent, {Tab}, ahk_exe javaw.exe
      }
      ControlSend, ahk_parent, {Shift up}, ahk_exe javaw.exe
   }
}

WaitForHost()
{
   logFile := StrReplace(savesDirectory, "saves", "logs\latest.log")
   numLines := 0
   Loop, Read, %logFile%
   {
      numLines += 1
   }
   openedToLAN := False
   while (!openedToLAN)
   {
      OutputDebug, reading log file
      Loop, Read, %logFile%
      {
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

Perch()
{
   if (version = 17)
   {
      Send, {Esc} ; pause
      ShiftTab(2)
      fastResetModStuff()
      Send, {enter} ; open to LAN
      Send, {tab}{tab}{enter} ; cheats on
      Send, `t
      Send, {enter} ; open to LAN
      WaitForHost()
      Send, /
      Sleep, 70
      SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
      Send, {enter}
   }
   else
   {
      Send, {Esc} ; pause
      ShiftTab(2)
      fastResetModStuff()
      Send, {enter} ; open to LAN
      ShiftTab(1)
      Send, {enter} ; cheats on
      Send, `t
      Send, {enter} ; open to LAN
      WaitForHost()
      Send, /
      Sleep, 70
      SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
      Send, {enter}
   }
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

EnterSingleplayer()
{
   Sleep, %screenDelay%
   if ((inputMethod = "key") or (!WinActive("Minecraft")))
   {
      SetKeyDelay, 0
      ControlSend, ahk_parent, `t
      WinGetPos, X, Y, W, H, Minecraft
      X1 := Floor(W / 2) - 1
      Y1 := Floor(H / 25)
      X2 := Ceil(W / 2) + 1
      Y2 := Ceil(H / 3)
      PixelSearch, Px, Py, X1, Y1, X2, Y2, 0xADAFB7, 0, Fast
      previousError := ErrorLevel
      ControlSend, ahk_parent, {enter}
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

CreateWorld()
{
   EnterSingleplayer()
   WorldListScreen()
   CreateNewWorldScreen()
   MoreWorldOptionsScreen()
}

WorldListScreen()
{
   if ((inputMethod = "key") or (!WinActive("Minecraft")))
   {
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}
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

CreateNewWorldScreen()
{
   NameWorld()
   if ((inputMethod = "key") or (!WinActive("Minecraft")))
   {
      SetKeyDelay, 0
      if (difficulty = "Normal")
      {
         ControlSend, ahk_parent, {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}
      }
      else
      {
         ControlSend, ahk_parent, `t
         if (difficulty = "Hardcore")
         {
            ControlSend, ahk_parent, {enter}
         }
         ControlSend, ahk_parent, `t
         if (difficulty != "Hardcore")
         {
            ControlSend, ahk_parent, {enter}
            if (difficulty != "Hard")
            {
               ControlSend, ahk_parent, {enter}
               if (difficulty != "Peaceful")
               {
                  ControlSend, ahk_parent, {enter}
               }
            }
         }
         if (difficulty != "Hardcore")
         {
            ControlSend, ahk_parent, {Tab}{Tab}
         }
         ControlSend, ahk_parent, {Tab}{Tab}
      }
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}
      SetKeyDelay, 1
   }
   else
   {
      WinGetPos, X, Y, W, H, Minecraft
      if (difficulty = "Hardcore")
      {
         if (GUIscale = 4)
         {
            if (InFullscreen())
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
            if (InFullscreen())
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
               if (InFullscreen())
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
                  if (InFullscreen())
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
      if (GUIscale = 4)
      {
         if (InFullscreen())
            MouseClick, L, W * 1295 // 1936, H * 780 // 1056, 1
         else
            MouseClick, L, W * 1295 // 1936, H * 830 // 1056, 1
      }
      else
      {
         MouseClick, L, W * 1200 // 1936, H * 600 // 1056, 1
      }
   }
}

MoreWorldOptionsScreen()
{
   if ((inputMethod = "key") or (!WinActive("Minecraft")))
   {
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}
      SetKeyDelay, 1
      Sleep, 1
      InputSeed()
      Sleep, 1
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}
      SetKeyDelay, 1
   }
   else
   {
      WinGetPos, X, Y, W, H, Minecraft
      if (GUIscale = 4)
         MouseClick, L, W * 963 // 1936, H * 310 // 1056, 1
      else
         MouseClick, L, W * 963 // 1936, H * 225 // 1056, 1
      InputSeed()
      Sleep, %screenDelay%
      if (GUIscale = 4)
         MouseClick, L, W * 653 // 1936, H * 978 // 1056, 1
      else
         MouseClick, L, W * 725 // 1936, H * 1012 // 1056, 1
   }
}

PossiblyPause()
{
   Sleep, 2000
   if ((pauseOnLoad = "Yes") or (doAutoResets = "Yes") or (activateMCOnLoad = "Yes") or (fullscreenOnLoad = "Yes"))
   {
      Loop
      {
         WinGetTitle, Title, ahk_exe javaw.exe
         if (InStr(Title, "player") or InStr(Title, "Instance"))
         {
            if ((InStr(previousTitle, "Minecraft")) && (!InStr(previousTitle, "player") && !InStr(previousTitle, "Instance")))
            {
               if (doAutoResets = "Yes")
               {
                  Sleep, 20
                  /*
                  oldClipboard := Clipboard
                  ControlSend, ahk_parent, {F3 Down}cd{F3 Up}
                  */
                  ControlSend, ahk_parent, {Esc}
               }
               else
               {
                  if (pauseOnLoad = "Yes")
                     ControlSend, ahk_parent, {Esc}
                  if ((activateMCOnLoad = "Yes") or (fullscreenOnLoad = "Yes"))
                     WinActivate, ahk_exe javaw.exe
                  if ((fullscreenOnLoad = "Yes") && !(InFullscreen()))
                     ControlSend, ahk_parent, {F11}
               }
            }
            break
         }
         Sleep, 50
         previousTitle := Title
      }
      
   }
}

NameWorld()
{
   if (worldName != "New World")
   {
      if WinActive("Minecraft")
      {
         SendInput, ^a
         Sleep, 1
         SendInput, %worldName%
         Sleep, 1
      }
      else
      {
         ControlSend, ahk_parent, {Control down}
         ControlSend, ahk_parent, a
         ControlSend, ahk_parent, {Control up}
         ControlSend, ahk_parent, {BackSpace}
         ControlSend, ahk_parent, %worldName%
      }
   }
   if (countAttempts = "Yes")
   {
      FileRead, WorldNumber, SSG_1_16.txt
      if (ErrorLevel)
         WorldNumber = 0
      else
         FileDelete, SSG_1_16.txt
      WorldNumber += 1
      FileAppend, %WorldNumber%, SSG_1_16.txt
      if WinActive("Minecraft")
      {
         Sleep, 1
         SendInput, %WorldNumber%
         Sleep, 1
      }
      else
      {
         ControlSend, ahk_parent, %WorldNumber%
      }
   }
}

InputSeed()
{
   if WinActive("Minecraft")
   {
      SendInput, %SEED%
   }
   else
   {
      ControlSend, ahk_parent, %SEED%
   }
}

ExitWorld(manualReset := True)
{
   if (manualReset)
   {
      ShiftTab(1)
      ControlSend, ahk_parent, {Enter}
      ControlSend, ahk_parent, {Esc}
      ;ChangeRD()
   }
   Sleep, 10
   ShiftTab(1)
   ControlSend, ahk_parent, {Enter}
}

getMostRecentFile()
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

DoEverything(manualReset := True)
{
   WinGetTitle, Title, ahk_exe javaw.exe
   getFlintStuff := False
   if (InStr(Title, "player") or InStr(Title, "Instance"))
   {
      ExitWorld(manualReset)
      getFlintStuff := True
   }
   if (InFullscreen() && ((windowedReset = "Yes")))
   {
      ControlSend, ahk_parent, {F11}
      Sleep, 50
   }
   startTime := A_TickCount
   confirmedExit := False
   lastWorld := getMostRecentFile()
   lockFile := lastWorld . "\session.lock"
   Loop
   {
      FileRead, sessionlockfile, %lockFile%
      Sleep, 10
      if (ErrorLevel = 0)
      {
         if ((trackFlint = "Yes") && getFlintStuff)
            TrackFlint()
         Sleep, 50
         break
      }
      if (!confirmedExit && (A_TickCount > (startTime + 100)))
      {
         WinGetTitle, theTitle, ahk_exe javaw.exe
         if (InStr(Title, "player") or InStr(Title, "Instance"))
            ControlSend, ahk_parent, {Enter}
         confirmedExit := True
      }
   }
   return (lastWorld)
}

DeleteOrMove(lastWorld)
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

InFullscreen()
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, fullscreenLine, %optionsFile%, 17
   if (InStr(fullscreenLine, "true"))
      return 1
   else
      return 0
}

global version = getVersion()
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


PauseOnLostFocus() ;used on script startup
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   if (version = 16)
      FileReadLine, optionLine, %optionsFile%, 45
   else
      FileReadLine, optionLine, %optionsFile%, 48
   if (InStr(optionLine, "true"))
      return 1
   else
      return 0
}

global GUIscale
getGUIscale() ;used on script startup
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

getIGT() ;unused
{
   currentWorld := getMostRecentFile()
   statsFolder := currentWorld . "\stats"
   Loop, Files, %statsFolder%\*.*, F
   {
      statsFile := A_LoopFileLongPath
   }
   FileReadLine, fileText, %statsFile%, 1
   statLocation := InStr(fileText, "play_one_minute")
   cutOutPrevious := SubStr(fileText, statLocation)
   statArray := StrSplit(cutOutPrevious, ",")
   theStat := statArray[1]
   justTheTwo := StrSplit(theStat, ":")
   justTheNumber := justTheTwo[2]
   return (justTheNumber)
}

isPaused() ;unused
{
   oldIGT := getIGT()
   ControlSend, ahk_parent, {Esc}
   Sleep, 50
   newIGT := getIGT()
   ;MsgBox, %oldIGT% %newIGT%
   if (newIGT = oldIGT)
   {
      return (0)
   }
   else
   {
      return (1)
   }
}

DoAReset(removePrevious := True, manualReset := True)
{
   lastWorld := DoEverything(manualReset)
   OutputDebug, reached title screen
   CreateWorld()
   if (removePrevious)
      DeleteOrMove(lastWorld)
   UpdateStats()
   PossiblyPause()
}

DoSomeResets(removePrevious := True)
{
   counter := 0
   Loop
   {
      if (counter = 0)
      {
         DoAReset(removePrevious)
         if (doAutoResets = "No")
            break
      }
      else
      {
         OutputDebug, resetting bad spawn
         DoAReset(True, False)
      }
      ;WaitForClipboardUpdate()
      if (goodSpawn())
      {
         AlertUser()
         break
      }
      OutputDebug, bad spawn
      ;WaitForLoadIn()
      counter += 1
   }
}
/*
WaitForClipboardUpdate()
{
   startTime = A_TickCount
   Loop
   {
      if ((A_TickCount - clipboardLoadTime) > startTime)
         break
      if (Clipboard != oldClipboard)
         break
      Sleep, 10
   }
}
*/

WaitForLoadIn()
{
   logFile := StrReplace(savesDirectory, "saves", "logs\latest.log")
   numLines := 0
   Loop, Read, %logFile%
   {
      numLines += 1
   }
   exitLoop := false
   startTime := A_TickCount
   while (!exitLoop)
   {
      OutputDebug, reading log file
      Loop, Read, %logFile%
      {
         if ((numLines - A_Index) < 10)
         {
            OutputDebug, %A_LoopReadLine%
            if ((InStr(A_LoopReadLine, "Saving chunks for level 'ServerLevel")) and (InStr(A_LoopReadLine, "minecraft:the_end")))
            {
               OutputDebug, found the saving chunks for the end thing
               exitLoop := True
            }
         }
      }
   }
}

getSpawnPoint()
{
   logFile := StrReplace(savesDirectory, "saves", "logs\latest.log")
   numLines := 0
   Loop, Read, %logFile%
   {
      numLines += 1
   }
   Loop, Read, %logFile%
   {
      if ((numLines - A_Index) <= 15)
      {
         OutputDebug, %A_LoopReadLine%
         if (InStr(A_LoopReadLine, "logged in with entity id"))
         {
            OutputDebug, found the needed line
            spawnLine := A_LoopReadLine
         }
      }
   }
   array1 := StrSplit(spawnLine, " at (")
   xyz := array1[2]
   array2 := StrSplit(xyz, ", ")
   xCoord := array2[1]
   zCooord := array2[3]
   array3 := StrSplit(zCooord, ")")
   zCoord := array3[1]
   return ([xCoord, zCoord])
}

goodSpawn()
{
   /*
   array1 := StrSplit(Clipboard, " ")
   xCoord := array1[7]
   zCoord := array1[9]
   */
   coords := getSpawnPoint()
   xCoord := coords[1]
   zCoord := coords[2]
   Loop, 2
   {
      currentSpawn[A_Index] := coords[A_Index]
   }
   OutputDebug, spawn is %xCoord%, %zCoord%
   if (inList(xCoord, zCoord, "whitelist.txt"))
   {
      OutputDebug, in whitelist
      return True
   }
   if (inList(xCoord, zCoord, "blacklist.txt"))
   {
      OutputDebug, in blacklist
      return False
   }
   xDisplacement := xCoord - centerPointX
   zDisplacement := zCoord - centerPointZ
   distance := Sqrt((xDisplacement * xDisplacement) + (zDisplacement * zDisplacement))
   OutputDebug, distance of %distance%
   if (distance <= radius)
      return True
   else
      return False
}

AddToBlacklist()
{
   xCoord := currentSpawn[1]
   zCoord := currentSpawn[2]
   OutputDebug, blacklisting %xCoord%, %zCoord%
   theString := xCoord . "," . zCoord . ";" . xCoord . "," . zCoord
   if (!FileExist("blacklist.txt"))
      FileAppend, %theString%, blacklist.txt
   else
      FileAppend, `n%theString%, blacklist.txt
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

AlertUser()
{
   if (playSound = "Yes")
   {
      if (FileExist("spawnready.mp3"))
         SoundPlay, spawnready.mp3
      else
         SoundPlay *16
   }
   if ((activateMCOnLoad = "Yes") or (fullscreenOnLoad = "Yes"))
      WinActivate, ahk_exe javaw.exe
   if (message != "")
      MsgBox, %message%
   if ((fullscreenOnLoad = "Yes") && !(InFullscreen()))
      ControlSend, ahk_parent, {F11}
}

TrackFlint()
{
   headers := "Time that run ended, Flint obtained, Gravel mined"
   if (!FileExist("SSGstats.csv"))
   {
      FileAppend, %headers%, SSGstats.csv
   }
   numbersArray := gravelDrops()
   flintDropped := numbersArray[1]
   gravelMined := numbersArray[2]
   theTime := readableTime()
   numbers := theTime . "," . flintDropped . "," . gravelMined
   FileAppend, `n, SSGstats.csv
   FileAppend, %numbers%, SSGstats.csv
}

gravelDrops()
{
   currentWorld := getMostRecentFile()
   statsFolder := currentWorld . "\stats"
   Loop, Files, %statsFolder%\*.*, F
   {
      statsFile := A_LoopFileLongPath
   }
   FileReadLine, fileText, %statsFile%, 1
   
   minedLocation := InStr(fileText, "minecraft:mined")
   if (minedLocation)
   {
      gravelLocation := InStr(fileText, "minecraft:gravel", , minedLocation)
      if (gravelLocation)
      {
         postMined := SubStr(fileText, gravelLocation)
         gravelArray1 := StrSplit(postMined, ":")
         gravelSubString := gravelArray1[3]
         gravelArray2 := StrSplit(gravelSubString, "}")
         gravelSubString2 := gravelArray2[1]
         gravelArray3 := StrSplit(gravelSubString2, ",")
         gravelMined := gravelArray3[1]
      }
      else
         gravelMined := 0
   }
   else
      gravelMined := 0
   
   pickedupLocation := Instr(fileText, "minecraft:picked_up")
   if (pickedupLocation)
   {
      flintLocation := InStr(fileText, "minecraft:flint", , pickedupLocation)
      if (flintLocation)
      {
         postPickedup := SubStr(fileText, flintLocation)
         flintArray1 := StrSplit(postPickedup, ":")
         flintSubString := flintArray1[3]
         flintArray2 := StrSplit(flintSubString, "}")
         flintSubString2 := flintArray2[1]
         flintArray3 := StrSplit(flintSubString2, ",")
         flintCollected := flintArray3[1]
      }
      else
         flintCollected := 0
   }
   else
      flintCollected := 0
   
   return ([flintCollected, gravelMined])
}

readableTime()
{
   theTime := A_Now
   year := theTime // 10000000000
   month := mod(theTime, 10000000000)
   month := month // 100000000
   day := mod(theTime, 100000000)
   day := day // 1000000
   hour := mod(theTime, 1000000)
   hour := hour // 10000
   minute := mod(theTime, 10000)
   minute := minute // 100
   second := mod(theTime, 100)
   if (second < 10)
      second := "0" . second
   if (minute < 10)
      minute := "0" . minute
   if (hour < 10)
      hour := "0" . hour
   if (day < 10)
      day := "0" . day
   if (month < 10)
      month := "0" . month
   timeString := month . "/" . day . "/" . year . " " . hour . ":" . minute . ":" second
   return (timeString)
}

UpdateStats()
{
   if (FileExist("SSGstats.csv"))
   {
      FileDelete, SSGstats.txt
      headerRead := false
      totalFlint := 0
      totalGravel := 0
      totalAttempts := 0
      todayFlint := 0
      todayGravel := 0
      todayAttempts := 0
      Loop, read, SSGstats.csv
      {
         if (headerRead)
         {
            theArray := StrSplit(A_LoopReadLine, ",")
            totalFlint += theArray[2]
            totalGravel += theArray[3]
            totalAttempts += 1
            currentDate := A_Now // 1000000
            readTime := theArray[1]
            dateTimeArray := StrSplit(readTime, " ")
            rowDate := dateTimeArray[1]
            dateArray := StrSplit(rowDate, "/")
            theMonth := dateArray[1]
            theDay := dateArray[2]
            theYear := dateArray[3]
            readDate := theYear . theMonth . theDay
            if (readDate = currentDate)
            {
               todayFlint += theArray[2]
               todayGravel += theArray[3]
               todayAttempts += 1
            }
         }
         headerRead := true
      }
      flintRate := 100 * totalFlint / totalGravel
      dailyFlintRate := 100 * todayFlint / todayGravel
      theString := totalAttempts . " attempts tracked" . "`n" . totalFlint . " flint drops out of " . totalGravel . " gravel mined for a rate of " flintRate . " percent" . "`n`n" . todayAttempts . " attempts tracked today" . "`n" . todayFlint . " flint drops out of " . todayGravel . " gravel mined for a rate of " dailyFlintRate . " percent"
      FileAppend, %theString%, SSGstats.txt
   }
}

Test()
{
   
}

if ((!FileExist(savesDirectory)) or (!InStr(savesDirectory, "\saves")))
{
   MsgBox, Your saves directory is invalid. Right click on the script file, click edit script, and put the correct saves directory, then save the script and run it again.
   ExitApp
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
if ((windowedReset != "Yes") and (windowedReset != "No"))
{
   MsgBox, Choose a valid option for whether or not to do windowed resets. Go to the Options section of this script and choose either "Yes" or "No" after the words "global windowedReset := "
   ExitApp
}
if ((pauseOnLoad != "Yes") and (pauseOnLoad != "No"))
{
   MsgBox, Choose a valid option for whether or not to pause on world load. Go to the Options section of this script and choose either "Yes" or "No" after the words "global pauseOnLoad := "
   ExitApp
}
if ((!getGUIscale()) && (inputMethod != "key"))
{
   MsgBox, Your GUI scale is not supported with the click macro. Either change your GUI scale to 0, 3, or 4, or change the input method to "key". Then run the script again.
   ExitApp
}
if ((playSound != "Yes") and (playSound != "No"))
{
   MsgBox, Choose a valid option for whether or not to play a sound. Go to the Options section of this script and choose either "Yes" or "No" after the words "global playSound := "
   ExitApp
}
if ((activateMCOnLoad != "Yes") and (activateMCOnLoad != "No"))
{
   MsgBox, Choose a valid option for whether or not to activate Minecraft when the load is complete. Go to the Options section of this script and choose either "Yes" or "No" after the words "global activateMCOnLoad := "
   ExitApp
}
if ((fullscreenOnLoad != "Yes") and (fullscreenOnLoad != "No"))
{
   MsgBox, Choose a valid option for whether or not to fullscreen Minecraft when the load is complete. Go to the Options section of this script and choose either "Yes" or "No" after the words "global fullscreenOnLoad := "
   ExitApp
}
;this feature does not work right now: global 2RDOnExit = "No" ; change this to "Yes" if you would like to automatically go to 2 render distance when you reset from a previous world (may not work depending on your resolution, and will not work if you don't have sodium)
;if ((2RDOnExit != "Yes") and (2RDOnExit != "No"))
;{
;   MsgBox, Choose a valid option for whether or not to go to 2 render distance when exiting a world. Go to the Options section of this script and choose either "Yes" or "No" after the words "global 2RDOnExit := "
;   ExitApp
;}
if ((trackFlint != "Yes") and (trackFlint != "No"))
{
   MsgBox, Choose a valid option for whether or not to track flint rates. Go to the Options section of this script and choose either "Yes" or "No" after the words "global trackFlint := "
   ExitApp
}
if ((PauseOnLostFocus()) && (doAutoResets = "Yes") && (f3pWarning = "enabled"))
{
   MsgBox, If you would like to use the autoresetter while tabbed out, you will need to disable the "pause on lost focus" feature by pressing F3 + P in-game. If you will not be tabbed out while using the autoresetter, then don't worry about this, and you can disable this warning by changing "global f3pWarning := "enabled"" to "global f3pWarning := "disabled"" This is just a warning message and it will not exit the script, so you do not need to restart the script if you see this.
}

SetDefaultMouseSpeed, 0
SetMouseDelay, 0
SetKeyDelay , 1
SetWinDelay, 1
;global oldClipboard
global currentSpawn := [9999,9999]

#IfWinActive, Minecraft
{
F5::Reload   

PgUp:: ; This is where the keybind for creating a world is set.
   DoSomeResets(False)
return

PgDn:: ; This is where the keybind for creating a world and deleting/moving the previous one is set.
   DoSomeResets()
return

End:: ; This is where the keybind for opening to LAN and perching is set.
   Perch()
return

Home:: ; This is where the keybind for exiting a world is set.
   ExitWorld()
return

^B:: ; This is where the keybind is set for adding a spawn to the blacklisted spawns.
   AddToBlacklist()
return

Insert::
   Test()
return
}

