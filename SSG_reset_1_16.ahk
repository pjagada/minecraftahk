; WARNING: THIS SCRIPT IS ILLEGAL AS OF CURRENT RULES UNLESS YOU SET "global doAutoResets := "No""

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
;   Q: Why does it spend so long at the world list screen?
;   A: Go a few lines down and decrease the number after the words "global worldListWait := "
;
;   Q: It doesn't do anything when I click run script / Run script doesn't appear.
;   A: Right click the file, click "Open with" -> "Choose another app" -> "More apps" -> "Look for another app on this PC," then find the AutoHotkey folder (likely in Program Files).
;      Go into that folder, and double click on AutoHotkeyU64.exe. If that's not there, then reinstall AutoHotkey.
 
#NoEnv
SetWorkingDir %A_ScriptDir%

; Options:
global savesDirectory := "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.16.1\.minecraft\saves" ; input your minecraft saves directory here. It will probably start with "C:\Users..." and end with "\minecraft\saves"
global screenDelay := 34 ; Change this value to increase/decrease the number of time (in milliseconds) that each world creation screen is held for. For your run to be verifiable, each of the three screens of world creation must be shown.
global worldListWait := 100 ; The macro will wait for the world list screen to show before proceeding, but sometimes this feature doesn't work, especially if you use fullscreen, and always if you're tabbed out during this part.
                            ; In that case, this number (in milliseconds) defines the hard limit that it will wait after clicking on "Singleplayer" before proceeding.
                            ; This number should basically just be a little longer than your world list screen showing lag.

global difficulty := "Normal" ; Set difficulty here. Options: "Peaceful" "Easy" "Normal" "Hard" "Hardcore"
global SEED := 2483313382402348964 ; Default seed is the current Any% SSG 1.16 seed, you can change it to whatever seed you want.

global countAttempts := "No" ; Change this to "Yes" if you would like the world name to include the attempt number, otherwise, keep it as "No"
                             ; The script will automatically create a text file to track your attempts starting from 1, but if you already have some attempts,
                             ; you can make a file called SSG_1_16.txt and put the number your attempts there. You can change that file whenever you want if the number ever gets messed up.
global worldName := "New World" ; you can name the world whatever you want, put the name inside the quotation marks.
                                ; If you selected "Yes" in the above option to counting attempts, this name will be the prefix.
                                ; For example, if you leave this as "New World" and you're on attempt 343, then the world will be named "New World343"
                                ; To just show the attempt number, change this variable to ""

global previousWorldOption := "delete" ; What to do with the previous world (either "delete" or "move") when the Page Down hotkey is used. If it says "move" then worlds will be moved to a folder called oldWorlds in your .minecraft folder

