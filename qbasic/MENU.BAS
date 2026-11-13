' MENU.BAS - Main menu for the 30 puzzle-room games (NMNS computer puzzle room, 1991)
' Controls: Up/Down arrows or PgUp/PgDn to move, Enter to start, ESC to quit to DOS.
' Each game is a separate file G01.BAS .. G30.BAS in the same directory.
DECLARE SUB DrawMenu (sel%)
DECLARE FUNCTION GetKey$ ()

DIM SHARED gname$(1 TO 30)
DIM SHARED gcat%(1 TO 30)
DIM SHARED catname$(1 TO 5)

FOR i% = 1 TO 30
  READ gname$(i%), gcat%(i%)
NEXT i%
FOR i% = 1 TO 5
  READ catname$(i%)
NEXT i%

DATA "Cat & Mouse (MAO ZHUO LAO SHU)",1
DATA "Detective & Thief (ZHEN TAN YU GUAI DAO)",1
DATA "Chickens & Rabbits (JI TU TONG LONG)",1
DATA "Tower of Hanoi (HAN NUO ER TA)",1
DATA "Cycloids (YOU QU DE BAI XIAN)",1
DATA "Brain Gym (TOU NAO TI CAO)",1
DATA "African Safari (FEI ZHOU SHOU LIE)",1
DATA "Tic-Tac-Toe (JING ZI YOU XI)",1
DATA "Golf (GAO ER FU QIU)",1
DATA "Ladder Lottery (CHOU DA TOU)",1
DATA "Block Arrange (PAI FANG KUAI)",1
DATA "Sort It (PAI PAI KAN)",1
DATA "Search It (ZHAO ZHAO KAN)",1
DATA "Sliding Puzzle (ZHI HUI PAN)",1
DATA "Binary (ER JIN WEI ZHI)",1
DATA "Bomber (HONG ZHA JI)",1
DATA "Home Run (QIANG BANG CHU JI)",1
DATA "Pascal Triangle (YANG HUI SAN JIAO XING)",1
DATA "3D Connect (LI TI LIAN ZHU)",2
DATA "Admiral (HAI JUN SHANG JIANG)",2
DATA "Seesaw (QIAO QIAO BAN)",2
DATA "Sailing Upwind (NI FENG XING ZHOU)",2
DATA "Moon Landing (CHANG E DENG YUE)",2
DATA "Laser Maze (LEI SHE MI GONG)",2
DATA "Opposites Attract (YI XING XIANG XI)",2
DATA "Mantis & Cicada (TANG LANG BU CHAN)",3
DATA "Animal ID (DONG WU SHI BIE)",3
DATA "Big Front Teeth (DA MEN YA)",4
DATA "Memory 100 (JI YI 100)",4
DATA "Computer Drawing (DIAN NAO HUI TU)",5
DATA "Mathematics","Physics","Biology","Health Education","Art"

sel% = 1
SCREEN 0
WIDTH 80
COLOR 7, 0
CLS
CALL DrawMenu(sel%)

DO
  k$ = GetKey$
  IF LEN(k$) = 2 THEN
    SELECT CASE ASC(RIGHT$(k$, 1))
      CASE 72
        sel% = sel% - 1
        IF sel% < 1 THEN sel% = 30
      CASE 80
        sel% = sel% + 1
        IF sel% > 30 THEN sel% = 1
      CASE 73
        sel% = sel% - 10
        IF sel% < 1 THEN sel% = 1
      CASE 81
        sel% = sel% + 10
        IF sel% > 30 THEN sel% = 30
      CASE 71
        sel% = 1
      CASE 79
        sel% = 30
    END SELECT
    CALL DrawMenu(sel%)
  ELSEIF k$ = CHR$(13) THEN
    f$ = "G" + RIGHT$("0" + LTRIM$(STR$(sel%)), 2) + ".BAS"
    ON ERROR GOTO NoGame
    RUN f$
    ON ERROR GOTO 0
    CALL DrawMenu(sel%)
  ELSEIF k$ = CHR$(27) THEN
    EXIT DO
  ELSEIF k$ >= "0" AND k$ <= "9" THEN
    ' type a one- or two-digit game number, then Enter is not needed for 2 digits
    n$ = k$
    LOCATE 24, 1
    PRINT "Game number: "; n$; "_   ";
    k2$ = GetKey$
    IF k2$ >= "0" AND k2$ <= "9" THEN n$ = n$ + k2$
    v% = VAL(n$)
    IF v% >= 1 AND v% <= 30 THEN sel% = v%
    CALL DrawMenu(sel%)
  END IF
LOOP

SCREEN 0
WIDTH 80
COLOR 7, 0
CLS
PRINT "Bye!"
END

NoGame:
  LOCATE 24, 1
  COLOR 12, 0
  PRINT "Cannot start "; f$; " (file not found?). Press any key.        ";
  COLOR 7, 0
  junk$ = INPUT$(1)
  RESUME NEXT

SUB DrawMenu (sel%)
  COLOR 15, 1
  LOCATE 1, 1
  PRINT SPACE$(80);
  LOCATE 1, 12
  PRINT "NMNS COMPUTER PUZZLE ROOM  -  30 GAMES (1991 list)";
  COLOR 7, 0
  FOR i% = 1 TO 30
    c% = (i% - 1) \ 15
    r% = ((i% - 1) MOD 15) + 3
    col% = 1 + c% * 40
    LOCATE r%, col%
    IF i% = sel% THEN COLOR 0, 7 ELSE COLOR 7 + gcat%(i%), 0
    PRINT USING "##"; i%;
    PRINT " ";
    PRINT LEFT$(gname$(i%) + SPACE$(36), 36);
  NEXT i%
  COLOR 7, 0
  LOCATE 19, 1
  PRINT STRING$(80, "-");
  LOCATE 20, 1
  PRINT "Categories: ";
  FOR i% = 1 TO 5
    COLOR 7 + i%, 0
    PRINT catname$(i%); "  ";
  NEXT i%
  COLOR 7, 0
  LOCATE 22, 1
  PRINT "Up/Down: move   PgUp/PgDn: +-10   Enter: play   0-9: type number   ESC: quit";
  LOCATE 24, 1
  PRINT SPACE$(79);
END SUB

FUNCTION GetKey$ ()
  DO
    k$ = INKEY$
  LOOP WHILE k$ = ""
  GetKey$ = k$
END FUNCTION
