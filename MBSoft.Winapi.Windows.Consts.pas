unit MBSoft.Winapi.Windows.Consts;
//****************************************************************************
//Costanti di supporto per la unit MBSoft.Winapi.Windows
//
//Copyright MBSoft (2021-2022)
//****************************************************************************

interface

const
  //Colori della console.
  //FG_ = foreground, ovvero colore del testo;
  //BG_ = background, ovvero colore dello sfondo.
  //Gli attributi del testo occupano un byte e sono divisi in due nibble.
  //Quello meno significativo corrisponde al colore del testo, quello più
  //significativo al colore dello sfondo.
  //-------------------------------------------------
  //| 128 |  64 |  32 |  16 |  8  |  4  |  2  |  1  |
  //-------------------------------------------------
  //|       BACKGROUND      |      FOREGROUND       |
  //-------------------------------------------------
  //|INTEN|     |     |     |INTEN|     |     |     |
  //| SITY| RED |GREEN| BLUE| SITY| RED |GREEN| BLUE|
  //-------------------------------------------------
  FG_BLACK        = $00;
  FG_BLUE         = $01;
  FG_GREEN        = $02;
  FG_CYAN         = $03;
  FG_RED          = $04;
  FG_MAGENTA      = $05;
  FG_BROWN        = $06;
  FG_LIGHTGRAY    = $07;
  FG_DARKGRAY     = $08;
  FG_LIGHTBLUE    = $09;
  FG_LIGHTGREEN   = $0A;
  FG_LIGHTCYAN    = $0B;
  FG_LIGHTRED     = $0C;
  FG_LIGHTMAGENTA = $0D;
  FG_YELLOW       = $0E;
  FG_WHITE        = $0F;
  BG_BLACK        = $00;
  BG_BLUE         = $10;
  BG_GREEN        = $20;
  BG_CYAN         = $30;
  BG_RED          = $40;
  BG_MAGENTA      = $50;
  BG_BROWN        = $60;
  BG_LIGHTGRAY    = $70;
  BG_DARKGRAY     = $80;
  BG_LIGHTBLUE    = $90;
  BG_LIGHTGREEN   = $A0;
  BG_LIGHTCYAN    = $B0;
  BG_LIGHTRED     = $C0;
  BG_LIGHTMAGENTA = $D0;
  BG_YELLOW       = $E0;
  BG_WHITE        = $F0;

  //Combinazioni di colori testo-sfondo già pronte da usare
  CONSOLE_COLOR_NORMAL   = FG_LIGHTGRAY or BG_BLACK;
  CONSOLE_COLOR_LIGHT    = FG_WHITE or BG_BLACK;
  CONSOLE_COLOR_TWILIGHT = FG_YELLOW or BG_BLACK;
  CONSOLE_COLOR_CLASSIC  = FG_YELLOW or BG_BLUE;
  CONSOLE_COLOR_OCEAN    = FG_YELLOW or BG_LIGHTCYAN;

implementation

end.
