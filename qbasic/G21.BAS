' G21.BAS - Seesaw (QIAO QIAO BAN)
' Educational content (1991 list): the lever principle - a beam balances when
'   (weight x distance) on the left equals (weight x distance) on the right.
' Controls: Left/Right move cursor, Space chooses weight, Enter places it,
'   U picks one up, R clears the beam, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (r%, c%, mx%)
DECLARE SUB Title ()
DECLARE SUB Msg (t$)
DECLARE SUB NewLevel ()
DECLARE FUNCTION Solvable% ()
DECLARE FUNCTION NetTorque% ()
DECLARE FUNCTION Formula$ (side%)
DECLARE SUB DrawScene (a!)
DECLARE SUB Refresh ()
DECLARE SUB HandLine ()
DECLARE SUB NextSel ()
DECLARE SUB PlayLevel ()
DECLARE SUB AskMass ()
DECLARE SUB Summary ()

' Item 1 is the fixed weight on the left (pk 1) or the mystery mass (pk 2).
' Items 2..n are the weights in your hand (pk 0); pp = beam position, 0 = not placed.
DIM SHARED pw%(1 TO 6), pp%(1 TO 6), pk%(1 TO 6), stk%(-5 TO 5)
DIM SHARED n%, h%, lv%, sel%, cp%, moves%, tot%, quit%
DIM SHARED ca!
RANDOMIZE TIMER
SCREEN 12
quit% = 0
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
DO
  tot% = 0
  FOR lv% = 1 TO 6
    CALL NewLevel
    CALL PlayLevel
    IF quit% <> 0 THEN EXIT FOR
  NEXT lv%
  IF quit% <> 0 THEN EXIT DO
  CALL Summary
  IF quit% <> 0 THEN EXIT DO
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

' Ask for the mystery mass after the beam balances (string + VAL, two tries).
SUB AskMass
  ok% = 0
  FOR t% = 1 TO 2
    IF ok% = 0 AND quit% = 0 THEN
      CALL Msg("Balanced! Torques are equal. What is the mystery mass? (type a number)")
      COLOR 7
      LOCATE 29, 1: PRINT "Mass = ";
      a$ = ReadLine$(29, 8, 8)
      LOCATE 29, 1: PRINT SPACE$(40);
      IF a$ = CHR$(27) THEN
        quit% = 1
      ELSEIF a$ <> "" AND ABS(VAL(a$) - pw%(1)) < .01 THEN
        ok% = 1
        tot% = tot% + 80 \ t%
      ELSE
        CALL Msg("Not quite. Mystery torque = known torque on the other side. Divide by distance.")
        CALL Delay(1.5)
      END IF
    END IF
  NEXT t%
  IF quit% = 0 THEN
    pk%(1) = 1
    CALL Refresh
    IF ok% <> 0 THEN
      CALL Msg("Correct! The mystery mass was" + STR$(pw%(1)) + ".  Bonus added.")
    ELSE
      CALL Msg("The mystery mass was" + STR$(pw%(1)) + ": its torque equals the other side.")
    END IF
  END IF
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

SUB DrawScene (a!)
  LINE (0, 112)-(639, 415), 0, BF
  FOR p% = -5 TO 5
    stk%(p%) = 0
  NEXT p%
  c! = COS(a!)
  s! = SIN(a!)
  LINE (100, 380)-(540, 380), 8
  LINE (320, 300)-(290, 380), 7
  LINE (320, 300)-(350, 380), 7
  x1% = 320 - 220 * c!
  y1% = 300 - 220 * s!
  x2% = 320 + 220 * c!
  y2% = 300 + 220 * s!
  LINE (x1%, y1% + 1)-(x2%, y2% + 1), 6
  LINE (x1%, y1%)-(x2%, y2%), 6
  LINE (x1%, y1% - 1)-(x2%, y2% - 1), 14
  COLOR 7
  FOR p% = -5 TO 5
    LINE (320 + p% * 40, 384)-(320 + p% * 40, 389), 7
    LOCATE 25, 40 + 5 * p%
    PRINT RIGHT$("  " + LTRIM$(STR$(p%)), 2);
  NEXT p%
  FOR i% = 1 TO n%
    p% = pp%(i%)
    IF p% >= -5 AND p% <= 5 AND p% <> 0 THEN
      bx% = 320 + p% * 40 * c!
      by% = 300 + p% * 40 * s!
      hh% = 14 + 3 * pw%(i%)
      yb% = by% - 3 - stk%(p%)
      yt% = yb% - hh%
      IF yt% < 114 THEN yt% = 114
      IF yt% > yb% - 4 THEN yt% = yb% - 4
      stk%(p%) = stk%(p%) + hh% + 1
      cl% = 9 + (pw%(i%) MOD 6)
      IF pk%(i%) = 1 THEN cl% = 12
      IF pk%(i%) = 2 THEN cl% = 13
      LINE (bx% - 12, yt%)-(bx% + 12, yb%), cl%, BF
      LINE (bx% - 12, yt%)-(bx% + 12, yb%), 15, B
      rw% = ((yt% + yb%) \ 2) \ 16 + 1
      cw% = (bx% - 4) \ 8 + 1
      IF rw% < 1 THEN rw% = 1
      IF rw% > 30 THEN rw% = 30
      IF cw% < 1 THEN cw% = 1
      IF cw% > 79 THEN cw% = 79
      COLOR 15
      LOCATE rw%, cw%
      IF pk%(i%) = 2 THEN PRINT "?"; ELSE PRINT LTRIM$(STR$(pw%(i%)));
    END IF
  NEXT i%
  COLOR 14
  LOCATE 26, 41 + 5 * cp%
  PRINT "^";
  COLOR 7
END SUB

' Text of the torque sum for one side of the beam (side -1 left, +1 right).
FUNCTION Formula$ (side%)
  t$ = ""
  sm% = 0
  hm% = 0
  FOR i% = 1 TO n%
    IF pp%(i%) <> 0 THEN
      IF SGN(pp%(i%)) = side% THEN
        d$ = LTRIM$(STR$(ABS(pp%(i%))))
        IF pk%(i%) = 2 THEN
          w$ = "?"
          hm% = 1
        ELSE
          w$ = LTRIM$(STR$(pw%(i%)))
          sm% = sm% + pw%(i%) * ABS(pp%(i%))
        END IF
        IF t$ <> "" THEN t$ = t$ + " + "
        t$ = t$ + w$ + "x" + d$
      END IF
    END IF
  NEXT i%
  IF t$ = "" THEN t$ = "(nothing)"
  IF hm% <> 0 THEN
    t$ = t$ + "   (known part =" + STR$(sm%) + ")"
  ELSE
    t$ = t$ + "  =" + STR$(sm%)
  END IF
  Formula$ = t$
END FUNCTION

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB HandLine
  LOCATE 27, 1
  PRINT SPACE$(79);
  LOCATE 27, 1
  COLOR 7
  PRINT "Hand: ";
  cnt% = 0
  FOR i% = 2 TO n%
    IF pp%(i%) = 0 THEN
      cnt% = cnt% + 1
      IF i% = sel% THEN
        COLOR 14
        PRINT "["; LTRIM$(STR$(pw%(i%))); "] ";
      ELSE
        COLOR 7
        PRINT " "; LTRIM$(STR$(pw%(i%))); "  ";
      END IF
    END IF
  NEXT i%
  COLOR 7
  IF cnt% = 0 THEN PRINT "(all placed)  ";
  PRINT "  Cursor at"; cp%;
END SUB

SUB Msg (t$)
  LOCATE 28, 1
  COLOR 10
  PRINT LEFT$(t$ + SPACE$(79), 79);
  COLOR 7
END SUB

SUB NewLevel
  h% = 2
  IF lv% >= 3 THEN h% = 3
  n% = h% + 1
  mxw% = 6
  t% = 1
  DO
    IF lv% <= 4 THEN
      pk%(1) = 1
      pw%(1) = INT(RND * 6) + 2
      pp%(1) = -(INT(RND * 5) + 1)
      mxw% = 6
    ELSE
      pk%(1) = 2
      pw%(1) = INT(RND * 9) + 1
      pp%(1) = -(INT(RND * 4) + 2)
      mxw% = 9
    END IF
    FOR i% = 2 TO n%
      pk%(i%) = 0
      pw%(i%) = INT(RND * mxw%) + 1
      pp%(i%) = 0
    NEXT i%
    IF Solvable% <> 0 THEN EXIT DO
    t% = t% + 1
  LOOP UNTIL t% > 300
  IF t% > 300 THEN
    pw%(1) = 4
    pp%(1) = -3
    pw%(2) = 3
    pw%(3) = 2
    IF n% >= 4 THEN pw%(4) = 1
  END IF
  sel% = 2
  cp% = 1
  moves% = 0
  ca! = 0
END SUB

FUNCTION NetTorque%
  s% = 0
  FOR i% = 1 TO n%
    s% = s% + pw%(i%) * pp%(i%)
  NEXT i%
  NetTorque% = s%
END FUNCTION

' Move the selection to the next weight still in the hand (0 if none).
SUB NextSel
  b% = sel%
  IF b% < 2 THEN b% = 1
  sel% = 0
  IF n% >= 3 THEN
    FOR j% = 1 TO n% - 1
      i% = ((b% - 2 + j%) MOD (n% - 1)) + 2
      IF pp%(i%) = 0 AND sel% = 0 THEN sel% = i%
    NEXT j%
  ELSEIF pp%(2) = 0 THEN
    sel% = 2
  END IF
END SUB

SUB PlayLevel
  CALL Refresh
  CALL Msg("Place your weights so the beam is level. Space = next weight, Enter = place.")
  bal% = 0
  DO
    k$ = GetKey$
    chg% = 0
    IF k$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    ELSEIF k$ = CHR$(0) + "K" THEN
      cp% = cp% - 1
      IF cp% = 0 THEN cp% = -1
      IF cp% < -5 THEN cp% = -5
      chg% = 1
    ELSEIF k$ = CHR$(0) + "M" THEN
      cp% = cp% + 1
      IF cp% = 0 THEN cp% = 1
      IF cp% > 5 THEN cp% = 5
      chg% = 1
    ELSEIF k$ = " " THEN
      CALL NextSel
      chg% = 1
    ELSEIF k$ = CHR$(13) THEN
      IF sel% >= 2 AND sel% <= n% THEN
        pp%(sel%) = cp%
        moves% = moves% + 1
        CALL NextSel
        chg% = 1
      ELSE
        CALL Msg("No weight in hand. Press U to pick one up, or R to clear the beam.")
      END IF
    ELSEIF k$ = "u" OR k$ = "U" THEN
      fd% = 0
      FOR i% = n% TO 2 STEP -1
        IF pp%(i%) = cp% AND fd% = 0 THEN
          fd% = i%
        END IF
      NEXT i%
      IF fd% > 0 THEN
        pp%(fd%) = 0
        IF sel% = 0 THEN sel% = fd%
        moves% = moves% + 1
        chg% = 1
      ELSE
        CALL Msg("There is no hand weight at that position.")
      END IF
    ELSEIF k$ = "r" OR k$ = "R" THEN
      FOR i% = 2 TO n%
        pp%(i%) = 0
      NEXT i%
      sel% = 2
      moves% = moves% + 1
      chg% = 1
    END IF
    IF chg% <> 0 THEN
      CALL Refresh
      IF NetTorque% = 0 THEN
        bal% = 1
      ELSE
        CALL Msg("Left torque and right torque are not equal yet - the heavier side drops.")
      END IF
    END IF
  LOOP UNTIL bal% <> 0
  sc% = 100 - 10 * (moves% - h%)
  IF sc% < 30 THEN sc% = 30
  tot% = tot% + sc%
  CALL Msg("BALANCED! left torque = right torque.  Level score +" + STR$(sc%))
  CALL Delay(1)
  IF pk%(1) = 2 THEN CALL AskMass
  IF quit% <> 0 THEN EXIT SUB
  CALL Refresh
  COLOR 7
  LOCATE 29, 1
  PRINT "Press any key for the next level (ESC = menu)"; SPACE$(20);
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
  LOCATE 29, 1
  PRINT SPACE$(70);
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

SUB Refresh
  nt% = NetTorque%
  ta! = nt% * .02
  IF ta! > .3 THEN ta! = .3
  IF ta! < -.3 THEN ta! = -.3
  IF ABS(ta! - ca!) > .002 THEN
    FOR i% = 1 TO 5
      ca! = ca! + (ta! - ca!) * .5
      CALL DrawScene(ca!)
      CALL Delay(.03)
    NEXT i%
  END IF
  ca! = ta!
  CALL DrawScene(ca!)
  COLOR 14
  LOCATE 3, 2
  PRINT "Level"; lv%; "of 6    Score"; tot%; "    Moves"; moves%; SPACE$(20);
  COLOR 7
  LOCATE 4, 2
  PRINT "Balanced when LEFT torque = RIGHT torque  (torque = weight x distance)";
  COLOR 11
  LOCATE 5, 2
  PRINT LEFT$("Left : " + Formula$(-1) + SPACE$(77), 77);
  LOCATE 6, 2
  PRINT LEFT$("Right: " + Formula$(1) + SPACE$(77), 77);
  r$ = "Beam: LEVEL"
  IF nt% > 0 THEN r$ = "Beam: RIGHT side goes down"
  IF nt% < 0 THEN r$ = "Beam: LEFT side goes down"
  IF pk%(1) <> 2 THEN r$ = r$ + "    net torque (right - left) =" + STR$(nt%)
  COLOR 15
  LOCATE 7, 2
  PRINT LEFT$(r$ + SPACE$(77), 77);
  COLOR 7
  CALL HandLine
  LOCATE 30, 1
  PRINT "Arrows move  Space=weight  Enter=place  U=pick up  R=clear    ESC = menu";
END SUB

' Can the hand weights, all placed, balance the beam? (10 positions each: -5..-1, 1..5)
FUNCTION Solvable%
  r% = 0
  tot1% = 1
  FOR i% = 1 TO h%
    tot1% = tot1% * 10
  NEXT i%
  FOR t% = 0 TO tot1% - 1
    tt% = t%
    tq% = pw%(1) * pp%(1)
    FOR i% = 2 TO h% + 1
      d% = tt% MOD 10
      tt% = tt% \ 10
      p% = d% - 5
      IF d% >= 5 THEN p% = d% - 4
      tq% = tq% + pw%(i%) * p%
    NEXT i%
    IF tq% = 0 THEN r% = 1
  NEXT t%
  Solvable% = r%
END FUNCTION

SUB Summary
  CLS
  COLOR 14
  LOCATE 4, 24
  PRINT "SEESAW - ALL LEVELS DONE"
  COLOR 15
  LOCATE 7, 10
  PRINT "Total score:"; tot%; "(best possible about 740)"
  COLOR 7
  LOCATE 9, 10
  IF tot% >= 600 THEN
    PRINT "Rating: Archimedes - you move the world with a lever!"
  ELSEIF tot% >= 400 THEN
    PRINT "Rating: Good balance - you understand torque."
  ELSE
    PRINT "Rating: Keep practising: multiply weight by distance on each side."
  END IF
  LOCATE 12, 10
  PRINT "Remember: a heavy weight near the pivot can balance a light weight far away."
  LOCATE 13, 10
  PRINT "Unknown mass = (torque of known weights) / (distance of the unknown mass)."
  COLOR 14
  LOCATE 17, 10
  PRINT "Any key = play again, ESC = menu";
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 22
  PRINT "G21  SEESAW  (QIAO QIAO BAN)"
  COLOR 7
  LOCATE 6, 6
  PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6
  PRINT "The LEVER PRINCIPLE: a seesaw balances when the torque on the left"
  LOCATE 8, 6
  PRINT "equals the torque on the right.  Torque = weight x distance from the pivot."
  COLOR 7
  LOCATE 11, 6
  PRINT "How to play:"
  LOCATE 12, 6
  PRINT "A fixed weight sits on the left. Place the weights in your hand on the beam"
  LOCATE 13, 6
  PRINT "(positions -5..-1 left, 1..5 right; stacking is allowed) so it levels out."
  LOCATE 14, 6
  PRINT "The beam tilts live and the torque sums are shown above it."
  LOCATE 15, 6
  PRINT "Levels 5 and 6 hide a MYSTERY mass (?): balance it, then work out its mass."
  LOCATE 17, 6
  PRINT "Left/Right = move cursor   Space = next weight   Enter = place"
  LOCATE 18, 6
  PRINT "U = pick up a weight at the cursor   R = clear the beam   ESC = menu"
  COLOR 10
  LOCATE 20, 6
  PRINT "Score: 100 per level minus 10 for every extra move; mystery answer bonus."
  COLOR 14
  LOCATE 23, 6
  PRINT "Press any key to start...";
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB
