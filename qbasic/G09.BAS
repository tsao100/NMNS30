' G09.BAS - Golf (GAO ER FU QIU)
' Educational content (1991 list): practice the four arithmetic operations (+ - x /).
' Controls: type numbers and Enter, Backspace edits, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (r%, c%, mx%)
DECLARE FUNCTION Num$ (v!)
DECLARE FUNCTION ScrX% (p!)
DECLARE SUB Msg (t$)
DECLARE SUB Title ()
DECLARE SUB MakeQ ()
DECLARE SUB DrawHole (h%, st%, bp!)
DECLARE SUB Fly (p0!, p1!)
DECLARE SUB PlayHole (h%)
DECLARE SUB Finish ()

' hdist! = hole length in metres, hpar% = par, hscore% = strokes taken (0 = not played yet)
DIM SHARED hdist!(1 TO 9), hpar%(1 TO 9), hscore%(1 TO 9)
DIM SHARED hd!, quit%, tot%, parsum%, qtxt$, qans!, nq%, nright%
RANDOMIZE TIMER
SCREEN 12
hd! = 100
quit% = 0
tot% = 0
parsum% = 0
nq% = 0
nright% = 0
FOR i% = 1 TO 9
  READ hdist!(i%), hpar%(i%)
  hscore%(i%) = 0
NEXT i%
DATA 120,3, 280,4, 150,3, 400,5, 210,4, 320,4, 170,3, 450,5, 350,4

CALL Title
IF quit% <> 0 THEN GOTO ExitGame
FOR hh% = 1 TO 9
  CALL PlayHole(hh%)
  IF quit% <> 0 THEN EXIT FOR
NEXT hh%
IF quit% <> 0 THEN GOTO ExitGame
CALL Finish

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

' Draws the whole hole screen: header, card, fairway, flag and ball.
SUB DrawHole (h%, st%, bp!)
  hd! = hdist!(h%)
  CLS
  COLOR 15
  LOCATE 1, 1: PRINT "G09 Golf (GAO ER FU QIU)";
  COLOR 14
  LOCATE 3, 1
  PRINT "Hole"; h%; "of 9   Par"; hpar%(h%); "  Distance"; hdist!(h%); "m  Strokes"; st%;
  c$ = "Card: "
  FOR i% = 1 TO 9
    IF hscore%(i%) > 0 THEN c$ = c$ + LTRIM$(STR$(hscore%(i%))) ELSE c$ = c$ + "-"
    c$ = c$ + " "
  NEXT i%
  COLOR 7
  LOCATE 5, 1: PRINT c$; " Total"; tot%; " (par so far"; parsum%; ")";
  COLOR 10
  LOCATE 7, 1: PRINT "Ball is"; Num$(ABS(hd! - bp!)); "m from the pin (holed when within 2 m)";
  LINE (20, 300)-(620, 300), 2
  LINE (ScrX%(0), 300)-(ScrX%(0), 310), 7
  fx% = ScrX%(hd!)
  LINE (fx%, 300)-(fx%, 262), 7
  LINE (fx%, 262)-(fx% + 16, 268), 12
  LINE (fx% + 16, 268)-(fx%, 274), 12
  CIRCLE (ScrX%(bp!), 297), 3, 15
  COLOR 7
  LOCATE 20, 1: PRINT "Tee";
  LOCATE 24, 1: PRINT "Right answer = steady shot (error under 3%). Wrong = off by 10 to 30%.";
  LOCATE 29, 1: PRINT "Type numbers + Enter    ESC = menu";
END SUB

SUB Finish
  CLS
  d% = tot% - parsum%
  COLOR 14
  LOCATE 3, 20: PRINT "ROUND COMPLETE - G09 Golf"
  COLOR 7
  LOCATE 6, 6: PRINT "Hole  Par  Strokes"
  FOR i% = 1 TO 9
    LOCATE 6 + i%, 6
    PRINT i%; "    "; hpar%(i%); "    "; hscore%(i%)
  NEXT i%
  COLOR 15
  LOCATE 17, 6: PRINT "Total strokes"; tot%; "  Par"; parsum%;
  LOCATE 18, 6: PRINT "Arithmetic answers right:"; nright%; "of"; nq%;
  r$ = "Keep practising your sums!"
  IF d% <= 8 THEN r$ = "Nice round - steady hands and steady sums."
  IF d% <= 2 THEN r$ = "Excellent! Close to par."
  IF d% <= -2 THEN r$ = "Tour champion: under par!"
  COLOR 10
  LOCATE 20, 6: PRINT r$;
  COLOR 7
  LOCATE 29, 1: PRINT "Press any key to return to the menu";
  k$ = GetKey$
END SUB

' Ball in flight: a parabola from the old spot to the new one.
SUB Fly (p0!, p1!)
  x0% = ScrX%(p0!)
  x1% = ScrX%(p1!)
  ah% = 40 + ABS(x1% - x0%) \ 4
  IF ah% > 150 THEN ah% = 150
  FOR i% = 0 TO 24
    t! = i% / 24
    ballx% = x0% + INT((x1% - x0%) * t!)
    bally% = 297 - INT(ah% * 4 * t! * (1 - t!))
    CIRCLE (ballx%, bally%), 3, 15
    CALL Delay(.03)
    CIRCLE (ballx%, bally%), 3, 0
  NEXT i%
  LINE (20, 300)-(620, 300), 2
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

