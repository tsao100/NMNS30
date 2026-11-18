'==============================================================================
'  LAZER MAZE  -  QBasic 1.1 version (SCREEN 12, 640x480, 16 colors) + MOUSE
'
'  Remake of the 1982 Apple II game "Lazer Maze" (James Spain / Avant-Garde).
'
'  RULES
'   - 10 x 10 box holding slanted reflectors ("baffles").
'   - Ports 10..49 around the box:  10-19 top (left to right)
'                                   20-29 left (top to bottom)
'                                   30-39 bottom (left to right)
'                                   40-49 right (top to bottom)
'   - 20 beams per game. Each beam uses one entry and one exit port.
'   - The soldier (blinking) fires from the entry port. CLICK the port where
'     you think the beam comes out (typing the 2 digits works too).
'     Right: the beam reflects and kills the alien.
'     Wrong: the alien throws a bomb at the soldier.
'   - Score per beam = baffle bonus + INT(2000 * bounces / time ticks).
'   - Number of baffles grows with your score (20,30,40,...,70).
'   - Beams already fired stay on the screen, each in its own color
'     (after 14 beams the colors repeat as dashed lines).
'
'  MOUSE     click buttons, click a port to answer (needs a DOS mouse driver)
'  KEYBOARD  digits = answer, ENTER = next / start, ESC = leave, F2 = sound
'==============================================================================
DEFINT A-Z

DECLARE SUB Init ()
DECLARE SUB Mouse (a, b, c, d)
DECLARE SUB MShow ()
DECLARE SUB MHide ()
DECLARE SUB PollMouse ()
DECLARE SUB Snd (f, t)
DECLARE SUB Dly (s!)
DECLARE SUB FlushIn ()
DECLARE FUNCTION GetKey$ ()
DECLARE FUNCTION Num$ (v)
DECLARE FUNCTION NumL$ (v AS LONG)
DECLARE FUNCTION PortAt (x, y)
DECLARE SUB DrawSoldier (cx, cy)
DECLARE SUB DrawAlien (cx, cy)
DECLARE SUB EraseActor (cx, cy)
DECLARE SUB SoldOn (x, y)
DECLARE SUB SoldOff ()
DECLARE SUB AlienOn (x, y)
DECLARE SUB AlienOff ()
DECLARE SUB DrawSeg (x1, y1, x2, y2, c, dash)
DECLARE SUB DrawMirror (i, j, kind, c)
DECLARE SUB DrawLabel (p, hl)
DECLARE SUB PutStat (r, l$, v$, c)
DECLARE SUB DrawStats ()
DECLARE SUB ShowMsg (l)
DECLARE SUB Msg (l, t$, c)
DECLARE SUB StatusReset ()
DECLARE SUB DrawBtnXY (x, y, w, h, t$, hov)
DECLARE SUB DrawBtn (i, hov)
DECLARE SUB DrawSide ()
DECLARE SUB ClearBtns ()
DECLARE SUB AddBtn (x, y, w, h, t$, k1, k2)
DECLARE FUNCTION SideHit (x, y)
DECLARE FUNCTION WaitChoice ()
DECLARE SUB DrawGame ()
DECLARE SUB CText (r, t$, c)
DECLARE SUB DrawTitle ()
DECLARE SUB DrawLevel ()
DECLARE SUB ResetBoardView ()
DECLARE SUB BuildMaze (n)
DECLARE SUB Trace (p)
DECLARE SUB ExplodeAt (x, y)
DECLARE SUB ThrowBomb (x1, y1, x2, y2)
DECLARE SUB DoShot (p, g, c, dash)
DECLARE SUB Demo (p, c)
DECLARE FUNCTION ReadGuess (p, tk)
DECLARE FUNCTION Title ()
DECLARE SUB LevelPage ()
DECLARE SUB Page (l1$, l2$)
DECLARE SUB PlayGame ()
DECLARE SUB Tutorial ()

CONST GX0 = 160, GY0 = 56, CW = 32, NSHOT = 20

DIM SHARED SCORE AS LONG, HI AS LONG
DIM SHARED MAZ(0 TO 9, 0 TO 9), SEEN(0 TO 9, 0 TO 9)
DIM SHARED USED(10 TO 49), UCOL(10 TO 49)
DIM SHARED PX(0 TO 200), PY(0 TO 200), NP
DIM SHARED HCI(0 TO 200), HCJ(0 TO 200), NH
DIM SHARED BPX(0 TO 20, 0 TO 200), BPY(0 TO 20, 0 TO 200)
DIM SHARED BN(0 TO 20), BCOL(0 TO 20), BDASH(0 TO 20), NB
DIM SHARED CT(0 TO 13)
DIM SHARED LX(10 TO 49), LY(10 TO 49)
DIM SHARED SXP(10 TO 49), SYP(10 TO 49), EPX(10 TO 49), EPY(10 TO 49)
DIM SHARED ZX1(10 TO 49), ZY1(10 TO 49), ZX2(10 TO 49), ZY2(10 TO 49)
DIM SHARED MSGT$(1 TO 3), MCOL(1 TO 3)
DIM SHARED BTX(1 TO 5), BTY(1 TO 5), BTW(1 TO 5), BTH(1 TO 5)
DIM SHARED BTT$(1 TO 5), BK1(1 TO 5), BK2(1 TO 5), NBTN
DIM SHARED MC(0 TO 29), BOMB(1 TO 100)
DIM SHARED HAVEMOUSE, MSHOWN, SOUNDON, SHOWMENU, ENDVIEW, SCRN, HOVP
DIM SHARED MX, MY, PB, CLK, CLKX, CLKY
DIM SHARED AUTOP
DIM SHARED BB, EXITP, MISS, REFL, HIT, SHOTNO, GAMEOK, QUITTUT
DIM SHARED LVL$, SOLDV, SOLDX, SOLDY, ALV, ALX, ALY

'------------------------------------------------------------------------------
'  MAIN
'------------------------------------------------------------------------------
Init
DO
  ch = Title
  SELECT CASE ch
    CASE 1
      DO
        PlayGame
      LOOP WHILE GAMEOK = 1
    CASE 2
      Tutorial
    CASE ELSE
      EXIT DO
  END SELECT
LOOP
SCREEN 0
WIDTH 80
COLOR 7
CLS
PRINT "THANKS FOR PLAYING LAZER MAZE"
END

'  beam colors, then the machine code of the mouse routine (hex bytes)
DATA 14,10,12,11,13,9,15,6,2,4,3,5,7,1
DATA 55,89,E5,8B,5E,0C,8B,07,50,8B,5E,0A,8B,07,50,8B,5E,08,8B,0F,8B,5E,06
DATA 8B,17,5B,58,1E,07,CD,33,53,8B,5E,0C,89,07,58,8B,5E,0A,89,07,8B,5E,08
DATA 89,0F,8B,5E,06,89,17,5D,CA,08,00

SUB AddBtn (x, y, w, h, t$, k1, k2)
  NBTN = NBTN + 1
  BTX(NBTN) = x: BTY(NBTN) = y: BTW(NBTN) = w: BTH(NBTN) = h
  BTT$(NBTN) = t$: BK1(NBTN) = k1: BK2(NBTN) = k2
END SUB

SUB AlienOff
  IF ALV <> 0 THEN
    MHide
    EraseActor ALX, ALY
    ALV = 0
  END IF
END SUB

SUB AlienOn (x, y)
  MHide
  ALX = x: ALY = y: ALV = 1
  DrawAlien x, y
END SUB

SUB BuildMaze (n)
  FOR i = 0 TO 9
    FOR j = 0 TO 9
      MAZ(i, j) = 0
    NEXT
  NEXT
  cnt = 0
  DO WHILE cnt < n
    i = INT(RND * 10): j = INT(RND * 10)
    IF MAZ(i, j) = 0 THEN
      MAZ(i, j) = 1 + INT(RND * 2)
      cnt = cnt + 1
    END IF
  LOOP
END SUB

SUB ClearBtns
  IF NBTN > 0 THEN
    MHide
    FOR i = 1 TO NBTN
      LINE (BTX(i), BTY(i))-(BTX(i) + BTW(i) - 1, BTY(i) + BTH(i) - 1), 0, BF
    NEXT
  END IF
  NBTN = 0
END SUB

SUB CText (r, t$, c)
  COLOR c
  LOCATE r, (80 - LEN(t$)) \ 2 + 1
  PRINT t$;
END SUB

SUB Demo (p, c)
  Trace p
  SoldOn SXP(p), SYP(p)
  DoShot p, EXITP, c, 0
END SUB

SUB DoShot (p, g, c, dash)
  s = (p - 10) \ 10
  alx = SXP(g): aly = SYP(g)
  IF g = p THEN
    IF s = 0 OR s = 2 THEN
      alx = alx + 36
    ELSE
      aly = aly + 36
    END IF
  END IF
  SoldOn SXP(p), SYP(p)
  FOR f = 3000 TO 600 STEP -400
    Snd f, 1
  NEXT
  AlienOn alx, aly              'the alien appears AFTER the soldier has fired

  'beam flight
  MHide
  FOR n = 0 TO NP - 2
    x1 = PX(n): y1 = PY(n): x2 = PX(n + 1): y2 = PY(n + 1)
    dx! = x2 - x1: dy! = y2 - y1
    seglen! = SQR(dx! * dx! + dy! * dy!)
    steps = INT(seglen! / 16) + 1
    px0 = x1: py0 = y1
    FOR t = 1 TO steps
      nx = x1 + CINT(dx! * t / steps)
      ny = y1 + CINT(dy! * t / steps)
      DrawSeg px0, py0, nx, ny, c, dash
      px0 = nx: py0 = ny
      Dly .01
    NEXT
    IF n < NP - 2 THEN Snd 1500, 1
  NEXT

  IF g = EXITP THEN
    HIT = 1
    ExplodeAt alx, aly
  ELSE
    HIT = 0
    ThrowBomb alx, aly, SXP(p), SYP(p)
    ExplodeAt SXP(p), SYP(p)
  END IF
  Dly .5
  NB = NB + 1
  FOR n = 0 TO NP - 1
    BPX(NB, n) = PX(n): BPY(NB, n) = PY(n)
  NEXT
  BN(NB) = NP: BCOL(NB) = c: BDASH(NB) = dash
  SOLDV = 0: ALV = 0
  DrawGame
END SUB

SUB DrawAlien (cx, cy)
  CIRCLE (cx, cy - 1), 9, 10
  PAINT (cx, cy - 1), 10, 10
  LINE (cx - 7, cy - 4)-(cx - 2, cy + 1), 0, BF
  LINE (cx + 2, cy - 4)-(cx + 7, cy + 1), 0, BF
  PSET (cx - 5, cy - 2), 15
  PSET (cx + 5, cy - 2), 15
  LINE (cx - 4, cy - 9)-(cx - 6, cy - 11), 10
  LINE (cx + 4, cy - 9)-(cx + 6, cy - 11), 10
  PSET (cx - 6, cy - 11), 12
  PSET (cx + 6, cy - 11), 12
  LINE (cx - 3, cy + 8)-(cx + 3, cy + 11), 2, BF
  LINE (cx - 8, cy + 9)-(cx - 6, cy + 11), 2, BF
  LINE (cx + 6, cy + 9)-(cx + 8, cy + 11), 2, BF
