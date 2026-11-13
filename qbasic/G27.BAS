' G27.BAS - Animal ID (DONG WU SHI BIE)
' Educational content (1991 list): identify animals by their features (legs, body cover,
'   how babies are born, where they live, what they eat, whether they fly).
' Menu: 1 = think of an animal, the computer asks yes/no questions and guesses it
'       2 = clues are shown, you pick the animal from four choices
'       ESC = back to the main menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION Part$ (s$, n%)
DECLARE FUNCTION AnimalStr$ (i%)
DECLARE FUNCTION Has% (a%, q%)
DECLARE FUNCTION QText$ (q%)
DECLARE FUNCTION Clue$ (a%, f%)
DECLARE FUNCTION YesNo% ()
DECLARE SUB Title ()
DECLARE SUB GuessMode ()
DECLARE SUB ClueMode ()
DECLARE SUB Describe (a%)

CONST NA = 20
CONST NQ = 14
DIM SHARED nm$(1 TO NA), f$(1 TO NA, 1 TO 6)
DIM SHARED quit%

RANDOMIZE TIMER
SCREEN 0
WIDTH 80
FOR i% = 1 TO NA
  s$ = AnimalStr$(i%)
  nm$(i%) = Part$(s$, 1)
  FOR j% = 1 TO 6
    f$(i%, j%) = Part$(s$, j% + 1)
  NEXT j%
NEXT i%
CALL Title
DO
  COLOR 7, 0
  CLS
  COLOR 14: LOCATE 3, 25: PRINT "G27  ANIMAL ID  (DONG WU SHI BIE)"
  COLOR 15
  LOCATE 7, 15: PRINT "1  Think of an animal - I will guess it"
  LOCATE 9, 15: PRINT "2  Read the clues - you identify the animal"
  LOCATE 11, 15: PRINT "ESC  Back to the main menu"
  COLOR 7
  k$ = GetKey$
  SELECT CASE k$
    CASE "1"
      CALL GuessMode
    CASE "2"
      CALL ClueMode
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

FUNCTION AnimalStr$ (i%)
  ' name|legs|cover|birth|home|diet|fly
  ' cover: F fur K feathers S scales H hard shell/body B bare skin
  ' birth: E eggs L live  home: L land W water B both  diet: H plants C animals O both
  SELECT CASE i%
    CASE 1: AnimalStr$ = "Dog|4|F|L|L|O|N"
    CASE 2: AnimalStr$ = "Cat|4|F|L|L|C|N"
    CASE 3: AnimalStr$ = "Cow|4|F|L|L|H|N"
    CASE 4: AnimalStr$ = "Pig|4|B|L|L|O|N"
    CASE 5: AnimalStr$ = "Elephant|4|B|L|L|H|N"
    CASE 6: AnimalStr$ = "Chicken|2|K|E|L|O|N"
    CASE 7: AnimalStr$ = "Duck|2|K|E|B|O|Y"
    CASE 8: AnimalStr$ = "Eagle|2|K|E|L|C|Y"
    CASE 9: AnimalStr$ = "Sparrow|2|K|E|L|O|Y"
    CASE 10: AnimalStr$ = "Penguin|2|K|E|B|C|N"
    CASE 11: AnimalStr$ = "Bat|2|F|L|L|C|Y"
    CASE 12: AnimalStr$ = "Frog|4|B|E|B|C|N"
    CASE 13: AnimalStr$ = "Snake|0|S|E|L|C|N"
    CASE 14: AnimalStr$ = "Goldfish|0|S|E|W|O|N"
    CASE 15: AnimalStr$ = "Crocodile|4|S|E|B|C|N"
    CASE 16: AnimalStr$ = "Turtle|4|H|E|B|O|N"
    CASE 17: AnimalStr$ = "Whale|0|B|L|W|C|N"
    CASE 18: AnimalStr$ = "Butterfly|6|H|E|L|H|Y"
    CASE 19: AnimalStr$ = "Ant|6|H|E|L|O|N"
    CASE ELSE: AnimalStr$ = "Spider|8|H|E|L|C|N"
  END SELECT
END FUNCTION

FUNCTION Clue$ (a%, f%)
  c$ = f$(a%, f%)
  SELECT CASE f%
    CASE 1
      IF c$ = "0" THEN
        Clue$ = "It has no legs."
      ELSE
        Clue$ = "It has " + c$ + " legs."
      END IF
    CASE 2
      SELECT CASE c$
        CASE "F": Clue$ = "Its body is covered with fur or hair."
        CASE "K": Clue$ = "Its body is covered with feathers."
        CASE "S": Clue$ = "Its body is covered with scales."
        CASE "H": Clue$ = "It has a hard shell or hard outer body."
        CASE ELSE: Clue$ = "Its skin is bare and smooth."
      END SELECT
    CASE 3
      IF c$ = "E" THEN Clue$ = "It hatches from an egg." ELSE Clue$ = "Its babies are born alive."
    CASE 4
      SELECT CASE c$
        CASE "L": Clue$ = "It lives on land."
        CASE "W": Clue$ = "It lives in water."
        CASE ELSE: Clue$ = "It lives on land and in water."
      END SELECT
    CASE 5
      SELECT CASE c$
        CASE "H": Clue$ = "It eats only plants."
        CASE "C": Clue$ = "It eats only animals."
        CASE ELSE: Clue$ = "It eats plants and animals."
      END SELECT
    CASE ELSE
      IF c$ = "Y" THEN Clue$ = "It can fly." ELSE Clue$ = "It cannot fly."
  END SELECT
