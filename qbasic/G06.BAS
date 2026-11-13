' G06.BAS - Brain Gym (TOU NAO TI CAO)
' Educational content (1991 article): comparing quantity, length and difference; maze test.
' Controls: arrow keys (LEFT/RIGHT, UP/DOWN) or digits 1-8 to answer, arrow keys in the maze.
'           ESC = back to menu.
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION WaitKey$ (secs!, valid$)
DECLARE SUB Hdr (t$)
DECLARE SUB Msg (s$)
DECLARE SUB LevelEnd (n%, pts%)
DECLARE SUB DrawDots (x0%, y0%, n%, c%)
DECLARE SUB LevelCount ()
DECLARE SUB LevelLength ()
DECLARE SUB LevelOdd ()
DECLARE SUB DrawShape (cx%, cy%, t%, c%)
DECLARE SUB BuildMaze ()
DECLARE SUB DrawCell (gx%, gy%, c%)
DECLARE SUB LevelMaze ()

DIM SHARED quit%, score%, tleft%
DIM SHARED cell%(0 TO 131)
DIM SHARED mz%(0 TO 30, 0 TO 22)
DIM SHARED stx%(0 TO 200), sty%(0 TO 200), cand%(1 TO 4)

RANDOMIZE TIMER
SCREEN 12
CLS
COLOR 14
LOCATE 2, 1: PRINT "G06 Brain Gym (TOU NAO TI CAO)"
COLOR 15
LOCATE 4, 1: PRINT "What you learn (1991 puzzle room): compare quantity, length and"
LOCATE 5, 1: PRINT "difference, and test your sense of direction in a maze."
COLOR 7
LOCATE 7, 1: PRINT "Level 1  Quantity : which pile has MORE dots?   LEFT / RIGHT arrow"
LOCATE 8, 1: PRINT "Level 2  Length   : which bar is LONGER?        UP (top) / DOWN (bottom)"
LOCATE 9, 1: PRINT "Level 3  Difference: find the odd one out in a row of 8 shapes (1-8)"
LOCATE 10, 1: PRINT "Level 4  Maze    : walk from the top-left to the green square, arrows"
LOCATE 12, 1: PRINT "Levels 1-3 have 5 rounds of 8 seconds each; faster answers score more."
LOCATE 13, 1: PRINT "The maze has a 90 second limit; the more time left, the more points."
LOCATE 14, 1: PRINT "Maximum score is 250."
COLOR 11
LOCATE 17, 1: PRINT "Press any key to start, ESC = menu"
k$ = GetKey$
IF k$ = CHR$(27) THEN GOTO ExitGame

score% = 0
quit% = 0
CALL LevelCount
IF quit% THEN GOTO ExitGame
CALL LevelLength
IF quit% THEN GOTO ExitGame
CALL LevelOdd
IF quit% THEN GOTO ExitGame
CALL LevelMaze
IF quit% THEN GOTO ExitGame

CLS
COLOR 14
LOCATE 4, 1: PRINT "Brain Gym finished!  Final score:"; score%; "out of 250"
COLOR 7
LOCATE 6, 1
IF score% >= 200 THEN
  PRINT "Rating: GENIUS - sharp eyes and a quick mind!"
ELSEIF score% >= 140 THEN
  PRINT "Rating: GREAT - very good comparing and searching."
ELSEIF score% >= 80 THEN
  PRINT "Rating: GOOD - keep training."
ELSE
  PRINT "Rating: KEEP PRACTISING - try to answer faster next time."
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

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

' Wait up to secs! seconds for a key in valid$.  Arrow keys come back as U, D, L, R.
' Returns "" on timeout, CHR$(27) for ESC.  Seconds left are stored in tleft%.
FUNCTION WaitKey$ (secs!, valid$)
  t! = TIMER
  lastr% = -1
  tleft% = INT(secs!)
  d! = 0
  DO
    k$ = INKEY$
    IF k$ <> "" THEN
      IF k$ = CHR$(27) THEN
        WaitKey$ = k$
        EXIT FUNCTION
      END IF
      IF LEN(k$) = 2 THEN
        SELECT CASE RIGHT$(k$, 1)
          CASE "H": k$ = "U"
          CASE "P": k$ = "D"
          CASE "K": k$ = "L"
          CASE "M": k$ = "R"
          CASE ELSE: k$ = ""
        END SELECT
      END IF
      k$ = UCASE$(k$)
      IF k$ <> "" THEN
        IF INSTR(valid$, k$) > 0 THEN
          WaitKey$ = k$
          EXIT FUNCTION
        END IF
      END IF
    END IF
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
    r% = INT(secs! - d!) + 1
    IF r% <> lastr% THEN
      lastr% = r%
      tleft% = r% - 1
      IF tleft% < 0 THEN tleft% = 0
      COLOR 11
      LOCATE 3, 60: PRINT "Time:"; tleft%; "  ";
      COLOR 15
    END IF
  LOOP UNTIL d! >= secs!
  tleft% = 0
  WaitKey$ = ""
END FUNCTION

SUB Hdr (t$)
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G06 Brain Gym (TOU NAO TI CAO)";
  COLOR 15
  LOCATE 1, 60: PRINT "Score:"; score%; "   ";
  LOCATE 2, 1: PRINT LEFT$(t$, 79);
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

SUB LevelEnd (n%, pts%)
  CALL Msg("Level" + STR$(n%) + " done: +" + LTRIM$(STR$(pts%)) + " points. Press a key.")
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB

' draw n% dots (squares of a 12 x 11 grid, random cells) with top-left corner x0%, y0%
SUB DrawDots (x0%, y0%, n%, c%)
  m% = n%
  IF m% > 132 THEN m% = 132
  FOR i% = 0 TO 131
    cell%(i%) = i%
  NEXT i%
  FOR i% = 0 TO m% - 1
    j% = i% + INT(RND * (132 - i%))
    IF j% > 131 THEN j% = 131
    SWAP cell%(i%), cell%(j%)
    gc% = cell%(i%) MOD 12
    gr% = cell%(i%) \ 12
    dx% = x0% + gc% * 20 + 10
    dy% = y0% + gr% * 20 + 10
    CIRCLE (dx%, dy%), 6, c%
    PAINT (dx%, dy%), c%, c%
  NEXT i%
END SUB

' Level 1: compare quantity
SUB LevelCount
  lv% = 0
  FOR rd% = 1 TO 5
    CALL Hdr("Level 1: which side has MORE dots?  LEFT or RIGHT arrow")
    na% = INT(RND * 20) + 6
    df% = INT(RND * 4) + 1
    IF RND < .5 THEN nb% = na% + df% ELSE nb% = na% - df%
    LINE (36, 106)-(284, 334), 8, B
    LINE (356, 106)-(604, 334), 8, B
    CALL DrawDots(40, 110, na%, 14)
    CALL DrawDots(360, 110, nb%, 11)
    COLOR 15
    LOCATE 5, 12: PRINT "LEFT";
    LOCATE 5, 52: PRINT "RIGHT";
    IF na% > nb% THEN ans$ = "L" ELSE ans$ = "R"
    k$ = WaitKey$(8, "LR")
    IF k$ = CHR$(27) THEN quit% = 1: EXIT SUB
    IF k$ = ans$ THEN
      pts% = 4 + tleft%
      IF pts% > 10 THEN pts% = 10
      lv% = lv% + pts%
      score% = score% + pts%
      m$ = "Correct! " + LTRIM$(STR$(na%)) + " vs " + LTRIM$(STR$(nb%))
      CALL Msg(m$ + " (difference " + LTRIM$(STR$(ABS(na% - nb%))) + ") +" + STR$(pts%))
    ELSEIF k$ = "" THEN
      CALL Msg("Time up! It was " + LTRIM$(STR$(na%)) + " vs " + LTRIM$(STR$(nb%)) + ".")
    ELSE
      m$ = "Wrong. It was " + LTRIM$(STR$(na%)) + " vs " + LTRIM$(STR$(nb%))
      CALL Msg(m$ + " (difference " + LTRIM$(STR$(ABS(na% - nb%))) + ").")
    END IF
    CALL Delay(1.5)
  NEXT rd%
  CALL LevelEnd(1, lv%)
END SUB

' Level 2: compare length
SUB LevelLength
  lv% = 0
  FOR rd% = 1 TO 5
    CALL Hdr("Level 2: which bar is LONGER?  UP arrow = top, DOWN arrow = bottom")
    la% = INT(RND * 160) + 100
    df% = INT(RND * 25) + 5
    IF RND < .5 THEN lb% = la% + df% ELSE lb% = la% - df%
    xa% = 60 + INT(RND * 80)
    xb% = 60 + INT(RND * 80)
    LINE (xa%, 150)-(xa% + la%, 164), 14, BF
    LINE (xb%, 250)-(xb% + lb%, 264), 11, BF
    COLOR 15
    LOCATE 10, 1: PRINT "TOP";
    LOCATE 16, 1: PRINT "BOTTOM";
    IF la% > lb% THEN ans$ = "U" ELSE ans$ = "D"
    k$ = WaitKey$(8, "UD")
    IF k$ = CHR$(27) THEN quit% = 1: EXIT SUB
    m$ = "Top = " + LTRIM$(STR$(la%)) + ", bottom = " + LTRIM$(STR$(lb%))
    m$ = m$ + ", difference " + LTRIM$(STR$(ABS(la% - lb%)))
    IF k$ = ans$ THEN
      pts% = 4 + tleft%
      IF pts% > 10 THEN pts% = 10
      lv% = lv% + pts%
      score% = score% + pts%
      CALL Msg("Correct! " + m$ + ". +" + LTRIM$(STR$(pts%)))
    ELSEIF k$ = "" THEN
      CALL Msg("Time up! " + m$ + ".")
    ELSE
      CALL Msg("Wrong. " + m$ + ".")
    END IF
    CALL Delay(1.5)
  NEXT rd%
  CALL LevelEnd(2, lv%)
END SUB

SUB DrawShape (cx%, cy%, t%, c%)
  SELECT CASE t%
    CASE 1
      LINE (cx% - 18, cy% - 18)-(cx% + 18, cy% + 18), c%, B
    CASE 2
      LINE (cx% - 18, cy% - 18)-(cx% + 18, cy% + 18), c%, BF
    CASE 3
      CIRCLE (cx%, cy%), 20, c%
    CASE 4
      LINE (cx%, cy% - 20)-(cx% - 20, cy% + 16), c%
      LINE -(cx% + 20, cy% + 16), c%
      LINE -(cx%, cy% - 20), c%
    CASE ELSE
      LINE (cx% - 20, cy%)-(cx% + 20, cy%), c%
      LINE (cx%, cy% - 20)-(cx%, cy% + 20), c%
  END SELECT
END SUB

' Level 3: find the difference
SUB LevelOdd
  lv% = 0
  FOR rd% = 1 TO 5
    CALL Hdr("Level 3: which shape is different?  Press 1-8")
    ta% = INT(RND * 5) + 1
    ca% = INT(RND * 6) + 9
    tb% = ta%
    cb% = ca%
    IF RND < .5 THEN
      tb% = (ta% MOD 5) + 1
    ELSE
      cb% = 9 + ((ca% - 9 + 1) MOD 6)
    END IF
    oi% = INT(RND * 8) + 1
    FOR i% = 1 TO 8
      sx% = 50 + (i% - 1) * 72
      IF i% = oi% THEN
        CALL DrawShape(sx%, 200, tb%, cb%)
      ELSE
        CALL DrawShape(sx%, 200, ta%, ca%)
      END IF
      COLOR 15
      LOCATE 16, (sx% \ 8) + 1: PRINT LTRIM$(STR$(i%));
    NEXT i%
    ans$ = LTRIM$(STR$(oi%))
    k$ = WaitKey$(10, "12345678")
    IF k$ = CHR$(27) THEN quit% = 1: EXIT SUB
    IF k$ = ans$ THEN
      pts% = 4 + tleft% \ 2 + 1
      IF pts% > 10 THEN pts% = 10
      lv% = lv% + pts%
      score% = score% + pts%
      CALL Msg("Correct! Shape" + STR$(oi%) + " was different. +" + LTRIM$(STR$(pts%)))
    ELSEIF k$ = "" THEN
      CALL Msg("Time up! Shape" + STR$(oi%) + " was different.")
    ELSE
      CALL Msg("Wrong. Shape" + STR$(oi%) + " was different.")
    END IF
    CALL Delay(1.5)
  NEXT rd%
  CALL LevelEnd(3, lv%)
END SUB

' random maze on a 31 x 23 grid (odd cells are rooms, 1 = wall) by depth-first carving
SUB BuildMaze
  FOR y% = 0 TO 22
    FOR x% = 0 TO 30
      mz%(x%, y%) = 1
    NEXT x%
  NEXT y%
  sp% = 1
  stx%(1) = 1: sty%(1) = 1
  mz%(1, 1) = 0
  DO WHILE sp% > 0
    x% = stx%(sp%): y% = sty%(sp%)
    nn% = 0
    FOR dd% = 1 TO 4
      ddx% = 0: ddy% = 0
      IF dd% = 1 THEN ddx% = 2
      IF dd% = 2 THEN ddx% = -2
      IF dd% = 3 THEN ddy% = 2
      IF dd% = 4 THEN ddy% = -2
      nx% = x% + ddx%: ny% = y% + ddy%
      IF nx% >= 1 AND nx% <= 29 AND ny% >= 1 AND ny% <= 21 THEN
        IF mz%(nx%, ny%) = 1 THEN
          nn% = nn% + 1
          cand%(nn%) = dd%
        END IF
      END IF
    NEXT dd%
    IF nn% = 0 THEN
      sp% = sp% - 1
    ELSE
      dd% = cand%(INT(RND * nn%) + 1)
      ddx% = 0: ddy% = 0
      IF dd% = 1 THEN ddx% = 1
      IF dd% = 2 THEN ddx% = -1
      IF dd% = 3 THEN ddy% = 1
      IF dd% = 4 THEN ddy% = -1
      mz%(x% + ddx%, y% + ddy%) = 0
      mz%(x% + 2 * ddx%, y% + 2 * ddy%) = 0
      IF sp% < 200 THEN
        sp% = sp% + 1
        stx%(sp%) = x% + 2 * ddx%
        sty%(sp%) = y% + 2 * ddy%
      END IF
    END IF
  LOOP
END SUB

SUB DrawCell (gx%, gy%, c%)
  px% = 40 + gx% * 16
  py% = 56 + gy% * 16
  LINE (px%, py%)-(px% + 15, py% + 15), c%, BF
END SUB

' Level 4: maze test
SUB LevelMaze
  CALL BuildMaze
  CALL Hdr("Level 4: maze - reach the green square with the arrow keys (90 seconds)")
  FOR y% = 0 TO 22
    FOR x% = 0 TO 30
      IF mz%(x%, y%) = 1 THEN CALL DrawCell(x%, y%, 9)
    NEXT x%
  NEXT y%
  CALL DrawCell(29, 21, 10)
  px% = 1: py% = 1
  CALL DrawCell(px%, py%, 14)
  t! = TIMER
  d! = 0
  lastr% = -1
  done% = 0
  DO
    k$ = INKEY$
    IF k$ = CHR$(27) THEN quit% = 1: EXIT SUB
    IF LEN(k$) = 2 THEN
      nx% = px%: ny% = py%
      SELECT CASE RIGHT$(k$, 1)
        CASE "H": ny% = py% - 1
        CASE "P": ny% = py% + 1
        CASE "K": nx% = px% - 1
        CASE "M": nx% = px% + 1
      END SELECT
      IF nx% >= 0 AND nx% <= 30 AND ny% >= 0 AND ny% <= 22 THEN
        IF mz%(nx%, ny%) = 0 THEN
          CALL DrawCell(px%, py%, 0)
          px% = nx%: py% = ny%
          CALL DrawCell(px%, py%, 14)
        END IF
      END IF
      IF px% = 29 AND py% = 21 THEN done% = 1
    END IF
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
    r% = 90 - INT(d!)
    IF r% < 0 THEN r% = 0
    IF r% <> lastr% THEN
      lastr% = r%
      COLOR 11
      LOCATE 3, 60: PRINT "Time:"; r%; "  ";
      COLOR 15
    END IF
  LOOP UNTIL done% = 1 OR d! >= 90
  pts% = 0
  IF done% = 1 THEN
    pts% = 10 + (90 - INT(d!))
    IF pts% > 100 THEN pts% = 100
    IF pts% < 10 THEN pts% = 10
  END IF
  score% = score% + pts%
  IF done% = 1 THEN
    CALL Msg("You found the way out!")
  ELSE
    CALL Msg("Time up - the maze beat you.")
  END IF
  CALL Delay(1)
  CALL LevelEnd(4, pts%)
END SUB