END SUB

SUB DrawBtn (i, hov)
  DrawBtnXY BTX(i), BTY(i), BTW(i), BTH(i), BTT$(i), hov
END SUB

SUB DrawBtnXY (x, y, w, h, t$, hov)
  MHide
  LINE (x, y)-(x + w - 1, y + h - 1), 0, BF
  IF hov <> 0 THEN
    LINE (x, y)-(x + w - 1, y + h - 1), 15, B
    LINE (x + 1, y + 1)-(x + w - 2, y + h - 2), 9, B
    COLOR 14
  ELSE
    LINE (x, y)-(x + w - 1, y + h - 1), 11, B
    COLOR 15
  END IF
  LOCATE ((y + (h - 16) \ 2) \ 16) + 1, ((x + (w - 8 * LEN(t$)) \ 2) \ 8) + 1
  PRINT t$;
END SUB

SUB DrawGame
  MHide
  CLS
  COLOR 14
  LOCATE 1, 1
  PRINT "LAZER MAZE";

  'board
  LINE (GX0 - 1, GY0 - 1)-(GX0 + 320, GY0 + 320), 15, B
  FOR i = 1 TO 9
    LINE (GX0 + i * CW, GY0)-(GX0 + i * CW, GY0 + 319), 8
    LINE (GX0, GY0 + i * CW)-(GX0 + 319, GY0 + i * CW), 8
  NEXT

  'beams already fired
  FOR b = 1 TO NB
    FOR n = 0 TO BN(b) - 2
      DrawSeg BPX(b, n), BPY(b, n), BPX(b, n + 1), BPY(b, n + 1), BCOL(b), BDASH(b)
    NEXT
  NEXT

  'reflectors (drawn over the beams)
  FOR i = 0 TO 9
    FOR j = 0 TO 9
      IF MAZ(i, j) <> 0 THEN
        c = 15
        IF ENDVIEW <> 0 AND SEEN(i, j) = 0 THEN c = 14
        DrawMirror i, j, MAZ(i, j), c
      END IF
    NEXT
  NEXT

  'ports
  FOR p = 10 TO 49
    DrawLabel p, 0
  NEXT

  'actors
  IF SOLDV <> 0 THEN DrawSoldier SOLDX, SOLDY
  IF ALV <> 0 THEN DrawAlien ALX, ALY

  DrawStats

  'message panel
  LINE (4, 428)-(635, 479), 8, B
  FOR l = 1 TO 3
    ShowMsg l
  NEXT

  DrawSide
  FOR i = 1 TO NBTN
    DrawBtn i, 0
  NEXT
END SUB

SUB DrawLabel (p, hl)
  x = LX(p): y = LY(p)
  MHide
  LINE (x - 3, y - 1)-(x + 18, y + 16), 0, BF
  IF hl <> 0 THEN
    LINE (x - 3, y - 1)-(x + 18, y + 16), 15, B
    LINE (x - 2, y)-(x + 17, y + 15), 14, B
    fg = 15
  ELSE
    IF UCOL(p) = 0 THEN
      bc = 8: fg = 7
    ELSE
      bc = UCOL(p): fg = UCOL(p)
    END IF
    LINE (x - 3, y - 1)-(x + 18, y + 16), bc, B
  END IF
  COLOR fg
  LOCATE y \ 16 + 1, x \ 8 + 1
  PRINT LTRIM$(STR$(p));
END SUB

SUB DrawLevel
  MHide
  CLS
  CText 8, "L A Z E R   M A Z E", 14
  CText 12, "YOU NOW QUALIFY FOR " + LVL$, 15
  CText 14, "WITH " + Num$(REFL) + " REFLECTORS", 15
  CText 17, "THERE ARE " + Num$(NSHOT) + " BEAMS IN EACH GAME", 7
  DrawSide
END SUB

SUB DrawMirror (i, j, kind, c)
  x = GX0 + i * CW: y = GY0 + j * CW
  IF kind = 1 THEN
    LINE (x + 6, y + 26)-(x + 26, y + 6), c
    LINE (x + 7, y + 26)-(x + 27, y + 6), c
  ELSE
    LINE (x + 6, y + 6)-(x + 26, y + 26), c
    LINE (x + 7, y + 6)-(x + 27, y + 26), c
  END IF
END SUB

SUB DrawSeg (x1, y1, x2, y2, c, dash)
  IF dash <> 0 THEN
    LINE (x1, y1)-(x2, y2), c, , &HF0F0
  ELSE
    LINE (x1, y1)-(x2, y2), c
    LINE (x1 + 1, y1 + 1)-(x2 + 1, y2 + 1), c
  END IF
END SUB

SUB DrawSide
  MHide
  IF SOUNDON <> 0 THEN t$ = "SOUND ON" ELSE t$ = "SOUND OFF"
  DrawBtnXY 556, 64, 80, 24, t$, 0
  IF SHOWMENU <> 0 THEN DrawBtnXY 556, 96, 80, 24, "MENU", 0
END SUB

