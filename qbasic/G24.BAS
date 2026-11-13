' G24.BAS - Laser Maze (LEI SHE MI GONG)
' Educational content (1991 list): a laser gun and mirrors; the LAW OF REFLECTION
'   (angle of incidence = angle of reflection).
' Controls: arrows move cursor, / or \ place a mirror, X removes it, ENTER fires,
'   R clears all mirrors, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Title ()
DECLARE SUB LoadLevel (n%)
DECLARE SUB DrawCell (x%, y%)
DECLARE SUB DrawBoard ()
DECLARE SUB Trace (dr%)
DECLARE SUB Half (x%, y%, d%)
DECLARE SUB BeamSeg (x1%, y1%, x2%, y2%)
DECLARE SUB Pr (r%, t$)
DECLARE SUB Msg (t$)
DECLARE SUB PlayLevel ()
DECLARE SUB Finale ()

' g%: 0 empty, 1 wall, 2 mirror "/", 3 mirror "\", 4 target, 5 laser gun
' directions d%: 0 right, 1 up, 2 left, 3 down
DIM SHARED g%(1 TO 14, 1 TO 10)
DIM SHARED ddx%(0 TO 3), ddy%(0 TO 3)
DIM SHARED lh%(1 TO 5, 1 TO 7), lwx%(1 TO 5, 1 TO 6), lwy%(1 TO 5, 1 TO 6)
DIM SHARED gx%, gy%, gd%, tx%, ty%, maxm%, mleft%, bounces%, hit%
DIM SHARED cx%, cy%, lvl%, shots%, tot%, quit%

RANDOMIZE TIMER
FOR i% = 0 TO 3
  READ ddx%(i%), ddy%(i%)
NEXT i%
FOR n% = 1 TO 5
  FOR k% = 1 TO 7
    READ lh%(n%, k%)
  NEXT k%
  FOR w% = 1 TO lh%(n%, 7)
    READ lwx%(n%, w%), lwy%(n%, w%)
  NEXT w%
NEXT n%
' right, up, left, down as (dx,dy) on the screen grid (y grows downward)
DATA 1,0, 0,-1, -1,0, 0,1
' per level: gun x,y,dir, target x,y, mirrors allowed, wall count, then wall x,y pairs
DATA 1,5,0, 10,2, 2, 2, 5,2, 6,8
DATA 1,2,0, 12,9, 3, 3, 3,5, 8,5, 9,7
DATA 14,10,2, 3,2, 4, 4, 8,10, 7,3, 6,8, 13,4
DATA 1,10,1, 14,1, 3, 3, 1,5, 9,7, 3,3
DATA 7,10,1, 11,5, 5, 4, 7,6, 5,5, 8,4, 13,8

SCREEN 12
tot% = 0
quit% = 0
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
FOR lvl% = 1 TO 5
  CALL PlayLevel
  IF quit% <> 0 THEN EXIT FOR
NEXT lvl%
IF quit% = 0 THEN CALL Finale

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

' Draw one grid square with whatever it holds.
SUB DrawCell (x%, y%)
  IF x% < 1 OR x% > 14 OR y% < 1 OR y% > 10 THEN EXIT SUB
  px% = 16 + (x% - 1) * 32
  py% = 40 + (y% - 1) * 32
  LINE (px%, py%)-(px% + 31, py% + 31), 0, BF
  LINE (px%, py%)-(px% + 31, py% + 31), 1, B
  SELECT CASE g%(x%, y%)
    CASE 1
      LINE (px% + 2, py% + 2)-(px% + 29, py% + 29), 8, BF
      LINE (px% + 2, py% + 2)-(px% + 29, py% + 29), 7, B
    CASE 2
      LINE (px% + 6, py% + 26)-(px% + 26, py% + 6), 11
      LINE (px% + 7, py% + 26)-(px% + 27, py% + 6), 11
      LINE (px% + 5, py% + 26)-(px% + 25, py% + 6), 15
    CASE 3
      LINE (px% + 6, py% + 6)-(px% + 26, py% + 26), 11
      LINE (px% + 5, py% + 6)-(px% + 25, py% + 26), 11
      LINE (px% + 7, py% + 6)-(px% + 27, py% + 26), 15
    CASE 4
      CIRCLE (px% + 16, py% + 16), 12, 14
      CIRCLE (px% + 16, py% + 16), 6, 12
    CASE 5
      LINE (px% + 4, py% + 4)-(px% + 27, py% + 27), 9, BF
      mx% = px% + 16 + 14 * ddx%(gd%)
      my% = py% + 16 + 14 * ddy%(gd%)
      LINE (px% + 16, py% + 16)-(mx%, my%), 15
      LINE (px% + 17, py% + 16)-(mx% + 1, my%), 15
  END SELECT
END SUB

' Draw a short piece of beam from the centre of (x,y) to the edge of that square in direction d.
SUB Half (x%, y%, d%)
  px% = 16 + (x% - 1) * 32 + 16
  py% = 40 + (y% - 1) * 32 + 16
  LINE (px%, py%)-(px% + 16 * ddx%(d%), py% + 16 * ddy%(d%)), 12
