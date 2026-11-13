' G28.BAS - Big Front Teeth (DA MEN YA)
' Educational content (1991 list): the structure, types and function of teeth and the
'   correct way to care for them.  Adult 32 teeth = 8 incisors, 4 canines, 8 premolars,
'   12 molars.  Baby teeth: 20.
' Controls: 1-4 pick an activity; arrows move; S/Space soft brush, H hard scrub; ESC = back
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Title ()
DECLARE SUB MenuScreen ()
DECLARE SUB Frame (t$, hint$)
DECLARE SUB Info (r%, t$)
DECLARE FUNCTION ToothType% (i%)
DECLARE FUNCTION TypeName$ (ty%)
DECLARE FUNCTION TypeFunc$ (ty%)
DECLARE FUNCTION TypeNote$ (ty%)
DECLARE FUNCTION ToothName$ (i%)
DECLARE SUB DrawTooth (jw%, i%, mode%, hl%)
DECLARE SUB DrawChart (mode%)
DECLARE SUB Legend ()
DECLARE SUB Anatomy ()
DECLARE SUB DrawSection (sel%)
DECLARE SUB PartText (sel%)
DECLARE SUB Learn ()
DECLARE SUB ShowTooth (jw%, i%)
DECLARE SUB Quiz ()
DECLARE SUB Brush ()
DECLARE SUB BrushStatus (tl%, gum%, sc%)
DECLARE FUNCTION PlaqueLeft% ()
DECLARE SUB DrawTips (r0%)

' pl%(jaw, tooth): plaque level 0..3 ; jaw 0 = upper, 1 = lower ; tooth 1..16 left to right
DIM SHARED pl%(0 TO 1, 1 TO 16)
DIM SHARED cq$(1 TO 10), ca%(1 TO 10), ce$(1 TO 10)
DIM SHARED tot%, quit%
FOR n% = 1 TO 10
  READ cq$(n%), ca%(n%), ce$(n%)
NEXT n%
DATA "An adult has 32 teeth.",1,"8 incisors, 4 canines, 8 premolars and 12 molars."
DATA "Baby teeth number 20.",1,"8 incisors, 4 canines, 8 molars - no premolars."
DATA "An adult has 12 molars.",1,"6 in each jaw, wisdom teeth included."
DATA "An adult has 6 premolars.",0,"8 premolars: 2 on each side of each jaw."
DATA "Brush hard so teeth get cleaner.",0,"Hard scrubbing wears enamel and hurts gums. Be gentle."
DATA "Brush at least twice a day.",1,"Morning and bedtime, 2 minutes, fluoride toothpaste."
DATA "Enamel is the hardest part of the body.",1
DATA "It cannot regrow, so protect it from acid and sugar."
DATA "Floss is not needed if you brush.",0,"A brush cannot reach between teeth. Floss every day."
DATA "Sweets all day are fine if I brush at night.",0
DATA "Each sugar hit feeds plaque bacteria. Limit sweets."
DATA "See a dentist twice a year.",1,"Checkups find cavities early, before they hurt."

RANDOMIZE TIMER
SCREEN 12
tot% = 0
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
DO
  CALL MenuScreen
  k$ = GetKey$
  IF k$ = CHR$(27) THEN EXIT DO
  IF k$ = "1" THEN CALL Anatomy
  IF k$ = "2" THEN CALL Learn
  IF k$ = "3" THEN CALL Quiz
  IF k$ = "4" THEN CALL Brush
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

SUB Anatomy
  sel% = 1
  CALL Frame("Inside a tooth", "Up/Down or 1-6 = choose a part   ESC = back")
  DO
    CALL DrawSection(sel%)
    CALL PartText(sel%)
    k$ = GetKey$
    IF k$ = CHR$(27) THEN EXIT DO
    IF k$ = CHR$(0) + "H" THEN sel% = sel% - 1
    IF k$ = CHR$(0) + "P" THEN sel% = sel% + 1
    IF LEN(k$) = 1 THEN
      IF k$ >= "1" AND k$ <= "6" THEN sel% = VAL(k$)
    END IF
    IF sel% < 1 THEN sel% = 6
    IF sel% > 6 THEN sel% = 1
  LOOP
END SUB

SUB Brush
  CALL Frame("Brushing game", "Any key = start   ESC = back")
  CALL Info(3, "Plaque is a sticky film of bacteria. Sugar feeds it and it makes acid that")
  CALL Info(4, "eats enamel. Clear the plaque in 60 seconds, but do NOT scrub the gums raw!")
  CALL DrawTips(6)
  COLOR 10
  CALL Info(15, "Arrows move the brush.  S or Space = soft stroke (+10, gums safe).")
  CALL Info(16, "H = hard scrub: cleans fast but hurts the gums. 5 sore gums = game over.")
  CALL Info(17, "Sweet snacks keep adding plaque. Grey = a little, brown = more, dark = lots.")
  COLOR 14
  CALL Info(19, "Score: 10 per soft stroke, 5 per level scrubbed, 3 per second left if all clean.")
  k$ = GetKey$
  IF k$ = CHR$(27) THEN EXIT SUB
  FOR jw% = 0 TO 1
    FOR i% = 1 TO 16
      pl%(jw%, i%) = 0
      IF RND < .6 THEN pl%(jw%, i%) = INT(RND * 3) + 1
    NEXT i%
  NEXT jw%
  IF PlaqueLeft% = 0 THEN pl%(0, 1) = 2
  CALL Frame("Brushing game - clear the plaque in 60 seconds", "Arrows  S soft  H hard  ESC=back")
  CALL DrawChart(2)
  cj% = 0
  ci% = 8
  gum% = 5
  sc% = 0
  esc% = 0
  CALL DrawTooth(cj%, ci%, 2, 1)
  start! = TIMER
  nxt! = 3
  DO
    e! = TIMER - start!
    IF e! < 0 THEN e! = e! + 86400
    tl% = 60 - INT(e!)
    IF tl% <= 0 THEN
      tl% = 0
      EXIT DO
    END IF
    k$ = INKEY$
    IF k$ = CHR$(27) THEN
      esc% = 1
      EXIT DO
    ELSEIF LEN(k$) = 2 THEN
      CALL DrawTooth(cj%, ci%, 2, 0)
      d$ = RIGHT$(k$, 1)
      IF d$ = "K" THEN ci% = ci% - 1
      IF d$ = "M" THEN ci% = ci% + 1
      IF d$ = "H" OR d$ = "P" THEN cj% = 1 - cj%
      IF ci% < 1 THEN ci% = 16
      IF ci% > 16 THEN ci% = 1
      CALL DrawTooth(cj%, ci%, 2, 1)
    ELSEIF k$ <> "" THEN
      u$ = UCASE$(k$)
      IF u$ = "S" OR u$ = " " THEN
        IF pl%(cj%, ci%) > 0 THEN
          pl%(cj%, ci%) = pl%(cj%, ci%) - 1
          sc% = sc% + 10
          CALL Info(24, "Soft short strokes: plaque comes off and the gums stay happy.")
        ELSE
          CALL Info(24, "That tooth is already clean. Move to a dirty one.")
        END IF
        CALL DrawTooth(cj%, ci%, 2, 1)
      ELSEIF u$ = "H" THEN
        gum% = gum% - 1
        sc% = sc% + 5 * pl%(cj%, ci%)
        pl%(cj%, ci%) = 0
        CALL Info(24, "OUCH! Scrubbing hard hurts the gums and wears the enamel.")
        CALL DrawTooth(cj%, ci%, 2, 1)
      END IF
    END IF
    IF e! >= nxt! THEN
      nj% = INT(RND * 2)
      ni% = INT(RND * 16) + 1
      IF ni% > 16 THEN ni% = 16
      IF pl%(nj%, ni%) < 3 THEN pl%(nj%, ni%) = pl%(nj%, ni%) + 1
      hl% = 0
      IF nj% = cj% AND ni% = ci% THEN hl% = 1
      CALL DrawTooth(nj%, ni%, 2, hl%)
      CALL Info(25, "Sweet snack! New plaque is growing.")
      nxt! = e! + 2.5
    END IF
    CALL BrushStatus(tl%, gum%, sc%)
    IF gum% <= 0 OR PlaqueLeft% = 0 THEN EXIT DO
    CALL Delay(.03)
  LOOP
  IF esc% <> 0 THEN EXIT SUB
  bonus% = 0
  IF PlaqueLeft% = 0 THEN bonus% = tl% * 3
  fin% = sc% + bonus%
  tot% = tot% + fin%
  CALL Frame("Brushing game - result", "Any key = back")
  IF PlaqueLeft% = 0 THEN
    CALL Info(3, "All teeth are clean! Time bonus" + STR$(bonus%))
  ELSEIF gum% <= 0 THEN
    CALL Info(3, "Your gums are too sore - you scrubbed too hard.")
  ELSE
    CALL Info(3, "Time is up. Plaque left on teeth:" + STR$(PlaqueLeft%))
  END IF
  CALL Info(4, "Soft gums left:" + STR$(gum%) + " of 5.   Score this game:" + STR$(fin%))
  CALL DrawTips(7)
  k$ = GetKey$