END FUNCTION

SUB ClueMode
  DIM sh%(1 TO 6), opt%(1 TO 4)
  score% = 0
  FOR r% = 1 TO 8
    a% = 1 + INT(RND * NA)
    ' choose 4 of the 6 features to show
    FOR i% = 1 TO 6
      sh%(i%) = 0
    NEXT i%
    n% = 0
    DO WHILE n% < 4
      i% = 1 + INT(RND * 6)
      IF sh%(i%) = 0 THEN sh%(i%) = 1: n% = n% + 1
    LOOP
    ' options: the answer plus 3 animals that break at least one shown clue
    opt%(1) = a%
    m% = 1
    tries% = 0
    DO WHILE m% < 4 AND tries% < 500
      tries% = tries% + 1
      b% = 1 + INT(RND * NA)
      ok% = 1
      FOR j% = 1 TO m%
        IF opt%(j%) = b% THEN ok% = 0
      NEXT j%
      diff% = 0
      FOR i% = 1 TO 6
        IF sh%(i%) = 1 AND f$(b%, i%) <> f$(a%, i%) THEN diff% = 1
      NEXT i%
      IF diff% = 0 THEN ok% = 0
      IF ok% = 1 THEN m% = m% + 1: opt%(m%) = b%
    LOOP
    IF m% < 4 THEN GOTO NextRound
    FOR i% = 4 TO 2 STEP -1
      j% = 1 + INT(RND * i%)
      SWAP opt%(i%), opt%(j%)
    NEXT i%
    CLS
    COLOR 14: PRINT "WHICH ANIMAL?  round"; r%; "of 8"
    COLOR 15
    PRINT
    FOR i% = 1 TO 6
      IF sh%(i%) = 1 THEN PRINT "  - "; Clue$(a%, i%)
    NEXT i%
    COLOR 7
    PRINT
    FOR i% = 1 TO 4
      PRINT "  "; i%; ") "; nm$(opt%(i%))
    NEXT i%
    DO
      k$ = GetKey$
    LOOP UNTIL (k$ >= "1" AND k$ <= "4") OR k$ = CHR$(27)
    IF k$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    END IF
    PRINT
    IF opt%(VAL(k$)) = a% THEN
      COLOR 10: PRINT "Correct! It is the "; nm$(a%); "."
      score% = score% + 1
    ELSE
      COLOR 12: PRINT "No - it is the "; nm$(a%); "."
    END IF
    COLOR 7
    CALL Describe(a%)
    PRINT "Press any key"
    junk$ = GetKey$
NextRound:
  NEXT r%
  CLS
  COLOR 14: PRINT "Animal ID score:"; score%; "/ 8"
  COLOR 7
  PRINT "Scientists group animals by features: body cover, legs, how babies are born..."
  PRINT "Press any key"
  junk$ = GetKey$
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

SUB Describe (a%)
  FOR i% = 1 TO 6
    PRINT "    "; Clue$(a%, i%)
  NEXT i%
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB GuessMode
  DIM al%(1 TO NA), asked%(1 TO NQ)
  FOR i% = 1 TO NA
    al%(i%) = 1
  NEXT i%
  FOR i% = 1 TO NQ
    asked%(i%) = 0
  NEXT i%
  CLS
  COLOR 14: PRINT "Think of one of these animals (do not tell me!):"
  COLOR 7
  PRINT
  FOR i% = 1 TO NA
    PRINT nm$(i%); "  ";
  NEXT i%
  PRINT
  PRINT
  PRINT "Answer my questions with Y or N. Press any key when ready."
  junk$ = GetKey$
  IF junk$ = CHR$(27) THEN
    quit% = 1
    EXIT SUB
  END IF
  nq% = 0
  DO
    cnt% = 0
    FOR i% = 1 TO NA
      cnt% = cnt% + al%(i%)
    NEXT i%
    IF cnt% <= 1 THEN EXIT DO
    best% = 0
    bd% = 999
    FOR q% = 1 TO NQ
      IF asked%(q%) = 0 THEN
        yes% = 0
        FOR i% = 1 TO NA
          IF al%(i%) = 1 AND Has%(i%, q%) = 1 THEN yes% = yes% + 1
        NEXT i%
        IF yes% > 0 AND yes% < cnt% THEN
          d% = ABS(yes% * 2 - cnt%)
          IF d% < bd% THEN bd% = d%: best% = q%
        END IF
      END IF
    NEXT q%
    IF best% = 0 THEN EXIT DO
    nq% = nq% + 1
    asked%(best%) = 1
    PRINT
    PRINT "Question"; nq%; ": "; QText$(best%); " (Y/N)"
    ans% = YesNo%
    IF ans% = -1 THEN
      quit% = 1
      EXIT SUB
    END IF
    FOR i% = 1 TO NA
      IF al%(i%) = 1 THEN
        IF (Has%(i%, best%) = 1) <> (ans% = 1) THEN al%(i%) = 0
      END IF
    NEXT i%
    PRINT "   remaining possibilities:";
    c2% = 0
    FOR i% = 1 TO NA
      c2% = c2% + al%(i%)
    NEXT i%
    PRINT c2%
  LOOP
  g% = 0
  FOR i% = NA TO 1 STEP -1
    IF al%(i%) = 1 THEN g% = i%
  NEXT i%
  PRINT
  IF g% = 0 THEN
    COLOR 12: PRINT "No animal on my list fits your answers. Did you answer correctly?"
  ELSE
    COLOR 10: PRINT "I think it is the "; nm$(g%); "!  Am I right? (Y/N)"
    ans% = YesNo%
    IF ans% = -1 THEN
      quit% = 1
      EXIT SUB
    END IF
    IF ans% = 1 THEN
      PRINT "Great - features are enough to tell animals apart!"
    ELSE
      PRINT "Hmm, check your answers."
    END IF
    COLOR 7
    CALL Describe(g%)
  END IF
  COLOR 7
  PRINT "Press any key"
  junk$ = GetKey$
