' G08.BAS - Tic-Tac-Toe (JING ZI YOU XI)
' Educational content (1991 article): train arithmetic, intelligence and general knowledge.
' Controls: D = easy/hard, Q = math quiz on/off at the setup screen, ENTER = start.
'           In play: answer the quiz, then press 1-9 to place your X.  ESC = back to menu.
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (maxlen%)
DECLARE FUNCTION IsNum% (s$)
DECLARE FUNCTION LineWin% ()
DECLARE FUNCTION Minimax% (who%, depth%)
DECLARE FUNCTION AskQuiz% ()
DECLARE SUB Msg (s$)
DECLARE SUB ClearRows (r1%, r2%)
DECLARE SUB DrawBoard ()
DECLARE SUB Panel ()
DECLARE SUB PlayerTurn ()
DECLARE SUB ComputerTurn ()
DECLARE SUB LoadData ()

DIM SHARED b%(1 TO 9), wl%(1 TO 8, 1 TO 3), cand%(1 TO 9)
DIM SHARED gq$(1 TO 10), go$(1 TO 10, 1 TO 3), ga%(1 TO 10)
DIM SHARED quit%, score%, qscore%, hard%, quizon%, gno%, wline%, qright%, qasked%
DIM SHARED wins%, losses%, draws%

' general knowledge questions: question, three options, number of the right option
DATA "Which planet is closest to the Sun?", "Mercury", "Venus", "Mars", 1
DATA "How many legs does a spider have?", "6", "8", "10", 2
DATA "At sea level water boils at how many degrees Celsius?", "90", "100", "120", 2
DATA "Which is the largest ocean?", "Atlantic", "Indian", "Pacific", 3
DATA "How many sides does a hexagon have?", "5", "6", "8", 2
DATA "Which gas do plants take in from the air?", "Oxygen", "Nitrogen", "Carbon dioxide", 3
DATA "What is the capital of Japan?", "Tokyo", "Osaka", "Kyoto", 1
DATA "How many minutes are there in 2 hours?", "100", "120", "180", 2
DATA "Which of these animals is a mammal?", "Shark", "Frog", "Whale", 3
DATA "Which is the hardest natural material?", "Gold", "Diamond", "Iron", 2
' the eight winning lines
DATA 1,2,3, 4,5,6, 7,8,9, 1,4,7, 2,5,8, 3,6,9, 1,5,9, 3,5,7

RANDOMIZE TIMER
SCREEN 12
CLS
CALL LoadData
COLOR 14
LOCATE 2, 1: PRINT "G08 Tic-Tac-Toe (JING ZI YOU XI)"
COLOR 15
LOCATE 4, 1: PRINT "What you learn (1991 puzzle room): practise arithmetic, train your"
LOCATE 5, 1: PRINT "intelligence (planning ahead) and test your general knowledge."
COLOR 7
LOCATE 7, 1: PRINT "You are X, the computer is O.  Get three in a row to win."
LOCATE 8, 1: PRINT "Before each of your moves a quiz question appears: a quick sum"
LOCATE 9, 1: PRINT "(+ - * /) or sometimes a general-knowledge question."
LOCATE 10, 1: PRINT "Answer correctly to place your X; a wrong answer loses your turn."
LOCATE 11, 1: PRINT "Squares are numbered 1-9, left to right, top to bottom."
LOCATE 12, 1: PRINT "Five games; the first mover alternates.  Win 10 (hard 15), draw 4,"
LOCATE 13, 1: PRINT "and every right answer gives 2 bonus points."
COLOR 11
LOCATE 16, 1: PRINT "Press any key for setup, ESC = menu"
k$ = GetKey$
IF k$ = CHR$(27) THEN GOTO ExitGame

hard% = 1: quizon% = 1
DO
  CLS
  COLOR 14
  LOCATE 3, 1: PRINT "Setup"
  COLOR 15
  LOCATE 5, 1: PRINT "D  Difficulty : ";
  IF hard% = 1 THEN PRINT "HARD (computer never loses) " ELSE PRINT "EASY (computer plays loosely)"
  LOCATE 6, 1: PRINT "Q  Quiz       : ";
  IF quizon% = 1 THEN PRINT "ON  (answer to move)   " ELSE PRINT "OFF (just play)        "
  COLOR 11
  LOCATE 9, 1: PRINT "Press D or Q to change, ENTER to start, ESC = menu"
  k$ = UCASE$(GetKey$)
  IF k$ = CHR$(27) THEN GOTO ExitGame
  IF k$ = "D" THEN hard% = 1 - hard%
  IF k$ = "Q" THEN quizon% = 1 - quizon%
LOOP UNTIL k$ = CHR$(13)

