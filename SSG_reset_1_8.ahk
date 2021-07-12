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
 
#NoEnv
SetWorkingDir %A_ScriptDir%

; Options:
global savesDirectory := "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.17\.minecraft\saves" ; input your minecraft saves directory here. It will probably start with "C:\Users..." and end with "\minecraft\saves"
global screenDelay := 30 ; Change this value to increase/decrease the number of time (in milliseconds) that each world creation screen is held for. For your run to be verifiable, each of the three screens of world creation must be shown.
global worldListWait := 1000 ; The macro will wait for the world list screen to show before proceeding, but sometimes this feature doesn't work, especially if you use fullscreen, and always if you're tabbed out during this part.
                            ; In that case, this number (in milliseconds) defines the hard limit that it will wait after clicking on "Singleplayer" before proceeding.
                            ; This number should basically just be a little longer than your world list screen showing lag.

global SEED := "-3294725893620991126" ; Default seed is the current Any% SSG 1.16+ seed, you can change it to whatever seed you want.

global countAttempts := "No" ; Change this to "Yes" if you would like the world name to include the attempt number, otherwise, keep it as "No"
                             ; The script will automatically create a text file to track your attempts starting from 1, but if you already have some attempts,
                             ; you can make a file called SSG_1_16.txt and put the number your attempts there. You can change that file whenever you want if the number ever gets messed up.
global worldName := "New World" ; you can name the world whatever you want, put the name inside the quotation marks.
                                ; If you selected "Yes" in the above option to counting attempts, this name will be the prefix.
                                ; For example, if you leave this as "New World" and you're on attempt 343, then the world will be named "New World343"
                                ; To just show the attempt number, change this variable to ""

global previousWorldOption := "move" ; What to do with the previous world (either "delete" or "move") when the Page Down hotkey is used. If it says "move" then worlds will be moved to a folder called oldWorlds in your .minecraft folder

global windowedReset := "No" ; change this to "Yes" if you would like to ensure that you are in windowed mode during resets (in other words, it will press f11 every time you reset if you are in fullscreen)


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
   Sleep, %screenDelay%
   WinGetPos, X, Y, W, H, Minecraft
   if (GUIscale = 4)
      MouseClick, L, W * 963 // 1936, H * 233 // 1056, 1
   else
      MouseClick, L, W * 1200 // 1936, H * 935 // 1056, 1
}

CreateNewWorldScreen()
{
   Sleep, %screenDelay%
   WinGetPos, X, Y, W, H, Minecraft
   if (GUIscale = 4)
      MouseClick, L, W * 963 // 1936, H * 233 // 1056, 1
   else
      MouseClick, L, W * 1200 // 1936, H * 935 // 1056, 1
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

ExitWorld()
{
   if (manualReset)
   {
      ShiftTab(1)
      ControlSend, ahk_parent, {Enter}
      ControlSend, ahk_parent, {Esc}
      ;ChangeRD()
   }
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


global GUIscale
getGUIscale() ;used on script startup
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, guiScaleLine, %optionsFile%, 7
   if (InStr(guiScaleLine, 4) or InStr(guiScaleLine, 0))
   {
      GUIscale := 4
      return 4
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

Recreate()
{
   lastWorld := DoEverything(manualReset)
   CreateWorld()
   if (removePrevious)
      DeleteOrMove(lastWorld)
   UpdateStats()
   PossiblyPause()
}

Test()
{
   UpdateStats()
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
if ((windowedReset != "Yes") and (windowedReset != "No"))
{
   MsgBox, Choose a valid option for whether or not to do windowed resets. Go to the Options section of this script and choose either "Yes" or "No" after the words "global windowedReset := "
   ExitApp
}
if (!getGUIscale())
{
   MsgBox, Your GUI scale is not supported. unlucky WideSadPag
   ExitApp
}

SetDefaultMouseSpeed, 0
SetMouseDelay, 0
SetKeyDelay , 1
SetWinDelay, 1

#IfWinActive, Minecraft
{
F5::Reload   

PgUp:: ; This is where the keybind for creating a world is set.
   CreateNew()
return

PgDn:: ; This is where the keybind for recreating a world and deleting/moving the previous one is set.
   Recreate()
return

Home:: ; This is where the keybind for exiting a world is set.
   ExitWorld()
return

Insert::
   Test()
return
}

