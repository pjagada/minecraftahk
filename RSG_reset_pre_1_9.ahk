; this is work in progress and currently only works for large scale gui in fullscreen mode

; Minecraft Reset Script (RANDOM SEED version)
; Author:   onvo
; Edited by SLTRR, DesktopFolder, Peej, and others
; To use this script, make sure you have autohotkey installed (autohotkey.com), then right click on the script file, and click "Run Script."
; If you make any changes to the script by right clicking and clicking "Edit Script," make sure to reload the script by right clicking on the logo in your taskbar and clicking "Reload Script."

; Script Function / Help:
;  The following only apply inside the Minecraft window:
;   1) When on the title screen, the "PgUp" key will create a world.
;   2) "PgDn" will do the same thing as "PgUp," but it will also delete the previous world.
;   3) To exit the world to the title screen, press "Home" on keyboard.
;   5) To change the "PgDn" and "PgUp" and "Home", scroll down to the bottom of this script, change the character before the double colon "::", and reload the script.
;      https://www.autohotkey.com/docs/KeyList.htm Here are a list of the keys you can use.
;   6) If you want to change the difficulty, scroll down to the Options and you can change those.
;   7) If you are in a minecraft world and inside a menu or inventory, close that menu/inventory before activating the script (otherwise, the macro may not function properly).
;      The macro that creates a new world only works from the title screen or from a previous world (unpaused and not in an inventory).
;   8) There have been a lot of verification problems of the world list screen not appearing because of the lag it takes to show that screen when you have a lot of worlds, even with a long key delay.
;      This script has a feature that can counter that problem by waiting for the title screen to go away and for the world list screen to appear before proceeding with the keypresses.

; Troubleshooting:
;   There can sometimes be an issue with DirectX and the PixelSearch command. This can sometimes cause two problems:
;	1) When resetting from a previous world, the program won't register the title screen, so it will never create a new world.
;          Unfortunately, there currently isn't a workaround, so you'll just have to first go to title screen by pressing "Home," and then you can press "PgUp" or "PgDn" to create a new world.
;	2) This also messes up the WaitForWorldList function, so if you're having an issue with that, you unfortunately won't be able to use that feature.
;	   Scroll down to the Options section and change the worldListWait variable to 0 to disable that feature.
;	   If you disable this feature, make sure that your key delay is long enough to show the world list screen even with the lag that tends to happen.
;   These issues tend to happen more frequently for fullscreen users.

#NoEnv
SetWorkingDir %A_ScriptDir%

; Options:
SetDefaultMouseSpeed, 1 ; mouse speed ranging from 0 (instant) to 100 (slowest)
global mouseDelay := 70 ; Change this value to increase/decrease delay between mouse clicks. For your run to be verifiable, all of the screens of world creation must be shown.
		      ; An input delay of 70 ms is recommended to ensure this. To remove delay, set this value to 0. Warning: Doing so will likely make your runs unverifiable.

CreateWorld()
{
MouseClick, Left, 960, 441
;if (worldListWait)
;{
;  WaitForWorldList()
;}
CreateNewWorld()
}

DeleteAndCreateWorld()
{
MouseClick, Left, 960, 441
;if (worldListWait)
;{
;  WaitForWorldList()
;}
MouseClick, Left, 960, 154
MouseClick, Left, 843, 1024
MouseClick, Left, 732, 496
CreateNewWorld()
}

CreateNewWorld()
{
MouseClick, Left, 1200, 952
MouseClick, Left, 711, 1024
}

if mouseDelay {
   SetMouseDelay , %mouseDelay%
   SetKeyDelay, %mouseDelay%
}
else {
   SendMode Input
}

ExitWorld()
{
   Send, {Esc}
   MouseClick, Left, 960, 610
}

;global worldListWait := 1 ; Once world list screen appears, wait 1 ms and then proceed. (You actually don't need anything more than that since the keyDelay takes care of showing the screen for enough time, but you can increase this if you want)
			   ; If your macro is getting stuck, change this to 0, but make sure that your key delay is long enough to show this world screen after accounting for the lag that tends to happen when showing that screen.
               ; Warning: If this value is 0, that means that it will not wait for any screen to load at all, not that it will wait for 0 ms, which is why I have it set to 1 by default.

;WaitForWorldList()
;{
;Loop { ; Keep checking until world list screen has appeared
;  WinGetPos, X, Y, W, H, Minecraft
;  PixelSearch, Px, Py, 0, 0, W, H, 0x00FCFC, 1, Fast
;  if (ErrorLevel) {
;	Sleep, %worldListWait% ;
;	break
;  }
;}
;}

#IfWinActive, Minecraft ; Ensure Minecraft is the active window.
{
PgUp:: ; This is where the keybind for creating an RSG world is set.
;   WinGetPos, X, Y, W, H, Minecraft
;   WinGetActiveTitle, Title
;   IfNotInString Title, player ; Determine if we are already in a world.
;      CreateWorld()f
;   else {
;      ExitWorld()
;      Loop {
;         IfWinActive, Minecraft 
;         {
;            PixelSearch, Px, Py, 0, 0, W, H, 0xBDC9EC, 1, Fast ; Waits to make sure we have properly exited the world.
;            if (!ErrorLevel) {
;               Sleep, 100
;               IfWinActive, Minecraft 
;               {
;		Sleep, 100
                  CreateWorld()
;                  break
;               }
;            }
;         }
;      } 
;   } 
return

PgDn:: ; This is where the keybind for creating an RSG world and deleting the 6th most recent one is set.
   DeleteAndCreateWorld()
return

Home::
   ExitWorld()
return

;F:: ; debugging
;   MouseGetPos, X, Y
;   MsgBox, %X% %Y%
;return


;C:: ; debugging
;   WinGetPos, X, Y, W, H, Minecraft
;   PixelSearch, Px, Py, 0, 0, W, H, 0xFFFF00, 2, Fast
;   if (ErrorLevel = 1) {
;      MsgBox, Color not found
;   }
;   else {
;      MsgBox, Color found
;   }
return
}


