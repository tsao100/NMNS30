' G13.BAS - Search It (ZHAO ZHAO KAN)
' Educational content (1991 list): searching methods - guessing with "higher/lower" hints,
'   binary search (halving the range) versus linear search on sorted data.
' Controls: 1 = you guess the computer's number, 2 = computer guesses yours,
'   3 = linear vs binary search demo, ESC = back (ESC at the game menu = main menu)
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadNum$ (maxlen%)
DECLARE SUB Title ()
DECLARE SUB GameMenu ()
DECLARE SUB Bar (t$)
DECLARE SUB Ruler (lo%, hi%)
DECLARE SUB YouGuess ()
DECLARE SUB CompGuess ()
DECLARE SUB Compare ()

RANDOMIZE TIMER
SCREEN 0
WIDTH 80
COLOR 7, 0
CALL Title
DO
  CALL GameMenu
  k$ = GetKey$
  SELECT CASE k$
    CASE "1"
      CALL YouGuess
    CASE "2"
      CALL CompGuess
    CASE "3"
      CALL Compare
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

SUB Bar (t$)
  COLOR 7
  LOCATE 25, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

SUB CompGuess
  CLS
  COLOR 15
  LOCATE 2, 2: PRINT "COMPUTER GUESSES: think of a whole number from 1 to 1000."
  COLOR 7
  LOCATE 4, 2: PRINT "Do not tell me. I will halve the range every time (binary search)."
  CALL Bar("Press any key when ready   ESC = back")
  k$ = GetKey$
  IF k$ = CHR$(27) THEN EXIT SUB
  lo% = 1
  hi% = 1000
  g% = 0
  DO
    CLS
    IF lo% > hi% THEN
      COLOR 12
      LOCATE 8, 2: PRINT "Your answers contradict each other - no number is left!"
      EXIT DO
    END IF
    m% = (lo% + hi%) \ 2
    g% = g% + 1
    COLOR 15
    LOCATE 2, 2: PRINT "Guess number"; g%; ": is your number"; m%; "?"
    COLOR 7
    LOCATE 4, 2: PRINT "Candidates left:"; hi% - lo% + 1; "  (from"; lo%; "to"; hi%; ")"
    LOCATE 6, 2
    CALL Ruler(lo%, hi%)
    CALL Bar("H = my number is Higher   L = Lower   C = Correct   ESC = back")
    DO
      k$ = UCASE$(GetKey$)
    LOOP UNTIL k$ = "H" OR k$ = "L" OR k$ = "C" OR k$ = CHR$(27)
    IF k$ = CHR$(27) THEN EXIT SUB
    IF k$ = "C" THEN
      COLOR 10
      LOCATE 9, 2: PRINT "Found it in"; g%; "guesses!  Halving needs at most 10 for 1..1000."
      EXIT DO
    ELSEIF k$ = "H" THEN
      lo% = m% + 1
    ELSE
      hi% = m% - 1
    END IF
  LOOP
  CALL Bar("Press any key")
  k$ = GetKey$
END SUB

SUB Compare
  DIM ar%(1 TO 100)
  v% = INT(RND * 8) + 1
  FOR i% = 1 TO 100
    ar%(i%) = v%
    v% = v% + INT(RND * 9) + 1
  NEXT i%
  tl& = 0
  tb& = 0
  runs% = 0
  DO
    CLS
    COLOR 15
    LOCATE 1, 2: PRINT "LINEAR vs BINARY search on a sorted list of 100 numbers"
    COLOR 8
    FOR i% = 1 TO 100
      LOCATE 3 + (i% - 1) \ 10, 2 + ((i% - 1) MOD 10) * 6
      PRINT USING "####"; ar%(i%);
    NEXT i%
    idx% = INT(RND * 100) + 1
    t% = ar%(idx%)
    IF RND < .2 THEN t% = INT(RND * 880) + 1
    COLOR 14
    LOCATE 14, 2: PRINT "Target:"; t%
    lc% = 0
    fl% = 0
    FOR i% = 1 TO 100
      lc% = lc% + 1
      IF ar%(i%) = t% THEN
        fl% = i%
        EXIT FOR
      END IF
    NEXT i%
    COLOR 12
    LOCATE 15, 2: PRINT "Linear search (look one by one):"; lc%; "comparisons";
    IF fl% > 0 THEN PRINT " - found at position"; fl% ELSE PRINT " - not found"
    COLOR 10
    lo% = 1
    hi% = 100
    bc% = 0
    fb% = 0
    r% = 16
    DO WHILE lo% <= hi%
      m% = (lo% + hi%) \ 2
      bc% = bc% + 1
      LOCATE r%, 4
      PRINT "probe #"; LTRIM$(STR$(m%)); " ="; ar%(m%);
      IF ar%(m%) = t% THEN
        fb% = m%
        PRINT " -> found!"
        lo% = hi% + 1
      ELSEIF ar%(m%) < t% THEN
        PRINT " -> too small, keep"; m% + 1; "to"; hi%
        lo% = m% + 1
      ELSE
        PRINT " -> too big, keep"; lo%; "to"; m% - 1
        hi% = m% - 1
      END IF
      r% = r% + 1
      IF r% > 22 THEN r% = 22
      CALL Delay(.25)
    LOOP
    LOCATE 23, 2
    COLOR 10
    PRINT "Binary search:"; bc%; "comparisons (at most 7 for 100 items)";
    tl& = tl& + lc%
    tb& = tb& + bc%
    runs% = runs% + 1
    COLOR 15
    LOCATE 24, 2
    PRINT "Average over"; runs%; "runs: linear"; tl& \ runs%; " binary"; tb& \ runs%;
    CALL Bar("Any key = another target   ESC = back")
    k$ = GetKey$
    IF k$ = CHR$(27) THEN EXIT DO
  LOOP
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

SUB GameMenu
  CLS
  COLOR 14
  LOCATE 3, 25: PRINT "G13  SEARCH IT  (ZHAO ZHAO KAN)"
  COLOR 15
  LOCATE 7, 20: PRINT "1  You guess the computer's number (1-1000)"
  LOCATE 9, 20: PRINT "2  The computer guesses your number"
  LOCATE 11, 20: PRINT "3  Linear search vs binary search"
  CALL Bar("Press 1, 2 or 3.   ESC = menu")
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

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

SUB Ruler (lo%, hi%)
  b$ = ""
  FOR i% = 1 TO 60
    cl& = (i% - 1) * 1000& \ 60 + 1
    ch& = i% * 1000& \ 60
    IF ch& >= lo% AND cl& <= hi% THEN b$ = b$ + "#" ELSE b$ = b$ + "."
  NEXT i%
  PRINT "1 ["; b$; "] 1000";
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 25: PRINT "G13  SEARCH IT  (ZHAO ZHAO KAN)"
  COLOR 7
  LOCATE 6, 4: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 4: PRINT "SEARCHING. Use 'higher / lower' hints to cut the range in half each time"
  LOCATE 8, 4: PRINT "(binary search) and see how it beats looking one by one (linear search)."
  COLOR 7
  LOCATE 11, 4: PRINT "Controls:"
  LOCATE 12, 4: PRINT "1 = you guess my secret number from 1 to 1000 (type digits, Enter)"
  LOCATE 13, 4: PRINT "2 = I guess your number: answer H (higher), L (lower) or C (correct)"
  LOCATE 14, 4: PRINT "3 = count the comparisons of linear and binary search"
  LOCATE 15, 4: PRINT "ESC = back / return to the main menu"
  COLOR 14
  LOCATE 19, 4: PRINT "Press any key to start..."
  k$ = GetKey$
END SUB

SUB YouGuess
  DIM gs%(1 TO 40), gr%(1 TO 40)
  tgt% = INT(RND * 1000) + 1
  lo% = 1
  hi% = 1000
  g% = 0
  msg$ = ""
  DO
    CLS
    COLOR 15
    LOCATE 1, 2: PRINT "I picked a number from 1 to 1000. Find it!   Guesses so far:"; g%
    COLOR 7
    LOCATE 3, 2: PRINT "Still possible:"; lo%; "to"; hi%; "("; hi% - lo% + 1; "numbers )"
    LOCATE 5, 2
    CALL Ruler(lo%, hi%)
    FOR i% = 1 TO g%
      IF i% > g% - 10 THEN
        LOCATE 7 + (i% - (g% - 10)), 4
        IF i% <= g% - 10 THEN LOCATE 7, 4
        PRINT "guess"; i%; ":"; gs%(i%);
        IF gr%(i%) < 0 THEN PRINT " too small" ELSE PRINT " too big"
      END IF
    NEXT i%
    COLOR 12
    LOCATE 20, 2: PRINT msg$
    msg$ = ""
    COLOR 14
    LOCATE 22, 2: PRINT "Your guess (1-1000): ";
    a$ = ReadNum$(4)
    IF a$ = CHR$(27) THEN EXIT SUB
    v% = VAL(a$)
    IF v% < 1 OR v% > 1000 THEN
      msg$ = "Please type a number from 1 to 1000."
    ELSE
      g% = g% + 1
      IF v% = tgt% THEN
        COLOR 10
        LOCATE 20, 2: PRINT "Correct! The number was"; tgt%; "- you needed"; g%; "guesses.     ";
        LOCATE 21, 2
        IF g% <= 10 THEN
          PRINT "Excellent: halving the range finds any number in 10 guesses or fewer.";
        ELSE
          PRINT "Try always guessing the middle of the range to finish in 10.";
        END IF
        EXIT DO
      END IF
      gs%(g%) = v%
      IF v% < tgt% THEN
        gr%(g%) = -1
        IF v% + 1 > lo% THEN lo% = v% + 1
      ELSE
        gr%(g%) = 1
        IF v% - 1 < hi% THEN hi% = v% - 1
      END IF
      IF g% >= 40 THEN
        LOCATE 20, 2: PRINT "Too many guesses! The number was"; tgt%; "     ";
        EXIT DO
      END IF
    END IF
  LOOP
  CALL Bar("Press any key")
  k$ = GetKey$
END SUB
