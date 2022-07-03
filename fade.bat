@Echo off & Cls

 If not "%~1"=="" Goto:%1

REM See it at: https://youtu.be/ph3SYsXvz-M

Rem GetDelay routine gets a baseline of how many For /l iterations the pc executes per second
Rem which is used to define the starting value of the delay rate. This approach permits higher fps and finer fps control
Rem than tdiff, which is limited to centiseconds.

 If not exist "%TEMP%\%~n0_Delay.cmd" >"%TEMP%\%~n0_Delay.cmd" (
  Title 1st Run Setup - FPS Baseline 1
  Call:GetDelay D1
  Title 1st Run Setup - FPS Baseline 2
  Call:GetDelay D2
  Title 1st Run Setup - FPS Baseline 3
  Call:GetDelay D3
  Title 1st Run Setup - FPS Baseline 4
  Call:GetDelay D4
  (Title )
  Set /A "InitDelay=(D1+D2+D3+D4)/4"
  Call Echo(@Set /A InitDelay=%%InitDelay%%
  Echo(@Goto:Eof
 )

 Call "%TEMP%\%~n0_Delay.cmd"

 CHCP 65001 > nul

 If "!!"=="" (
 	Echo(Delayed Expansion must be disabled prior to starting %~n0
 	Exit /b 1
 )

 Call:TestVT || (
 	Echo(Virtual terminal sequences not supported
 	Exit /b 1
 )

REM macro used to implement relative frame intervals
 SET every="1/(((~(0-(frames %% #))>>31)&1)&((~((frames %% #)-0)>>31)&1))"

REM properties / initial values

 %= console dims, zero sprite array size and turn count =%	Set /A "Height=35","Width=140","Sprites=0","turn=0"
 %= Initial ForeGround and BackGround colors =%			Set "BG=10;10;10" & Set "FG=10;10;10"
 %= initail colors of sprite 1 substrings =%			Set /A "S1cR=50,Thrust=S1cR"

REM Sprite 1 rotor blade animation array, Starting frame, Array Size for modulo cycling and initial thruster character
 Set "R[1]=╔═╦═╗"
 Set "R[2]= ═╦═ "
 Set "R[3]=  ╬  "
 Set "R[4]= ═╦═ "
 Set "R[5]=╔═╦═╗"
 Set /A "bladesSTEP=1","bladesMOD=5"
 Set "Thruster=▼"

REM Sprite 2 animation array, Starting frame, Array Size for modulo cycling array
 Set "hunter[1]=%\E%[38;2;20;160;140m♦%\E%[38;2;180;;m♦♦%\E%[1B%\E%[1D♦%\E%[1B%\E%[3D%\E%7♦♦♦%\E%8%\E%[1A♦%\E%[38;5;145%\E%[48;2;150;120;50m"
 Set "hunter[2]=%\E%[38;2;180;;m♦%\E%[38;2;20;160;140m♦%\E%[38;2;180;;m♦%\E%[1B%\E%[1D♦%\E%[1B%\E%[3D%\E%7♦♦♦%\E%8%\E%[1A♦%\E%[38;5;140%\E%[48;2;150;120;50m☻"
 Set "hunter[3]=%\E%[38;2;180;;m♦♦%\E%[38;2;20;160;140m♦%\E%[38;2;180;;m%\E%[1B%\E%[1D♦%\E%[1B%\E%[3D%\E%7♦♦♦%\E%8%\E%[1A♦%\E%[38;5;135%\E%[48;2;150;120;50m☻"
 Set "hunter[4]=%\E%[38;2;180;;m♦♦♦%\E%[1B%\E%[1D%\E%[38;2;20;160;140m♦%\E%[38;2;180;;m%\E%[1B%\E%[3D%\E%7♦♦♦%\E%8%\E%[1A♦%\E%[38;5;130%\E%[48;2;150;120;50m☻"
 Set "hunter[5]=%\E%[38;2;180;;m♦♦♦%\E%[1B%\E%[1D♦%\E%[1B%\E%[3D%\E%7%\E%[38;2;20;160;140m♦%\E%[38;2;180;;m♦♦%\E%8%\E%[1A♦%\E%[38;5;125m%\E%[48;2;150;120;50m☻"
 Set "hunter[6]=%\E%[38;2;180;;m♦♦♦%\E%[1B%\E%[1D♦%\E%[1B%\E%[3D%\E%7♦%\E%[38;2;20;160;140m♦%\E%[38;2;180;;m♦%\E%8%\E%[1A♦%\E%[38;5;120m%\E%[48;2;150;120;50m☻"
 Set "hunter[7]=%\E%[38;2;180;;m♦♦♦%\E%[1B%\E%[1D♦%\E%[1B%\E%[3D%\E%7♦♦%\E%[38;2;20;160;140m♦%\E![38;2;180;;m%\E%8%\E%[1A♦%\E%[38;5;115m%\E%[48;2;150;120;50m☻"
 Set "hunter[8]=%\E%[38;2;180;;m♦♦♦%\E%[1B%\E%[1D♦%\E%[1B%\E%[3D%\E%7♦♦♦%\E%8%\E%[1A%\E%[38;2;20;160;140m♦%\E%[38;5;110m48;2;150;120;50m☻"
 Set /A "hunterSTEP=1","hunterMOD=8"

REM Patrol sprites String definition, animation array, Starting frame and Array Size for modulo cycling.
 Set "Patrollers[1]=╔╗%\E%[1B%\E%[2D╚╝"
 Set "Patrollers[2]=▄▄%\E%[1B%\E%[2D▀▀"
 Set "Patrollers[3]=◄►%\E%[1B%\E%[2D◄►"
 Set "Patrollers[4]=▀▀%\E%[1B%\E%[2D▄▄"
 Set "Patrollers[5]=▲▲%\E%[1B%\E%[2D▼▼"
 Set "Patrollers[6]=▀▄%\E%[1B%\E%[2D▀▄"
 Set /A "patrolSTEP=1","PatrolMOD=6"

 Call:DefSprite "!\E![38;2;255;153;51m!R[%%%%b]!\n!\E![38;2;!S1cR!;220;!s1cR!m╬!\E![96m{!\E![91m!\E![48;2;;160;140m☻!\E![96m!\E![48;2;!BG!m}!\E![38;2;!S1cR!;220;!s1cR!m╬\n!\E![33m▀!\E![48;2;!Thrust!;;m!\E![38;2;;;!Thrust!m!Thruster!!\E![48;2;!BG!m!\E![33m▀!\E![48;2;!Thrust!;;m!\E![38;2;;;!Thrust!m!Thruster!!\E![48;2;!BG!m!\E![33m▀" 5 5 3 5 "!S1cR!;220;!s1cR!" "!BG!"

 REM obsolete:hunter:╔═╗\n║!\E![33m!\E![48;2;80;60;m♦!\E![38;2;200;;m!\E![48;2;!BG!m║\n╚═╝
 Call:DefSprite "!hunter[%%%%d]!"		Height/2    Width/2-1 3 3 "200;;"     "!BG!"   2

 REM obsolete:patrol:╔╗\n╚╝
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2-2  Width/2-2 2 2 "!RandRR!;120;!randBB!" "!BG!" 3
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2+2  Width/2+2 2 2 "!RandRR!;140;!randBB!" "!BG!" 4
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2-4  Width/2-4 2 2 "!RandRR!;160;!randBB!" "!BG!" 3
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2+4  Width/2+4 2 2 "!RandRR!;180;!randBB!" "!BG!" 4
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2-6  Width/2-6 2 2 "!RandRR!;200;!randBB!" "!BG!" 3
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2+6  Width/2+6 2 2 "!RandRR!;220;!randBB!" "!BG!" 4
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2-8  Width/2-8 2 2 "!RandRR!;240;!randBB!" "!BG!" 3
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2+8  Width/2+8 2 2 "!RandRR!;220;!randBB!" "!BG!" 4
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2-10 Width/2-8 2 2 "110;!RandGG!;160"	  "!BG!" 3
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2+10 Width/2+8 2 2 "130;!RandGG!;160"	  "!BG!" 4
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2-12 Width/2-6 2 2 "150;!RandGG!;180"	  "!BG!" 3
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2+12 Width/2+6 2 2 "170;!RandGG!;180"	  "!BG!" 4
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2-14 Width/2-4 2 2 "190;!RandGG!;220"	  "!BG!" 3
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2+14 Width/2+4 2 2 "210;!RandGG!;220"	  "!BG!" 4
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2-16 Width/2-2 2 2 "230;!RandGG!;240"	  "!BG!" 3
 Call:DefSprite "!Patrollers[%%%%c]!"	Height/2+16 Width/2+2 2 2 "250;!RandGG!;240"	  "!BG!" 4

REM Control Key assignments.
 Set "kD=Right" & Set "k6=Right"
 Set "kA=Left"  & Set "k4=Left"
 Set "kW=Up"    & Set "k8=Up"
 Set "kS=Down"  & Set "k2=Down"
 Set "kP=Pause" & Set "Pause=1"

REM Define player sprite movement macros
 Set "Right=Set /A "1/((S1RB)/(S1X))" && Set /A "S1LX=S1X","S1LY=S1Y","S1X+=1" ||Set /A "S1LX=S1X","S1LY=S1Y""
 Set "Left= Set /A "1/(S1LB-S1X)"     && Set /A "S1LX=S1X","S1LY=S1Y","S1X-=1" ||Set /A "S1LX=S1X","S1LY=S1Y""
 Set "Up=   Set /A "1/(S1UB-S1Y)"     && Set /A "S1LX=S1X","S1LY=S1Y","S1Y-=1" ||Set /A "S1LX=S1X","S1LY=S1Y""
 Set "Down= Set /A "1/(S1BB/S1Y)"     && Set /A "S1LX=S1X","S1LY=S1Y","S1Y+=1" ||Set /A "S1LX=S1X","S1LY=S1Y""
 Set "Jump= Set /A "1/(S1BB/(S1Y+1))" || (Set /A "S1LX=S1X","S1LY=S1Y","S1Y-=10")"

REM Define non player sprite movement macros
 Set sRight=Set /A "1/(S%%iRB/S%%iX)" ^&^& Set /A "S%%iLX=S%%iX","S%%iLY=S%%iY","S%%iX+=1" ^|^|Set /A "S%%iLX=S%%iX","S%%iLY=S%%iY"
 Set sLeft= Set /A "1/(S%%iLB-S%%iX)" ^&^& Set /A "S%%iLX=S%%iX","S%%iLY=S%%iY","S%%iX-=1" ^|^|Set /A "S%%iLX=S%%iX","S%%iLY=S%%iY"
 Set sUp=   Set /A "1/(S%%iUB-S%%iY)" ^&^& Set /A "S%%iLX=S%%iX","S%%iLY=S%%iY","S%%iY-=1" ^|^|Set /A "S%%iLX=S%%iX","S%%iLY=S%%iY"
 Set sDown= Set /A "1/(S%%iBB/S%%iY)" ^&^& Set /A "S%%iLX=S%%iX","S%%iLY=S%%iY","S%%iY+=1" ^|^|Set /A "S%%iLX=S%%iX","S%%iLY=S%%iY"

 Setlocal EnableDelayedExpansion

 Echo(Survive^^^!
 Call:PlayMusic "%WINDIR%\Media\windows unlock.wav" 70

 Set "Title=Move: W A S D Quit: 'L'.  Turns Survived: ^!turn^!"

 Mode %Width%,%Height%
 Title %Title%
 Set /A "Delay=InitDelay","DelayReduce=InitDelay/50","DelayEnd=DelayReduce-1","frames=0","RandBB=!Random! %% 130 + 120","RandGG=!Random! %% 130 + 120","RandRR=!Random! %% 70 + 60"

 For /F "tokens=1,2,3 Delims=;" %%b in ("!bladesSTEP!;!PatrolSTEP!;!hunterSTEP!")Do Echo(%\E%[?25l%\E%[1;1H%\E%[48;2;!BG!m%\E%[38;2;!FG!m%\E%[2J%Sprite[1]%%Sprite[2]%%Sprite[3]%%Sprite[4]%%Sprite[5]%%Sprite[6]%%Sprite[7]%%Sprite[8]%%Sprite[9]%%Sprite[10]%%Sprite[11]%%Sprite[12]%%Sprite[13]%%Sprite[14]%%Sprite[15]%%Sprite[16]%%Sprite[17]%%Sprite[18]%

Rem Use control function as input to game via pipline.

 "%~F0" CONTROL W >"%temp%\%~n0_signal.txt" | "%~F0" GAME <"%temp%\%~n0_signal.txt"
 EXIT

 :GAME
 Setlocal EnableDelayedExpansion
 <nul Set /p "=%\E%[?25l"
 2> nul (				%= Suppress STDERR of condiitional equations =%
 	For /l %%. in () Do (	%= Enact Infinite Loop =%
			
		For /l %%# in (1 1 !Delay!) Do Rem %= Implement Delay Timing. =%

		%= If not game paused Increment frame and assign BG colors and ... =% 
		Set /A "1/(pause-2)", "frames+=1",    "BGRm=((S1Y+10)*100)/130","BGBm=((S4X+10)*100)/130" && (

			%= Every 10th frame Reduce Delay interval and recalculate speed percentage =%
          		Set /A !every:#=10! && Set /A "Delay-=(Delay/DelayReduce)","Speed=(DelayEnd*100)/Delay"

			%= Every 2nd frame ... =%
			Set /A !every:#=2! && (

				%= Return thruster character to original =%
				Set "Thruster=░"

				%= Modifiy BG S1 and Thrust colors + increment Enemy turn count =% %= Every Fourth frame cycle animation step of s1 blade rotation and patrol sprites =%
				Set /A "BGc+=5","S1cR+=1","thrust=!Random! %% 195 + 50","turn+=1",!every:#=4! && Set /A "bladesSTEP=bladesSTEP %%bladesMOD + 1","PatrolSTEP=PatrolSTEP %%!PatrolMOD! + 1","hunterSTEP=hunterSTEP %%!PatrolMOD! + 1"

    				%= Move sprites =%
				For /L %%i in (2 1 !Sprites!)Do 	%= Implement sprite behaviours =% (

					%= Sprite 2 Implement Hunter Behaviour. Hunter behaviour unique to prevent sprite overlap. If using multiple Hunters additional collision detection required =%
					If %%i LSS 3 (
						%= Sprite 2 is the only hunter sprite in this demo. =%
						If !S%%iY! GTR !S1Y! ( Set /A "S%%iYd=S%%iY-S1Y" )Else Set /A "S%%iYd=S1Y-S%%iY"
						If !S%%iX! GTR !S1X! ( Set /A "S%%iXd=S%%iX-S1Y" )Else Set /A "S%%iXd=S1X-S%%iX"
						If !S%%iX! GTR !S1X! Set "S%%iDir=3"
						If !S%%iYd! GTR !S%%iXd! (
							If !S%%iY! GTR !S1Y! Set "S%%iDir=1"
							If !S%%iY! LSS !S1Y! Set "S%%iDir=2"
						)Else (
							If !S%%iX! GTR !S1X! Set "S%%iDir=3"
							If !S%%iX! LSS !S1X! Set "S%%iDir=4"
						)

						If !S%%iDir! EQU 1 %sUp%
						If !S%%iDir! EQU 2 %sDown%
						If !S%%iDir! EQU 3 %sLeft%
						If !S%%iDir! EQU 4 %sRight%
					)

					%= Sprites 3+ example basic patrolling and implementation of group behaviour using arrays =%
					If %%i GEQ 3 (
						If !s%%iDir! EQU 3 If !S%%iX! NEQ !S%%iLB! ( Set /A "S%%iLX=S%%iX","S%%iX-=1" )Else Set "s%%iDir=4"
						If !s%%iDir! EQU 4 If !S%%iX! NEQ !S%%iRB! ( Set /A "S%%iLX=S%%iX","S%%iX+=1" )Else Set "s%%iDir=3"
					)

					%= Implementation of Bounding box collison test via Bitshifted Or algorithm. Assess the following conditions and trigger divide by zero error if no condition true =%
					%= Conditions =% %= If Base1 LSS Top2   =% %=     If Top1 GTR Base2       =% %=    If Right1 LSS Left2    =% %=    If Left1 GTR Right2     =%
					Set /A "1/(((((S1Y+(S1H-1))-S%%iY)>>31)&1)|((((S%%iY+(S%%iH-1))-S1Y)>>31)&1)|((((S1X+S1W)-(S%%iX+1))>>31)&1)|((((S%%iX+S%%iW)-1-S1X)>>31)&1))" || (

						%= Sprite is in Collision with S1 - player Sprite. Update screen with animations at desired animation step. =%
     						For /f "tokens=1,2,3 Delims=;" %%b in ("1;1;!hunterSTEP!")Do Echo(%\E%[1;1H%\E%[48;2;!BG!m%\E%[38;2;!FG!m%\E%[0J%Sprite[1]%%Sprite[2]%%Sprite[3]%%Sprite[4]%%Sprite[5]%%Sprite[6]%%Sprite[7]%%Sprite[8]%%Sprite[9]%%Sprite[10]%%Sprite[11]%%Sprite[12]%%Sprite[13]%%Sprite[14]%%Sprite[15]%%Sprite[16]%%Sprite[17]%%Sprite[18]%

						%= Use substitution to invert colliding sprite colors and output. =%
						%= Below line Not compatible with animated multicolor sprties =%
						REM For /F "delims=" %%v in ("!Sprite[%%i]:H=H%\E%[7m!")Do Call Echo(%%v

						%= Use vbscript to play windows .wav file on collision =%
						Call:PlayMusic "%Windir%\media\Windows Error.wav" 70

						%= Clear the console and environment and start a new game in the same window. =%
						Cls
						(Title )
						Endlocal & Endlocal
						Start /b "" "%~f0"
						EXIT
					)
				)

				%= Final adgustments to Sprite 1 and BackGround colors prior to output =%
				If !S1cR! GTR 250 Set "S1cR=50"
				Set "BG=!BGRm!;50;!BGBm!"
				Set "FG=!BG!"
			)
		)

		%= Read last key press from input buffer without waiting. aka Non blocking input =%
		If not "!Lastkey!"=="Pause" Set "LastKey=!Key!"
		Set "NewKey="
		Set /P "NewKey="
		If Defined NewKey For %%v in (!NewKey!)Do (
			If not "!k%%v!"=="" Set "key=!k%%v!"
			If %%v == L EXIT
		)

		%= Implement Control actions. =%
		If Defined Key (
			If "!Key!"=="Pause" (
				Set /A "!Key!=!Pause! %%2 +1"
				Set "Key="
				If !Pause! EQU 1 Set "Key=!LastKey!"
			)
			If not !Pause! EQU 2 (
				If "!Key!"=="Up" (
					%Up%
					Set "LastYkey=Up"
				)
				If "!Key!"=="Down" (
					%Down%
					Set "LastYkey=Down"
				)
				If "!Key!"=="Left" (
					%Left%
					Set "LastXkey=Left"
				)
				If "!Key!"=="Right" (
					%Right%
					Set "LastXkey=Right"
				)
			)

			%= Notify Controls + info via title =%
			Title %Title% Speed !Speed!%% !Time:~-6! %Time:~-6%
		)

		For /F "tokens=1,2,3 Delims=;" %%b in ("!bladesSTEP!;!PatrolSTEP!;!hunterSTEP!")Do Echo(%\E%[1;1H%\E%[48;2;!BG!m%\E%[38;2;!FG!m%\E%[0J%Sprite[1]%%Sprite[2]%%Sprite[3]%%Sprite[4]%%Sprite[5]%%Sprite[6]%%Sprite[7]%%Sprite[8]%%Sprite[9]%%Sprite[10]%%Sprite[11]%%Sprite[12]%%Sprite[13]%%Sprite[14]%%Sprite[15]%%Sprite[16]%%Sprite[17]%%Sprite[18]%

		%= Alternate Thruster character definition for animation =%
		Set "Thruster=▼"
	)
 )

===============================================================

 :DefSprite "CELLline\nCELLline" Y X H W "RR GG BB(foreground)" "RR GG BB(background)" [1|2|3|4]
 REM   Args 1                    2 3 4 5  6                      7                      8 (Starting Direction)

 	Set /A Sprites+=1
 	Set "cells=%~1"
 	Set /A "SH=%~4"
 	Set /A "SW=%~5"
 	Set "FGcol=%~6"
 	Set "BGcol=%~7"
        Set "Spacing= "
        For /L %%i in (2 1 %SW%)Do Call Set "Spacing=%%Spacing%% "
 	Set /A "S%Sprites%LY=%~2,S%Sprites%Y=%~2","S%Sprites%LX=%~3,S%Sprites%X=%~3","S%Sprites%H=SH","S%Sprites%W=SW"
 	Set /A "S%Sprites%UB=2","S%Sprites%BBG=Height-SH","S%Sprites%BB=Height-SH-1","S%Sprites%LB=2","S%Sprites%RB=Width-SW-1","S%Sprites%RBe=Width-SW"
 	Call Set "cells=%%Cells:\n=!\E![!S%Sprites%X!G!\E![1B%%"
        Set "ClearCells=!\E![48;2;!BG!m%\E%[38;2;!FG!m!\E![!S%Sprites%LY!;!\E![!S%Sprites%LX!H%Spacing%"
        For /L %%i in (2 1 %SH%)Do Call Set "ClearCells=%%ClearCells%%!\E![1B!\E![!S%Sprites%LX!G%Spacing%"
 	Set "Sprite[%Sprites%]=%ClearCells%!\E![!S%Sprites%Y!;!S%Sprites%X!H!\E![48;2;%BGcol%m!\E![38;2;%FGcol%m%Cells%!\E![0m"
 	If not "%~8"=="" Set "S%Sprites%Dir=%~8"
Exit /b 0

 :TestVT Author:  T3RRY ; Released: 21/01/2022 ==========================================================================
 REM     PURPOSE: For use with scripts that utilise Vertual terminal sequences.
 REM See:         https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
 REM     METHOD:  Utilizes powershell to Identify if the terminal running the batch script is succesfully executing virual terminal sequences,
 REM              by assessing which character occupies the buffer cell the cursor is currently positioned at.
 REM              As this method is slow, an ADS of this file or a temporary file is used to remember if virtual terminal supported
 Cls

 For /f "delims=" %%e in ('Echo(Prompt $E^|cmd')Do set "\E=%%e"

 2> nul (
	Set "NTFSdrive=true"
	(Echo(verify) >"%~f0:ntfs.test" && (
		Set "SupportINFO=%~f0:VTSupport.dat"
	) || (
		Set "NTFSdrive="
		For /f delims^= %%G in ("%~f0")Do Set "SupportINFO=%TEMP%\%%~nG_VTSupport.dat"
  	)
 )

 2> nul (
	More < "%SupportINFO%" > nul && (
		Exit /b 0
	) || (
		<Nul Set /P "=Verifying Compatability %\E%[2D" 1> CON
		for /F "delims=" %%a in ('"PowerShell.exe $console=$Host.UI.RawUI; $curPos=$console.CursorPosition; $rect=new-object System.Management.Automation.Host.Rectangle $curPos.X,$curPos.Y,$curPos.X,$curPos.Y; $BufCellArray=$console.GetBufferContents($rect); Write-Host $BufCellArray[0,0].Character;"') do (
			Cls
			If "%%a" == "y" (
				(Echo(true) >"%SupportINFO%"
				Exit /b 0
			)else (
				Exit /b 1
			)
		)
	)
 )
 Exit /b 2


===============================================================

:playMusic
	If "%~1" == "" (
		Echo Play Music Usage:
		Echo/Parameters required For Player: "filepath.ext" 0-100
		pause
		Exit /B
	)

	Set "MusicPath=%~1"
	Set /A vol=Loop_TF=0
	Set /A "vol+=%~2 + 0" 2> nul
	Set "Loop_TF=0"
	If not Exist "%~1" Exit /b 1

Rem Creates a vbs Script to play audio
	>"%~dp0Play%~3_mp3.vbs" (
		echo Set Sound = CreateObject^("WMPlayer.OCX.7"^)
		echo Sound.URL = "%MusicPath%"
		echo Sound.settings.volume = %vol%
		echo Sound.settings.setMode "loop", %Loop_TF%
		echo Sound.Controls.play
 		echo While Sound.playState ^<^> 1
		echo WScript.Sleep 100
		echo Wend
	)
	If "%~3"=="" (
		start /wait /min "" "%~dp0Play_mp3.vbs"
	)Else (
		start /min "" "%~dp0Play%~3_mp3.vbs"
	)

Exit /b 0

===============================================================

:GetDelay ReturnVar
Rem counts the number of for /l loops executed per second. Allows For /l loops to be used to implement delays in the millisecond range,
Rem while balancing differences in PC Specs / performance. Routine is executed multiple times on initial run to determine a mean performance baseline.
Rem If The users PC is heavily burdened with other processes, the value this routine returns will be lower than expected resulting in shorter delays /
REM faster gameplay


 Setlocal EnableDelayedExpansion
 for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1"
 Set "%1="
 Set /a t1=t2

	For /l %%i in (1 1 1000000)Do (
		for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1"
		if !tDiff! lss 0 set /a tDiff+=24*60*60*100
		if !tDiff! geq 100 (
			Endlocal & Set /A "%1=%%i*3/7"
			Exit /b 0
		)
	)

===============================================================

:CONTROL
FOR /L %%C in () do (
	FOR /F "tokens=*" %%A in ('%SystemRoot%\System32\CHOICE.exe /C:abcdefghijklmnopqrstuvwxyz0123456789 /N') DO (
		
		<NUL SET /P ".=%%A"
		If %%A == L (
			EXIT
		)
	)

)
EXIT
