' G15.BAS - Binary Numbers (ER JIN WEI ZHI)
' Educational content (1991 list): the binary number system, shown with the mind-reading cards.
' Controls: menu 1 = mind reader cards, 2 = decimal/binary quiz, 3 = light switches,
'   Y/N answer the cards, 1-6 toggle lamps, ESC = back / menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (r%, c%, mx%)
DECLARE SUB Title ()
DECLARE SUB Msg (t$)
DECLARE SUB DrawCard (k%)
DECLARE SUB DrawLamps (v%)
DECLARE SUB Telepathy ()
DECLARE SUB Quiz ()
DECLARE SUB Switches ()
DECLARE FUNCTION BinVal% (s$)
DECLARE FUNCTION BinStr$ (n%)
DECLARE FUNCTION Expand$ (n%)

DIM SHARED p%(0 TO 5)
DIM SHARED tot%, quit%
RANDOMIZE TIMER
SCREEN 12
FOR i% = 0 TO 5
  p%(i%) = 2 ^ i%
NEXT i%
tot% = 0
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
DO
  CLS
  COLOR 14
  LOCATE 3, 20: PRINT "G15 BINARY NUMBERS - choose a game"
  COLOR 15
  LOCATE 6, 10: PRINT "1  Mind reader: six cards guess your number (1-63)"
  LOCATE 8, 10: PRINT "2  Quiz: decimal <-> binary (10 questions)"
  LOCATE 10, 10: PRINT "3  Light switches: set the lamps to show a number"
  COLOR 10
  LOCATE 13, 10: PRINT "Total score:"; tot%
  COLOR 7
  LOCATE 30, 1: PRINT "Press 1, 2 or 3.   ESC = menu";
  k$ = GetKey$
  IF k$ = CHR$(27) THEN
    EXIT DO
  ELSEIF k$ = "1" THEN
    CALL Telepathy
  ELSEIF k$ = "2" THEN
    CALL Quiz
  ELSEIF k$ = "3" THEN
    CALL Switches
  END IF
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

FUNCTION BinStr$ (n%)
  s$ = ""
  FOR k% = 5 TO 0 STEP -1
    IF (n% AND p%(k%)) <> 0 THEN s$ = s$ + "1" ELSE s$ = s$ + "0"
  NEXT k%
  BinStr$ = s$
END FUNCTION

' Returns the value of a string of 0/1 characters, or -1 if it is not a binary number.
FUNCTION BinVal% (s$)
  t$ = LTRIM$(RTRIM$(s$))
  v% = 0
  IF LEN(t$) = 0 OR LEN(t$) > 8 THEN v% = -1
  FOR i% = 1 TO LEN(t$)
    c$ = MID$(t$, i%, 1)
    IF v% >= 0 THEN
      IF c$ = "0" OR c$ = "1" THEN
        v% = v% * 2 + VAL(c$)
      ELSE
        v% = -1
      END IF
    END IF
  NEXT i%
  BinVal% = v%
END FUNCTION

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

' One mind-reader card: all numbers 1..63 whose binary digit k is 1 (32 numbers).
SUB DrawCard (k%)
  CLS
  COLOR 14
  LOCATE 2, 1: PRINT "Card"; k% + 1; "of 6  -  first number ="; p%(k%)
  LINE (72, 64)-(500, 208), 11, B
  cnt% = 0
  FOR n% = 1 TO 63
    IF (n% AND p%(k%)) <> 0 THEN
      IF cnt% = 0 THEN COLOR 14 ELSE COLOR 15
      LOCATE 6 + (cnt% \ 8) * 2, 12 + (cnt% MOD 8) * 6
      PRINT RIGHT$("  " + LTRIM$(STR$(n%)), 2);
      cnt% = cnt% + 1
    END IF
  NEXT n%
  COLOR 7
  LOCATE 16, 3: PRINT "Every number here has a 1 in the"; p%(k%); "place of its binary form."
END SUB

