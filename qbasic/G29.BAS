' G29.BAS - Memory 100 (JI YI 100)
' Educational content (1991 list): memory tests, and how the brain is built and what it does.
' Three tests: digit span (33 pts), card pairs (34 pts), light sequence (33 pts) = 100 points.
' Menu: 1 = take the memory test, 2 = tour of the brain, ESC = back to the main menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Title ()
DECLARE FUNCTION DigitTest% ()
DECLARE FUNCTION PairTest% ()
DECLARE FUNCTION SeqTest% ()
DECLARE SUB DrawPairs ()
DECLARE SUB Flash (b%, lit%)
DECLARE SUB BrainTour ()
DECLARE SUB BrainText (n%)

DIM SHARED sym$(1 TO 16), st%(1 TO 16)
DIM SHARED quit%
CONST LABELS = "123456789ABCDEFG"

RANDOMIZE TIMER
SCREEN 0
WIDTH 80
CALL Title
DO
  COLOR 7, 0
  CLS
  COLOR 14: LOCATE 3, 25: PRINT "G29  MEMORY 100  (JI YI 100)"
  COLOR 15
  LOCATE 7, 20: PRINT "1  Memory test (100 points)"
  LOCATE 9, 20: PRINT "2  Tour of the brain"
  LOCATE 11, 20: PRINT "ESC  Back to the main menu"
  COLOR 7
  k$ = GetKey$
  SELECT CASE k$
    CASE "1"
      d% = DigitTest%
      IF quit% = 0 THEN p% = PairTest%
      IF quit% = 0 THEN s% = SeqTest%
      IF quit% = 0 THEN
        tot% = d% + p% + s%
        CLS
        COLOR 14: LOCATE 3, 28: PRINT "YOUR MEMORY SCORE"
        COLOR 15
        LOCATE 6, 20: PRINT "Digit memory   :"; d%; "/ 33"
        LOCATE 7, 20: PRINT "Card pairs     :"; p%; "/ 34"
        LOCATE 8, 20: PRINT "Light sequence :"; s%; "/ 33"
        COLOR 14
        LOCATE 10, 20: PRINT "TOTAL          :"; tot%; "/ 100"
        COLOR 10
        LOCATE 12, 20
        IF tot% >= 85 THEN
          PRINT "Excellent memory!"
        ELSEIF tot% >= 65 THEN
          PRINT "Good memory."
        ELSEIF tot% >= 40 THEN
          PRINT "Average. Practice helps!"
        ELSE
          PRINT "Keep training - memory is like a muscle."
        END IF
        COLOR 7
        LOCATE 14, 12: PRINT "Tips: group digits into chunks, repeat aloud, link items to pictures,"
        LOCATE 15, 12: PRINT "and sleep well - sleep helps the hippocampus store new memories."
        LOCATE 18, 12: PRINT "Press any key";
        junk$ = GetKey$
      END IF
    CASE "2"
      CALL BrainTour
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

SUB BrainText (n%)
  FOR r% = 14 TO 23
    LOCATE r%, 1: PRINT SPACE$(79);
  NEXT r%
  COLOR 14
  LOCATE 14, 4
  SELECT CASE n%
    CASE 1
      PRINT "FRONTAL LOBE";
      COLOR 7
      LOCATE 16, 4: PRINT "Planning, decisions, speaking, and controlling behavior."
      LOCATE 17, 4: PRINT "It is the thinking and personality centre."
    CASE 2
      PRINT "PARIETAL LOBE";
      COLOR 7
      LOCATE 16, 4: PRINT "Feels touch, pain and temperature, and knows where the body is."
    CASE 3
      PRINT "TEMPORAL LOBE";
      COLOR 7
      LOCATE 16, 4: PRINT "Hearing, understanding language, and storing memories."
    CASE 4
      PRINT "OCCIPITAL LOBE";
      COLOR 7
      LOCATE 16, 4: PRINT "Vision: it turns what the eyes send into pictures we understand."
    CASE 5
      PRINT "CEREBELLUM";
      COLOR 7
      LOCATE 16, 4: PRINT "Balance and smooth, coordinated movement (riding a bicycle)."
    CASE 6
      PRINT "BRAIN STEM";
      COLOR 7
      LOCATE 16, 4: PRINT "Controls breathing, heartbeat and sleep - things we do without thinking."
      LOCATE 17, 4: PRINT "It links the brain to the spinal cord."
    CASE ELSE
      PRINT "HIPPOCAMPUS";
      COLOR 7
      LOCATE 16, 4: PRINT "A seahorse-shaped part deep in the temporal lobe."
      LOCATE 17, 4: PRINT "It turns short-term memory into long-term memory."
  END SELECT
  COLOR 7
