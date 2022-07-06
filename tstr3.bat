
@Echo off & CHCP 65001 > nul

 If not "%~1"=="" Goto:%1

 Del "%TEMP%\%~n0_*.log" 2> nul

rem todo // implement framerate
rem todo // implement player sprite ; controls ; gravity [downward move if only whitespace beneath sprites lowerY*width]
rem todo // derive offset calculation to test characters at a given x/y coord for use in collision detection.
 rem - x right and y below CD done. 

 For /f "delims=" %%e in ('Echo prompt $E^|cmd')Do Set "\E=%%e"

Rem Set "BG=10;10;10"
Rem Set "FG=10;10;10"
 Call:DefSprite "/---\\n «o» \n\---/" 27 4 3 5 "40;0;0" "240;0;0"

 Set /A width=75,hieght=40

 <nul set /p "=%\E%[?25l"

 SET every="1/(((~(0-(frames %% #))>>31)&1)&((~((frames %% #)-0)>>31)&1))"

 Setlocal EnabledelayedExpansion


 Set "DeleteColumn="
 For /l %%i in (1 1 !{L}!)Do Set "DeleteColumn=!DeleteColumn!%\E%[%%i;1H%\E%[1P"
 
 Set "k87=Up" & Set "k119=Up" & Set "k-72=Up"
 Set "k83=Down" & Set "k115=Down" & Set "k-80=Down"
 Set "k68=Right" & Set "k100=Right" & Set "k-77=Right"
 Set "kD=Right" & Set "k6=Right"
 Set "kA=Left"  & Set "k4=Left"
 Set "kW=Up"    & Set "k8=Up"
 Set "kS=Down"  & Set "k2=Down"
 Set "XKeys= A 4 D 6"
 Set "YKeys=W 8 S 2"

 Mode %width%,%hieght%
 Set /A "{X}=Width","pin=({X}-width)+S1X",""pinHome=({X}-width)"","Floor=1","frames=0"
 Set "Right= "
 Set "CollideRight="

 Call:Level 1 10 "▓" "▒"

 "%~F0" CONTROL W >"%temp%\%~n0_signal.txt" | "%~F0" GAME <"%temp%\%~n0_signal.txt"
 EXIT

 :GAME
 Setlocal EnableDelayedExpansion

 2> "%TEMP%\%~n0_Game_STDerr.log" (
	For /l %%. in ()Do (
		Set /A "PinAdjust=MapWidth-2"

		For /l %%n in (1 1 !LevelDelay!)Do REM

		Set /A "S1Left=(Pin+1+S1X)-2","S1Ymax=(S1Y+S1H)-1","S1Right=(PIN+1+S1X+S1W)-1"
		Set /A "frames+=1","Floor=0","Roof=0","{x}=!{X}! %% MapWidth + 1","Pin=!Pin! %% MapWidth + 1"

		If !Pin! GEQ !PinAdjust! (
			Set /A "S1Right+=1"
			If not !Pin! EQU !{X}! (
				If !S1X! GTR !S1startX! Set /A "S1X-=1"
			)
		)

REM		If !{X}! EQU 1 If not "!Key!"=="Up" If not "!Key!"=="Down" Set "Key=Left"
		Set "Right="
		Set "CollideRight="
		Set "Left="
		Set "CollideLeft="

		For %%v In (!S1Right! !S1Left!)Do (
			For /L %%j in (!S1Y! 1 !S1YMax!)Do (
				If "%%v"=="!S1Right!" If not "!line[%%j]:~%%v,1!"=="" (
					For %%k in (!Colliders!)Do If "!line[%%j]:~%%v,1!"=="%%~k" Set "CollideRight=true"
					Set "Right=!Right!!line[%%j]:~%%v,1!"
				)
				If "%%v"=="!S1Left!" If not "!line[%%j]:~%%v,1!"=="" (
					For %%k in (!Colliders!)Do If "!line[%%j]:~%%v,1!"=="%%~k" Set "CollideLeft=true"
					Set "Left=!Left!!line[%%j]:~%%v,1!"
				)
			)
		)

		If "!Right: =!"=="" Set "CollideRight="
		If "!Right!"=="" Set "CollideRight="

		If Defined CollideRight (
			If !S1X! GTR 4 (
				Set /A "1/(Pin-1)","S1LX=S1X","S1X-=1" || Set /A "{x}=!{X}! %% MapWidth + 1","Pin=!Pin! %% MapWidth + 1"
				REM If "!Key!"=="Right" Set "Key=Left"
			)Else (
				Set /A "{x}-=1","Pin-=1"
			)

		)

		Set /A "S1Above=S1Y-1","S1Below=S1Y+S1H","S1Left=Pin+S1X-2","S1Right=PIN+S1X+S1W-1","S1Ymax=(S1Y+S1H)","S1BaseY=S1Y+S1H-1"
		Set /A "pinoffset=(pin+S1X)","PinLeft=Pin-1","pinRight=Pin+1"

		For /f "tokens=1,2,3,4,5,6,7,8 delims=;" %%1 in ("!{x}!;!pin!;!S1Above!;!S1Below!;!S1Right!;!S1Left!;!PinLeft!;!PinRight!")Do (
			If "!S1Y!;!Pin!" == "24;45" (
				Title exit located^^!
			)Else REM Title  Find the exit. W = Up S = Down L = Leave Game
			Set "Below="
			Set "Above="
			For %%i in (!pinoffset!)Do (
				Set "Below=!line[%%4]:~%%i,%S1W%!"
				Set "Above=!line[%%3]:~%%i,%S1W%!"
				For %%k in (!Colliders!)Do (
					If not "!Below:%%~k=!"=="!below!" Set "Floor=1"
					If not "!Above:%%~k=!"=="!Above!" Set "Roof=1"
				)

			)
			Echo(%\E%[1;1H%\E%[2J%\E%[7m%Screen%%Sprite[1]%
		)
REM		TITLE Key:!Key!; L:!CollideLeft!; R:!CollideRight!-"!Right!"; A:!Roof!-"!Above!"; B:!Floor!-"!Below!" P:!Pin!;X:!{X}!//!S1Y!;!S1X!

		If defined CollideRight If not "!Key!"=="Up" If not "!Key!"=="Down" Set "Key=Left"
		Set "NewKey="
		Set /P "NewKey="
		If Defined NewKey For %%v in (!NewKey!)Do (
 			If not "!k%%v!"=="" Set "key=!k%%v!"
			If %%v == L EXIT
			If not "!XKeys: %%v=!"=="!XKeys!" Set "LastXKey=!Key!"
			If not "!YKeys: %%v=!"=="!YKeys!" Set "LastYKey=!Key!"
		)
Rem Up / down movement - execute every 2 frames

                Set /A !every:#=2! && (
			If "!Key!"=="Up" If not !Roof! EQU 1 (
				Set /A S1LY=S1Y,S1Y-=1
			)Else Set "Key="
			If "!Key!"=="Right" (
				If not defined CollideRight (
					Set /A "1/(Width/(S1X+S1W+1))" && Set /A S1LX=S1X,S1X+=1
				)Else Set "Key=Left"
			)
			If "!Key!"=="Left" If not defined CollideLeft IF !S1X! GTR 4 (
				Set /A S1LX=S1X,S1X-=1
			)
			If "!Key!"=="Down" If not !Floor! EQU 1 (
				Set /A S1LY=S1Y,S1Y+=1
			)Else Set "Key="
		)
	)
 )

 Endlocal & Goto:Eof

   If defined right If not "!Right: =!"=="" If not "!Right:▓=!"=="!Right!" (
    Echo(M|choice /N
    Endlocal
    Start "" "%~f0"
    EXIT
   )

 :DefSprite "CELLline\nCELLline" Y X H W "RR GG BB(foreground)" "RR GG BB(background)" [1|2|3|4]
 REM   Args 1                    2 3 4 5  6                      7                      8 (Starting Direction)

 	Set /A Sprites+=1
 	Set "cells=%~1"
 	Set /A "SH=%~4"
 	Set /A "SW=%~5"
 	Set "FGcol=%~6"
 	Set "BGcol=%~7"

 	Set /A "S%Sprites%LY=%~2,S%Sprites%Y=%~2","S%Sprites%LX=%~3-1,S%Sprites%X=%~3",S%Sprites%startX=%~3",S%Sprites%iX=%~3","S%Sprites%H=SH","S%Sprites%W=SW"
 	Set /A "S%Sprites%UB=2","S%Sprites%BBG=Hieght-SH","S%Sprites%BB=Hieght-SH-1","S%Sprites%LB=2","S%Sprites%RB=Width-SW-1","S%Sprites%RBe=Width-SW","S%Sprites%Wo=SW+1"
 	Call Set "cells=%%Cells:\n=!\E![!S%Sprites%X!G!\E![1B%%"
	Set "Sprite[%Sprites%]=!\E![!S%Sprites%Y!;!S%Sprites%X!H!\E![48;2;%BGcol%m!\E![38;2;%FGcol%m%Cells%%\E%[48;2;!BG!m!\E![38;2;255;255;255m"
 	If not "%~8"=="" Set "S%Sprites%Dir=%~8"
Exit /b 0

===============================================================

:CONTROL
	Setlocal EnableDelayedExpansion
	2> "%TEMP%\%~n0_Control_STDerr.log" (
		FOR /L %%C in () do (
			FOR /F "tokens=*" %%A in ('%SystemRoot%\System32\CHOICE.exe /C:abcdefghijklmnopqrstuvwxyz0123456789 /N') DO (
				<NUL SET /P ".=%%A"
				If %%A == L (
				EXIT
			)
		)
	)
EXIT

:Level Number DelayRate "Collider" "Collider..."
 Set "Screen=!\E![1;1H"
 Set "{L}=0"
 2> nul (
  For /f "usebackq tokens=2 delims=:#" %%G in (`type "%~f0" ^| %SystemRoot%\System32\findstr.exe /blc:":%~1#" "%~f0"`) Do (
   Set /A "{L}+=1"
   Set "Line[!{L}!]=%%G"
    For %%v in (!{L}!)Do (
     Set "Screen=!Screen!^!Line[%%v]:~%%8,%width%^!!\E![1E"
     For /l %%w in (0 1 1000)Do if not "!Line[%%v]:~%%w,1!"=="" (
      Set /a "MapWidth=%%w"
      If defined Xline[%%w] (
       Set "Xline[%%w]=!Xline[%%w]!%\E%[1D%\E%[1B!Line[%%v]:~%%w,1!"
       Set "Xtest[%%w]=!Xtest[%%w]!!Line[%%v]:~%%w,1!"
      )Else (
       Set "Xline[%%w]=%\E%[1d!Line[%%v]:~%%w,1!"
       Set "Xtest[%%w]=!Line[%%v]:~%%w,1!"
      )
     )
     Set "Line[%%v]=!Line[%%v]!!Line[%%v]!"
    ) 
   )
  )
 )
 <nul Set /P "=%\E%[1;1H%\E%[48;2;!BG!m%\E%[38;2;255;255;255m%\E%[0J%\E%[1;1H"
 For /L %%i in (1 1 %Width%)Do <nul Set /p "=%\E%[%%iG!xline[%%i]!"
 Set "LevelDelay=%~2"
 Set "Colliders=%*"
 Set "Colliders=!Colliders:%1 %2=!"
Exit /b 0

:1#▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓:
:1#                                                                                                                    :
:1#                                  ._,                                                                               :
:1#                            ░       `                                                                               :
:1#                  /-\   ░  ░ ░                                                                                      :
:1#                       ░░░░░░░                                                                                      :
:1#                         ░░ ░                                   /-\                                                 :
:1#                                                                                                                    :
:1#                                                                                                                    :
:1#                                                                                                                    :
:1#                                                                                                                    :
:1#                                                                                                     ▒▓▓▓▓▓▒        :
:1#                                                                                                     ▓▒▒▒▒▒▓        :
:1#                                                                                                     ▒▓▓▓▓▓▒        :
:1#                                                                                                     ▓▒▒▒▒▒▓        :
:1#                                                                                                     ░▓▓▓▓▓▒        :
:1#                                                                                                      ░▒▒▒▒▓        :
:1#░▓▓▓▓▓▓▓▓▓░                                                  ░▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓░                    ░▓▓▓▒        :
:1# ░▓▒▒▒▒▒▓░                                                    ░▓▒▒▒▒▒▓░  ░▓▒▒▒▒▒▓░                                  :
:1#  ░▓▒▒▒▓░                                                      ░▓▒▒▒▓░    ░▓▒▒▒▓░                                   :
:1#   ░▓▒▓░                                                        ░▓▒▓░      ░▓▒▓░                                    :
:1#    ░▓░                                                          ░▓░        ░▓░                                     :
:1#     ░                                          ▓▓▓▓▓▓▓           ░          ░                                      :
:1#                                                ▓«░░░»▓                                                             :
:1#                                              ▓▓▓░░░░░▓▓▓                                                           :
:1#                                              ▓░░░░░░░░░▓                                                           :
:1#     ░                                                                                                              :
:1#    ░▓░                                                                                                             :
:1#   ░▓▒▓░                                                                                                            :
:1#  ░▓▒▒▒▓░                                         ░░░░░░░░                                                          :
:1# ░▓▒▒▒▒▒▓░                                      ▒▒▒▒▒▒▒▒▒▒▒▒                                                        :
:1#░▓▒▒▒▒▒▒▒▓░                                     ▒░░░░░░░░░░▒                                                        :
:1#▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓:
