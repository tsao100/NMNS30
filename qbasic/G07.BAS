' G07.BAS - African Safari (FEI ZHOU SHOU LIE)
' Educational content (1991 article): reasoning to find hidden animals; Cartesian coordinates.
' Controls: type x,y (x first, then y; both -10 to 10) and press ENTER, e.g. -3,5
'           ESC = back to menu.
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (maxlen%)
DECLARE FUNCTION IsNum% (s$)
DECLARE FUNCTION GX% (v%)
DECLARE FUNCTION GY% (v%)
DECLARE SUB Msg (s$)
DECLARE SUB DrawMap ()
DECLARE SUB Panel ()
DECLARE SUB NewGame ()
DECLARE SUB MarkMiss (x%, y%)
DECLARE SUB MarkAnimal (x%, y%, c%)

DIM SHARED ax%(1 TO 3), ay%(1 TO 3), fnd%(1 TO 3), nm$(1 TO 3)
DIM SHARED tried%(0 TO 20, 0 TO 20), hist$(1 TO 15)
DIM SHARED quit%, score%, shots%, nfound%, nh%

RANDOMIZE TIMER
SCREEN 12
CLS
COLOR 14
LOCATE 2, 1: PRINT "G07 African Safari (FEI ZHOU SHOU LIE)"
COLOR 15
LOCATE 4, 1: PRINT "What you learn (1991 puzzle room): reasoning, and how to name a point"
LOCATE 5, 1: PRINT "on a plane with Cartesian coordinates (x, y)."
COLOR 7
LOCATE 7, 1: PRINT "Three animals (a lion, a zebra and a giraffe) hide on a grid of points"
LOCATE 8, 1: PRINT "from -10 to 10 in both directions.  x is across (East = +), y is up"
LOCATE 9, 1: PRINT "(North = +).  The centre is (0,0)."
LOCATE 11, 1: PRINT "Fire at a point by typing x,y  for example  -3,5  then ENTER."
LOCATE 12, 1: PRINT "A hit finds an animal.  A miss tells you the direction and the distance"
LOCATE 13, 1: PRINT "of the NEAREST hidden animal.  Use the hints to narrow the search."
LOCATE 14, 1: PRINT "You have 15 shots.  Each animal found scores 20 plus 2 per shot left."
COLOR 11
LOCATE 17, 1: PRINT "Press any key to start, ESC = menu"
k$ = GetKey$
IF k$ = CHR$(27) THEN GOTO ExitGame

quit% = 0
DO
  CALL NewGame
  CALL DrawMap
  CALL Panel
  CALL Msg("Fire when ready.")
  DO
    LOCATE 28, 1: PRINT SPACE$(79);
    p$ = "Shoot at x,y (e.g. -3,5): "
    COLOR 15
    LOCATE 28, 1: PRINT p$;
    LOCATE 28, LEN(p$) + 1
    s$ = ReadLine$(10)
    IF quit% THEN GOTO ExitGame
    p% = INSTR(s$, ",")
    IF p% = 0 THEN p% = INSTR(s$, " ")
    IF p% < 2 THEN
      CALL Msg("Type two numbers separated by a comma, like -3,5.")
    ELSE
      xs$ = LTRIM$(RTRIM$(LEFT$(s$, p% - 1)))
      ys$ = LTRIM$(RTRIM$(MID$(s$, p% + 1)))
      IF IsNum%(xs$) = 0 OR IsNum%(ys$) = 0 THEN
        CALL Msg("Numbers only, please, like -3,5.")
      ELSE
        sx% = INT(VAL(xs$))
        sy% = INT(VAL(ys$))
        IF sx% < -10 OR sx% > 10 OR sy% < -10 OR sy% > 10 THEN
          CALL Msg("Both numbers must be between -10 and 10.")
        ELSEIF tried%(sx% + 10, sy% + 10) <> 0 THEN
          CALL Msg("You already fired at that point. Try another.")
        ELSE
          shots% = shots% - 1
          tried%(sx% + 10, sy% + 10) = 1
          hit% = 0
          FOR i% = 1 TO 3
            IF fnd%(i%) = 0 AND ax%(i%) = sx% AND ay%(i%) = sy% THEN hit% = i%
          NEXT i%
          nh% = nh% + 1
          pt$ = " (" + LTRIM$(STR$(sx%)) + "," + LTRIM$(STR$(sy%)) + ")"
          IF hit% > 0 THEN
            fnd%(hit%) = 1
            nfound% = nfound% + 1
            score% = score% + 20 + 2 * shots%
            CALL MarkAnimal(sx%, sy%, 14)
            hist$(nh%) = "#" + LTRIM$(STR$(nh%)) + pt$ + " HIT " + nm$(hit%)
            CALL Msg("HIT! You found the " + nm$(hit%) + " at" + pt$)
          ELSE
            CALL MarkMiss(sx%, sy%)
            ' find nearest animal not yet found (squared distance, integers)
            best& = 999999
            bi% = 0
            FOR i% = 1 TO 3
              IF fnd%(i%) = 0 THEN
                ddx% = ax%(i%) - sx%
                ddy% = ay%(i%) - sy%
                d2& = CLNG(ddx%) * ddx% + CLNG(ddy%) * ddy%
                IF d2& < best& THEN best& = d2&: bi% = i%
              END IF
            NEXT i%
            IF bi% > 0 THEN
              ddx% = ax%(bi%) - sx%
              ddy% = ay%(bi%) - sy%
              v$ = "": h$ = ""
              IF ddy% > 0 THEN v$ = "N"
              IF ddy% < 0 THEN v$ = "S"
              IF ddx% > 0 THEN h$ = "E"
              IF ddx% < 0 THEN h$ = "W"
              IF ABS(ddx%) * 2 < ABS(ddy%) THEN h$ = ""
              IF ABS(ddy%) * 2 < ABS(ddx%) THEN v$ = ""
              dist% = INT(SQR(best&) + .5)
              w$ = "cold"
              IF dist% <= 5 THEN w$ = "warm"
              IF dist% <= 2 THEN w$ = "HOT"
              hist$(nh%) = "#" + LTRIM$(STR$(nh%)) + pt$ + " " + v$ + h$ + " " + LTRIM$(STR$(dist%))
              m$ = "Miss. Nearest animal: " + v$ + h$ + ", about " + LTRIM$(STR$(dist%))
              CALL Msg(m$ + " squares away (" + w$ + ").")
            END IF
          END IF
          CALL Panel
        END IF
      END IF
    END IF
  LOOP UNTIL shots% <= 0 OR nfound% >= 3

  ' reveal the animals that were missed
  FOR i% = 1 TO 3
    IF fnd%(i%) = 0 THEN CALL MarkAnimal(ax%(i%), ay%(i%), 12)
  NEXT i%
  LOCATE 28, 1: PRINT SPACE$(79);
  COLOR 14
  IF nfound% >= 3 THEN
    CALL Msg("All three animals found!  Score" + STR$(score%) + ".  Play again? (Y/N)")
  ELSE
    m$ = "Out of shots. Found" + STR$(nfound%) + " of 3 (red = missed).  Score"
    CALL Msg(m$ + STR$(score%) + ".  Play again? (Y/N)")
  END IF
  again% = 0
  DO
    k$ = UCASE$(GetKey$)
    IF k$ = CHR$(27) THEN GOTO ExitGame
    IF k$ = "Y" THEN again% = 1
    IF k$ = "N" THEN GOTO ExitGame
  LOOP UNTIL again% = 1
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

FUNCTION ReadLine$ (maxlen%)
  s$ = ""
  LOCATE , , 1
  DO
    k$ = GetKey$
    IF k$ = CHR$(27) THEN
      quit% = 1
      EXIT DO
    ELSEIF k$ = CHR$(13) THEN
      EXIT DO
    ELSEIF k$ = CHR$(8) THEN
      IF LEN(s$) > 0 THEN
        s$ = LEFT$(s$, LEN(s$) - 1)
        LOCATE CSRLIN, POS(0) - 1
        PRINT " ";
        LOCATE CSRLIN, POS(0) - 1
      END IF
    ELSEIF LEN(k$) = 1 THEN
      IF ASC(k$) >= 32 AND LEN(s$) < maxlen% THEN
        s$ = s$ + k$
        PRINT k$;
      END IF
    END IF
  LOOP
  LOCATE , , 0
  ReadLine$ = s$
END FUNCTION

' 1 if s$ is an optional sign followed by 1 or 2 digits
FUNCTION IsNum% (s$)
  t$ = s$
  IF LEFT$(t$, 1) = "-" OR LEFT$(t$, 1) = "+" THEN t$ = MID$(t$, 2)
  IsNum% = 0
  IF LEN(t$) < 1 OR LEN(t$) > 2 THEN EXIT FUNCTION
  FOR i% = 1 TO LEN(t$)
    c$ = MID$(t$, i%, 1)
    IF c$ < "0" OR c$ > "9" THEN EXIT FUNCTION
  NEXT i%
  IsNum% = 1
END FUNCTION

' pixel position of coordinate values (grid cell = 18 pixels, origin at x=240, y=220)
FUNCTION GX% (v%)
  GX% = 60 + (v% + 10) * 18
END FUNCTION

FUNCTION GY% (v%)
  GY% = 40 + (10 - v%) * 18
END FUNCTION

SUB Msg (s$)
  COLOR 10
  LOCATE 29, 1
  PRINT LEFT$(s$ + SPACE$(79), 79);
  COLOR 15
END SUB

SUB NewGame
  nm$(1) = "Lion": nm$(2) = "Zebra": nm$(3) = "Giraffe"
  FOR i% = 0 TO 20
    FOR j% = 0 TO 20
      tried%(i%, j%) = 0
    NEXT j%
  NEXT i%
  FOR i% = 1 TO 3
    DO
      ok% = 1
      ax%(i%) = INT(RND * 21) - 10
      ay%(i%) = INT(RND * 21) - 10
      FOR j% = 1 TO i% - 1
        IF ax%(j%) = ax%(i%) AND ay%(j%) = ay%(i%) THEN ok% = 0
      NEXT j%
    LOOP UNTIL ok% = 1
    fnd%(i%) = 0
  NEXT i%
  FOR i% = 1 TO 15
    hist$(i%) = ""
  NEXT i%
  shots% = 15
  nfound% = 0
  nh% = 0
  score% = 0
END SUB

SUB DrawMap
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G07 African Safari (FEI ZHOU SHOU LIE)";
  FOR v% = -10 TO 10
    LINE (GX%(v%), GY%(10))-(GX%(v%), GY%(-10)), 8
    LINE (GX%(-10), GY%(v%))-(GX%(10), GY%(v%)), 8
  NEXT v%
  LINE (GX%(0), GY%(10))-(GX%(0), GY%(-10)), 15
  LINE (GX%(-10), GY%(0))-(GX%(10), GY%(0)), 15
  COLOR 11
  FOR v% = -10 TO 10 STEP 5
    LOCATE (GY%(-10) + 6) \ 16 + 1, GX%(v%) \ 8 + 1 - 1
    PRINT RIGHT$("   " + LTRIM$(STR$(v%)), 3);
    LOCATE GY%(v%) \ 16 + 1, 1
    PRINT RIGHT$("   " + LTRIM$(STR$(v%)), 3);
  NEXT v%
  COLOR 12
  LOCATE 2, 19: PRINT "y (north +)";
  LOCATE 25, 55: PRINT "x (east +)";
  COLOR 8
  LOCATE 30, 1: PRINT "ESC = menu";
  COLOR 15
END SUB

SUB MarkMiss (x%, y%)
  LINE (GX%(x%) - 4, GY%(y%) - 4)-(GX%(x%) + 4, GY%(y%) + 4), 12
  LINE (GX%(x%) - 4, GY%(y%) + 4)-(GX%(x%) + 4, GY%(y%) - 4), 12
END SUB

SUB MarkAnimal (x%, y%, c%)
  CIRCLE (GX%(x%), GY%(y%)), 7, c%
  PAINT (GX%(x%), GY%(y%)), c%, c%
END SUB

' side panel: shots left, animals found, score, shot history
SUB Panel
  COLOR 15
  LOCATE 3, 58: PRINT "Shots left:"; shots%; "  ";
  LOCATE 4, 58: PRINT "Found:"; nfound%; "of 3  ";
  LOCATE 5, 58: PRINT "Score:"; score%; "   ";
  COLOR 7
  LOCATE 7, 58: PRINT "Animals: Lion,";
  LOCATE 8, 58: PRINT "Zebra, Giraffe";
  LOCATE 10, 58: PRINT "Shot log";
  first% = nh% - 11
  IF first% < 1 THEN first% = 1
  r% = 11
  FOR i% = first% TO nh%
    IF i% >= 1 AND i% <= 15 AND r% <= 24 THEN
      LOCATE r%, 58: PRINT LEFT$(hist$(i%) + SPACE$(22), 22);
      r% = r% + 1
    END IF
  NEXT i%
  COLOR 15
END SUB
