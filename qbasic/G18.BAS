' G18.BAS - Pascal's Triangle (YANG HUI SAN JIAO XING)
' Educational content (1991 list): the structure and the applications of Pascal's (Yang Hui's)
'   triangle: odd numbers, row sums, diagonal sums, binomial expansion, combinations.
' Controls: number keys 1-7 pick a mode, Up/Down change the row, Enter/Backspace edit input,
'   ESC = back (ESC at the mode list = menu)
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (r%, c%, mx%)
DECLARE FUNCTION Bin# (n%, k%)
DECLARE FUNCTION ToInt% (a$)
DECLARE FUNCTION Fib& (m%)
DECLARE SUB Note (r%, t$)
DECLARE SUB Title ()
DECLARE SUB BuildPas ()
DECLARE SUB DrawTri (nr%, md%, sel%, hn%, hk%, anim%)
DECLARE SUB Expand (n%)
DECLARE SUB Explain (md%, sel%)
DECLARE SUB Browse (md%)
DECLARE SUB Calc ()
DECLARE SUB Quiz ()
DECLARE SUB ShowMenu ()

' pas&(n,k) = number in row n (0-14), position k (0-n)
DIM SHARED pas&(0 TO 14, 0 TO 14)
DIM SHARED quit%
RANDOMIZE TIMER
SCREEN 0
WIDTH 80
quit% = 0
CALL BuildPas
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
DO
  CALL ShowMenu
  k$ = GetKey$
  IF k$ = CHR$(27) THEN EXIT DO
  IF k$ >= "1" AND k$ <= "5" THEN
    m% = VAL(k$)
    CALL Browse(m%)
  ELSEIF k$ = "6" THEN
    CALL Calc
  ELSEIF k$ = "7" THEN
    CALL Quiz
  END IF
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

' Binomial coefficient C(n,k) as a double (exact for n up to 30).
FUNCTION Bin# (n%, k%)
  IF k% < 0 OR k% > n% THEN
    Bin# = 0
    EXIT FUNCTION
  END IF
  j% = k%
  IF n% - k% < j% THEN j% = n% - k%
  r# = 1
  FOR i% = 1 TO j%
    r# = r# * (n% - j% + i%) / i%
  NEXT i%
  Bin# = INT(r# + .5)
END FUNCTION

SUB Browse (md%)
  sel% = 4
  IF md% = 4 THEN sel% = 6
  anim% = 0
  IF md% = 1 THEN anim% = 1
  DO
    CLS
    COLOR 15
    LOCATE 1, 1: PRINT "G18 Pascal's Triangle (YANG HUI SAN JIAO XING)";
    COLOR 11
    SELECT CASE md%
      CASE 1
        LOCATE 2, 1: PRINT "Mode 1: the triangle - every number is the sum of the two above it";
      CASE 2
        LOCATE 2, 1: PRINT "Mode 2: odd numbers - the Sierpinski triangle hides inside";
      CASE 3
        LOCATE 2, 1: PRINT "Mode 3: row sums are powers of 2";
      CASE 4
        LOCATE 2, 1: PRINT "Mode 4: shallow diagonal sums are Fibonacci numbers";
      CASE ELSE
        LOCATE 2, 1: PRINT "Mode 5: binomial expansion (a+b)^n";
    END SELECT
    CALL DrawTri(15, md%, sel%, -1, -1, anim%)
    anim% = 0
    CALL Explain(md%, sel%)
    COLOR 7
    LOCATE 25, 1: PRINT "Up/Down = change row    ESC = back";
    k$ = GetKey$
    IF k$ = CHR$(27) THEN
      EXIT DO
    ELSEIF k$ = CHR$(0) + "H" OR k$ = CHR$(0) + "K" THEN
      IF sel% > 0 THEN sel% = sel% - 1
    ELSEIF k$ = CHR$(0) + "P" OR k$ = CHR$(0) + "M" THEN
      IF sel% < 14 THEN sel% = sel% + 1
    END IF
  LOOP
END SUB

SUB BuildPas
  FOR n% = 0 TO 14
    FOR k% = 0 TO 14
      pas&(n%, k%) = 0
    NEXT k%
  NEXT n%
  FOR n% = 0 TO 14
    pas&(n%, 0) = 1
    pas&(n%, n%) = 1
    FOR k% = 1 TO n% - 1
      pas&(n%, k%) = pas&(n% - 1, k% - 1) + pas&(n% - 1, k%)
    NEXT k%
  NEXT n%
END SUB

' Combination calculator: C(n,k) up to n = 30, also shown as the Pascal rule.
SUB Calc
  sn% = -1
  sk% = -1
  DO
    CLS
    COLOR 15
    LOCATE 1, 1: PRINT "G18 Pascal's Triangle (YANG HUI SAN JIAO XING)";
    COLOR 11
    LOCATE 2, 1: PRINT "Mode 6: combinations C(n,k) = ways to choose k things from n";
    CALL DrawTri(15, 6, sn%, -1, sk%, 0)
    COLOR 7
    LOCATE 19, 1: PRINT "n (0-30)  > ";
    a$ = ReadLine$(19, 13, 3)
    IF a$ = CHR$(27) THEN EXIT DO
    nn% = ToInt%(a$)
    IF nn% < 0 OR nn% > 30 THEN
      CALL Note(23, "Please type a whole number from 0 to 30.")
    ELSE
      CALL Note(19, "n =" + STR$(nn%))
      LOCATE 20, 1: PRINT "k (0-n)   > ";
      b$ = ReadLine$(20, 13, 3)
      IF b$ = CHR$(27) THEN EXIT DO
      kk% = ToInt%(b$)
      IF kk% < 0 OR kk% > nn% THEN
        CALL Note(23, "k must be a whole number from 0 to n.")
      ELSE
        r# = Bin#(nn%, kk%)
        COLOR 14
        msg$ = "C(" + LTRIM$(STR$(nn%)) + "," + LTRIM$(STR$(kk%))
        msg$ = msg$ + ") = n!/(k!(n-k)!) = " + LTRIM$(STR$(r#))
        CALL Note(21, msg$)
        COLOR 10
        IF kk% >= 1 AND kk% <= nn% - 1 THEN
          x# = Bin#(nn% - 1, kk% - 1)
          y# = Bin#(nn% - 1, kk%)
          msg$ = "Pascal rule: C(n-1,k-1) + C(n-1,k) = " + LTRIM$(STR$(x#)) + " + "
          msg$ = msg$ + LTRIM$(STR$(y#))
          CALL Note(22, msg$)
        ELSE
          CALL Note(22, "k = 0 or k = n: the edge of the triangle, always 1 way.")
        END IF
        IF nn% <= 14 THEN
          sn% = nn%
          sk% = kk%
          CALL DrawTri(15, 6, sn%, -1, sk%, 0)
        ELSE
          sn% = -1
          sk% = -1
        END IF
        COLOR 7
        CALL Note(24, "Any key = another one, ESC = back")
        k$ = GetKey$
        IF k$ = CHR$(27) THEN EXIT DO
      END IF
    END IF
  LOOP
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

' Draws rows 0..nr-1 centred. md: 1 plain, 2 odd/even, 3 and 5 highlight row sel, 4 highlight
' the shallow diagonal n+k = sel, 6 highlight cell (sel,hk), 7 quiz: cell (hn,hk) shown as ?
SUB DrawTri (nr%, md%, sel%, hn%, hk%, anim%)
  FOR n% = 0 TO nr% - 1
    FOR k% = 0 TO n%
      v& = pas&(n%, k%)
      t$ = LTRIM$(STR$(v&))
      c% = 7
      SELECT CASE md%
        CASE 1
          c% = 11
        CASE 2
          IF v& MOD 2 = 1 THEN
            c% = 14
          ELSE
            c% = 8
            t$ = "."
          END IF
        CASE 3, 5
          IF n% = sel% THEN c% = 14
        CASE 4
          IF n% + k% = sel% THEN c% = 14
        CASE 6
          IF n% = sel% AND k% = hk% THEN c% = 14
        CASE 7
          IF n% = hn% AND k% = hk% THEN
            c% = 12
            t$ = "?"
          ELSE
            c% = 11
          END IF
      END SELECT
      col% = 1 + (80 - nr% * 5) \ 2 + ((nr% - 1 - n%) * 5) \ 2 + k% * 5
      COLOR c%
      LOCATE 3 + n%, col%
      PRINT RIGHT$(SPACE$(5) + t$, 5);
    NEXT k%
    IF anim% <> 0 THEN CALL Delay(.1)
  NEXT n%
END SUB

' Rows 20-23: the expansion of (a+b)^n, wrapped to the screen width.
SUB Expand (n%)
  rw% = 20
  cur$ = "(a+b)^" + LTRIM$(STR$(n%)) + " = "
  FOR k% = 0 TO n%
    c& = pas&(n%, k%)
    t$ = ""
    IF c& > 1 OR n% = 0 THEN t$ = LTRIM$(STR$(c&))
    ap% = n% - k%
    IF ap% > 0 THEN t$ = t$ + "a"
    IF ap% > 1 THEN t$ = t$ + "^" + LTRIM$(STR$(ap%))
    IF k% > 0 THEN t$ = t$ + "b"
    IF k% > 1 THEN t$ = t$ + "^" + LTRIM$(STR$(k%))
    IF k% < n% THEN t$ = t$ + " + "
    IF LEN(cur$) + LEN(t$) > 76 THEN
      IF rw% <= 23 THEN CALL Note(rw%, cur$)
      rw% = rw% + 1
      cur$ = "    "
    END IF
    cur$ = cur$ + t$
  NEXT k%
  IF rw% <= 23 THEN CALL Note(rw%, cur$)
END SUB

SUB Explain (md%, sel%)
  FOR r% = 19 TO 24
    CALL Note(r%, "")
  NEXT r%
  COLOR 10
  SELECT CASE md%
    CASE 1
      CALL Note(19, "Rule: each number is the sum of the two above it; the edges are all 1.")
      CALL Note(20, "Yang Hui wrote about this triangle in 1261, Pascal studied it in 1654.")
      CALL Note(21, "Row n has n+1 numbers. Rows are counted from 0.")
    CASE 2
      o% = 0
      FOR n% = 0 TO 14
        FOR k% = 0 TO n%
          IF pas&(n%, k%) MOD 2 = 1 THEN o% = o% + 1
        NEXT k%
      NEXT n%
      CALL Note(19, "Bright = odd, dots = even. The odd numbers draw the Sierpinski triangle,")
      msg$ = "a fractal: triangles inside triangles. Odd entries here:" + STR$(o%)
      msg$ = msg$ + " of 120"
      CALL Note(20, msg$)
      CALL Note(21, "Why: odd + even = odd, but odd + odd and even + even are both even.")
    CASE 3
      s$ = ""
      t& = 0
      p& = 1
      FOR k% = 0 TO sel%
        s$ = s$ + LTRIM$(STR$(pas&(sel%, k%)))
        IF k% < sel% THEN s$ = s$ + "+"
        t& = t& + pas&(sel%, k%)
        IF k% > 0 THEN p& = p& * 2
      NEXT k%
      CALL Note(19, "Row n =" + STR$(sel%) + " (Up/Down to change). Add up the whole row:")
      CALL Note(20, s$)
      CALL Note(21, "Sum =" + STR$(t&) + "      2^" + LTRIM$(STR$(sel%)) + " =" + STR$(p&))
    CASE 4
      s$ = ""
      t& = 0
      FOR k% = 0 TO sel% \ 2
        s$ = s$ + LTRIM$(STR$(pas&(sel% - k%, k%)))
        IF k% < sel% \ 2 THEN s$ = s$ + "+"
        t& = t& + pas&(sel% - k%, k%)
      NEXT k%
      msg$ = "Shallow diagonal" + STR$(sel%)
      msg$ = msg$ + " (Up/Down to change). Add the bright numbers:"
      CALL Note(19, msg$)
      CALL Note(20, s$)
      msg$ = "Sum =" + STR$(t&) + "   = Fibonacci number F" + LTRIM$(STR$(sel%
      msg$ = msg$ + 1)) + " =" + STR$(Fib&(sel% + 1))
      CALL Note(21, msg$)
      CALL Note(22, "Fibonacci: 1 1 2 3 5 8 13 21 34 55 ... each is the sum of the two before.")
    CASE ELSE
      CALL Note(19, "n =" + STR$(sel%) + " (Up/Down). The coefficients are exactly row n:")
      CALL Expand(sel%)
  END SELECT
END SUB

FUNCTION Fib& (m%)
  a& = 1
  b& = 1
  FOR i% = 3 TO m%
    c& = a& + b&
    a& = b&
    b& = c&
  NEXT i%
  Fib& = b&
END FUNCTION

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB Note (r%, t$)
  IF r% < 1 OR r% > 25 THEN EXIT SUB
  LOCATE r%, 1
  PRINT LEFT$(t$ + SPACE$(79), 79);
END SUB

' Quiz: find the hidden number by adding the two above it. 5 questions, 20 points each.
SUB Quiz
  sc% = 0
  FOR q% = 1 TO 5
    n% = INT(RND * 8) + 2
    k% = INT(RND * (n% - 1)) + 1
    CLS
    COLOR 15
    LOCATE 1, 1: PRINT "G18 Pascal's Triangle (YANG HUI SAN JIAO XING)";
    COLOR 11
    LOCATE 2, 1: PRINT "Mode 7: quiz - question"; q%; "of 5    score"; sc%;
    CALL DrawTri(10, 7, 0, n%, k%, 0)
    COLOR 7
    CALL Note(15, "Which number belongs where the ? is?  (add the two numbers above it)")
    LOCATE 17, 1: PRINT "Your answer > ";
    a$ = ReadLine$(17, 15, 6)
    IF a$ = CHR$(27) THEN EXIT SUB
    v& = pas&(n%, k%)
    IF LEN(a$) > 0 AND VAL(a$) = v& THEN
      sc% = sc% + 20
      COLOR 10
      CALL Note(19, "Correct! +20")
    ELSE
      COLOR 12
      msg$ = "Not quite: " + LTRIM$(STR$(pas&(n% - 1, k% - 1))) + " + "
      msg$ = msg$ + LTRIM$(STR$(pas&(n% - 1, k%))) + " =" + STR$(v&)
      CALL Note(19, msg$)
    END IF
    COLOR 7
    CALL Note(21, "Any key = next, ESC = back")
    k$ = GetKey$
    IF k$ = CHR$(27) THEN EXIT SUB
  NEXT q%
  CLS
  COLOR 14
  LOCATE 5, 25: PRINT "QUIZ FINISHED"
  COLOR 15
  LOCATE 8, 25: PRINT "Score:"; sc%; "out of 100"
  COLOR 10
  IF sc% >= 80 THEN
    LOCATE 10, 25: PRINT "You know the triangle well!"
  ELSE
    LOCATE 10, 25: PRINT "Try modes 1-6 again, then retry."
  END IF
  COLOR 7
  LOCATE 24, 1: PRINT "Press any key";
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

SUB ShowMenu
  CLS
  COLOR 14
  LOCATE 2, 20: PRINT "G18  PASCAL'S TRIANGLE  (YANG HUI SAN JIAO XING)"
  COLOR 15
  LOCATE 5, 15: PRINT "1  The triangle (animated)"
  LOCATE 6, 15: PRINT "2  Odd numbers: Sierpinski triangle"
  LOCATE 7, 15: PRINT "3  Row sums = powers of 2"
  LOCATE 8, 15: PRINT "4  Diagonal sums = Fibonacci numbers"
  LOCATE 9, 15: PRINT "5  Binomial expansion (a+b)^n"
  LOCATE 10, 15: PRINT "6  Combination calculator C(n,k)"
  LOCATE 11, 15: PRINT "7  Quiz (5 questions, 100 points)"
  COLOR 7
  LOCATE 14, 15: PRINT "Press 1-7 to choose a mode"
  LOCATE 25, 1: PRINT "ESC = menu";
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 18: PRINT "G18  PASCAL'S TRIANGLE  (YANG HUI SAN JIAO XING)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "The STRUCTURE of Pascal's (Yang Hui's) triangle and its APPLICATIONS."
  COLOR 7
  LOCATE 10, 6: PRINT "Each number is the sum of the two above it. Explore the patterns inside:"
  LOCATE 11, 6: PRINT "  odd numbers (Sierpinski), row sums (2^n), diagonal sums (Fibonacci),"
  LOCATE 12, 6: PRINT "  binomial expansion (a+b)^n and combinations C(n,k) = choose k from n."
  LOCATE 14, 6: PRINT "Controls: keys 1-7 choose a mode, Up/Down change the row,"
  LOCATE 15, 6: PRINT "  type numbers + Enter in the calculator and quiz, ESC = back."
  COLOR 10
  LOCATE 17, 6: PRINT "Quiz score: 20 points for each correct number (100 in all)."
  COLOR 14
  LOCATE 21, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB

FUNCTION ToInt% (a$)
  ToInt% = -1
  IF LEN(a$) < 1 OR LEN(a$) > 2 THEN EXIT FUNCTION
  FOR i% = 1 TO LEN(a$)
    IF MID$(a$, i%, 1) < "0" OR MID$(a$, i%, 1) > "9" THEN EXIT FUNCTION
  NEXT i%
  ToInt% = VAL(a$)
END FUNCTION
