;
; Minecraft Reset Script (SET SEED version)
; Author:   onvo
; Edited by SLTRR, DesktopFolder, Peej, and others
;

; Script Function / Help:
;  The following only apply inside the Minecraft window:
;   1) When on the title screen, the "PgUp" key will create a world on Easy with the desired seed.
;   2) After loading in the world, "PgUp" will exit the world and then auto create another world on Easy
;   3) "PgDn" will do the same thing as "PgUp," but it will also delete the previous world.
;   4) To just exit the world and not auto create world, press "Home" on keyboard.
;   5) To open to LAN and make the dragon perch (make sure you're not in an inventory or already paused), press "End"
;   6) To change the "PgDn" and "PgUp" and "Home" and "End," scroll down to the bottom of this script, change the character before the double colon "::", and reload the script.
;      https://www.autohotkey.com/docs/KeyList.htm Here are a list of the keys you can use.
;   7) If you want to use a different seed (for category extensions, etc), scroll down to the line 
;      that starts with ; SEED: and modify the seed in the line below as desired.
;   8) If you are in a minecraft world and inside a menu or inventory, close that menu/inventory before
;      activating the script (otherwise, the macro may not function properly).
;      The macro that creates a new world only works from the title screen or from a previous world (unpaused and not in an inventory).
;   9) If you scroll down to the WaitForWorldList function, you can also change the delay after the world list screen is shown.
;   10) Many people will set their key delay to much lower than 70, so the Perch function does automatically account for that.
;       This is because I believe that opening chat is somewhat tick-based, so there must be at least 50 ms of delay (in practice it should be like at least 60) between the "/" and the rest of the command.
;       So basically, that the number in the Perch function next to the "Sleep" command adds up to at least like 50-60ish when combined with the key delay for the rest of the script.


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

TypeSeed()
{
; SEED: This is where the seed is input. If a different seed is desired, edit below.
SendInput, 2483313382402348964
}

WaitForWorldList(W, H)
{
Loop { ; Keep checking until world list screen has appeared
PixelSearch, Px, Py, 0, 0, W, H, 0x00FCFC, 1, Fast
if (ErrorLevel) {
	Sleep, 70 ; Once world list screen appears, wait 70 ms and then create new world. You can probably lower this number if you want, but this is pretty safe.
	break
}
}
}

Perch()
{
Send, {Esc} ; pause
Send, +`t
Send, +`t
Send, {enter} ; open to LAN
Send, +`t
Send, {enter} ; cheats on
Send, `t
Send, {enter} ; open to LAN
Send, /
Sleep, 50 ; You can lower this number or take it out completely if it adds up to over 50-60ish depending on your key delay.
; Just make sure that this number plus your key delay is at least like 50-60 and it should work fine.
SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
Send, {enter}
}

CreateWorld(W, H)
{
Send, `t
Send, {enter}
WaitForWorldList(W, H)
CreateNewWorld()
}

DeleteAndCreateWorld(W, H)
{
Send, `t
Send, {enter}
WaitForWorldList(W, H)
Send, `t
Send, `t
Send, `t
Send, `t
Send, `t
Send, {enter}
Send, `t
Send, {enter}
CreateNewWorld()
}

CreateNewWorld()
{
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
Send, {enter}
Send, `t
Send, `t
Send, `t
TypeSeed()
Send, +`t
Send, +`t
Send, {enter}
}

ExitWorld()
{
   send {Esc}+{Tab}{Enter} 
}

#IfWinActive, Minecraft ; Ensure Minecraft is the active window.
{
PgUp:: ; This is where the keybind for (re)creating an SSG world is set.
   WinGetPos, X, Y, W, H, Minecraft
   WinGetActiveTitle, Title
   IfNotInString Title, player ; Determine if we are already in a world.
      CreateWorld(W, H)
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
                  CreateWorld(W, H)
                  break
               }
            }
         }
      } 
   } 
return

PgDn:: ; This is where the keybind for (re)creating an SSG world and deleting the previous one is set.
   WinGetPos, X, Y, W, H, Minecraft
   WinGetActiveTitle, Title
   IfNotInString Title, player ; Determine if we are already in a world.
      DeleteAndCreateWorld(W, H)
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
                  DeleteAndCreateWorld(W, H)
                  break
               }
            }
         }
      } 
   } 
return

Home::
   ExitWorld()
return

End::
   Perch()
return
}