score% = 0: qscore% = 0: wins% = 0: losses% = 0: draws% = 0
qright% = 0: qasked% = 0: quit% = 0
FOR gno% = 1 TO 5
  FOR i% = 1 TO 9
    b%(i%) = 0
  NEXT i%
  wline% = 0
  IF gno% MOD 2 = 1 THEN turn% = 1 ELSE turn% = 2
  over% = 0
  CLS
  CALL DrawBoard
  CALL Panel
  DO
    IF turn% = 1 THEN
      CALL PlayerTurn
      IF quit% THEN GOTO ExitGame
    ELSE
      CALL ComputerTurn
    END IF
    wline% = LineWin%
    full% = 1
    FOR i% = 1 TO 9
      IF b%(i%) = 0 THEN full% = 0
    NEXT i%
    CALL DrawBoard
    IF wline% > 0 OR full% = 1 THEN over% = 1
    turn% = 3 - turn%
  LOOP UNTIL over% = 1
  CALL DrawBoard
  IF wline% > 0 THEN
    IF b%(wl%(wline%, 1)) = 1 THEN
      wins% = wins% + 1
      score% = score% + 10 + 5 * hard%
      CALL Msg("You win this game!  +" + LTRIM$(STR$(10 + 5 * hard%)) + " points.  Press a key.")
    ELSE
      losses% = losses% + 1
      CALL Msg("The computer wins this game.  Press a key.")
    END IF
  ELSE
    draws% = draws% + 1
    score% = score% + 4
    CALL Msg("A draw.  +4 points.  Press a key.")
  END IF
  CALL Panel
  k$ = GetKey$
  IF k$ = CHR$(27) THEN GOTO ExitGame
NEXT gno%

CLS
COLOR 14
total% = score% + qscore%
LOCATE 3, 1: PRINT "Match over!  Total score:"; total%
COLOR 7
LOCATE 5, 1: PRINT "Wins"; wins%; "  Draws"; draws%; "  Losses"; losses%
LOCATE 6, 1: PRINT "Quiz answers right:"; qright%; "of"; qasked%; "  (bonus"; qscore%; ")"
LOCATE 8, 1
IF total% >= 60 THEN
  PRINT "Rating: GRAND MASTER of noughts and crosses!"
ELSEIF total% >= 35 THEN
  PRINT "Rating: Clever player."
ELSE
  PRINT "Rating: Keep practising - look two moves ahead!"
END IF
LOCATE 10, 1: PRINT "Press any key to return to the menu."
k$ = GetKey$

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

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
  AskQuiz% = res%
END FUNCTION

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

' 1 if s$ is 1 to 5 digits
FUNCTION IsNum% (s$)
  IsNum% = 0
  IF LEN(s$) < 1 OR LEN(s$) > 5 THEN EXIT FUNCTION
  FOR i% = 1 TO LEN(s$)
    c$ = MID$(s$, i%, 1)
    IF c$ < "0" OR c$ > "9" THEN EXIT FUNCTION
  NEXT i%
  IsNum% = 1
END FUNCTION

SUB LoadData
  FOR i% = 1 TO 10
    READ gq$(i%), go$(i%, 1), go$(i%, 2), go$(i%, 3), ga%(i%)
  NEXT i%
  FOR i% = 1 TO 8
    READ wl%(i%, 1), wl%(i%, 2), wl%(i%, 3)
  NEXT i%
END SUB

SUB Msg (s$)
  COLOR 10
  LOCATE 29, 1
  PRINT LEFT$(s$ + SPACE$(79), 79);
  COLOR 15
END SUB

SUB ClearRows (r1%, r2%)
  FOR r% = r1% TO r2%
    IF r% >= 1 AND r% <= 30 THEN
      LOCATE r%, 1: PRINT SPACE$(79);
    END IF
  NEXT r%
END SUB

' index (1-8) of a complete line, or 0
FUNCTION LineWin% ()
  LineWin% = 0
  FOR i% = 1 TO 8
    a% = b%(wl%(i%, 1))
    IF a% <> 0 THEN
      IF a% = b%(wl%(i%, 2)) AND a% = b%(wl%(i%, 3)) THEN
        LineWin% = i%
        EXIT FUNCTION
      END IF
    END IF
  NEXT i%
END FUNCTION