SUB DrawSoldier (cx, cy)
  LINE (cx - 6, cy - 11)-(cx + 6, cy - 8), 2, BF
  LINE (cx - 7, cy - 8)-(cx + 7, cy - 7), 10, BF
  LINE (cx - 5, cy - 6)-(cx + 5, cy - 1), 14, BF
  PSET (cx - 2, cy - 4), 0
  PSET (cx + 2, cy - 4), 0
  LINE (cx - 6, cy)-(cx + 6, cy + 7), 2, BF
  LINE (cx - 6, cy + 4)-(cx + 6, cy + 4), 6
  LINE (cx - 10, cy)-(cx - 8, cy + 6), 2, BF
  LINE (cx + 8, cy + 1)-(cx + 10, cy + 5), 2, BF
  LINE (cx + 8, cy + 3)-(cx + 11, cy + 3), 7
  LINE (cx - 5, cy + 8)-(cx - 2, cy + 11), 10, BF
  LINE (cx + 2, cy + 8)-(cx + 5, cy + 11), 10, BF
END SUB

SUB DrawStats
  MHide
  PutStat 4, "SHOT", Num$(SHOTNO) + "/" + Num$(NSHOT), 14
  PutStat 7, "SCORE", NumL$(SCORE), 15
  PutStat 10, "HIGH", NumL$(HI), 11
  PutStat 13, "REFLECTORS", Num$(REFL), 10
  IF MISS > 0 THEN mc = 12 ELSE mc = 7
  PutStat 16, "MISSES", Num$(MISS), mc
END SUB

SUB DrawTitle
  MHide
  CLS
  CText 2, "L A Z E R   M A Z E", 14
  CText 4, "A GAME FOR SHARP EYES AND QUICK WITS", 11
  CText 6, "Remake of the 1982 Apple II game by James Spain", 7
  'little demo beam
  c = 12
  FOR k = 0 TO 1
    LINE (104, 146 + k)-(200, 146 + k), c
    LINE (200 + k, 146)-(200 + k, 121), c
    LINE (200, 121 + k)-(440, 121 + k), c
    LINE (440 + k, 121)-(440 + k, 146), c
    LINE (440, 146 + k)-(536, 146 + k), c
  NEXT
  LINE (192, 158)-(208, 142), 15
  LINE (192, 133)-(208, 117), 15
  LINE (432, 117)-(448, 133), 15
  LINE (432, 142)-(448, 158), 15
  DrawSoldier 90, 146
  DrawAlien 550, 146
  CText 12, "WHAT DO YOU WANT TO DO?", 15
  CText 24, "Mouse: click the buttons / click a port to answer", 7
  CText 25, "F2 = sound on/off      ESC = leave a game", 8
  DrawSide
END SUB

SUB Dly (s!)
  IF AUTOP <> 0 THEN s! = s! / 20
  t0! = TIMER
  DO
    t! = TIMER - t0!
    IF t! < 0 THEN t! = t! + 86400!
  LOOP WHILE t! < s!
END SUB

SUB EraseActor (cx, cy)
  LINE (cx - 12, cy - 12)-(cx + 12, cy + 12), 0, BF
END SUB

SUB ExplodeAt (x, y)
  MHide
  CIRCLE (x, y), 5, 14
  PAINT (x, y), 14, 14
  Snd 120, 1
  CIRCLE (x, y), 12, 12
  PAINT (x, y), 12, 12
  CIRCLE (x, y), 6, 14
  PAINT (x, y), 14, 14
  Snd 90, 1
  FOR k = 0 TO 7
    a! = k * 3.14159 / 4
    LINE (x, y)-(x + CINT(20 * COS(a!)), y + CINT(20 * SIN(a!))), 14
  NEXT
  CIRCLE (x, y), 9, 4
  PAINT (x, y), 4, 4
  CIRCLE (x, y), 4, 14
  PAINT (x, y), 14, 14
  FOR n = 1 TO 6
    Snd 60 + INT(RND * 300), 1
  NEXT
  Dly .2
END SUB

SUB FlushIn
  PollMouse
  CLK = 0
  DO WHILE INKEY$ <> ""
  LOOP
END SUB

FUNCTION GetKey$
  k$ = INKEY$
  IF LEN(k$) = 2 THEN
    IF ASC(RIGHT$(k$, 1)) = 60 THEN
      SOUNDON = 1 - SOUNDON
      DrawSide
    END IF
    k$ = ""
  END IF
  GetKey$ = k$
END FUNCTION

