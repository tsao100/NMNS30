' G10.BAS - Ladder Lottery (CHOU DA TOU)
' Educational content (1991 list): ladder lottery (Amida) as a one-to-one function,
'   its inverse function, and the composition of two functions.
' Controls: Left/Right = pick start, Enter = walk ladder A, G = walk A then B,
'   I = inverse (which start reaches an end?), T = redraw, 4-8 = number of lines,
'   N = new ladders, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Title ()
DECLARE SUB MakeLadders ()
DECLARE SUB DrawAll (s%)
DECLARE FUNCTION Trace% (k%, s%, anim%)
DECLARE SUB Msg (t$)

DIM SHARED rg%(1 TO 2, 1 TO 12, 0 TO 9)
DIM SHARED nl%, quit%
RANDOMIZE TIMER
SCREEN 12
nl% = 5
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
CALL MakeLadders
s% = 1
CALL DrawAll(s%)
DO
  k$ = GetKey$
  IF k$ = CHR$(27) THEN
    EXIT DO
  ELSEIF k$ = CHR$(0) + "K" THEN
    s% = s% - 1
    IF s% < 1 THEN s% = nl%
    CALL DrawAll(s%)
  ELSEIF k$ = CHR$(0) + "M" THEN
    s% = s% + 1
    IF s% > nl% THEN s% = 1
    CALL DrawAll(s%)
  ELSEIF k$ = CHR$(13) THEN
    CALL DrawAll(s%)
    e% = Trace%(1, s%, 1)
    CALL Msg("f(" + LTRIM$(STR$(s%)) + ") = " + LTRIM$(STR$(e%)) + "   (one start, one end)")
  ELSEIF UCASE$(k$) = "G" THEN
    CALL DrawAll(s%)
    e% = Trace%(1, s%, 1)
    e2% = Trace%(2, e%, 1)
    CALL Msg("g(f(" + LTRIM$(STR$(s%)) + ")) = g(" + LTRIM$(STR$(e%)) + ") = " + LTRIM$(STR$(e2%)))
  ELSEIF UCASE$(k$) = "I" THEN
    CALL Msg("Inverse: press the END number (1-" + LTRIM$(STR$(nl%)) + ") on the bottom of A")
    d$ = GetKey$
    d% = VAL(d$)
    IF d$ >= "1" AND d$ <= "9" AND d% <= nl% THEN
      FOR t% = 1 TO nl%
        IF Trace%(1, t%, 0) = d% THEN s% = t%
      NEXT t%
      CALL DrawAll(s%)
      e% = Trace%(1, s%, 1)
      a$ = LTRIM$(STR$(d%)): b$ = LTRIM$(STR$(s%)): c$ = LTRIM$(STR$(e%))
      CALL Msg("f^-1(" + a$ + ") = " + b$ + ", since f(" + b$ + ") = " + c$)
    ELSEIF d$ = CHR$(27) THEN
      EXIT DO
    ELSE
      CALL DrawAll(s%)
    END IF
  ELSEIF UCASE$(k$) = "N" THEN
    CALL MakeLadders
    CALL DrawAll(s%)
  ELSEIF k$ >= "4" AND k$ <= "8" THEN
    nl% = VAL(k$)
    IF s% > nl% THEN s% = nl%
    CALL MakeLadders
    CALL DrawAll(s%)
  ELSEIF UCASE$(k$) = "T" THEN
    CALL DrawAll(s%)
  END IF
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

SUB DrawAll (s%)
  CLS
  COLOR 15
  LOCATE 1, 1: PRINT "G10 Ladder Lottery (CHOU DA TOU)   lines:"; nl%
  COLOR 7
  LOCATE 2, 1: PRINT "Ladder A = function f, ladder B = function g. Ends of A feed the starts of B."
  FOR k% = 1 TO 2
    x0% = 40 + (k% - 1) * 320
    COLOR 11
    LOCATE 4, x0% \ 8 - 1
    IF k% = 1 THEN PRINT "A (f)" ELSE PRINT "B (g)"
    FOR i% = 1 TO nl%
      x% = x0% + (i% - 1) * 36
      LINE (x%, 80)-(x%, 384), 7
      IF k% = 1 AND i% = s% THEN COLOR 12 ELSE COLOR 15
      LOCATE 5, x% \ 8 + 1
      PRINT LTRIM$(STR$(i%));
      COLOR 15
      LOCATE 25, x% \ 8 + 1
      PRINT LTRIM$(STR$(i%));
    NEXT i%
    FOR l% = 1 TO 12
      y% = 96 + (l% - 1) * 24
      FOR i% = 1 TO nl% - 1
        IF rg%(k%, l%, i%) = 1 THEN
          LINE (x0% + (i% - 1) * 36, y%)-(x0% + i% * 36, y%), 9
        END IF
      NEXT i%
    NEXT l%
  NEXT k%
  ' mapping table: every start has exactly one end (one-to-one)
  COLOR 10
  LOCATE 26, 1: PRINT "f    : ";
  LOCATE 27, 1: PRINT "g    : ";
  LOCATE 28, 1: PRINT "g(f) : ";
  FOR i% = 1 TO nl%
    a% = Trace%(1, i%, 0)
    b% = Trace%(2, i%, 0)
    c% = Trace%(2, a%, 0)
    LOCATE 26, 9 + (i% - 1) * 7: PRINT LTRIM$(STR$(i%)); ">"; LTRIM$(STR$(a%));
    LOCATE 27, 9 + (i% - 1) * 7: PRINT LTRIM$(STR$(i%)); ">"; LTRIM$(STR$(b%));
    LOCATE 28, 9 + (i% - 1) * 7: PRINT LTRIM$(STR$(i%)); ">"; LTRIM$(STR$(c%));
  NEXT i%
  COLOR 7
  LOCATE 30, 1
  PRINT "Left/Right start  Enter walk  G A+B  I inverse  4-8 lines  N new  ESC = menu";
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB MakeLadders
  FOR k% = 1 TO 2
    FOR l% = 1 TO 12
      FOR i% = 0 TO 9
        rg%(k%, l%, i%) = 0
      NEXT i%
      FOR i% = 1 TO nl% - 1
        IF rg%(k%, l%, i% - 1) = 0 AND RND < .45 THEN rg%(k%, l%, i%) = 1
      NEXT i%
    NEXT l%
  NEXT k%
END SUB

SUB Msg (t$)
  LOCATE 29, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 20: PRINT "G10  LADDER LOTTERY  (CHOU DA TOU)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "The ladder lottery is a ONE-TO-ONE FUNCTION: each start gives one end,"
  LOCATE 8, 6: PRINT "and no two starts share an end. Reverse it to get the INVERSE function."
  LOCATE 9, 6: PRINT "Chain two ladders to get a COMPOSITE function g(f(x))."
  COLOR 7
  LOCATE 12, 6: PRINT "Controls:"
  LOCATE 13, 6: PRINT "Left/Right = choose a start    Enter = walk ladder A"
  LOCATE 14, 6: PRINT "G = walk A then B (composition)  I = inverse: which start reaches an end"
  LOCATE 15, 6: PRINT "4-8 = number of lines   N = new ladders   ESC = back to menu"
  COLOR 10
  LOCATE 18, 6: PRINT "Rule: go down; at every rung you meet, cross it to the next line."
  COLOR 14
  LOCATE 22, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB

FUNCTION Trace% (k%, s%, anim%)
  p% = s%
  x0% = 40 + (k% - 1) * 320
  y% = 80
  FOR l% = 1 TO 12
    yl% = 96 + (l% - 1) * 24
    q% = p%
    IF rg%(k%, l%, p%) = 1 THEN
      q% = p% + 1
    ELSEIF rg%(k%, l%, p% - 1) = 1 THEN
      q% = p% - 1
    END IF
    IF anim% <> 0 THEN
      LINE (x0% + (p% - 1) * 36, y%)-(x0% + (p% - 1) * 36, yl%), 14
      IF q% <> p% THEN LINE (x0% + (p% - 1) * 36, yl%)-(x0% + (q% - 1) * 36, yl%), 14
      CALL Delay(.06)
    END IF
    p% = q%
    y% = yl%
  NEXT l%
  IF anim% <> 0 THEN LINE (x0% + (p% - 1) * 36, y%)-(x0% + (p% - 1) * 36, 384), 14
  Trace% = p%
END FUNCTION