global inputMethod := "key" ; either "click" or "key" (click is theoretically faster but kinda experimental at this point and may not work properly depending on your resolution)
global windowedReset := "No" ; change this to "Yes" if you would like to ensure that you are in windowed mode during resets (in other words, it will press f11 every time you reset if you are in fullscreen) (this is automatically enabled if you're using the autoresetter)
global pauseOnLoad := "No" ; change this to "Yes" if you would like the macro to automatically pause when the world loads in (this is automatically enabled if you're using the autoresetter)

; Autoresetter Options:
global doAutoResets := "Yes" ; "Yes" or "No" for whether or not to run the autoresetter based on spawns
; The autoresetter will automatically reset if your spawn is greater than a certain number of blocks away from a certain point (ignoring y)
global centerPointX := -272.5 ; this is the x coordinate of that certain point (by default it's the best spawn of 2483313382402348964)
global centerPointZ := 240.5 ; this is the z coordinate of that certain point (by default it's the best spawn of 2483313382402348964)
global radius := 46 ; if this is 10 for example, the autoresetter will not reset if you are within 10 blocks of the point specified above. Set this smaller for better spawns but more resets
global f3pWarning := "enabled" ; change this to "disabled" once you've seen the warning
global message := "good spawn PauseMan" ; what message will pop up when a good spawn is found (if you don't want a message to pop up, change this to "")
global playSound := "Yes" ; "Yes" or "No" on whether or not to play that Windows sound when good seed is found

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
      ControlSend, ahk_parent, {Shift down}
      Loop, %n%
      {
         ControlSend, ahk_parent, {Tab}
      }
      ControlSend, ahk_parent, {Shift up}
   }
}

Perch()
{
   Send, {Esc} ; pause
   ShiftTab(1)
   ShiftTab(1)
   fastResetModStuff()
   Send, {enter} ; open to LAN
   ShiftTab(1)
   Send, {enter} ; cheats on
   Send, `t
   Send, {enter} ; open to LAN
   Sleep, 20
   Send, /
   Sleep, 70
   SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
   Send, {enter}
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
   if (inputMethod = "key")
   {
      ControlSend, ahk_parent, `t
      WinGetPos, X, Y, W, H, Minecraft
      X1 := Floor(W / 2) - 1
      Y1 := Floor(H / 25)
      X2 := Ceil(W / 2) + 1
      Y2 := Ceil(H / 3)
      PixelSearch, Px, Py, X1, Y1, X2, Y2, 0xADAFB7, 0, Fast
      previousError := ErrorLevel
      ControlSend, ahk_parent, {enter}
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

PossiblyPause()
{
   Sleep, 1000
   if ((pauseOnLoad = "Yes") or (doAutoResets = "Yes"))
   {
      Loop
      {
         WinGetTitle, Title, ahk_exe javaw.exe
         if (InStr(Title, "player"))
         {
            if ((InStr(previousTitle, "Minecraft")) && (!InStr(previousTitle, "player")))
            {
               if (doAutoResets = "Yes")
               {
                  Sleep, 10
                  ControlSend, ahk_parent, {F3 Down}c{F3 Up}
               }
               ControlSend, ahk_parent, {Esc}
            }
            break
         }
         Sleep, 50
         previousTitle := Title
      }
      
   }
}

WorldListScreen()
{
   if (inputMethod = "key")
   {
      if WinActive("Minecraft")
      {
         ShiftTab(2)
      }
      else
      {
         ControlSend, ahk_parent, `t
         ControlSend, ahk_parent, `t
         ControlSend, ahk_parent, `t
      }
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}
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
   if (inputMethod = "key")
   {
      if (difficulty = "Normal")
      {
         ShiftTab(3)
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
            ControlSend, ahk_parent, `t
            ControlSend, ahk_parent, `t
         }
         ControlSend, ahk_parent, `t
         ControlSend, ahk_parent, `t
      }
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}
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

MoreWorldOptionsScreen()
{
   if (inputMethod = "key")
   {
      ControlSend, ahk_parent, `t
      ControlSend, ahk_parent, `t
      ControlSend, ahk_parent, `t
      InputSeed()
      ShiftTab(2)
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}
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

ExitWorld2()
{
   
   ControlSend, ahk_parent, {Esc}
   if (inputMethod = "key")
   {
      ShiftTab(1)
      ControlSend, ahk_parent, {Enter}
   }
   else
   {
      WinGetPos, X, Y, W, H, Minecraft
      if (GUIscale = 4)
         MouseClick, L, W * 963 // 1936, H * 836 // 1056, 1
      else
         MouseClick, L, W * 963 // 1936, H * 669 // 1056, 1
   }
}

ExitWorld(manualReset := True)
{
   if (manualReset)
   {
      ShiftTab(1)
      ControlSend, ahk_parent, {Enter}
      ControlSend, ahk_parent, {Esc}
      ShiftTab(1)
      Sleep, 10
      ControlSend, ahk_parent, {Enter}
   }
   else
   {
      ShiftTab(1)
      Sleep, 10
      ControlSend, ahk_parent, {Enter}
   }
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
   IfInString Title, player
      ExitWorld(manualReset)
   if (InFullscreen() && ((windowedReset = "Yes") or (doAutoResets = "Yes")))
   {
      ControlSend, ahk_parent, {F11}
      Sleep, 50
   }
   Loop
   {
      lastWorld := getMostRecentFile()
      lockFile := lastWorld . "\session.lock"
      FileRead, sessionlockfile, %lockFile%
      Sleep, 10
      if (ErrorLevel = 0)
      {
         Sleep, 50
         break
      }
   }
   return (lastWorld)
}

DeleteOrMove(lastWorld)
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

InFullscreen()
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, fullscreenLine, %optionsFile%, 17
   if (InStr(fullscreenLine, "true"))
      return 1
   else
      return 0
}

PauseOnLostFocus()
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, optionLine, %optionsFile%, 45
   if (InStr(optionLine, "true"))
      return 1
   else
      return 0
}

global GUIscale
getGUIscale()
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, guiScaleLine, %optionsFile%, 26
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

getIGT()
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

isPaused()
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
   CreateWorld()
   if (removePrevious)
      DeleteOrMove(lastWorld)
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
         DoAReset(True, False)
      if (goodSpawn())
         break
      counter += 1
      Sleep, 100
   }
}

goodSpawn()
{
   array1 := StrSplit(Clipboard, " ")
   xCoord := array1[7]
   zCoord := array1[9]
   xDisplacement := xCoord - centerPointX
   zDisplacement := zCoord - centerPointZ
   distance := Sqrt((xDisplacement * xDisplacement) + (zDisplacement * zDisplacement))
   if (distance <= radius)
   {
      AlertUser()
      return True
   }
   else
      return False
}

AlertUser()
{
   WinActivate, ahk_exe javaw.exe
   if (playSound = "Yes")
      SoundPlay *16
   if (message != "")
      MsgBox, %message%
}

Test()
{
   
}

if ((!FileExist(savesDirectory)) or (!InStr(savesDirectory, ".minecraft\saves")))
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
if ((PauseOnLostFocus()) && (doAutoResets = "Yes") && (f3pWarning = "enabled"))
{
   MsgBox, If you would like to use the autoresetter while tabbed out, you will need to disable the "pause on lost focus" feature by pressing F3 + P in-game. If you will not be tabbed out while using the autoresetter, then don't worry about this, and you can disable this warning by changing "global f3pWarning := "enabled"" to "global f3pWarning := "disabled"" This is just a warning message and it will not exit the script, so you do not need to restart the script if you see this.
}
if ((playSound != "Yes") and (playSound != "No"))
{
   MsgBox, Choose a valid option for whether or not to play a sound. Go to the Options section of this script and choose either "Yes" or "No" after the words "global playSound := "
   ExitApp
}

SetDefaultMouseSpeed, 0
SetMouseDelay, 0
SetKeyDelay , 1

F5::Reload

Insert::
   Test()
return

#IfWinActive, Minecraft
{
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
}