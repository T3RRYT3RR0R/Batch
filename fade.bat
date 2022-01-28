
 @Echo off & Cls
 CHCP 65001 > nul

 If "!!"=="" (
  Echo(Delayed Expansion must be disabled prior to starting %~n0
  Exit /b 1
 )

 If not exist "%TEMP%\GetKey.exe" (
  Title Resource required - GetKey.exe
  Echo(This program requires GetKey.exe to run.
  Echo(Install from this file Y/N ?
  For /f "delims=" %%C in ('%SystemRoot%\System32\choice.exe /N /C:YN')Do if %%C==Y (
   Certutil -decode "%~f0" "%TEMP%\GetKey.exe" > nul
  )Else Exit /B 1
  Cls & (Title )
 )

 Call:TestVT || (
  Echo(Virtual terminal sequences not supported
  Exit /b 1
 )

 REM properties
 Set /A "Hieght=35","Width=140","Sprites=0"
 Set "BG=10;10;10"
 Set "FG=10;10;10"

 Set "S1cR=50"
 Call:DefSprite "/---\\n «o» \n\---/" 5        5       3 5 "0;200;250"  "!S1cR!;!s1cR!;60"
 Call:DefSprite "╔═╗\n║ ║\n╚═╝"       10       60      2 3 "200;0;0"    "0;90;120"         2
 Call:DefSprite "╔╗\n╚╝"              Hieght/2 Width/2 2 2 "90;220;180" "!BG!"             3

REM Controls
 Set "k68=Right" & Set "k100=Right" & Set "k-77=Right"
 Set "Right=Set /A "1/((S1RB)/(S1X))" && Set /A "S1LX=S1X","S1LY=S1Y","S1X+=1"||Set /A "S1LX=S1X","S1LY=S1Y""

 Set "k65=Left" & Set "K97=Left" & Set "k-75=Left"
 Set "Left=Set /A "1/(S1LB-S1X)" && Set /A "S1LX=S1X","S1LY=S1Y","S1X-=1"||Set /A "S1LX=S1X","S1LY=S1Y""

 Set "k87=Up" & Set "k119=Up" & Set "k-72=Up"
 Set "Up=Set /A "1/(S1UB-S1Y)" && Set /A "S1LX=S1X","S1LY=S1Y","S1Y-=1"||Set /A "S1LX=S1X","S1LY=S1Y""

 Set "k83=Down" & Set "k115=Down" & Set "k-80=Down"
 Set "Down=Set /A "1/(S1BB/S1Y)" && Set /A "S1LX=S1X","S1LY=S1Y","S1Y+=1"||Set /A "S1LX=S1X","S1LY=S1Y""

 Set "k32=Jump"
 Set "Jump=Set /A "1/(S1BB/(S1Y+1))" || (Set /A "S1LX=S1X","S1LY=S1Y","S1Y-=10")"
 Mode %Width%,%Hieght%
 Set "Delay=4"

 Setlocal EnableDelayedExpansion

 REM Set "sprites=0"
 REM For /f Delims^= %%G in ('Set Sprite[')Do Set /A "sprites+=1"

 Set "Gravity=N"
 Echo(Enable gravity Y/N?
 For /f "Delims=" %%G in ('Choice /n /c:yn')Do Set "Gravity=!Gravity:%%G=!"
 If not defined Gravity (
  Set "k32="
  Set "Title=Move: W A S D Quit: ESC"
 )Else (
  Set /A "S1Y=S1BB","S3LY=S3Y=Hieght-S3H-1"
  For %%G in (83 87 115 119 "-72" "-80")Do Set "k%%~G="
  Set "Key=Right"
  Set "LastXKey=Right"
  Set "Title=Move: W D Space Quit: ESC"
 )

 Title %Title%
 <nul Set /p "=%\E%[?25l%\E%[1;1H%\E%[48;2;!BG!m%\E%[38;2;!FG!m%\E%[2J%Sprite[1]%%Sprite[2]%%Sprite[3]%%Border%"
 Timeout /t 1 /NoBreak > nul
 

 2> nul (
  For /l %%. in () Do (
   %= Title -!S1Y!,!S1X!-!Relative!-!S2Y!,!S2X! =%
   %= Calculate time elapsed =%
   for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1"
   if !tDiff! lss 0 set /a tDiff+=24*60*60*100
   if !tDiff! geq !delay! (
    Set /A "BGc+=5","t1=t2","S1cR+=1"
    For /L %%i in (2 1 !Sprites!)Do (
     If not %%i equ 3 (
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
     )
     If !s3Dir! EQU 3 If !S3X! NEQ !S3LB! ( Set /A "S3LX=S3X","S3X-=1" )Else Set "s3Dir=4"
     If !s3Dir! EQU 4 If !S3X! NEQ !S3RB! ( Set /A "S3LX=S3X","S3X+=1" )Else Set "s3Dir=3"
     ( Call:Move %%i !S%%iDir! ) || (
      <nul set /p "=%Sprite[1]%%\E%[1;1H%\E%[48;2;!BG!m%\E%[38;2;!FG!m%\E%[0J%Sprite[1]%%Sprite[2]%%Sprite[3]%"
      Echo(M|Choice > nul
      Title Game over. Play Again Y/N?
      Cls
      Timeout /T 3 /Nobreak > nul
      Endlocal
      For /f "delims=" %%C in ('%SystemRoot%\System32\choice.exe /N /C:YN')Do if %%C==Y Start "" "%~f0"
      Exit
     )
    )
    If !BGc! GTR 250 Set "BGc=10"
    If !S1cR! GTR 250 Set "S1cR=50"
    Rem Set "FG=!BGc!;!BGc!;!BGc!"
    Set "FG=50;!S1X!;!S1X!"
    Set "BG=!FG!"
    If defined Gravity If !S1Y! NEQ %S1BBG% (
     Set /A "S1LX=S1X","S1LY=S1Y",S1Y+=1"
     Set "Key=!LastXkey!"
    )
    <nul set /p "=%\E%[1;1H%\E%[48;2;!BG!m%\E%[38;2;!FG!m%\E%[0J%Sprite[1]%%Sprite[2]%%Sprite[3]%"
   )
   %TEMP%\GetKey.exe /n
   If !errorlevel! EQU 27 Exit
   If not !Errorlevel! EQU 0 For %%v in (!Errorlevel!)Do If not "!k%%v!"=="" Set "key=!k%%v!"
   If "!Key!"=="Left" Set "LastXkey=Left"
   If "!Key!"=="Right" Set "LastXkey=Right"
   If Defined Key (
    If "!Key!"=="Up" %Up%
    If "!Key!"=="Down" %Down%
    If "!Key!"=="Left" %Left%
    If "!Key!"=="Right" %Right%
    If "!Key!"=="Jump" %Jump%
   )
  )
 )

 :Move Non player Sprite; enacts collision detection prior to movement. Returns collided sprite in errorlevel
  REM Collision detection method - Bounding box; Application: Alogirthm based conditional Execution
  REM See: http://devmag.org.za/2009/04/13/basic-collision-detection-in-2d-part-1/

  REM Condition tests "((Sum)>>31)" return -1 if condition true ; 0 if false. If sum of conditions EQU 0 (IE: ALL conditions false; Collision true)
  Set "NOTsafe=DeadAsBro"
                  %= If Base1 LSS Top2 =%    %= If Top1 GTR Base2 =%         %= If Right1 LSS Left2 =%    %= If Left1 GTR Right2 =%
  Set /A "Collide=(((S1Y+(S1H-1))-S%1Y)>>31) + (((S%1Y+(S%1H-1))-S1Y)>>31) + (((S1X+S1W)-(S%1X+1))>>31) + (((S%1X+S%1W)-1-S1X)>>31)","1/Collide" && Set "NOTsafe="
  If Defined NOTsafe Exit /b %1
  If not "%~3"=="" Exit /b 0

  Set "UpdateSprite=!Sprite[%1]!"
  If %2 EQU 1 Set "Move=!Up:S1=S%1!"
  If %2 EQU 2 Set "Move=!Down:S1=S%1!"
  If %2 EQU 3 Set "Move=!Left:S1=S%1!"
  If %2 EQU 4 Set "Move=!Right:S1=S%1!"
  <nul Set /p "=%UpdateSprite%"
  %Move%

  REM remove rem below to retest post sprite move
  ( Call:Move %1 %2 retest ) || Exit /B !Errorlevel!
 Exit /b 0

:DefSprite "CELLline\nCELLline" Y X H W "RR GG BB(foreground)" "RR GG BB(background)" [1|2|3|4]
REM   Args 1                    2 3 4 5  6                      7                      8 (Starting Direction)

 Set /A Sprites+=1
 Set "cells=%~1"
 Set /A "SH=%~4"
 Set /A "SW=%~5"
 Set "FGcol=%~6"
 Set "BGcol=%~7"
 Set /A "S%Sprites%LY=%~2,S%Sprites%Y=%~2","S%Sprites%LX=%~3,S%Sprites%X=%~3","S%Sprites%H=SH","S%Sprites%W=SW"
 Set /A "S%Sprites%UB=2","S%Sprites%BBG=Hieght-SH","S%Sprites%BB=Hieght-SH-1","S%Sprites%LB=2","S%Sprites%RB=Width-SW-1"
 Call Set "cells=%%Cells:\n=!\E![!S%Sprites%X!G!\E![1B%%"

 Set "Sprite[%Sprites%]=!\E![!S%Sprites%LY!;!S%Sprites%LX!H!\E![48;2;!BG!m%\E%[38;2;!FG!m%Cells%!\E![!S%Sprites%Y!;!S%Sprites%X!H!\E![48;2;%BGcol%m!\E![38;2;%FGcol%m%Cells%!\E![0m"

 If not "%~8"=="" Set "S%Sprites%Dir=%~8"

Exit /b 0

 :TestVT
  For /F Delims^= %%e in ('Echo prompt $E^|cmd')Do set "\E=%%e"
  <nul set /P "=%\E%[0c"
  %TEMP%\GetKey.exe /n
  if errorlevel 27 (
      for /L %%. in (1 1 10) do (
          %TEMP%\GetKey.exe /n
          if errorlevel 99 (
              exit /B 0
          )
      )
      exit /B 0
  )
  Cls
 exit /B 1

::: Getkey.Exe by Antonio https://www.dostips.com/forum/viewtopic.php?f=3&t=3428#p17101

-----BEGIN CERTIFICATE-----
TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAsAAAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFtIGNhbm5v
dCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAABVtbj9EdTWrhHU1q4R1Nau
n8vFrhjU1q7t9MSuE9TWrlJpY2gR1NauAAAAAAAAAABQRQAATAECAFpm0U8AAAAA
AAAAAOAADwELAQUMAAIAAAACAAAAAAAAABAAAAAQAAAAIAAAAABAAAAQAAAAAgAA
BAAAAAAAAAAEAAAAAAAAAAAwAAAAAgAAAAAAAAMAAAAAABAAABAAAAAAEAAAEAAA
AAAAABAAAAAAAAAAAAAAABggAAA8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAIAAAGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC50ZXh0AAAA
lgAAAAAQAAAAAgAAAAIAAAAAAAAAAAAAAAAAACAAAGAucmRhdGEAALoAAAAAIAAA
AAIAAAAEAAAAAAAAAAAAAAAAAABAAABAAAAAAAAAAADoBgAAAFDocwAAAOhAAAAA
6F8AAACAPgB0GGaBPi9XdAdmgT4vd3QK/xUMIEAAhcB0Gf8VECBAAIXAdAc94AAA
AHUI/xUQIEAA99jDzMzMzOgvAAAAi/CKBkY8InUJigZGPCJ1+esMigZGPCB0BITA
dfVOw4oGRjwgdPlOw8z/JQQgQAD/JQAgQAD/JRAgQAD/JQwgQAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAHogAABsIAAAAAAAAKQgAACaIAAAAAAAAFQgAAAAAAAA
AAAAAIwgAAAAIAAAYCAAAAAAAAAAAAAAriAAAAwgAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAHogAABsIAAAAAAAAKQgAACaIAAAAAAAAJsARXhpdFByb2Nlc3MA5gBHZXRD
b21tYW5kTGluZUEAa2VybmVsMzIuZGxsAADOAF9nZXRjaAAAEQFfa2JoaXQAAG1z
dmNydC5kbGwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
-----END CERTIFICATE-----
