

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance Force
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global savesDirectories := ["C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.17.1 multi 1\.minecraft\saves", "C:\Users\prana\AppData\Roaming\mmc-stable-win32\MultiMC\instances\1.17.1 multi 2\.minecraft\saves"]
global screenDelay := 100 ; Change this value to increase/decrease the number of time (in milliseconds) that each world creation screen is held for. For your run to be verifiable, each of the three screens of world creation must be shown.
global worldListWait := 200 ; The macro will wait for the world list screen to show before proceeding, but sometimes this feature doesn't work, especially if you use fullscreen, and always if you're tabbed out during this part.
                            ; In that case, this number (in milliseconds) defines the hard limit that it will wait after clicking on "Singleplayer" before proceeding.
                            ; This number should basically just be a little longer than your world list screen showing lag.

global timerReset := "NumPad0" ; hotkey for resetting timer to 0

global difficulty := "Normal" ; Set difficulty here. Options: "Peaceful" "Easy" "Normal" "Hard" "Hardcore"
global SEED := "-3294725893620991126" ; Default seed is the current Any% SSG 1.16+ seed, you can change it to whatever seed you want (will not do anything if doing rsg).

global countAttempts := "No" ; Change this to "Yes" if you would like the world name to include the attempt number, otherwise, keep it as "No"
                             ; The script will automatically create a text file to track your attempts starting from 1, but if you already have some attempts,
                             ; you can make a file called SSG_1_16.txt and put the number your attempts there. You can change that file whenever you want if the number ever gets messed up.
global worldName := "New World" ; you can name the world whatever you want, put the name inside the quotation marks.
                                ; If you selected "Yes" in the above option to counting attempts, this name will be the prefix.
                                ; For example, if you leave this as "New World" and you're on attempt 343, then the world will be named "New World343"
                                ; To just show the attempt number, change this variable to ""

global previousWorldOption := "delete" ; What to do with the previous world (either "delete" or "move" or "keep".) when the Page Down hotkey is used. If it says "move" then worlds will be moved to a folder called oldWorlds in your .minecraft folder. This does not apply to worlds whose files start with an "_" (without the quotes). If it says "keep" then it will not do anything
global inputMethod := "key" ; either "click" or "key" (click is theoretically faster but kinda experimental at this point and may not work properly depending on your resolution)
global fullscreenOnLoad = "No" ; change this to "Yes" if you would like the macro ensure that you are in fullscreen mode when the world is ready (a little experimental so I would recommend not using this in case of verification issues)
global unpauseOnSwitch := "No" ; change this to "Yes" if you would like the macro to automatically unpause when you switch to the next instance

; Autoresetter use:
;   1) By default, the autoresetter will reset all spawns outside of the set radius of the set focal point and will alert you of any spawns inside or equal to the set radius of the set focal point.
;   2) If there are only a few spawns that you're going to reset, create a file (in same folder as this script) called blacklist.txt and set the autoresetter radius to something very large like 1000.
;   3) If there are only a few spawns that you're going to play, crate a file (in same folder as this script) called whitelist.txt and set the autoresetter radius to a negative number like -1.
;   4) You can also use the blacklist and whitelist features in combination with each other and in combination with the radius.
;      For example, if the radius is mostly good but some spawns within it put you in like a hole, you can blacklist those spawns.
;      Apply the inverse concept for a whitelist.
;   5) In your blacklist.txt and/or whitelist.txt, each line should be of the following format:
;      X1,Z1;X2,Z2
;      Those coordinates should be opposite corners of a rectangle. Any spawns within that rectangle will be automatically counted as a good spawn if that rectangle was obtained from whitelist.txt.
;      Similarly, if that rectangle is obtained from blacklist.txt, any spawns within that rectangle will be resetted automatically. The whitelist is consulted first, the blacklist second, and the radius last.
;   6) If the autoresetter gives you a spawn that you don't like, you can add it to the blacklist by pressing Ctrl B (the same thing you would press to bold text).
;      It will blacklist the most recent spawn of the active instance, so keep that in mind when pressing Ctrl B.
;   7) Because of this feature, I recommend starting out with a higher radius than you would need, then just add bad spawns to the blacklist.

