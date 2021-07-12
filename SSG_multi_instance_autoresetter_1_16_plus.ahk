

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global numInstances := 4

global savesDirectory1 := "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.17\.minecraft\saves" ; input your minecraft saves directory here. It will probably start with "C:\Users..." and end with "\minecraft\saves"
global savesDirectory2 := "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.17 Instance 2\.minecraft\saves" ; same thing here, if you're not using multiple instances, then it doesn't matter what this is
global savesDirectory3 := "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.17 Instance 3\.minecraft\saves" ; same thing here, if you're not using more than 2 instances, then it doesn't matter what this is
global savesDirectory4 := "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.17 Instance 4\.minecraft\saves" ; same thing here, if you're not using more than 3 instances, then it doesn't matter what this is


global keepLooping
MainLoop()
{
	keepLooping := true
	while (keepLooping)
	{
		Send, f
		Sleep, 100
	}
}

global states
getStates()
{
	Loop, %numInstances%
	{
	}
}

Test()
{
	numIts := 3
	Loop, %numIts%
		Send, g
}

;Insert::
	;getStates()
	;MainLoop()
;return

Insert::
	Test()
return