SUB Init
  SCREEN 12
  RANDOMIZE TIMER
  FOR i = 0 TO 13
    READ CT(i)
  NEXT
  'load the mouse machine code
  DEF SEG = VARSEG(MC(0))
  FOR i = 0 TO 56
    READ h$
    POKE VARPTR(MC(0)) + i, VAL("&H" + h$)
  NEXT
  DEF SEG
  'is there a mouse driver?
  HAVEMOUSE = 1
  DEF SEG = 0
  IF PEEK(&HCC) + PEEK(&HCD) + PEEK(&HCE) + PEEK(&HCF) = 0 THEN HAVEMOUSE = 0
  DEF SEG
  IF HAVEMOUSE <> 0 THEN
    a = 0: b = 0: c = 0: d = 0
    Mouse a, b, c, d
    IF a = 0 THEN HAVEMOUSE = 0
  END IF
  MSHOWN = 0: MX = -1: MY = -1: PB = 0: CLK = 0

  'port geometry
  FOR p = 10 TO 49
    s = (p - 10) \ 10: k = (p - 10) MOD 10
    SELECT CASE s
      CASE 0
        LX(p) = 168 + 32 * k: LY(p) = 32
        SXP(p) = LX(p) + 8: SYP(p) = 14
        EPX(p) = SXP(p): EPY(p) = 27
        ZX1(p) = GX0 + 32 * k: ZY1(p) = 0: ZX2(p) = ZX1(p) + 31: ZY2(p) = GY0 - 1
      CASE 1
        LX(p) = 128: LY(p) = 64 + 32 * k
        SXP(p) = 100: SYP(p) = LY(p) + 8
        EPX(p) = 114: EPY(p) = SYP(p)
        ZX1(p) = 84: ZY1(p) = GY0 + 32 * k: ZX2(p) = GX0 - 1: ZY2(p) = ZY1(p) + 31
      CASE 2
        LX(p) = 168 + 32 * k: LY(p) = 384
        SXP(p) = LX(p) + 8: SYP(p) = 414
        EPX(p) = SXP(p): EPY(p) = 401
        ZX1(p) = GX0 + 32 * k: ZY1(p) = GY0 + 321: ZX2(p) = ZX1(p) + 31: ZY2(p) = 426
      CASE ELSE
        LX(p) = 496: LY(p) = 64 + 32 * k
        SXP(p) = 540: SYP(p) = LY(p) + 8
        EPX(p) = 526: EPY(p) = SYP(p)
        ZX1(p) = GX0 + 321: ZY1(p) = GY0 + 32 * k: ZX2(p) = 549: ZY2(p) = ZY1(p) + 31
    END SELECT
  NEXT

  'bomb sprite for XOR animation
  CLS
  CIRCLE (8, 10), 6, 8
  PAINT (8, 10), 7, 8
  LINE (8, 4)-(12, 0), 14
  PSET (12, 0), 12
  GET (0, 0)-(15, 16), BOMB
  CLS

  SOUNDON = 1
  REFL = 20
  LVL$ = "A BEGINNERS LEVEL GAME"
  SCORE = 7000: HI = 0
END SUB

SUB LevelPage
  SCRN = 2: SHOWMENU = 1
  StatusReset
  ClearBtns
  DrawLevel
  AddBtn 270, 296, 100, 32, "START", 13, 0
  r = WaitChoice
  ClearBtns
  IF r < 0 THEN GAMEOK = 0
END SUB

SUB MHide
  IF HAVEMOUSE = 0 THEN EXIT SUB
  IF MSHOWN <> 0 THEN
    a = 2: b = 0: c = 0: d = 0
    Mouse a, b, c, d
    MSHOWN = 0
  END IF
END SUB

SUB Mouse (a, b, c, d)
  DEF SEG = VARSEG(MC(0))
  CALL ABSOLUTE(a, b, c, d, VARPTR(MC(0)))
  DEF SEG
END SUB

SUB Msg (l, t$, c)
  MSGT$(l) = t$
  MCOL(l) = c
  IF SCRN = 3 THEN ShowMsg l
END SUB

SUB MShow
  IF HAVEMOUSE = 0 THEN EXIT SUB
  IF MSHOWN = 0 THEN
    a = 1: b = 0: c = 0: d = 0
    Mouse a, b, c, d
    MSHOWN = 1
  END IF
END SUB

FUNCTION Num$ (v)
  Num$ = LTRIM$(STR$(v))
END FUNCTION

FUNCTION NumL$ (v AS LONG)
  NumL$ = LTRIM$(STR$(v))
END FUNCTION

SUB Page (l1$, l2$)
  Msg 1, l1$, 15
  Msg 2, l2$, 15
  Msg 3, "", 15
  ClearBtns
  AddBtn 556, 296, 80, 32, "NEXT >", 13, 0
  r = WaitChoice
  ClearBtns
  IF r < 0 THEN QUITTUT = 1
END SUB

