' G04.BAS - Tower of Hanoi (HAN NUO ER TA)
' Educational content: recursive thinking; n discs need 2^n - 1 moves.
' Controls: press source peg then target peg (1-3), e.g. 1 then 3.
'           D = demo (computer solves recursively)  R = restart  N = change discs  ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (maxlen%)
DECLARE FUNCTION MoveDisc% (a%, b%)
DECLARE SUB DrawAll (dep%)
DECLARE SUB Msg (s$, c%)
DECLARE SUB Solve (k%, a%, b%, c%, dep%)
DECLARE SUB Reset2 ()

DIM SHARED pg%(1 TO 3, 1 TO 7), cnt%(1 TO 3)
DIM SHARED n%, moves%, quit%, maxdep%
RANDOMIZE TIMER
SCREEN 12
CLS
COLOR 14
LOCATE 2, 1: PRINT "G04 Tower of Hanoi (HAN NUO ER TA)"
COLOR 15
LOCATE 4, 1: PRINT "What you learn (1991 puzzle room): recursion - solving a big problem by"
LOCATE 5, 1: PRINT "solving the same problem for a smaller number of discs."
COLOR 7
LOCATE 7, 1: PRINT "Move all discs from peg 1 to peg 3.  Rules:"
LOCATE 8, 1: PRINT "   - move one disc at a time (the top disc of a peg)"
LOCATE 9, 1: PRINT "   - never put a bigger disc on a smaller one"
LOCATE 10, 1: PRINT "With n discs the least number of moves is 2^n - 1 (3 discs: 7, 7 discs: 127)."
LOCATE 12, 1: PRINT "Recursion: to move n discs A->C, move n-1 discs A->B, move the big disc"
LOCATE 13, 1: PRINT "A->C, then move n-1 discs B->C.   The demo shows the recursion depth."
LOCATE 15, 1: PRINT "Keys: press the source peg (1-3) then the target peg (1-3)"
LOCATE 16, 1: PRINT "      D = demo   R = restart   N = change number of discs   ESC = menu"
COLOR 11
LOCATE 19, 1: PRINT "How many discs (3-7)?  Press a key 3 to 7:"
n% = 0
DO
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
  IF LEN(k$) = 1 THEN
    IF k$ >= "3" AND k$ <= "7" THEN n% = VAL(k$)
  END IF
LOOP UNTIL n% >= 3

CALL Reset2
CALL DrawAll(0)
CALL Msg("Your move: press source peg, then target peg.", 10)
DO
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
  u$ = UCASE$(k$)
  IF LEN(k$) = 1 AND k$ >= "1" AND k$ <= "3" THEN
    a% = VAL(k$)
    CALL Msg("From peg" + STR$(a%) + " to which peg?", 14)
    k2$ = GetKey$
    IF k2$ = CHR$(27) THEN GOTO ExitGame
    IF LEN(k2$) = 1 AND k2$ >= "1" AND k2$ <= "3" THEN
      b% = VAL(k2$)
      IF MoveDisc%(a%, b%) = 1 THEN
        CALL DrawAll(0)
        IF cnt%(3) = n% THEN
          mn% = INT(2 ^ n% + .5) - 1
          m$ = "SOLVED in" + STR$(moves%) + " moves!  Minimum is 2^n-1 =" + STR$(mn%)
          CALL Msg(m$ + ".  R to replay.", 10)
        ELSE
          CALL Msg("Moved peg" + STR$(a%) + " to peg" + STR$(b%) + ".", 10)
        END IF
      ELSE
        CALL Msg("Illegal move! (empty peg, or bigger disc onto smaller)", 12)
      END IF
    ELSE
      CALL Msg("Cancelled.", 7)
    END IF
  ELSEIF u$ = "R" THEN
    CALL Reset2
    CALL DrawAll(0)
    CALL Msg("Restarted.", 7)
  ELSEIF u$ = "N" THEN
    CALL Msg("New disc count (3-7)?", 14)
    k2$ = GetKey$
    IF k2$ = CHR$(27) THEN GOTO ExitGame
    IF LEN(k2$) = 1 THEN
      IF k2$ >= "3" AND k2$ <= "7" THEN n% = VAL(k2$)
    END IF
    CALL Reset2
    CALL DrawAll(0)
    CALL Msg("Discs:" + STR$(n%), 7)
  ELSEIF u$ = "D" THEN
    CALL Reset2
    CALL DrawAll(0)
    maxdep% = 0
    CALL Solve(n%, 1, 3, 2, 1)
    IF quit% THEN GOTO ExitGame
    mn% = INT(2 ^ n% + .5) - 1
    m$ = "Demo done:" + STR$(moves%) + " moves = 2^" + LTRIM$(STR$(n%))
    CALL Msg(m$ + " - 1 =" + STR$(mn%), 10)
  END IF
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

SUB Reset2
  FOR i% = 1 TO 3
    cnt%(i%) = 0
    FOR j% = 1 TO 7
      pg%(i%, j%) = 0
    NEXT j%
  NEXT i%
  FOR j% = 1 TO n%
    pg%(1, j%) = n% - j% + 1
  NEXT j%
  cnt%(1) = n%
  moves% = 0
END SUB

' move the top disc of peg a to peg b if legal; returns 1 on success
FUNCTION MoveDisc% (a%, b%)
  r% = 0
  IF a% >= 1 AND a% <= 3 AND b% >= 1 AND b% <= 3 AND a% <> b% THEN
    IF cnt%(a%) > 0 THEN
      d% = pg%(a%, cnt%(a%))
      ok% = 0
      IF cnt%(b%) = 0 THEN
        ok% = 1
      ELSEIF pg%(b%, cnt%(b%)) > d% THEN
        ok% = 1
      END IF
      IF ok% = 1 AND cnt%(b%) < 7 THEN
        pg%(a%, cnt%(a%)) = 0
        cnt%(a%) = cnt%(a%) - 1
        cnt%(b%) = cnt%(b%) + 1
        pg%(b%, cnt%(b%)) = d%
        moves% = moves% + 1
        r% = 1
      END IF
    END IF
  END IF
  MoveDisc% = r%
END FUNCTION

' Recursive solution: move k discs from peg a to peg b using peg c
SUB Solve (k%, a%, b%, c%, dep%)
  IF quit% OR k% < 1 THEN EXIT SUB
  IF dep% > maxdep% THEN maxdep% = dep%
  CALL Solve(k% - 1, a%, c%, b%, dep% + 1)
  IF quit% THEN EXIT SUB
  dummy% = MoveDisc%(a%, b%)
  CALL DrawAll(dep%)
  m$ = "Move disc" + STR$(k%) + ": peg" + STR$(a%) + " ->" + STR$(b%)
  CALL Msg(m$ + "   recursion level" + STR$(dep%), 14)
  CALL Delay(.3)
  IF INKEY$ = CHR$(27) THEN quit% = 1
  IF quit% THEN EXIT SUB
  CALL Solve(k% - 1, c%, b%, a%, dep% + 1)
END SUB

SUB DrawAll (dep%)
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G04 Tower of Hanoi (HAN NUO ER TA)";
  COLOR 7
  LOCATE 3, 1: PRINT "Discs:"; n%; "   Moves:"; moves%; "   Minimum (2^n-1):"; INT(2 ^ n% + .5) - 1;
  IF dep% > 0 THEN PRINT "   Depth:"; dep%; " of max"; n%;
  LINE (40, 400)-(600, 408), 6, BF
  FOR p% = 1 TO 3
    x% = 120 + (p% - 1) * 200
    LINE (x% - 3, 250)-(x% + 3, 400), 6, BF
    COLOR 15
    LOCATE 27, (x% \ 8) + 1
    PRINT USING "#"; p%;
    FOR j% = 1 TO cnt%(p%)
      sz% = pg%(p%, j%)
      w% = 10 + sz% * 8
      y% = 400 - j% * 18
      LINE (x% - w%, y%)-(x% + w%, y% + 16), 8 + sz%, BF
    NEXT j%
  NEXT p%
  COLOR 8
  LOCATE 30, 1: PRINT "1-3 = pegs   D = demo   R = restart   N = discs   ESC = menu";
  COLOR 15
END SUB

SUB Msg (s$, c%)
  COLOR c%
  LOCATE 29, 1
  PRINT LEFT$(s$ + SPACE$(79), 79);
  COLOR 15
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

' Read a line with the keyboard; ESC sets quit% = 1
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
