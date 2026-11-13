' G20.BAS - Admiral (HAI JUN SHANG JIANG)
' Educational content (1991 list): vectors and navigation. A ship's own velocity vector PLUS the
'   water current's vector gives the REAL (resultant) vector - vector addition by parallelogram.
' Controls: Left/Right = heading (15 deg), Up/Down = speed, Enter = sail one turn, N = new map,
'   ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Arrow (x1!, y1!, x2!, y2!, c%)
DECLARE SUB NewLevel ()
DECLARE SUB DrawScene ()
DECLARE SUB Sail ()
DECLARE FUNCTION ZoneOf% (py!)

CONST PI = 3.14159265
DIM SHARED cux%(1 TO 3), cuy%(1 TO 3)
DIM SHARED tx!(0 TO 20), ty!(0 TO 20)
DIM SHARED shx!, shy!, hbx!, hby!, isx!, isy!, isr!
DIM SHARED hd%, spd%, fuel%, turns%, lvl%, ntr%, stat%
DIM SHARED score&

RANDOMIZE TIMER
SCREEN 12
CLS
COLOR 14
LOCATE 2, 22: PRINT "G20  ADMIRAL  (HAI JUN SHANG JIANG)"
COLOR 15
LOCATE 4, 8: PRINT "Steer your ship to the harbour before you run out of turns or fuel."
COLOR 11
LOCATE 6, 8: PRINT "What you learn: VECTOR ADDITION."
LOCATE 7, 8: PRINT "Your ship has its own velocity vector (heading + speed, cyan arrow)."
LOCATE 8, 8: PRINT "The sea moves too: each water zone has a current vector (blue arrow)."
LOCATE 9, 8: PRINT "Where you REALLY go is the sum of the two (yellow arrow): place the"
LOCATE 10, 8: PRINT "blue arrow at the tip of the cyan one and join start to end."
LOCATE 11, 8: PRINT "Vectors are written (E,N): east and north parts, in knots."
LOCATE 12, 8: PRINT "One turn = 10 pixels per knot.  Beware of the island (brown)."
COLOR 7
LOCATE 15, 8: PRINT "Left/Right = turn the bow 15 degrees    Up/Down = speed 0..6 knots"
LOCATE 16, 8: PRINT "Enter = sail one turn    N = new map    ESC = back to menu"
LOCATE 17, 8: PRINT "Score for each harbour = 100 + 10 x turns left + fuel left."
COLOR 14
LOCATE 20, 8: PRINT "Press any key to start"
k$ = GetKey$
IF k$ = CHR$(27) THEN GOTO ExitGame

lvl% = 1: score& = 0
CALL NewLevel
DO
  CALL DrawScene
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
  IF LEN(k$) = 2 THEN
    SELECT CASE ASC(RIGHT$(k$, 1))
      CASE 75: hd% = (hd% + 345) MOD 360
      CASE 77: hd% = (hd% + 15) MOD 360
      CASE 72: IF spd% < 6 THEN spd% = spd% + 1
      CASE 80: IF spd% > 0 THEN spd% = spd% - 1
    END SELECT
  ELSEIF k$ = CHR$(13) OR k$ = " " THEN
    CALL Sail
    CALL DrawScene
    IF stat% = 1 THEN
      pts& = 100 + turns% * 10 + fuel%
      score& = score& + pts&
      COLOR 10: LOCATE 28, 4
      PRINT "PORT REACHED!  +"; pts&; "points.  Press a key for the next voyage.";
      k$ = GetKey$
      IF k$ = CHR$(27) THEN GOTO ExitGame
      lvl% = lvl% + 1
      CALL NewLevel
    ELSEIF turns% <= 0 THEN
      COLOR 12: LOCATE 28, 4
      PRINT "Out of turns - the admiral is relieved of command.  Final score"; score&;
      LOCATE 29, 4: PRINT "R = new game    ESC = menu";
      DO
        k$ = GetKey$
        IF k$ = CHR$(27) THEN GOTO ExitGame
      LOOP UNTIL UCASE$(k$) = "R"
      lvl% = 1: score& = 0
      CALL NewLevel
    ELSEIF stat% = 2 THEN
      COLOR 12: LOCATE 28, 4: PRINT "Aground on the island!  The turn is lost.";
      Delay 1.2
    END IF
  ELSEIF UCASE$(k$) = "N" THEN
    CALL NewLevel
  END IF
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

' Draw a vector arrow from (x1,y1) to (x2,y2) with a small head
SUB Arrow (x1!, y1!, x2!, y2!, c%)
  dx! = x2! - x1!: dy! = y2! - y1!
  ln! = SQR(dx! * dx! + dy! * dy!)
  IF ln! < 2 THEN EXIT SUB
  LINE (x1!, y1!)-(x2!, y2!), c%
  bx! = -dx! / ln!: by! = -dy! / ln!
  ax! = x2! + 9 * (bx! * .8776 - by! * .4794)
  ay! = y2! + 9 * (bx! * .4794 + by! * .8776)
  LINE (x2!, y2!)-(ax!, ay!), c%
  ax! = x2! + 9 * (bx! * .8776 + by! * .4794)
  ay! = y2! + 9 * (-bx! * .4794 + by! * .8776)
  LINE (x2!, y2!)-(ax!, ay!), c%
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

' Draw the sea, the three current zones, island, harbour, trail and the three vectors
SUB DrawScene
  CLS
  FOR z% = 1 TO 2
    LINE (0, z% * 122 + 1)-(639, z% * 122 + 1), 8, , &HAAAA
  NEXT z%
  LINE (0, 367)-(639, 367), 7
  FOR z% = 1 TO 3
    yc! = 61 + (z% - 1) * 123
    CALL Arrow(300!, yc!, 300! + cux%(z%) * 10, yc! - cuy%(z%) * 10, 3)
    COLOR 3
    LOCATE INT(yc! / 16) + 1, 44
    PRINT "Current zone"; z%; ": E"; cux%(z%); "N"; cuy%(z%);
  NEXT z%
  COLOR 6
  CIRCLE (isx!, isy!), isr!, 6
  PAINT (isx!, isy!), 6, 6
  CIRCLE (hbx!, hby!), 14, 12
  CIRCLE (hbx!, hby!), 5, 12
  COLOR 12
  LOCATE INT((hby! - 22) / 16) + 1, INT(hbx! / 8) - 1
  PRINT "PORT";
  COLOR 15
  LOCATE 1, 80: PRINT "N";
  CALL Arrow(636!, 40!, 636!, 20!, 15)
  FOR i% = 1 TO ntr%
    LINE (tx!(i% - 1), ty!(i% - 1))-(tx!(i%), ty!(i%)), 14
    CIRCLE (tx!(i%), ty!(i%)), 2, 14
  NEXT i%
  CIRCLE (shx!, shy!), 5, 15
  PSET (shx!, shy!), 15
  s% = spd%
  IF s% > fuel% THEN s% = fuel%
  bx! = s% * SIN(hd% * PI / 180)
  by! = s% * COS(hd% * PI / 180)
  z% = ZoneOf%(shy!)
  ex! = shx! + bx! * 10: ey! = shy! - by! * 10
  CALL Arrow(shx!, shy!, ex!, ey!, 11)
  fx! = ex! + cux%(z%) * 10: fy! = ey! - cuy%(z%) * 10
  CALL Arrow(ex!, ey!, fx!, fy!, 9)
  CALL Arrow(shx!, shy!, fx!, fy!, 14)
  COLOR 15
  LOCATE 24, 1
  PRINT "Level"; lvl%; "  Score"; score&; "  Turns left"; turns%; "  Fuel"; fuel%;
  PRINT "  Heading"; hd%; "deg  Speed"; spd%; "kn";
  LOCATE 25, 1
  PRINT USING "Boat E##.# N##.#  + Current E##.# N##.#"; bx!; by!; cux%(z%); cuy%(z%);
  PRINT USING "  = REAL E##.# N##.#"; bx! + cux%(z%); by! + cuy%(z%);
  COLOR 7
  LOCATE 26, 1: PRINT "Cyan = boat vector, blue = current at your position, yellow = real path.";
  LOCATE 27, 1: PRINT "Left/Right heading  Up/Down speed  Enter sail  N new map";
  LOCATE 30, 1: PRINT "ESC = menu";
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

' New map: random currents per zone, harbour and island; reset the ship
SUB NewLevel
  mx% = 2
  IF lvl% > 2 THEN mx% = 3
  FOR z% = 1 TO 3
    cux%(z%) = INT(RND * (2 * mx% + 1)) - mx%
    cuy%(z%) = INT(RND * (2 * mx% + 1)) - mx%
  NEXT z%
  shx! = 40: shy! = 340
  hbx! = 420 + INT(RND * 180): hby! = 30 + INT(RND * 300)
  isx! = 140 + INT(RND * 120): isy! = 60 + INT(RND * 240): isr! = 16 + INT(RND * 10)
  hd% = 45: spd% = 3: fuel% = 70: turns% = 14
  ntr% = 0: tx!(0) = shx!: ty!(0) = shy!
  stat% = 0
END SUB

' One turn: 8 small steps, current looked up at the ship's position each step
SUB Sail
  s% = spd%
  IF s% > fuel% THEN s% = fuel%
  bx! = s% * SIN(hd% * PI / 180)
  by! = s% * COS(hd% * PI / 180)
  stat% = 0
  FOR k% = 1 TO 8
    z% = ZoneOf%(shy!)
    nx! = shx! + (bx! + cux%(z%)) * 1.25
    ny! = shy! - (by! + cuy%(z%)) * 1.25
    IF nx! < 4 THEN nx! = 4
    IF nx! > 635 THEN nx! = 635
    IF ny! < 4 THEN ny! = 4
    IF ny! > 362 THEN ny! = 362
    dd! = SQR((nx! - isx!) * (nx! - isx!) + (ny! - isy!) * (ny! - isy!))
    IF dd! < isr! + 4 THEN
      stat% = 2
      EXIT FOR
    END IF
    LINE (shx!, shy!)-(nx!, ny!), 14
    shx! = nx!: shy! = ny!
    dd! = SQR((shx! - hbx!) * (shx! - hbx!) + (shy! - hby!) * (shy! - hby!))
    IF dd! <= 14 THEN
      stat% = 1
      EXIT FOR
    END IF
    Delay .04
  NEXT k%
  fuel% = fuel% - s%
  turns% = turns% - 1
  IF ntr% < 20 THEN ntr% = ntr% + 1
  tx!(ntr%) = shx!: ty!(ntr%) = shy!
END SUB

FUNCTION ZoneOf% (py!)
  IF py! < 122 THEN
    ZoneOf% = 1
  ELSEIF py! < 245 THEN
    ZoneOf% = 2
  ELSE
    ZoneOf% = 3
  END IF
END FUNCTION
