' G05.BAS - Cycloids (YOU QU DE BAI XIAN)
' Educational content: curves drawn by a point on a rolling circle (cycloid, epicycloid,
' hypocycloid, curtate/prolate cycloid) and the functions that describe them.
' Controls: choose a curve 1-4, type the radii and the tracing distance, watch the animation.
'           Any key during the animation = draw faster.  ESC = menu.
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (maxlen%)
DECLARE FUNCTION AskNum% (prompt$, rw%, lo%, hi%)
DECLARE FUNCTION Gcd% (a%, b%)
DECLARE SUB Calc (typ%, bigr%, smr%, dd!, t!)
DECLARE SUB Plot (typ%, bigr%, smr%, dpct%)
DECLARE SUB Formula (typ%)

DIM SHARED ccx!, ccy!, ppx!, ppy!, quit%
CONST PI = 3.14159265
RANDOMIZE TIMER
SCREEN 12
CLS
COLOR 14
LOCATE 2, 1: PRINT "G05 Cycloids (YOU QU DE BAI XIAN)"
COLOR 15
LOCATE 4, 1: PRINT "What you learn (1991 puzzle room): beautiful curves traced by a point"
LOCATE 5, 1: PRINT "on a rolling circle, and the functions that describe them."
COLOR 7
LOCATE 7, 1: PRINT "1  Cycloid        circle rolls on a straight line, point on the rim"
LOCATE 8, 1: PRINT "2  Epicycloid     circle rolls OUTSIDE a fixed circle"
LOCATE 9, 1: PRINT "3  Hypocycloid    circle rolls INSIDE a fixed circle"
LOCATE 10, 1: PRINT "4  Trochoid       like 1 but the point is inside (short) or outside (long)"
LOCATE 12, 1: PRINT "You choose the radius of the fixed circle R, of the rolling circle r, and how"
LOCATE 13, 1: PRINT "far the pen is from the centre of the rolling circle (100% = on the rim)."
LOCATE 14, 1: PRINT "The ratio R : r decides the number of cusps / loops of the curve."
COLOR 11
LOCATE 17, 1: PRINT "Press any key to start, ESC = menu"
k$ = GetKey$
IF k$ = CHR$(27) THEN GOTO ExitGame

DO
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G05 Cycloids - choose a curve";
  COLOR 7
  LOCATE 3, 1: PRINT "1 Cycloid   2 Epicycloid   3 Hypocycloid   4 Trochoid (short/long)"
  LOCATE 4, 1: PRINT "Press 1-4 (ESC = menu): ";
  typ% = 0
  DO
    k$ = GetKey$
    IF k$ = CHR$(27) THEN GOTO ExitGame
    IF LEN(k$) = 1 THEN
      IF k$ >= "1" AND k$ <= "4" THEN typ% = VAL(k$)
    END IF
  LOOP UNTIL typ% > 0
  PRINT k$
  bigr% = 0
  dpct% = 100
  IF typ% = 1 OR typ% = 4 THEN
    smr% = AskNum%("Rolling circle radius r (5-40): ", 6, 5, 40)
  ELSE
    bigr% = AskNum%("Fixed circle radius R (10-120): ", 6, 10, 120)
    IF quit% THEN GOTO ExitGame
    hi% = 60
    IF typ% = 3 THEN hi% = bigr% - 1
    smr% = AskNum%("Rolling circle radius r (3-" + LTRIM$(STR$(hi%)) + "): ", 7, 3, hi%)
  END IF
  IF quit% THEN GOTO ExitGame
  IF typ% <> 1 THEN
    dpct% = AskNum%("Pen distance d as % of r (0-200): ", 8, 0, 200)
    IF quit% THEN GOTO ExitGame
  END IF
  CALL Plot(typ%, bigr%, smr%, dpct%)
  IF quit% THEN GOTO ExitGame
  LOCATE 29, 1: PRINT "Press any key for another curve, ESC = menu"; SPACE$(20);
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

' Ask for an integer in lo..hi; sets quit% on ESC
FUNCTION AskNum% (prompt$, rw%, lo%, hi%)
  v% = lo% - 1
  DO
    LOCATE rw%, 1
    PRINT prompt$; SPACE$(12);
    LOCATE rw%, LEN(prompt$) + 1
    s$ = ReadLine$(4)
    IF quit% THEN EXIT DO
    IF LEN(s$) > 0 THEN
      c$ = LEFT$(s$, 1)
      IF c$ >= "0" AND c$ <= "9" THEN v% = INT(VAL(s$))
    END IF
    IF v% < lo% OR v% > hi% THEN
      LOCATE rw%, 50
      PRINT "Range"; lo%; "to"; hi%; "  ";
      v% = lo% - 1
    END IF
  LOOP UNTIL v% >= lo%
  IF quit% THEN v% = lo%
  LOCATE rw%, 50
  PRINT SPACE$(28);
  AskNum% = v%
END FUNCTION

FUNCTION Gcd% (a%, b%)
  x% = a%
  y% = b%
  DO WHILE y% <> 0
    t% = x% MOD y%
    x% = y%
    y% = t%
  LOOP
  Gcd% = x%
END FUNCTION

' center of rolling circle (ccx, ccy) and pen point (ppx, ppy) at parameter t (math coords)
SUB Calc (typ%, bigr%, smr%, dd!, t!)
  SELECT CASE typ%
    CASE 1, 4
      ccx! = smr% * t!
      ccy! = smr%
      ppx! = smr% * t! - dd! * SIN(t!)
      ppy! = smr% - dd! * COS(t!)
    CASE 2
      k! = (bigr% + smr%) / smr%
      ccx! = (bigr% + smr%) * COS(t!)
      ccy! = (bigr% + smr%) * SIN(t!)
      ppx! = ccx! - dd! * COS(k! * t!)
      ppy! = ccy! - dd! * SIN(k! * t!)
    CASE ELSE
      k! = (bigr% - smr%) / smr%
      ccx! = (bigr% - smr%) * COS(t!)
      ccy! = (bigr% - smr%) * SIN(t!)
      ppx! = ccx! + dd! * COS(k! * t!)
      ppy! = ccy! - dd! * SIN(k! * t!)
  END SELECT
END SUB

SUB Formula (typ%)
  COLOR 11
  SELECT CASE typ%
    CASE 1
      LOCATE 2, 1: PRINT "Cycloid:      x = r (t - sin t)           y = r (1 - cos t)";
    CASE 2
      LOCATE 2, 1: PRINT "Epicycloid:   x = (R+r) cos t - d cos((R+r)t/r)";
      LOCATE 3, 1: PRINT "              y = (R+r) sin t - d sin((R+r)t/r)";
    CASE 3
      LOCATE 2, 1: PRINT "Hypocycloid:  x = (R-r) cos t + d cos((R-r)t/r)";
      LOCATE 3, 1: PRINT "              y = (R-r) sin t - d sin((R-r)t/r)";
    CASE ELSE
      LOCATE 2, 1: PRINT "Trochoid:     x = r t - d sin t           y = r - d cos t";
  END SELECT
END SUB

SUB Plot (typ%, bigr%, smr%, dpct%)
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G05 Cycloids";
  CALL Formula(typ%)
  dd! = smr% * dpct% / 100
  IF typ% = 1 THEN dd! = smr%
  ' scale so that the picture fits
  sf! = 1
  IF typ% = 2 THEN ext! = bigr% + smr% + dd!
  IF typ% = 3 THEN ext! = bigr% - smr% + dd!
  IF typ% = 2 OR typ% = 3 THEN
    IF ext! > 170 THEN sf! = 170 / ext!
    ox% = 320: oy% = 250
    CIRCLE (ox%, oy%), CINT(bigr% * sf!), 9
    g% = Gcd%(bigr%, smr%)
    turns% = smr% \ g%
    IF turns% > 12 THEN turns% = 12
    tmax! = 2 * PI * turns%
    LOCATE 5, 1: COLOR 7
    PRINT "R ="; bigr%; " r ="; smr%; " d ="; INT(dd! * 10) / 10;
    PRINT "  ratio R:r ="; bigr% \ g%; ":"; smr% \ g%;
  ELSE
    ox% = 40: oy% = 400
    LINE (20, oy%)-(620, oy%), 9
    tmax! = 4 * PI
    LOCATE 5, 1: COLOR 7
    PRINT "r ="; smr%; " d ="; INT(dd! * 10) / 10; "  (d < r short loop, d > r long loop)";
  END IF
  dt! = .05
  nst& = INT(tmax! / dt!)
  fast% = 0
  FOR i& = 0 TO nst&
    t! = i& * dt!
    CALL Calc(typ%, bigr%, smr%, dd!, t!)
    sx% = CINT(ox% + sf! * ppx!)
    sy% = CINT(oy% - sf! * ppy!)
    IF i& = 0 THEN
      PSET (sx%, sy%), 14
    ELSE
      LINE -(sx%, sy%), 14
    END IF
    IF i& MOD 10 = 0 THEN
      rs% = CINT(smr% * sf!)
      IF rs% < 1 THEN rs% = 1
      cxs% = CINT(ox% + sf! * ccx!)
      cys% = CINT(oy% - sf! * ccy!)
      CIRCLE (cxs%, cys%), rs%, 8
      LINE (cxs%, cys%)-(sx%, sy%), 8
      LINE (sx%, sy%)-(sx%, sy%), 14
      k$ = INKEY$
      IF k$ = CHR$(27) THEN
        quit% = 1
        EXIT FOR
      ELSEIF k$ <> "" THEN
        fast% = 1
      END IF
      IF fast% = 0 THEN CALL Delay(.03)
      PSET (sx%, sy%), 14
    END IF
  NEXT i&
  COLOR 8
  LOCATE 30, 1: PRINT "ESC = menu";
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

' Line input at the current cursor position; ESC sets quit% and returns ""
FUNCTION ReadLine$ (maxlen%)
  r% = CSRLIN
  c% = POS(0)
  s$ = ""
  DO
    LOCATE r%, c%
    PRINT s$; "_ ";
    k$ = GetKey$
    IF k$ = CHR$(13) THEN
      EXIT DO
    ELSEIF k$ = CHR$(27) THEN
      quit% = 1
      s$ = ""
      EXIT DO
    ELSEIF k$ = CHR$(8) THEN
      IF LEN(s$) > 0 THEN s$ = LEFT$(s$, LEN(s$) - 1)
    ELSEIF LEN(k$) = 1 AND LEN(s$) < maxlen% THEN
      IF k$ >= " " THEN s$ = s$ + k$
    END IF
  LOOP
  LOCATE r%, c%
  PRINT SPACE$(maxlen% + 2);
  LOCATE r%, c%
  ReadLine$ = s$
END FUNCTION