END SUB

SUB BrainTour
  CLS
  COLOR 14: LOCATE 1, 2: PRINT "THE BRAIN  (side view, front is on the left)"
  COLOR 7
  LOCATE 3, 4: PRINT "The CEREBRUM is the big part: it thinks, remembers and senses."
  LOCATE 5, 4: PRINT "+--------------+--------------+--------------+"
  LOCATE 6, 4: PRINT "|  1 FRONTAL   |  2 PARIETAL  | 4 OCCIPITAL  |"
  LOCATE 7, 4: PRINT "+--------------+--------------+--------------+"
  LOCATE 8, 4: PRINT "   |  3 TEMPORAL (7 hippocampus inside)  |   +-------------+"
  LOCATE 9, 4: PRINT "   +--------------------------------------+   | 5 CEREBELLUM|"
  LOCATE 10, 4: PRINT "          | 6 BRAIN STEM |                    +-------------+"
  LOCATE 11, 4: PRINT "          +--------------+"
  COLOR 10
  LOCATE 12, 4: PRINT "Press 1-7 to learn about a part.  ESC = back."
  COLOR 7
  DO
    k$ = GetKey$
    IF k$ = CHR$(27) THEN EXIT DO
    IF k$ >= "1" AND k$ <= "7" THEN CALL BrainText(VAL(k$))
  LOOP
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

FUNCTION DigitTest%
  best% = 2
  L% = 3
  DO
    n$ = ""
    FOR i% = 1 TO L%
      n$ = n$ + CHR$(48 + INT(RND * 10))
    NEXT i%
    CLS
    COLOR 14: LOCATE 2, 2: PRINT "TEST 1: DIGIT MEMORY   (length"; L%; ")"
    COLOR 7
    LOCATE 4, 2: PRINT "Remember the number. It will disappear!"
    COLOR 15
    LOCATE 12, 36: PRINT n$
    CALL Delay(.5 + .4 * L%)
    CLS
    COLOR 7
    LOCATE 8, 2
    LINE INPUT "What was the number? "; a$
    IF a$ = n$ THEN
      best% = L%
      COLOR 10: PRINT "Correct!"
      L% = L% + 1
      CALL Delay(.8)
    ELSE
      COLOR 12: PRINT "It was "; n$
      CALL Delay(1.5)
      EXIT DO
    END IF
  LOOP UNTIL L% > 9
  COLOR 7
  DigitTest% = INT(33 * (best% - 2) / 7)
END FUNCTION

SUB DrawPairs
  LOCATE 4, 2: COLOR 7: PRINT "Find the 8 matching pairs. Press the key shown on a card to flip it."
  FOR i% = 1 TO 16
    r% = 7 + ((i% - 1) \ 4) * 3
    c% = 20 + ((i% - 1) MOD 4) * 10
    LOCATE r%, c%
    IF st%(i%) = 1 THEN
      COLOR 10: PRINT "[ "; sym$(i%); " ]";
    ELSEIF st%(i%) = 2 THEN
      COLOR 14: PRINT "[ "; sym$(i%); " ]";
    ELSE
      COLOR 7: PRINT "[ "; MID$(LABELS, i%, 1); " ]";
    END IF
  NEXT i%
  COLOR 7
END SUB

SUB Flash (b%, lit%)
  LOCATE 12, 10 + b% * 12
  IF lit% = 1 THEN
    COLOR 15, b%
    PRINT "   "; b%; "   ";
  ELSE
    COLOR b% + 8, 0
    PRINT "[  "; b%; "  ]";
  END IF
  COLOR 7, 0
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

FUNCTION PairTest%
  CLS
  COLOR 14: LOCATE 2, 2: PRINT "TEST 2: CARD PAIRS"
  s$ = "!@#$%&*+"
  FOR i% = 1 TO 16
    sym$(i%) = MID$(s$, (i% - 1) \ 2 + 1, 1)
    st%(i%) = 0
  NEXT i%
  FOR i% = 16 TO 2 STEP -1
    j% = 1 + INT(RND * i%)
    SWAP sym$(i%), sym$(j%)
  NEXT i%
  matched% = 0
  tries% = 0
  DO WHILE matched% < 8
    CALL DrawPairs
    DO
      k$ = UCASE$(GetKey$)
      IF k$ = CHR$(27) THEN
        quit% = 1
        PairTest% = 0
        EXIT FUNCTION
      END IF
      a% = INSTR(LABELS, k$)
    LOOP UNTIL a% > 0 AND k$ <> "" AND st%(a%) = 0
    st%(a%) = 2
    CALL DrawPairs
    DO
      k$ = UCASE$(GetKey$)
      IF k$ = CHR$(27) THEN
        quit% = 1
        PairTest% = 0
        EXIT FUNCTION
      END IF
      b% = INSTR(LABELS, k$)
    LOOP UNTIL b% > 0 AND k$ <> "" AND st%(b%) = 0
    st%(b%) = 2
    CALL DrawPairs
    tries% = tries% + 1
    IF sym$(a%) = sym$(b%) THEN
      st%(a%) = 1: st%(b%) = 1
      matched% = matched% + 1
    ELSE
      CALL Delay(1.3)
      st%(a%) = 0: st%(b%) = 0
    END IF
  LOOP
  CALL DrawPairs
  LOCATE 21, 2: PRINT "All pairs found in"; tries%; "tries (best possible is 8).";
  CALL Delay(2)
  p% = 34 - (tries% - 8) * 3
  IF p% < 0 THEN p% = 0
  PairTest% = p%
END FUNCTION

FUNCTION SeqTest%
  DIM sq%(1 TO 10)
  best% = 0
  FOR n% = 1 TO 10
    sq%(n%) = 1 + INT(RND * 4)
    CLS
    COLOR 14: LOCATE 2, 2: PRINT "TEST 3: LIGHT SEQUENCE   (length"; n%; ")"
    COLOR 7
    LOCATE 4, 2: PRINT "Watch the lights, then repeat the order with keys 1 2 3 4."
    FOR b% = 1 TO 4
      CALL Flash(b%, 0)
    NEXT b%
    CALL Delay(1)
    FOR i% = 1 TO n%
      CALL Flash(sq%(i%), 1)
      CALL Delay(.6)
      CALL Flash(sq%(i%), 0)
      CALL Delay(.25)
    NEXT i%
    LOCATE 15, 2: PRINT "Your turn:";
    ok% = 1
    FOR i% = 1 TO n%
      DO
        k$ = GetKey$
        IF k$ = CHR$(27) THEN
          quit% = 1
          SeqTest% = 0
          EXIT FUNCTION
        END IF
      LOOP UNTIL k$ >= "1" AND k$ <= "4"
      PRINT " "; k$;
      IF VAL(k$) <> sq%(i%) THEN
        ok% = 0
        EXIT FOR
      END IF
    NEXT i%
    IF ok% = 1 THEN
      best% = n%
      LOCATE 17, 2: COLOR 10: PRINT "Correct!"
      COLOR 7
      CALL Delay(.8)
    ELSE
      LOCATE 17, 2: COLOR 12: PRINT "Wrong - the game ends here."
      COLOR 7
      CALL Delay(1.5)
      EXIT FOR
    END IF
  NEXT n%
  SeqTest% = INT(33 * best% / 10)
END FUNCTION

SUB Title
  CLS
  COLOR 14: LOCATE 3, 28: PRINT "G29  MEMORY 100  (JI YI 100)"
  COLOR 15
  LOCATE 6, 8: PRINT "How good is your memory? Three short tests add up to 100 points:"
  COLOR 7
  LOCATE 8, 8: PRINT "  1. Digit memory  - remember a number that grows longer"
  LOCATE 9, 8: PRINT "  2. Card pairs    - find 8 matching pairs in as few tries as you can"
  LOCATE 10, 8: PRINT "  3. Light sequence - repeat a growing pattern of lights"
  LOCATE 12, 8: PRINT "Then take the tour of the brain: where memory lives, and what the"
  LOCATE 13, 8: PRINT "other parts of the brain do."
  COLOR 15
  LOCATE 20, 8: PRINT "Press any key";
  junk$ = GetKey$
END SUB
