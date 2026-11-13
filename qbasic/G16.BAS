' G16.BAS - Bomber (HONG ZHA JI)
' Educational content (1991 list): encirclement tactics, a submarine hunt, and the
'   Cartesian coordinate plane.
' Controls: type "x,y" (1-10) and Enter to drop a bomb, Backspace edits, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (r%, c%, mx%)
DECLARE SUB Title ()
DECLARE SUB Msg (t$)
DECLARE SUB DrawSea ()
DECLARE SUB DrawCell (x%, y%, rv%)
DECLARE SUB Panel ()
DECLARE SUB Fly (x%, y%)
DECLARE SUB PlayRound ()
DECLARE FUNCTION CellClass% (o%, ax%, ay%, x%, y%)
DECLARE FUNCTION Candidates% ()
DECLARE FUNCTION ParseXY% (a$)

' sh%: 0 untouched, 1 miss, 2 near (sub in an adjacent square), 3 hit
DIM SHARED sh%(1 TO 10, 1 TO 10)
DIM SHARED sx%, sy%, so%, bx%, by%, bombs%, hits%, tot%, quit%
DIM SHARED last$
RANDOMIZE TIMER
SCREEN 12
tot% = 0
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
DO
  CALL PlayRound
  IF quit% <> 0 THEN EXIT DO
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

' How a bomb at (x,y) is reported for a sub of length 4 whose first cell is (ax,ay).
' o = 0 horizontal, 1 vertical.  Returns 3 hit, 2 near (8 neighbours), 1 miss.
FUNCTION CellClass% (o%, ax%, ay%, x%, y%)
  r% = 1
  FOR k% = 0 TO 3
    cx% = ax% + k% * (1 - o%)
    cy% = ay% + k% * o%
    IF cx% = x% AND cy% = y% THEN
      r% = 3
    ELSEIF ABS(cx% - x%) <= 1 AND ABS(cy% - y%) <= 1 THEN
      IF r% < 2 THEN r% = 2
    END IF
  NEXT k%
  CellClass% = r%
END FUNCTION

' Number of sub positions still consistent with every report so far (encirclement shrinks it).
FUNCTION Candidates%
  n% = 0
  FOR o% = 0 TO 1
    FOR ax% = 1 TO 10 - 3 * (1 - o%)
      FOR ay% = 1 TO 10 - 3 * o%
        ok% = 1
        FOR x% = 1 TO 10
          FOR y% = 1 TO 10
            IF sh%(x%, y%) > 0 THEN
              IF CellClass%(o%, ax%, ay%, x%, y%) <> sh%(x%, y%) THEN ok% = 0
            END IF
          NEXT y%
        NEXT x%
        IF ok% <> 0 THEN n% = n% + 1
      NEXT ay%
    NEXT ax%
  NEXT o%
  Candidates% = n%
END FUNCTION

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

SUB DrawCell (x%, y%, rv%)
  px% = 80 + (x% - 1) * 36
  py% = 48 + (10 - y%) * 36
  st% = sh%(x%, y%)
  SELECT CASE st%
    CASE 0
      col% = 1
    CASE 1
      col% = 8
    CASE 2
      col% = 14
    CASE ELSE
      col% = 12
  END SELECT
  IF rv% <> 0 AND st% <> 3 THEN col% = 4
  LINE (px% + 1, py% + 1)-(px% + 34, py% + 34), col%, BF
  LINE (px%, py%)-(px% + 35, py% + 35), 9, B
  LOCATE (py% + 10) \ 16 + 1, (px% + 14) \ 8 + 1
  IF st% = 2 THEN COLOR 0 ELSE COLOR 15
  IF st% = 1 THEN PRINT "o";
  IF st% = 2 THEN PRINT "?";
  IF st% = 3 THEN PRINT "X";
  IF st% = 0 AND rv% <> 0 THEN PRINT "S";
END SUB

SUB DrawSea
  CLS
  COLOR 15
  LOCATE 1, 1: PRINT "G16 Bomber (HONG ZHA JI)";
  COLOR 11
  LOCATE 3, 7: PRINT "y";
  FOR i% = 1 TO 10
    py% = 48 + (10 - i%) * 36
    LOCATE (py% + 10) \ 16 + 1, 8
    PRINT RIGHT$("  " + LTRIM$(STR$(i%)), 2);
    LOCATE 27, (80 + (i% - 1) * 36 + 14) \ 8 + 1
    PRINT LTRIM$(STR$(i%));
  NEXT i%
  LOCATE 27, 55: PRINT "x (across)";
  FOR x% = 1 TO 10
    FOR y% = 1 TO 10
      CALL DrawCell(x%, y%, 0)
    NEXT y%
  NEXT x%
  COLOR 7
  LOCATE 30, 1: PRINT "Type x,y then Enter (example 4,7)    ESC = menu";
END SUB

' The bomber flies along row y from the left edge to column x, then drops its bomb.
SUB Fly (x%, y%)
  py% = 48 + (10 - y%) * 36
  FOR i% = 1 TO x%
    px% = 80 + (i% - 1) * 36
    LINE (px% + 4, py% + 12)-(px% + 30, py% + 22), 15, BF
    LINE (px% + 14, py% + 4)-(px% + 22, py% + 30), 15, BF
    CALL Delay(.04)
    CALL DrawCell(i%, y%, 0)
  NEXT i%
  px% = 80 + (x% - 1) * 36
  CIRCLE (px% + 17, py% + 17), 12, 14
  CIRCLE (px% + 17, py% + 17), 6, 12
  CALL Delay(.2)
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB Msg (t$)
  LOCATE 28, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

SUB Panel
  FOR i% = 3 TO 24
    LOCATE i%, 55: PRINT SPACE$(25);
  NEXT i%
  COLOR 14
  LOCATE 3, 55: PRINT "Bombs left:"; 20 - bombs%;
  LOCATE 4, 55: PRINT "Hits:"; hits%; "of 4";
  LOCATE 5, 55: PRINT "Total score:"; tot%;
  COLOR 10
  LOCATE 7, 55: PRINT "Last: "; last$;
  COLOR 15
  LOCATE 9, 55: PRINT "Sub positions left:";
  LOCATE 10, 55: PRINT Candidates%; "of 140";
  COLOR 7
  LOCATE 12, 55: PRINT "o = miss (sea clear)";
  LOCATE 13, 55: PRINT "? = NEAR: sub is in a";
  LOCATE 14, 55: PRINT "    touching square";
  LOCATE 15, 55: PRINT "X = HIT";
  LOCATE 17, 55: PRINT "Squares are (x,y):";
  LOCATE 18, 55: PRINT "x across, y up.";
  LOCATE 19, 55: PRINT "Lower-left is (1,1).";
  LOCATE 21, 55: PRINT "Encircle: bomb a ring";
  LOCATE 22, 55: PRINT "round each ? to close";
  LOCATE 23, 55: PRINT "in on the 4-long sub.";
END SUB

' Reads "x,y": exactly two numbers 1..10 separated by any non-digit; sets bx%, by%.
FUNCTION ParseXY% (a$)
  p$ = a$ + " "
  cur$ = ""
  n% = 0
  v1% = 0
  v2% = 0
  FOR i% = 1 TO LEN(p$)
    c$ = MID$(p$, i%, 1)
    IF c$ >= "0" AND c$ <= "9" THEN
      cur$ = cur$ + c$
    ELSE
      IF cur$ <> "" THEN
        v% = 99
        IF LEN(cur$) <= 3 THEN v% = VAL(cur$)
        IF n% = 0 THEN v1% = v%
        IF n% = 1 THEN v2% = v%
        n% = n% + 1
        cur$ = ""
      END IF
    END IF
  NEXT i%
  ParseXY% = 0
  IF n% = 2 THEN
    IF v1% >= 1 AND v1% <= 10 AND v2% >= 1 AND v2% <= 10 THEN
      bx% = v1%
      by% = v2%
      ParseXY% = 1
    END IF
  END IF
END FUNCTION

SUB PlayRound
  FOR x% = 1 TO 10
    FOR y% = 1 TO 10
      sh%(x%, y%) = 0
    NEXT y%
  NEXT x%
  so% = INT(RND * 2)
  IF so% = 0 THEN
    sx% = INT(RND * 7) + 1
    sy% = INT(RND * 10) + 1
  ELSE
    sx% = INT(RND * 10) + 1
    sy% = INT(RND * 7) + 1
  END IF
  bombs% = 0
  hits% = 0
  last$ = "none yet"
  CALL DrawSea
  CALL Panel
  CALL Msg("An enemy submarine (4 squares long, straight) hides in the sea. Find it!")
  DO
    COLOR 7
    LOCATE 29, 1: PRINT "Bomb at x,y > ";
    a$ = ReadLine$(29, 15, 12)
    IF a$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    END IF
    IF ParseXY%(a$) = 0 THEN
      CALL Msg("Type two numbers from 1 to 10, like 4,7  (x across, y up).")
    ELSEIF sh%(bx%, by%) <> 0 THEN
      CALL Msg("You already bombed that square. Choose another.")
    ELSE
      CALL Fly(bx%, by%)
      bombs% = bombs% + 1
      cl% = CellClass%(so%, sx%, sy%, bx%, by%)
      sh%(bx%, by%) = cl%
      IF cl% = 3 THEN hits% = hits% + 1
      CALL DrawCell(bx%, by%, 0)
      w$ = "MISS"
      IF cl% = 2 THEN w$ = "NEAR"
      IF cl% = 3 THEN w$ = "HIT"
      last$ = "(" + LTRIM$(STR$(bx%)) + "," + LTRIM$(STR$(by%)) + ") " + w$
      CALL Panel
      IF cl% = 3 THEN
        CALL Msg("HIT! Bomb the squares beside it to find which way the sub lies.")
      ELSEIF cl% = 2 THEN
        CALL Msg("NEAR: the submarine touches that square. Encircle it!")
      ELSE
        CALL Msg("Miss: the sea around that square is clear (nothing touching it).")
      END IF
    END IF
  LOOP UNTIL hits% = 4 OR bombs% = 20
  IF hits% = 4 THEN
    sc% = 40 + 10 * (20 - bombs%)
    tot% = tot% + sc%
    CALL Panel
    CALL Msg("SUBMARINE SUNK with" + STR$(bombs%) + " bombs!  Score +" + LTRIM$(STR$(sc%)))
  ELSE
    FOR k% = 0 TO 3
      FOR x% = 1 TO 10
        FOR y% = 1 TO 10
          IF x% = sx% + k% * (1 - so%) AND y% = sy% + k% * so% THEN CALL DrawCell(x%, y%, 1)
        NEXT y%
      NEXT x%
    NEXT k%
    CALL Msg("Out of bombs. The submarine escaped (shown as S).")
  END IF
  COLOR 7
  LOCATE 29, 1: PRINT "Any key = new sea, ESC = menu"; SPACE$(30);
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB

FUNCTION ReadLine$ (r%, c%, mx%)
  s$ = ""
  DO
    LOCATE r%, c%
    PRINT s$; "_ ";
    k$ = GetKey$
    IF k$ = CHR$(13) THEN
      EXIT DO
    ELSEIF k$ = CHR$(27) THEN
      s$ = CHR$(27)
      EXIT DO
    ELSEIF k$ = CHR$(8) THEN
      IF LEN(s$) > 0 THEN s$ = LEFT$(s$, LEN(s$) - 1)
    ELSEIF LEN(k$) = 1 AND LEN(s$) < mx% THEN
      IF k$ >= " " THEN s$ = s$ + k$
    END IF
  LOOP
  LOCATE r%, c%
  PRINT SPACE$(mx% + 2);
  ReadLine$ = s$
END FUNCTION

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 20: PRINT "G16  BOMBER  (HONG ZHA JI)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "ENCIRCLEMENT tactics and the CARTESIAN COORDINATE plane: every square of"
  LOCATE 8, 6: PRINT "the sea is a pair (x,y). A hidden submarine is found by closing a ring"
  LOCATE 9, 6: PRINT "around it, using each clue to rule out squares."
  COLOR 7
  LOCATE 12, 6: PRINT "How to play:"
  LOCATE 13, 6: PRINT "The sea is 10 x 10. x counts across, y up; lower-left square is (1,1)."
  LOCATE 14, 6: PRINT "A submarine 4 squares long lies straight (across or up) somewhere."
  LOCATE 15, 6: PRINT "Type  x,y  and press Enter: the bomber flies in along that row and bombs."
  LOCATE 16, 6: PRINT "Reports: HIT, NEAR (the sub touches that square, even diagonally), or MISS."
  LOCATE 17, 6: PRINT "You have 20 bombs. The panel counts the positions still possible."
  LOCATE 18, 6: PRINT "Backspace edits, ESC = back to menu"
  COLOR 10
  LOCATE 20, 6: PRINT "Score = 40 + 10 for every bomb left when the submarine sinks."
  COLOR 14
  LOCATE 23, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB
