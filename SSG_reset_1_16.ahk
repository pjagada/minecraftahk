; Minecraft Reset Script (SET SEED version)
; Author:  Peej, with code taken from Jojoe77777, onvo, SLTRR, DesktopFolder, and _D4rkS0ul_
; To use this script, make sure you have autohotkey installed (autohotkey.com), then right click on the script file, and click "Run Script."
; If you make any changes to the script by right clicking and clicking "Edit Script," make sure to reload the script by right clicking on the logo in your taskbar and clicking "Reload Script."

; Script Function / Help:
;  The following only apply inside the Minecraft window:
;   1) When on the title screen, the "PgUp" key will create a world with the desired seed.
;   2) After loading in the world, "PgUp" will exit the world and then auto create another world.
;   3) "PgDn" will do the same thing as "PgUp," but it will also delete the previous world.
;   4) To just exit the world and not create another world, press "Home" on keyboard.
;   5) To open to LAN and make the dragon perch (make sure you're not in an inventory or already paused), press "End"
;   6) To change the "PgDn" and "PgUp" and "Home" and "End," scroll down to the bottom of this script, change the character before the double colon "::", and reload the script.
;      https://www.autohotkey.com/docs/KeyList.htm Here are a list of the keys you can use.
;   7) If you want to use a different seed, change the difficulty, or change the world name, scroll down to the Options and you can change those.
;   8) If you are in a minecraft world and inside a menu or inventory, close that menu/inventory before activating the script (otherwise, the macro may not function properly).
;      The macro that creates a new world only works from the title screen or from a previous world (unpaused and not in an inventory).
;   9) There have been a lot of verification problems of the world list screen not appearing because of the lag it takes to show that screen when you have a lot of worlds, even with a long key delay.
;      This script has a feature that can counter that problem by waiting for the title screen to go away and for the world list screen to appear before proceeding with the keypresses.

; Troubleshooting:
;   There can sometimes be an issue with the PixelSearch command. This can cause the following problem:
;	When resetting from a previous world, the program won't register the title screen, so it will never create a new world.
;   Unfortunately, there currently isn't a workaround, so you'll just have to first go to title screen by pressing "Home," and then you can press "PgUp" or "PgDn" to create a new world.
;   This issue tends to happen more frequently for fullscreen users.
 
#NoEnv
SetWorkingDir %A_ScriptDir%

; Options:
global keyDelay := 70 ; Change this value to increase/decrease delay between key presses. For your run to be verifiable, each of the three screens of world creation must be shown.
		      ; An input delay of 70 ms is recommended to ensure this. To remove delay, set this value to 0. Warning: Doing so will likely make your runs unverifiable.
global worldListWait := 1000 ; The macro will wait for the world list screen before proceeding, but sometimes this feature doesn't work and it will just get stuck, especially if you use fullscreen, and always if you're tabbed out during this part.
                            ; In that case, this number (in milliseconds) defines the hard limit that it will wait before proceeding. This number should basically just be a little longer than your world list screen showing lag.

global difficulty := "Easy" ; Set difficulty here. Options: "Peaceful" "Easy" "Normal" "Hard" "Hardcore"
global SEED := 2483313382402348964 ; Default seed is the current Any% SSG 1.16 seed, you can change it to whatever seed you want.

global countAttempts := "No" ; Change this to "Yes" if you would like the world name to include the attempt number, otherwise, keep it as "No"
global worldName := "New World" ; you can name the world whatever you want, put the name inside the quotation marks.
                                ; If you selected "Yes" in the above option to counting attempts, this name will be the prefix.
                                ; For example, if you leave this as "New World" and you're on attempt 343, then the world will be named "New World343"
                                ; To just show the attempt number, change this variable to ""

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
; Just make sure that this number plus your key delay is at least like 50-60 and it should work fine. This is because opening chat is tick based so you need some delay.
SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
Send, {enter}
}