END SUB

' Draw beam from centre of one square to centre of the next.
SUB BeamSeg (x1%, y1%, x2%, y2%)
  ax% = 16 + (x1% - 1) * 32 + 16
  ay% = 40 + (y1% - 1) * 32 + 16
  bx% = 16 + (x2% - 1) * 32 + 16
  by% = 40 + (y2% - 1) * 32 + 16
  LINE (ax%, ay%)-(bx%, by%), 12
  LINE (ax% + 1, ay% + 1)-(bx% + 1, by% + 1), 12
END SUB

' Follow the beam from the gun square by square.  A "/" mirror swaps right<->up and left<->down,
' a "\" mirror swaps right<->down and left<->up: the beam leaves at the same angle it arrived.
' dr% <> 0 also draws the path.  Sets hit% and bounces%.
SUB Trace (dr%)
  x% = gx%
  y% = gy%
  d% = gd%
  hit% = 0
  bounces% = 0
  n% = 0
  DO
    nx% = x% + ddx%(d%)
    ny% = y% + ddy%(d%)
    IF nx% < 1 OR nx% > 14 OR ny% < 1 OR ny% > 10 THEN
      IF dr% <> 0 THEN CALL Half(x%, y%, d%)
      EXIT DO
    END IF
    c% = g%(nx%, ny%)
    IF c% = 1 OR c% = 5 THEN
      IF dr% <> 0 THEN CALL Half(x%, y%, d%)
      EXIT DO
    END IF
    IF dr% <> 0 THEN CALL BeamSeg(x%, y%, nx%, ny%)
    IF c% = 4 THEN
      hit% = 1
      EXIT DO
    END IF
    IF c% = 2 THEN
      IF d% MOD 2 = 0 THEN d% = d% + 1 ELSE d% = d% - 1
      bounces% = bounces% + 1
    ELSEIF c% = 3 THEN
      d% = 3 - d%
      bounces% = bounces% + 1
    END IF
    x% = nx%
    y% = ny%
    n% = n% + 1
    IF n% > 300 THEN EXIT DO
  LOOP
END SUB

SUB Pr (r%, t$)
  IF r% < 1 OR r% > 30 THEN EXIT SUB
  LOCATE r%, 61
  PRINT LEFT$(t$ + SPACE$(19), 19);
END SUB

SUB Msg (t$)
  LOCATE 27, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

SUB DrawBoard
  FOR x% = 1 TO 14
    FOR y% = 1 TO 10
      CALL DrawCell(x%, y%)
    NEXT y%
  NEXT x%
  CALL Trace(1)
  px% = 16 + (cx% - 1) * 32
  py% = 40 + (cy% - 1) * 32
  LINE (px% + 1, py% + 1)-(px% + 30, py% + 30), 15, B
  COLOR 14
  CALL Pr(3, "LEVEL" + STR$(lvl%) + " of 5")
  COLOR 10
  CALL Pr(5, "Mirrors left:" + STR$(mleft%))
  CALL Pr(6, "Shots fired:" + STR$(shots%))
  CALL Pr(7, "Score:" + STR$(tot%))
  COLOR 12
  CALL Pr(9, "Bounces:" + STR$(bounces%))
  COLOR 7
  CALL Pr(11, "Law of reflection:")
  CALL Pr(12, "angle in = angle")
  CALL Pr(13, "out. Each mirror")
  CALL Pr(14, "sits at 45 deg, so")
  CALL Pr(15, "the beam turns a")
  CALL Pr(16, "right angle (90).")
  CALL Pr(18, "Blue box = gun")
  CALL Pr(19, "Gold ring = target")
  CALL Pr(20, "Grey = wall")
  CALL Pr(21, "Red line = laser")
END SUB

