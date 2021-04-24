;
; Minecraft Reset Script v1.2 (RANDOM SEED version)
; Author:   onvo
; Edited by SLTRR, DesktopFolder, Peej, and others
;

; Script Function / Help:
;  The following only apply inside the Minecraft window:
;   1) When on the title screen, the "J" key will create a world on Easy.
;   2) After loading in the world, "J" will exit the world and then auto create another world on Easy
;   3) "I" will do the same thing as "J," but it will also delete the previous world.
;   4) To just exit the world and not auto create world, press "U" on keyboard.
;   5) To change the "I" and "J" and "U", scroll down to the bottom of this script, change the character before the double colon "::", and reload the script.
;      https://www.autohotkey.com/docs/KeyList.htm Here are a list of the keys you can use.
;   6) If you are in a minecraft world and inside a menu or inventory, close that menu/inventory before
;      activating the script (otherwise, the macro may not function properly).
;      The macro that creates a new world only works from the title screen or from a previous world (unpaused and not in an inventory).


#NoEnv
SetWorkingDir %A_ScriptDir%

; This script comes with delay enabled, with 70ms delay between keypresses (not including seed input)
; To remove input delay, change the following line to DELAY = 0. Warning: This may make your runs unverifiable.
DELAY = 1
if DELAY
   SetKeyDelay , 70 ; Change this value to increase/decrease delay between key presses. For your run to be verifiable, each of the three screens of world creation must be shown. An input delay of 70 ms is recommended to ensure this.
else {
   SendMode Input
}

CreateWorld()
{
Send, `t
Send, {enter}
Send, `t
Send, `t
Send, `t
Send, {enter}
Send, `t
Send, `t
Send, {enter}
Send, {enter}
Send, {enter}
Send, `t
Send, `t
Send, `t
Send, `t
Send, `t
Send, {enter}
}

DeleteAndCreateWorld()
{
Send, `t
Send, {enter}
Send, `t
Send, {Down}
Send, {Down}
Send, {Down}
Send, {Down}
Send, {Down}
Send, `t
Send, `t
Send, `t
Send, `t
Send, {enter}
Send, `t
Send, {enter}
Send, `t
Send, `t
Send, `t
Send, {enter}
Send, `t
Send, `t
Send, {enter}
Send, {enter}
Send, {enter}
Send, `t
Send, `t
Send, `t
Send, `t
Send, `t
Send, {enter}
}


ExitWorld()
{
   send {Esc}+{Tab}{Enter} 
}

#IfWinActive, Minecraft ; Ensure Minecraft is the active window.
{
J:: ; This is where the keybind for (re)creating an RSG world is set.
   WinGetPos, X, Y, W, H, Minecraft
   WinGetActiveTitle, Title
   IfNotInString Title, player ; Determine if we are already in a world.
      CreateWorld()
   else {
      ExitWorld()
      Loop {
         IfWinActive, Minecraft 
         {
            PixelSearch, Px, Py, 0, 0, W, H, 0x00FCFC, 1, Fast ; Waits to make sure we have properly exited the world.
            if (!ErrorLevel) {
               Sleep, 100
               IfWinActive, Minecraft 
               {
		Sleep, 100
                  CreateWorld()
                  break
               }
            }
         }
      } 
   } 
return

I:: ; This is where the keybind for (re)creating an RSG world and deleting the previous one is set.
   WinGetPos, X, Y, W, H, Minecraft
   WinGetActiveTitle, Title
   IfNotInString Title, player ; Determine if we are already in a world.
      DeleteAndCreateWorld()
   else {
      ExitWorld()
      Loop {
         IfWinActive, Minecraft 
         {
            PixelSearch, Px, Py, 0, 0, W, H, 0x00FCFC, 1, Fast ; Waits to make sure we have properly exited the world.
            if (!ErrorLevel) {
               Sleep, 100
               IfWinActive, Minecraft 
               {
		Sleep, 100
                  DeleteAndCreateWorld()
                  break
               }
            }
         }
      } 
   } 
return

U::
   ExitWorld()
return
}


