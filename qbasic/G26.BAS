' G26.BAS - Mantis & Cicada (TANG LANG BU CHAN)
' Educational content (1991 list): food chains and feeding habits of living things.
'   Proverb: "the mantis stalks the cicada, not seeing the oriole behind it".
'   Food chain: plant -> cicada -> mantis -> oriole. Arrows point from food to eater.
' Menu: 1 Food-chain quiz, 2 Feeding-habit quiz, 3 Chase game, ESC = back to main menu
' Chase: arrows move the mantis (M). Eat cicadas (c), hide in tall grass (#) from the oriole (B).
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ChainStr$ (q%)
DECLARE FUNCTION DietStr$ (q%)
DECLARE FUNCTION Part$ (s$, n%)
DECLARE SUB Title ()
DECLARE SUB ChainQuiz ()
DECLARE SUB DietQuiz ()
DECLARE SUB Chase ()

DIM SHARED quit%
RANDOMIZE TIMER
SCREEN 0
WIDTH 80
CALL Title
DO
  COLOR 7, 0
  CLS
  COLOR 14: LOCATE 3, 20: PRINT "G26  MANTIS & CICADA  (TANG LANG BU CHAN)"
  COLOR 15
  LOCATE 7, 25: PRINT "1  Food-chain quiz"
  LOCATE 9, 25: PRINT "2  Feeding-habit quiz"
  LOCATE 11, 25: PRINT "3  Chase game"
  LOCATE 13, 25: PRINT "ESC  Back to the main menu"
  COLOR 7
  k$ = GetKey$
  SELECT CASE k$
    CASE "1"
      CALL ChainQuiz
    CASE "2"
      CALL DietQuiz
    CASE "3"
      CALL Chase
    CASE CHR$(27)
      quit% = 1
  END SELECT
LOOP UNTIL quit%
GOTO ExitGame

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

FUNCTION ChainStr$ (q%)
  ' each chain listed from the producer (food) to the top eater
  SELECT CASE q%
    CASE 1: ChainStr$ = "Grass|Grasshopper|Frog|Snake"
    CASE 2: ChainStr$ = "Leaf|Caterpillar|Small bird|Hawk"
    CASE 3: ChainStr$ = "Algae|Water flea|Small fish|Large fish"
    CASE 4: ChainStr$ = "Corn|Mouse|Snake|Owl"
    CASE 5: ChainStr$ = "Plant sap|Cicada|Mantis|Oriole"
    CASE ELSE: ChainStr$ = "Grass|Rabbit|Fox|Wolf"
  END SELECT
END FUNCTION

SUB ChainQuiz
  DIM nm$(1 TO 4), dp%(1 TO 4)
  score% = 0
  FOR q% = 1 TO 6
    s$ = ChainStr$(q%)
    FOR i% = 1 TO 4
      nm$(i%) = Part$(s$, i%)
      dp%(i%) = i%
    NEXT i%
    FOR i% = 4 TO 2 STEP -1
      j% = 1 + INT(RND * i%)
      SWAP dp%(i%), dp%(j%)
    NEXT i%
    CLS
    COLOR 14: PRINT "FOOD-CHAIN QUIZ  question"; q%; "of 6"
    COLOR 7
    PRINT
    PRINT "Put these living things in food-chain order."
    PRINT "Start with the one that is eaten first (the plant or the smallest food)."
    PRINT
    FOR p% = 1 TO 4
      PRINT "   "; p%; ") "; nm$(dp%(p%))
    NEXT p%
    PRINT
    cr$ = ""
    FOR i% = 1 TO 4
      FOR p% = 1 TO 4
        IF dp%(p%) = i% THEN cr$ = cr$ + CHR$(48 + p%)
      NEXT p%
    NEXT i%
    LINE INPUT "Type the four numbers in order, e.g. 2413 (Q = quit): "; a$
    IF UCASE$(LEFT$(a$, 1)) = "Q" THEN
      EXIT SUB
    END IF
    PRINT
    IF a$ = cr$ THEN
      COLOR 10: PRINT "Correct!"
      score% = score% + 1
    ELSE
      COLOR 12: PRINT "Not quite."
    END IF
    COLOR 15
    PRINT nm$(1); " -> "; nm$(2); " -> "; nm$(3); " -> "; nm$(4)
    COLOR 7
    PRINT "Each arrow points from the food to the animal that eats it."
    PRINT "Press any key"
    junk$ = GetKey$
    IF junk$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    END IF
  NEXT q%
  CLS
  COLOR 14: PRINT "Food-chain quiz score:"; score%; "/ 6"
  COLOR 7
  PRINT "Plants make food from sunlight; every animal in the chain depends on them."
  PRINT "Press any key"
  junk$ = GetKey$
END SUB

SUB Chase
  CONST W = 60
  CONST H = 16
  DIM g%(1 TO W, 1 TO H), grow$(1 TO H)
  DIM cx%(1 TO 5), cy%(1 TO 5)
  CLS
  FOR i% = 1 TO 18
    gx% = 1 + INT(RND * W): gy% = 1 + INT(RND * H)
    FOR a% = 0 TO 2
      IF gx% + a% <= W THEN g%(gx% + a%, gy%) = 1
    NEXT a%
  NEXT i%
  FOR y% = 1 TO H
    grow$(y%) = STRING$(W, " ")
    FOR x% = 1 TO W
      IF g%(x%, y%) = 1 THEN MID$(grow$(y%), x%, 1) = "#"
    NEXT x%
  NEXT y%
  mx% = W \ 2: my% = H \ 2
  bx% = W: by% = H
  FOR i% = 1 TO 5
    cx%(i%) = 1 + INT(RND * W): cy%(i%) = 1 + INT(RND * H)
  NEXT i%
  eaten% = 0: tick% = 0: lost% = 0
  COLOR 14: LOCATE 1, 2: PRINT "CHASE: eat 10 cicadas (c). Hide in grass (#) from the oriole (B)!"
  COLOR 7: LOCATE 2, 2: PRINT "Arrows move the mantis (M).  ESC = back."
  LOCATE 4, 9: PRINT "+"; STRING$(W, "-"); "+"
  LOCATE 5 + H, 9: PRINT "+"; STRING$(W, "-"); "+"
  FOR y% = 1 TO H
    LOCATE 4 + y%, 9: PRINT "|"
    LOCATE 4 + y%, 10 + W: PRINT "|"
  NEXT y%
  DO
    tick% = tick% + 1
    lastk$ = ""
    DO
      k$ = INKEY$
      IF k$ <> "" THEN lastk$ = k$
    LOOP WHILE k$ <> ""
    IF lastk$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    END IF
    IF LEN(lastk$) = 2 THEN
      SELECT CASE RIGHT$(lastk$, 1)
        CASE "H": IF my% > 1 THEN my% = my% - 1
        CASE "P": IF my% < H THEN my% = my% + 1
        CASE "K": IF mx% > 1 THEN mx% = mx% - 1
        CASE "M": IF mx% < W THEN mx% = mx% + 1
      END SELECT
    END IF
    ' eating: the mantis is a predator, the cicada is its prey
    FOR i% = 1 TO 5
      IF cx%(i%) = mx% AND cy%(i%) = my% THEN
        eaten% = eaten% + 1
        cx%(i%) = 1 + INT(RND * W): cy%(i%) = 1 + INT(RND * H)
        BEEP
      END IF
      IF tick% MOD 3 = 0 THEN
        cx%(i%) = cx%(i%) + INT(RND * 3) - 1
        cy%(i%) = cy%(i%) + INT(RND * 3) - 1
        IF cx%(i%) < 1 THEN cx%(i%) = 1
        IF cx%(i%) > W THEN cx%(i%) = W
        IF cy%(i%) < 1 THEN cy%(i%) = 1
        IF cy%(i%) > H THEN cy%(i%) = H
      END IF
    NEXT i%
    ' the oriole hunts the mantis, but cannot see it in tall grass
    IF tick% > 20 AND tick% MOD 2 = 0 THEN
      IF g%(mx%, my%) = 1 THEN
        bx% = bx% + INT(RND * 3) - 1
        by% = by% + INT(RND * 3) - 1
      ELSEIF ABS(mx% - bx%) >= ABS(my% - by%) THEN
        bx% = bx% + SGN(mx% - bx%)
      ELSE
        by% = by% + SGN(my% - by%)
      END IF
      IF bx% < 1 THEN bx% = 1
      IF bx% > W THEN bx% = W
      IF by% < 1 THEN by% = 1
      IF by% > H THEN by% = H
    END IF
    IF bx% = mx% AND by% = my% AND g%(mx%, my%) = 0 THEN lost% = 1
    COLOR 2
    FOR y% = 1 TO H
      LOCATE 4 + y%, 10: PRINT grow$(y%);
    NEXT y%
    COLOR 14
    FOR i% = 1 TO 5
      LOCATE 4 + cy%(i%), 9 + cx%(i%): PRINT "c";
    NEXT i%
    COLOR 12: LOCATE 4 + by%, 9 + bx%: PRINT "B";
    COLOR 15: LOCATE 4 + my%, 9 + mx%: PRINT "M";
    COLOR 7
    LOCATE 22, 2: PRINT "Cicadas eaten:"; eaten%; "/ 10     ";
    IF g%(mx%, my%) = 1 THEN PRINT "(hidden in grass)  "; ELSE PRINT "                  ";
    CALL Delay(.12)
  LOOP UNTIL eaten% >= 10 OR lost% = 1
  LOCATE 24, 2
  IF lost% = 1 THEN
    COLOR 12: PRINT "The oriole got the mantis! The one behind you is the next link in the chain.";
  ELSE
    COLOR 10: PRINT "You ate 10 cicadas and stayed safe. Predators have predators too.";
  END IF
  COLOR 7
  junk$ = GetKey$
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

FUNCTION DietStr$ (q%)
  ' animal|diet  (1 plant eater, 2 meat eater, 3 eats both)
  SELECT CASE q%
    CASE 1: DietStr$ = "Cow|1"
    CASE 2: DietStr$ = "Lion|2"
    CASE 3: DietStr$ = "Pig|3"
    CASE 4: DietStr$ = "Cicada (sucks plant sap)|1"
    CASE 5: DietStr$ = "Praying mantis (eats insects)|2"
    CASE 6: DietStr$ = "Bear|3"
    CASE 7: DietStr$ = "Rabbit|1"
    CASE 8: DietStr$ = "Frog (eats insects)|2"
    CASE 9: DietStr$ = "Crow|3"
    CASE ELSE: DietStr$ = "Panda (mostly bamboo)|1"
  END SELECT
END FUNCTION

SUB DietQuiz
  score% = 0
  FOR q% = 1 TO 10
    s$ = DietStr$(q%)
    CLS
    COLOR 14: PRINT "FEEDING-HABIT QUIZ  question"; q%; "of 10"
    COLOR 15
    PRINT
    PRINT Part$(s$, 1)
    COLOR 7
    PRINT
    PRINT "  1 = herbivore (eats plants)"
    PRINT "  2 = carnivore (eats animals)"
    PRINT "  3 = omnivore (eats both)"
    DO
      k$ = GetKey$
    LOOP UNTIL k$ = "1" OR k$ = "2" OR k$ = "3" OR k$ = CHR$(27)
    IF k$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    END IF
    PRINT
    IF k$ = Part$(s$, 2) THEN
      COLOR 10: PRINT "Correct!"
      score% = score% + 1
    ELSE
      COLOR 12: PRINT "No. The answer is"; Part$(s$, 2)
    END IF
    COLOR 7
    PRINT "Press any key"
    junk$ = GetKey$
  NEXT q%
  CLS
  COLOR 14: PRINT "Feeding-habit score:"; score%; "/ 10"
  COLOR 7
  PRINT "Teeth and digestion match the diet: grinders for plants, sharp teeth for meat."
  PRINT "Press any key"
  junk$ = GetKey$
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

FUNCTION Part$ (s$, n%)
  ' n-th field of a string separated by |
  st% = 1
  FOR i% = 1 TO n% - 1
    p% = INSTR(st%, s$, "|")
    IF p% = 0 THEN
      Part$ = ""
      EXIT FUNCTION
    END IF
    st% = p% + 1
  NEXT i%
  e% = INSTR(st%, s$, "|")
  IF e% = 0 THEN
    Part$ = MID$(s$, st%)
  ELSE
    Part$ = MID$(s$, st%, e% - st%)
  END IF
END FUNCTION

SUB Title
  CLS
  COLOR 14: LOCATE 3, 20: PRINT "G26  MANTIS & CICADA  (TANG LANG BU CHAN)"
  COLOR 15
  LOCATE 6, 8: PRINT "An old proverb: the mantis stalks the cicada,"
  LOCATE 7, 8: PRINT "not seeing the oriole behind it."
  COLOR 7
  LOCATE 9, 8: PRINT "It is a FOOD CHAIN:  plant -> cicada -> mantis -> oriole"
  LOCATE 10, 8: PRINT "Arrows point from the food to the animal that eats it."
  LOCATE 12, 8: PRINT "Herbivores eat plants, carnivores eat animals, omnivores eat both."
  LOCATE 13, 8: PRINT "Every animal is food for something, and also needs food itself."
  COLOR 10
  LOCATE 16, 8: PRINT "Play two quizzes, then the chase game: be a hunter and be hunted!"
  COLOR 15
  LOCATE 20, 8: PRINT "Press any key";
  junk$ = GetKey$
END SUB
