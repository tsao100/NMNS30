' G22.BAS - Sailing Upwind (NI FENG XING ZHOU)
' Educational content (1991 list): the principle of sailing against the wind.
'   A boat cannot sail straight into the wind. The wind pushes on the sail, and the keel turns
'   part of that push into forward motion, so a boat can sail about 45 degrees off the wind.
'   To reach a buoy upwind it zig-zags: this is called tacking.
' Controls: Left/Right arrows turn the boat 15 degrees; ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION Spd! (a!)
DECLARE SUB Title ()
DECLARE SUB Scene (bx%, by%)
DECLARE SUB DrawBoat (x!, y!, hd!, c%)
DECLARE SUB Hud (hd!, v!, tm!, lv%, tk%)

CONST PI = 3.14159265
RANDOMIZE TIMER
SCREEN 12
CALL Title
tot! = 0
FOR lv% = 1 TO 3
  bx% = 100 + INT(RND * 440)
  by% = 60
  x! = 320: y! = 420: hd! = 0
  tk% = 0: side% = 0
  CALL Scene(bx%, by%)
  t0! = TIMER
  done% = 0
  DO
    k$ = INKEY$
    IF k$ = CHR$(27) THEN GOTO ExitGame
    IF LEN(k$) = 2 THEN
      IF RIGHT$(k$, 1) = "K" THEN hd! = hd! - 15
      IF RIGHT$(k$, 1) = "M" THEN hd! = hd! + 15
      IF hd! > 180 THEN hd! = hd! - 360
      IF hd! <= -180 THEN hd! = hd! + 360
    END IF
    a! = ABS(hd!)
    v! = Spd(a!)
    IF SGN(hd!) <> 0 AND a! >= 35 THEN
      IF side% <> 0 AND SGN(hd!) <> side% THEN tk% = tk% + 1
      side% = SGN(hd!)
    END IF
    CALL DrawBoat(x!, y!, hd!, 0)
    PSET (INT(x!), INT(y!)), 3
    x! = x! + 6 * v! * SIN(hd! * PI / 180)
    y! = y! - 6 * v! * COS(hd! * PI / 180)
    IF x! < 15 THEN x! = 15
    IF x! > 625 THEN x! = 625
    IF y! < 95 THEN y! = 95
    IF y! > 440 THEN y! = 440
    CALL DrawBoat(x!, y!, hd!, 14)
    tm! = TIMER - t0!
    IF tm! < 0 THEN tm! = tm! + 86400
    CALL Hud(hd!, v!, tm!, lv%, tk%)
    IF y! <= by% + 40 AND ABS(x! - bx%) < 24 THEN done% = 1
    IF y! <= 96 AND ABS(x! - bx%) < 40 THEN done% = 1
    CALL Delay(.06)
  LOOP UNTIL done%
  tot! = tot! + tm!
  LOCATE 14, 28: COLOR 10: PRINT "Buoy reached in"; INT(tm!); "s,"; tk%; "tacks";
  COLOR 7
  LOCATE 16, 30: PRINT "Press any key";
  junk$ = GetKey$
NEXT lv%
SCREEN 12: CLS
COLOR 14: LOCATE 8, 28: PRINT "SAILING UPWIND - RESULT"
COLOR 15: LOCATE 11, 20: PRINT "Total time for 3 buoys:"; INT(tot!); "seconds"
COLOR 7
LOCATE 13, 20: PRINT "Sailing close to 45 degrees, then tacking, gives the fastest path."
LOCATE 15, 20: PRINT "Press any key to return to the menu."
junk$ = GetKey$
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

SUB DrawBoat (x!, y!, hd!, c%)
  ' boat = line along the heading, with a small sail mark across it
  dx! = SIN(hd! * PI / 180)
  dy! = -COS(hd! * PI / 180)
  LINE (INT(x! - 7 * dx!), INT(y! - 7 * dy!))-(INT(x! + 9 * dx!), INT(y! + 9 * dy!)), c%
  LINE (INT(x! - 5 * dy!), INT(y! + 5 * dx!))-(INT(x! + 5 * dy!), INT(y! - 5 * dx!)), c%
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB Hud (hd!, v!, tm!, lv%, tk%)
  COLOR 15
  LOCATE 2, 2: PRINT "Buoy"; lv%; "of 3   Time"; INT(tm!); "s   Tacks"; tk%; "   ";
  LOCATE 3, 2: PRINT "Heading"; INT(hd!); "deg   Angle to wind"; INT(ABS(hd!)); "deg   ";
  LOCATE 4, 2
  IF ABS(hd!) < 35 THEN
    COLOR 12: PRINT "IN IRONS - the boat cannot point into the wind. Turn away!   ";
  ELSE
    COLOR 10
    vm% = INT(v! * COS(hd! * PI / 180) * 100)
    PRINT "Boat speed"; INT(v! * 100); "%  Upwind progress"; vm%; "%   ";
  END IF
  COLOR 7
END SUB

SUB Scene (bx%, by%)
  CLS
  COLOR 9
  FOR i% = 0 TO 4
    ax% = 80 + i% * 120
    LINE (ax%, 100)-(ax%, 150), 9
    LINE (ax% - 5, 142)-(ax%, 150), 9
    LINE (ax% + 5, 142)-(ax%, 150), 9
  NEXT i%
  COLOR 9
  LOCATE 7, 30: PRINT "WIND blows from the top";
  CIRCLE (bx%, by%), 8, 12
  PAINT (bx%, by%), 12, 12
  COLOR 12
  LOCATE by% \ 16 + 2, bx% \ 8: PRINT "BUOY";
  COLOR 7
  LOCATE 29, 2: PRINT "Left/Right = turn 15 deg   ESC = menu";
END SUB

FUNCTION Spd! (a!)
  ' speed polar: zero in the no-go zone (< 35 deg), best on a beam reach
  IF a! < 35 THEN
    Spd! = 0
  ELSE
    Spd! = .25 + .75 * SQR(SIN((a! - 35) * PI / 145))
  END IF
END FUNCTION

SUB Title
  CLS
  COLOR 14: LOCATE 3, 25: PRINT "G22  SAILING UPWIND  (NI FENG XING ZHOU)"
  COLOR 15
  LOCATE 6, 8: PRINT "Goal: sail from the bottom to the red buoy at the top, against the wind."
  COLOR 7
  LOCATE 8, 8: PRINT "The wind blows from the top of the screen toward the bottom."
  LOCATE 9, 8: PRINT "A boat cannot sail straight into the wind: within 35 degrees of it"
  LOCATE 10, 8: PRINT "the sail just flaps and the boat stops (in irons)."
  LOCATE 12, 8: PRINT "At about 45 to 60 degrees off the wind the sail works like a wing."
  LOCATE 13, 8: PRINT "The wind force on the sail is split in two parts. The sideways part"
  LOCATE 14, 8: PRINT "is stopped by the keel; the forward part drives the boat."
  LOCATE 16, 8: PRINT "So zig-zag left and right (tack). Fewer wasted turns means less time."
  COLOR 10
  LOCATE 19, 8: PRINT "Left / Right arrows: turn the boat 15 degrees.   ESC: menu."
  COLOR 15
  LOCATE 22, 8: PRINT "Press any key to start";
  junk$ = GetKey$
END SUB
