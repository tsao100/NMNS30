' G30.BAS - Computer Drawing (DIAN NAO HUI TU)
' Educational content (1991 list): computer-aided coloring and drawing.
'   A computer picture is made of points (pixels) with coordinates. Lines, boxes and circles are
'   defined by a few numbers, and colouring is filling a closed region with a colour.
' Controls: arrows move the cursor; 1 Pen 2 Line 3 Box 4 Circle 5 Fill (tool);
'   Space/Enter = use the tool (Pen: put down/lift; Line/Box/Circle: press at start, move, press
'   at end; Fill: colour the closed region under the cursor); . and , = next/previous colour;
'   S = step size; U = undo; T = next outline picture to colour; N = clear; ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Title ()
DECLARE SUB Template (t%)
DECLARE SUB Redraw ()
DECLARE SUB Hud (tool%, col%, stp%, pn%, anch%, cx%, cy%)
DECLARE SUB DoCmd (t%, c%, a%, b%, d%, e%)
DECLARE SUB Rec (t%, c%, a%, b%, d%, e%)
DECLARE SUB Flood (x0%, y0%, fc%)

CONST MAXC = 1500
CONST CMAX = 407
DIM SHARED cm%(1 TO MAXC, 0 TO 5)
DIM SHARED ncmd%, full%, tmpl%
DIM SHARED cur%(1 TO 120)
DIM SHARED stx%(1 TO 800), sty%(1 TO 800)

RANDOMIZE TIMER
SCREEN 12
CALL Title
' make the cursor image: a cross that is drawn and erased with XOR
CLS
LINE (8, 0)-(8, 16), 15
LINE (0, 8)-(16, 8), 15
GET (0, 0)-(16, 16), cur%
cx% = 320: cy% = 200
tool% = 1: col% = 12: stp% = 4: pn% = 0: anch% = 0
ax% = 0: ay% = 0
ncmd% = 0: full% = 0: tmpl% = 0
CALL Redraw
CALL Hud(tool%, col%, stp%, pn%, anch%, cx%, cy%)
PUT (cx% - 8, cy% - 8), cur%, XOR
DO
  k$ = INKEY$
  IF k$ <> "" THEN
    IF k$ = CHR$(27) THEN EXIT DO
    PUT (cx% - 8, cy% - 8), cur%, XOR
    nx% = cx%: ny% = cy%
    IF LEN(k$) = 2 THEN
      SELECT CASE RIGHT$(k$, 1)
        CASE "H": ny% = cy% - stp%
        CASE "P": ny% = cy% + stp%
        CASE "K": nx% = cx% - stp%
        CASE "M": nx% = cx% + stp%
      END SELECT
      IF nx% < 8 THEN nx% = 8
      IF nx% > 631 THEN nx% = 631
      IF ny% < 8 THEN ny% = 8
      IF ny% > CMAX THEN ny% = CMAX
      IF pn% = 1 AND (nx% <> cx% OR ny% <> cy%) THEN
        CALL DoCmd(1, col%, cx%, cy%, nx%, ny%)
        CALL Rec(1, col%, cx%, cy%, nx%, ny%)
      END IF
      cx% = nx%: cy% = ny%
    ELSE
      SELECT CASE UCASE$(k$)
        CASE "1", "2", "3", "4", "5"
          tool% = VAL(k$)
          anch% = 0
        CASE "."
          col% = (col% + 1) MOD 16
        CASE ","
          col% = (col% + 15) MOD 16
        CASE "S"
          IF stp% = 1 THEN
            stp% = 4
          ELSEIF stp% = 4 THEN
            stp% = 16
          ELSE
            stp% = 1
          END IF
        CASE " ", CHR$(13)
          SELECT CASE tool%
            CASE 1
              pn% = 1 - pn%
            CASE 2, 3, 4
              IF anch% = 0 THEN
                ax% = cx%: ay% = cy%: anch% = 1
              ELSE
                IF tool% = 4 THEN
                  r% = INT(SQR((cx% - ax%) ^ 2 + (cy% - ay%) ^ 2))
                  IF r% < 1 THEN r% = 1
                  CALL DoCmd(3, col%, ax%, ay%, r%, 0)
                  CALL Rec(3, col%, ax%, ay%, r%, 0)
                ELSE
                  CALL DoCmd(tool%, col%, ax%, ay%, cx%, cy%)
                  CALL Rec(tool%, col%, ax%, ay%, cx%, cy%)
                END IF
                anch% = 0
              END IF
            CASE 5
              CALL DoCmd(4, col%, cx%, cy%, 0, 0)
              CALL Rec(4, col%, cx%, cy%, 0, 0)
          END SELECT
        CASE "U"
          IF full% = 1 THEN
            LOCATE 28, 2: PRINT "Undo list was full - press N or T to start again.";
          ELSEIF ncmd% > 0 THEN
            ncmd% = ncmd% - 1
            CALL Redraw
          END IF
        CASE "T"
          tmpl% = (tmpl% + 1) MOD 4
          ncmd% = 0: full% = 0: anch% = 0
          CALL Redraw
        CASE "N"
          tmpl% = 0
          ncmd% = 0: full% = 0: anch% = 0
          CALL Redraw
      END SELECT
    END IF
    CALL Hud(tool%, col%, stp%, pn%, anch%, cx%, cy%)
    PUT (cx% - 8, cy% - 8), cur%, XOR
  END IF
LOOP
GOTO ExitGame

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

SUB DoCmd (t%, c%, a%, b%, d%, e%)
  SELECT CASE t%
    CASE 1
      LINE (a%, b%)-(d%, e%), c%
    CASE 2
      LINE (a%, b%)-(d%, e%), c%, B
    CASE 3
      CIRCLE (a%, b%), d%, c%
    CASE 4
      CALL Flood(a%, b%, c%)
  END SELECT
END SUB

SUB Flood (x0%, y0%, fc%)
  ' scanline flood fill: colours the connected region that has the same colour as the start point
  t% = POINT(x0%, y0%)
  IF t% = fc% OR t% < 0 THEN EXIT SUB
  sp% = 1
  stx%(1) = x0%: sty%(1) = y0%
  DO WHILE sp% > 0
    x% = stx%(sp%): y% = sty%(sp%)
    sp% = sp% - 1
    IF POINT(x%, y%) = t% THEN
      xl% = x%
      DO WHILE xl% > 0 AND POINT(xl% - 1, y%) = t%
        xl% = xl% - 1
      LOOP
      xr% = x%
      DO WHILE xr% < 639 AND POINT(xr% + 1, y%) = t%
        xr% = xr% + 1
      LOOP
      LINE (xl%, y%)-(xr%, y%), fc%
      FOR dy% = -1 TO 1 STEP 2
        yy% = y% + dy%
        IF yy% >= 0 AND yy% <= 479 THEN
          inspan% = 0
          FOR xx% = xl% TO xr%
            IF POINT(xx%, yy%) = t% THEN
              IF inspan% = 0 AND sp% < 800 THEN
                sp% = sp% + 1
                stx%(sp%) = xx%: sty%(sp%) = yy%
              END IF
              inspan% = 1
            ELSE
              inspan% = 0
            END IF
          NEXT xx%
        END IF
      NEXT dy%
    END IF
  LOOP
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB Hud (tool%, col%, stp%, pn%, anch%, cx%, cy%)
  LINE (0, 416)-(639, 479), 0, BF
  FOR c% = 0 TO 15
    LINE (8 + c% * 20, 420)-(24 + c% * 20, 432), c%, BF
  NEXT c%
  LINE (6 + col% * 20, 418)-(26 + col% * 20, 434), 15, B
  COLOR 15
  LOCATE 29, 2
  PRINT "Tool:";
  SELECT CASE tool%
    CASE 1
      IF pn% = 1 THEN
        PRINT " PEN (down)";
      ELSE
        PRINT " PEN (up)";
      END IF
    CASE 2
      PRINT " LINE";
    CASE 3
      PRINT " BOX";
    CASE 4
      PRINT " CIRCLE";
    CASE ELSE
      PRINT " FILL";
  END SELECT
  PRINT "  Colour"; col%; " Step"; stp%; " Pos"; cx%; ","; cy%; "  ";
  IF anch% = 1 THEN PRINT "move, then Space";
  PRINT "          ";
  COLOR 7
  LOCATE 30, 2
  PRINT "1-5 tool Space=use .,=colour S=step U=undo T=picture N=clear ESC=menu";
END SUB

SUB Redraw
  CLS
  CALL Template(tmpl%)
  FOR i% = 1 TO ncmd%
    CALL DoCmd(cm%(i%, 0), cm%(i%, 1), cm%(i%, 2), cm%(i%, 3), cm%(i%, 4), cm%(i%, 5))
  NEXT i%
END SUB

SUB Rec (t%, c%, a%, b%, d%, e%)
  IF ncmd% >= MAXC THEN
    full% = 1
    EXIT SUB
  END IF
  ncmd% = ncmd% + 1
  cm%(ncmd%, 0) = t%: cm%(ncmd%, 1) = c%
  cm%(ncmd%, 2) = a%: cm%(ncmd%, 3) = b%
  cm%(ncmd%, 4) = d%: cm%(ncmd%, 5) = e%
END SUB

SUB Template (t%)
  SELECT CASE t%
    CASE 1
      ' house
      LINE (200, 200)-(400, 360), 15, B
      LINE (180, 200)-(300, 110), 15
      LINE (300, 110)-(420, 200), 15
      LINE (180, 200)-(420, 200), 15
      LINE (270, 270)-(330, 360), 15, B
      LINE (220, 230)-(260, 270), 15, B
      LINE (340, 230)-(380, 270), 15, B
      CIRCLE (540, 80), 30, 15
      LINE (0, 360)-(639, 360), 15
    CASE 2
      ' fish
      CIRCLE (300, 200), 120, 15, , , .5
      LINE (418, 200)-(500, 140), 15
      LINE (500, 140)-(500, 260), 15
      LINE (500, 260)-(418, 200), 15
      CIRCLE (230, 180), 8, 15
      LINE (280, 142)-(320, 110), 15
      LINE (320, 110)-(340, 146), 15
      CIRCLE (120, 120), 12, 15
      CIRCLE (95, 90), 8, 15
      CIRCLE (140, 70), 5, 15
    CASE 3
      ' tree
      LINE (280, 250)-(330, 380), 15, B
      CIRCLE (305, 190), 70, 15
      CIRCLE (245, 235), 50, 15
      CIRCLE (365, 235), 50, 15
      LINE (0, 380)-(639, 380), 15
      CIRCLE (520, 90), 25, 15
      CIRCLE (100, 80), 20, 15
      CIRCLE (130, 75), 25, 15
      CIRCLE (160, 82), 18, 15
  END SELECT
END SUB

SUB Title
  CLS
  COLOR 14: LOCATE 3, 25: PRINT "G30  COMPUTER DRAWING  (DIAN NAO HUI TU)"
  COLOR 15
  LOCATE 6, 8: PRINT "A computer picture is made of tiny dots (pixels). Each dot has a position"
  LOCATE 7, 8: PRINT "(x, y) and a colour. A line needs two points; a circle needs a centre"
  LOCATE 8, 8: PRINT "and a radius. Colouring is filling a closed region with one colour."
  COLOR 7
  LOCATE 10, 8: PRINT "Draw your own picture, or press T to get an outline to colour in."
  COLOR 10
  LOCATE 12, 8: PRINT "Arrows .......... move the cursor"
  LOCATE 13, 8: PRINT "1 Pen 2 Line 3 Box 4 Circle 5 Fill .... choose a tool"
  LOCATE 14, 8: PRINT "Space ........... use the tool (line/box/circle: start, move, end)"
  LOCATE 15, 8: PRINT ". and , ........ next / previous colour"
  LOCATE 16, 8: PRINT "S step size   U undo   T outline picture   N clear   ESC menu"
  COLOR 15
  LOCATE 20, 8: PRINT "Press any key to start";
  junk$ = GetKey$
END SUB
