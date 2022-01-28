@Echo off 

:newGame
Title Yahtzee
CLS

REM Yahtzee V 1.0.1 13/01/2022
REM Author: T3RRY
REM 
REM Game Rule Variations:
REM Game Comprises of 16 turns, inclusive of Bonus Yahtzees.
REM Bonus Yahtzee's 1 2 and 3 can be used as zero scoring chances.
REM
REM Gameplay:
REM - You may quit the game after any Roll - You will be asked for confirmationation if you select Quit Game.
REM - At the end of each roll:
REM   - Select Keep beneath each dice you wish to keep [Kept dice are remembered between rolls]
REM   - Select Keep All to toggle between All Dice as selected or unselected. Individual dice may subsequently be deselected.
REM   - You may view the state of assigned scores after each roll by clicking View Scoresheet. Any subsequent click will return you to the game.
REM   - Once you are happy with the dice you have selected, if any, Press Continue to proceede to the next roll
REM - After the third roll, you will immediately progress to the scoring sheet screen.
REM   - Assign your score by clicking the scoring option. If the scoring option is valid, it will be assigned without confirmation. This cannot be undone.
REM   - Attempting to assign a score you haven't achieved [Straights, FullHouse, Xkinds etc] will
REM     allow you the option of sacrificing that scoring option [0 score, Confirmation required]
REM   - You must assign a score to progress to the next turn upon Clicking Continue.
REM 
REM v 1b modifications:
REM  - Incorporated Highscore saves
REM  - Added basic start menu to allow disabling of rolling animation prior to game start.
REM  - changed virtual terminal verification method
REM
REM May be ADDED in furure:
REM  - Animations for Game Start / Yahtzee / Game Over
REM

If "!!"=="" ENDLOCAL
Setlocal EnableExtensions DisableDelayedExpansion

REM Start the program from the command line with any argument to disable the Dice roll animations
Set "DisableDelay=%~1"

REM The below calls a subscript that will request permission to install BG.exe which is required to facilitate
REM clickable buttons. If permission is denied, or your system is not Virtual Terminal compatible, script will abort.
 Call:Buttons def || (
  Pause
  Endlocal & Goto:Eof
 )

 Start /b "" %BG.exe% Play "%WINDIR%\Media\windows unlock.wav"

 Set "HighScore=0"
 2> nul > nul (
  More < "%~f0:Highscore.dat" && (
   For /F "usebackq Delims=" %%G in ("%~f0:Highscore.dat")Do Set "HighScore=%%G"
  ) || (
   %bg.exe% play  "%CD%\Windows Print complete.wav"
   (Echo(0) 1>"%~f0:Highscore.dat"
  )
 )

 Set "TurnCount=0"

REM delay Timing - May not work correctly on NON english based systems [untested].
 For /F "tokens=1,2 delims==" %%G in ('wmic cpu get maxclockspeed /format:value^|%SystemRoot%\System32\Findstr.exe /Li "MaxClockSpeed"')Do Set /A "%%G=%%H" 2> nul
 If not Defined MaxClockSpeed Set "MaxClockSpeed=2000"
 Set /A "DelayBase=(MaxClockSpeed * (Number_Of_Processors*Number_Of_Processors)) - 250","EORdelay=(DelayBase/2)*5"

REM macro used to constrain randomized face to an adjacent side within a for loop without Goto.
 Set "ConstrainFlip=Set /A "F#=!Random! %% 6 + 1","1/(Old-F#)",!Side[%%~v]! ||"

REM Die FG / BG properties [\E7m inverts] 
REM - Virtual terminal variable \E definiton and code page handled within :buttons function
 Set "DB=%\E%[0m%\E%[38;2;;;m%\E%[48;2;200;;m%\E%[7m"

REM Die animation macros.
 REM Macros used to display static list of rolled dice
  Set "dcol=%\E%[0m%\E%[33;1;7m%\E%[48;2;200;;m" %= Dice background / foreground color =%
  Set "fc=%\E%[48;2;155;;200m☻%dcol%"            %= Dice pip foreground color and character + background reset =%
  Set "d\n=%\E%[1B%\E%[7D"                       %= VT sequences position cursor ready for dices next line =%
  Set "d\e=%\E%[0m%\E%[4A"                %= VT sequences position cursor for next dice [top left] =%
  Set "d1=%\E%C%dcol%╔═════╗%d\n%║     ║%d\n%║  %fc%  ║%d\n%║     ║%d\n%╚═════╝%d\e%"
  Set "d2=%\E%C%dcol%╔═════╗%d\n%║%fc%    ║%d\n%║     ║%d\n%║    %fc%║%d\n%╚═════╝%d\e%"
  Set "d3=%\E%C%dcol%╔═════╗%d\n%║%fc%    ║%d\n%║  %fc%  %dcol%║%d\n%║    %fc%║%d\n%╚═════╝%d\e%"
  Set "d4=%\E%C%dcol%╔═════╗%d\n%║%fc%   %fc%║%d\n%║     %dcol%║%d\n%║%fc%   %fc%║%d\n%╚═════╝%d\e%"
  Set "d5=%\E%C%dcol%╔═════╗%d\n%║%fc%   %fc%║%d\n%║  %fc%  %dcol%║%d\n%║%fc%   %fc%║%d\n%╚═════╝%d\e%"
  Set "d6=%\E%C%dcol%╔═════╗%d\n%║%fc%   %fc%║%d\n%║%fc%   %fc%║%d\n%║%fc%   %fc%║%d\n%╚═════╝%d\e%"
 REM Restore cursor;Cusor Down;Cursor left;Save Cursor
  Set "\c=%\E%8%\E%[B%\E%7!DB!"
 REM Face Strings, Split via substring every 3rd character to create the 3 lines comprising the die face interior for a given side.
  Set "F1=    ☻    "
  Set "F2=☻       ☻"
  Set "F3=☻   ☻   ☻"
  Set "F4=☻ ☻   ☻ ☻"
  Set "F5=☻ ☻ ☻ ☻ ☻"
  Set "F6=☻ ☻☻ ☻☻ ☻"

REM macros used to enforce natural flips of the dice during rolling sequence by excluding opposing side from RNG.
 Set Side[1]="1/(6-F#)"
 Set Side[2]="1/(5-F#)"
 Set Side[3]="1/(4-F#)"
 Set Side[4]="1/(3-F#)"
 Set Side[5]="1/(2-F#)"
 Set Side[6]="1/(1-F#)"

 Set "Scored=%\E%[2;11H%\E%[35m !Scored[1]!%\E%[5;11H !Scored[2]!%\E%[8;11H !Scored[3]!%\E%[11;11H !Scored[4]!%\E%[14;11H !Scored[5]!%\E%[17;11H !Scored[6]!"
 Set "Scored=%Scored%%\E%[20;11H !Scored[Yahtzee]!%\E%[2;37H !Scored[ThreeOfAKind]!%\E%[5;37H !Scored[FourOfAKind]!%\E%[8;37H !Scored[FullHouse]!%\E%[11;37H !Scored[SmallStraight]!"
 Set "Scored=%Scored%%\E%[14;37H !Scored[LargeStraight]!%\E%[17;37H !Scored[Chance]!%\E%[20;37H !Scored[BY1]! !Scored[BY2]! !Scored[BY3]!%\E%[0m"

 Setlocal EnableDelayedExpansion

REM Make.Btn MacroArgs GroupName /S "Button Text" /BG background Color /FG Foreground Color /BO BorderColor /t togglebutton=true  /Y Yposition /X Xposition

REM %Make.Btn% Menu /S Start /Y 5
REM %Make.Btn% Menu /S "Disable roll animation" /t
 If defined DisableDelay Set "Btn[Menu][2]{state}=true"

 %Make.Btn% Dice /S " Keep" /BG 180 0 0 /FG 0 250 0 /BO 38 2 0 160 120 + 48 2 80 0 120 /t /Y 20 /X 1
 %Make.Btn% Dice /S " Keep" /BG 180 0 0 /FG 0 250 0 /BO 38 2 0 160 120 + 48 2 80 0 120 /t /Y 20 /X 8
 %Make.Btn% Dice /S " Keep" /BG 180 0 0 /FG 0 250 0 /BO 38 2 0 160 120 + 48 2 80 0 120 /t /Y 20 /X 15
 %Make.Btn% Dice /S " Keep" /BG 180 0 0 /FG 0 250 0 /BO 38 2 0 160 120 + 48 2 80 0 120 /t /Y 20 /X 22
 %Make.Btn% Dice /S " Keep" /BG 180 0 0 /FG 0 250 0 /BO 38 2 0 160 120 + 48 2 80 0 120 /t /Y 20 /X 29

 %Make.Btn% KeepAll /S "Keep All Dice" /BG 180 0 0 /FG 0 250 0 /BO 38 2 0 160 120 + 48 2 80 0 120 /t /Y 23 /X 11
 %Make.Btn% Control /S "Continue" /BG 0 90 120 /FG 255 255 255 /Y 23 /X 1
 %Make.Btn% Control /S "Quit Game" /BG 150 0 120 /FG 255 255 255 /Y 23 /X 26
 %Make.btn% Control /S ? /Y 23 /X 37 /t /d
 %Make.Btn% ScoreSheet /S "         View ScoreSheet            " /BG 150 0 120 /FG 255 255 255 /Y 26 /X 1
 %Make.Btn% Hold /S "            Continue                " /BG 0 90 120 /FG 255 255 255 /Y 26 /X 1

 %Make.btn% Scoring /S "    Ones" /Y 2 /X 1 /N /T
 %Make.btn% Scoring /S "    Twos" /T
 %Make.btn% Scoring /S "  Threes" /T
 %Make.btn% Scoring /S "   Fours" /T
 %Make.btn% Scoring /S "   Fives" /T
 %Make.btn% Scoring /S "   Sixes" /T
 %Make.btn% Scoring /S "Three of a Kind" /Y 2 /X 20 /T
 %Make.btn% Scoring /S " Four of A Kind" /X 20 /T
 %Make.btn% Scoring /S "     Full House" /X 20 /T
 %Make.btn% Scoring /S " Small Straight" /X 20 /T
 %Make.btn% Scoring /S " Large Straight" /X 20 /T
 %Make.btn% Scoring /S "         Chance" /X 20 /T
 %Make.btn% Scoring /S " Yahtzee" /X 1 /T
 %Make.btn% Scoring /S "BY1" /Y 20 /X 20 /T
 %Make.btn% Scoring /S "BY2" /Y 20 /X 25 /T
 %Make.btn% Scoring /S "  BY3" /Y 20 /X 30 /T
 
 Set "BG=%\E%[7m%\E%[1;1H%\E%[48;2;;;120m%\E%[K"
 For /L %%i in (2 1 12)Do Set "BG=!BG!%\E%[1E%\E%[48;2;40;80;0m%\E%[K"
 Set "BG=!BG!%\E%[1E%\E%[48;2;;;120m%\E%[K"

:StartMenu
REM %Get.Click% Menu
REM %If.btn[Menu]%[1] Goto:Turn
REM %If.btn[Menu]%[2] (
REM  if "!Btn[Menu][2]{state}!"=="true" (
REM   Set "DisableDelay=true"
REM  )Else Set "DisableDelay="
REM )
REM Goto:StartMenu

 Call:YesNo "Animation Disabled" "Normal Mode" "Welcome^!"
 If "!Clicked[YN]!"=="Normal Mode" Goto:Turn
 Set "DisableDelay=true"

:Turn
 If defined DisableDelay Set "Btn[Control][3]{state}=false"
 cls
 Mode 180,40
 Set "RollCount=0"
 If !TurnCount! EQU 16 (
  Set /A Upperscore=TotalScore=Scored[UpperBonus]=0
  For /l %%i in (1 1 6)Do Set /A "Upperscore+=Scored[%%i]"
  If !UpperScore! GEQ 63 Set "Scored[UpperBonus]=35"
  For /f "tokens=2 Delims==" %%G in ('Set Scored[')Do Set /A "TotalScore+=%%G"
  Set /A "LowerScore=TotalScore-UpperScore-Scored[UpperBonus]"
  If !TotalScore! GTR !HighScore! (
   (Echo(!TotalScore!) 1>"%~f0:Highscore.dat"
   %bg.exe% play "%Windir%\Media\Windows Print complete.wav"
   Title New HighScore: !TotalScore!
  )
  CLS
  Echo( %\E%[0m%\E%[31m%\E%[7m%\E%[K Your Score:%\E%[33m
  Echo( Upper:%\E%[32m!UpperScore!%\E%[33m UpperBonus:%\E%[32m!Scored[UpperBonus]!%\E%[33m Lower:%\E%[32m!LowerScore! %\E%[33mTotal:%\E%[32m!TotalScore!%\E%[0m%\E%[1E
  Timeout /T 5
  Call:yesNo "Play Agian" "Quit" "Game Over"
  If Errorlevel 2 (
   Endlocal & Endlocal
   Exit /b 0
  )
  Endlocal & Endlocal & Set "DisableDelay=%DisableDelay%"
  Goto:NewGame
 )

(For /F "tokens=1,2 Delims==" %%G in ('Set "Roll["')Do Set "%%G=") 2> nul
 Call :#Rolls 5
 Set /A #StdOut=1
 Call:DiceSelect || (Endlocal & Exit /b)
 If not !Kept! EQU 5 Call :SortRolls Roll Roll[i] !$Roll! !nDice!
 If not !Kept! EQU 5 Call :#Rolls 5
 If not !Kept! EQU 5 Call:DiceSelect || (Endlocal & Exit /b)
 If not !Kept! EQU 5 Call :SortRolls Roll Roll[i] !$Roll! !nDice!
 If not !Kept! EQU 5 Call :#Rolls 5
 If not !Kept! EQU 5 Call :SortRolls Roll Roll[i] !$Roll!
 If not !Kept! EQU 5 Call :SortRolls Roll Roll[i] !$Roll!
 Call:TestRoll
 Set /A "TurnCount+=1"
 
 For /l %%i in (1 1 5)Do Set "Btn[dice][%%i]{state}=false")

Goto:Turn

REM Script Break

:DiceSelect =========================== Button Menu Logic for dice retention
 Set "nDice="
 Set "Btn[KeepAll][1]{state}=false"

 :KeepX
 If "!btn[Control][3]{state}!"=="false" (
  Set "DisableDelay=true"
 )Else Set "DisableDelay="

 Set "Kept=0"
 %Get.Click% Dice Control KeepAll ScoreSheet
 If "!Group!" == "ScoreSheet" (
  %Buffer:@=Alt%
  For /l %%i in (1 1 16)Do If "!Btn[Scoring][%%i]{state}!"=="true" (
   set "tmpstr=!Btn[Scoring][%%i]:38=7;38!"
   <nul set /P "=!tmpstr:48=7;48!"
  )Else Echo(!Btn[Scoring][%%i]!
  Echo(%Scored%
  %Get.Click% Hold
  %Buffer:@=Main%
 )Else IF "!Group!" == "KeepAll" (
  For /L %%i in (1 1 5)Do If "!Btn[KeepAll][1]{state}!"=="true" (
   Set "Btn[Dice][%%i]{state}=true
  )Else (
   Set "Btn[Dice][%%i]{state}=false"
  )
 )Else IF "!Group!" == "Control" (
  %If.Btn[Control]%[3] Goto:KeepX
  %If.Btn[Control]%[2] (
   Call:YesNo Quit Return "Are you Sure?"
   If /I "!Clicked[YN]!"=="Quit" Exit /B 1
   Goto:KeepX
  )
  For /l %%i in (1 1 5)Do (
   If "!btn[Dice][%%i]{state}!"=="false" (
    Set "Roll[%%i]="
   )Else (
    Set /A "Kept+=1"
    If defined nDice (
     Set "nDice=!nDice! !Roll[%%i]!"
    )Else (
     Set "nDice=!Roll[%%i]!"
    )
   )
  )
  Exit /B 0
 )
 Goto:KeepX

Exit /b 0

:TestRoll ======================== Assess Roll outcomes and define scoring array

 Set /A "Chance[score]=Roll[1]+Roll[2]+Roll[3]+Roll[4]+Roll[5]","ThreeOfAKind[Score]=Chance[score]","FourOfAKind[Score]=Chance[score]","FullHouse[Score]=25","Yahtzee[score]=50"
 Set /A "SmallStraight[score]=30","LargeStraight[score]=40"
 Set "Scoreset=!Roll[1]!!Roll[2]!!Roll[3]!!Roll[4]!!Roll[5]!"

 Set "[1][score]=0"
 Set "null=%Scoreset:1="& Set /A "[1][score]+=1" & Set "null=%"
 Set "[2][score]=0"
 Set "null=%Scoreset:2="& Set /A "[2][score]+=2" & Set "null=%"
 Set "[3][score]=0"
 Set "null=%Scoreset:3="& Set /A "[3][score]+=3" & Set "null=%"
 Set "[4][score]=0"
 Set "null=%Scoreset:4="& Set /A "[4][score]+=4" & Set "null=%"
 Set "[5][score]=0"
 Set "null=%Scoreset:5="& Set /A "[5][score]+=5" & Set "null=%"
 Set "[6][score]=0"
 Set "null=%Scoreset:6="& Set /A "[6][score]+=6" & Set "null=%"

 Set "Yahtzee=false"
 Set "Fullhouse=false"
 Set "ThreeOfAKind=false"
 Set "FourOfAKind=false"

 For /l %%1 in (1 1 6)Do For /L %%2 in (1 1 6)Do (
  For %%G in ("%%1%%1%%1%%2%%2" "%%1%%1%%2%%2%%2")Do if "%%~G" == "!Roll[1]!!Roll[2]!!Roll[3]!!Roll[4]!!Roll[5]!" (
   Set "ThreeOfAKind=true"
   if not "%%1"=="%%2" (
    Set "FullHouse=true"
   )Else (
    Set "Yahtzee=true"
    Set "FourOfAKind=true"
 )))

 If not "!FourOfAKind!"=="true" For /l %%1 in (1 1 6)Do For /L %%2 in (1 1 6)Do if not "%%1"=="%%2" (
  For %%G in ("%%1%%1%%1%%1%%2" "%%2%%1%%1%%1%%1")Do if "%%~G" == "!Roll[1]!!Roll[2]!!Roll[3]!!Roll[4]!!Roll[5]!" (
   Set "FourOfAKind=true"
   Set "ThreeOfAKind=true"
 ))

 If not "!ThreeOfAKind!"=="true" For /l %%1 in (1 1 6)Do (
  For %%G in (".%%1%%1%%1." "..%%1%%1%%1" "%%1%%1%%1..")Do For %%H in ("!Roll[1]!!Roll[2]!!Roll[3]!" "!Roll[2]!!Roll[3]!!Roll[4]!" "!Roll[3]!!Roll[4]!!Roll[5]!")Do (
   if "%%~G" == ".%%~H." (
    Set "ThreeOfAKind=true"
   )
   if "%%~G" == "..%%~H" (
    Set "ThreeOfAKind=true"
   )
   if "%%~G" == "%%~H.." (
    Set "ThreeOfAKind=true"
 )))

 Set "LargeStraight=false"
 Set "SmallStraight=false"
 For %%G in (12345 23456)Do if "%%G" == "!Roll[1]!!Roll[2]!!Roll[3]!!Roll[4]!!Roll[5]!" (
  Set "LargeStraight=true"
  Set "SmallStraight=true"
 )

 
 If not "!SmallStraight!"=="true" For %%G in (11234 12234 12334 12344 12346 13456 22345 23345 23445 23455 33456 34456 34556 34566)Do (
  if "%%G" == "!Roll[1]!!Roll[2]!!Roll[3]!!Roll[4]!!Roll[5]!" (
   Set "SmallStraight=true"
 ))

=========================================================== REM score Assignment via button input
 Set "ScoreAssigned="
 :ScoreMenu
 Cls
 Echo(%Scored%

 Echo(%\E%[28;1H
 For /L %%i in (1 1 5)Do For %%v in (!Roll[%%i]!)Do <nul Set /p"=!d%%v!"
 Echo(%\E%[1;1H
 %Get.Click% Scoring Hold
 If "!Group!"=="Hold" (
  If Defined ScoreAssigned (
    Exit /B 0
  )Else (
   Start /b "" %BG.exe% play "%WINDIR%\Media\Windows Error.wav"
   Goto:ScoreMenu
  )
 )

 For /l %%i in (1 1 6)Do %If.Btn[Scoring]%[%%i] (
  Set "Btn[Scoring][%%i]{state}=false"
  If not defined ScoreAssigned (
   If not defined Scored[%%i] (
    Set /A Scored[%%i]=[%%i][Score],ScoreAssigned=1
  ))
  If defined Scored[%%i] Set "Btn[Scoring][%%i]{state}=true"
 )

 %If.Btn[Scoring]%[7] (
  Set "Btn[Scoring][7]{state}=false"
  If not defined ScoreAssigned (
   If "!ThreeOfAKind!"=="true" (
    If not defined Scored[ThreeOfAKind] (
     Set /A Scored[ThreeOfAKind]=ThreeOfAKind[Score],ScoreAssigned=1
    )
   )Else If not defined Scored[ThreeOfAKind] (
    Call :YesNo Yes No "Sacrifice Three of a Kind?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[ThreeOfAKind]=0",ScoreAssigned=1
   )
  )
  If defined Scored[ThreeOfAKind] Set "Btn[Scoring][7]{state}=true"
 )

 %If.Btn[Scoring]%[8] (
  Set "Btn[Scoring][8]{state}=false"
  If not defined ScoreAssigned (
   If "!FourOfAKind!"=="true" (
    If not defined Scored[FourOfAKind] (
     Set /A Scored[FourOfAKind]=FourOfAKind[Score],ScoreAssigned=1
    )
   )Else If not defined Scored[FourOfAKind] (
    Call :YesNo Yes No "Sacrifice Four of a Kind?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[FourOfAKind]=0",ScoreAssigned=1
   )
  )
  If defined Scored[FourOfAKind] Set "Btn[Scoring][8]{state}=true"
 )

 %If.Btn[Scoring]%[9] (
  Set "Btn[Scoring][9]{state}=false"
  If not defined ScoreAssigned (
   If "!FullHouse!"=="true" (
    If not defined Scored[FullHouse] (
     Set /A Scored[FullHouse]=FUllHouse[Score],ScoreAssigned=1
    )
   )Else If not defined Scored[FullHouse] (
    Call :YesNo Yes No "Sacrifice Fullhouse?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[FullHouse]=0",ScoreAssigned=1
   )
  )
  If defined Scored[FullHouse] Set "Btn[Scoring][9]{state}=true"
 )

 %If.Btn[Scoring]%[10] (
  If not defined Scored[SmallStraight] Set "Btn[Scoring][10]{state}=false"
  If not defined ScoreAssigned (
   If "!SmallStraight!"=="true" (
    If not defined Scored[SmallStraight] (
     Set /A Scored[SmallStraight]=Smallstraight[Score],ScoreAssigned=1
    )
   )Else If not defined Scored[SmallStraight] (
    Call :YesNo Yes No "Sacrifice Small Straight?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[SmallStraight]=0",ScoreAssigned=1
   )
  )
  If defined Scored[SmallStraight] Set "Btn[Scoring][10]{state}=true"
 )

 %If.Btn[Scoring]%[11] (
  If not defined Scored[LargeStraight] Set "Btn[Scoring][11]{state}=false"
  If not defined ScoreAssigned (
   If "!LargeStraight!"=="true" (
    If not defined Scored[LargeStraight] (
     Set /A Scored[LargeStraight]=LargeStraight[Score],ScoreAssigned=1
    )
   )Else If not defined Scored[LargeStraight] (
    Call :YesNo Yes No "Sacrifice Large Straight?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[LargeStraight]=0",ScoreAssigned=1
   )
  )
  If defined Scored[LargeStraight] Set "Btn[Scoring][11]{state}=true"
 )

 %If.Btn[Scoring]%[12] (
  Set "Btn[Scoring][12]{state}=false"
  If not defined ScoreAssigned (
   If not defined Scored[Chance] (
    Set /A Scored[Chance]=Chance[Score],ScoreAssigned=1
  ))
  If defined Scored[Chance] Set "Btn[Scoring][12]{state}=true"
 )

 %If.Btn[Scoring]%[13] (
  Set "Btn[Scoring][13]{state}=false"
  If not defined ScoreAssigned (
   If "!Yahtzee!"=="true" (
    If not defined Scored[Yahtzee] (
     Set /A Scored[Yahtzee]=Yahtzee[Score],ScoreAssigned=1
    )
   )Else If not defined Scored[Yahtzee] (
    Call :YesNo Yes No "Sacrifice Yahtzee?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[Yahtzee]=0",ScoreAssigned=1
   )
  )
  If defined Scored[Yahtzee] Set "Btn[Scoring][13]{state}=true"
 )

 %If.Btn[Scoring]%[14] (
  Set "Btn[Scoring][14]{state}=false"
  If not defined ScoreAssigned (
   If "!Yahtzee!"=="true" (
    If defined Scored[Yahtzee] If not defined Scored[BY1] (
     Set /A "Scored[BY1]=Scored[Yahtzee]*2",ScoreAssigned=1
    )
   )Else If not defined Scored[BY1] (
    Call :YesNo Yes No "Sacrifice Bonus Yahtzee 1?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[BY1]=0",ScoreAssigned=1
   )
  )
  If defined Scored[BY1] Set "Btn[Scoring][14]{state}=true"
 )

 %If.Btn[Scoring]%[15] (
  Set "Btn[Scoring][15]{state}=false"
  If not defined ScoreAssigned (
   If "!Yahtzee!"=="true" (
    If defined Scored[Yahtzee] If not defined Scored[BY2] (
     Set /A "Scored[BY2]=Scored[Yahtzee]*2",ScoreAssigned=1
    )
   )Else If Defined Scored[BY1] If not defined Scored[BY2] (
    Call :YesNo Yes No "Sacrifice Bonus Yahtzee 2?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[BY2]=0",ScoreAssigned=1
   )
  )
  If defined Scored[BY2] Set "Btn[Scoring][15]{state}=true"
 )

 %If.Btn[Scoring]%[16] (
  Set "Btn[Scoring][16]{state}=false"
  If not defined ScoreAssigned (
   If "!Yahtzee!"=="true" (
    If defined Scored[Yahtzee] If not defined Scored[BY3] (
     Set /A "Scored[BY3]=Scored[Yahtzee]*2",ScoreAssigned=1
    )
   )Else If Defined Scored[BY2] If not defined Scored[BY3] (
    Call :YesNo Yes No "Sacrifice Bonus Yahtzee 3?"
    If /I "!Clicked[YN]!" == "Yes" Set /A "Scored[BY3]=0",ScoreAssigned=1
   )
  )
  If defined Scored[BY3] Set "Btn[Scoring][16]{state}=true"
 )

Goto:ScoreMenu

:SortRolls ======================= <Element_VarName> <Element_Index_VarName>
 Set /a "Max=%2+1"
 For /L %%a In (0,1,!Max!)Do (
  Set /A "S_Offset=%%a - 1"
  For /L %%b IN (0,1,%%a)Do (
   If not %%b==%%a For %%c in (!S_Offset!)Do (
    If defined %1[%%c] IF !%1[%%c]! LEQ !%1[%%b]! (
     Set "tmpV=!%1[%%c]!"
     Set "tmpS=!btn[Dice][%%c]{state}!"
     Set "%1[%%c]=!%1[%%b]!"
     Set "%1[%%b]=!tmpV!"
  REM swap state of dice retention if defined
     If defined tmpS If defined btn[Dice][%%b]{state} (
      Set "btn[Dice][%%c]{state}=!btn[Dice][%%b]{state}!"
      Set "btn[Dice][%%b]{state}=!tmpS!"
     )
 ))))
Exit /B 0


:#Rolls ===================== Enact Individual Die Rolls For any Dice to be rolled / not retained
 Set /A RollCount+=1
 TITLE Turn:!TurnCount! -- Roll: !RollCount! -- HighScore:!HighScore!
 Cls
 <nul Set /p "=%\E%[14;1H"
 For /L %%i in (1 1 5)Do For %%v in ("!Roll[%%i]!")Do if not "!Roll[%%i]!"=="" (
  <nul Set /P "=!d%%~v!"
 )

 Set "$Roll="
 If not "%~1"=="" (%= Enact for /l loop only if arg 1 a positive integer =%
  Set /A "Roll[i]=%~1","1/(%~1>>31)" 2> nul || Set /a "1/%~1" 2> nul && For /L %%R in (1 1 %~1)Do If "!Roll[%%R]!"=="" (
   Set /A "Y=2,X=1","Old=!Random! %%6 +1","Mod=!Random! %%3 + 6","Flips=!Random! %%Mod + Mod"
   For /l %%i in (!Flips! -1 1)Do (%= Naturally flip die a random number of times =%
    Set /A "Delay=(DelayBase / (%%i+1/2))*4"
    2> nul (
     For %%v in ("!Old!")Do (
      REM enforce natural flips of the dice during the roll - Each side cannot flip to itself or its opposing side.
      Set /A "F#=!Random! %% 6 + 1","1/(Old-F#)",!Side[%%~v]! || (
       %ConstrainFlip% (
        %ConstrainFlip% (
         %ConstrainFlip% (
          %ConstrainFlip% (
           %ConstrainFlip% (
            %ConstrainFlip% (
             %ConstrainFlip% (
              %ConstrainFlip% (
               %ConstrainFlip% (
                %ConstrainFlip% (
                 %ConstrainFlip% (
                  %= Reroll probability failure to constrain Flip to adjacent side is approx 0 - NOT non-zero. =%
                  %= No failures in 600000 test flips. In case of Failure - 'slide' on current face. =%
                  Set "F#=!Old!"
    ))))))))))))))
    Set /A "Old=!F#!"
    For %%v in ("!F#!")Do Echo(%\E%[?25l%BG%%\E%[!y!;!x!H%\E%7!DB!╔═════╗%\c%║ !F%%~v:~0,3! ║%\c%║ !F%%~v:~3,3! ║%\c%║ !F%%~v:~6,3! ║%\c%╚═════╝%\c%%\E%[13;1H%\E%[48;2;10;10;10m%\E%[K%\E%[48;2;;;120m%\E%[K%\E%[1E%\E%[0m
    If not Defined DisableDelay For /l %%z in (1 1 !Delay!)Do REM ANIMATION DELAY-FLIP
    Set /A "X+=%%i+(!Random! %%7 - 2)","LY=Y"
    Rem Restrict Y value to random range range 2-8. Modulo of X value by Flip number used to implement approximation of bouncing
    Set /A "Y=(X %% %%i-2)","1/(-1-(Y>>31))","1/Y","1/(8/Y)","1/(Y-1)" 2> nul || Set /A "Y=LY+1","1/(8/Y)" 2> nul || Set /A "Y=LY"
   )
   Set "Roll[%%R]=!F#!"
   Set "Roll[i]=%%R"
   Set "$Roll=!$Roll! !F#!"
   Call:SortRolls Roll 5
   <nul Set /p "=%\E%[14;1H"
   For /L %%i in (1 1 5)Do For %%v in ("!Roll[%%i]!")Do if not "!Roll[%%i]!"=="" (
    <nul Set /P "=!d%%~v!"
   )
   If not Defined DisableDelay For /l %%z in (1 1 !EORdelay!)Do REM ANIMATION DELAY-END OF ROLL
   <nul Set /P "=%\E%[1;1H%\E%7"
   <nul Set /p "=%\E%[13;1H"
  )
 )
 If Defined DisableDelay For /l %%z in (1 1 !EORdelay!)Do REM DELAY-END OF ROLL reduce risk of clicking continue unintentionally
Exit /B 0


:Buttons ================== Macro definitions and exe creation to facilitate Button Input.

REM ** IMPORTANT NOTE: WINDOWS 11 has different Virtual terminal Syntax which broke this script.
REM scipt has been updated to resolve this issue, by replacing previous supported Syntax for moving cursor 
REM up \EA down \EB Left \ED right \EC with explicit values: up \E[1A down \E[1B Left \E[1D right \E[1C

:# As exampled at: https://youtu.be/ZYhvUbek4Xc

:# Batch clickable button macros and example functions
:# Author: T3RRY Version: 2.0.5 Last Update: 11/01/2022
:# New features:
:# Added 'def' arg to allow this file to be called to define macros for use in a calling file.
:#  - Note:
:#        - Delayed Expansion be DISabled prior to defining macros
:#        - Delayed Expansion must be ENabled to expand macros
:# Expanded help information
:# Reduced number of macros and functions to simplify usage
:# Added new switches to make.btn for controlling button toggle type and defaults
:# Added prompt for permission to install bg.exe ; a required component of this file.

:testEnviron
 If "!!" == "" (Goto :button_help)
 Set "Buttons_File=%~f0"

(Set \n=^^^

%= \n macro newline variable. Do not modify =%)
(Set LF=^


%= LF newline variable. Do not modify =%)

CLS

====================:# OS Requirement tests
:# Verify NTFS drive ** ADS Used to store Settings applied in demo function ColorMod
 (Echo(verify.NTFS >"%~f0:Status") || (
  Echo(This file must be located on an NTFS drive as it utilises Alternate Data Streams.
  Pause
  Exit /B 1
 )

 For /f "Delims=" %%e in ('Echo(Prompt $E^|cmd')Do Set "\E=%%~e"

 Call:TestVT || Exit /B 1

:# Buttons macro Based on function at: https://www.dostips.com/forum/viewtopic.php?f=3&t=9222

:# Script Structure:
:# OS and Exe Validation
:# - Variable and macro Setup
:#  - Functions
:#   - Macro help handling
:#    - [Script Break - Jump to :Main]
:#     - Embedded Exe for Mouse and Key Inputs
:#      - Main script body

 Set "reg.restore=(Call )"

:# disable QuickEdit if enabled. Restored at :end label if disabled by script
  For /f "skip=1 Tokens=3" %%G in ('reg query HKEY_CURRENT_USER\console\ /v Quickedit')Do Set "QE.reg=%%G"
   If "%QE.reg%" == "0x1" (
   (Reg add HKEY_CURRENT_USER\console\ /v QuickEdit /t REG_DWORD /d 0x0 /f) > nul
   Set "reg.restore=Reg add HKEY_CURRENT_USER\console\ /v QuickEdit /t REG_DWORD /d 0x1 /f"
  )

 If not exist "%TEMP%\BG.exe" (
  Echo(%\E%[33mThis program requires Bg.exe to run.%\E%[0m
  Echo( Install from this file %\E%[32m[Y]%\E%[0m or Exit %\E%[31m[N]%\E%[0m ?
  For /f "delims=" %%C in ('%SystemRoot%\System32\choice.exe /N /C:YN')Do if %%C==Y (
   Certutil -decode "%~f0" "%TEMP%\BG.exe" > nul
  )Else Exit /B 1
  Cls
 )

 Set BG.exe="%TEMP%\BG.exe"

 For /f "tokens=4 Delims=: " %%C in ('CHCP')Do Set "active.cp=%%C"
 chcp 65001 > nul

 Set "/??=0"
:#0  \E33m
:#0 Call this file with one of the below macro or function \E37mNames\E33m
:#0 to see it's full usage information.
:#0  \E36m
:#0 Macros: \E37m
:#0  Make.Btn   \E38;2;61;61;61m %Make.Btn% GroupName /S button text \E37m
:#0  Get.Click  \E38;2;61;61;61m %Get.Click% GroupName OtherGroupName \E37m
:#0  If.Btn     \E38;2;61;61;61m %If.Btn[Groupname]%[#] command \E37m
:#0  Buffer     \E38;2;61;61;61m %Buffer:@=Alt% \E37m
:#0             \E38;2;61;61;61m %Buffer:@=Main% \E37m
:#0  Clean.Exit \E38;2;61;61;61m %Clean.Exit%
:#0  \E36m
:#0 Functions: \E37m
:#0  YesNo      \E38;2;61;61;61m Call :YesNo "Option 1" "Option 2" "Spoken Prompt"
:#0  \E36m
:#0 Define macros for use in a calling .bat or .cmd script: \E37m
:#0  Call buttons.bat def
:#0 

 Set "Buffer?=1"
:#1 \E36m
:#1 Usage:   %Buffer:@=Alt%
:#1 \E0m          - Switch to Alt buffer; preserving content of main screen buffer.
:#1 \E36m
:#1          %Buffer:@=Main%
:#1 \E0m          - Returns to main screen buffer.
:#1
 Set "Buffer.Hash=@"
 Set "Buffer=If not "!Buffer.Hash!"=="@" ( <nul set /p "=!@!" )Else (Cls&Call "%~f0" Buffer&Call Echo(%\E%[31mUsage Error in %%0 - Missing or Incorrect Substitution^^!%\E%[0m&Pause &Exit)"
 Set "Alt=%\E%[?1049h%\E%[?25l"
 Set "Main=%\E%[?25h%\E%[?1049l%\E%[?25l"

:# button sound fx. disable by undefining buttonsfx below ; prior to definition of OnCLick macro
 Set "buttonsfx=On"
 %BG.exe% Play "%WINDIR%\Media\Windows Feed Discovered.wav"
 Set "OnClick=(Call )"
 Set "OnType=(Call )"
 If defined buttonsfx (
  For /f "Delims=" %%G in ('Dir /b /s "%WINDIR%\SystemApps\*KbdKeyTap.wav"')Do If exist "%%~G" Set "OnClick=(Start /b "" %BG.exe% Play "%%~G")"
  Set "OnType=(start /b "" %BG.exe% Play "%WINDIR%\Media\Windows Feed Discovered.wav")"
 )

 Set "Get.Click?=2"
:#2 \E36m
:#2 Usage: %Get.Click% \E0m{^<\E31mGroupName\E0m^> ^| ^<\E31mGroupName\E0m^> ^<\E31mOtherGroupName\E0m^>}
:#2 \E33m
:#2 Performs the following Actions: \E0m
:#2  - Launches Bg.exe with mouse arg to get mouse click
:#2  - Assigns 1 indexed Y;X pos of mouse click to c{Pos}
:#2  - Performs a conditional comparison via substring modifications
:#2    of all buttons Coordinates defined in each btn[GroupName] array
:#2    matching against the Y;X value of c{Pos}
:#2 \E33m
:#2 On clicked position matching a buttons defined Coordinates: \E0m
:#2  - If %Make.Btn% /T or /TM Switches used to define defined btn[Groupname][Index]{t}:
:#2    - /T:
:#2      - Toggles button visually by inverting colors
:#2      - Toggles btn[Groupname][Index]{state} variable value: true / false
:#2    - /TM:
:#2      - Forces btn[Groupname][Index]{state} true for clicked button.
:#2      * Use In conjunction with /D 'default' or /CD 'Conditional Default' switch
:#2        when a mandatory single selection is required.
:#2  - Defines the following:
:#2     If.btn[GroupName]=\E35mIf [Groupname][Index] == [GroupName]\E0m
:#2     Group=GroupName
:#2     Clicked[Groupname]=Button Text
:#2     ValidClick[GroupName]=[GroupName][Index]
:#2     - Tip reference values directly using: \E36m
:#2       !Clicked[%Group%]!
:#2       !ValidClick[%Group%]!  \E0m
:#2  - Plays the system file KbdKeyTap.wav [If Present] as a clicking sound.
:#2 \E33m
:#2 On clicked position not matching a buttons defined Coordinates: \E0m
:#2  - Defines:
:#2     If.btn[GroupName]=\E36mIf Not.Clicked ==\E0m
:#2  - Undefined:
:#2     Group
:#2      - To loop to a label and wait for a valid click of any
:#2        button defined to a supplied GroupName, Use:
:#2        \E36mIf not defined Group Goto :\E33mlabel\E0m
:#2     Clicked[Groupname]
:#2     ValidClick[GroupName]
:#2 
 Set "If.Btn?=4"
:#4 \E36m
:#4 Usage: %If.btn\E35m[GroupName]\E36m%\E31m[Index] \E90m(Command)\E0m
:#4 
:#4  -\E33m Compares clicked button \E0m[GroupName][Index]\E33m against \E0m[Groupname]\E31m[arg]\E0m
:#4 

:# return button click coords in c{pos} variable n Y;X format
 Set Get.Click=For %%n in (1 2)Do if %%n==2 (%\n%
  Set "Group="%\n%
  For %%G in (!GroupName!)Do (%\n: Update display of toggle state =%
   For /l %%i in (1 1 !Btns[%%G][i]!)Do (%\n%
    If not "!Btn[%%G][%%i]{state}!"=="true" (%\n%
     ^<nul set /P "=!Btn[%%G][%%i]!"%\n%
    )Else If Defined Btn[%%G][%%i]{t} (%\n%
     set "tmpstr=!Btn[%%G][%%i]:38=7;38!"%\n%
     ^<nul set /P "=!tmpstr:48=7;48!"%\n%
  )))%\n%
  for /f "tokens=1,2" %%X in ('%BG.exe% mouse')Do (%\n: Wait for mouse input =%
   Set /A "c{pos}=%%X+1"                         %\n: Adjust X axis for 1 index =%
   Set "c{pos}=!c{Pos}!;%%Y"                     %\n: define actual Y;X coordinate clicked =%
   For %%G in (!GroupName!)Do (                  %\n: iterate over list of supplied group names =%
    Set "If.Btn[%%G]=If Not.Clicked =="          %\n: assign or clear default values for return variables =%
    Set "Clicked[%%G]="%\n%
    Set "ValidClick[%%G]="%\n%
    Set "ValidClick[%%G]{t}="%\n%
    For /F "Delims=" %%C in ("!c{Pos}!")Do (     %\n: expand Coordinate var for use in substring modification =%
     For /l %%I in (1 1 !btns[%%G][I]!)Do (      %\n: test if [Y;X] Coord contained in btn Coord Var =%
      If not "!btn[%%G][%%I][Coord]:[%%C]=!" == "!btn[%%G][%%I][Coord]!" (%\n%
       %OnClick%                                 %\n: play click sound effect if available =%
       Set "Group=%%G"                           %\n: assign groupname value the button clicked belongs to =%
       Set "If.Btn[%%G]=If [%%G][%%I] == [%%G]"  %\n: define If.Btn[GroupName] macro =%
       Set "ValidClick[%%G]=[%%G][%%I]"          %\n: assign [GroupName][Index] of clicked button =%
       Set "Clicked[%%G]=!Btn[%%G][%%I][String]!"%\n: assign the text containd in the clicked button =%
       If Defined Btn[%%G][%%I][items] (%\n%
        Set Btn[%%G][%%I][items]="!Btn[%%G][%%I][items]:{EQ}==!"%\n%
        Set "Btn[%%G][%%I][items]=!Btn[%%G][%%I][items]: =" "!"%\n%
        Set "Tmp.Items=!Btn[%%G][%%I][items]!"%\n%
        Set "Btn[%%G][%%I][items]="%\n%
        For %%t in (!Tmp.Items!)Do (%\n%
         Set "tmp.str=%%~t"%\n%
         Set "tmp.str=!tmp.Str:_= !"%\n%
         Set "!tmp.str!"%\n%
         Echo(!tmp.str!^|findstr.exe /R "[0-9]" ^> nul ^|^| Set "Btn[%%G][%%I][items]=!Btn[%%G][%%I][items]! "!tmp.str!""%\n%
        )%\n%
       )%\n%
       If Defined Btn[%%G][%%I]{t} (             %\n: toggle state handling. =%
        Set "ValidClick[%%G]{t}=[%%G][%%I]"      %\n: flag toggle state change for toggle.If.Not macro =%
        If "!Btn[%%G][%%I]{state}!"=="true" (    %\n: update console display of toggle state by inverting colors =%
        If not defined Btn[%%G][%%I]{m} (%\n%
         ^<nul set /P "=!Btn[%%G][%%I]!"%\n%
          Set "Btn[%%G][%%I]{state}=false"%\n%
         )%\n%
        )Else (%\n%
         set "tmpstr=!Btn[%%G][%%I]:38=7;38!"%\n%
         ^<nul set /P "=!tmpstr:48=7;48!"%\n%
         Set "Btn[%%G][%%I]{state}=true"%\n%
  )))))))%\n%
 )Else Set GroupName=

 Set "Toggle.If.not?=5"
:#5 \E36m
:#5 Usage: %Toggle.If.Not% \E0m{^<\E31m[Groupname][Index]\E0m^> ^| ^<\E31m[Groupname][Index]\E0m^> ^<\E31m[OtherGroupname][Index]\E0m^>}
:#5 \E33m
:#5 Macro Actions: \E0m
:#5 - Defines {state} false for all toggle buttons in GroupName except [Groupname][Index] 
:#5 - Updates Display Color of all buttons; Inverting each button with {state}=true
:#5 
:#5 * Multiple [GroupName][Index]'s \E31m with unique GroupNames \E0m may be supplied
:#5 \E33m
:#5 Example usage:\E36m
:#5 %Toggle.If.Not% !ValidClick[GroupName]!
:#5 \E0m
 Set Toggle.If.not=For %%n in (1 2)Do if %%n==2 (%\n%
  For /f "tokens=1,2 Delims=[]" %%G in ("!GroupName: =!")Do (%\n: Remove spaces from arg assignment =%
   If defined ValidClick[%%G]{t} (               %\n: If state change flagged true in Get.Click macro =%
    For /l %%i in (1 1 !btns[%%G][i]!)Do (       %\n: test each button in groupname =%
     If not "%%i"=="%%H" (                       %\n: If not button EQU clciked button =%
      Set "btn[%%G][%%i]{state}=false"           %\n: Force btn[%%G][%%i]{state} false =%
      ^<nul Set /P "=!btn[%%G][%%i]!"            %\n: Display button in standard unselected color =%
  ))))%\n%
 )Else Set GroupName=

 Set "Clean.Exit?=7"
:#7 
:#7 Clean.Exit \E33m
:#7  Restores codepage and Quickedit registry state
:#7  Clears the title and screen ; ends the local environment
:#7  executes Goto :Eof
:#7 \E0m
 Set Clean.Exit=(%\n%
  cls %\n%
  (%Reg.Restore%) ^> nul %\n%
  (Title ) %\n%
  ^<nul set /p "=%\E%[?25h" %\n%
  CHCP %active.cp% ^> nul %\n%
  Endlocal %\n%
  Goto :Eof %\n%
 )

 Set "Make.Btn?=9"
:#9  \E33m
:#9 Make.Btn Macro Usage: \E36m
:#9 %Make.Btn%\E0m ^<\E31mGroupName\E0m^> ^<\E31m/S "Btn text"\E0m^> [\E32m/Y Coord\E0m] [\E32m/X Coord\E0m] [\E32m/FG R G B\E0m]
:#9            [\E32m/BG R G B\E0m] [\E32m/BO \E0m{\E33mR G B\E0m^|\E33mR G B + R G B\E0m^|\E33mValue\E0m}] [\E32m/T\E0m] [\E32m/N\E0m]
:#9            [^<\E31m/TM\E0m^> [\E32m/D\E0m]^|[\E32m/CD Variable\E0m]]
:#9  \E37m
:#9  - Arg 1 must be Groupname. Switch order is NOT mandatory.
:#9  \E36m
:#9   /N \E37mReset button count for GroupName (Arg 1) to 0. use when creating buttons in a :label that is returned to. \E36m
:#9   /T \E37mDefine button as toggleable. Button state: 'Btn[Groupname][i]{state}' variable
:#9      alternates true or false when clicked; and clicked buttons Color is inverted on match. \E36m
:#9   /TM \E0m'Toggle Mandatory' as above; however mandatory true state for last selected button \E36m
:#9      /D  \E0m'default selection' ; Flags toggle {state} true on definition. \E31m * Requires \E36m/TM
:#9      /CD \E0m'Conditional default selection' ; If /CD Variable contains /S string
:#9           Flags toggle {state} true on definition. \E31m * Requires \E36m/TM
:#9 
:#9 Note: \E36m/BO \E37m{'Button box'} may supply a pair of R G B values for FG and BG by concatenating values with '+'
:#9   IE: '\E36m/BO \E38;2;255;0;0m\E48;2;0;0;100m38 2 255 0 0 + 48 2 0 0 100\E0m'
:#9   R G B sequences are groups of three integers between 0 and 255. Each R G B value adjusts the intensity of
:#9  that color. Valid values for Virtual terminal sequences can be referenced at:
:#9  \E32m https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
:#9  \E33m
:#9 Default Y and X Coordinates is used are /X value is ommited \E37m
:#9 - Button defaults to next X spacing if /Y position included ; Else X = 2
:#9 - Button defaults to next Y spacing if /Y ommited ;
:#9   - defaults to previous /X spacing if /X also ommited
:#9 
:#9 \E38;2;81;81;81mExpansion time is approxiamtely 1/33rd of a second when all switches used.
:#9 \E0m

 Set Make.Btn[Switches]="S" "Y" "X" "FG" "BG" "BO" "T" "TM" "D" "N" "CD" "Def"

 Set Make.Btn=For %%n in (1 2)Do if %%n==2 (                              %\n: CAPTURE ARG STRING =%
  Set "Make.Btn[Syntax]=%\E%[33m!Make.Btn[args]!"%\n%
  For /F "Tokens=1,2 Delims==" %%G in ('Set "Make.Btn_" 2^^^> nul')Do Set "%%~G=" %\n: RESETS ALL MACRO INTERNAL VARS =%
  If not "!Make.Btn[args]:* /=!" == "!Make.Btn[args]!" (                              %\n: BUILD Make.Btn.Args[!Make.Btn_arg[i]!] ARRAY IF ARGS PRESENT =%
   Set "Make.Btn_leading.args=!Make.Btn[args]:*/=!"                                   %\n: SPLIT ARGS FROM SWITCHES =%
   For /F "Delims=" %%G in ("!Make.Btn_leading.args!")Do Set "Make.Btn_leading.args=!Make.Btn[args]:/%%G=!"%\n%
   Set ^"Make.Btn[args]=!Make.Btn[args]:"=!"                                          %\n: REMOVE DOUBLEQUOTES FROM REMAINING ARGSTRING - SWITCHES =%
   Set "Make.Btn_arg[i]=0"                                                            %\n: ZERO INDEX FOR ARGS ARRAY =%
   For %%G in (!Make.Btn_leading.args!)Do (                                           %\n: BUILD ARGS ARRAY =%
    Set /A "Make.Btn_arg[i]+=1"%\n%
    Set "Make.Btn_arg[!Make.Btn_arg[i]!]=%%~G"%\n%
    For %%i in ("!Make.Btn_arg[i]!")Do (                                              %\n: SUBSTITUTE THE FOLLOWING POISON CHARACTERS =%
     Set "Make.Btn_arg[%%~i]=!Make.Btn_arg[%%~i]:{SC}=;!"%\n%
     Set "Make.Btn_arg[%%~i]=!Make.Btn_arg[%%~i]:{QM}=?!"%\n%
     Set "Make.Btn_arg[%%~i]=!Make.Btn_arg[%%~i]:{FS}=/!"%\n%
     Set "Make.Btn_arg[%%~i]=!Make.Btn_arg[%%~i]:{AS}=*!"%\n%
     Set "Make.Btn_arg[%%~i]=!Make.Btn_arg[%%~i]:{EQ}==!"%\n%
     Set ^"Make.Btn_arg[%%~i]=!Make.Btn_arg[%%~i]:{DQ}="!"%\n%
  ))) Else (                                                                           %\n: IF NO ARGS REMOVE DOUBLEQUOTES FROM ARGSTRING - SWITCHES =%
   Set ^"Make.Btn[args]=!Make.Btn[args]:"=!"%\n%
   Set "Make.Btn_Arg[1]=!Make.Btn[args]!"%\n%
   Set "Make.Btn_Arg[i]=1"%\n%
  )%\n%
  For /L %%L in (2 1 4)Do If "!Make.Btn_LastSwitch!" == "" (%\n%
   If "!Make.Btn[args]:~-%%L,1!" == " " Set "Make.Btn_LastSwitch=_"%\n%
   If "!Make.Btn[args]:~-%%L,1!" == "/" (                                              %\n: FLAG LAST SWITCH TRUE IF NO SUBARGS ; FOR SWITCHES UP TO 3 CHARCTERS LONG =%
    For /F "Delims=" %%v in ('Set /A "%%L-1"')Do Set "Make.Btn_Switch[!Make.Btn[args]:~-%%v!]=true"%\n%
    If not "!Make.Btn[args]:/?=!." == "!Make.Btn[args]!." Set "Make.Btn_Switch[help]=true"%\n%
    Set "Make.Btn[args]=!Make.Btn[args]:~0,-%%L!"%\n%
    Set "Make.Btn_LastSwitch=_"%\n%
   )%\n%
  )%\n%
  For %%G in ( %Make.Btn[Switches]% )Do If not "!Make.Btn[args]:/%%~G =!" == "!Make.Btn[args]!" (%\n: SPLIT AND ASSIGN SWITCH VALUES =%
   Set "Make.Btn_Switch[%%~G]=!Make.Btn[args]:*/%%~G =!"%\n%
   If not "!Make.Btn_Switch[%%~G]:*/=!" == "!Make.Btn_Switch[%%~G]!" (%\n%
    Set "Make.Btn_Trail[%%~G]=!Make.Btn_Switch[%%~G]:*/=!"%\n%
    For %%v in ("!Make.Btn_Trail[%%~G]!")Do (%\n%
     Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]: /%%~v=!"%\n%
     Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:/%%~v=!"%\n%
    )%\n%
    Set "Make.Btn_Trail[%%~G]="%\n%
    If "!Make.Btn_Switch[%%~G]:~-1!" == " " Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:~0,-1!"%\n%
    If "!Make.Btn_Switch[%%~G]!" == "" Set "Make.Btn_Switch[%%~G]=true"%\n%
    If not "!Make.Btn_Switch[%%~G]!" == "" If not "!Make.Btn_Switch[%%~G]!" == "true" (%\n%
     Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:{SC}=;!"%\n%
     Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:{QM}=?!"%\n%
     Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:{FS}=/!"%\n%
     Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:{AS}=*!"%\n%
     Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:{EQ}==!"%\n%
     Set ^"Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:{DQ}="!"%\n%
   ))%\n%
   If "!Make.Btn_Switch[%%~G]:~-1!" == " " Set "Make.Btn_Switch[%%~G]=!Make.Btn_Switch[%%~G]:~0,-1!"%\n%
  )%\n: ACTION SWITCH ASSESSMENT BELOW. USE CONDITIONAL TESTING OF VALID SWITCHES OR ARGS ARRAY TO ENACT COMMANDS FOR YOUR MACRO FUNCTION =%
  If not defined Make.Btn_Arg[1] (%\n:           Enforce button Groupname Definiton via Arg 1 =%
   Call "%Buttons_File%" Make.Btn%\n%
   ^<nul Set /P "=%\E%[E ^! %\E%[31mMissing Arg 1 GroupName in:%\E%[36m %%Make.btn%%%\E%[31m GroupName!Make.Btn[Syntax]:  = !%\E%[0m%\E%[E"%\n%
   Pause %\n%
   cls %\n%
   (%Reg.Restore%) ^> nul %\n%
   (Title ) %\n%
   ^<nul set /p "=%\E%[?25h" %\n%
   CHCP %active.cp% ^> nul %\n%
   Endlocal %\n%
   Goto :Eof %\n%
  )%\n%
  If not defined Make.Btn_Switch[S] (%\n:        Enforce button text definition via /S switch parameter value =%
   Call "%Buttons_File%" Make.Btn%\n%
   ^<nul Set /P "=%\E%[E ^! %\E%[31mMissing Switch /S in:%\E%[36m %%Make.btn%%!Make.Btn[Syntax]:  = ! %\E%[31m/S Button text%\E%[0m%\E%[E"%\n%
   Pause %\n%
   cls %\n%
   (%Reg.Restore%) ^> nul %\n%
   (Title ) %\n%
   ^<nul set /p "=%\E%[?25h" %\n%
   CHCP %active.cp% ^> nul %\n%
   Endlocal %\n%
   Goto :Eof %\n%
  )%\n%
  For %%e in ("!Make.Btn_Arg[1]!")Do (%\n:       Expand button Groupname ; Arg 1 =%
   If defined Make.Btn_Switch[N] (%\n:           Reset button group index and X Y positions if /N switch used =%
    Set "Btn[%%~e][X]="%\n%
    Set "Btn[%%~e][Y]="%\n%
    Set "Btns[%%~e][i]=0"%\n%
   )%\n%
   If defined Make.Btn_Switch[Y] (%\n:           Determine button Y Position according to /Y switch usage or default increment =%
    Set /A "Btn[%%~e][Y]=!Make.Btn_Switch[Y]!"%\n%
   )Else (%\n%
    Set /A "Btn[%%~e][Y]+=3+0"%\n%
   )%\n%
   If defined Make.Btn_Switch[X] (%\n:           Determine button X Position according to /X usage or default increment =%
    Set /A "Btn[%%~e][X]=!Make.Btn_Switch[X]!"%\n%
   )Else (%\n%
    If defined Make.Btn_Switch[Y] (%\n%
     Set /A "Btn[%%~e][X]=!L[%%~e][X]!+0"%\n%
    )Else (%\n%
     If not defined Btn[%%~e][X] Set "Btn[%%~e][X]=2"%\n%
   ))%\n%
   If !Btn[%%~e][X]! LSS 1 ( Set "Btn[%%~e][X]=1" )%\n: Constrain X min to One =%
   Set /a "Btns[%%~e][i]+=1+0"%\n:               Increment button Index =%
   For %%f in ("!Btns[%%~e][i]!")Do (%\n:        Expand button index =%
    Set "Btn[%%~e][!Btns[%%~e][i]!][p]=!Btn[%%~e][Y]!;!Btn[%%~e][X]!"%\n%
    Set "Btn[%%~e][!Btns[%%~e][i]!][string]=!Make.Btn_Switch[S]!"%\n%
    If /I "!Make.Btn_Switch[T]!"=="true" (%\n:   Define toggle vars according to /T or /TM switche usage =%
     Set "Btn[%%~e][%%~f]{t}=true"%\n%
     Set "Btn[%%~e][%%~f]{state}=false"%\n%
    ) Else If /I "!Make.Btn_Switch[TM]!"=="true" (%\n%
     Set "Btn[%%~e][%%~f]{t}=true"%\n%
     Set "Btn[%%~e][%%~f]{state}=false"%\n%
     Set "Btn[%%~e][%%~f]{m}=true"%\n%
    ) Else (%\n:                                 If /Tor /TM toggle switches not used ; ensure toggle vars undefined =%
     Set "Btn[%%~e][%%~f]{t}="%\n%
     Set "Btn[%%~e][%%~f]{state}="%\n%
     Set "Btn[%%~e][%%~f]{m}="%\n%
    )%\n%
    If defined Make.Btn_Switch[D] (%\n:          Define button as toggle state true =%
     If defined Btn[%%~e][%%~f]{t} (%\n:         if button is defined as toggleable =%
      Set "Btn[%%~e][%%~f]{state}=true"%\n%
    ))%\n%
    If defined Make.Btn_Switch[CD] (%\n:         Test supplied variable for contents of button text =%
     If defined Btn[%%~e][%%~f]{t} (%\n:         if button is defined as toggleable =%
      For %%1 in ("!Make.Btn_Switch[CD]!")Do (%\n%
       For %%2 in ("!Make.Btn_Switch[S]!")Do (%\n%
        If not "!%%~1:%%~2=!"=="!%%~1!" (%\n:     Define button as toggle state true on match =%
         Set "Btn[%%~e][%%~f]{state}=true"%\n%
    )))))%\n%
    If defined Make.Btn_Switch[FG] (%\n:         Assign Foreground color =%
     Set "Btn[%%~e][FG]=%\E%[38;2;!Make.Btn_Switch[FG]: =;!m"%\n%
    )Else (%\n%
     set "Btn[%%~e][FG]=%\E%[38;2;0;0;0m"%\n%
    )%\n%
    Set "Btn[%%~e][%%~f][FG]=!Btn[%%~e][FG]!"%\n%
    Set "Btn[%%~e][%%~f][iFG]=!Btn[%%~e][FG]:[38=48!"%\n%
    If defined Make.Btn_Switch[BG] (%\n%
     Set "Btn[%%~e][BG]=%\E%[48;2;!Make.Btn_Switch[BG]: =;!m"%\n%
    )Else (%\n%
     Set "Btn[%%~e][BG]=%\E%[48;2;230;230;200m"%\n%
    )%\n%
    Set "Btn[%%~e][%%~f][BG]=!Btn[%%~e][BG]!"%\n%
    Set "Btn[%%~e][%%~f][iBG]=!Btn[%%~e][BG]:[48=38!"%\n%
    If defined Make.Btn_Switch[BO] (%\n:         Process value of /BO border color =%
     Set "Btn[%%~e][Col]=!Btn[%%~e][Col]: + =m%\E%[!"%\n%
     Set "Btn[%%~e][Col]=%\E%[!Make.Btn_Switch[BO]: =;!m"%\n%
     Set "Btn[%%~e][Col]=!Btn[%%~e][Col]:+=m%\E%[!"%\n%
     Set "Btn[%%~e][Col]=!Btn[%%~e][Col]:[;=[!"%\n%
     Set "Btn[%%~e][Col]=!Btn[%%~e][Col]:;;=;!"%\n%
     Set "Btn[%%~e][Col]=!Btn[%%~e][Col]:;m=m!"%\n%
    ) Else (%\n:                                 Enact default border color if no value supplied =%
     set "Btn[%%~e][Col]=%\E%[90m"%\n%
    )%\n%
    Set "Btn[%%~e][%%~f][BO]=!Btn[%%~e][Col]!"%\n%
    Set "len="%\n:                               Get string length of button text =%
    Set "tmp.s=#!Make.Btn_Switch[S]!"%\n%
    For %%P in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (%\n%
     If "!tmp.s:~%%P,1!" NEQ "" (%\n%
      Set /a "len+=%%P"%\n%
      Set "tmp.s=!tmp.s:~%%P!"%\n%
    ))%\n%
    Set /A "Btn{Xmin}=!Btn[%%~e][X]!+1", "Btn{Xmax}=!Btn[%%~e][X]!+len", "l[%%~e][X]=!Btn[%%~e][X]!+len+2"%\n%
    Set "Btn[%%~e][%%~f][S]="%\n%
    Set "Btn[%%~e][%%~f][Bar]="%\n%
    Set "Btn[%%~e][%%~f][Coord]="%\n%
    For /l %%i in (!Btn{Xmin}! 1 !Btn{Xmax}!)Do (%\n%
     Set /A "Btn[%%~e][%%~f][Len]=%%i-3", "Xoffset=%%i-1"%\n%
     Set "Btn[%%~e][%%~f][Coord]=!Btn[%%~e][%%~f][Coord]![!Btn[%%~e][Y]!;!Xoffset!]"%\n%
     Set "Btn[%%~e][%%~f][Bar]=!Btn[%%~e][%%~f][Bar]!═"%\n%
     Set "Btn[%%~e][%%~f][S]=!Btn[%%~e][%%~f][S]! "%\n%
    )%\n%
    Set /A "Btn[%%e][Cpos]=!Btn[%%~e][Y]!+2"%\n%
    If defined Make.Btn_Switch[Def] Set "btn[%%~e][%%~f][items]=!Make.Btn_Switch[Def]!"%\n%
    Set "Btn[%%~e][%%~f]=%\E%[!Btn[%%~e][Y]!;!Btn[%%~e][X]!H!Btn[%%~e][%%~f][BO]!%\E%7║%\E%8%\E%[1A╔!Btn[%%~e][%%~f][Bar]!╗%\E%8%\E%[1B╚!Btn[%%~e][%%~f][Bar]!╝%\E%8%\E%[1C%\E%[0m!Btn[%%~e][%%~f][FG]!!Btn[%%~e][%%~f][BG]!!Make.Btn_Switch[S]!%\E%[0m!Btn[%%~e][%%~f][BO]!║%\E%[0m%\E%[2E%\E%7"%\n%
    Set "Btn[%%~e][%%~f][t]=%\E%[0m!Btn[%%~e][%%~f][FG]!!Btn[%%~e][%%~f][BG]!!Make.Btn_Switch[S]!%\E%[0m!Btn[%%~e][%%~f][BO]!║%\E%[0m%\E%[K"%\n%
  ))%\n%
 %= ESCAPE AMPERSANDS AND REDIRECTION CHARACTERS.  =%) Else Set Make.Btn[args]=

 <nul set /p "=%\E%[?25l"

 If not "%~1" == "" (
  If /I not "%~1" == "def" (
   Goto :button_help
  )Else Exit /b 0
 )

==========
 Goto :BUttonsMain
==========

:# HELP INFO

============
:button_help </?|Function_Name|Macro_Name>
 Set "_D="
 If not "%~1"=="" (
  Setlocal EnableDelayedExpansion
  Set "_D=!%~1?!"
 )
 Endlocal & Set "_D=%_D%"

 If not "%~1"=="" (
  If Defined _D (
   Mode 120,45
   (
    Echo(%\E%[36mSyntax: %\E%[0m^<%\E%[31mMandatory%\E%[0m^> [%\E%[32mOptional%\E%[0m] {%\E%[33mMutually^%\E%[0m^|%\E%[33mExclusive%\E%[0m}
    For /f "Tokens=2* Delims=%_D%" %%T in ('Findstr /BLIC:":#%_D%" "%Buttons_File%"')Do (
     Set "line=%%T"
     Call Set "line=%%line:buttons.bat="%~f0"%%"
     Call Echo(%%Line:\E=%\E%[%%
    )
   )> "%TEMP%\%~n0_Help"
   Type "%TEMP%\%~n0_Help" > Con
   Exit /B -1
  )Else (
   Findstr /BLIC:":%~1 " "%~f0" >nul && (
    Echo(%\E%[36mSyntax: %\E%[0m^<%\E%[31mMandatory%\E%[0m^> [%\E%[32mOptional%\E%[0m] {%\E%[33mMutually^%\E%[0m^|%\E%[33mExclusive%\E%[0m}
    <nul Set /P "=%\E%[K %~1 Usage:%\E%[2E Call "
    Findstr /BLIC:":%~1 " "%Buttons_File%"
    Exit /B -1
   ) || (
    Echo(Help query '%~1' does not match any existing Macro or Function.
    Echo(Check your Spelling and try again.
    Exit /B -1
   )
  )
 )Else (
  Echo(%\E%[33mDelayed Expansion %\E%[31mmust not %\E%[33mbe enabled prior to running %\E%[36m%~nx0%\E%[0m
  Exit /B -1
 )
Goto :eof

:TestHost ====================== Identify parent environment
 REM function a derivitive of the method proposed by Mathieu at:
 REM  https://discord.com/channels/288498150145261568/931201474338357300

 Setlocal EnableDelayedExpansion

 Set "ParentProcessID="
 wmic process get parentprocessid,name |find "WMIC" 1>"%TEMP%\PID.dat"

 For /F "UsebackQ tokens=2" %%G in ("%TEMP%\PID.dat")Do (
  Set "querry=powershell -nologo -noprofile -command gwmi Win32_Process -filter 'processid = %%G' ^| select ParentProcessId"
  For /f "Skip=2 Tokens=1,2 Delims=- " %%I in ('!Querry!')Do (
   Set "ParentProcessID=%%I"
  )
 )
 Del "%TEMP%\PID.dat"
 Endlocal & Set "ParentProcessID=%ParentProcessID%"

 set "ProcessType=0"
 set "ParentProcessName="

 > nul 2>&1 Set "WT_SESSION" && (
  set "ProcessType=3"
  set "ParentProcessName=WindowsTerminal.exe"
 )

 If Defined ParentProcessID (
  For /F "Skip=1 tokens=1 delims=," %%G in ('Tasklist /FI "PID EQ %ParentProcessID%" /FO CSV')Do If %ProcessType% EQU 0 (
   If /I not "%%~G"=="cmd.exe" (
    Set "ParentProcessName=%%~G"
   )Else Set "ParentProcessName=%%~G"
  ) Else If /I "%%~G"=="cmd.exe" If %ProcessType% EQU 3 (
   Set "ProcessType=2"
   Set "ParentProcessName=%%~G child of WindowsTerminal.exe"
  )
 )

 If /I "%ParentProcessName%"=="Explorer.exe" Set "ProcessType=1"
 If /I not "%ParentProcessName%" == "cmd.exe" If %ProcessType% EQU 0 Set "ProcessType=-1"

 Exit /b %ProcessType%

:TestVT
REM test if console is hosted via windows terminal, differentiate between a cmd.exe instance that is a child process of wt.exe
REM bg.exe does not behave as intended when executed from windows terminal.
REM Windows Terminal behaviour       - Does not consistenly flag the release of mouse button click as the end of the input stream.
REM  - expected behavior for cmd.exe - Read mouse input only while mouse button is depressed.
REM impact: Returns input on mouse position change event as well as mouse click event after first click.
REM         The Buttons macro system is designed to act as a script blocking input method and prevent furthor execution
REM         until a click event occurs. In the Windows terminal environment, the button would be deemed as clicked
REM         as soon as the mouse is moved over its location, instead of when the button is clicked.
 Call:TestHost
 If Errorlevel 3 (
  Echo(This script will not work correctly in windows terminal.
  Pause
  Exit /B 1
 )
 Set "VTsupport="
 2> nul (
  More < "%~f0:VTsupport" > nul && (
   Exit /b 0
  ) || (
   <Nul Set /P "=Verifying Compatability %\E%[2D"
   for /F "delims=" %%a in ('"PowerShell $console=$Host.UI.RawUI; $curPos=$console.CursorPosition; $rect=new-object System.Management.Automation.Host.Rectangle $curPos.X,$curPos.Y,$curPos.X,$curPos.Y; $BufCellArray=$console.GetBufferContents($rect); Write-Host $BufCellArray[0,0].Character;"') do (
    Cls
    If "%%a" == "y" (
     (Echo(true) >"%~f0:VTsupport"
     Exit /b 0
    )else (
     Echo(Virtual terminal sequences not enabled on your system. This program will not execute as intended.
     Exit /b 1
 ))))
Exit /b 2

====================
REM Button Functions
====================

:YesNo      ["Option 1"] ["Prompt 2"] ["Spoken Prompt"]
REM Default:    Yes           No

 %Buffer:@=Alt%
 If not "%~3"=="" start /b "" PowerShell -Nop -ep Bypass -C "Add-Type –AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak('%~3');

 If "%~1"=="" %Make.Btn% YN /N /S "Yes" /Y 3 /X 3 /FG 0 0 0 /BG 255 0 0 /BO 38 2 60 0 0 + 48 2 20 20 40
 If not "%~1"=="" %Make.Btn% YN /N /S "%~1" /Y 3 /X 3 /FG 0 0 0 /BG 255 0 0 /BO 38 2 60 0 0 + 48 2 20 20 40
 If "%~2"=="" %Make.Btn% YN /S "No" /Y 3 /FG 0 0 0 /BG 0 255 0 /BO 38 2 0 60 0 + 48 2 20 20 40
 If not "%~2"=="" %Make.Btn% YN /S "%~2" /Y 3 /FG 0 0 0 /BG 0 255 0 /BO 38 2 0 60 0 + 48 2 20 20 40

:YesNoWait
 %Get.Click% YN
 If defined ValidClick[YN] (
  %Buffer:@=Main%
 )Else Goto :YesNoWait
 %If.Btn[YN]%[1] Exit /B 1
 %If.Btn[YN]%[2] Exit /B 2

=========
:ColorMod <Prefixvar.Extension> [-l]
:# Prefix var doubles as the name of the Alternate data stream color variables as saved to / loaded from
:# values returned:
:# prefixvar.ext.FG.Color prefixvar.ext.BG.Color
:# prefixvar.ext_FG_Red prefix.var_FG_Blue prefix.var_FG_Green
:# prefixvar.ext_BG_Red prefix.var_BG_Blue prefix.var_BG_Green
:#
 %Buffer:@=Alt%
 If Not "%~1" == "" Set "Type=%~1"

:# load any existing saved values.
 (For /F "UsebackQ Delims=" %%G in ("%~f0:%Type%")Do %%G) 2> nul
 If /I "%~2"=="-l" Goto :Eof

 If "!%Type%_FG_Red!"=="" If "!%Type%_BG_Red!"=="" (
  For %%Z in ("FG" "BG")Do (
   If not defined %Type%.%%~Z.Color (
    Cls & Echo(Defalut value for %Type%.%%~Z.Color must be defined in format rrr;ggg;bbb
    Pause
    Exit
   )
   For /F "Tokens=1,2,3 Delims=;" %%1 in ("!%Type%.%%~Z.Color!")Do (
    Set "%Type%_%%~Z_Red=%%1"
    Set "%Type%_%%~Z_Green=%%2"
    Set "%Type%_%%~Z_Blue=%%3"
 )))

 If "!%Type%_Zone!" == "" Set "%Type%_Zone=BG"
 If "!%Type%_Spectrum!" == "" Set "%Type%_Spectrum=%Type%_!%Type%_Zone!_Blue"

:# definition of /d switch assigns default toggle state to last stored value; or default value if no value stored.

%= [CMcolor][1] =%	     %Make.btn% CMcolor /s Red /y 3 /x 3 /fg 255 0 0 /bg 0 0 0 /bo 48 2 0 0 0 + 38 2 255 255 255 /tm /cd %Type%_Spectrum /N
%= [CMcolor][2] =%	     %Make.btn% CMcolor /s Green /y 3 /fg 0 255 0 /bg 0 0 0 /bo 48 2 0 0 0 + 38 2 255 255 255 /tm /cd %Type%_Spectrum
%= [CMcolor][3] =%	     %Make.btn% CMcolor /s Blue /y 3 /fg 0 0 255 /bg 0 0 0 /bo 48 2 0 0 0 + 38 2 255 255 255 /tm /cd %Type%_Spectrum

%= [CMzone][1] =%	     %Make.btn% CMzone /s FG /y 6 /x 3 /tm /bo 48 2 0 0 0 + 38 2 255 255 255 /cd %Type%_Zone /N
%= [CMzone][2] =%	     %Make.btn% CMzone /s BG /y 6 /x 7 /bo 48 2 0 0 0 + 38 2 255 255 255 /tm /cd %Type%_Zone

%= [CMcontrol][2] =%	     %Make.btn% CMcontrol /s " ▲   " /y 6 /x 11 /fg 255 255 255 /bg 50 20 50 /bo 33 /N
%= [CMcontrol][3] =%	     %Make.btn% CMcontrol /s " ▼   " /y 6 /fg 255 255 255 /bg 50 20 50 /bo 33
%= [CMcontrol][1] =%	     %Make.btn% CMcontrol /s "     Accept       " /bg 180 160 0 /bo 32 /y 9 /x 3

:ColorModLoop
 Set "%Type%.FG.Color=!%Type%_FG_Red!;!%Type%_FG_Green!;!%Type%_FG_Blue!"
 Set "%Type%.BG.Color=!%Type%_BG_Red!;!%Type%_BG_Green!;!%Type%_BG_Blue!"

 <nul Set /P "=%\E%[13d%\E%[G%\E%[38;2;255;255;255m%\E%[48;2;!%Type%.BG.Color!m%Type% FG: %\E%[38;2;!%Type%.FG.Color!m!%Type%_FG_Red!;!%Type%_FG_Green!;!%Type%_FG_Blue! %\E%[38;2;255;255;255mBG:%\E%[38;2;!%Type%.FG.Color!m!%Type%_BG_Red!;!%Type%_BG_Green!;!%Type%_BG_Blue!%\E%[0m%\E%[K"

 %Get.Click% CMzone CMcolor CMcontrol
 If not defined Group Goto :ColorModLoop

 If not "%Group%" == "CMcontrol" %Toggle.If.Not% !ValidClick[%Group%]!

 If "%Group%"=="CMzone" (
  Set "%Type%_Zone=!Clicked[%Group%]!"
  If "!Clicked[%Group%]!"=="FG" (
   Set "%Type%_Spectrum=!%Type%_Spectrum:BG=FG!"
  )Else Set "%Type%_Spectrum=!%Type%_Spectrum:FG=BG!"
 )

 If "%Group%"=="CMcolor" Set "%Type%_Spectrum=%Type%_!%Type%_Zone!_!Clicked[%Group%]!"

 For /f "Delims=" %%G in ("!%Type%_Spectrum!") Do (
  %If.Btn[CMcontrol]%[1] (
   If not !%%G! EQU 255 ( Set /A "%%G+=5" )Else Start /b "" %BG.exe% play "%WINDIR%\Media\Windows Error.wav"
  )
  %If.Btn[CMcontrol]%[2] (
   If not !%%G! EQU 0 ( Set /A "%%G-=5" )Else Start /b "" %BG.exe% play "%WINDIR%\Media\Windows Error.wav"
 ))

:# Update stored Color values in alternate data stream
 (For /f "Delims=" %%G in ('Set %Type%')Do Echo(Set "%%G") >"%~f0:%Type%"

 %If.Btn[CMcontrol]%[3] (
  %Buffer:@=Main%
  Goto :Eof
 )

Goto :ColorModLoop


==========
:ShowState <GroupName>
 %Buffer:@=Alt%
 For %%G in (%*)Do (
  For /l %%i in (1 1 !Btns[%%~G][i]!)Do If defined Btn[%%~G][%%i]{t} Echo(Btn[%%~G][%%i]{state}=!Btn[%%~G][%%i]{state}!
 )
 Timeout /T 15
 %Buffer:@=Main%
 Cls
Goto :eof

==========================
:# REQUIRED UTILITY BG.exe
:# - Allows mouse click to be accepted [ blocking input ]
:# - Allows .Wav files to be played
:# - Refer to the documentation at the github repository for all usage options. [ link below ]

/* BG.exe V 3.9
  https://github.com/carlos-montiers/consolesoft-mirror/blob/master/bg/README.md
  Copyright (C) 2010-2018 Carlos Montiers Aguilera

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

  Carlos Montiers Aguilera
  cmontiers@gmail.com
 */

-----BEGIN CERTIFICATE-----
TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAgAAAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFtIGNhbm5v
dCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAABQRQAATAEEAG3tp1sAAAAA
AAAAAOAADwMLAQIZABoAAAAIAAAAAgAAcCcAAAAQAAAAAMD/AABAAAAQAAAAAgAA
BAAAAAEAAAAEAAAAAAAAAABgAAAABAAAu00AAAMAAAAAACAAABAAAAAAEAAAEAAA
AAAAABAAAAAAAAAAAAAAAABQAABMBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAD4UAAAlAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC50ZXh0AAAA
IBkAAAAQAAAAGgAAAAQAAAAAAAAAAAAAAAAAACAAUGAucmRhdGEAALgBAAAAMAAA
AAIAAAAeAAAAAAAAAAAAAAAAAABAAGBALmJzcwAAAACMAAAAAEAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAgABgwC5pZGF0YQAATAQAAABQAAAABgAAACAAAAAAAAAAAAAA
AAAAAEAAMMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
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
/yU8UUAAkJD/JThRQACQkP8lNFFAAJCQ/yUwUUAAkJD/JSxRQACQkP8lKFFAAJCQ
/yUkUUAAkJD/JSBRQACQkP8lHFFAAJCQ/yUYUUAAkJD/JRRRQACQkP8lEFFAAJCQ
/yUMUUAAkJD/JQhRQACQkP8lBFFAAJCQ/yUAUUAAkJD/JfxQQACQkP8l+FBAAJCQ
/////wAAAAD/////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
QwBPAE4ATwBVAFQAJAAAAEsARQBSAE4ARQBMADMAMgAuAEQATABMAAAAU2V0Q3Vy
cmVudENvbnNvbGVGb250RXgAVABlAHIAbQBpAG4AYQBsAAAAJQBkACAAJQBkACAA
JQBkACAAJQBkACAAJQBkACAAJQBkACAAJQBkACAAJQBkAAoAAABDAE8ATgBJAE4A
JAAAACUAZAAgACUAZAAKAAAAAABQAFIASQBOAFQAAABGAEMAUABSAEkATgBUAAAA
QwBPAEwATwBSAAAATABPAEMAQQBUAEUAAABMAEEAUwBUAEsAQgBEAAAASwBCAEQA
AABNAE8AVQBTAEUAAABEAEEAVABFAFQASQBNAEUAAABTAEwARQBFAFAAAABDAFUA
UgBTAE8AUgAAAEYATwBOAFQAAABQAEwAQQBZAAAAAACkMEAAACZAALAwQACAG0AA
wDBAANAaQADMMEAAwBlAANowQABgGUAA6jBAABAZQADyMEAAIBhAAP4wQACwF0AA
EDFAAGAXQAAcMUAAYBZAACoxQAAwFEAANDFAAIATQABHQ0M6ICh0ZG02NC0xKSA1
LjEuMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABkUAAAAAAAAAAAAADcUwAA
+FAAALBQAAAAAAAAAAAAACBUAABEUQAA6FAAAAAAAAAAAAAAMFQAAHxRAADwUAAA
AAAAAAAAAABAVAAAhFEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAjFEAAJpRAACoUQAA
tlEAAMRRAADcUQAA7lEAAAxSAAAcUgAALlIAAD5SAABSUgAAalIAAIZSAACYUgAA
qlIAAMRSAADMUgAAAAAAAOJSAAD0UgAA/lIAAAhTAAAQUwAAGlMAACZTAAAyUwAA
PFMAAEhTAABUUwAAXlMAAGhTAAAAAAAAclMAAAAAAACEUwAAAAAAAIxRAACaUQAA
qFEAALZRAADEUQAA3FEAAO5RAAAMUgAAHFIAAC5SAAA+UgAAUlIAAGpSAACGUgAA
mFIAAKpSAADEUgAAzFIAAAAAAADiUgAA9FIAAP5SAAAIUwAAEFMAABpTAAAmUwAA
MlMAADxTAABIUwAAVFMAAF5TAABoUwAAAAAAAHJTAAAAAAAAhFMAAAAAAABTAENs
b3NlSGFuZGxlAJIAQ3JlYXRlRmlsZVcAGgFFeGl0UHJvY2VzcwBkAUZyZWVMaWJy
YXJ5AKQBR2V0Q29uc29sZUN1cnNvckluZm8AALABR2V0Q29uc29sZU1vZGUAALYB
R2V0Q29uc29sZVNjcmVlbkJ1ZmZlckluZm8AAAQCR2V0TG9jYWxUaW1lAABFAkdl
dFByb2NBZGRyZXNzAAAsA0xvYWRMaWJyYXJ5VwAApQNSZWFkQ29uc29sZUlucHV0
VwDzA1NldENvbnNvbGVDdXJzb3JJbmZvAAD1A1NldENvbnNvbGVDdXJzb3JQb3Np
dGlvbgAA9wNTZXRDb25zb2xlRm9udAAAAQRTZXRDb25zb2xlTW9kZQAACgRTZXRD
b25zb2xlVGV4dEF0dHJpYnV0ZQB0BFNsZWVwAOwEV3JpdGVDb25zb2xlT3V0cHV0
VwB3AF9fd2dldG1haW5hcmdzAAAFAV9maWxlbm8AOwFfZ2V0Y2gAAGEBX2lvYgAA
xAFfa2JoaXQAALUCX3NldG1vZGUAAI0DX3djc2ljbXAAAEsEZnB1dHdjAAB1BGlz
d2N0eXBlAACqBHNldGxvY2FsZQD0BHdjc2NweQAABwV3Y3N0b2wAAA4Fd3ByaW50
ZgDIAU9lbVRvQ2hhckJ1ZmZXAAAJAFBsYXlTb3VuZFcAAAAAAFAAAABQAAAAUAAA
AFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAA
AFAAAABQAAAAUAAAS0VSTkVMMzIuZGxsAAAAABRQAAAUUAAAFFAAABRQAAAUUAAA
FFAAABRQAAAUUAAAFFAAABRQAAAUUAAAFFAAABRQAABtc3ZjcnQuZGxsAAAoUAAA
VVNFUjMyLmRsbAAAPFAAAFdJTk1NLkRMTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
-----END CERTIFICATE-----

==============================
:ButtonsMain Script body - USAGE DEMO
==============================

:# Enable Macros; facilitate nested variables !element[%index%]!
 Setlocal enableDelayedExpansion

:# Ensure no Existing variables prefixed 'Btn'
 For /f "Tokens=1,2 Delims==" %%G in ('Set Btn 2^> nul')Do Set "%%G="

 Set /A "Density=4", "minX=5", "maxX=45", "minY=5", "maxY=20"
 Set "Live.Cell.Char=╬"
 Set "Live.Cell.Char[i]=20"

 For %%z in (Live Dead)Do Call :ColorMod %%z.cell -l

 If "!Live.Cell.FG.Color!"=="" Set "Live.Cell.FG.Color=250;70;0"
 If "!Live.Cell.BG.Color!"=="" Set "Live.Cell.BG.Color=0;80;160"
 If "!Dead.Cell.FG.Color!"=="" Set "Dead.Cell.FG.Color=20;30;40"
 If "!Dead.Cell.BG.Color!"=="" Set "Dead.Cell.BG.Color=0;0;0"

%= [demo][1] =% %Make.Btn% demo /S Option One /t
%= [demo][2] =% %Make.Btn% demo /S Option Two /t
%= [demo][3] =% %Make.Btn% demo /S Option Three /t
%= [demo][4] =% %Make.Btn% demo /S "    Exit      " /bo 38 2 190 160 0 + 48 2 40 0 0 /bg 40 0 0 /fg 40 200 40

:Demoloop REM [ demo -  Generic menu via a loop ]
REM redefines buttons each loop with current color values. Note /N switch used to reset
REM button group.
%= [CellCol][1] =% %Make.Btn% CellCol /S Live.Cell /X 20/fg %Live.cell.FG.Color:;= % /bg %Live.cell.BG.Color:;= % /bo 33 /N
%= [CellCol][2] =% %Make.Btn% CellCol /S Dead.Cell /fg %Dead.cell.FG.Color:;= % /bg %Dead.cell.BG.Color:;= % /bo 33

REM Expand Get.Click macro with arguments corresponding to the group names of buttons defined using make.btn
REM Each loop Displays Buttons current toggle state. Use goto to break out of a loop to your target label.
 %Get.Click% demo CellCol

 Title Y;X:!C{pos}! C:!Clicked[%Group%]! VC:!ValidClick[%Group%]!
 %If.btn[demo]%[4] (
  Call :YesNo Yes No "Are you sure?"
  If "!Clicked[YN]!" == "Yes" (
   cls
   REM [ demo - Familiarise users with state definitions for toggle buttons. ]
   Set btn[ | findstr /lic:"{state}"
   Pause
   %Clean.Exit%
  )
 )

Rem assess If button clicked belonged to a specific group, if true Passes the buttons text to the Function ColorMod
 If "%Group%"=="CellCol" Call :ColorMod !Clicked[CellCol]!

Goto :Demoloop