END SUB

FUNCTION Has% (a%, q%)
  r% = 0
  SELECT CASE q%
    CASE 1: IF f$(a%, 1) = "4" THEN r% = 1
    CASE 2: IF f$(a%, 1) = "2" THEN r% = 1
    CASE 3: IF f$(a%, 1) = "0" THEN r% = 1
    CASE 4: IF VAL(f$(a%, 1)) >= 6 THEN r% = 1
    CASE 5: IF f$(a%, 2) = "F" THEN r% = 1
    CASE 6: IF f$(a%, 2) = "K" THEN r% = 1
    CASE 7: IF f$(a%, 2) = "S" THEN r% = 1
    CASE 8: IF f$(a%, 2) = "H" THEN r% = 1
    CASE 9: IF f$(a%, 3) = "E" THEN r% = 1
    CASE 10: IF f$(a%, 4) = "L" THEN r% = 1
    CASE 11: IF f$(a%, 4) = "W" THEN r% = 1
    CASE 12: IF f$(a%, 6) = "Y" THEN r% = 1
    CASE 13: IF f$(a%, 5) = "H" THEN r% = 1
    CASE ELSE: IF f$(a%, 5) = "C" THEN r% = 1
  END SELECT
  Has% = r%
END FUNCTION

FUNCTION Part$ (s$, n%)
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

FUNCTION QText$ (q%)
  SELECT CASE q%
    CASE 1: QText$ = "Does it have 4 legs?"
    CASE 2: QText$ = "Does it have 2 legs?"
    CASE 3: QText$ = "Does it have no legs?"
    CASE 4: QText$ = "Does it have 6 or more legs?"
    CASE 5: QText$ = "Is its body covered with fur or hair?"
    CASE 6: QText$ = "Is its body covered with feathers?"
    CASE 7: QText$ = "Is its body covered with scales?"
    CASE 8: QText$ = "Does it have a hard shell or hard outer body?"
    CASE 9: QText$ = "Does it hatch from an egg?"
    CASE 10: QText$ = "Does it live only on land?"
    CASE 11: QText$ = "Does it live only in water?"
    CASE 12: QText$ = "Can it fly?"
    CASE 13: QText$ = "Does it eat only plants?"
    CASE ELSE: QText$ = "Does it eat only animals?"
  END SELECT
END FUNCTION

SUB Title
  CLS
  COLOR 14: LOCATE 3, 25: PRINT "G27  ANIMAL ID  (DONG WU SHI BIE)"
  COLOR 15
  LOCATE 6, 8: PRINT "How do we tell one animal from another? By its FEATURES:"
  COLOR 7
  LOCATE 8, 8: PRINT "  - how many legs it has        - what covers its body"
  LOCATE 9, 8: PRINT "  - eggs or live babies         - where it lives"
  LOCATE 10, 8: PRINT "  - what it eats                - whether it can fly"
  LOCATE 12, 8: PRINT "A bat has fur and feeds its babies milk, so it is a mammal, not a bird."
  LOCATE 13, 8: PRINT "A whale lives in water but breathes air and has live babies: a mammal."
  COLOR 10
  LOCATE 16, 8: PRINT "Mode 1: I guess your animal.   Mode 2: you guess from the clues."
  COLOR 15
  LOCATE 20, 8: PRINT "Press any key";
  junk$ = GetKey$
END SUB

FUNCTION YesNo%
  ' returns 1 for Y, 0 for N, -1 for ESC
  DO
    k$ = UCASE$(GetKey$)
  LOOP UNTIL k$ = "Y" OR k$ = "N" OR k$ = CHR$(27)
  IF k$ = "Y" THEN
    YesNo% = 1
  ELSEIF k$ = "N" THEN
    YesNo% = 0
  ELSE
    YesNo% = -1
  END IF
END FUNCTION
