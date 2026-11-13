' G03.BAS - Chickens & Rabbits (JI TU TONG LONG)
' Educational content: solving puzzles with the four arithmetic operations
' (assume all are chickens; the extra feet / 2 = number of rabbits).
' Controls: type numbers and press Enter, any key to continue, ESC = menu.
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (maxlen%)
DECLARE FUNCTION AskNum% (prompt$, rw%)
DECLARE SUB Frame (q%)
DECLARE SUB DrawCage (c%, r%)
DECLARE SUB ShowStep (n%, s$)
DECLARE SUB Msg (s$, c%)

DIM SHARED quit%, score%
RANDOMIZE TIMER
SCREEN 12
CLS
COLOR 14
LOCATE 2, 1: PRINT "G03 Chickens & Rabbits (JI TU TONG LONG)"
COLOR 15
LOCATE 4, 1: PRINT "What you learn (1991 puzzle room): solving word problems with + - x /."
COLOR 7
LOCATE 6, 1: PRINT "A cage holds chickens (2 feet) and rabbits (4 feet)."
LOCATE 7, 1: PRINT "You are told the number of HEADS and FEET.  How many of each?"
LOCATE 8, 1: PRINT "If you are wrong, the computer shows the classic method:"
LOCATE 9, 1: PRINT "   1. Suppose every animal is a chicken: feet = 2 x heads."
LOCATE 10, 1: PRINT "   2. Extra feet = real feet - 2 x heads."
LOCATE 11, 1: PRINT "   3. Each rabbit has 2 more feet, so rabbits = extra feet / 2."
LOCATE 12, 1: PRINT "   4. Chickens = heads - rabbits."
LOCATE 14, 1: PRINT "10 cage questions + 3 shopping/ticket problems.  10 points each."
LOCATE 16, 1: PRINT "Type a number and press Enter.   ESC = menu"
COLOR 11
LOCATE 18, 1: PRINT "Press any key to start"
k$ = GetKey$
IF k$ = CHR$(27) THEN GOTO ExitGame

score% = 0
FOR q% = 1 TO 13
  IF q% <= 10 THEN
    c% = INT(RND * 9) + 1
    r% = INT(RND * 9) + 1
    h% = c% + r%
    f% = 2 * c% + 4 * r%
    CALL Frame(q%)
    CALL DrawCage(0, 0)
    LOCATE 5, 1: PRINT "A cage holds chickens and rabbits."
    LOCATE 6, 1: PRINT "There are"; h%; "heads and"; f%; "feet."
    DO
      a1% = AskNum%("How many chickens? ", 9)
      IF quit% THEN GOTO ExitGame
    LOOP UNTIL a1% >= 0
    DO
      a2% = AskNum%("How many rabbits?  ", 10)
      IF quit% THEN GOTO ExitGame
    LOOP UNTIL a2% >= 0
    CALL DrawCage(c%, r%)
    IF a1% = c% AND a2% = r% THEN
      score% = score% + 10
      CALL Msg("Correct! " + STR$(c%) + " chickens and" + STR$(r%) + " rabbits. +10", 10)
    ELSE
      CALL Msg("Not quite.  Let us solve it step by step (press a key).", 12)
      k$ = GetKey$
      IF k$ = CHR$(27) THEN GOTO ExitGame
      e% = f% - 2 * h%
      CALL ShowStep(1, "1. All chickens: feet = 2 x" + STR$(h%) + " =" + STR$(2 * h%))
      IF quit% THEN GOTO ExitGame
      CALL ShowStep(2, "2. Extra feet =" + STR$(f%) + " -" + STR$(2 * h%) + " =" + STR$(e%))
      IF quit% THEN GOTO ExitGame
      CALL ShowStep(3, "3. Rabbits = extra / 2 =" + STR$(e%) + " / 2 =" + STR$(r%))
      IF quit% THEN GOTO ExitGame
      CALL ShowStep(4, "4. Chickens =" + STR$(h%) + " -" + STR$(r%) + " =" + STR$(c%))
      IF quit% THEN GOTO ExitGame
    END IF
  ELSE
    CALL Frame(q%)
    SELECT CASE q%
        CASE 11
          p% = INT(RND * 6) + 3: nb% = INT(RND * 8) + 8
          n1% = INT(RND * 4) + 2: n2% = INT(RND * 4) + 2
          ans% = n1% * p% + n2% * nb%
          LOCATE 5, 1
          PRINT "A pen costs $"; LTRIM$(STR$(p%)); ", a notebook $"; LTRIM$(STR$(nb%)); "."
          LOCATE 6, 1: PRINT "You buy"; n1%; "pens and"; n2%; "notebooks.  Total cost ($)?"
          hint$ = "Total =" + STR$(n1%) + " x" + STR$(p%) + " +" + STR$(n2%) + " x" + STR$(nb%)
        CASE 12
          a% = INT(RND * 20) + 10: b% = INT(RND * 20) + 10: c% = INT(RND * 20) + 10
          ans% = 100 - a% - b% - c%
          LOCATE 5, 1
          PRINT "Three snacks cost $"; LTRIM$(STR$(a%)); ", $"; LTRIM$(STR$(b%));
          PRINT " and $"; LTRIM$(STR$(c%)); "."
          LOCATE 6, 1: PRINT "You pay with a $100 note.  How much change ($)?"
          hint$ = "Change = 100 -" + STR$(a%) + " -" + STR$(b%) + " -" + STR$(c%)
        CASE ELSE
          n% = INT(RND * 5) + 5: ad% = INT(RND * (n% - 1)) + 1
          tt% = ad% * 50 + (n% - ad%) * 30
          ans% = ad%
          LOCATE 5, 1: PRINT "Adult ticket $50, child ticket $30."
          LOCATE 6, 1: PRINT n%; "tickets were sold for $"; LTRIM$(STR$(tt%)); "."
          LOCATE 7, 1: PRINT "How many ADULT tickets were sold?"
          hint$ = "All child:" + STR$(n% * 30) + ". Extra" + STR$(tt% - n% * 30)
          hint$ = hint$ + " / 20 per adult."
    END SELECT
    DO
      a1% = AskNum%("Your answer? ", 9)
      IF quit% THEN GOTO ExitGame
    LOOP UNTIL a1% >= 0
    IF a1% = ans% THEN
      score% = score% + 10
      CALL Msg("Correct! +10", 10)
    ELSE
      CALL Msg("The answer is" + STR$(ans%) + ".  " + hint$, 12)
    END IF
  END IF
  LOCATE 28, 1: PRINT "Score:"; score%; "   Press any key (ESC = menu)"; SPACE$(20);
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
NEXT q%

CLS
COLOR 14
LOCATE 4, 1: PRINT "Finished!  Score:"; score%; "/ 130"
COLOR 7
LOCATE 6, 1
IF score% >= 110 THEN
  PRINT "Brilliant! You are a puzzle master."
ELSEIF score% >= 70 THEN
  PRINT "Nice job.  Remember: assume all chickens, then fix the feet."
ELSE
  PRINT "Practice the 4-step method and try again."
END IF
LOCATE 8, 1: PRINT "Press any key to return to the menu."
k$ = GetKey$

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

' Ask for a non-negative number; returns -1 if the text is not a number
FUNCTION AskNum% (prompt$, rw%)
  LOCATE rw%, 1
  PRINT prompt$; SPACE$(10);
  LOCATE rw%, LEN(prompt$) + 1
  s$ = ReadLine$(5)
  r% = -1
  IF quit% = 0 AND LEN(s$) > 0 THEN
    c$ = LEFT$(s$, 1)
    IF c$ >= "0" AND c$ <= "9" THEN r% = INT(VAL(s$))
  END IF
  AskNum% = r%
END FUNCTION

SUB Frame (q%)
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G03 Chickens & Rabbits (JI TU TONG LONG)";
  COLOR 7
  LOCATE 3, 1: PRINT "Question"; q%; "of 13     Score:"; score%;
  COLOR 8
  LOCATE 30, 1: PRINT "ESC = menu";
  COLOR 15
END SUB

SUB ShowStep (n%, s$)
  COLOR 11
  LOCATE 18 + n%, 1
  PRINT s$;
  COLOR 7
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB

SUB Msg (s$, c%)
  COLOR c%
  LOCATE 17, 1
  PRINT LEFT$(s$ + SPACE$(79), 79);
  COLOR 15
END SUB

' Draw the cage with c chickens (2 legs) and r rabbits (4 legs)
SUB DrawCage (c%, r%)
  LINE (340, 56)-(620, 216), 6, BF
  LINE (342, 58)-(618, 214), 0, BF
  FOR i% = 0 TO 14
    LINE (340 + i% * 20, 56)-(340 + i% * 20, 216), 6
  NEXT i%
  IF c% + r% = 0 THEN
    COLOR 15
    LOCATE 9, 58: PRINT "?";
    EXIT SUB
  END IF
  FOR k% = 0 TO c% + r% - 1
    IF k% > 17 THEN EXIT FOR
    x% = 363 + (k% MOD 6) * 46
    y% = 86 + (k% \ 6) * 50
    IF k% < c% THEN
      CIRCLE (x%, y%), 8, 14
      LINE (x% - 3, y% + 8)-(x% - 3, y% + 17), 14
      LINE (x% + 3, y% + 8)-(x% + 3, y% + 17), 14
      LINE (x% + 8, y% - 2)-(x% + 13, y% - 1), 12
    ELSE
      CIRCLE (x%, y%), 8, 15
      LINE (x% - 4, y% - 8)-(x% - 4, y% - 18), 15
      LINE (x% + 4, y% - 8)-(x% + 4, y% - 18), 15
      LINE (x% - 6, y% + 8)-(x% - 6, y% + 15), 15
      LINE (x% - 2, y% + 8)-(x% - 2, y% + 15), 15
      LINE (x% + 2, y% + 8)-(x% + 2, y% + 15), 15
      LINE (x% + 6, y% + 8)-(x% + 6, y% + 15), 15
    END IF
  NEXT k%
  COLOR 7
  LOCATE 15, 43: PRINT "yellow = chicken, white = rabbit";
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

' Read a line with the keyboard; ESC sets quit% = 1
FUNCTION ReadLine$ (maxlen%)
  s$ = ""
  LOCATE , , 1
  DO
    k$ = GetKey$
    IF k$ = CHR$(27) THEN
      quit% = 1
      EXIT DO
    ELSEIF k$ = CHR$(13) THEN
      EXIT DO
    ELSEIF k$ = CHR$(8) THEN
      IF LEN(s$) > 0 THEN
        s$ = LEFT$(s$, LEN(s$) - 1)
        LOCATE CSRLIN, POS(0) - 1
        PRINT " ";
        LOCATE CSRLIN, POS(0) - 1
      END IF
    ELSEIF LEN(k$) = 1 THEN
      IF ASC(k$) >= 32 AND LEN(s$) < maxlen% THEN
        s$ = s$ + k$
        PRINT k$;
      END IF
    END IF
  LOOP
  LOCATE , , 0
  ReadLine$ = s$
END FUNCTION