' Six lamps, weights 32 16 8 4 2 1 from left to right. Lit lamp = binary digit 1.
SUB DrawLamps (v%)
  FOR i% = 0 TO 5
    b% = 5 - i%
    x% = 200 + i% * 60
    IF (v% AND p%(b%)) <> 0 THEN col% = 14 ELSE col% = 8
    LINE (x%, 320)-(x% + 40, 352), col%, BF
    COLOR 11
    LOCATE 19, x% \ 8 + 2
    PRINT RIGHT$("  " + LTRIM$(STR$(p%(b%))), 2);
    COLOR 15
    LOCATE 24, x% \ 8 + 3
    IF (v% AND p%(b%)) <> 0 THEN
      PRINT "1";
    ELSE
      PRINT "0";
    END IF
  NEXT i%
END SUB

' Writes n as a sum of powers of two, e.g. "21 = 16 + 4 + 1".
FUNCTION Expand$ (n%)
  s$ = ""
  FOR k% = 5 TO 0 STEP -1
    IF (n% AND p%(k%)) <> 0 THEN s$ = s$ + " + " + LTRIM$(STR$(p%(k%)))
  NEXT k%
  IF LEN(s$) >= 3 THEN s$ = MID$(s$, 4)
  Expand$ = LTRIM$(STR$(n%)) + " = " + s$
END FUNCTION

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB Msg (t$)
  LOCATE 28, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

SUB Quiz
  sc% = 0
  FOR q% = 1 TO 10
    n% = INT(RND * 63) + 1
    CLS
    COLOR 14
    LOCATE 1, 1: PRINT "Quiz"; q%; "/ 10     score"; sc%
    COLOR 15
    IF q% MOD 2 = 1 THEN
      LOCATE 5, 5: PRINT "Write the decimal number"; n%; "in binary (0s and 1s):"
      a$ = ReadLine$(8, 5, 8)
      IF a$ = CHR$(27) THEN EXIT SUB
      good% = 0
      IF BinVal%(a$) = n% THEN good% = 1
    ELSE
      LOCATE 5, 5: PRINT "These lamps show a binary number. What is it in decimal?"
      CALL DrawLamps(n%)
      a$ = ReadLine$(8, 5, 8)
      IF a$ = CHR$(27) THEN EXIT SUB
      good% = 0
      IF VAL(a$) = n% THEN good% = 1
    END IF
    LOCATE 10, 5
    IF good% <> 0 THEN
      COLOR 10
      PRINT "Correct! +10   "; Expand$(n%); "  =  "; BinStr$(n%)
      sc% = sc% + 10
    ELSE
      COLOR 12
      PRINT "Not quite.  "; Expand$(n%); "  =  "; BinStr$(n%)
    END IF
    COLOR 7
    LOCATE 30, 1: PRINT "Any key = next, ESC = back";
    k$ = GetKey$
    IF k$ = CHR$(27) THEN EXIT FOR
  NEXT q%
  tot% = tot% + sc%
  CLS
  COLOR 14
  LOCATE 8, 10: PRINT "Quiz finished. Score this round:"; sc%; "of 100"
  COLOR 7
  LOCATE 30, 1: PRINT "Any key = back";
  k$ = GetKey$
END SUB

SUB Switches
  sc% = 0
  FOR rd% = 1 TO 5
    t% = INT(RND * 63) + 1
    cur% = 0
    presses% = 0
    minp% = 0
    FOR i% = 0 TO 5
      IF (t% AND p%(i%)) <> 0 THEN minp% = minp% + 1
    NEXT i%
    DO
      CLS
      COLOR 14
      LOCATE 1, 1: PRINT "Switches: round"; rd%; "/ 5    score"; sc%
      COLOR 15
      LOCATE 4, 5: PRINT "Make the lamps show the number"; t%
      LOCATE 6, 5: PRINT "Keys 1-6 flip the lamps from left (32) to right (1)."
      LOCATE 8, 5: PRINT "Your lamps now show"; cur%; " = "; BinStr$(cur%)
      CALL DrawLamps(cur%)
      COLOR 7
      LOCATE 30, 1: PRINT "1-6 flip lamp   ESC = back";
      IF cur% = t% THEN EXIT DO
      k$ = GetKey$
      IF k$ = CHR$(27) THEN EXIT SUB
      IF k$ >= "1" AND k$ <= "6" THEN
        cur% = cur% XOR p%(6 - VAL(k$))
        presses% = presses% + 1
      END IF
    LOOP
    pts% = 10 - (presses% - minp%)
    IF pts% < 1 THEN pts% = 1
    sc% = sc% + pts%
    mm$ = Expand$(t%) + "   +" + LTRIM$(STR$(pts%)) + " points (fewest flips ="
    CALL Msg(mm$ + STR$(minp%) + "). Any key")
    k$ = GetKey$
    IF k$ = CHR$(27) THEN EXIT FOR
  NEXT rd%
  tot% = tot% + sc%
  CLS
  COLOR 14
  LOCATE 8, 10: PRINT "Switches finished. Score this round:"; sc%
  COLOR 7
  LOCATE 30, 1: PRINT "Any key = back";
  k$ = GetKey$
END SUB

' Mind reader: the player answers yes/no for each card; yes adds the card's first number.
SUB Telepathy
  CLS
  COLOR 14
  LOCATE 4, 10: PRINT "MIND READER"
  COLOR 15
  LOCATE 7, 10: PRINT "Think of a number from 1 to 63. Do not tell me."
  LOCATE 9, 10: PRINT "I will show six cards. Say whether your number is on each card."
  COLOR 7
  LOCATE 30, 1: PRINT "Any key = start, ESC = back";
  k$ = GetKey$
  IF k$ = CHR$(27) THEN EXIT SUB
  v% = 0
  FOR k% = 0 TO 5
    CALL DrawCard(k%)
    CALL Msg("Is your number on this card?   Y = yes   N = no   ESC = back")
    DO
      a$ = UCASE$(GetKey$)
    LOOP UNTIL a$ = "Y" OR a$ = "N" OR a$ = CHR$(27)
    IF a$ = CHR$(27) THEN EXIT SUB
    IF a$ = "Y" THEN v% = v% + p%(k%)
  NEXT k%
  CLS
  COLOR 14
  LOCATE 3, 10: PRINT "I know it!"
  COLOR 15
  IF v% = 0 THEN
    LOCATE 6, 10: PRINT "You said NO to every card, so the number is 0 (not in 1-63)."
  ELSE
    LOCATE 6, 10: PRINT "Your number is"; v%
    LOCATE 8, 10: PRINT "Add the first numbers of the cards you said YES to:"
    LOCATE 10, 10: PRINT Expand$(v%)
    LOCATE 12, 10: PRINT "In binary: "; BinStr$(v%)
  END IF
  CALL DrawLamps(v%)
  COLOR 7
  LOCATE 16, 2: PRINT "Card k starts with 2^k (1,2,4,8,16,32). The cards are the six binary digits:"
  LOCATE 17, 2: PRINT "a number is on a card exactly when that binary digit is 1 (lamp ON)."
  LOCATE 30, 1: PRINT "Any key = back";
  k$ = GetKey$
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

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 20: PRINT "G15  BINARY NUMBERS  (ER JIN WEI ZHI)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "The BINARY system: computers count with only 0 and 1. Every number is a"
  LOCATE 8, 6: PRINT "sum of powers of two: 1, 2, 4, 8, 16, 32 ...  (21 = 16 + 4 + 1 = 10101)."
  LOCATE 9, 6: PRINT "Six cards starting with 1,2,4,8,16,32 can read any mind from 1 to 63."
  COLOR 7
  LOCATE 12, 6: PRINT "Games:"
  LOCATE 13, 6: PRINT "1 = mind reader cards (answer Y or N for each card)"
  LOCATE 14, 6: PRINT "2 = quiz: decimal to binary and binary lamps to decimal"
  LOCATE 15, 6: PRINT "3 = light switches: keys 1-6 flip lamps to make a target number"
  LOCATE 16, 6: PRINT "ESC = back (to menu from the game list)"
  COLOR 10
  LOCATE 18, 6: PRINT "Scoring: quiz 10 per correct answer, switches up to 10 per round."
  COLOR 14
  LOCATE 22, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB
