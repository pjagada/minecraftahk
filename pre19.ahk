
#NoEnv
SetWorkingDir %A_ScriptDir%

; Activate using Q. Scroll down to bottom and change the Q if you want.
; I wouldn't recommend using a letter that's actually found in one of the commands since that may cause problems.
; You can also substitue "Q" for "^f" for example to activate using control + f
; but this is a little finnicky as you have to release control + f really quickly otherwise it skips some items.
; This script comes with delay enabled, with 70ms delay between keypresses
; To remove input delay, change the following line to DELAY = 0.
DELAY = 1
if DELAY
   SetKeyDelay , 60 ;
else {
   SendMode Input
}


GiveShit()
{
Send, /
SendInput, give @a stone_sword
Send, {enter}
Send, /
SendInput, give @a iron_pickaxe
Send, {enter}
Send, /
SendInput, give @a stone_shovel
Send, {enter}
Send, /
SendInput, give @a cooked_beef 64
Send, {enter}
Send, /
SendInput, give @a bed 2
Send, {enter}
Send, /
SendInput, give @a water_bucket
Send, {enter}
Send, /
SendInput, give @a bow
Send, {enter}
Send, /
SendInput, give @a leaves 64
Send, {enter}
Send, /
SendInput, give @a bed 5
Send, {enter}
Send, /
SendInput, give @a arrow 16
Send, {enter}
Send, /
SendInput, setblock ~ ~ ~ end_portal
Send, {enter}
}

#IfWinActive, Minecraft ; Ensure Minecraft is the active window.
{
Q:: ; Change the Q to whatever hotkey you want.
   GiveShit()
return
}


