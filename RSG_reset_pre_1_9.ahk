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

#NoEnv
SetWorkingDir %A_ScriptDir%

; Options:
SetDefaultMouseSpeed, 1 ; mouse speed ranging from 0 (instant) to 100 (slowest)
global mouseDelay := 70 ; Change this value to increase/decrease delay between mouse clicks. For your run to be verifiable, all of the screens of world creation must be shown.
		      ; An input delay of 70 ms is recommended to ensure this. To remove delay, set this value to 0. Warning: Doing so will likely make your runs unverifiable.

CreateWorld()
{
MouseClick, Left, 960, 441
CreateNewWorld()
}

DeleteAndCreateWorld()
{
MouseClick, Left, 960, 441
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

#IfWinActive, Minecraft ; Ensure Minecraft is the active window.
{
PgUp:: ; This is where the keybind for creating an RSG world is set.
   CreateWorld()
return

PgDn:: ; This is where the keybind for creating an RSG world and deleting the 6th most recent one is set.
   DeleteAndCreateWorld()
return

Home::
   ExitWorld()
return
}