SUB PlayGame
  GAMEOK = 1
  AUTOP = 0
  LevelPage
  IF GAMEOK = 0 THEN EXIT SUB
  SCORE = 7000: MISS = 0: SHOTNO = 0
  FOR i = 0 TO 9
    FOR j = 0 TO 9
      SEEN(i, j) = 0
    NEXT
  NEXT
  BuildMaze REFL
  ResetBoardView

  FOR shot = 1 TO NSHOT
    SHOTNO = shot
    DrawStats
    StatusReset
    DO
      p = 10 + INT(RND * 40)
    LOOP WHILE USED(p) <> 0
    USED(p) = 1
    Trace p
    USED(EXITP) = 1
    c = CT((shot - 1) MOD 14)
    dash = 0
    IF shot > 14 THEN dash = 1
    tk = 1
    g = ReadGuess(p, tk)
    IF g < 0 THEN
      Msg 2, "GAME ABORTED", 12
      SoldOff
      Dly 1
      GAMEOK = 0
      EXIT SUB
    END IF
    Msg 2, "", 15
    DoShot p, g, c, dash
    FOR n = 0 TO NH - 1
      SEEN(HCI(n), HCJ(n)) = 1
    NEXT
    UCOL(p) = c: UCOL(EXITP) = c
    DrawLabel p, 0
    DrawLabel EXITP, 0

    bs& = 0
    Msg 2, "", 15
    IF HIT = 1 THEN
      IF BB > 10 THEN
        bu = BB * 30
        bs& = bs& + bu
        Msg 2, "BONUS !!    " + Num$(bu) + " POINTS    !! BONUS", 14
        FOR n = 1 TO 8
          Snd 1000 + n * 100, 1
        NEXT
      ELSEIF BB > 6 THEN
        bs& = bs& + 200
        Msg 2, "200 POINTS !!!!! BONUS !!!! 200 POINTS", 14
        FOR n = 1 TO 4
          Snd 1000 + n * 150, 1
        NEXT
      END IF
      bs& = bs& + (2000& * BB) \ tk
      Msg 1, "GOOD CALL......GOOD CALL......GOOD CALL", 10
      Snd 523, 2
      Snd 659, 2
      Snd 784, 2
      Snd 1047, 4
    ELSE
      MISS = MISS + 1
      Msg 1, "SORRY...YOU MISSED", 12
      Msg 2, "BEAM CAME OUT AT " + Num$(EXITP), 12
      Snd 220, 4
      Snd 165, 6
    END IF
    SCORE = SCORE + bs&
    DrawStats
    Msg 3, "BEAM SCORE = " + NumL$(bs&) + "    TOTAL = " + NumL$(SCORE), 11
    Dly 1.8

    IF HIT = 0 AND MISS = 3 THEN
      Msg 2, "WANT TO REVIEW THE INSTRUCTIONS (Y/N)?", 15
      ClearBtns
      AddBtn 556, 296, 80, 32, "YES", ASC("Y"), 0
      AddBtn 556, 344, 80, 32, "NO", ASC("N"), 0
      r = WaitChoice
      ClearBtns
      IF r = 1 THEN
        Tutorial
        GAMEOK = 0
        EXIT SUB
      END IF
    END IF
  NEXT

  StatusReset
  IF MISS = 0 THEN
    bn& = 20& * REFL
    SCORE = SCORE + bn&
    Msg 1, "NO MISSES !!! BONUS " + NumL$(bn&) + " !!! NO MISSES", 14
    FOR n = 1 TO 12
      Snd 800 + n * 80, 1
    NEXT
  END IF
  IF SCORE > HI THEN HI = SCORE
  ENDVIEW = 1                    'untouched baffles turn yellow
  DrawGame
  AUTOP = 0
  Msg 2, "GAME COMPLETE...YOUR SCORE WAS " + NumL$(SCORE) + "  (UNTOUCHED BAFFLES: YELLOW)", 15
  Msg 3, "THE HIGHEST SCORE IS " + NumL$(HI), 10
  ClearBtns
  AddBtn 556, 296, 80, 32, "NEXT GAME", 13, 0
  r = WaitChoice
  ClearBtns
  IF r < 0 THEN GAMEOK = 0
  IF SCORE > 3000 THEN REFL = 30: LVL$ = "A HIGHER LEVEL GAME"
  IF SCORE > 4000 THEN REFL = 40: LVL$ = "AN INTERMEDIATE LEVEL GAME"
  IF SCORE > 5000 THEN REFL = 50: LVL$ = "A HIGH LEVEL GAME"
  IF SCORE > 6000 THEN REFL = 60: LVL$ = "A MASTER'S LEVEL GAME"
  IF SCORE > 7000 THEN REFL = 70: LVL$ = "A MASTER'S LEVEL GAME"
END SUB

SUB PollMouse
  IF HAVEMOUSE = 0 THEN EXIT SUB
  a = 3: b = 0: c = 0: d = 0
  Mouse a, b, c, d
  MX = c: MY = d
  IF (b AND 1) <> 0 THEN
    IF PB = 0 THEN
      CLK = 1: CLKX = c: CLKY = d
    END IF
    PB = 1
  ELSE
    PB = 0
  END IF
END SUB

FUNCTION PortAt (x, y)
  r = 0
  FOR p = 10 TO 49
    IF x >= ZX1(p) AND x <= ZX2(p) AND y >= ZY1(p) AND y <= ZY2(p) THEN r = p
  NEXT
  PortAt = r
END FUNCTION

SUB PutStat (r, l$, v$, c)
  COLOR 8
  LOCATE r, 1
  PRINT l$ + SPACE$(11 - LEN(l$));
  COLOR c
  LOCATE r + 1, 1
  PRINT LEFT$(v$ + SPACE$(11), 11);
END SUB

FUNCTION ReadGuess (p, tk)
  IF AUTOP <> 0 THEN
    Msg 1, "AUTO SOLVE: LAZER " + Num$(p) + " -> " + Num$(EXITP), 14
    tk = 11
    ReadGuess = EXITP
    EXIT FUNCTION
  END IF
  SoldOn SXP(p), SYP(p)
  FlushIn
  ClearBtns
  pr$ = "WHAT IS THE OUTPUT OF LAZER NO. " + Num$(p) + " ? "
  Msg 1, pr$, 15
  Msg 2, "CLICK THE EXIT PORT OR TYPE 2 DIGITS  (PRESS A = AUTO-SOLVE ALL)", 7
  HOVP = 0
  d$ = "": res = 0: done = 0
  t0! = TIMER: lb! = TIMER
  DO
    PollMouse
    MShow
    IF CLK <> 0 THEN
      CLK = 0
      s = SideHit(CLKX, CLKY)
      IF s = 2 THEN
        res = -1: done = 1
      ELSEIF s = 0 THEN
        q = PortAt(CLKX, CLKY)
        IF q > 0 THEN res = q: done = 1
      END IF
    END IF
    IF done = 0 THEN
      k$ = GetKey$
      IF k$ <> "" THEN
        kc = ASC(k$)
        IF kc = 27 THEN
          res = -1: done = 1
        ELSEIF kc = 65 OR kc = 97 THEN
          AUTOP = 1: res = EXITP: done = 1
        ELSEIF kc = 8 THEN
          d$ = ""
          Msg 1, pr$, 15
        ELSEIF kc >= 48 AND kc <= 57 THEN
          IF d$ = "" THEN
            IF kc >= 49 AND kc <= 52 THEN
              d$ = k$
            ELSE
              Snd 800, 4
            END IF
          ELSE
            d$ = d$ + k$
          END IF
          Msg 1, pr$ + d$, 15
          IF LEN(d$) = 2 THEN res = VAL(d$): done = 1
        ELSE
          Snd 800, 4
        END IF
      END IF
    END IF
    IF done = 0 THEN
      'hover highlight of the port under the mouse
      q = PortAt(MX, MY)
      IF q <> HOVP THEN
        MHide
        IF HOVP > 0 THEN DrawLabel HOVP, 0
        IF q > 0 THEN DrawLabel q, 1
        HOVP = q
      END IF
      'blinking soldier
      IF TIMER - lb! > .3 OR TIMER < lb! THEN
        MHide
        IF SOLDV <> 0 THEN SoldOff ELSE SoldOn SXP(p), SYP(p)
        lb! = TIMER
      END IF
    END IF
  LOOP UNTIL done <> 0
  MHide
  IF HOVP > 0 THEN DrawLabel HOVP, 0
  HOVP = 0
  IF SOLDV = 0 THEN SoldOn SXP(p), SYP(p)
  el! = TIMER - t0!
  IF el! < 0 THEN el! = el! + 86400!
  IF el! > 3000 THEN el! = 3000
  tk = INT(el! * 10) + 1
  IF AUTOP <> 0 THEN tk = 11
  ReadGuess = res
END FUNCTION

SUB ResetBoardView
  NB = 0
  SOLDV = 0: ALV = 0
  ENDVIEW = 0
  FOR p = 10 TO 49
    USED(p) = 0: UCOL(p) = 0
  NEXT
  SCRN = 3
  SHOWMENU = 1
  ClearBtns
  DrawGame
END SUB

SUB ShowMsg (l)
  r = 27 + l
  COLOR 15
  LOCATE r, 2
  PRINT SPACE$(76);
  COLOR MCOL(l)
  LOCATE r, 2
  PRINT LEFT$(MSGT$(l), 76);
END SUB

FUNCTION SideHit (x, y)
  SideHit = 0
  IF x >= 556 AND x < 636 AND y >= 64 AND y < 88 THEN
    SOUNDON = 1 - SOUNDON
    DrawSide
    SideHit = 1
    EXIT FUNCTION
  END IF
  IF SHOWMENU <> 0 AND x >= 556 AND x < 636 AND y >= 96 AND y < 120 THEN SideHit = 2
END FUNCTION

SUB SoldOff
  IF SOLDV <> 0 THEN
    MHide
    EraseActor SOLDX, SOLDY
    SOLDV = 0
  END IF
END SUB

SUB SoldOn (x, y)
  MHide
  SOLDX = x: SOLDY = y: SOLDV = 1
  DrawSoldier x, y
END SUB

SUB Snd (f, t)
  IF SOUNDON = 0 OR AUTOP <> 0 THEN EXIT SUB
  ff = f
  IF ff < 37 THEN ff = 37
  IF ff > 32767 THEN ff = 32767
  SOUND ff, t
END SUB

SUB StatusReset
  FOR i = 1 TO 3
    Msg i, "", 15
  NEXT
END SUB

SUB ThrowBomb (x1, y1, x2, y2)
  MHide
  dx! = x2 - x1: dy! = y2 - y1
  dist! = SQR(dx! * dx! + dy! * dy!)
  ns = INT(dist! / 14)
  IF ns < 1 THEN ns = 1
  FOR n = 0 TO ns
    bxx = x1 + CINT(dx! * n / ns)
    byy = y1 + CINT(dy! * n / ns)
    PUT (bxx - 8, byy - 9), BOMB, XOR
    Snd 300 + (ns - n) * 15, 1
    Dly .02
    PUT (bxx - 8, byy - 9), BOMB, XOR
  NEXT
END SUB

FUNCTION Title
  SCRN = 0: SHOWMENU = 0: NB = 0
  StatusReset
  ClearBtns
  DrawTitle
  AddBtn 220, 216, 200, 32, "1) PLAY THE GAME", ASC("1"), ASC("P")
  AddBtn 220, 264, 200, 32, "2) INSTRUCTIONS", ASC("2"), ASC("I")
  AddBtn 220, 312, 200, 32, "3) QUIT", ASC("3"), ASC("Q")
  DO
    r = WaitChoice
    IF r > 0 THEN EXIT DO
  LOOP
  ClearBtns
  Title = r
END FUNCTION

SUB Trace (p)
  s = (p - 10) \ 10: k = (p - 10) MOD 10
  SELECT CASE s
    CASE 0
      i = k: j = 0: di = 0: dj = 1
    CASE 1
      i = 0: j = k: di = 1: dj = 0
    CASE 2
      i = k: j = 9: di = 0: dj = -1
    CASE ELSE
      i = 9: j = k: di = -1: dj = 0
  END SELECT
  PX(0) = EPX(p): PY(0) = EPY(p): NP = 1
  BB = 0: NH = 0
  DO WHILE i >= 0 AND i <= 9 AND j >= 0 AND j <= 9
    IF MAZ(i, j) <> 0 THEN
      BB = BB + 1
      HCI(NH) = i: HCJ(NH) = j: NH = NH + 1
      PX(NP) = GX0 + i * CW + 16
      PY(NP) = GY0 + j * CW + 16
      NP = NP + 1
      t = di
      IF MAZ(i, j) = 1 THEN
        di = -dj: dj = -t
      ELSE
        di = dj: dj = t
      END IF
    END IF
    i = i + di: j = j + dj
  LOOP
  IF j < 0 THEN
    EXITP = 10 + i
  ELSEIF i < 0 THEN
    EXITP = 20 + j
  ELSEIF j > 9 THEN
    EXITP = 30 + i
  ELSE
    EXITP = 40 + j
  END IF
  PX(NP) = EPX(EXITP): PY(NP) = EPY(EXITP): NP = NP + 1
  BB = BB + 1
END SUB

SUB Tutorial
  QUITTUT = 0
  FOR i = 0 TO 9
    FOR j = 0 TO 9
      MAZ(i, j) = 0
    NEXT
  NEXT
  MAZ(3, 5) = 1: MAZ(5, 4) = 2: MAZ(9, 5) = 1: MAZ(5, 8) = 2: MAZ(6, 5) = 1
  MAZ(1, 2) = 1: MAZ(2, 8) = 1: MAZ(5, 1) = 2: MAZ(8, 2) = 2: MAZ(8, 9) = 2
  ResetBoardView
  SHOTNO = 0
  StatusReset
  Page "EACH NUMBER AROUND THE BOX IS A PLACE WHERE A LASER BEAM CAN ENTER OR EXIT.", "THE SOLDIER FIRES FROM THE ENTRY NUMBER; YOU CLICK THE EXIT."
  IF QUITTUT <> 0 THEN EXIT SUB
  Page "THE SLANTED LINES ARE REFLECTIVE BAFFLES.  THEY BEND THE BEAM TO THE", "RIGHT, LEFT, UP OR DOWN.  THE BAFFLES ARE ALWAYS VISIBLE."
  IF QUITTUT <> 0 THEN EXIT SUB
  StatusReset
  Msg 1, "WATCH A BEAM ENTER AT 22...", 15
  Demo 22, CT(0)
  Page "IT HITS A BAFFLE AND TURNS STRAIGHT UP TO COME OUT AT 11.", ""
  IF QUITTUT <> 0 THEN EXIT SUB
  StatusReset
  Msg 1, "NOW A BEAM ENTERING AT 20...", 15
  Demo 20, CT(1)
  Page "IT DOES NOT HIT ANY BAFFLE AND SIMPLY EXITS AT 40.", "NOW YOU TRY SOME.  CLICK THE EXIT PORT OF EACH BEAM."
  IF QUITTUT <> 0 THEN EXIT SUB
  FOR q = 1 TO 5
    SELECT CASE q
      CASE 1: p = 29
      CASE 2: p = 15
      CASE 3: p = 39
      CASE 4: p = 33
      CASE ELSE: p = 31
    END SELECT
    StatusReset
    Trace p
    tk = 1
    g = ReadGuess(p, tk)
    IF g < 0 THEN
      SoldOff
      EXIT SUB
    END IF
    DoShot p, g, CT(1 + q), 0
    IF HIT = 1 THEN
      Msg 1, "GOOD CALL!  BEAM " + Num$(p) + " COMES OUT AT " + Num$(EXITP) + ".", 10
    ELSE
      Msg 1, "NOT QUITE.  BEAM " + Num$(p) + " COMES OUT AT " + Num$(EXITP) + ".", 12
    END IF
    Dly 2
  NEXT
  Page "BEAM SCORE DEPENDS ON BAFFLES HIT AND ON HOW FAST YOU ANSWER.", "BONUSES ARE GIVEN FOR CORRECTLY PREDICTING ESPECIALLY COMPLEX PATHWAYS."
  IF QUITTUT <> 0 THEN EXIT SUB
  Page "EACH GAME HAS 20 BEAMS; EVERY NUMBER IS USED EXACTLY ONCE.", "THE HIGHER YOUR SCORE, THE MORE BAFFLES THE NEXT GAME HAS."
END SUB

FUNCTION WaitChoice
  MHide
  FOR i = 1 TO NBTN
    DrawBtn i, 0
  NEXT
  FlushIn
  hv = 0
  DO
    PollMouse
    MShow
    IF CLK <> 0 THEN
      CLK = 0
      s = SideHit(CLKX, CLKY)
      IF s = 2 THEN
        WaitChoice = -1
        EXIT FUNCTION
      END IF
      IF s = 0 THEN
        FOR i = 1 TO NBTN
          IF CLKX >= BTX(i) AND CLKX < BTX(i) + BTW(i) AND CLKY >= BTY(i) AND CLKY < BTY(i) + BTH(i) THEN
            WaitChoice = i
            EXIT FUNCTION
          END IF
        NEXT
      END IF
    END IF
    k$ = GetKey$
    IF k$ <> "" THEN
      kc = ASC(k$)
      IF kc = 27 THEN
        WaitChoice = -1
        EXIT FUNCTION
      END IF
      u = ASC(UCASE$(k$))
      FOR i = 1 TO NBTN
        IF BK1(i) = u OR BK2(i) = u THEN
          WaitChoice = i
          EXIT FUNCTION
        END IF
      NEXT
    END IF
    'button hover
    h = 0
    FOR i = 1 TO NBTN
      IF MX >= BTX(i) AND MX < BTX(i) + BTW(i) AND MY >= BTY(i) AND MY < BTY(i) + BTH(i) THEN h = i
    NEXT
    IF h <> hv THEN
      MHide
      IF hv > 0 THEN DrawBtn hv, 0
      IF h > 0 THEN DrawBtn h, 1
      hv = h
    END IF
  LOOP
END FUNCTION
