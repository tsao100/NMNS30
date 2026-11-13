' G02.BAS - Detective & Thief (ZHEN TAN YU GUAI DAO)
' Educational content: role play; logical reasoning by asking yes/no questions and
' eliminating suspects (classification by several attributes).
' Controls: 1-6 ask a question, A then 1-6 = accuse a suspect, ESC = menu.
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (maxlen%)
DECLARE FUNCTION Attr% (i%, q%)
DECLARE FUNCTION QText$ (q%)
DECLARE SUB DrawSuspects ()
DECLARE SUB Msg (s$, c%)
DECLARE SUB NewCase ()

DIM SHARED hat%(1 TO 6), gl%(1 TO 6), sc%(1 TO 6), tl%(1 TO 6), cut%(1 TO 6)
DIM SHARED thief%, quit%, revealed%
RANDOMIZE TIMER
SCREEN 12
CLS
COLOR 14
LOCATE 2, 1: PRINT "G02 Detective & Thief (ZHEN TAN YU GUAI DAO)"
COLOR 15
LOCATE 4, 1: PRINT "What you learn (1991 puzzle room): role-playing and logical reasoning."
COLOR 7
LOCATE 6, 1: PRINT "A thief has stolen a fossil from the museum!  You are the detective."
LOCATE 7, 1: PRINT "Six suspects are lined up.  Each differs in four ways:"
LOCATE 8, 1: PRINT "   hat, glasses, scarf colour (red/blue/green), and height."
LOCATE 9, 1: PRINT "Ask the witness yes/no questions about the thief.  After each answer"
LOCATE 10, 1: PRINT "suspects who do not fit are crossed out."
LOCATE 11, 1: PRINT "The fewer questions you ask, the higher your score (100 - 12 per question)."
LOCATE 12, 1: PRINT "A wrong accusation scores 0.  Three cases in all."
LOCATE 14, 1: PRINT "Keys:  1-6 ask a question    A = accuse    ESC = menu"
COLOR 11
LOCATE 17, 1: PRINT "Press any key to start"
k$ = GetKey$
IF k$ = CHR$(27) THEN GOTO ExitGame

total% = 0
FOR cs% = 1 TO 3
  CALL NewCase
  nq% = 0
  done% = 0
  CALL DrawSuspects
  CALL Msg("Case" + STR$(cs%) + ": ask a question (1-6) or press A to accuse.", 10)
  DO
    k$ = GetKey$
    IF k$ = CHR$(27) THEN GOTO ExitGame
    q% = VAL(k$)
    IF q% >= 1 AND q% <= 6 AND LEN(k$) = 1 THEN
      nq% = nq% + 1
      ans% = Attr%(thief%, q%)
      FOR i% = 1 TO 6
        IF Attr%(i%, q%) <> ans% THEN cut%(i%) = 1
      NEXT i%
      CALL DrawSuspects
      IF ans% = 1 THEN a$ = "YES" ELSE a$ = "NO"
      CALL Msg("Q" + STR$(nq%) + ": " + QText$(q%) + "  Witness: " + a$, 14)
    ELSEIF UCASE$(k$) = "A" THEN
      CALL Msg("Accuse which suspect (1-6)?  (any other key cancels)", 12)
      k$ = GetKey$
      IF k$ = CHR$(27) THEN GOTO ExitGame
      w% = VAL(k$)
      IF w% >= 1 AND w% <= 6 AND LEN(k$) = 1 THEN
        done% = 1
        revealed% = 1
        CALL DrawSuspects
        IF w% = thief% THEN
          pts% = 100 - 12 * nq%
          IF pts% < 10 THEN pts% = 10
          total% = total% + pts%
          CALL Msg("Caught the thief!  Questions:" + STR$(nq%) + "  Score +" + STR$(pts%), 10)
        ELSE
          CALL Msg("Wrong!  The thief was suspect" + STR$(thief%) + ".  Score +0", 12)
        END IF
      ELSE
        CALL Msg("Accusation cancelled.", 7)
      END IF
    END IF
  LOOP UNTIL done% = 1
  CALL Delay(1)
  LOCATE 29, 1: PRINT "Press any key for the next case (ESC = menu)   Total:"; total%; "    ";
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
NEXT cs%

CLS
COLOR 14
LOCATE 4, 1: PRINT "All cases closed.  Total score:"; total%; "/ 300"
COLOR 7
LOCATE 6, 1
IF total% >= 220 THEN
  PRINT "Master detective!"
ELSEIF total% >= 120 THEN
  PRINT "Good detective work."
ELSE
  PRINT "Try asking questions that split the suspects in half."
END IF
LOCATE 8, 1: PRINT "Press any key to return to the menu."
k$ = GetKey$

ExitGame:
SCREEN 0: WIDTH 80: COLOR 7, 0: CLS
ON ERROR GOTO NoMenu
RUN "MENU.BAS"
NoMenu:
END

' q: 1 hat, 2 glasses, 3 red scarf, 4 blue scarf, 5 green scarf, 6 tall
FUNCTION Attr% (i%, q%)
  r% = 0
  SELECT CASE q%
    CASE 1: r% = hat%(i%)
    CASE 2: r% = gl%(i%)
    CASE 3: IF sc%(i%) = 1 THEN r% = 1
    CASE 4: IF sc%(i%) = 2 THEN r% = 1
    CASE 5: IF sc%(i%) = 3 THEN r% = 1
    CASE 6: r% = tl%(i%)
  END SELECT
  Attr% = r%
END FUNCTION

FUNCTION QText$ (q%)
  SELECT CASE q%
    CASE 1: QText$ = "Is the thief wearing a hat?"
    CASE 2: QText$ = "Does the thief wear glasses?"
    CASE 3: QText$ = "Is the scarf red?"
    CASE 4: QText$ = "Is the scarf blue?"
    CASE 5: QText$ = "Is the scarf green?"
    CASE 6: QText$ = "Is the thief tall?"
    CASE ELSE: QText$ = ""
  END SELECT
END FUNCTION

SUB NewCase
  DIM code%(0 TO 23)
  FOR i% = 0 TO 23
    code%(i%) = i%
  NEXT i%
  FOR i% = 23 TO 1 STEP -1
    j% = INT(RND * (i% + 1))
    t% = code%(i%): code%(i%) = code%(j%): code%(j%) = t%
  NEXT i%
  FOR i% = 1 TO 6
    c% = code%(i% - 1)
    hat%(i%) = c% AND 1
    gl%(i%) = (c% \ 2) AND 1
    tl%(i%) = (c% \ 4) AND 1
    sc%(i%) = (c% \ 8) + 1
    cut%(i%) = 0
  NEXT i%
  thief% = INT(RND * 6) + 1
  revealed% = 0
END SUB

SUB DrawSuspects
  CLS
  COLOR 14
  LOCATE 1, 1: PRINT "G02 Detective & Thief (ZHEN TAN YU GUAI DAO)";
  alive% = 0
  FOR i% = 1 TO 6
    x% = 60 + (i% - 1) * 104
    IF tl%(i%) = 1 THEN bh% = 130 ELSE bh% = 90
    hy% = 280 - bh% - 18
    LINE (x% - 14, 280 - bh%)-(x% + 14, 280), 8, BF
    SELECT CASE sc%(i%)
      CASE 1: scc% = 12
      CASE 2: scc% = 9
      CASE ELSE: scc% = 10
    END SELECT
    LINE (x% - 17, 280 - bh% - 2)-(x% + 17, 280 - bh% + 8), scc%, BF
    CIRCLE (x%, hy%), 16, 14
    PAINT (x%, hy%), 14, 14
    PSET (x% - 5, hy% - 6), 0
    PSET (x% + 5, hy% - 6), 0
    LINE (x% - 4, hy% + 7)-(x% + 4, hy% + 7), 4
    IF hat%(i%) = 1 THEN
      LINE (x% - 12, hy% - 30)-(x% + 12, hy% - 15), 6, BF
      LINE (x% - 20, hy% - 15)-(x% + 20, hy% - 14), 6, BF
    END IF
    IF gl%(i%) = 1 THEN
      CIRCLE (x% - 6, hy% - 6), 5, 0
      CIRCLE (x% + 6, hy% - 6), 5, 0
      LINE (x% - 1, hy% - 6)-(x% + 1, hy% - 6), 0
    END IF
    IF cut%(i%) = 1 THEN
      LINE (x% - 30, 70)-(x% + 30, 280), 12
      LINE (x% + 30, 70)-(x% - 30, 280), 12
    ELSE
      alive% = alive% + 1
    END IF
    COLOR 15
    LOCATE 19, (x% \ 8) + 1
    PRINT USING "#"; i%;
    IF revealed% = 1 AND i% = thief% THEN
      COLOR 12
      LOCATE 20, (x% \ 8) - 1
      PRINT "THIEF!";
    END IF
  NEXT i%
  COLOR 7
  LOCATE 22, 1: PRINT "1 Hat?  2 Glasses?  3 Red scarf?  4 Blue scarf?  5 Green scarf?  6 Tall?";
  LOCATE 23, 1: PRINT "A = accuse     Suspects still possible:"; alive%; "  ";
  COLOR 8
  LOCATE 30, 1: PRINT "ESC = menu";
  COLOR 15
END SUB

SUB Msg (s$, c%)
  COLOR c%
  LOCATE 26, 1
  PRINT LEFT$(s$ + SPACE$(79), 79);
  COLOR 15
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