END SUB

SUB BrushStatus (tl%, gum%, sc%)
  g% = gum%
  IF g% < 0 THEN g% = 0
  IF g% > 5 THEN g% = 5
  s$ = "Time:" + STR$(tl%) + " s   Gums: " + STRING$(g%, "*") + SPACE$(5 - g%)
  s$ = s$ + "   Score:" + STR$(sc%) + "   Plaque left:" + STR$(PlaqueLeft%)
  COLOR 15
  CALL Info(21, s$)
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

SUB DrawChart (mode%)
  COLOR 7
  LOCATE 3, 2: PRINT "Upper jaw";
  LOCATE 19, 2: PRINT "Lower jaw";
  LINE (24, 54)-(616, 67), 4, BF
  LINE (24, 273)-(616, 286), 4, BF
  FOR jw% = 0 TO 1
    FOR i% = 1 TO 16
      CALL DrawTooth(jw%, i%, mode%, 0)
    NEXT i%
  NEXT jw%
END SUB

' Section through a tooth: enamel, dentin, pulp, root (cementum), gum, jawbone.
SUB DrawSection (sel%)
  ce% = 15
  IF sel% = 1 THEN ce% = 10
  cd% = 14
  IF sel% = 2 THEN cd% = 10
  cp% = 12
  IF sel% = 3 THEN cp% = 10
  cc% = 7
  IF sel% = 4 THEN cc% = 10
  cg% = 13
  IF sel% = 5 THEN cg% = 10
  cb% = 6
  IF sel% = 6 THEN cb% = 10
  LINE (320, 290)-(408, 380), cb%, BF
  LINE (472, 290)-(560, 380), cb%, BF
  LINE (320, 225)-(408, 289), cg%, BF
  LINE (472, 225)-(560, 289), cg%, BF
  LINE (390, 110)-(490, 230), ce%, BF
  LINE (398, 118)-(482, 230), cd%, BF
  LINE (410, 230)-(470, 372), cc%, BF
  LINE (415, 230)-(465, 366), cd%, BF
  LINE (418, 140)-(462, 230), cp%, BF
  LINE (435, 230)-(445, 360), cp%, BF
  COLOR 7
  LOCATE 11, 72: PRINT "Crown";
  LOCATE 15, 72: PRINT "Neck";
  LOCATE 20, 72: PRINT "Root";
END SUB

SUB DrawTips (r0%)
  IF r0% < 1 OR r0% > 22 THEN EXIT SUB
  COLOR 11
  CALL Info(r0%, "Correct brushing - in this order:")
  COLOR 7
  CALL Info(r0% + 1, " 1. Soft brush and a pea-sized dab of fluoride toothpaste.")
  CALL Info(r0% + 2, " 2. Hold the brush at 45 degrees to the gum line; short, gentle strokes.")
  CALL Info(r0% + 3, " 3. Outer surfaces first, then inner surfaces, then the chewing surfaces.")
  CALL Info(r0% + 4, " 4. Gently brush the tongue. Total 2 minutes, morning and bedtime.")
  CALL Info(r0% + 5, " 5. Floss once a day, eat fewer sweets, new brush every 3 months.")
  CALL Info(r0% + 6, " 6. See a dentist twice a year.")
END SUB

' jw 0 = upper jaw (crowns hang down), 1 = lower jaw (crowns point up)
' mode 0 plain white, 1 colour by tooth type, 2 colour by plaque level; hl = 1 cursor box
SUB DrawTooth (jw%, i%, mode%, hl%)
  IF i% < 1 OR i% > 16 OR jw% < 0 OR jw% > 1 THEN EXIT SUB
  ty% = ToothType%(i%)
  SELECT CASE ty%
    CASE 1
      h% = 52
    CASE 2
      h% = 60
    CASE 3
      h% = 44
    CASE ELSE
      h% = 36
  END SELECT
  cx% = 32 + (i% - 1) * 36 + 16
  IF jw% = 0 THEN
    yb% = 70
    dr% = 1
    ya% = 68
    yz% = 70 + h% + 3
  ELSE
    yb% = 270
    dr% = -1
    ya% = 270 - h% - 3
    yz% = 272
  END IF
  col% = 15
  IF mode% = 1 THEN
    SELECT CASE ty%
      CASE 1
        col% = 15
      CASE 2
        col% = 11
      CASE 3
        col% = 10
      CASE ELSE
        col% = 9
    END SELECT
  ELSEIF mode% = 2 THEN
    SELECT CASE pl%(jw%, i%)
      CASE 0
        col% = 15
      CASE 1
        col% = 7
      CASE 2
        col% = 6
      CASE ELSE
        col% = 8
    END SELECT
  END IF
  LINE (cx% - 18, ya%)-(cx% + 18, yz%), 0, BF
  FOR j% = 0 TO h% - 1
    y% = yb% + dr% * j%
    SELECT CASE ty%
      CASE 1
        hw% = 11
      CASE 2
        hw% = 13 - (12 * j%) \ h%
      CASE 3
        hw% = 14
      CASE ELSE
        hw% = 16
    END SELECT
    LINE (cx% - hw%, y%)-(cx% + hw%, y%), col%
  NEXT j%
  IF ty% = 3 THEN
    LINE (cx%, yb% + dr% * (h% - 9))-(cx%, yb% + dr% * (h% - 1)), 8
  ELSEIF ty% = 4 THEN
    LINE (cx% - 6, yb% + dr% * (h% - 9))-(cx% - 6, yb% + dr% * (h% - 1)), 8
    LINE (cx% + 6, yb% + dr% * (h% - 9))-(cx% + 6, yb% + dr% * (h% - 1)), 8
  END IF
  IF hl% <> 0 THEN LINE (cx% - 18, ya%)-(cx% + 18, yz%), 14, B
END SUB

SUB Frame (t$, hint$)
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT t$;
  COLOR 10
  LOCATE 1, 60: PRINT "Total score:"; tot%;
  COLOR 7
  LOCATE 30, 1: PRINT LEFT$(hint$ + SPACE$(79), 79);
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB Info (r%, t$)
  IF r% < 1 OR r% > 29 THEN EXIT SUB
  LOCATE r%, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

SUB Learn
  jw% = 0
  i% = 8
  CALL Frame("Learn the teeth", "Arrows = choose a tooth   ESC = back")
  CALL DrawChart(1)
  CALL Legend
  COLOR 7
  CALL Info(25, "Adult: 32 teeth = 8 incisors + 4 canines + 8 premolars + 12 molars.")
  CALL Info(26, "Baby (milk) teeth: 20 = 8 incisors + 4 canines + 8 molars (no premolars).")
  CALL DrawTooth(jw%, i%, 1, 1)
  CALL ShowTooth(jw%, i%)
  DO
    k$ = GetKey$
    IF k$ = CHR$(27) THEN EXIT DO
    IF LEN(k$) = 2 THEN
      CALL DrawTooth(jw%, i%, 1, 0)
      d$ = RIGHT$(k$, 1)
      IF d$ = "K" THEN i% = i% - 1
      IF d$ = "M" THEN i% = i% + 1
      IF d$ = "H" OR d$ = "P" THEN jw% = 1 - jw%
      IF i% < 1 THEN i% = 16
      IF i% > 16 THEN i% = 1
      CALL DrawTooth(jw%, i%, 1, 1)
      CALL ShowTooth(jw%, i%)
    END IF
  LOOP
END SUB

SUB Legend
  LOCATE 11, 3
  COLOR 15: PRINT "Incisor x8 (cut)   ";
  COLOR 11: PRINT "Canine x4 (tear)   ";
  COLOR 10: PRINT "Premolar x8 (crush)   ";
  COLOR 9: PRINT "Molar x12 (grind)";
  COLOR 7
  LOCATE 12, 3: PRINT "Counts are for the whole mouth: half of them are in each jaw.";
END SUB

SUB MenuScreen
  CALL Frame("G28 Big Front Teeth (DA MEN YA)", "1-4 = choose   ESC = back to the game menu")
  COLOR 15
  LOCATE 5, 10: PRINT "1  Inside a tooth     - enamel, dentin, pulp, root, gum, bone"
  LOCATE 7, 10: PRINT "2  Learn the teeth    - 4 types, their names and jobs"
  LOCATE 9, 10: PRINT "3  Tooth quiz         - 8 questions, 10 points each"
  LOCATE 11, 10: PRINT "4  Brushing game      - clear the plaque, protect the gums"
  COLOR 7
  LOCATE 14, 10: PRINT "Quiz and brushing points are added to your total score."
END SUB

SUB PartText (sel%)
  COLOR 7
  p$ = "Enamel    Dentin    Pulp      Root      Gum       Jawbone   "
  FOR n% = 1 TO 6
    LOCATE 3 + n%, 2
    IF n% = sel% THEN COLOR 10 ELSE COLOR 7
    PRINT STR$(n%); " "; MID$(p$, (n% - 1) * 10 + 1, 10);
  NEXT n%
  SELECT CASE sel%
    CASE 1
      a$ = "ENAMEL: the hardest material in the body, a white shell over the crown."
      b$ = "No nerves and it cannot regrow. Acid from sugar and plaque eats it: cavities."
      c$ = "Care: fluoride toothpaste hardens enamel; limit sweets and sour drinks."
    CASE 2
      a$ = "DENTIN: yellow layer under the enamel; softer, makes up most of the tooth."
      b$ = "Tiny tubes lead to the nerve, so worn enamel makes teeth sensitive to cold."
      c$ = "Care: do not brush hard; it wears enamel away and exposes the dentin."
    CASE 3
      a$ = "PULP: soft centre with the nerves and blood vessels that feed the tooth."
      b$ = "A deep cavity reaches it and causes toothache. See the dentist early."
      c$ = "Care: checkups twice a year catch cavities before they reach the pulp."
    CASE 4
      a$ = "ROOT and CEMENTUM: the root is the part under the gum; cementum coats it."
      b$ = "Fibres from the cementum hold the tooth in its socket in the jawbone."
      c$ = "Care: floss daily to keep the gum line and root surface healthy."
    CASE 5
      a$ = "GUM (gingiva): pink tissue that seals around the neck of the tooth."
      b$ = "Plaque at the gum line makes gums red and bleeding (gingivitis)."
      c$ = "Care: brush at 45 degrees toward the gum line, soft and short strokes."
    CASE ELSE
      a$ = "JAWBONE: the socket holds the root firmly and spreads the chewing force."
      b$ = "Untreated gum disease destroys this bone and teeth become loose."
      c$ = "Care: do not smoke, brush and floss daily, visit the dentist."
  END SELECT
  COLOR 15
  CALL Info(26, a$)
  COLOR 7
  CALL Info(27, b$)
  COLOR 10
  CALL Info(28, c$)
END SUB

FUNCTION PlaqueLeft%
  n% = 0
  FOR jw% = 0 TO 1
    FOR i% = 1 TO 16
      n% = n% + pl%(jw%, i%)
    NEXT i%
  NEXT jw%
  PlaqueLeft% = n%
END FUNCTION

SUB Quiz
  DIM usd%(1 TO 10)
  FOR n% = 1 TO 10
    usd%(n%) = 0
  NEXT n%
  sc% = 0
  ab% = 0
  q% = 1
  DO WHILE q% <= 8 AND ab% = 0
    CALL Frame("Quiz - question" + STR$(q%) + " of 8", "ESC = back")
    ok% = 0
    IF q% MOD 2 = 1 THEN
      CALL DrawChart(0)
      jw% = INT(RND * 2)
      i% = INT(RND * 16) + 1
      IF i% > 16 THEN i% = 16
      CALL DrawTooth(jw%, i%, 0, 1)
      ty% = ToothType%(i%)
      COLOR 15
      CALL Info(21, "Which TYPE of tooth is in the yellow box?")
      CALL Info(22, "1 Incisor    2 Canine    3 Premolar    4 Molar")
      a% = 0
      DO
        k$ = GetKey$
        IF k$ = CHR$(27) THEN ab% = 1
        IF LEN(k$) = 1 THEN
          IF k$ >= "1" AND k$ <= "4" THEN a% = VAL(k$)
        END IF
      LOOP UNTIL a% > 0 OR ab% <> 0
      IF ab% = 0 THEN
        IF a% = ty% THEN ok% = 1
        IF ok% <> 0 THEN
          COLOR 10
          CALL Info(24, "Correct! " + ToothName$(i%) + " - a " + TypeName$(ty%) + ".")
        ELSE
          COLOR 12
          CALL Info(24, "Not quite: it is a " + TypeName$(ty%) + " (" + ToothName$(i%) + ").")
        END IF
        COLOR 7
        CALL Info(25, TypeName$(ty%) + ": " + TypeFunc$(ty%))
      END IF
    ELSE
      DO
        n% = INT(RND * 10) + 1
      LOOP UNTIL n% >= 1 AND n% <= 10 AND usd%(n%) = 0
      usd%(n%) = 1
      COLOR 15
      LOCATE 8, 4: PRINT "True or False?"
      LOCATE 10, 4: PRINT cq$(n%)
      COLOR 7
      LOCATE 13, 4: PRINT "T = True     F = False"
      a% = -1
      DO
        k$ = UCASE$(GetKey$)
        IF k$ = CHR$(27) THEN ab% = 1
        IF k$ = "T" THEN a% = 1
        IF k$ = "F" THEN a% = 0
      LOOP UNTIL a% >= 0 OR ab% <> 0
      IF ab% = 0 THEN
        IF a% = ca%(n%) THEN ok% = 1
        IF ok% <> 0 THEN
          COLOR 10
          LOCATE 16, 4: PRINT "Correct!"
        ELSE
          COLOR 12
          LOCATE 16, 4: PRINT "Not quite."
        END IF
        COLOR 7
        LOCATE 17, 4: PRINT ce$(n%)
      END IF
    END IF
    IF ab% = 0 THEN
      IF ok% <> 0 THEN sc% = sc% + 10
      CALL Info(28, "Score" + STR$(sc%) + ".  Any key = next")
      k$ = GetKey$
      IF k$ = CHR$(27) THEN ab% = 1
      q% = q% + 1
    END IF
  LOOP
  IF ab% <> 0 THEN EXIT SUB
  tot% = tot% + sc%
  CALL Frame("Quiz - result", "Any key = back")
  COLOR 15
  LOCATE 5, 4: PRINT "Quiz score:"; sc%; "of 80"
  COLOR 10
  IF sc% >= 70 THEN
    LOCATE 7, 4: PRINT "Tooth expert!"
  ELSEIF sc% >= 40 THEN
    LOCATE 7, 4: PRINT "Good. Look again at the Learn screen and the tooth types."
  ELSE
    LOCATE 7, 4: PRINT "Keep practising: visit Learn the teeth, then try again."
  END IF
  CALL DrawTips(10)
  k$ = GetKey$
END SUB

SUB ShowTooth (jw%, i%)
  ty% = ToothType%(i%)
  j$ = "Upper"
  IF jw% = 1 THEN j$ = "Lower"
  COLOR 15
  CALL Info(21, j$ + " jaw, tooth" + STR$(i%) + ": " + ToothName$(i%))
  COLOR 14
  CALL Info(22, "Type: " + TypeName$(ty%))
  COLOR 7
  CALL Info(23, "Job: " + TypeFunc$(ty%))
  CALL Info(24, TypeNote$(ty%))
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 20: PRINT "G28  BIG FRONT TEETH  (DA MEN YA)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "Teeth: their STRUCTURE, their TYPES and jobs, and the CORRECT WAY to care"
  LOCATE 8, 6: PRINT "for them."
  COLOR 7
  LOCATE 11, 6: PRINT "Adult: 32 teeth = 8 incisors (cut), 4 canines (tear), 8 premolars (crush)"
  LOCATE 12, 6: PRINT "and 12 molars (grind).  Baby teeth: 20, with no premolars."
  LOCATE 13, 6: PRINT "Each tooth has enamel, dentin, pulp and a root held in the jawbone."
  LOCATE 15, 6: PRINT "Choose: inside a tooth, learn the 32 teeth, a quiz, or a brushing game."
  LOCATE 16, 6: PRINT "Arrow keys move, S/H brush, numbers choose, ESC = back to the menu."
  COLOR 10
  LOCATE 18, 6: PRINT "Score: 10 per quiz answer, plus points for plaque you brush away."
  COLOR 14
  LOCATE 22, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB

' Position 1..16 counted left to right across the jaw; the middle is between 8 and 9.
FUNCTION ToothName$ (i%)
  SELECT CASE i%
    CASE 1, 16
      ToothName$ = "Third molar (wisdom tooth)"
    CASE 2, 15
      ToothName$ = "Second molar"
    CASE 3, 14
      ToothName$ = "First molar"
    CASE 4, 13
      ToothName$ = "Second premolar"
    CASE 5, 12
      ToothName$ = "First premolar"
    CASE 6, 11
      ToothName$ = "Canine (eye tooth)"
    CASE 7, 10
      ToothName$ = "Lateral incisor"
    CASE 8, 9
      ToothName$ = "Central incisor (big front tooth)"
    CASE ELSE
      ToothName$ = ""
  END SELECT
END FUNCTION

' 1 incisor, 2 canine, 3 premolar, 4 molar
FUNCTION ToothType% (i%)
  SELECT CASE i%
    CASE 1 TO 3, 14 TO 16
      ToothType% = 4
    CASE 4, 5, 12, 13
      ToothType% = 3
    CASE 6, 11
      ToothType% = 2
    CASE ELSE
      ToothType% = 1
  END SELECT
END FUNCTION

FUNCTION TypeFunc$ (ty%)
  SELECT CASE ty%
    CASE 1
      TypeFunc$ = "chisel-shaped edge that cuts and bites food."
    CASE 2
      TypeFunc$ = "pointed and strong; tears and holds food."
    CASE 3
      TypeFunc$ = "two cusps; crush and tear food."
    CASE ELSE
      TypeFunc$ = "broad, bumpy top that grinds food into small bits."
  END SELECT
END FUNCTION

FUNCTION TypeName$ (ty%)
  SELECT CASE ty%
    CASE 1
      TypeName$ = "Incisor"
    CASE 2
      TypeName$ = "Canine"
    CASE 3
      TypeName$ = "Premolar"
    CASE ELSE
      TypeName$ = "Molar"
  END SELECT
END FUNCTION

FUNCTION TypeNote$ (ty%)
  SELECT CASE ty%
    CASE 1
      TypeNote$ = "8 in an adult (4 up, 4 down). They bite off a piece of apple and help speech."
    CASE 2
      TypeNote$ = "4 in an adult, with the longest roots. Called the 'eye teeth' (upper)."
    CASE 3
      TypeNote$ = "8 in an adult. Baby teeth have none; they grow in at about age 10."
    CASE ELSE
      TypeNote$ = "12 in an adult, including 4 wisdom teeth (appear at about 17-25)."
  END SELECT
END FUNCTION
