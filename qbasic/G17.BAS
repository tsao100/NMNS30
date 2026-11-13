' G17.BAS - Home Run (QIANG BANG CHU JI)
' Educational content (1991 list): guessing a 4-digit number made of different digits -
'   permutations and elimination.
' Controls: type a 4-digit guess + Enter, L = list the possible numbers (when 24 or fewer),
'   Backspace edits, ESC = menu
DECLARE SUB Delay (secs!)
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION ReadLine$ (r%, c%, mx%)
DECLARE SUB Title ()
DECLARE SUB Msg (t$)
DECLARE SUB DrawAll ()
DECLARE SUB DrawDiamond (h%)
DECLARE SUB ScoreGuess (a%, b%, h%, bl%)
DECLARE SUB PlayGame ()
DECLARE FUNCTION Distinct% (v%)
DECLARE FUNCTION ValidGuess% (a$)
DECLARE FUNCTION Fmt4$ (v%)

DIM SHARED cand%(0 TO 5039), hg%(1 TO 10), hh%(1 TO 10), hb%(1 TO 10), hr%(1 TO 10)
DIM SHARED da%(1 TO 4), db%(1 TO 4)
DIM SHARED ncand%, sec%, g%, gv%, lh%, tot%, wins%, quit%
RANDOMIZE TIMER
SCREEN 12
tot% = 0
wins% = 0
CALL Title
IF quit% <> 0 THEN GOTO ExitGame
DO
  CALL PlayGame
  IF quit% <> 0 THEN EXIT DO
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

' Four different digits? (leading zero allowed, so 10*9*8*7 = 5040 numbers)
FUNCTION Distinct% (v%)
  da%(1) = v% \ 1000
  da%(2) = (v% \ 100) MOD 10
  da%(3) = (v% \ 10) MOD 10
  da%(4) = v% MOD 10
  Distinct% = 1
  FOR i% = 1 TO 3
    FOR j% = i% + 1 TO 4
      IF da%(i%) = da%(j%) THEN Distinct% = 0
    NEXT j%
  NEXT i%
END FUNCTION

SUB DrawAll
  CLS
  COLOR 15
  LOCATE 1, 1: PRINT "G17 Home Run (QIANG BANG CHU JI)   games won:"; wins%; "  total score:"; tot%;
  COLOR 7
  LOCATE 2, 1: PRINT "Secret: 4 DIFFERENT digits 0-9 (10 x 9 x 8 x 7 = 5040 possibilities)";
  COLOR 11
  LOCATE 4, 2: PRINT "No.  Guess   Hits Balls   Possible left";
  COLOR 15
  FOR i% = 1 TO g%
    LOCATE 4 + i%, 2
    PRINT RIGHT$("  " + LTRIM$(STR$(i%)), 2); "   "; Fmt4$(hg%(i%));
    PRINT "    "; hh%(i%); "    "; hb%(i%);
    PRINT "      "; hr%(i%);
  NEXT i%
  COLOR 7
  LOCATE 16, 2: PRINT "Hit = right digit, right place.  Ball = right digit, wrong place.";
  LOCATE 17, 2: PRINT "4 hits = HOME RUN.  You have 10 turns at bat.";
  CALL DrawDiamond(lh%)
  COLOR 7
  LOCATE 30, 1: PRINT "Type 4 digits + Enter   L list possibilities   ESC = menu";
END SUB

SUB DrawDiamond (h%)
  LINE (520, 330)-(600, 250), 10
  LINE (600, 250)-(520, 170), 10
  LINE (520, 170)-(440, 250), 10
  LINE (440, 250)-(520, 330), 10
  FOR i% = 1 TO 4
    SELECT CASE i%
      CASE 1
        bx% = 600: by% = 250
      CASE 2
        bx% = 520: by% = 170
      CASE 3
        bx% = 440: by% = 250
      CASE ELSE
        bx% = 520: by% = 330
    END SELECT
    IF h% >= i% THEN
      IF i% = 4 THEN col% = 12 ELSE col% = 14
    ELSE
      col% = 8
    END IF
    LINE (bx% - 10, by% - 10)-(bx% + 10, by% + 10), col%, BF
  NEXT i%
  COLOR 10
  LOCATE 12, 62: PRINT "2nd";
  LOCATE 16, 49: PRINT "3rd";
  LOCATE 16, 76: PRINT "1st";
  LOCATE 22, 62: PRINT "HOME";
  COLOR 14
  LOCATE 24, 55: PRINT "Hits on base:"; h%;
END SUB

FUNCTION Fmt4$ (v%)
  Fmt4$ = RIGHT$("000" + LTRIM$(STR$(v%)), 4)
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

SUB PlayGame
  ncand% = 0
  FOR v% = 0 TO 9876
    IF Distinct%(v%) <> 0 THEN
      cand%(ncand%) = v%
      ncand% = ncand% + 1
    END IF
  NEXT v%
  sec% = cand%(INT(RND * ncand%))
  g% = 0
  lh% = 0
  won% = 0
  CALL DrawAll
  CALL Msg("Guess my number. Possible numbers left:" + STR$(ncand%))
  DO
    COLOR 7
    LOCATE 29, 1: PRINT "Your guess > ";
    a$ = ReadLine$(29, 14, 6)
    IF a$ = CHR$(27) THEN
      quit% = 1
      EXIT SUB
    END IF
    IF UCASE$(a$) = "L" THEN
      CALL DrawAll
      IF ncand% <= 24 THEN
        COLOR 10
        LOCATE 19, 2: PRINT "Still possible:";
        FOR i% = 0 TO ncand% - 1
          LOCATE 20 + i% \ 8, 2 + (i% MOD 8) * 6
          PRINT Fmt4$(cand%(i%));
        NEXT i%
        CALL Msg("These" + STR$(ncand%) + " numbers are all that fit every clue so far.")
      ELSE
        CALL Msg("Too many to list (" + LTRIM$(STR$(ncand%)) + "). Make more guesses first.")
      END IF
    ELSEIF ValidGuess%(a$) = 0 THEN
      CALL Msg("Type exactly 4 different digits, for example 0123.")
    ELSE
      g% = g% + 1
      CALL ScoreGuess(gv%, sec%, h%, bl%)
      hg%(g%) = gv%
      hh%(g%) = h%
      hb%(g%) = bl%
      lh% = h%
      n% = 0
      FOR i% = 0 TO ncand% - 1
        CALL ScoreGuess(gv%, cand%(i%), h2%, b2%)
        IF h2% = h% AND b2% = bl% THEN
          cand%(n%) = cand%(i%)
          n% = n% + 1
        END IF
      NEXT i%
      ncand% = n%
      hr%(g%) = ncand%
      CALL DrawAll
      IF h% = 4 THEN
        won% = 1
      ELSE
        mm$ = LTRIM$(STR$(h%)) + " hit(s), " + LTRIM$(STR$(bl%)) + " ball(s)."
        CALL Msg(mm$ + " Numbers still possible:" + STR$(ncand%))
      END IF
    END IF
  LOOP UNTIL won% <> 0 OR g% = 10
  IF won% <> 0 THEN
    pts% = (11 - g%) * 10
    tot% = tot% + pts%
    wins% = wins% + 1
    CALL DrawAll
    COLOR 14
    LOCATE 19, 2: PRINT "HOME RUN in"; g%; "turns!  +"; pts%; "points";
    CALL Msg("HOME RUN!  Any key = next game, ESC = menu")
  ELSE
    COLOR 12
    LOCATE 19, 2: PRINT "Struck out. My number was "; Fmt4$(sec%);
    CALL Msg("Out of turns.  Any key = next game, ESC = menu")
  END IF
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
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

' Compare guess a% with secret b%: h% = right digit right place, bl% = right digit wrong place.
SUB ScoreGuess (a%, b%, h%, bl%)
  da%(1) = a% \ 1000
  da%(2) = (a% \ 100) MOD 10
  da%(3) = (a% \ 10) MOD 10
  da%(4) = a% MOD 10
  db%(1) = b% \ 1000
  db%(2) = (b% \ 100) MOD 10
  db%(3) = (b% \ 10) MOD 10
  db%(4) = b% MOD 10
  h% = 0
  bl% = 0
  FOR i% = 1 TO 4
    FOR j% = 1 TO 4
      IF da%(i%) = db%(j%) THEN
        IF i% = j% THEN
          h% = h% + 1
        ELSE
          bl% = bl% + 1
        END IF
      END IF
    NEXT j%
  NEXT i%
END SUB

SUB Title
  CLS
  COLOR 14
  LOCATE 3, 20: PRINT "G17  HOME RUN  (QIANG BANG CHU JI)"
  COLOR 7
  LOCATE 6, 6: PRINT "Original 1991 educational content:"
  COLOR 15
  LOCATE 7, 6: PRINT "Guessing a 4-digit number with all different digits: a game of"
  LOCATE 8, 6: PRINT "PERMUTATIONS. There are 10 x 9 x 8 x 7 = 5040 of them, and every clue"
  LOCATE 9, 6: PRINT "(hits and balls) throws away many of the possibilities."
  COLOR 7
  LOCATE 12, 6: PRINT "How to play:"
  LOCATE 13, 6: PRINT "I pick a secret number such as 0537. You type guesses of 4 different digits."
  LOCATE 14, 6: PRINT "HIT  = right digit in the right place  (runner advances one base)"
  LOCATE 15, 6: PRINT "BALL = right digit in the wrong place"
  LOCATE 16, 6: PRINT "4 hits = HOME RUN. You get 10 turns. L = list what is still possible."
  LOCATE 17, 6: PRINT "Backspace edits, ESC = back to menu"
  COLOR 10
  LOCATE 19, 6: PRINT "Score: 100 for a home run on turn 1, 10 less for each extra turn."
  COLOR 14
  LOCATE 22, 6: PRINT "Press any key to start..."
  k$ = GetKey$
  IF k$ = CHR$(27) THEN quit% = 1
END SUB

FUNCTION ValidGuess% (a$)
  ValidGuess% = 0
  IF LEN(a$) = 4 THEN
    ok% = 1
    FOR i% = 1 TO 4
      c$ = MID$(a$, i%, 1)
      IF c$ < "0" OR c$ > "9" THEN ok% = 0
    NEXT i%
    IF ok% <> 0 THEN
      gv% = VAL(a$)
      IF Distinct%(gv%) <> 0 THEN ValidGuess% = 1
    END IF
  END IF
END FUNCTION
