' G14.BAS - Sliding Puzzle (ZHI HUI PAN)
' Educational content (1991 list): odd and even permutations (the 15 puzzle).
' Controls: Arrows = slide a tile that way, N = new shuffle, C = custom arrangement check,
'   F = solved board with 14 and 15 swapped (unsolvable), ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (r%, c%, mx%)
DECLARE SUB Title ()
DECLARE SUB DrawBoard ()
DECLARE SUB Info ()
DECLARE SUB Msg (t$)
DECLARE SUB ResetBoard ()
DECLARE SUB Shuffle ()
DECLARE SUB CustomMode ()
DECLARE FUNCTION Inv% ()
DECLARE FUNCTION BlankPos% ()
DECLARE FUNCTION IsSolved% ()
DECLARE FUNCTION Slide% (dr%, dc%)

DIM SHARED bd%(0 TO 15), cu%(0 TO 15)
DIM SHARED mv%, best%, quit%, tot%
RANDOMIZE TIMER
SCREEN 12
best% = 0
tot% = 0
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
CALL Shuffle
CALL DrawBoard
CALL Info
CALL Msg("Slide the tiles back into order 1..15 with the blank in the last square.")
DO
  k$ = GetKey$
  moved% = 0
  IF k$ = CHR$(27) THEN
    EXIT DO
  ELSEIF k$ = CHR$(0) + "H" THEN
    moved% = Slide%(-1, 0)
  ELSEIF k$ = CHR$(0) + "P" THEN
    moved% = Slide%(1, 0)
  ELSEIF k$ = CHR$(0) + "K" THEN
    moved% = Slide%(0, -1)
  ELSEIF k$ = CHR$(0) + "M" THEN
    moved% = Slide%(0, 1)
  ELSEIF UCASE$(k$) = "N" THEN
    CALL Shuffle
    CALL DrawBoard
    CALL Info
    CALL Msg("New shuffle (made only of legal slides, so it is solvable).")
  ELSEIF UCASE$(k$) = "C" THEN
    CALL CustomMode
    CALL DrawBoard
    CALL Info
  ELSEIF UCASE$(k$) = "F" THEN
    CALL ResetBoard
    t% = bd%(13): bd%(13) = bd%(14): bd%(14) = t%
    mv% = 0
    CALL DrawBoard
    CALL Info
    CALL Msg("Only 14 and 15 are swapped: ONE exchange = odd permutation. Impossible!")
  END IF
  IF moved% <> 0 THEN
    mv% = mv% + 1
    CALL DrawBoard
    CALL Info
    IF IsSolved% <> 0 THEN
      sc% = 1000 - 5 * mv%
      IF sc% < 0 THEN sc% = 0
      tot% = tot% + sc%
      IF best% = 0 OR mv% < best% THEN best% = mv%
      CALL Info
      mm$ = "SOLVED in" + STR$(mv%) + " moves! Score +" + LTRIM$(STR$(sc%))
      CALL Msg(mm$ + ". Any key = new, ESC = menu")
      k$ = GetKey$
      IF k$ = CHR$(27) THEN EXIT DO
      CALL Shuffle
      CALL DrawBoard
      CALL Info
      CALL Msg("New shuffle.")
    END IF
  END IF
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

FUNCTION BlankPos%
  BlankPos% = 0
  FOR i% = 0 TO 15
    IF bd%(i%) = 0 THEN BlankPos% = i%
  NEXT i%
END FUNCTION

' Parse a line of numbers; the user may type 16 numbers 0..15 (0 = blank)
SUB CustomMode
  CALL Msg("Type 16 numbers 0-15 (0 = blank), row by row, e.g. 1 2 3 4 5 ... Enter = cancel")
  LOCATE 28, 1: PRINT "Rows: first four numbers are the top row.";
  a$ = ReadLine$(29, 1, 70)
  IF a$ = CHR$(27) OR a$ = "" THEN
    CALL Msg("Cancelled.")
    EXIT SUB
  END IF
  p$ = a$ + " "
  cur$ = ""
  n% = 0
  FOR i% = 1 TO LEN(p$)
    c$ = MID$(p$, i%, 1)
    IF c$ >= "0" AND c$ <= "9" THEN
      cur$ = cur$ + c$
    ELSE
      IF cur$ <> "" THEN
        v% = 99
        IF LEN(cur$) <= 3 THEN v% = VAL(cur$)
        IF n% <= 15 THEN cu%(n%) = v%
        n% = n% + 1
        cur$ = ""
      END IF
    END IF
  NEXT i%
  ok% = 1
  IF n% <> 16 THEN ok% = 0
  IF ok% <> 0 THEN
    FOR i% = 0 TO 15
      IF cu%(i%) < 0 OR cu%(i%) > 15 THEN ok% = 0
    NEXT i%
  END IF
  IF ok% <> 0 THEN
    FOR i% = 0 TO 14
      FOR j% = i% + 1 TO 15
        IF cu%(i%) = cu%(j%) THEN ok% = 0
      NEXT j%
    NEXT i%
  END IF
  IF ok% = 0 THEN
    CALL Msg("Need each of 0..15 exactly once (16 numbers). Try again with C.")
    EXIT SUB
  END IF
  FOR i% = 0 TO 15
    bd%(i%) = cu%(i%)
  NEXT i%
  mv% = 0
  r% = BlankPos% \ 4 + 1
  s% = Inv% + r%
  IF s% MOD 2 = 0 THEN
    mm$ = "inversions" + STR$(Inv%) + " + blank row" + STR$(r%) + " =" + STR$(s%)
    CALL Msg(mm$ + " is EVEN: solvable!")
  ELSE
    mm$ = "inversions" + STR$(Inv%) + " + blank row" + STR$(r%) + " =" + STR$(s%)
    CALL Msg(mm$ + " is ODD: UNSOLVABLE.")
  END IF
END SUB

SUB DrawBoard
  COLOR 15
  LOCATE 1, 1: PRINT "G14 Sliding Puzzle (ZHI HUI PAN)";
  FOR i% = 0 TO 15
    r% = i% \ 4
    c% = i% MOD 4
    x0% = 40 + c% * 80
    y0% = 64 + r% * 80
    IF bd%(i%) = 0 THEN
      LINE (x0%, y0%)-(x0% + 79, y0% + 79), 0, BF
      LINE (x0%, y0%)-(x0% + 79, y0% + 79), 8, B
    ELSE
      IF bd%(i%) = i% + 1 THEN col% = 2 ELSE col% = 1
      LINE (x0% + 2, y0% + 2)-(x0% + 77, y0% + 77), col%, BF
      LINE (x0%, y0%)-(x0% + 79, y0% + 79), 9, B
      COLOR 15
      LOCATE y0% \ 16 + 3, x0% \ 8 + 5
      PRINT RIGHT$("  " + LTRIM$(STR$(bd%(i%))), 2);
    END IF
  NEXT i%
  COLOR 7
  LOCATE 30, 1
  PRINT "Arrows slide  N new  C check custom  F 14/15 swapped  ESC = menu";
END SUB

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

SUB Info
  n% = Inv%
  r% = BlankPos% \ 4 + 1
  s% = n% + r%
  FOR i% = 3 TO 19
    LOCATE i%, 46: PRINT SPACE$(34);
  NEXT i%
  COLOR 14
  LOCATE 3, 46: PRINT "Inversions (tiles 1-15):"; n%;
  IF n% MOD 2 = 0 THEN
    LOCATE 4, 46: PRINT "-> an EVEN permutation";
  ELSE
    LOCATE 4, 46: PRINT "-> an ODD permutation";
  END IF
  LOCATE 5, 46: PRINT "Blank is in row"; r%; "(from top)";
  LOCATE 6, 46: PRINT "Inversions + row ="; s%;
  IF s% MOD 2 = 0 THEN
    COLOR 10
    LOCATE 7, 46: PRINT "EVEN -> SOLVABLE";
  ELSE
    COLOR 12
    LOCATE 7, 46: PRINT "ODD  -> UNSOLVABLE";
  END IF
  COLOR 15
  LOCATE 9, 46: PRINT "Moves:"; mv%; "  Best:"; best%;
  LOCATE 10, 46: PRINT "Total score:"; tot%;
  COLOR 7
  LOCATE 12, 46: PRINT "Why? A slide swaps the blank with";
  LOCATE 13, 46: PRINT "one tile = one exchange, which";
  LOCATE 14, 46: PRINT "flips even/odd. A vertical slide";
  LOCATE 15, 46: PRINT "hops a tile over 3 others, so";
  LOCATE 16, 46: PRINT "inversions change by an odd";
  LOCATE 17, 46: PRINT "number while the blank row moves";
  LOCATE 18, 46: PRINT "by 1: the sum keeps its parity.";
  LOCATE 19, 46: PRINT "Solved board: 0 + row 4 = EVEN.";
END SUB

FUNCTION Inv%
  n% = 0
  FOR i% = 0 TO 14
    FOR j% = i% + 1 TO 15
      IF bd%(i%) > 0 AND bd%(j%) > 0 THEN
        IF bd%(i%) > bd%(j%) THEN n% = n% + 1
      END IF
    NEXT j%
  NEXT i%
  Inv% = n%
END FUNCTION

FUNCTION IsSolved%
  IsSolved% = 1
  FOR i% = 0 TO 14
    IF bd%(i%) <> i% + 1 THEN IsSolved% = 0
  NEXT i%
  IF bd%(15) <> 0 THEN IsSolved% = 0
END FUNCTION

SUB Msg (t$)
  LOCATE 28, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
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

SUB ResetBoard
  FOR i% = 0 TO 14
    bd%(i%) = i% + 1
  NEXT i%
  bd%(15) = 0
END SUB

SUB Shuffle
  DO
    CALL ResetBoard
    FOR i% = 1 TO 300
      d% = INT(RND * 4)
      SELECT CASE d%
        CASE 0
          dummy% = Slide%(-1, 0)
        CASE 1
          dummy% = Slide%(1, 0)
        CASE 2
          dummy% = Slide%(0, -1)
        CASE ELSE
          dummy% = Slide%(0, 1)
      END SELECT
    NEXT i%
  LOOP WHILE IsSolved% <> 0
  mv% = 0
END SUB

' The tile in the direction opposite to (dr,dc) from the blank slides into the blank.
FUNCTION Slide% (dr%, dc%)
  p% = BlankPos%
  br% = p% \ 4
  bc% = p% MOD 4
  sr% = br% - dr%
  sc% = bc% - dc%
  Slide% = 0
  IF sr% >= 0 AND sr% <= 3 AND sc% >= 0 AND sc% <= 3 THEN
    bd%(p%) = bd%(sr% * 4 + sc%)
    bd%(sr% * 4 + sc%) = 0
    Slide% = 1
  END IF
END FUNCTION

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 20: PRINT "G14  SLIDING PUZZLE  (ZHI HUI PAN)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "ODD and EVEN PERMUTATIONS: every arrangement of the tiles is a"
  LOCATE 8, 6: PRINT "permutation. Count the INVERSIONS (a bigger number before a smaller one)."
  LOCATE 9, 6: PRINT "An exchange of two tiles flips the permutation between even and odd."
  LOCATE 10, 6: PRINT "Exactly half of all arrangements can never be solved; parity tells which."
  COLOR 7
  LOCATE 13, 6: PRINT "Controls:"
  LOCATE 14, 6: PRINT "Arrow keys = slide the tile in that direction into the blank"
  LOCATE 15, 6: PRINT "N = new shuffle    C = type your own arrangement and test it"
  LOCATE 16, 6: PRINT "F = show the famous unsolvable board (14 and 15 swapped)"
  LOCATE 17, 6: PRINT "ESC = back to menu"
  COLOR 10
  LOCATE 19, 6: PRINT "Score = 1000 - 5 per move.  The side panel shows the parity live."
  COLOR 14
  LOCATE 22, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB
