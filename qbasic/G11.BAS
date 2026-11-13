' G11.BAS - Block Arrange (PAI FANG KUAI)
' Educational content (1991 list): prime numbers and composite numbers.
'   A prime number of blocks can only be made into one rectangle (1 x n);
'   a composite number can be made into several rectangles.
' Controls: 1 = arrange blocks, 2 = sieve of Eratosthenes, 3 = prime/composite quiz,
'   ESC = back (ESC at the game menu returns to the main menu)
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadNum$ (maxlen%)
DECLARE FUNCTION IsPrime% (n%)
DECLARE SUB Title ()
DECLARE SUB GameMenu ()
DECLARE SUB Arrange ()
DECLARE SUB Sieve ()
DECLARE SUB Quiz ()
DECLARE SUB Bar (t$)

RANDOMIZE TIMER
SCREEN 12
CALL Title
DO
  CALL GameMenu
  k$ = GetKey$
  SELECT CASE k$
    CASE "1"
      CALL Arrange
    CASE "2"
      CALL Sieve
    CASE "3"
      CALL Quiz
    CASE CHR$(27)
      EXIT DO
  END SELECT
LOOP

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

SUB Arrange
  DO
    CLS
    COLOR 15
    LOCATE 1, 1: PRINT "ARRANGE BLOCKS: how many blocks (1-48)? Enter to go, ESC = back"
    COLOR 7
    LOCATE 3, 1: PRINT "Blocks: ";
    a$ = ReadNum$(2)
    IF a$ = CHR$(27) THEN EXIT DO
    n% = VAL(a$)
    IF n% >= 1 AND n% <= 48 THEN
      y% = 64
      cnt% = 0
      FOR a% = 1 TO 7
        IF a% * a% <= n% AND n% MOD a% = 0 THEN
          b% = n% \ a%
          cnt% = cnt% + 1
          FOR r% = 0 TO a% - 1
            FOR c% = 0 TO b% - 1
              x1% = 20 + c% * 11
              y1% = y% + r% * 11
              LINE (x1%, y1%)-(x1% + 8, y1% + 8), 9 + cnt%, BF
            NEXT c%
          NEXT r%
          COLOR 14
          LOCATE y% \ 16 + 1, (20 + b% * 11) \ 8 + 3
          PRINT LTRIM$(STR$(a%)); " x "; LTRIM$(STR$(b%));
          y% = y% + a% * 11 + 12
        END IF
      NEXT a%
      COLOR 15
      LOCATE 24, 1
      PRINT LTRIM$(STR$(n%)); " blocks can make"; cnt%; "different rectangle(s)."
      IF n% = 1 THEN
        PRINT "1 is neither prime nor composite."
      ELSEIF cnt% = 1 THEN
        COLOR 10
        PRINT "PRIME: only one way, 1 x"; n%; "."
      ELSE
        COLOR 12
        PRINT "COMPOSITE: it has factors other than 1 and itself."
      END IF
      COLOR 7
      LOCATE 29, 1: PRINT "Press any key (ESC = back)";
      k$ = GetKey$
      IF k$ = CHR$(27) THEN EXIT DO
    END IF
  LOOP
END SUB

SUB Bar (t$)
  COLOR 7
  LOCATE 30, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

SUB GameMenu
  CLS
  COLOR 14
  LOCATE 3, 25: PRINT "G11  BLOCK ARRANGE  (PAI FANG KUAI)"
  COLOR 15
  LOCATE 7, 20: PRINT "1  Arrange n blocks into rectangles"
  LOCATE 9, 20: PRINT "2  Sieve of Eratosthenes (1 to 100)"
  LOCATE 11, 20: PRINT "3  Prime or composite? quiz"
  CALL Bar("Press 1, 2 or 3.   ESC = menu")
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

FUNCTION IsPrime% (n%)
  r% = 1
  IF n% < 2 THEN r% = 0
  d% = 2
  DO WHILE d% * d% <= n%
    IF n% MOD d% = 0 THEN r% = 0
    d% = d% + 1
  LOOP
  IsPrime% = r%
END FUNCTION

SUB Quiz
  sc% = 0
  FOR q% = 1 TO 10
    n% = INT(RND * 98) + 2
    CLS
    COLOR 15
    LOCATE 2, 5: PRINT "QUIZ  question"; q%; "of 10     score"; sc%
    COLOR 14
    LOCATE 8, 10: PRINT "Is"; n%; "a PRIME (P) or a COMPOSITE (C) number?"
    CALL Bar("P = prime   C = composite   ESC = back")
    DO
      k$ = UCASE$(GetKey$)
    LOOP UNTIL k$ = "P" OR k$ = "C" OR k$ = CHR$(27)
    IF k$ = CHR$(27) THEN EXIT SUB
    ok% = 0
    IF (k$ = "P" AND IsPrime%(n%) = 1) OR (k$ = "C" AND IsPrime%(n%) = 0) THEN ok% = 1
    LOCATE 12, 10
    IF ok% = 1 THEN
      sc% = sc% + 1
      COLOR 10: PRINT "Correct!";
    ELSE
      COLOR 12: PRINT "Wrong.";
    END IF
    COLOR 7
    LOCATE 14, 10
    IF IsPrime%(n%) = 1 THEN
      PRINT LTRIM$(STR$(n%)); " is prime: only 1 x"; n%;
    ELSE
      d% = 2
      DO WHILE n% MOD d% <> 0
        d% = d% + 1
      LOOP
      PRINT LTRIM$(STR$(n%)); " ="; d%; "x"; n% \ d%; " so it is composite";
    END IF
    LOCATE 29, 1: PRINT "Press any key (ESC = back)";
    k$ = GetKey$
    IF k$ = CHR$(27) THEN EXIT SUB
  NEXT q%
  CLS
  COLOR 15
  LOCATE 10, 20: PRINT "Final score:"; sc%; "/ 10"
  COLOR 14
  LOCATE 12, 20
  IF sc% >= 9 THEN
    PRINT "Excellent! You know your primes."
  ELSEIF sc% >= 6 THEN
    PRINT "Good. Try the sieve to see the pattern."
  ELSE
    PRINT "Keep practicing: test divisors up to the square root."
  END IF
  LOCATE 29, 1: PRINT "Press any key";
  k$ = GetKey$
END SUB

FUNCTION ReadNum$ (maxlen%)
  s$ = ""
  r0% = CSRLIN
  c0% = POS(0)
  DO
    LOCATE r0%, c0%
    PRINT s$; "_  ";
    k$ = GetKey$
    IF k$ = CHR$(27) THEN
      s$ = CHR$(27)
      EXIT DO
    ELSEIF k$ = CHR$(13) THEN
      EXIT DO
    ELSEIF k$ = CHR$(8) THEN
      IF LEN(s$) > 0 THEN s$ = LEFT$(s$, LEN(s$) - 1)
    ELSEIF k$ >= "0" AND k$ <= "9" AND LEN(k$) = 1 THEN
      IF LEN(s$) < maxlen% THEN s$ = s$ + k$
    END IF
  LOOP
  ReadNum$ = s$
END FUNCTION

SUB Sieve
  DIM m%(1 TO 100)
  CLS
  COLOR 15
  LOCATE 1, 1: PRINT "SIEVE OF ERATOSTHENES: keep a prime, cross out its multiples"
  FOR i% = 1 TO 100
    m%(i%) = 0
    COLOR 7
    LOCATE 4 + ((i% - 1) \ 10) * 2, 10 + ((i% - 1) MOD 10) * 6
    PRINT USING "###"; i%;
  NEXT i%
  COLOR 8
  LOCATE 4, 10: PRINT "  1";
  FOR p% = 2 TO 10
    IF m%(p%) = 0 THEN
      COLOR 10
      LOCATE 4 + ((p% - 1) \ 10) * 2, 10 + ((p% - 1) MOD 10) * 6
      PRINT USING "###"; p%;
      LOCATE 25, 1: PRINT "Prime"; p%; ": crossing out its multiples      ";
      FOR j% = p% * p% TO 100 STEP p%
        IF m%(j%) = 0 THEN
          m%(j%) = 1
          COLOR 4
          LOCATE 4 + ((j% - 1) \ 10) * 2, 10 + ((j% - 1) MOD 10) * 6
          PRINT USING "###"; j%;
          CALL Delay(.05)
        END IF
      NEXT j%
    END IF
  NEXT p%
  cnt% = 0
  FOR i% = 2 TO 100
    IF m%(i%) = 0 THEN
      cnt% = cnt% + 1
      COLOR 10
      LOCATE 4 + ((i% - 1) \ 10) * 2, 10 + ((i% - 1) MOD 10) * 6
      PRINT USING "###"; i%;
    END IF
  NEXT i%
  COLOR 14
  LOCATE 25, 1: PRINT "Done:"; cnt%; "primes below 100 (green). Red = composite, 1 = neither.   ";
  CALL Bar("Press any key")
  k$ = GetKey$
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 22: PRINT "G11  BLOCK ARRANGE  (PAI FANG KUAI)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "PRIME and COMPOSITE numbers. Try to build a rectangle from n blocks."
  LOCATE 8, 6: PRINT "A prime can only be a 1 x n strip. A composite has more rectangles."
  COLOR 7
  LOCATE 11, 6: PRINT "Controls:"
  LOCATE 12, 6: PRINT "1 = arrange n blocks (type a number, Enter)"
  LOCATE 13, 6: PRINT "2 = watch the sieve of Eratosthenes find the primes up to 100"
  LOCATE 14, 6: PRINT "3 = quiz: prime or composite? (P / C)"
  LOCATE 15, 6: PRINT "ESC = back / return to the main menu"
  COLOR 14
  LOCATE 19, 6: PRINT "Press any key to start..."
  k$ = GetKey$
END SUB