; Autoresetter Options:
global doAutoResets := "Yes" ; "Yes" or "No" for whether or not to run the autoresetter based on spawns
; The autoresetter will automatically reset if your spawn is greater than a certain number of blocks away from a certain point (ignoring y)
global centerPointX := 162.7 ; this is the x coordinate of that certain point (by default it's the x coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global centerPointZ := 194.5 ; this is the z coordinate of that certain point (by default it's the z coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global radius := 13 ; if this is 10 for example, the autoresetter will not reset if you are within 10 blocks of the point specified above. Set this smaller for better spawns but more resets
; if you would only like to reset the blacklisted spawns, then just set this number really large (1000 should be good enough), and if you would only like to play out whitelisted spawns, then just make this number negative
global message := "" ; what message will pop up when a good spawn is found (if you don't want a message to pop up, change this to "")
global playSound := "No" ; "Yes" or "No" on whether or not to play that Windows sound when good seed is found. To play a custom sound, just save it as spawnready.mp3 in the same folder as this script.

getSavesDirectory()
{
   WinGet, thePID, PID, A
   OutputDebug, getting saves directory of PID number %thePID%
   if (numInstances > 1)
   {
      OutputDebug, have to select saves directory from PID since we are on more than one instance
      OutputDebug, current PID: %thePID%
      Loop, %numInstances%
      {
         if (thePID = PIDs[A_Index])
         {
            OutputDebug, we are on instance %A_Index%
            savesDirectory := savesDirectories[A_Index]
         }
      }
      return (savesDirectory)
   }
   else
   {
      OutputDebug, only using one instance so saves directory is saves directory
      return (savesDirectories[1])
   }
}

fastResetModExist(savesDirectory)
{
   modsFolder := StrReplace(savesDirectory, "saves", "mods")
   Loop, Files, %modsFolder%\*.*, F
   {
      if(InStr(A_LoopFileName, "fast-reset"))
      {
         return True
      }
   }
}

WaitForHost(savesDirectory)
{
   logFile := StrReplace(savesDirectory, "saves", "logs\latest.log")
   numLines := 0
   Loop, Read, %logFile%
   {
      numLines += 1
   }
   openedToLAN := False
   startTime := A_TickCount
   while (!openedToLAN)
   {
      OutputDebug, reading log file
      if ((A_TickCount - startTime) > 5000)
      {
         OutputDebug, open to lan timed out
         openedToLAN := True
      }
      Loop, Read, %logFile%
      {
         if ((A_TickCount - startTime) > 5000)
         {
            OutputDebug, open to lan timed out
            openedToLAN := True
         }
         if ((numLines - A_Index) < 2)
         {
            OutputDebug, %A_LoopReadLine%
            if (InStr(A_LoopReadLine, "[CHAT] Local game hosted on port"))
            {
               OutputDebug, found the [CHAT] Local game hosted on port
               openedToLAN := True
            }
         }
      }
   }
}

Perch()
{
   WinGet, thePID, PID, A
   savesDirectory := getSavesDirectory()
   SetKeyDelay, 1
   if (version = 17)
   {
      OutputDebug, 1.17 perch
      Send, {Esc} ; pause
      ShiftTab(thePID, 2)
      if (fastResetModExist(savesDirectory))
      {
         ShiftTab(thePID, 1)
      }
      Send, {enter} ; open to LAN
      Send, {tab}{tab}{enter} ; cheats on
      Send, `t
      Send, {enter} ; open to LAN
      WaitForHost(savesDirectory)
      Send, /
      Sleep, 70
      SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
      Send, {enter}
   }
   else
   {
      OutputDebug, 1.16 perch
      Send, {Esc} ; pause
      ShiftTab(thePID, 2)
      if (fastResetModExist(savesDirectory))
      {
         ShiftTab(thePID, 1)
      }
      Send, {enter} ; open to LAN
      ShiftTab(thePID, 1)
      Send, {enter} ; cheats on
      Send, `t
      Send, {enter} ; open to LAN
      WaitForHost(savesDirectory)
      Send, /
      Sleep, 70
      SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
      Send, {enter}
   }
   SetKeyDelay, 1
}

global numInstances = savesDirectories.MaxIndex()
OutputDebug, %numInstances% instances being used
Loop, %numInstances%
	
global GUIscale := 0
getGUIscale(savesDirectory) ;used on script startup
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   if (version = 16)
      FileReadLine, guiScaleLine, %optionsFile%, 26
   else
      FileReadLine, guiScaleLine, %optionsFile%, 29
   if (InStr(guiScaleLine, 4) or InStr(guiScaleLine, 0))
   {
      GUIscale := 4
      return 4
   }
   else if (InStr(guiScaleLine, 3))
   {
      GUIscale := 3
      return 3
   }
   else
      return 0
}

DeletePIDsFile()
{
   FileSetAttrib, -R, PIDs.txt
   FileDelete, PIDs.txt
   if (FileExist("PIDs.txt"))
      OutputDebug, file still not deleted for some reason
}

global version = getVersion(savesDirectories[1])
OutputDebug, we are on 1.%version%
getVersion(savesDirectory)
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, versionLine, %optionsFile%, 1
   arr := StrSplit(versionLine, ":")
   dataVersion := arr[2]
   if (dataVersion > 2600)
      return (17)
   else
      return (16)
}
Loop, %numInstances%
{
   if ((!FileExist(savesDirectories[A_Index])) or (!InStr(savesDirectories[A_Index], "\saves")))
   {
      MsgBox, Your saves directory for instance %A_Index% is invalid. Right click on the script file, click edit script, and put the correct saves directory, then save the script and run it again.
      ExitApp
   }
}
if ((previousWorldOption != "move") and (previousWorldOption != "delete") and (previousWorldOption != "keep"))
{
   MsgBox, Choose a valid option for what to do with the previous world. Go to the Options section of this script and choose either "move" or "delete" or "keep" after the words "global previousWorldOption := "
   ExitApp
}
if ((difficulty != "Peaceful") and (difficulty != "Easy") and (difficulty != "Normal") and (difficulty != "Hard") and (difficulty != "Hardcore"))
{
   MsgBox, Difficulty entered is invalid. Please check your spelling and enter a valid difficulty. Options are "Peaceful" "Easy" "Normal" "Hard" or "Hardcore"
   ExitApp
}
if ((inputMethod != "key") and (inputMethod != "click"))
{
   MsgBox, Choose a valid option for what input method to use. Go to the Options section of this script and choose either "key" or "click" after the words "global inputMethod := "
   ExitApp
}
if ((!getGUIscale(savesDirectories[1])) && (inputMethod != "key"))
{
   MsgBox, Your GUI scale is not supported with the click macro. Either change your GUI scale to 0, 3, or 4, or change the input method to "key". Then run the script again.
   ExitApp
}
if ((fullscreenOnLoad != "Yes") and (fullscreenOnLoad != "No"))
{
   MsgBox, Choose a valid option for whether or not to fullscreen Minecraft when the load is complete. Go to the Options section of this script and choose either "Yes" or "No" after the words "global fullscreenOnLoad := "
   ExitApp
}
if ((unpauseOnSwitch != "Yes") and (unpauseOnSwitch != "No"))
{
   MsgBox, Choose a valid option for whether or not to unpause on instance switch. Go to the Options section of this script and choose either "Yes" or "No" after the words "global unpauseOnSwitch := "
   ExitApp
}

getMostRecentFile(savesDirectory)
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

PIDFileCheck()
{
   lineCounter = 0
   willNeedToSetUpPIDs := False
   Loop, Read, PIDs.txt
   {
      lineCounter += 1
      OutputDebug, the PID it read is %A_LoopReadLine%
      WinGetTitle, Title, ahk_pid %A_LoopReadLine%
      if (!InStr(Title, "Minecraft"))
      {
         OutputDebug, PID not found
         willNeedToSetUpPIDs := True
      }
      else
      {
         PIDs.push(A_LoopReadLine)
         thePID := PIDs[lineCounter]
         OutputDebug, PID number %thePID% was found
      }
   }
   if (lineCounter != numInstances)
   {
      OutputDebug, line counter is %lineCounter%
      OutputDebug, number of instances is %numInstances%
      willNeedToSetUpPIDs := True
   }
   if (willNeedToSetUpPIDs)
   {
      OutputDebug, setting up PIDs
      PIDs := []
      SetupPIDs()
   }
   else
      OutputDebug, all PIDs are good and everything and all that
}

SetupPIDs()
{
   if (FileExist("PIDs.txt"))
   {
      OutputDebug, the file exists
      DeletePIDsFile()
   }
   Loop, %numInstances%
   {
      getPID(A_Index)
   }
   if (numInstances > 1)
   {
      MsgBox, Close this message and you're good to go.
   }
}

getPID(n)
{
   MsgBox, Close this message, click on Instance %n%, and press the F key after you have clicked on that instance.
   Loop
   {
      if GetKeyState("F", "P")
      {
         WinGetActiveTitle, title
         if (InStr(title, "Minecraft"))
         {
            WinGet, thePID, PID, A
            if (n > 1)
            {
               m := n - 1
               Loop, %m%
               {
                  PIDcheck := PIDs[A_Index]
                  if (PIDcheck = thePID)
                  {
                     MsgBox, You clicked on the same window for Instance %n% as you did for Instance %A_Index%. Close this message to start over.
                     Reload
                  }
               }
            }
            FileAppend, %thePID%`n, PIDs.txt
            PIDs.Push(thePID)
            OutputDebug, wrote PID number %thePID% to the file and appended it to the array.
            return (thePID)
         }
         else
            MsgBox, This is not a Minecraft window. Close this message, click on Instance %n%, and press the P key after you have clicked on that instance.
      }
   }
}

EnterSingleplayer(n)
{
	thePID := PIDs[n]
	Sleep, %screenDelay%
	if ((inputMethod = "key") or (!WinActive("ahk_pid" thePID)))
	{
		SetKeyDelay, 0
		ControlSend, ahk_parent, `t, ahk_pid %thePID%
		ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
		SetKeyDelay, 1
	}
	else
	{
		if (GUIscale = 4)
			MouseClick, L, W * 963 // 1936, H * 515 // 1056, 1
		else
			MouseClick, L, W * 963 // 1936, H * 460 // 1056, 1
	}
	if (previousWorldOption != "keep")
	{
		lastWorld := getMostRecentFile(savesDirectories[n])
		DeleteOrMove(lastWorld)
	}
   states[n] := "world list"
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

WorldListScreen(n)
{
	thePID := PIDs[n]
   if ((inputMethod = "key") or (!WinActive("ahk_pid" thePID)))
   {
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}, ahk_pid %thePID%
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
      SetKeyDelay, 1
   }
   else
   {
      Sleep, %screenDelay%
      WinGetPos, X, Y, W, H, Minecraft
      if (GUIscale = 4)
         MouseClick, L, W * 1282 // 1936, H * 879 // 1056, 1
      else
         MouseClick, L, W * 1200 // 1936, H * 935 // 1056, 1
   }
   states[n] := "create new world"
}

global mode := "SSG"

CreateNewWorldScreen(n)
{
	thePID := PIDs[n]
	savesDirectory := savesDirectories[n]
   NameWorld(thePID)
   if ((inputMethod = "key") or (!WinActive("ahk_pid" thePID)))
   {
      SetKeyDelay, 0
      if (difficulty = "Normal")
      {
         ControlSend, ahk_parent, {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}, ahk_pid %thePID%
      }
      else
      {
         ControlSend, ahk_parent, `t, ahk_pid %thePID%
         if (difficulty = "Hardcore")
         {
            ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
         }
         ControlSend, ahk_parent, `t, ahk_pid %thePID%
         if (difficulty != "Hardcore")
         {
            ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
            if (difficulty != "Hard")
            {
               ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
               if (difficulty != "Peaceful")
               {
                  ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
               }
            }
         }
         if (difficulty != "Hardcore")
         {
            ControlSend, ahk_parent, {Tab}{Tab}, ahk_pid %thePID%
         }
         ControlSend, ahk_parent, {Tab}{Tab}, ahk_pid %thePID%
      }
      if (mode = "RSG")
         ControlSend, ahk_parent, {Tab}, ahk_pid %thePID%
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
      SetKeyDelay, 1
   }
   else
   {
      WinGetPos, X, Y, W, H, Minecraft
      if (difficulty = "Hardcore")
      {
         if (GUIscale = 4)
         {
            if (InFullscreen(savesDirectory))
               MouseClick, L, W * 653 // 1936, H * 450 // 1056, 1
            else
               MouseClick, L, W * 653 // 1936, H * 480 // 1056, 1
         }
         else
         {
            MouseClick, L, W * 735 // 1936, H * 350 // 1056, 1
         }
      }
      else if (difficulty != "Normal")
      {
         if (GUIscale = 4)
         {
            if (InFullscreen(savesDirectory))
               MouseClick, L, W * 1303 // 1936, H * 450 // 1056, 1
            else
               MouseClick, L, W * 1303 // 1936, H * 480 // 1056, 1
         }
         else
         {
            MouseClick, L, W * 1200 // 1936, H * 350 // 1056, 1
         }
         if (difficulty != "Hard")
         {
            if (GUIscale = 4)
            {
               if (InFullscreen(savesDirectory))
                  MouseClick, L, W * 1303 // 1936, H * 450 // 1056, 1
               else
                  MouseClick, L, W * 1303 // 1936, H * 480 // 1056, 1
            }
            else
            {
               MouseClick, L, W * 1200 // 1936, H * 350 // 1056, 1
            }
            if (difficulty != "Peaceful")
            {
               if (GUIscale = 4)
               {
                  if (InFullscreen(savesDirectory))
                     MouseClick, L, W * 1303 // 1936, H * 450 // 1056, 1
                  else
                     MouseClick, L, W * 1303 // 1936, H * 480 // 1056, 1
               }
               else
               {
                  MouseClick, L, W * 1200 // 1936, H * 350 // 1056, 1
               }
            }
         }
      }
      Sleep, %screenDelay%
      if (mode = "SSG")
      {
         if (GUIscale = 4)
         {
            if (InFullscreen(savesDirectory))
               MouseClick, L, W * 1295 // 1936, H * 780 // 1056, 1
            else
               MouseClick, L, W * 1295 // 1936, H * 830 // 1056, 1
         }
         else
         {
            MouseClick, L, W * 1200 // 1936, H * 600 // 1056, 1
         }
      }
      else
      {
         if (GUIscale = 4)
            MouseClick, L, W * 653 // 1936, H * 978 // 1056, 1
         else
            MouseClick, L, W * 725 // 1936, H * 1012 // 1056, 1
      }
   }
   states[n] := "more options"
}

MoreWorldOptionsScreen(n)
{
	thePID := PIDs[n]
   if ((inputMethod = "key") or (!WinActive("ahk_pid" thePID)))
   {
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}, ahk_pid %thePID%
      SetKeyDelay, 1
      Sleep, 1
      InputSeed(thePID)
      Sleep, 1
      SetKeyDelay, 0
      ControlSend, ahk_parent, {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}, ahk_pid %thePID%
      Sleep, %screenDelay%
      ControlSend, ahk_parent, {enter}, ahk_pid %thePID%
      SetKeyDelay, 1
   }
   else
   {
      WinGetPos, X, Y, W, H, Minecraft
      if (GUIscale = 4)
         MouseClick, L, W * 963 // 1936, H * 310 // 1056, 1
      else
         MouseClick, L, W * 963 // 1936, H * 225 // 1056, 1
      InputSeed(thePID)
      Sleep, %screenDelay%
      if (GUIscale = 4)
         MouseClick, L, W * 653 // 1936, H * 978 // 1056, 1
      else
         MouseClick, L, W * 725 // 1936, H * 1012 // 1056, 1
   }
   states[n] := "loading screen"
}

NameWorld(thePID)
{
   if (worldName != "New World")
   {
      if WinActive("ahk_pid" thePID)
      {
         SendInput, ^a
         Sleep, 1
         SendInput, %worldName%
         Sleep, 1
      }
      else
      {
         ControlSend, ahk_parent, {Control down}, ahk_pid %thePID%
         ControlSend, ahk_parent, a, ahk_pid %thePID%
         ControlSend, ahk_parent, {Control up}, ahk_pid %thePID%
         ControlSend, ahk_parent, {BackSpace}, ahk_pid %thePID%
         ControlSend, ahk_parent, %worldName%, ahk_pid %thePID%
      }
   }
   if (countAttempts = "Yes")
   {
      if (mode = "SSG")
         FileRead, WorldNumber, SSG_1_16.txt
      else
         FileRead, WorldNumber, RSG_1_16.txt
      if (ErrorLevel)
         WorldNumber = 0
      else
      {
         if (mode = "SSG")
            FileDelete, SSG_1_16.txt
         else
            FileDelete, RSG_1_16.txt
      }
      WorldNumber += 1
      if (mode = "SSG")
         FileAppend, %WorldNumber%, SSG_1_16.txt
      else
         FileAppend, %WorldNumber%, RSG_1_16.txt
      if WinActive("ahk_pid" thePID)
      {
         Sleep, 1
         SendInput, %WorldNumber%
         Sleep, 1
      }
      else
      {
         ControlSend, ahk_parent, %WorldNumber%, ahk_pid %thePID%
      }
   }
}

InputSeed(thePID)
{
   if WinActive("ahk_pid" thePID)
   {
      SendInput, %SEED%
   }
   else
   {
      ControlSend, ahk_parent, %SEED%, ahk_pid %thePID%
   }
}

GoodSpawn(n)
{
   /*
   array1 := StrSplit(Clipboard, " ")
   xCoord := array1[7]
   zCoord := array1[9]
   */
   xCoord := xCoords[n]
   zCoord := zCoords[n]
   OutputDebug, spawn is %xCoord%, %zCoord%
   xDisplacement := xCoord - centerPointX
   zDisplacement := zCoord - centerPointZ
   distance := Sqrt((xDisplacement * xDisplacement) + (zDisplacement * zDisplacement))
   OutputDebug, distance of %distance%
   distances[n] := distance
   if (inList(xCoord, zCoord, "whitelist.txt"))
   {
      OutputDebug, in whitelist
      return True
   }
   if (inList(xCoord, zCoord, "blacklist.txt"))
   {
      OutputDebug, in blacklist
      return False
   }
   if (distance <= radius)
      return True
   else
      return False
}

inList(xCoord, zCoord, fileName)
{
   if (FileExist(fileName))
   {
      Loop, read, %fileName%
      {
         arr0 := StrSplit(A_LoopReadLine, ";")
         corner1 := arr0[1]
         corner2 := arr0[2]
         arr1 := StrSplit(corner1, ",")
         arr2 := StrSplit(corner2, ",")
         X1 := arr1[1]
         Z1 := arr1[2]
         X2 := arr2[1]
         Z2 := arr2[2]
         if ((((xCoord <= X1) && (xCoord >= X2)) or ((xCoord >= X1) && (xCoord <= X2))) and (((zCoord <= Z1) && (zCoord >= Z2)) or ((zCoord >= Z1) && (zCoord <= Z2))))
            return True
      }
   }
   return False
}

SwitchTo(instanceNum)
{
   WinActivate, OBS
   WinActivate, DebugView
   thePID := PIDs[instanceNum]
   WinActivate, ahk_pid %thePID%
   states[instanceNum] := "running"
   
}

InFullscreen(savesDirectory)
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   FileReadLine, fullscreenLine, %optionsFile%, 17
   if (InStr(fullscreenLine, "true"))
      return 1
   else
      return 0
}

AlertUser(n)
{
	if (playSound = "Yes")
	{
		if (FileExist("spawnready.mp3"))
			SoundPlay, spawnready.mp3
		else
			SoundPlay *16
	}
	if (message != "")
		MsgBox, %message%
	if ((fullscreenOnLoad = "Yes") && !(InFullscreen(savesDirectories[n])))
		ControlSend, ahk_parent, {F11}, ahk_pid %thePID%
	Send, {%timerReset%}
	if (unpauseOnSwitch = "Yes")
	{
		Send, {Esc}
	}
}

global keepLooping
MainLoop()
{
	keepLooping := true
	while (keepLooping)
	{
		if (playerState = "need spawn")
		{
			instancesWithGoodSpawns := []
			for r, state in states
			{
				if (state = "good spawn")
				{
					OutputDebug, instance %r% has a good spawn
					instancesWithGoodSpawns.Push(r)
				}
			}
			bestSpawn := -1
			counter = 0
			for p, q in instancesWithGoodSpawns
			{
				counter += 1
				if (counter = 1)
				{
					minDist := distances[q]
					bestSpawn := q
				}
				theDistance := distances[q]
				OutputDebug, minimum distance is %minDist%, comparing with %theDistance%
				if (theDistance <= minDist)
				{
					minDist := distances[q]
					bestSpawn := q
				}
			}
			if (counter > 0)
			{
				OutputDebug, best spawn is on instance %bestSpawn% with a distance of %minDist%
				SwitchTo(bestSpawn)
				AlertUser(bestSpawn)
				playerState := "running"
			}
			else
			{
				;OutputDebug, no spawns available
			}
		}
		for i, state in states
		{
			if (state = "title")
			{
				OutputDebug, instance %i% is on the title screen, entering singleplayer
				EnterSingleplayer(i)
			}
			else if (state = "world list")
			{
				OutputDebug, instance %i% is in the world list screen, pressing create new world
				WorldListScreen(i)
			}
			else if (state = "create new world")
			{
				OutputDebug, instance %i% is in the create new world screen, selecting difficulty and pressing more world options
				CreateNewWorldScreen(i)
			}
			else if (state = "more options")
			{
				OutputDebug, instance %i% is in the more world options screen, inputting seed and creating world
				MoreWorldOptionsScreen(i)
			}
			else if (state = "loading screen")
			{
				thePID := PIDs[i]
				WinGetTitle, Title, ahk_pid %thePID%
				if ((InStr(Title, "player")) or (InStr(Title, "Instance")))
				{
					OutputDebug, instance %i% has changed title, pausing
					ControlSend, ahk_parent, {Esc}, ahk_pid %thePID%
					states[i] := "joined"
				}
			}
			else if (state = "joined")
			{
				OutputDebug, instance %i% has joined the world, getting spawn point
				logFile := StrReplace(savesDirectories[i], "saves", "logs\latest.log")
				numLines := 0
				Loop, Read, %logFile%
				{
					numLines += 1
				}
				Loop, Read, %logFile%
				{
					if ((numLines - A_Index) <= 15)
					{
						;OutputDebug, %A_LoopReadLine%
						if (InStr(A_LoopReadLine, "logged in with entity id"))
						{
							OutputDebug, found the needed line
							spawnLine := A_LoopReadLine
							array1 := StrSplit(spawnLine, " at (")
							xyz := array1[2]
							array2 := StrSplit(xyz, ", ")
							xCoord := array2[1]
							zCooord := array2[3]
							array3 := StrSplit(zCooord, ")")
							zCoord := array3[1]
							xCoords[i] := xCoord
							zCoords[i] := zCoord
							states[i] := "need spawn checked"
						}
					}
				}
			}
			else if (state = "need spawn checked")
			{
				OutputDebug, instance %i% needs its spawn checked
				if (GoodSpawn(i))
				{
					OutputDebug, instance %i% is a good spawn
					states[i] := "good spawn"
				}
				else
				{
					OutputDebug, instance %i% is a bad spawn
					states[i] := "bad spawn"
				}
			}
			else if (state = "bad spawn")
			{
				OutputDebug, instance %i% has a bad spawn so the world is exiting
				ExitFromPause(i)
			}
			else if (state = "exiting screen")
			{
				savesDirectory := savesDirectories[i]
				lastWorld := getMostRecentFile(savesDirectory)
				lockFile := lastWorld . "\session.lock"
				FileRead, sessionlockfile, %lockFile%
				if (ErrorLevel = 0)
				{
					OutputDebug, reached title screen
					states[i] := "title"
				}
			}
			else if (state = "paused")
			{
				OutputDebug, instance %i% is paused so world is exiting
				ExitFromPause(i)
			}
		}
	}
}

ExitFromPause(n)
{
	thePID := PIDs[n]
	ShiftTab(thePID)
	ControlSend, ahk_parent, {Enter}, ahk_pid %thePID%
	states[n] := "exiting screen"
}

ShiftTab(thePID, n := 1)
{
   if WinActive("ahk_pid" thePID)
   {
      Loop, %n%
      {
         Send, +`t
      }
   }
   else
   {
      ControlSend, ahk_parent, {Shift down}, ahk_pid %thePID%
      Loop, %n%
      {
         ControlSend, ahk_parent, {Tab}, ahk_pid %thePID%
      }
      ControlSend, ahk_parent, {Shift up}, ahk_pid %thePID%
   }
}

PauseOnLostFocus(savesDirectory) ;used on script startup
{
   optionsFile := StrReplace(savesDirectory, "saves", "options.txt")
   if (version = 16)
      FileReadLine, optionLine, %optionsFile%, 45
   else
      FileReadLine, optionLine, %optionsFile%, 48
   if (InStr(optionLine, "true"))
      return 1
   else
      return 0
}

Test()
{
	numIts := 3
	Loop, %numIts%
		Send, g
}

ExitCurrentWorld()
{
	Send, {Esc}+{Tab}{Enter}
	currentInst := getActiveInstance()
	states[currentInst] := "exiting screen"
}

getActiveInstance()
{
	WinGet, thePID, PID, A
	Loop, %numInstances%
	{
		if (thePID = PIDs[A_Index])
        {
			OutputDebug, we are on instance %A_Index%
			return (A_Index)
        }
    }
}

AddToBlacklist()
{
	t := getActiveInstance
   xCoord := xCoords[t]
   zCoord := zCoords[t]
   OutputDebug, blacklisting %xCoord%, %zCoord%
   theString := xCoord . "," . zCoord . ";" . xCoord . "," . zCoord
   if (!FileExist("blacklist.txt"))
      FileAppend, %theString%, blacklist.txt
   else
      FileAppend, `n%theString%, blacklist.txt
}

SetDefaultMouseSpeed, 0
SetMouseDelay, 0
SetKeyDelay , 1
SetWinDelay, 1
global PIDs := [] ;GetAllPIDs()
PIDFileCheck()
global states := []
global xCoords := []
global zCoords := []
global distances := []
global playerState := "need spawn"
for s, the_PID in PIDs
{
	OutputDebug, PID number %s% is %the_PID%
	saves_Directory := savesDirectories[s]
	last_World := getMostRecentFile(saves_Directory)
	lock_File := last_World . "\session.lock"
	Loop
	{
		FileRead, session_lockfile, %lock_File%
		Sleep, 10
		if (ErrorLevel = 0)
		{
			OutputDebug, instance %s% is on the title screen
			states.Push("title")
			break
		}
		WinGetTitle, theTitle, ahk_pid %the_PID%
		if (InStr(theTitle, "player") or InStr(theTitle, "Instance"))
		{
			OutputDebug, instance %s% is paused
			states.Push("paused")
			break
		}
	}
	xCoords.Push(0)
	zCoords.Push(0)
	distances.Push(0)
}
for j, the_State in states
{
	OutputDebug, instance %j% is in state %the_State%
}
for k, saves_directory in savesDirectories
{
	if (PauseOnLostFocus(saves_directory))
	{
		MsgBox, Instance %k% has pause on lost focus enabled. Disable this feature by pressing F3 + P in-game, then start the script again.
		ExitApp
	}
}
MsgBox, Close this message and the resetting will start
MainLoop()



#IfWinActive, Minecraft
{
	PgDn::
		ExitCurrentWorld()
		b := getActiveInstance()
		the_pid := PIDs[b]
		if (InFullscreen(savesDirectories[b]))
			ControlSend, ahk_parent, {F11}, ahk_pid %the_pid%
		playerState := "need spawn"
	return
	
	F5::Reload
	
	Insert::
		Test()
	return
	
	^B:: ; This is where the keybind is set for adding a spawn to the blacklisted spawns.
		AddToBlacklist()
	return
	
	End:: ; This is where the keybind for opening to LAN and perching is set.
		Perch()
	return
}