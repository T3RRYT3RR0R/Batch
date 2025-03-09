@Echo off

IF not "%~1" == "" (
    Setlocal EnableDelayedExpansion
    GOTO :%~1
)
Setlocal EnableDelayedExpansion
CHCP 65001 > nul
mode 100,45

If not exist "%TEMP%\%~n0demo.txt" (
  Setlocal DISABLEdelayedExpansion
  >"%TEMP%\%~n0demo.txt" (
	For /f "tokens=2 Delims=+" %%^" in ("+"+"+")Do (
          For /f "tokens=1* Delims=0" %%G in ('Findstr.exe /BLI "0" "%~f0"')Do If not "%%G"=="" echo(%%~"%%G%%~"
        )
  )
  Endlocal
)

  Call:defmacros
  Set "p.spr=%esc%[^!p.Y^!;^!p.X^!H@"
  Set /A "p.y=5","p.x=15"

  %$Make.camera% --c.Map:"%TEMP%\%~n0demo.txt" --c.W:80 --c.H:35 --c.X:0 --c.Y:1 --c.Xh:5 --c.Yh:5 --Frame.color:48;2;;150;90;38;2;25;;25 --MAP.color:48;2;50;;;38;2;15;15;0 --c.mode:$Pan.6
  Set $Refresh.Camera >"outfile.txt"
  If Errorlevel 1 (
    For %%v in (!Errorlevel!)Do echo(!Errorcode[%%v]!
    Exit /b
  )


  CALL :RADISH GAME
  EXIT /B

:GAME
  Set "Controls=-27-32-97-98-99-100-101-102-103-104-105-"
  Set "North= 7 8 9 "
  Set "South= 1 2 3 "
  Set "West= 7 4 1 "
  Set "East= 9 6 2 "
  Set /A Speed=24,minSpeed=12,Pause=1

rem  Call:Radish_WAIT
Set "CMDCMDLINE="
Set /A "DPAD=6","lDPAD=6"
2> NUL (
  For /l %%. in ()Do (
    %$if.tElapse.GEQ.target:FPS=SPEED% IF "!CMDCMDLINE:##=!" == "!CMDCMDLINE!" (
      FOR /F "tokens=1-4 delims=." %%R in ("!CMDCMDLINE!") DO (
        If %%T GTR 0 (
          Set "Pause=%%T" 
          If "%%T"=="1" (
            Set "Keys=-98-"
            Set "CMDCMDLINE="
          )
        )
        Set "Keys=%%U"
        1>&2 Set /A "lM.Y=cM.Y","cM.Y=%%S","lM.X=cM.Y","cM.X=%%R","m.Button=%%T"
        If defined Keys If "!Controls:%%U=!"=="!Controls!" Set "Keys="
         If defined Keys (
          If not "!m.Button!"=="1" Set "Pause=1"
          If not "!Keys:-32-=!"=="!Keys!" (
            Set "Pause=2"
            Set /A Keys=DPAD+96
            Set "Keys=-!Keys!-"
            Set "CMDCMDLINE="
          )
          If not "!Keys:-27-=!" == "!Keys!" (
            <nul Set /P "=%esc%[?25h%esc%[1;1H%esc%[2J"
            %RADISH_END%
            Exit /B 0
          )Else (
            Set /A lDPAD=DPAD,DPAD=!Keys:~1,-1!-96
            If not "!Keys:-101-=!"=="!Keys!" (
              Set "Keys="
              Set /A "Speed=Speed %% 250 +1","DPAD=lDPAD"
            )Else For /f "Delims=" %%i in ("!DPAD!")Do Set "c.mode=!$Pan.%%i!"
            If !SPEED! LSS !minSpeed! Set "SPEED=!minSpeed!"
          )
        )
      )
      If 1==0 REM The below codeblock is a controller to demonstrate the camera across all available directions.
      If 1==0 REM Controls effected:  Move in direction of keypress numpad 1-9 [5 changes the speed of the camera]
      If 1==0 REM  N:8  E:6  S:2  W:4 inverse direction by 180 degrees on reaching map edge
      If 1==0 REM NE:9 NW:7 SE:3 SW:1 rotate direction by 90 degrees clockwise on reaching map edge
      For /f %%D in ("!DPAD!")Do (
        If %%D EQU 1 (
          If !c.X! EQU 0 If !c.y! NEQ !c.Y.max! (
            Set "c.mode=!$Pan.3!"
            Set /A "DPAD=3","lDPAD=3"
          )
          If !c.X! EQU 0 If !c.y! EQU !c.Y.max! (
            Set "c.mode=!$Pan.9!"
            Set /A "DPAD=9","lDPAD=9"
          )
          If !c.X! GTR 0 If !c.y! EQU !c.Y.max! (
            Set "c.mode=!$Pan.7!"
            Set /A "DPAD=7","lDPAD=7"
          )
        )Else If %%D EQU 2 (
          If !c.y!==!c.Y.max! (
            Set "c.mode=!$Pan.8!"
            Set /A "DPAD=8","lDPAD=8"
          )
        )Else If %%D EQU 3 (
          If !c.Y! EQU !c.Y.Max! If !c.X! LSS !c.X.Max! (
            Set "c.mode=!$Pan.9!"
            Set /A "DPAD=9","lDPAD=9"
          )
          If !c.Y! EQU !c.Y.Max! If !c.X! EQU !c.X.max! (
            Set "c.mode=!$Pan.7!"
            Set /A "DPAD=7","lDPAD=7"
          )
          If !c.X! EQU !c.X.max! If !c.Y! NEQ !c.Y.Max! (
            Set "c.mode=!$Pan.1!"
            Set /A "DPAD=1","lDPAD=1"
          )
        )Else If %%D EQU 4 (
          If !c.X!==0 (
            Set "c.mode=!$Pan.6!"
            Set /A "DPAD=6","lDPAD=6"
          )
        )Else If %%D EQU 6 (
          If !c.X!==!c.X.max! (
            Set "c.mode=!$Pan.4!"
            Set /A "DPAD=4","lDPAD=4"
          )
        )Else If %%D EQU 7 (
          If !c.X! EQU 0 If !c.y! NEQ 1 (
            Set "c.mode=!$Pan.9!"
            Set /A "DPAD=9","lDPAD=9"
          )
          If !c.X! EQU 0 If !c.y! EQU 1 (
            Set "c.mode=!$Pan.3!"
            Set /A "DPAD=3","lDPAD=3"
          )
          If !c.X! GTR 0 If !c.y! EQU 1 (
            Set "c.mode=!$Pan.1!"
            Set /A "DPAD=1","lDPAD=1"
          )
        )Else If %%D EQU 8 (
          If !c.y!==1 (
            Set "c.mode=!$Pan.2!"
            Set /A "DPAD=2","lDPAD=2"
          )
        )Else If %%D EQU 9 (
          If !c.X! EQU !c.X.Max! If !c.Y! NEQ 1 (
            Set "c.mode=!$Pan.7!"
            Set /A "DPAD=7","lDPAD=7"
          )
          If !c.X! EQU !c.X.Max! If !c.Y! EQU 1 (
            Set "c.mode=!$Pan.1!"
            Set /A "DPAD=1","lDPAD=1"
          )
          If !c.X! LSS !c.X.Max! If !c.Y! EQU 1 (
            Set "c.mode=!$Pan.3!"
            Set /A "DPAD=3","lDPAD=3"
          )
        )
      )
      If not !Pause! EQU 2 If Defined c.mode Set /A "!c.mode!"
             %=   control info   =%  %= mouse pos =%                                          %= camera position relative map 0;0 =%
      TITLE [!LDPAD!:!DPAD!:!PAUSE!] [!cM.X!:!cM.Y!] QUIT:esc MV: 12346789 Speed:5 !SPEED!] X=!c.X! ^| Y1=!c.Y1! ^| c.Y!c.H!=!c.Y%c.H%!
      Set /A "tDiff=0","FRAME=0"
      %$Refresh.Camera%
      Echo(!Camera.View!
      If !c.Debug!==1 1>&2 Echo(!Screen!
    )
  )
)
)
Exit /b 0

:Defmacros
Set "AND=&"

(Set \n=^^^

%= Do not modify \n definiton =%)

for /F %%a in ('Echo(prompt $E^| cmd')Do Set esc=%%a

Set "$cam[1]Tokens= ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]"
Set "$cam[2]Tokens= _`abcdefghijklmnopqrstuvwxyz"

REM TODO generation of player collision chunk for loop and expansion variable
Set "$playerTokens= #$%%&'()*+,-./0123456789:;<=>"
Set "shader=░"
Set "FrameBar=!Shader!"
For /l %%i in (1 1 8)Do Set "FrameBar=!FrameBar:%Shader%=%Shader%%Shader%!"

for /f "tokens=2 delims=+" %%^" in ("+"+"+")Do for /f %%^^ in (%%"^ ^^^^ !!%%")Do for /f %%! in ("! ! ^^^!")Do ^
Set "$StrLen=If Defined $temp (Set "$Len=1"%%^&For %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1)Do (If "%%%%~!$temp:~%%P,1%%%%~!" NEQ "" (Set /a "$Len+=%%P"%%^&Set "$temp=%%%%~!$temp:~%%P%%%%~!")))Else set $Len=0"

Rem "Path\to\mapName.ext",Width,Height,Xstart,Ystart,Xhome,Yhome,$camera.mode || TODO: ,playerXvar,PlayerYvar,PlayerWidth,PlayerHeight to implement ANYcollision

Rem $Make.Camera Usage information
Rem Argument Structure designed to support user assignment of internal camera variable names:
Rem note: Argument values may not contain ':' or '`' characters, as these are used to delimit arguments internally during parsing.
Rem Fixed argument count and positions matching the patterns:
Rem --ReturnVar:ExpectedValue
Rem --ReturnVar . 
Rem '.' denotes a nul value for the argument.
Rem Mandatory Args:
Rem         --ReturnVar:ExpectedValue         || Desciption of expected Argument value: 
Rem Arg 1:  --ReturnVar:"Path\to\mapName.ext" || The filepath of the map to be loaded.
Rem Arg 2:  --ReturnVar:Integer               || The column width of the Camera. Must not exceed map width
Rem Arg 3:  --ReturnVar:Integer               || The row height of the camera.   Must not exceed map height
Rem Arg 4:  --ReturnVar:Integer               || The starting map X position. [camera x variable]
Rem Arg 5:  --ReturnVar:Integer               || The starting map Y position. [camera y variable]
Rem                                              Defines macro:
Rem                                              update.ReturnVar
Rem Usage:                                       Set /A cameraXvar=NewValue,cameraYvar=NewValue,!update.ALL.cameraYvar!
Rem Arg 6:  --ReturnVar:Integer               || The column position of camera X home. Camera home is the top left corner of the camera frame.
Rem Arg 7:  --ReturnVar:Integer               || The row    position of camera Y home.

REM The below Arguments are optional, but positionally fixed. These args require A nul value must be provided when unused.
Rem example: " --. " which is equivalent to " --voidArg . "
Rem Arg 8:  --ReturnVar:48;5;INT;38;5;INTm    || VT Sequence - Assign Camera Frame foreground and background color to ReturnVar
Rem Arg 9:  --ReturnVar:48;5;INT;38;5;INTm    || VT Sequence - Assign Map foreground and background color to ReturnVar
Rem Arg 10: --ReturnVar:$Pan.VECTOR           || Assign an Algorithm for controlling Initial camera direction to ReturnVar as a macro.
REM                                              Available $PAN.VECTORS: 8 9 6 3 2 1 4 7 corresponding to: N NE E SE S SW W NW
Rem Arg 11: --ReturnVar:Integer               || Initial Player X position.
Rem Arg 12: --ReturnVar:Integer               || Initial Player Y position.
Rem Arg 13: --ReturnVar:Integer               || Player Width.
Rem Arg 14: --ReturnVar:Integer               || Player Height.

Set "Errorcode[1]=Argument Arithmetic error"
Set "Errorcode[2]=Camera Width exceeds Map Width"
Set "Errorcode[3]=Camera Height exceeds Map Height"

Rem Additional Macro Returns to support camera control:

Rem Usage: || %$Make.Camera% --map.filepath:"Path\to\mapName.ext" --Width:Int --Height:Int --mapXpos:Int --mapYpos:Int --camXhome:Int --camYHome:Int --borderColor:VTsequence --Mapcolor:VTsequence --Camera.Mode:$Pan.VECTOR
for /f %%^^ in ("^ ^^^^ !!")Do for /f %%! in ("! ! ^^^!")Do ^
Set $Make.Camera=For %%. in (1 2)Do If %%.==2 (%\n%
  Set "$temp.Args=%%!$temp.Args: --=`--%%!"%\n%
  Set "$temp.Args=%%!$temp.Args:--.=--VoidArg:.%%!"%\n%
  Set "$temp.Args=%%!$temp.Args::\=;\%%!"%\n%
  Set "$temp.Args=%%!$temp.Args: .--= .`--%%!"%\n%
  Set "$temp.Args=%%!$temp.Args: .`=:.`%%!"%\n%
  Set "$temp=%%!$temp.Args%%!"%\n%
  %$StrLen:$Len=$temp.c%%\n%
  Set "$temp=%%!$temp.Args:--=%%!"%\n%
  %$StrLen:$Len=$temp.i%%\n%
  Set /A "$temp.i=($temp.c-$temp.i)/2"%\n%
  Set "$temp.args.supportingMATH= 2 3 4 5 6 7 11 12 13 14"%\n%
  For /l %%i in (1 1 %%!$temp.i%%!)do For /f "tokens=1,2 Delims=:`" %%1 in ("%%!$temp.Args:*--=%%!")Do (%\n%
    If not "%%1"=="VoidArg" (%\n%
      If "%%!$temp.args.supportingMATH: %%i =%%!" == "%%!$temp.args.supportingMATH%%!" (%\n%
        Set "$temp.%%i=%%1"%\n%
        Set "$temp.%%i.v=%%~2"%\n%
        Set "$temp.%%i.v=%%!$temp.%%i.v:;\=:\%%!"%\n%
        Set "%%1=%%~2"%\n%
        Set "%%1=%%!%%1:;\=:\%%!"%\n%
      )Else (%\n%
        Set "$temp.%%i=%%1"%\n%
        Set /A "$temp.%%i.v=%%~2","%%1=%%~2"%\n%
      )%\n%
    )Else Set "$temp.%%i="%\n%
    Set "$temp.Args=%%!$temp.Args:*--%%1:%%2=%%!"%\n%
  )%\n%
  (Call )%\n%
  Set /A "%%!$temp.6%%!=%%!$temp.6.v%%!+1"%\n%
  For /f "tokens=1-10 Delims=`" %%1 in ("%%!$temp.1%%!`%%!$temp.2%%!`%%!$temp.3%%!`%%!$temp.4%%!`%%!$temp.5%%!`%%!$temp.6%%!`%%!$temp.7%%!`%%!$temp.8%%!`%%!$temp.9%%!`%%!$temp.10%%!") Do (%\n%
    Set /A "%%4.Min=0","%%5.Min=1","%%5.Max=0","$temp.Frame=%%!%%2%%!+2","%%4.start=%%!%%4%%!","%%5.start=%%!%%5%%!"%\n%
    If Errorlevel 1 Set "$temp.Args=malformed"%\n%
    If defined $temp.Args (%\n%
      Echo( Invalid Arg Syntax. Check for misplaced Doublequotes / Parentheses.%\n%
      Echo( refer to usage information -- Aborting Camera Build.%\n%
      Exit /b 1%\n%
    )%\n%
    If not "%%!%%!"=="" Exit /b 1%\n%
    Set /A "FRAME=0","c.Debug=0"%\n%
    For /f "Delims=" %%G in (%%!%%1%%!)Do (%\n%
      Set /A "%%5.Max+=1"%\n%
      Set "#[%%!%%5.Max%%!]=%%G"%\n%
    )%\n%
    Set "$temp=%%!#[1]%%!"%\n%
    %$StrLen%%\n%
    Set /A "%%4.Max=$Len"%\n%
    Set /A "%%5.End=(%%!%%5%%!+%%!%%3%%!)"%\n%
    For /l %%i in (%%!%%5.Start%%! 1 %%!%%5.End%%!)Do (%\n%
      Set /A "$temp.mapY.index=(%%i - %%!%%5.start%%!)+1"%\n%
      Set /A "%%5%%!$temp.mapY.index%%!=%%i"%\n%
    )%\n%
    Set "$pan.8=%%5-=1,%%51=%%5"%\n%
    For /l %%i in (2 1 %%!%%3%%!)Do (%\n%
      Set /A "$temp.pan.offset=%%i-1"%\n%
      Set "$pan.8=%%!$pan.8%%!,%%5%%i=%%51+%%!$temp.pan.offset%%!"%\n%
    )%\n%
    Set "$pan.2=%%!$pan.8:-=+%%!"%\n%
    Set "$pan.4=%%4-=1"%\n%
    Set "$pan.6=%%4+=1"%\n%
    Set "update.%%5=%%!$Pan.8:*,=%%!"%\n%
    Set "$pan.7=%%!$pan.8%%!,%%!$pan.4%%!"%\n%
    Set "$pan.9=%%!$pan.8%%!,%%!$pan.6%%!"%\n%
    Set "$pan.1=%%!$pan.2%%!,%%!$pan.4%%!"%\n%
    Set "$pan.3=%%!$pan.2%%!,%%!$pan.6%%!"%\n%
    For /f "tokens=1,2 delims=." %%G in ("%%!%%~:%%!")Do (%\n%
      Set "%%~:=%%!%%G.%%H%%!"%\n%
      Set "DPAD=%%H"%\n%
    )%\n%
    If "%%!%%~:%%!"=="" Set "%%~:=%%!$Pan.E%%!"%\n%
    Set "$camera.data[1]=%%^%%!%%4%%^%%! %%^%%!%%2%%^%%!"%\n%
    For /f %%W in ("%%!$temp.Frame%%!")Do Set "CAMERA=%esc%[7;%%^%%!%%9%%^%%!m%esc%[%%!%%7%%!;%%!%%6%%!H%esc%7%esc%[1A%%!FrameBar:~0,%%W%%!"%\n%
    If %%!%%3%%! LSS 29 (Set /A "$temp.tkn.loop.1=%%!$temp.3.v%%!")Else Set "$temp.tkn.loop.1=29"%\n%
    For /l %%i in (1 1 %%!$temp.tkn.loop.1%%!)Do (%\n%
      Set "$camera.data[1]=%%!$camera.data[1]%%! %%^%%!%%5%%i%%^%%!"%\n%
      For /f %%T in ("%%!$cam[1]tokens:~%%i,1%%!")Do Set "CAMERA=%%!CAMERA%%!%esc%[1B%esc%[%%!%%6%%!G%esc%[%%!%%2%%!X%%!Shader%%!%esc%[%%^%%!%%8%%^%%!m%%^%%!#[%%%%~T]:~%%?,%%@%%^%%!%esc%[%%^%%!%%9%%^%%!m%%!Shader%%!"%\n%
    )%\n%
    If %%!%%3%%! GTR 29 (%\n%
      Set "$camera.data[2]= "%\n%
      For /l %%i in (30 1 %%!%%3%%!)Do (%\n%
        Set "$camera.data[2]=%%!$camera.data[2]%%! %%^%%!%%5%%i%%^%%!"%\n%
        Set /A "$temp.tkn.Index=(%%i-29)"%\n%
        For /f %%e in ("%%!$temp.tkn.Index%%!")Do (%\n%
          For /f %%T in ("%%!$cam[2]tokens:~%%e,1%%!")Do (%\n%
            Set "CAMERA=%%!CAMERA%%!%esc%[1B%esc%[%%!%%6%%!G%esc%[%%!%%2%%!X%%!Shader%%!%esc%[%%^%%!%%8%%^%%!m%%^%%!#[%%%%T]:~%%?,%%@%%^%%!%esc%[%%^%%!%%9%%^%%!m%%!Shader%%!"%\n%
          )%\n%
        )%\n%
      )%\n%
    )%\n%
    For /f %%W in ("%%!$temp.Frame%%!")Do Set "CAMERA=%%!CAMERA%%!%esc%[1B%esc%[%%!%%6%%!G%%!FrameBar:~0,%%W%%!%esc%[0m"%\n%
    Set /A "$temp.tkn.loop.1+=2"%\n%
    Set "$Refresh.Camera=For /f "tokens=1-%%!$temp.tkn.loop.1%%!" %%? in ("%%!$camera.data[1]%%!")Do "%\n%
    If %%!%%3%%! GEQ 30 (%\n%
      Set /a "$temp.tkn.loop.2=%%!%%3%%!-29"%\n%
      Set "$Refresh.Camera=%%!$Refresh.Camera%%!For /f "tokens=1-%%!$temp.tkn.loop.2%%!" %%_ in ("%%!$camera.data[2]%%!")Do "%\n%
    )%\n%
    Set "$Refresh.Camera=%%!$Refresh.Camera%%! (Set "Camera.view=%%!CAMERA%%!" %%!AND%%! Set "ANYcollision=%%!PlayerCHUNK%%!" %%!AND%%! if defined ANYcollision Set "ANYcollision=%%!ANYcollision: =%= TBA PlayerChunk =%%%!")"%\n%
    Echo(%esc%[?25l%\n%
    Set /A "%%4.max=(%%4.max-%%!%%2%%!)+1"%\n%
    Set /A "%%5.max=(%%5.max-%%!%%3%%!)+1"%\n%
  )%\n%
  For /f "tokens=1 Delims==" %%G in ('Set "$temp"')Do Set "%%G="%\n%
)Else Set $temp.Args=

REM default to 24 fps if no target FPS supplied via substitution
REM usage: || %$if.tElapse.GEQ.target:FPS=INTEGER% ( commands per framerate interval )
Set /A "FPS=24"
for /f %%! in ("! ! ^^^!")Do ^
Set "$if.tElapse.GEQ.target=(If not "%%!tCS%%!"=="%%!lCS%%!" (Set /a "tDiff=tCS-lCS","lCS=tCS","FRAME+=1") %AND% If %%!tDiff%%! GTR 1 Set /A "FRAME+=tDiff") %AND% Set /A "tFR=(10000000/(FPS*1000))","tCS=%%!time:~-1%%!","FR.i=(FRAME %% 100 + 1)*100" %AND% If %%!FR.i%%! GEQ %%!tFR%%! "

for /f %%! in ("! ! ^^^!")Do ^
Set "$Unload.Camera=Set $Unload.Camera=&Set $Make.Camera=&Set $Modify.Camera=&Set $Refresh.Camera=&Set $if.tElapse.GEQ.targetFPS="
Exit /b 0

:RADISH AUTHOR: theLowSunOverTheMoon
SET /A "RADISH_ID=RADISH_INDEX=0" & SET "RADISH_AUDIO_START=ECHO " & SET "RADISH_AUDIO_END=>\\.\pipe\RADISH" & SET "RADISH_END=(TASKKILL /F /IM "RADISH.exe")>NUL & EXIT"
Where radish.exe > nul || (
  Echo( required utility Radish.exe missing.
  Echo( https://github.com/thelowsunoverthemoon/radish/blob/main/bin/radish.exe
  Echo( https://github.com/thelowsunoverthemoon/radish/blob/main/bin/fmod.dll
  Pause
  Exit /b 1
)
2> nul RADISH "%~nx0" %~1
GOTO :EOF
:RADISH_WAIT 
(ECHO/ > \\.\pipe\RADISH) 2>NUL && GOTO :EOF
(PATHPING 127.0.0.1 -n -q 1 -p 150)>NUL
GOTO :RADISH_WAIT
:RADISH_ADD <name> <var> <type> 
(PATHPING 127.0.0.1 -n -q 1 -p 100)>NUL & SET /A "%2=RADISH_INDEX", "RADISH_INDEX+=1"
IF "%3" == "EFFECT" (%RADISH_AUDIO_START% "E#%~1" %RADISH_AUDIO_END%) else IF "%3" == "TRACK" (%RADISH_AUDIO_START% "T#%~1" %RADISH_AUDIO_END%) else IF "%3" == "OBJECT" (%RADISH_AUDIO_START% "O#%~1" %RADISH_AUDIO_END%)
(PATHPING 127.0.0.1 -n -q 1 -p 100)>NUL
GOTO :EOF
:RADISH_CREATE_OBJ <index> <var> <x> <y>
(PATHPING 127.0.0.1 -n -q 1 -p 100)>NUL
SET /A "RADISH_ID-=1", "%2=RADISH_ID" & %RADISH_AUDIO_START% "C#%1#%3#%4" %RADISH_AUDIO_END% & (PATHPING 127.0.0.1 -n -q 1 -p 100)>NUL
GOTO :EOF
:RADISH_SET_OBS <x> <y>
(PATHPING 127.0.0.1 -n -q 1 -p 100)>NUL & %RADISH_AUDIO_START% "X#%1#%2" %RADISH_AUDIO_END% & (PATHPING 127.0.0.1 -n -q 1 -p 100)>NUL
GOTO :EOF
0     // /  |           @   //  /  |                  ., `                                                                                                            || 
0    / \/   |           I  /  \/   |               ..`    ```.,                  .___.                                                                                || 
0   |   |+H+H+H+H+H+H+H+H+H|   |   /            ...            `..              +(   )|                                                                               {} 
0   |   |H+H+H+/--\H+H+H+H+|   |  /           ...                 `,            H[   ]/                                                                               || 
0   |   |+H+H+H{==}+H+H+H+H|   | /           ..                     `,          ======                                                                                || 
0   |   |H+H+H+{==}H+H+H+H+|   |/          ..                         `..........................,                               , , .                                || 
0               ..                        ..    .                                                `.,     ,___________,          /,\MYm,                               || 
0    .           ..                     ..     ,@y,                                      [?]       `..  /___________/ \         `  `Y/`                               || 
0   `@,           .......................       Y`                                                   ../            \  \            ||                                || 
0    Y           ......................        .i.                                                    /              \/|`....,...   ||                                || 
0   .i.        ....      i-----i                                                                      |   [ ]   [ ]  |`|   ```````......                              || 
0            ....    ~~~Gg~~~~gG~~~                                                                   |              | |                ``                            {} 
0           ...   ~cC~c~c~~~~~~~cc~                                                                   |              | |                  ``                          || 
0............    ~~OcC~c~~Cc~~~cC~~~                                                                                                        ``                        || 
0           ..  ~~~oO~~~~~~~oGo~~~~~                                                                                                          ``                      || 
0            ..                                                                                                                                 ``                    || 
0             ...                                                                                                                                 `,..                || 
0               ..                                                                  /-\                                                                ```,           || 
0                ..,..................................,                            //i\\                                                                  .           || 
0                  ..                              ````````````````.              //`W \\                                                                  `          || 
0                   ..                                              ``,.....     @-I   I.                                                                   `         {} 
0                    ..                                                   ```..   H+H+H+H                                                                   `         --
0                     ...                                                     ....WWWWWWW  @~                                                               `..,.,...|  |
0                       ``,.                                                            ,                                                                    ,...,..,|  |
0                          ``..                                                          .                                                                   ,        -- 
0                             ..                                                         .                                                                   .        {} 
0                              ..                                                         .                                                                  `        || 
0                               .`                                                        .             _____, _____, _____,                                 `        || 
0                               .`,    ~`~                                                 `           /_____\/_____\/_____\\                       ,......,`         || 
0       /\ /\ /\ /\ /\ /\ /\ /\/\\` ~`~   ~`~                                               `...      |+H+H+H|+H+H+H|+H+H+H||                  ,..,`                  || 
0      //\\/\\//\\/\\//\\/\\//\\/\\                                                             `., []|H+H+_____,+H_____,H_____,        ,..,```                       || 
0       || || || || || || || || || .,.                                                             .  |+H+/______\/_____\/_____\\   ,..`                              || 
0       || || || |/\|/\|/\|/\|/\|/\ /\`,                                                            `..., |+H+H+H|+H+H+H|+H+H+H||..`                                  || 
0                //\//\//\//\//\//\//\\..                                                                 |H+H+H+|H+H+H+|H+H+H+||                                     || 
0           `@,   || || || || || || ||  ..                                                                |+H+H+H|+H+H+H|+H+H+H|| []                                  || 
0                 || || || || || || ||   ..                                                                                                     /\                    {} 
0                                        ..                                                                                                  /\//\\/\                 || 
0 .........................................`,..,                                                                                            //\\||//\\/\              || 
0          .`                                   ``.                                                                                     /\ /\||/\|/\|//\\             || 
0          ,                                       ``.                                                                                 //\\/\\//\\/\\ ||              || 
0         `                                           ``````,                                                                        .  || ||  || ||  ||              || 
0        .                                                   `                                                                      ,   || ||  || ||                  || 
0       `                                                     ``,                                                                  .                                  || 
0     .`                                                        .             _____, _____, _____,                                 `                                  || 
0     .`,    ~`~                                                 `           /_____\/_____\/_____\\                       ,......,`                                   || 
0   /\/\\` ~`~   ~`~                                               `...      |+H+H+H|+H+H+H|+H+H+H||                  ,..,`                                           || 
0  //\\/\\                                                             `., []|H+H+_____,+H_____,H_____,        ,..,```                                                || 
0   || || .,.                                                             .  |+H+/______\/_____\/_____\\   ,..`                                                       || 
0   /\ /\`,                                                                `..., |+H+H+H|+H+H+H|+H+H+H||..`                                                           || 
0 \//\//\\..                                                                     |H+H+H+|H+H+H+|H+H+H+||                                                              || 
0 || || ||  ..                                                                   |+H+H+H|+H+H+H|+H+H+H|| []                                                           || 
0             ,                                                                                                                                 /\                    {} 
0              `,                        ..                                                                                                  /\//\\/\                 || 
0 ...............`.........................`,..,                                                                                            //\\||//\\/\              || 
0                                               ``.                                                                                     /\ /\||/\|/\|//\\             || 
0                                                  ``.                                                                                 //\\/\\//\\/\\ ||              || 
0                                                     ``````,                                                                           || ||  || ||  ||              || 
0                                                            `                                                                          || ||  || ||                  || 
0                                                             ``,                                                                                                     || 