WaitForWorldList(previousErrorLevel)
{
   if (previousErrorLevel = 0)
   {
      WinGetPos, X, Y, W, H, Minecraft
      start := A_TickCount
      elapsed := A_TickCount - start
      PixelSearch, Px, Py, 0, 0, W, H, 0xADAFB7, 0, Fast
      while ((elapsed < worldListWait) && (ErrorLevel = 0))
      {
         PixelSearch, Px, Py, 0, 0, W, H, 0xADAFB7, 0, Fast
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
   ControlSend, ahk_parent, `t
   WinGetPos, X, Y, W, H, Minecraft
   PixelSearch, Px, Py, 0, 0, W, H, 0xADAFB7, 0, Fast
   previousError := ErrorLevel
   ControlSend, ahk_parent, {enter}
   WaitForWorldList(previousError)
}

CreateWorld()
{
EnterSingleplayer()
CreateNewWorld()
}

DeleteAndCreateWorld()
{
EnterSingleplayer()
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, {enter}
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, {enter}
CreateNewWorld()
}

CreateNewWorld()
{
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, `t
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
      if (worldName = "")
      {
         ControlSend, ahk_parent, {BackSpace}
      }
      else
      {
         ControlSend, ahk_parent, %worldName%
      }
      SetKeyDelay, %keyDelay%
   }
}
if (countAttempts = "Yes")
{
   FileRead, WorldNumber, SSG_1_16.txt
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
      SetKeyDelay, 1
      ControlSend, ahk_parent, %WorldNumber%
      SetKeyDelay, %keyDelay%
   }
}
ControlSend, ahk_parent, `t
if (difficulty = "Hardcore")
{
  ControlSend, ahk_parent, {enter}
}
ControlSend, ahk_parent, `t
if ((difficulty != "Normal") && (difficulty != "Hardcore")) ; Hard, Peaceful, or Easy
{
  ControlSend, ahk_parent, {enter}
  if (difficulty != "Hard") ; Peaceful or Easy
  {
    ControlSend, ahk_parent, {enter}
    if (difficulty != "Peaceful") ; Easy
    {
      ControlSend, ahk_parent, {enter}
      if (difficulty != "Easy") ; invalid difficulty
      {
        MsgBox, Difficulty entered is invalid. Please check your spelling and enter a valid difficulty. Options are "Peaceful" "Easy" "Normal" "Hard" or "Hardcore"
	ExitApp
      }
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
ControlSend, ahk_parent, {enter}
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, `t
ControlSend, ahk_parent, `t
if WinActive("Minecraft")
{
   SendInput, %SEED%
}
else
{
   SetKeyDelay, 1
   ControlSend, ahk_parent, %SEED%
   SetKeyDelay, %keyDelay%
}
if WinActive("Minecraft")
{
   Send, +`t
}
else
{
   ControlSend, ahk_parent, {Shift down}{Tab}{Shift up}
}
if WinActive("Minecraft")
{
   Send, +`t
}
else
{
   ControlSend, ahk_parent, {Shift down}{Tab}{Shift up}
}
ControlSend, ahk_parent, {enter}
}

ExitWorld()
{
   Send, {Esc}+{Tab}{Enter} 
}

SetKeyDelay , %keyDelay%

#IfWinActive, Minecraft ; Ensure Minecraft is the active window.
{
PgUp:: ; This is where the keybind for (re)creating an SSG world is set.
   WinGetPos, X, Y, W, H, Minecraft
   WinGetActiveTitle, Title
   IfNotInString Title, player ; Determine if we are already in a world.
      CreateWorld()
   else {
      ExitWorld()
      Loop {
         IfWinActive, Minecraft 
         {
            PixelSearch, Px, Py, 0, 0, W, H, 0xADAFB7, 0, Fast ; Waits to make sure we have properly exited the world.
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

PgDn:: ; This is where the keybind for (re)creating an SSG world and deleting the previous one is set.
   WinGetPos, X, Y, W, H, Minecraft
   WinGetActiveTitle, Title
   IfNotInString Title, player ; Determine if we are already in a world.
      DeleteAndCreateWorld()
   else {
      ExitWorld()
      Loop {
         IfWinActive, Minecraft 
         {
            PixelSearch, Px, Py, 0, 0, W, H, 0xADAFB7, 0, Fast ; Waits to make sure we have properly exited the world.
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

Home::
   ExitWorld()
return

End::
   Perch()
return
}


