' G19.BAS - 3D Connect (LI TI LIAN ZHU)
' Educational content (1991 list): solid (3-D) connect-four. A point in space needs three
'   numbers (x,y,z); the 4x4x4 cube is shown as four flat planes (levels).
' Controls: Left/Right/Up/Down = move cursor, Enter or Space = drop piece, ESC = menu
DECLARE SUB BuildLines ()
DECLARE SUB DrawBoard (md%)
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION WinIf% (cell%, pl%)
DECLARE FUNCTION Score& (c%, pl%)
DECLARE FUNCTION CpuPick% (pl%)

DIM SHARED bd%(0 TO 63)
DIM SHARED ht%(0 TO 15)
DIM SHARED ln%(1 TO 80, 0 TO 3)
DIM SHARED nl%, wl%, cx%, cy%
DIM pnm$(1 TO 2)

RANDOMIZE TIMER
CALL BuildLines
SCREEN 12
CLS
COLOR 14
LOCATE 2, 22: PRINT "G19  3D CONNECT  (LI TI LIAN ZHU)"
COLOR 15
LOCATE 4, 8: PRINT "Connect four pieces in a line inside a 4 x 4 x 4 cube."
COLOR 11
LOCATE 6, 8: PRINT "What you learn: a point in space needs THREE numbers (x, y, z)."
LOCATE 7, 8: PRINT "The cube is drawn as FOUR flat planes (Level 1 = bottom ... Level 4 = top)."
LOCATE 8, 8: PRINT "Cell (x,y,z): x = column, y = row, z = level. A column (x,y) runs"
LOCATE 9, 8: PRINT "through all four levels; pieces fall to the lowest empty level (gravity)."
LOCATE 10, 8: PRINT "A winning line can lie in one plane, run straight up through the"
LOCATE 11, 8: PRINT "levels, or slant through 3-D space. The cube holds 76 lines in all."
COLOR 7
LOCATE 14, 8: PRINT "Arrows move the cursor (shown on all four levels), Enter/Space drops."
LOCATE 15, 8: PRINT "R = rematch after a game.   ESC = back to menu."
COLOR 14
LOCATE 18, 8: PRINT "Press 1 = two players     2 = play against the computer"
DO
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
LOOP UNTIL k$ = "1" OR k$ = "2"
mode% = VAL(k$)
pnm$(1) = "Player 1 (red)"
IF mode% = 2 THEN pnm$(2) = "Computer (blue)" ELSE pnm$(2) = "Player 2 (blue)"
w1% = 0: w2% = 0

DO
  FOR i% = 0 TO 63
    bd%(i%) = 0
  NEXT i%
  FOR i% = 0 TO 15
    ht%(i%) = 0
  NEXT i%
  turn% = 1: gover% = 0: moves% = 0: cx% = 1: cy% = 1
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G19 3D Connect (LI TI LIAN ZHU)";
  COLOR 11
  LOCATE 20, 4: PRINT "A 3-D point needs three numbers (x,y,z). ";
  PRINT "Each Level is one flat plane (z fixed).";
  LOCATE 21, 4: PRINT "Lines of 4 can lie in a plane, go straight up through the levels, or slant";
  LOCATE 22, 4: PRINT "through the cube like a 3-D diagonal. 76 winning lines exist.";
  DO
    CALL DrawBoard(0)
    COLOR 15
    c% = cx% + 4 * cy%
    LOCATE 16, 4
    IF ht%(c%) < 4 THEN
      PRINT "Cursor column x="; LTRIM$(STR$(cx% + 1)); " y="; LTRIM$(STR$(cy% + 1));
      PRINT "  -> piece falls to level z="; LTRIM$(STR$(ht%(c%) + 1)); "      ";
    ELSE
      PRINT "Cursor column x="; LTRIM$(STR$(cx% + 1)); " y="; LTRIM$(STR$(cy% + 1));
      PRINT "  is FULL, choose another            ";
    END IF
    LOCATE 17, 4
    PRINT "Turn: "; pnm$(turn%); "        ";
    LOCATE 18, 4
    PRINT "Wins  Player 1:"; w1%; "   "; pnm$(2); ":"; w2%; "      ";
    COLOR 7
    LOCATE 30, 1: PRINT "Arrows=move  Enter/Space=drop  ESC=menu";
    drop% = -1
    IF mode% = 2 AND turn% = 2 THEN
      Delay 0.5
      drop% = CpuPick%(2)
    ELSE
      k$ = GetKey$
      IF k$ = CHR$(27) THEN GOTO ExitGame
      IF LEN(k$) = 2 THEN
        SELECT CASE ASC(RIGHT$(k$, 1))
          CASE 72: IF cy% > 0 THEN cy% = cy% - 1
          CASE 80: IF cy% < 3 THEN cy% = cy% + 1
          CASE 75: IF cx% > 0 THEN cx% = cx% - 1
          CASE 77: IF cx% < 3 THEN cx% = cx% + 1
        END SELECT
      ELSEIF k$ = CHR$(13) OR k$ = " " THEN
        IF ht%(c%) < 4 THEN drop% = c%
      END IF
    END IF
    IF drop% >= 0 THEN
      cell% = drop% + 16 * ht%(drop%)
      bd%(cell%) = turn%
      ht%(drop%) = ht%(drop%) + 1
      moves% = moves% + 1
      IF WinIf%(cell%, turn%) = 1 THEN
        gover% = 1
      ELSEIF moves% >= 64 THEN
        gover% = 2
      ELSE
        turn% = 3 - turn%
      END IF
    END IF
  LOOP UNTIL gover% > 0
  CALL DrawBoard(gover%)
  COLOR 10
  LOCATE 24, 4
  IF gover% = 1 THEN
    PRINT pnm$(turn%); " connects four!  (line shown in green)        ";
    IF turn% = 1 THEN w1% = w1% + 1 ELSE w2% = w2% + 1
  ELSE
    PRINT "The cube is full - a draw.                               ";
  END IF
  COLOR 14
  LOCATE 25, 4: PRINT "R = rematch    ESC = menu";
  DO
    k$ = GetKey$
    IF k$ = CHR$(27) THEN GOTO ExitGame
  LOOP UNTIL UCASE$(k$) = "R"
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

' Build the 76 winning lines. Each line = 4 cell numbers, cell = x + 4*y + 16*z.
SUB BuildLines
  nl% = 0
  FOR dx% = -1 TO 1
    FOR dy% = -1 TO 1
      FOR dz% = -1 TO 1
        ok% = 0
        IF dx% > 0 THEN ok% = 1
        IF dx% = 0 AND dy% > 0 THEN ok% = 1
        IF dx% = 0 AND dy% = 0 AND dz% > 0 THEN ok% = 1
        IF ok% = 1 THEN
          FOR x% = 0 TO 3
            FOR y% = 0 TO 3
              FOR z% = 0 TO 3
                ex% = x% + 3 * dx%
                ey% = y% + 3 * dy%
                ez% = z% + 3 * dz%
                IF ex% >= 0 AND ex% <= 3 AND ey% >= 0 AND ey% <= 3 AND ez% >= 0 AND ez% <= 3 THEN
                  nl% = nl% + 1
                  FOR i% = 0 TO 3
                    ln%(nl%, i%) = (x% + i% * dx%) + 4 * (y% + i% * dy%) + 16 * (z% + i% * dz%)
                  NEXT i%
                END IF
              NEXT z%
            NEXT y%
          NEXT x%
        END IF
      NEXT dz%
    NEXT dy%
  NEXT dx%
END SUB

' md% = 0 normal (show cursor), 1 = game won (show winning line), 2 = draw
SUB DrawBoard (md%)
  FOR z% = 0 TO 3
    x0% = 20 + z% * 155
    COLOR 7
    LOCATE 4, x0% \ 8 + 1
    SELECT CASE z%
      CASE 0: PRINT "Level 1 (bottom)";
      CASE 3: PRINT "Level 4 (top)   ";
      CASE ELSE: PRINT "Level "; LTRIM$(STR$(z% + 1)); "        ";
    END SELECT
    FOR y% = 0 TO 3
      FOR x% = 0 TO 3
        cxp% = x0% + x% * 34 + 17
        cyp% = 72 + y% * 34 + 17
        LINE (cxp% - 16, cyp% - 16)-(cxp% + 16, cyp% + 16), 0, BF
        LINE (cxp% - 16, cyp% - 16)-(cxp% + 16, cyp% + 16), 8, B
        v% = bd%(x% + 4 * y% + 16 * z%)
        IF v% = 0 THEN
          CIRCLE (cxp%, cyp%), 3, 8
        ELSE
          IF v% = 1 THEN pc% = 12 ELSE pc% = 9
          CIRCLE (cxp%, cyp%), 12, pc%
          PAINT (cxp%, cyp%), pc%, pc%
        END IF
      NEXT x%
    NEXT y%
    IF md% = 0 THEN
      xx% = x0% + cx% * 34 + 17
      yy% = 72 + cy% * 34 + 17
      LINE (xx% - 16, yy% - 16)-(xx% + 16, yy% + 16), 14, B
      c% = cx% + 4 * cy%
      IF ht%(c%) = z% THEN
        LINE (xx% - 15, yy% - 15)-(xx% + 15, yy% + 15), 15, B
      END IF
    END IF
  NEXT z%
  IF md% = 1 THEN
    FOR j% = 0 TO 3
      q% = ln%(wl%, j%)
      zz% = q% \ 16
      yy% = (q% \ 4) MOD 4
      xx% = q% MOD 4
      px1% = 20 + zz% * 155 + xx% * 34 + 17
      py1% = 72 + yy% * 34 + 17
      LINE (px1% - 17, py1% - 17)-(px1% + 17, py1% + 17), 10, B
      LINE (px1% - 14, py1% - 14)-(px1% + 14, py1% + 14), 10, B
    NEXT j%
  END IF
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

' Would a piece of player pl% at cell% complete a line? (sets wl% to that line)
FUNCTION WinIf% (cell%, pl%)
  r% = 0
  FOR i% = 1 TO nl%
    inl% = 0: cnt% = 0
    FOR j% = 0 TO 3
      IF ln%(i%, j%) = cell% THEN
        inl% = 1
      ELSEIF bd%(ln%(i%, j%)) = pl% THEN
        cnt% = cnt% + 1
      END IF
    NEXT j%
    IF inl% = 1 AND cnt% = 3 THEN r% = 1: wl% = i%
  NEXT i%
  WinIf% = r%
END FUNCTION

' Heuristic value of dropping in column c% for player pl%
FUNCTION Score& (c%, pl%)
  cell% = c% + 16 * ht%(c%)
  op% = 3 - pl%
  IF WinIf%(cell%, pl%) = 1 THEN Score& = 100000: EXIT FUNCTION
  IF WinIf%(cell%, op%) = 1 THEN Score& = 50000: EXIT FUNCTION
  s& = INT(RND * 5)
  FOR i% = 1 TO nl%
    inl% = 0: m% = 0: o% = 0
    FOR j% = 0 TO 3
      q% = ln%(i%, j%)
      IF q% = cell% THEN
        inl% = 1
      ELSEIF bd%(q%) = pl% THEN
        m% = m% + 1
      ELSEIF bd%(q%) = op% THEN
        o% = o% + 1
      END IF
    NEXT j%
    IF inl% = 1 THEN
      IF o% = 0 THEN s& = s& + m% * m% * 4 + 1
      IF m% = 0 THEN s& = s& + o% * o% * 3
    END IF
  NEXT i%
  IF ht%(c%) < 3 THEN
    IF WinIf%(cell% + 16, op%) = 1 THEN s& = s& - 30000
  END IF
  Score& = s&
END FUNCTION

FUNCTION CpuPick% (pl%)
  best& = -999999
  bc% = 0
  FOR c% = 0 TO 15
    IF ht%(c%) < 4 THEN
      v& = Score&(c%, pl%)
      IF v& > best& THEN best& = v&: bc% = c%
    END IF
  NEXT c%
  CpuPick% = bc%
END FUNCTION