' value for the computer (O = 2): positive = computer wins, negative = player wins
FUNCTION Minimax% (who%, depth%)
  w% = LineWin%
  IF w% > 0 THEN
    IF b%(wl%(w%, 1)) = 2 THEN Minimax% = 10 - depth% ELSE Minimax% = depth% - 10
    EXIT FUNCTION
  END IF
  free% = 0
  IF who% = 2 THEN best% = -100 ELSE best% = 100
  FOR i% = 1 TO 9
    IF b%(i%) = 0 THEN
      free% = free% + 1
      b%(i%) = who%
      v% = Minimax%(3 - who%, depth% + 1)
      b%(i%) = 0
      IF who% = 2 AND v% > best% THEN best% = v%
      IF who% = 1 AND v% < best% THEN best% = v%
    END IF
  NEXT i%
  IF free% = 0 THEN best% = 0
  Minimax% = best%
END FUNCTION

SUB DrawBoard
  ox% = 60: oy% = 70
  LINE (ox% - 10, oy% - 10)-(ox% + 250, oy% + 250), 0, BF
  LINE (ox% + 80, oy%)-(ox% + 80, oy% + 240), 7
  LINE (ox% + 160, oy%)-(ox% + 160, oy% + 240), 7
  LINE (ox%, oy% + 80)-(ox% + 240, oy% + 80), 7
  LINE (ox%, oy% + 160)-(ox% + 240, oy% + 160), 7
  FOR i% = 1 TO 9
    r% = (i% - 1) \ 3
    c% = (i% - 1) MOD 3
    cx% = ox% + c% * 80 + 40
    cy% = oy% + r% * 80 + 40
    IF b%(i%) = 1 THEN
      LINE (cx% - 24, cy% - 24)-(cx% + 24, cy% + 24), 12
      LINE (cx% - 24, cy% + 24)-(cx% + 24, cy% - 24), 12
    ELSEIF b%(i%) = 2 THEN
      CIRCLE (cx%, cy%), 26, 11
    ELSE
      COLOR 8
      LOCATE cy% \ 16 + 1, cx% \ 8 + 1: PRINT LTRIM$(STR$(i%));
    END IF
  NEXT i%
  IF wline% > 0 THEN
    a% = wl%(wline%, 1) - 1
    z% = wl%(wline%, 3) - 1
    x1% = ox% + (a% MOD 3) * 80 + 40: y1% = oy% + (a% \ 3) * 80 + 40
    x2% = ox% + (z% MOD 3) * 80 + 40: y2% = oy% + (z% \ 3) * 80 + 40
    LINE (x1%, y1%)-(x2%, y2%), 10
  END IF
  COLOR 8
  LOCATE 30, 1: PRINT "ESC = menu";
  COLOR 15
END SUB

SUB Panel
  COLOR 14
  LOCATE 2, 45: PRINT "G08 Tic-Tac-Toe";
  COLOR 15
  LOCATE 4, 45: PRINT "Game"; gno%; "of 5   ";
  IF hard% = 1 THEN LOCATE 5, 45: PRINT "Level: HARD  " ELSE LOCATE 5, 45: PRINT "Level: EASY  "
  IF quizon% = 1 THEN LOCATE 6, 45: PRINT "Quiz: ON  " ELSE LOCATE 6, 45: PRINT "Quiz: OFF "
  LOCATE 8, 45: PRINT "Score:"; score% + qscore%; "    ";
  LOCATE 9, 45: PRINT "W"; wins%; " D"; draws%; " L"; losses%; "   ";
  COLOR 7
  LOCATE 11, 45: PRINT "You = X (red)";
  LOCATE 12, 45: PRINT "Computer = O (blue)";
  COLOR 15
END SUB

' ask one question; 1 = right, 0 = wrong; ESC sets quit%
FUNCTION AskQuiz% ()
  AskQuiz% = 0
  CALL ClearRows(22, 28)
  COLOR 15
  IF INT(RND * 4) = 0 THEN
    ' general knowledge
    q% = INT(RND * 10) + 1
    LOCATE 22, 1: PRINT "Knowledge: "; gq$(q%);
    LOCATE 23, 1: PRINT "  1) "; go$(q%, 1); "   2) "; go$(q%, 2); "   3) "; go$(q%, 3);
    LOCATE 24, 1: PRINT "Your answer (1, 2 or 3): ";
    DO
      k$ = GetKey$
      IF k$ = CHR$(27) THEN
        quit% = 1
        EXIT FUNCTION
      END IF
    LOOP UNTIL k$ = "1" OR k$ = "2" OR k$ = "3"
    qasked% = qasked% + 1
    IF VAL(k$) = ga%(q%) THEN
      AskQuiz% = 1
    ELSE
      CALL Msg("Wrong. The answer was " + go$(q%, ga%(q%)) + ".")
    END IF
  ELSE
    t% = INT(RND * 4)
    SELECT CASE t%
      CASE 0
        a% = INT(RND * 50) + 10: b2% = INT(RND * 50) + 10
        ans% = a% + b2%: op$ = "+"
      CASE 1
        a% = INT(RND * 50) + 20: b2% = INT(RND * (a% - 1)) + 1
        ans% = a% - b2%: op$ = "-"
      CASE 2
        a% = INT(RND * 8) + 2: b2% = INT(RND * 8) + 2
        ans% = a% * b2%: op$ = "*"
      CASE ELSE
        b2% = INT(RND * 8) + 2: ans% = INT(RND * 9) + 2
        a% = b2% * ans%: op$ = "/"
    END SELECT
    q$ = "Math: " + LTRIM$(STR$(a%)) + " " + op$ + " " + LTRIM$(STR$(b2%)) + " = ? "
    LOCATE 22, 1: PRINT q$;
    s$ = ReadLine$(5)
    IF quit% THEN EXIT FUNCTION
    qasked% = qasked% + 1
    IF IsNum%(s$) = 1 THEN
      IF VAL(s$) = ans% THEN AskQuiz% = 1
    END IF
    IF AskQuiz% = 0 THEN CALL Msg("Wrong. The answer was" + STR$(ans%) + ".")
  END IF
  IF AskQuiz% = 1 THEN
    qright% = qright% + 1
    qscore% = qscore% + 2
    CALL Msg("Correct! +2 bonus points.")
  END IF
END FUNCTION

SUB PlayerTurn
  ok% = 1
  IF quizon% = 1 THEN
    r% = AskQuiz%
    IF quit% THEN EXIT SUB
    CALL Panel
    IF r% = 0 THEN ok% = 0
    CALL Delay(1.2)
    CALL ClearRows(22, 28)
  END IF
  IF ok% = 0 THEN
    CALL Msg("Your turn is lost because of the wrong answer.")
    CALL Delay(1.5)
    EXIT SUB
  END IF
  CALL Msg("Your move: press a square number 1-9.")
  DO
    k$ = GetKey$
    IF k$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    END IF
    sq% = 0
    IF LEN(k$) = 1 THEN
      IF k$ >= "1" AND k$ <= "9" THEN sq% = VAL(k$)
    END IF
    placed% = 0
    IF sq% >= 1 AND sq% <= 9 THEN
      IF b%(sq%) = 0 THEN
        b%(sq%) = 1
        placed% = 1
      ELSE
        CALL Msg("That square is taken. Press another number.")
      END IF
    END IF
  LOOP UNTIL placed% = 1
  CALL Msg("")
END SUB

SUB ComputerTurn
  CALL Msg("The computer is thinking...")
  mv% = 0
  free% = 0
  FOR i% = 1 TO 9
    IF b%(i%) = 0 THEN free% = free% + 1
  NEXT i%
  IF free% = 0 THEN EXIT SUB
  ' take an immediate win if there is one (both levels)
  FOR i% = 1 TO 9
    IF mv% = 0 AND b%(i%) = 0 THEN
      b%(i%) = 2
      IF LineWin% > 0 THEN mv% = i%
      b%(i%) = 0
    END IF
  NEXT i%
  IF mv% = 0 AND hard% = 1 THEN
    IF free% = 8 THEN
      ' first reply: centre if free, otherwise a corner (the known safe answer)
      IF b%(5) = 0 THEN mv% = 5 ELSE mv% = 1
    ELSEIF free% = 9 THEN
      ' empty board: search would be slow, so choose a corner or the centre
      mv% = 1
      SELECT CASE INT(RND * 5)
        CASE 0: mv% = 1
        CASE 1: mv% = 3
        CASE 2: mv% = 5
        CASE 3: mv% = 7
        CASE ELSE: mv% = 9
      END SELECT
    ELSE
      best% = -1000
      nb% = 0
      FOR i% = 1 TO 9
        IF b%(i%) = 0 THEN
          b%(i%) = 2
          v% = Minimax%(1, 1)
          b%(i%) = 0
          IF v% > best% THEN
            best% = v%
            nb% = 1
            cand%(1) = i%
          ELSEIF v% = best% THEN
            nb% = nb% + 1
            cand%(nb%) = i%
          END IF
        END IF
      NEXT i%
      IF nb% >= 1 THEN mv% = cand%(INT(RND * nb%) + 1)
    END IF
  END IF
  IF mv% = 0 THEN
    ' easy level (or fallback): a random free square
    pick% = INT(RND * free%) + 1
    FOR i% = 1 TO 9
      IF b%(i%) = 0 THEN
        pick% = pick% - 1
        IF pick% = 0 AND mv% = 0 THEN mv% = i%
      END IF
    NEXT i%
  END IF
  IF mv% >= 1 AND mv% <= 9 THEN
    IF b%(mv%) = 0 THEN b%(mv%) = 2
  END IF
  CALL Delay(.6)
  CALL Msg("")
END SUB
