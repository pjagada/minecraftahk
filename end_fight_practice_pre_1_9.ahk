
#NoEnv
SetWorkingDir %A_ScriptDir%

; This script gives you items for a pre 1.9 end fight (presets from FinestPigeon) and sets the end portal block to teleport you to the end.
; Activate using Q. Scroll down to bottom and change the Q if you want.
; I wouldn't recommend using a letter that's actually found in one of the commands since that may cause problems.
; You can also substitue "Q" for "^f" for example to activate using control + f
; but this is a little finnicky as you have to release control + f really quickly otherwise it skips some items.
; You can try lowering the delay, but from my testing, you need like a little more than a tick between pressing "t" or "/" to open chat and the chat actually opening.
DELAY = 1
if DELAY
   SetKeyDelay , 60 ;
else {
   SendMode Input
}


GiveStuff()
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
   GiveStuff()
return
}

