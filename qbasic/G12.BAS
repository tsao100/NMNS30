' G12.BAS - Sort It (PAI PAI KAN)
' Educational content (1991 list): sorting methods (bubble, insertion, selection, merge)
'   and how many comparisons and moves each one needs.
' Controls: B/I/S/M = run a sort, R = race (guess the winner), N = new data,
'   D = change size, P = change pattern, +/- = speed, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE SUB Title ()
DECLARE SUB Gen ()
DECLARE SUB ResetData ()
DECLARE SUB DrawBar (i%, c%)
DECLARE SUB DrawAll ()
DECLARE SUB Stat ()
DECLARE SUB Pause ()
DECLARE SUB Hilite (i%, j%)
DECLARE SUB SetVal (i%, v%)
DECLARE SUB SwapEl (i%, j%)
DECLARE SUB Bubble ()
DECLARE SUB Insertion ()
DECLARE SUB Selection ()
DECLARE SUB MSort (lo%, hi%)
DECLARE SUB RunSort (m%)
DECLARE SUB Finish ()
DECLARE SUB Race ()

DIM SHARED a%(1 TO 40), bs%(1 TO 40), tm%(1 TO 40)
DIM SHARED rc&(1 TO 4), rm&(1 TO 4), nm$(1 TO 4)
DIM SHARED n%, pat%, fast%, abort%, cur$
DIM SHARED cmp&, mv&, dl!

RANDOMIZE TIMER
SCREEN 12
nm$(1) = "Bubble"
nm$(2) = "Insertion"
nm$(3) = "Selection"
nm$(4) = "Merge"
n% = 20
pat% = 1
dl! = .03
CALL Title
CALL Gen
DO
  abort% = 0
  CALL DrawAll
  k$ = UCASE$(GetKey$)
  SELECT CASE k$
    CASE "B"
      CALL RunSort(1)
    CASE "I"
      CALL RunSort(2)
    CASE "S"
      CALL RunSort(3)
    CASE "M"
      CALL RunSort(4)
    CASE "R"
      CALL Race
    CASE "N"
      CALL Gen
    CASE "D"
      n% = n% + 10
      IF n% > 40 THEN n% = 10
      CALL Gen
    CASE "P"
      pat% = pat% + 1
      IF pat% > 3 THEN pat% = 1
      CALL Gen
    CASE "+"
      dl! = dl! / 1.6
      IF dl! < .002 THEN dl! = .002
    CASE "-"
      dl! = dl! * 1.6
      IF dl! > .5 THEN dl! = .5
    CASE CHR$(27)
      EXIT DO
  END SELECT
  IF abort% <> 0 THEN EXIT DO
LOOP

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

SUB Bubble
  FOR i% = 1 TO n% - 1
    sw% = 0
    FOR j% = 1 TO n% - i%
      cmp& = cmp& + 1
      CALL Hilite(j%, j% + 1)
      IF a%(j%) > a%(j% + 1) THEN
        CALL SwapEl(j%, j% + 1)
        sw% = 1
      END IF
    NEXT j%
    IF sw% = 0 THEN EXIT FOR
  NEXT i%
END SUB

SUB Delay (secs!)
  t! = TIMER
  DO
    d! = TIMER - t!
    IF d! < 0 THEN d! = d! + 86400
  LOOP UNTIL d! >= secs!
END SUB

SUB DrawAll
  CLS
  COLOR 15
  LOCATE 1, 1
  PRINT "G12 Sort It (PAI PAI KAN)  items:"; n%; "  data: ";
  SELECT CASE pat%
    CASE 1
      PRINT "random"
    CASE 2
      PRINT "reversed"
    CASE ELSE
      PRINT "nearly sorted"
  END SELECT
  COLOR 7
  LOCATE 2, 1
  PRINT "B bubble  I insertion  S selection  M merge  R race  N new  D size  P pattern"
  FOR i% = 1 TO n%
    CALL DrawBar(i%, 9)
  NEXT i%
  CALL Stat
  COLOR 7
  LOCATE 30, 1
  PRINT "+/- speed   ESC = menu                                          ";
END SUB

SUB DrawBar (i%, c%)
  w% = 600 \ n%
  x% = 20 + (i% - 1) * w%
  h% = a%(i%) * 360 \ n%
  LINE (x%, 40)-(x% + w% - 3, 400), 0, BF
  IF h% > 0 THEN LINE (x%, 400 - h%)-(x% + w% - 3, 400), c%, BF
END SUB

SUB Finish
  IF fast% <> 0 THEN EXIT SUB
  FOR i% = 1 TO n%
    CALL DrawBar(i%, 10)
    IF abort% = 0 THEN CALL Delay(.01)
  NEXT i%
  CALL Stat
END SUB

SUB Gen
  FOR i% = 1 TO n%
    bs%(i%) = i%
  NEXT i%
  SELECT CASE pat%
    CASE 1
      FOR i% = n% TO 2 STEP -1
        j% = INT(RND * i%) + 1
        SWAP bs%(i%), bs%(j%)
      NEXT i%
    CASE 2
      FOR i% = 1 TO n%
        bs%(i%) = n% + 1 - i%
      NEXT i%
    CASE ELSE
      FOR t% = 1 TO 3
        i% = INT(RND * (n% - 1)) + 1
        SWAP bs%(i%), bs%(i% + 1)
      NEXT t%
  END SELECT
  cmp& = 0
  mv& = 0
  cur$ = ""
  CALL ResetData
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION

SUB Hilite (i%, j%)
  IF fast% <> 0 THEN EXIT SUB
  CALL DrawBar(i%, 12)
  CALL DrawBar(j%, 12)
  CALL Stat
  CALL Pause
  CALL DrawBar(i%, 9)
  CALL DrawBar(j%, 9)
END SUB

SUB Insertion
  FOR i% = 2 TO n%
    kv% = a%(i%)
    j% = i% - 1
    DO WHILE j% >= 1
      cmp& = cmp& + 1
      CALL Hilite(j%, j% + 1)
      IF a%(j%) > kv% THEN
        CALL SetVal(j% + 1, a%(j%))
        mv& = mv& + 1
        j% = j% - 1
      ELSE
        EXIT DO
      END IF
    LOOP
    CALL SetVal(j% + 1, kv%)
    mv& = mv& + 1
  NEXT i%
END SUB

SUB MSort (lo%, hi%)
  IF lo% >= hi% THEN EXIT SUB
  md% = (lo% + hi%) \ 2
  CALL MSort(lo%, md%)
  CALL MSort(md% + 1, hi%)
  i% = lo%
  j% = md% + 1
  k% = lo%
  DO WHILE i% <= md% AND j% <= hi%
    cmp& = cmp& + 1
    IF a%(i%) <= a%(j%) THEN
      tm%(k%) = a%(i%)
      i% = i% + 1
    ELSE
      tm%(k%) = a%(j%)
      j% = j% + 1
    END IF
    k% = k% + 1
  LOOP
  DO WHILE i% <= md%
    tm%(k%) = a%(i%)
    i% = i% + 1
    k% = k% + 1
  LOOP
  DO WHILE j% <= hi%
    tm%(k%) = a%(j%)
    j% = j% + 1
    k% = k% + 1
  LOOP
  FOR k% = lo% TO hi%
    CALL SetVal(k%, tm%(k%))
    mv& = mv& + 1
    CALL Hilite(k%, k%)
  NEXT k%
END SUB

SUB Pause
  IF fast% <> 0 THEN EXIT SUB
  k$ = INKEY$
  IF k$ = CHR$(27) THEN abort% = 1
  IF k$ = "+" THEN
    dl! = dl! / 1.6
    IF dl! < .002 THEN dl! = .002
  END IF
  IF k$ = "-" THEN
    dl! = dl! * 1.6
    IF dl! > .5 THEN dl! = .5
  END IF
  IF abort% = 0 THEN CALL Delay(dl!)
END SUB

SUB Race
  LOCATE 28, 1
  COLOR 14
  PRINT "RACE: which method needs the fewest steps (compares+moves)?  B I S M   ";
  g$ = UCASE$(GetKey$)
  IF g$ = CHR$(27) THEN
    abort% = 1
    EXIT SUB
  END IF
  gi% = INSTR("BISM", g$)
  IF gi% = 0 OR LEN(g$) <> 1 THEN EXIT SUB
  fast% = 1
  FOR m% = 1 TO 4
    CALL RunSort(m%)
    rc&(m%) = cmp&
    rm&(m%) = mv&
  NEXT m%
  fast% = 0
  CALL ResetData
  best% = 1
  FOR m% = 2 TO 4
    IF rc&(m%) + rm&(m%) < rc&(best%) + rm&(best%) THEN best% = m%
  NEXT m%
  CLS
  COLOR 15
  LOCATE 3, 5: PRINT "RACE RESULT  ("; n%; "items, same data for every method)"
  COLOR 7
  LOCATE 5, 5: PRINT "Method        Compares     Moves     Total"
  FOR m% = 1 TO 4
    IF m% = best% THEN COLOR 10 ELSE COLOR 7
    LOCATE 6 + m%, 5
    PRINT LEFT$(nm$(m%) + SPACE$(12), 12); rc&(m%); rm&(m%); rc&(m%) + rm&(m%)
  NEXT m%
  COLOR 14
  LOCATE 13, 5
  IF gi% = best% THEN
    PRINT "You guessed right! Winner: "; nm$(best%)
  ELSE
    PRINT "Not quite. Winner: "; nm$(best%); "   (you chose "; nm$(gi%); ")"
  END IF
  COLOR 7
  LOCATE 15, 5: PRINT "Bubble and selection need about n*n/2 compares; merge needs about n*log2(n)."
  LOCATE 16, 5: PRINT "Insertion is fast when the data is already nearly sorted."
  LOCATE 30, 1: PRINT "Press any key";
  k$ = GetKey$
  IF k$ = CHR$(27) THEN abort% = 1
END SUB

SUB ResetData
  FOR i% = 1 TO n%
    a%(i%) = bs%(i%)
  NEXT i%
END SUB

SUB RunSort (m%)
  cmp& = 0
  mv& = 0
  cur$ = nm$(m%)
  CALL ResetData
  IF fast% = 0 THEN CALL DrawAll
  SELECT CASE m%
    CASE 1
      CALL Bubble
    CASE 2
      CALL Insertion
    CASE 3
      CALL Selection
    CASE ELSE
      CALL MSort(1, n%)
  END SELECT
  CALL Finish
  IF fast% = 0 THEN
    LOCATE 29, 1
    COLOR 15
    PRINT "Done. Press any key.";
    k$ = GetKey$
    IF k$ = CHR$(27) THEN abort% = 1
  END IF
END SUB

SUB Selection
  FOR i% = 1 TO n% - 1
    m% = i%
    FOR j% = i% + 1 TO n%
      cmp& = cmp& + 1
      CALL Hilite(j%, m%)
      IF a%(j%) < a%(m%) THEN m% = j%
    NEXT j%
    IF m% <> i% THEN CALL SwapEl(i%, m%)
  NEXT i%
END SUB

SUB SetVal (i%, v%)
  a%(i%) = v%
  IF fast% = 0 THEN CALL DrawBar(i%, 9)
END SUB

SUB Stat
  COLOR 14
  LOCATE 27, 1
  PRINT LEFT$(cur$ + SPACE$(12), 12); " compares:"; cmp&; "  moves:"; mv&; "        ";
END SUB

SUB SwapEl (i%, j%)
  SWAP a%(i%), a%(j%)
  mv& = mv& + 1
  IF fast% = 0 THEN
    CALL DrawBar(i%, 9)
    CALL DrawBar(j%, 9)
  END IF
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 28: PRINT "G12  SORT IT  (PAI PAI KAN)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "SORTING METHODS. Watch bubble, insertion, selection and merge sort"
  LOCATE 8, 6: PRINT "put bars in order, and compare how many comparisons and moves they need."
  COLOR 7
  LOCATE 11, 6: PRINT "Controls:"
  LOCATE 12, 6: PRINT "B / I / S / M = bubble / insertion / selection / merge sort"
  LOCATE 13, 6: PRINT "R = race: guess which method finishes with the fewest steps"
  LOCATE 14, 6: PRINT "N = new data   D = number of bars   P = random / reversed / nearly sorted"
  LOCATE 15, 6: PRINT "+ / - = speed      ESC = back to the main menu"
  COLOR 14
  LOCATE 19, 6: PRINT "Press any key to start..."
  k$ = GetKey$
END SUB