' Makes one question of a random kind: + - x / (answers are whole numbers > 0).
SUB MakeQ
  op% = INT(RND * 4)
  SELECT CASE op%
    CASE 0
      a% = INT(RND * 80) + 10
      b% = INT(RND * 80) + 10
      qtxt$ = LTRIM$(STR$(a%)) + " + " + LTRIM$(STR$(b%))
      qans! = a% + b%
    CASE 1
      a% = INT(RND * 80) + 20
      b% = INT(RND * 18) + 2
      qtxt$ = LTRIM$(STR$(a%)) + " - " + LTRIM$(STR$(b%))
      qans! = a% - b%
    CASE 2
      a% = INT(RND * 11) + 2
      b% = INT(RND * 11) + 3
      qtxt$ = LTRIM$(STR$(a%)) + " x " + LTRIM$(STR$(b%))
      qans! = a% * b%
    CASE ELSE
      b% = INT(RND * 11) + 2
      c% = INT(RND * 11) + 2
      a% = b% * c%
      qtxt$ = LTRIM$(STR$(a%)) + " / " + LTRIM$(STR$(b%))
      qans! = c%
  END SELECT
END SUB

SUB Msg (t$)
  LOCATE 28, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

FUNCTION Num$ (v!)
  Num$ = LTRIM$(STR$(INT(v! + .5)))
END FUNCTION

SUB PlayHole (h%)
  hd! = hdist!(h%)
  bp! = 0
  st% = 0
  holed% = 0
  mtxt$ = "Pick a swing: type the distance in metres (1 to 250)."
  DO
    CALL DrawHole(h%, st%, bp!)
    CALL Msg(mtxt$)
    COLOR 7
    LOCATE 20, 1: PRINT "Swing distance (1-250 m) > ";
    a$ = ReadLine$(20, 28, 6)
    IF a$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    END IF
    sw! = VAL(a$)
    IF sw! < 1 OR sw! > 250 THEN
      mtxt$ = "Please type a number from 1 to 250."
    ELSE
      CALL MakeQ
      COLOR 11
      LOCATE 22, 1: PRINT "Accuracy question:  "; qtxt$; " = ";
      b$ = ReadLine$(22, 24 + LEN(qtxt$), 6)
      IF b$ = CHR$(27) THEN
        quit% = 1
        EXIT SUB
      END IF
      ok% = 0
      IF LEN(b$) > 0 THEN
        IF ABS(VAL(b$) - qans!) < .01 THEN ok% = 1
      END IF
      nq% = nq% + 1
      IF ok% = 1 THEN
        nright% = nright% + 1
        f! = (RND - .5) * .06
        ex$ = "Correct! Steady swing."
      ELSE
        f! = RND * .2 + .1
        IF RND < .5 THEN f! = -f!
        ex$ = "Wrong (answer " + Num$(qans!) + "): off target!"
      END IF
      dr% = 1
      IF hd! < bp! THEN dr% = -1
      land! = bp! + dr% * sw! * (1 + f!)
      IF land! < 0 THEN land! = 0
      CALL Fly(bp!, land!)
      bp! = land!
      st% = st% + 1
      IF ABS(hd! - bp!) <= 2 THEN holed% = 1
      pc% = INT(f! * 100 + .5)
      s$ = LTRIM$(STR$(pc%))
      IF pc% > 0 THEN s$ = "+" + s$
      mtxt$ = ex$ + " Shot length error " + s$ + "%."
    END IF
  LOOP UNTIL holed% <> 0 OR st% >= 8
  hscore%(h%) = st%
  tot% = tot% + st%
  parsum% = parsum% + hpar%(h%)
  CALL DrawHole(h%, st%, bp!)
  d% = st% - hpar%(h%)
  IF holed% = 0 THEN
    r$ = "Pick up! Eight strokes is the limit."
  ELSEIF st% = 1 THEN
    r$ = "HOLE IN ONE!"
  ELSEIF d% <= -3 THEN
    r$ = "Albatross!"
  ELSEIF d% = -2 THEN
    r$ = "Eagle!"
  ELSEIF d% = -1 THEN
    r$ = "Birdie!"
  ELSEIF d% = 0 THEN
    r$ = "Par."
  ELSEIF d% = 1 THEN
    r$ = "Bogey."
  ELSEIF d% = 2 THEN
    r$ = "Double bogey."
  ELSE
    r$ = "Over par by" + STR$(d%) + "."
  END IF
  COLOR 10
  LOCATE 26, 1: PRINT r$; " Strokes:"; st%; "  Par"; hpar%(h%);
  CALL Msg("Press any key for the next hole, ESC = menu")
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
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

' Screen x of a point p metres from the tee (scaled so the pin is at 80% of the width).
FUNCTION ScrX% (p!)
  v! = 40 + p! * 560 / (hd! * 1.25)
  IF v! < 20 THEN v! = 20
  IF v! > 620 THEN v! = 620
  ScrX% = INT(v!)
END FUNCTION

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 25: PRINT "G09  GOLF  (GAO ER FU QIU)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "Practise the FOUR ARITHMETIC OPERATIONS: addition, subtraction,"
  LOCATE 8, 6: PRINT "multiplication and division - fast and accurate sums win the game."
  COLOR 7
  LOCATE 11, 6: PRINT "How to play:"
  LOCATE 12, 6: PRINT "Nine holes, each with a distance in metres and a par."
  LOCATE 13, 6: PRINT "Type how far you want to swing (1 to 250 m) and press Enter."
  LOCATE 14, 6: PRINT "Then answer a sum (+, -, x or /). Right = a steady shot (error under 3%)."
  LOCATE 15, 6: PRINT "Wrong = the shot is off by 10 to 30%. Within 2 m of flag = holed."
  LOCATE 16, 6: PRINT "After 8 strokes you must pick up the ball."
  LOCATE 17, 6: PRINT "Backspace edits, ESC = back to menu."
  COLOR 10
  LOCATE 19, 6: PRINT "Score = total strokes against par (lower is better)."
  COLOR 14
  LOCATE 23, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB
