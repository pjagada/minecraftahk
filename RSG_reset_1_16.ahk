; Minecraft Reset Script (random seed 1.16)
; Author:  Peej, with help/code from jojoe77777, onvo, SLTRR, DesktopFolder, and _D4rkS0ul_
; Authors are not liable for any run rejections.
; To use this script, make sure you have autohotkey installed (autohotkey.com), then right click on the script file, and click "Run Script."
; If you make any changes to the script by right clicking and clicking "Edit Script," make sure to reload the script by right clicking on the logo in your taskbar and clicking "Reload Script."

; Script Function / Help:
;  The following only apply inside the Minecraft window:
;   1) When on the title screen, the "PgUp" key will create a world.
;   2) When in a previous world, "PgUp" will exit the world and then auto create another world. You must specify your saves directory down below for this to work.
;   3) "PgDn" will do the same thing as "PgUp," but it will also move the previous world to another folder (or delete it if you have that option selected).
;   4) To just exit the world and not create another world, press "Home" on keyboard.
;   5) To change the "PgDn" and "PgUp" and "Home," scroll down to the bottom of this script, change the character before the double colon "::", and reload the script.
;      https://www.autohotkey.com/docs/KeyList.htm Here are a list of the keys you can use.
;   6) If you want to change the difficulty or change the world name, scroll down to the Options and you can change those.
;   7) If you are in a minecraft world and inside a menu or inventory, close that menu/inventory before activating the script (otherwise, the macro will not function properly).
;      The macro that creates a new world only works from the title screen or from a previous world (unpaused and not in an inventory).
;   8) There have been a lot of verification problems of the world list screen not appearing because of the lag it takes to show that screen when you have a lot of worlds, even with a long key delay.
;      This script has a feature that can counter that problem by waiting for the title screen to go away and for the world list screen to appear before proceeding with the keypresses.

; Troubleshooting:
;   Q: When I reset from a previous world, why is it getting stuck at the title screen?
;   A: Check that your saves directory is spelled correctly.
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
global savesDirectory := "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.16.1\.minecraft\saves" ; input your minecraft saves directory here. It will probably start with "C:\Users..." and end with "\minecraft\saves"
global keyDelay := 70 ; Change this value to increase/decrease delay between key presses. For your run to be verifiable, each of the three screens of world creation must be shown.
		      ; An input delay of 70 ms is recommended to ensure this. To remove delay, set this value to 0. Warning: Doing so will likely make your runs unverifiable.
global worldListWait := 1000 ; The macro will wait for the world list screen to show before proceeding, but sometimes this feature doesn't work, especially if you use fullscreen, and always if you're tabbed out during this part.
                            ; In that case, this number (in milliseconds) defines the hard limit that it will wait after clicking on "Singleplayer" before proceeding.
                            ; This number should basically just be a little longer than your world list screen showing lag.

global difficulty := "Normal" ; Set difficulty here. Options: "Peaceful" "Easy" "Normal" "Hard" "Hardcore"

global countAttempts := "No" ; Change this to "Yes" if you would like the world name to include the attempt number, otherwise, keep it as "No"
                             ; The script will automatically create a text file to track your attempts starting from 1, but if you already have some attempts,
                             ; you can make a file called RSG_1_16.txt and put the number your attempts there. You can change that file whenever you want if the number ever gets messed up.
global worldName := "New World" ; you can name the world whatever you want, put the name inside the quotation marks.
                                ; If you selected "Yes" in the above option to counting attempts, this name will be the prefix.
                                ; For example, if you leave this as "New World" and you're on attempt 343, then the world will be named "New World343"
                                ; To just show the attempt number, change this variable to ""

global previousWorldOption := "move" ; What to do with the previous world (either "delete" or "move") when the Page Down hotkey is used. If it says "move" then worlds will be moved to a folder called oldWorlds in your .minecraft folder

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
         Sleep, 20
      }
   }
   else
   {
      Sleep, worldListWait
   }
}

EnterSingleplayer()
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
   WaitForWorldList(previousError)
}

CreateWorld()
{
EnterSingleplayer()
CreateNewWorld()
}

CreateNewWorld()
{
ShiftTab()
ShiftTab()
ControlSend, ahk_parent, {enter}
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
      SetKeyDelay, 1
      ControlSend, ahk_parent, {Control down}
      ControlSend, ahk_parent, a
      ControlSend, ahk_parent, {Control up}
      ControlSend, ahk_parent, {BackSpace}
      ControlSend, ahk_parent, %worldName%
      SetKeyDelay, %keyDelay%
   }
}
if (countAttempts = "Yes")
{
   FileRead, WorldNumber, RSG_1_16.txt
   if (ErrorLevel)
      WorldNumber = 0
   else
      FileDelete, RSG_1_16.txt
   WorldNumber += 1
   FileAppend, %WorldNumber%, RSG_1_16.txt
   if WinActive("Minecraft")
   {
      Sleep, 1
      SendInput, %WorldNumber%
      Sleep, 1
   }
   else
   {
      SetKeyDelay, 1
      ControlSend, ahk_parent, %WorldNumber%
      SetKeyDelay, %keyDelay%
   }
}
if (difficulty = "Hardcore")
{
   ControlSend, ahk_parent, `t
   ControlSend, ahk_parent, {enter}
   ShiftTab()
   ShiftTab()
   ShiftTab()
}
else if (difficulty = "Normal")
{
   ShiftTab()
   ShiftTab()
}
else
{
  ControlSend, ahk_parent, `t
  ControlSend, ahk_parent, `t
  ControlSend, ahk_parent, {enter}
  if (difficulty != "Hard")
  {
    ControlSend, ahk_parent, {enter}
    if (difficulty != "Peaceful")
    {
      ControlSend, ahk_parent, {enter}
      if (difficulty != "Easy")
      {
        MsgBox, Difficulty entered is invalid. Please check your spelling and enter a valid difficulty. Options are "Peaceful" "Easy" "Normal" "Hard" or "Hardcore"
	ExitApp
      }
    }
  }
  ShiftTab()
  ShiftTab()
  ShiftTab()
  ShiftTab() 
}
ControlSend, ahk_parent, {enter}
}

ShiftTab()
{
   if WinActive("Minecraft")
   {
      Send, +`t
   }
   else
   {
      SetKeyDelay, 1
      ControlSend, ahk_parent, {Shift down}{Tab}{Shift up}
      SetKeyDelay, %keyDelay%
   }
}

ExitWorld()
{
   ControlSend, ahk_parent, {Esc}
   ShiftTab()
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

DoEverything()
{
   WinGetActiveTitle, Title
   IfInString Title, player
   ExitWorld()
   Loop
   {
      lastWorld := getMostRecentFile()
      lockFile := lastWorld . "\session.lock"
      FileRead, sessionlockfile, %lockFile%
      Sleep, 20
      if (ErrorLevel = 0)
      {
         Sleep, %keyDelay%
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
   else
   {
      MsgBox, Choose a valid option for what to do with the previous world. Go to the Options section of this script and choose either "move" or "delete" after the words "global previousWorldOption := "
      ExitApp
   }
}

SetKeyDelay , %keyDelay%

#IfWinActive, Minecraft
{
PgUp:: ; This is where the keybind for creating a world is set.
   DoEverything()
   CreateWorld()
return

PgDn:: ; This is where the keybind for creating a world and deleting/moving the previous one is set.
   lastWorld := DoEverything()
   CreateWorld()
   DeleteOrMove(lastWorld)
return

Home:: ; This is where the keybind for exiting a world is set.
   ExitWorld()
return
}


