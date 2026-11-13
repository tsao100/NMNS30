' G01.BAS - Cat & Mouse (MAO ZHUO LAO SHU)
' Educational content (1991 article): learning directions (N/E/S/W) and judging distance.
' Controls: type a letter and a number at the prompt, e.g. E 3 = move cat 3 squares east.
'           Type Q to take a direction quiz.  ESC = back to menu.
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (maxlen%)
DECLARE SUB DrawBoard ()
DECLARE SUB Msg (s$)
DECLARE SUB Quiz ()
DECLARE SUB MoveMouse ()

DIM SHARED cx%, cy%, mx%, my%, quit%, score%
RANDOMIZE TIMER
SCREEN 12
CLS
COLOR 14
LOCATE 2, 1: PRINT "G01 Cat & Mouse (MAO ZHUO LAO SHU)"
COLOR 15
LOCATE 4, 1: PRINT "What you learn (1991 puzzle room): recognise the four directions"
LOCATE 5, 1: PRINT "North, South, East, West, and judge how far away something is."
COLOR 7
LOCATE 7, 1: PRINT "The cat (C) chases the mouse (M) on a 12 x 12 map."
LOCATE 8, 1: PRINT "North is UP, South is DOWN, East is RIGHT, West is LEFT."
LOCATE 9, 1: PRINT "Each turn type a direction letter and a number of squares:"
LOCATE 10, 1: PRINT "    E 3   = walk 3 squares east        N 1 = walk 1 square north"
LOCATE 11, 1: PRINT "After your move the mouse runs one random square."
LOCATE 12, 1: PRINT "Catch it by landing on it (or walking through it) within 20 turns."
LOCATE 13, 1: PRINT "Each level shows the SHORTEST number of steps and how many you used."
LOCATE 14, 1: PRINT "Before each level: say where the mouse is (direction + squares) for bonus."
LOCATE 15, 1: PRINT "Five levels.  Fewer wasted steps = more points."
COLOR 11
LOCATE 18, 1: PRINT "Press any key to start, ESC = menu"
k$ = GetKey$
IF k$ = CHR$(27) THEN GOTO ExitGame

score% = 0
FOR level% = 1 TO 5
  ' place cat and mouse at least 4 squares apart
  DO
    cx% = INT(RND * 12) + 1: cy% = INT(RND * 12) + 1
    mx% = INT(RND * 12) + 1: my% = INT(RND * 12) + 1
    d% = ABS(cx% - mx%) + ABS(cy% - my%)
  LOOP UNTIL d% >= 4
  startd% = d%
  steps% = 0
  turns% = 0
  caught% = 0
  CALL DrawBoard
  CALL Msg("Level " + STR$(level%) + ": shortest path = " + STR$(startd%) + " steps. Press a key.")
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
  CALL Quiz
  IF quit% THEN GOTO ExitGame
  DO
    CALL DrawBoard
    p$ = "Turn" + STR$(turns% + 1) + " of 20  Move (E 3, Q=quiz): "
    LOCATE 28, 1: PRINT p$; SPACE$(30);
    LOCATE 28, LEN(p$) + 1
    s$ = ReadLine$(6)
    IF quit% THEN GOTO ExitGame
    s$ = UCASE$(LTRIM$(s$))
    IF s$ = "Q" THEN
      CALL Quiz
      IF quit% THEN GOTO ExitGame
    ELSEIF LEN(s$) >= 1 THEN
      d$ = LEFT$(s$, 1)
      n% = INT(VAL(MID$(s$, 2)))
      dx% = 0: dy% = 0
      IF d$ = "E" THEN dx% = 1
      IF d$ = "W" THEN dx% = -1
      IF d$ = "S" THEN dy% = 1
      IF d$ = "N" THEN dy% = -1
      tx% = cx% + dx% * n%: ty% = cy% + dy% * n%
      IF (dx% = 0 AND dy% = 0) OR n% < 1 OR n% > 11 THEN
        CALL Msg("Use N, S, E or W followed by 1 to 11, e.g. E 3.")
      ELSEIF tx% < 1 OR tx% > 12 OR ty% < 1 OR ty% > 12 THEN
        CALL Msg("That would walk off the map! Try fewer squares.")
      ELSE
        turns% = turns% + 1
        FOR i% = 1 TO n%
          cx% = cx% + dx%: cy% = cy% + dy%
          steps% = steps% + 1
          IF cx% = mx% AND cy% = my% THEN caught% = 1: EXIT FOR
        NEXT i%
        IF caught% = 0 THEN
          CALL MoveMouse
          IF cx% = mx% AND cy% = my% THEN caught% = 1
        END IF
        CALL DrawBoard
        IF caught% = 0 THEN CALL Msg("The mouse ran to a new square.")
      END IF
    END IF
  LOOP UNTIL caught% = 1 OR turns% >= 20
  CALL DrawBoard
  IF caught% = 1 THEN
    extra% = steps% - startd%
    IF extra% < 0 THEN extra% = 0
    pts% = 10 - extra%
    IF pts% < 2 THEN pts% = 2
    score% = score% + pts%
    m$ = "CAUGHT! Shortest" + STR$(startd%) + ", you used" + STR$(steps%)
    CALL Msg(m$ + ". +" + STR$(pts%) + " pts")
  ELSE
    CALL Msg("Out of turns - the mouse escaped. Shortest was" + STR$(startd%) + " steps.")
  END IF
  LOCATE 27, 56: PRINT "Score:"; score%; "   ";
  CALL Delay(1)
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
NEXT level%

CLS
COLOR 14
LOCATE 4, 1: PRINT "Game over!  Final score:"; score%; "out of about 60 + quiz bonus"
COLOR 7
LOCATE 6, 1
IF score% >= 45 THEN
  PRINT "Excellent navigator!"
ELSEIF score% >= 25 THEN
  PRINT "Good work. Count squares carefully to save steps."
ELSE
  PRINT "Keep practising directions and distances."
END IF
LOCATE 8, 1: PRINT "Press any key to return to the menu."
k$ = GetKey$

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

SUB DrawBoard
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G01 Cat & Mouse (MAO ZHUO LAO SHU)";
  COLOR 8
  FOR i% = 0 TO 12
    LINE (32 + i% * 32, 32)-(32 + i% * 32, 416), 8
    LINE (32, 32 + i% * 32)-(416, 32 + i% * 32), 8
  NEXT i%
  ' mouse
  px% = 32 + (mx% - 1) * 32
  py% = 32 + (my% - 1) * 32
  LINE (px% + 4, py% + 1)-(px% + 27, py% + 14), 7, BF
  COLOR 0
  LOCATE 3 + (my% - 1) * 2, 6 + (mx% - 1) * 4: PRINT "M";
  ' cat
  px% = 32 + (cx% - 1) * 32
  py% = 32 + (cy% - 1) * 32
  LINE (px% + 4, py% + 1)-(px% + 27, py% + 14), 14, BF
  COLOR 0
  LOCATE 3 + (cy% - 1) * 2, 6 + (cx% - 1) * 4: PRINT "C";
  ' compass
  COLOR 11
  LOCATE 3, 61: PRINT "N"
  LOCATE 4, 61: PRINT "|"
  LOCATE 5, 56: PRINT "W ---+--- E"
  LOCATE 6, 61: PRINT "|"
  LOCATE 7, 61: PRINT "S"
  COLOR 7
  LOCATE 9, 56: PRINT "Cat   col"; cx%; "row"; cy%; "  ";
  LOCATE 10, 56: PRINT "N=up S=down";
  LOCATE 11, 56: PRINT "E=right W=left";
  LOCATE 27, 56: PRINT "Score:"; score%; "   ";
  COLOR 8
  LOCATE 30, 1: PRINT "ESC = menu";
  COLOR 15
END SUB

SUB Msg (s$)
  COLOR 10
  LOCATE 29, 1
  PRINT LEFT$(s$ + SPACE$(79), 79);
  COLOR 15
END SUB

SUB MoveMouse
  DO
    r% = INT(RND * 4)
    ddx% = 0: ddy% = 0
    IF r% = 0 THEN ddx% = 1
    IF r% = 1 THEN ddx% = -1
    IF r% = 2 THEN ddy% = 1
    IF r% = 3 THEN ddy% = -1
    nx% = mx% + ddx%: ny% = my% + ddy%
  LOOP UNTIL nx% >= 1 AND nx% <= 12 AND ny% >= 1 AND ny% <= 12
  mx% = nx%: my% = ny%
END SUB

' Quiz: where is the mouse relative to the cat?
SUB Quiz
  dx% = mx% - cx%
  dy% = my% - cy%
  ex$ = "E": IF dx% < 0 THEN ex$ = "W"
  ey$ = "S": IF dy% < 0 THEN ey$ = "N"
  LOCATE 28, 1: PRINT SPACE$(79);
  LOCATE 28, 1
  PRINT "QUIZ: mouse is how far EAST/WEST of cat? (E 3, W 2, or 0): ";
  a$ = UCASE$(LTRIM$(ReadLine$(5)))
  IF quit% THEN EXIT SUB
  ok1% = 0
  IF dx% = 0 THEN
    IF VAL(a$) = 0 AND LEN(a$) > 0 THEN ok1% = 1
  ELSEIF LEFT$(a$, 1) = ex$ AND INT(VAL(MID$(a$, 2))) = ABS(dx%) THEN
    ok1% = 1
  END IF
  LOCATE 28, 1: PRINT SPACE$(79);
  LOCATE 28, 1
  PRINT "QUIZ: mouse is how far NORTH/SOUTH of cat? (N 3, S 2, or 0): ";
  b$ = UCASE$(LTRIM$(ReadLine$(5)))
  IF quit% THEN EXIT SUB
  ok2% = 0
  IF dy% = 0 THEN
    IF VAL(b$) = 0 AND LEN(b$) > 0 THEN ok2% = 1
  ELSEIF LEFT$(b$, 1) = ey$ AND INT(VAL(MID$(b$, 2))) = ABS(dy%) THEN
    ok2% = 1
  END IF
  IF ok1% = 1 AND ok2% = 1 THEN
    score% = score% + 2
    CALL Msg("Correct! +2 bonus points.")
  ELSE
    t$ = "Answer: " + LTRIM$(STR$(ABS(dx%))) + " " + ex$
    t$ = t$ + " and " + LTRIM$(STR$(ABS(dy%))) + " " + ey$
    CALL Msg(t$)
  END IF
  CALL Delay(1.5)
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
