' G25.BAS - Opposites Attract (YI XING XIANG XI)
' Educational content (1991 list): charged objects at rest and in motion; like charges
'   repel, opposite charges attract (Coulomb force, F = k q1 q2 / r^2).
' Controls: arrows move cursor, + / - place a positive / negative charge, U undo, R reset,
'   P preview on/off, ENTER releases the moving charge, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Title ()
DECLARE SUB LoadLevel (n%)
DECLARE SUB DrawCharge (x%, y%, s%)
DECLARE SUB DrawField (pv%)
DECLARE SUB Simulate (an%)
DECLARE SUB AddCharge (s%)
DECLARE SUB Pr (r%, t$)
DECLARE SUB Msg (t$)
DECLARE SUB PlayLevel ()
DECLARE SUB Finale ()
DECLARE FUNCTION ResText$ (r%)

' Fixed charges (at rest): qx!, qy!, qs% (+1 or -1).  The first nf% entries belong to the level.
' The moving test charge is positive, so it is repelled by + and attracted by -.
DIM SHARED qx!(1 TO 8), qy!(1 TO 8), qs%(1 TO 8)
DIM SHARED ls!(1 TO 4, 1 TO 6), lm%(1 TO 4), lnf%(1 TO 4)
DIM SHARED lfx%(1 TO 4, 1 TO 2), lfy%(1 TO 4, 1 TO 2), lfs%(1 TO 4, 1 TO 2)
DIM SHARED sx!, sy!, svx!, svy!, tx!, ty!
DIM SHARED nq%, nf%, maxq%, res%, lvl%, att%, tot%, quit%, prev%
DIM SHARED cxp%, cyp%, pres%

RANDOMIZE TIMER
FOR n% = 1 TO 4
  FOR k% = 1 TO 6
    READ ls!(n%, k%)
  NEXT k%
  READ lm%(n%), lnf%(n%)
  FOR f% = 1 TO lnf%(n%)
    READ lfx%(n%, f%), lfy%(n%, f%), lfs%(n%, f%)
  NEXT f%
NEXT n%
' per level: start x,y, start vx,vy, target x,y, charges allowed, fixed count, fixed x,y,sign
DATA 40,300, 1.6,0, 410,100, 2, 0
DATA 40,200, 1.6,0, 410,200, 3, 1, 230,200,1
DATA 40,80, 1.6,.4, 410,300, 3, 1, 240,200,-1
DATA 230,330, 0,-1.6, 70,70, 3, 1, 230,170,1

SCREEN 12
tot% = 0
quit% = 0
prev% = 1
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
FOR lvl% = 1 TO 4
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

' Place one more charge of sign s at the cursor if the spot is legal.
SUB AddCharge (s%)
  IF nq% >= nf% + maxq% OR nq% >= 8 THEN
    CALL Msg("No charges left. Press U to take the last one back.")
    EXIT SUB
  END IF
  IF ABS(cxp% - sx!) < 20 AND ABS(cyp% - sy!) < 20 THEN
    CALL Msg("Too close to the moving charge's starting point.")
    EXIT SUB
  END IF
  IF ABS(cxp% - tx!) < 26 AND ABS(cyp% - ty!) < 26 THEN
    CALL Msg("Too close to the target.")
    EXIT SUB
  END IF
  FOR i% = 1 TO nq%
    IF ABS(cxp% - qx!(i%)) < 16 AND ABS(cyp% - qy!(i%)) < 16 THEN
      CALL Msg("Another charge is already there.")
      EXIT SUB
    END IF
  NEXT i%
  nq% = nq% + 1
  qx!(nq%) = cxp%
  qy!(nq%) = cyp%
  qs%(nq%) = s%
  IF s% > 0 THEN
    CALL Msg("Positive charge placed: it REPELS the moving (+) charge.")
  ELSE
    CALL Msg("Negative charge placed: it ATTRACTS the moving (+) charge.")
  END IF
END SUB

SUB DrawCharge (x%, y%, s%)
  IF s% > 0 THEN c% = 12 ELSE c% = 9
  CIRCLE (x%, y%), 8, c%
  LINE (x% - 5, y%)-(x% + 5, y%), c%
  IF s% > 0 THEN LINE (x%, y% - 5)-(x%, y% + 5), c%
END SUB

SUB DrawField (pv%)
  LINE (16, 40)-(455, 359), 0, BF
  LINE (15, 39)-(456, 360), 7, B
  FOR i% = 1 TO nq%
    CALL DrawCharge(INT(qx!(i%)), INT(qy!(i%)), qs%(i%))
  NEXT i%
  CIRCLE (tx!, ty!), 16, 10
  CIRCLE (tx!, ty!), 8, 10
  CIRCLE (tx!, ty!), 2, 10
  CIRCLE (sx!, sy!), 4, 14
  LINE (sx!, sy!)-(sx! + svx! * 12, sy! + svy! * 12), 10
  pres% = 0
  IF pv% <> 0 THEN CALL Simulate(0)
  LINE (cxp% - 4, cyp% - 4)-(cxp% + 4, cyp% + 4), 15, B
  COLOR 14
  CALL Pr(3, "LEVEL" + STR$(lvl%) + " of 4")
  COLOR 10
  CALL Pr(4, "Try" + STR$(att% + 1) + " of 3")
  CALL Pr(5, "Charges left:" + STR$(nf% + maxq% - nq%))
  CALL Pr(6, "Score:" + STR$(tot%))
  COLOR 8
  IF pv% <> 0 THEN
    SELECT CASE pres%
      CASE 1
        CALL Pr(8, "Preview: HIT")
      CASE 2
        CALL Pr(8, "Preview: leaves")
      CASE 3
        CALL Pr(8, "Preview: crash")
      CASE ELSE
        CALL Pr(8, "Preview: too slow")
    END SELECT
  ELSE
    CALL Pr(8, "")
  END IF
  COLOR 7
  CALL Pr(10, "Yellow ring = moving")
  CALL Pr(11, "  charge (+), green")
  CALL Pr(12, "  line = its start")
  CALL Pr(13, "Green rings = goal")
  CALL Pr(14, "Red + = positive")
  CALL Pr(15, "Blue - = negative")
  CALL Pr(16, "Grey dots = preview")
  CALL Pr(17, "Pink = force arrow")
  COLOR 15
  CALL Pr(19, "Like charges REPEL")
  CALL Pr(20, "Opposites ATTRACT")
  COLOR 7
  CALL Pr(21, "F = k q1 q2 / r^2")
  CALL Pr(22, "Near = strong force")
  CALL Pr(23, "Far = weak force")
END SUB

SUB Finale
  CLS
  COLOR 14
  LOCATE 6, 20: PRINT "ALL FOUR LEVELS DONE!"
  COLOR 15
  LOCATE 9, 20: PRINT "Final score:"; tot%
  COLOR 7
  LOCATE 12, 10: PRINT "Fixed charges stay at rest; the free charge speeds up toward unlike"
  LOCATE 13, 10: PRINT "charges and is pushed away from like charges. Closer = stronger force."
  COLOR 10
  LOCATE 16, 10: PRINT "Press any key to return to the menu..."
  k$ = GetKey$
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB LoadLevel (n%)
  IF n% < 1 OR n% > 4 THEN EXIT SUB
  sx! = ls!(n%, 1)
  sy! = ls!(n%, 2)
  svx! = ls!(n%, 3)
  svy! = ls!(n%, 4)
  tx! = ls!(n%, 5)
  ty! = ls!(n%, 6)
  maxq% = lm%(n%)
  nf% = lnf%(n%)
  IF nf% > 2 THEN nf% = 2
  nq% = nf%
  FOR f% = 1 TO nf%
    qx!(f%) = lfx%(n%, f%)
    qy!(f%) = lfy%(n%, f%)
    qs%(f%) = lfs%(n%, f%)
  NEXT f%
END SUB

SUB Msg (t$)
  LOCATE 27, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

SUB PlayLevel
  CALL LoadLevel(lvl%)
  cxp% = 232
  cyp% = 200
  att% = 0
  CLS
  COLOR 15
  LOCATE 1, 1: PRINT "G25 Opposites Attract (YI XING XIANG XI)";
  COLOR 7
  LOCATE 30, 1: PRINT "Arrows move  + - add charge  U undo  R reset  P preview  ENTER go  ESC=menu";
  CALL Msg("Steer the moving charge onto the green target with + and - charges.")
  DO
    CALL DrawField(prev%)
    k$ = GetKey$
    IF k$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    ELSEIF LEN(k$) = 2 THEN
      SELECT CASE RIGHT$(k$, 1)
        CASE "H"
          IF cyp% > 48 THEN cyp% = cyp% - 8
        CASE "P"
          IF cyp% < 352 THEN cyp% = cyp% + 8
        CASE "K"
          IF cxp% > 24 THEN cxp% = cxp% - 8
        CASE "M"
          IF cxp% < 448 THEN cxp% = cxp% + 8
      END SELECT
    ELSEIF k$ = "+" OR k$ = "=" THEN
      CALL AddCharge(1)
    ELSEIF k$ = "-" OR k$ = "_" THEN
      CALL AddCharge(-1)
    ELSEIF k$ = "u" OR k$ = "U" THEN
      IF nq% > nf% THEN nq% = nq% - 1
    ELSEIF k$ = "r" OR k$ = "R" THEN
      nq% = nf%
    ELSEIF k$ = "p" OR k$ = "P" THEN
      prev% = 1 - prev%
    ELSEIF k$ = CHR$(13) THEN
      att% = att% + 1
      CALL DrawField(0)
      CALL Msg("Released! The moving charge feels the force of every fixed charge.")
      CALL Simulate(1)
      IF res% = 1 THEN
        pts% = 100 - 25 * (att% - 1) + 10 * (nf% + maxq% - nq%)
        tot% = tot% + pts%
        CALL Msg("TARGET REACHED! +" + LTRIM$(STR$(pts%)) + " points.")
        LOCATE 28, 1: PRINT "Press any key for the next level, ESC = menu";
        k$ = GetKey$
        IF k$ = CHR$(27) THEN quit% = 1
        EXIT SUB
      END IF
      CALL Msg(ResText$(res%))
      IF att% >= 3 THEN
        LOCATE 28, 1: PRINT "Out of tries - next level. Press any key, ESC = menu";
        k$ = GetKey$
        IF k$ = CHR$(27) THEN quit% = 1
        EXIT SUB
      END IF
      LOCATE 28, 1: PRINT "Press any key to adjust the charges and try again";
      k$ = GetKey$
      IF k$ = CHR$(27) THEN
        quit% = 1
        EXIT SUB
      END IF
      LOCATE 28, 1: PRINT SPACE$(60);
    END IF
  LOOP
END SUB

SUB Pr (r%, t$)
  IF r% < 1 OR r% > 30 THEN EXIT SUB
  LOCATE r%, 59
  PRINT LEFT$(t$ + SPACE$(20), 20);
END SUB

FUNCTION ResText$ (r%)
  SELECT CASE r%
    CASE 1
      ResText$ = "HIT"
    CASE 2
      ResText$ = "MISS: the charge flew out of the field. Adjust the charges."
    CASE 3
      ResText$ = "MISS: it crashed into a charge. Keep a little distance."
    CASE ELSE
      ResText$ = "MISS: time ran out before it reached the target."
  END SELECT
END FUNCTION

' Move the positive test charge under Coulomb forces (acceleration = sum of k q / r^2, softened
' with +400 so a close pass can never divide by zero).  an% = 0: silent preview dots;
' an% = 1: animated flight with a force arrow every few steps.  Sets res% (and pres% for preview).
SUB Simulate (an%)
  x! = sx!
  y! = sy!
  vx! = svx!
  vy! = svy!
  r% = 4
  FOR n% = 1 TO 700
    ax! = 0
    ay! = 0
    FOR i% = 1 TO nq%
      dx! = x! - qx!(i%)
      dy! = y! - qy!(i%)
      rr! = SQR(dx! * dx! + dy! * dy! + 400)
      f! = qs%(i%) * 6000 / (rr! * rr! * rr!)
      ax! = ax! + f! * dx!
      ay! = ay! + f! * dy!
    NEXT i%
    vx! = vx! + ax!
    vy! = vy! + ay!
    v! = SQR(vx! * vx! + vy! * vy!)
    IF v! > 8 THEN
      vx! = vx! * 8 / v!
      vy! = vy! * 8 / v!
    END IF
    x! = x! + vx!
    y! = y! + vy!
    IF x! < 16 OR x! > 455 OR y! < 40 OR y! > 359 THEN
      r% = 2
      EXIT FOR
    END IF
    IF an% = 0 THEN
      IF n% MOD 4 = 0 THEN PSET (x!, y!), 8
    ELSE
      CIRCLE (x!, y!), 2, 14
      IF n% MOD 12 = 0 THEN
        am! = SQR(ax! * ax! + ay! * ay!)
        IF am! > .0005 THEN
          ln! = am! * 150
          IF ln! > 40 THEN ln! = 40
          ex! = x! + ax! / am! * ln!
          ey! = y! + ay! / am! * ln!
          IF ex! > 455 THEN ex! = 455
          IF ex! < 16 THEN ex! = 16
          IF ey! > 359 THEN ey! = 359
          IF ey! < 40 THEN ey! = 40
          LINE (x!, y!)-(ex!, ey!), 13
        END IF
      END IF
      CALL Delay(.012)
    END IF
    IF (x! - tx!) * (x! - tx!) + (y! - ty!) * (y! - ty!) < 576 THEN
      r% = 1
      EXIT FOR
    END IF
    FOR i% = 1 TO nq%
      dx! = x! - qx!(i%)
      dy! = y! - qy!(i%)
      IF dx! * dx! + dy! * dy! < 100 THEN r% = 3
    NEXT i%
    IF r% = 3 THEN EXIT FOR
  NEXT n%
  IF an% = 0 THEN pres% = r% ELSE res% = r%
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 18: PRINT "G25  OPPOSITES ATTRACT  (YI XING XIANG XI)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "ELECTRIC CHARGES at rest and in motion. Like charges repel, opposite"
  LOCATE 8, 6: PRINT "charges attract, and the force falls off with distance (F = k q1 q2 / r^2)."
  COLOR 7
  LOCATE 11, 6: PRINT "How to play:"
  LOCATE 12, 6: PRINT "A small POSITIVE charge (yellow ring) is released with a push to the right"
  LOCATE 13, 6: PRINT "or upward. Fixed charges stay at rest and pull or push it along its way."
  LOCATE 14, 6: PRINT "Move the cursor with the arrow keys; + places a red positive charge (repels"
  LOCATE 15, 6: PRINT "the mover), - places a blue negative one (attracts it)."
  LOCATE 16, 6: PRINT "Grey dots preview the path (P turns that off). U undo, R reset."
  LOCATE 17, 6: PRINT "ENTER releases the charge; pink arrows show the force on it. ESC = menu."
  COLOR 10
  LOCATE 19, 6: PRINT "4 levels, 3 tries each. Score = 100, minus 25 per extra try, plus 10 for"
  LOCATE 20, 6: PRINT "every charge you did not need."
  COLOR 14
  LOCATE 23, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB
