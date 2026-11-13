' G23.BAS - Moon Landing (CHANG E DENG YUE)
' Educational content (1991 list): the ideas of gravity and acceleration.
'   Gravity pulls the lander down: it gains speed every second (acceleration g).
'   Moon g = 1.62 m/s2, Earth g = 9.8 m/s2. Engine thrust gives an upward acceleration.
'   Net acceleration = thrust acceleration - g.
' Controls: Up/Down = more/less throttle (0-10), Space = engine off,
'   Left/Right = sideways push, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Title ()
DECLARE SUB DrawLander (x!, y!, thr%, c%)
DECLARE SUB Ground (padx%)
DECLARE SUB Panel (nm$, g!, thr%, tmax!, alt!, vy!, vx!, fuel!, ac!)

CONST ALT0 = 500
CONST FLOORY = 430

RANDOMIZE TIMER
SCREEN 12
CALL Title
wins% = 0
FOR lv% = 1 TO 3
  READ nm$, g!, tmax!, fuel!
  padx% = 120 + INT(RND * 400)
  x! = 80 + INT(RND * 480)
  alt! = ALT0: vy! = 0: vx! = 0: thr% = 0
  CLS
  CALL Ground(padx%)
  oy! = FLOORY - alt! * 350 / ALT0
  ox! = x!: othr% = 0
  landed% = 0
  DO
    k$ = INKEY$
    IF k$ = CHR$(27) THEN GOTO ExitGame
    IF k$ = " " THEN thr% = 0
    IF LEN(k$) = 2 THEN
      SELECT CASE RIGHT$(k$, 1)
        CASE "H"
          IF thr% < 10 THEN thr% = thr% + 1
        CASE "P"
          IF thr% > 0 THEN thr% = thr% - 1
        CASE "K"
          IF fuel! > 0 THEN vx! = vx! - .5: fuel! = fuel! - .3
        CASE "M"
          IF fuel! > 0 THEN vx! = vx! + .5: fuel! = fuel! - .3
      END SELECT
    END IF
    IF fuel! <= 0 THEN fuel! = 0: thr% = 0
    ' acceleration: engine up, gravity down  (a = thrust - g)
    ac! = thr% / 10 * tmax! - g!
    vy! = vy! + ac! * .1
    alt! = alt! + vy! * .1
    x! = x! + vx! * 3
    IF x! < 20 THEN x! = 20: vx! = 0
    IF x! > 620 THEN x! = 620: vx! = 0
    fuel! = fuel! - thr% / 10 * .25
    IF alt! <= 0 THEN alt! = 0: landed% = 1
    CALL DrawLander(ox!, oy!, othr%, 0)
    CALL Ground(padx%)
    y! = FLOORY - alt! * 350 / ALT0
    CALL DrawLander(x!, y!, thr%, 11)
    ox! = x!: oy! = y!: othr% = thr%
    CALL Panel(nm$, g!, thr%, tmax!, alt!, vy!, vx!, fuel!, ac!)
    CALL Delay(.05)
  LOOP UNTIL landed%
  sp! = ABS(vy!)
  LOCATE 14, 22
  IF sp! <= 2.5 AND ABS(vx!) <= 2 AND ABS(x! - padx%) <= 35 THEN
    COLOR 10: PRINT "SOFT LANDING!  Speed"; INT(sp! * 10) / 10; "m/s";
    wins% = wins% + 1
  ELSEIF ABS(x! - padx%) > 35 THEN
    COLOR 12: PRINT "Missed the landing pad!";
  ELSE
    COLOR 12: PRINT "CRASH!  Too fast: speed"; INT(sp! * 10) / 10; "m/s (limit 2.5)";
  END IF
  COLOR 7
  LOCATE 16, 22: PRINT "Free fall: v squared = 2 x g x height. Higher g = faster impact.";
  LOCATE 18, 22: PRINT "Press any key";
  junk$ = GetKey$
NEXT lv%
CLS
COLOR 14: LOCATE 8, 28: PRINT "MOON LANDING - RESULT"
COLOR 15: LOCATE 11, 22: PRINT "Soft landings:"; wins%; "of 3"
COLOR 7
LOCATE 13, 22: PRINT "On the Moon gravity is only 1/6 of Earth's, so a small engine is enough."
LOCATE 15, 22: PRINT "Press any key to return to the menu."
junk$ = GetKey$
GOTO ExitGame

DATA "MOON",1.62,4,60
DATA "EARTH",9.8,20,80
DATA "MOON (low fuel)",1.62,4,50

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

SUB DrawLander (x!, y!, thr%, c%)
  ix% = INT(x!): iy% = INT(y!)
  IF iy% < 20 THEN iy% = 20
  LINE (ix% - 8, iy% - 16)-(ix% + 8, iy% - 4), c%, B
  LINE (ix% - 8, iy% - 4)-(ix% - 12, iy%), c%
  LINE (ix% + 8, iy% - 4)-(ix% + 12, iy%), c%
  IF thr% > 0 THEN
    fc% = c%
    IF c% <> 0 THEN fc% = 12
    LINE (ix% - 4, iy% - 4)-(ix%, iy% - 4 + thr% * 2), fc%
    LINE (ix% + 4, iy% - 4)-(ix%, iy% - 4 + thr% * 2), fc%
  END IF
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB Ground (padx%)
  LINE (0, FLOORY + 1)-(639, FLOORY + 1), 8
  LINE (padx% - 35, FLOORY + 1)-(padx% + 35, FLOORY + 3), 10, BF
END SUB

SUB Panel (nm$, g!, thr%, tmax!, alt!, vy!, vx!, fuel!, ac!)
  COLOR 15
  LOCATE 1, 2: PRINT "Planet: "; nm$; "   gravity g ="; g!; "m/s2    ";
  fs! = INT(-vy! * 10) / 10
  LOCATE 2, 2: PRINT "Altitude"; INT(alt!); "m  Fall speed"; fs!; "m/s  Side"; vx!; "   ";
  LOCATE 3, 2: PRINT "Throttle"; thr%; "/10  Net accel"; INT(ac! * 100) / 100; "m/s2 (+ = up)   ";
  LOCATE 4, 2: PRINT "Fuel"; INT(fuel!); "   Land softly: speed <= 2.5 m/s, on the green pad.    ";
  LOCATE 29, 2: PRINT "Up/Down throttle  Space off  Left/Right sideways  ESC = menu";
  COLOR 7
END SUB

SUB Title
  CLS
  COLOR 14: LOCATE 3, 25: PRINT "G23  MOON LANDING  (CHANG E DENG YUE)"
  COLOR 15
  LOCATE 6, 8: PRINT "Land the lander gently on the green pad."
  COLOR 7
  LOCATE 8, 8: PRINT "GRAVITY pulls the lander down. It does not just fall: it falls FASTER"
  LOCATE 9, 8: PRINT "every second. That change of speed per second is ACCELERATION."
  LOCATE 11, 8: PRINT "  Moon: g = 1.62 m/s2      Earth: g = 9.8 m/s2"
  LOCATE 13, 8: PRINT "The engine gives an upward acceleration. Net acceleration = engine - g."
  LOCATE 14, 8: PRINT "If net acceleration is negative you speed up downward; if positive you slow."
  LOCATE 16, 8: PRINT "Three flights: Moon, Earth (harder), Moon with little fuel."
  COLOR 10
  LOCATE 19, 8: PRINT "Up/Down = throttle   Space = off   Left/Right = sideways   ESC = menu"
  COLOR 15
  LOCATE 22, 8: PRINT "Press any key to start";
  junk$ = GetKey$
END SUB