SUB LoadLevel (n%)
  FOR x% = 1 TO 14
    FOR y% = 1 TO 10
      g%(x%, y%) = 0
    NEXT y%
  NEXT x%
  IF n% < 1 OR n% > 5 THEN EXIT SUB
  gx% = lh%(n%, 1)
  gy% = lh%(n%, 2)
  gd% = lh%(n%, 3)
  tx% = lh%(n%, 4)
  ty% = lh%(n%, 5)
  maxm% = lh%(n%, 6)
  FOR w% = 1 TO lh%(n%, 7)
    wx% = lwx%(n%, w%)
    wy% = lwy%(n%, w%)
    IF wx% >= 1 AND wx% <= 14 AND wy% >= 1 AND wy% <= 10 THEN g%(wx%, wy%) = 1
  NEXT w%
  g%(tx%, ty%) = 4
  g%(gx%, gy%) = 5
  mleft% = maxm%
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB PlayLevel
  CALL LoadLevel(lvl%)
  cx% = 4
  cy% = 5
  IF g%(cx%, cy%) <> 0 THEN cx% = 3
  shots% = 0
  CLS
  COLOR 15
  LOCATE 1, 1: PRINT "G24 Laser Maze (LEI SHE MI GONG)";
  COLOR 7
  LOCATE 30, 1: PRINT "Arrows move  / \ place  X remove  ENTER fire  R clear  ESC = menu";
  CALL DrawBoard
  CALL Msg("Guide the laser onto the target with mirrors. Place / or \ then press ENTER.")
  DO
    k$ = GetKey$
    redraw% = 0
    IF k$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    ELSEIF LEN(k$) = 2 THEN
      redraw% = 1
      SELECT CASE RIGHT$(k$, 1)
        CASE "H"
          IF cy% > 1 THEN cy% = cy% - 1
        CASE "P"
          IF cy% < 10 THEN cy% = cy% + 1
        CASE "K"
          IF cx% > 1 THEN cx% = cx% - 1
        CASE "M"
          IF cx% < 14 THEN cx% = cx% + 1
        CASE ELSE
          redraw% = 0
      END SELECT
    ELSEIF k$ = "/" OR k$ = "\" THEN
      IF g%(cx%, cy%) = 0 AND mleft% > 0 THEN
        IF k$ = "/" THEN g%(cx%, cy%) = 2 ELSE g%(cx%, cy%) = 3
        mleft% = mleft% - 1
        CALL Msg("Mirror placed. The red line shows where the beam goes now.")
      ELSEIF g%(cx%, cy%) = 0 THEN
        CALL Msg("No mirrors left. Remove one with X first.")
      ELSE
        CALL Msg("That square is not empty.")
      END IF
      redraw% = 1
    ELSEIF k$ = "x" OR k$ = "X" OR k$ = " " THEN
      IF g%(cx%, cy%) = 2 OR g%(cx%, cy%) = 3 THEN
        g%(cx%, cy%) = 0
        mleft% = mleft% + 1
        CALL Msg("Mirror removed.")
      END IF
      redraw% = 1
    ELSEIF k$ = "r" OR k$ = "R" THEN
      FOR x% = 1 TO 14
        FOR y% = 1 TO 10
          IF g%(x%, y%) = 2 OR g%(x%, y%) = 3 THEN g%(x%, y%) = 0
        NEXT y%
      NEXT x%
      mleft% = maxm%
      CALL Msg("All mirrors cleared.")
      redraw% = 1
    ELSEIF k$ = CHR$(13) THEN
      shots% = shots% + 1
      CALL Trace(0)
      IF hit% <> 0 THEN
        pts% = 100 - 10 * (shots% - 1)
        IF pts% < 30 THEN pts% = 30
        pts% = pts% + 10 * mleft%
        tot% = tot% + pts%
        CALL DrawBoard
        CALL Delay(.3)
        m$ = "TARGET HIT after" + STR$(bounces%) + " reflections! +"
        CALL Msg(m$ + LTRIM$(STR$(pts%)) + " points.")
        LOCATE 28, 1: PRINT "Press any key for the next level, ESC = menu";
        k$ = GetKey$
        IF k$ = CHR$(27) THEN quit% = 1
        EXIT SUB
      ELSE
        CALL Msg("Missed: the beam never reached the target. Move a mirror and fire again.")
        redraw% = 1
      END IF
    END IF
    IF redraw% <> 0 THEN CALL DrawBoard
  LOOP
END SUB

SUB Finale
  CLS
  COLOR 14
  LOCATE 6, 20: PRINT "ALL FIVE MAZES SOLVED!"
  COLOR 15
  LOCATE 9, 20: PRINT "Final score:"; tot%
  COLOR 7
  LOCATE 12, 12: PRINT "Remember: a mirror sends the beam away at the same angle it came in."
  LOCATE 13, 12: PRINT "(angle of incidence = angle of reflection)"
  COLOR 10
  LOCATE 16, 12: PRINT "Press any key to return to the menu..."
  k$ = GetKey$
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 20: PRINT "G24  LASER MAZE  (LEI SHE MI GONG)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "A LASER GUN and MIRROR REFLECTION. Light bounces off a mirror so that the"
  LOCATE 8, 6: PRINT "angle of incidence equals the angle of reflection (the law of reflection)."
  COLOR 7
  LOCATE 11, 6: PRINT "How to play:"
  LOCATE 12, 6: PRINT "A laser gun (blue) shoots along its arrow. Grey blocks stop the beam."
  LOCATE 13, 6: PRINT "Put limited mirrors on the grid so the beam reaches the gold target."
  LOCATE 14, 6: PRINT "A / mirror turns right->up, up->right, left->down, down->left."
  LOCATE 15, 6: PRINT "A \ mirror turns right->down, down->right, left->up, up->left."
  LOCATE 16, 6: PRINT "Arrow keys move the cursor; / or \ places a mirror; X removes it."
  LOCATE 17, 6: PRINT "The red line is drawn live. ENTER fires for real. R clears. ESC = menu."
  COLOR 10
  LOCATE 19, 6: PRINT "Five levels. Level score = 100, minus 10 per extra shot, plus 10 per mirror"
  LOCATE 20, 6: PRINT "you did not need."
  COLOR 14
  LOCATE 23, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB
