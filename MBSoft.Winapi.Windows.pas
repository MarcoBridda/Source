unit MBSoft.Winapi.Windows;
//****************************************************************************
//Aggiunte alla unit Winapi.Windows
//
//Copyrigth MBSoft (2021-2023)
//****************************************************************************

interface

uses
  System.SysUtils, System.Math,
  Winapi.Windows,
  MBSoft.System, MBSoft.System.DateUtils;

const
  LIB_VERSION: TProductFileVersion = (Major: 1; Minor: 0; Build: 0; Release: 0);

//****************************************************************************
//Supporto esteso alla console, un po' più Delphi friendly...
//è migliorabile sicuramente ma per il momento mi accontento.
//****************************************************************************

type
  TCoordHelper = record helper for TCoord
  public
    constructor Create(X, Y: SmallInt);
    function ToString: String;

    class operator Implicit(Coord: TCoord): String;
  end;

  TSmallRectHelper = record helper for TSmallRect
  private
    function GetArea: Cardinal;
    function GetHeight: SmallInt;
    function GetWidth: SmallInt;
    procedure SetHeight(const Value: SmallInt);
    procedure SetWidth(const Value: SmallInt);
    function GetLeftTop: TCoord;
    function GetRightBottom: TCoord;
  public
    constructor Create(const aLeft, aTop, aRight, aBottom: SmallInt); overload;
    constructor Create(const aLeftTop, aRightBottom: TCoord); overload;

    property Width: SmallInt read GetWidth write SetWidth;
    property Height: SmallInt read GetHeight write SetHeight;

    property Area: Cardinal read GetArea;

    property LeftTop: TCoord read GetLeftTop;
    property RightBottom: TCoord read GetRightBottom;
  end;

  TConsoleColor = (ccBlack, ccBlue, ccGreen, ccCyan, ccRed, ccMagenta,
    ccBrown, ccLightGray, ccDarkGray, ccLightBlue, ccLightGreen,
    ccLightCyan, ccLightRed, ccLightMagenta, ccYellow, ccWhite);

  TConsoleColorHelper = record helper for TConsoleColor
  private const
    CONSOLE_COLOR_STRINGS: array[TConsoleColor] of String = ('Black', 'Blue',
      'Green', 'Cyan', 'Red', 'Magenta', 'Brown', 'Lightgray', 'DarkGray',
      'LightBlue', 'LightGreen', 'LightCyan', 'LightRed', 'LightMagenta',
      'Yellow', 'White');
  public
    function ToString: String;

    class operator Implicit(Color: TConsoleColor): String;
  end;

  //Una struttura per gli attributi in formato TConsoleColor
  TConsoleAttributes = record
  public
    FgColor: TConsoleColor;
    BgColor: TConsoleColor;

    constructor Create(const aFgColor, aBgColor: TConsoleColor); overload;
    constructor Create(const aRawAttributes: Word); overload;

    function ChangeRawAttributes(const aRawAttributes: Word): Word;

    class function ExtractFgColor(const aRawAttributes: Word): TConsoleColor; static;
    class function ExtractBgColor(const aRawAttributes: Word): TConsoleColor; static;

    class function ChangeRawFgColor(const aRawAttributes: Word; const Color: TConsoleColor): Word; static;
    class function ChangeRawBgColor(const aRawAttributes: Word; const Color: TConsoleColor): Word; static;
  end;

  TConsole = record
  private
    class var
      FStdIn: THandle;
      FStdOut: THandle;
      FStdError: THandle;

  private
    class function GetCheckStdHandle(nStdHandle: Cardinal;
      aCheck: Boolean): NativeUInt; static;

    class function GetStdIn(aCheck: Boolean = false): THandle; static;
    class function GetStdOut(aCheck: Boolean = false): THandle; static;
    class function GetStdError(aCheck: Boolean = false): THandle; static;

    class function GetBufferInfo: TConsoleScreenBufferInfo; static;

    class function GetWidth: SmallInt; static;
    class function GetHeight: SmallInt; static;
    class function GetSize: TCoord; static;

    class function GetRawAttributes: Word; static;
    class procedure SetRawAttributes(const Value: Word); static;

    class function GetAttributes: TConsoleAttributes; static;
    class procedure SetAttributes(const Value: TConsoleAttributes); static;

    class function GetCursorPosition: TCoord; static;
    class procedure SetCursorPosition(const Value: TCoord); static;

    class function GetCursorX: SmallInt; static;
    class procedure SetCursorX(const Value: SmallInt); static;

    class function GetCursorY: Smallint; static;
    class procedure SetCursorY(const Value: Smallint); static;

    class procedure ClearRect(const aRect: TSmallRect; const aAttributes: TConsoleAttributes); static;

    class function GetBgColor: TConsoleColor; static;
    class procedure SetBgColor(const Value: TConsoleColor); static;

    class function GetFgColor: TConsoleColor; static;
    class procedure SetFgColor(const Value: TConsoleColor); static;
    class function GetMaxX: SmallInt; static;
    class function GetMaxY: SmallInt; static;
  public
    class constructor Create;

    class procedure ClrScr; overload; static;
    class procedure ClrScr(const aAttributes: TConsoleAttributes); overload; static;
    class procedure ClrScr(const aFgColor, aBgColor: TConsoleColor); overload; static;

    class procedure ClrEOL; overload; static;
    class procedure ClrEOL(const aAttributes: TConsoleAttributes); overload; static;
    class procedure ClrEOL(const aFgColor, aBgColor: TConsoleColor); overload; static;

    class function Area: DWORD; static;

    class property StdIn: THandle read FStdIn;
    class property StdOut: THandle read FStdOut;
    class property StdError: THandle read FStdError;

    class property BufferInfo: TConsoleScreenBufferInfo read GetBufferInfo;

    class property Width: SmallInt read GetWidth;
    class property Height: SmallInt read GetHeight;

    class property MaxX: SmallInt read GetMaxX;
    class property MaxY: SmallInt read GetMaxY;

    class property Size: TCoord read GetSize;

    class property RawAttributes: Word read GetRawAttributes
      write SetRawAttributes;

    class property Attributes: TConsoleAttributes read GetAttributes
      write SetAttributes;

    class property CursorPosition: TCoord read GetCursorPosition
      write SetCursorPosition;
    class property CursorX: SmallInt read GetCursorX write SetCursorX;
    class property CursorY: Smallint read GetCursorY write SetCursorY;

    class property BgColor: TConsoleColor read GetBgColor write SetBgColor;
    class property FgColor: TConsoleColor read GetFgColor write SetFgColor;
  end;

//****************************************************************************
//Supporto per le info di versione di un eseguibile
//Per info vedere la unit Winapi.Windows
//****************************************************************************

type
  //Un record helper per la struttura TVSFixedFileInfo
  TVSFixedFileInfoHelper = record helper for TVSFixedFileInfo
    //Recupera la struttura che contiene la versione e altre cose.
    //Filename è il nome dell' eseguibile;
    //La funzione ritorna vera se è riuscita nel suo intento.
    function Init(FileName: String): Boolean;

    //Versione del file
    function GetFileVersion: TProductFileVersion;
    //Versione del prodotto software di cui fa parte il file
    function GetProductVersion: TProductFileVersion;
  end;

//****************************************************************************
//Supporto per la gestione dei fusi orari e delle date di transizione  tra
//ora legale e ora solare, e viceversa
//****************************************************************************

type
  //Codifica della data di transizione tra ora solare e ora legale
  TDateEncodingFormat = (efUnknown, efAbsolute, efRelative, efError);

  //Posizione del giorno della settimana nel mese quando viene usate la
  //codifica relativa (primo, secondo terzo, quarto e ultimo)
  TOrdinalDayOfWeek = (odUnknown, odFirst, odSecond, odThird, odForth, odLast,
    odError);

  //Orario solare (standard) o legale (daylight)?
  TTimeZoneId = (tzUnknown, tzStandard, tzDaylight, tzError);

  //Per comodità di debug definisco anche tre helper per avere la versione
  //stampabile dei tipi definiti sopra
  TDateEncodingFormatHelper = record helper for TDateEncodingFormat
  private const
    DATE_ENCODING_FORMAT_STRINGS: array[TDateEncodingFormat] of String = (
      'Unknow', 'Absolute', 'Relative', 'Error');
  public
    function ToString: String;
  end;

  TOrdinalDayOfWeekHelper = record helper for TOrdinalDayOfWeek
  private const
    ORDINAL_DAY_OF_WEEK_STRINGS: array[TOrdinalDayOfWeek] of String = (
      'Unknow', 'First', 'Second', 'Third', 'Forth', 'Last', 'Error');
  public
    function ToString: String;
  end;

  TTimeZoneIdHelper = record helper for TTimeZoneId
  private const
    TIME_ZONE_ID_STRINGS: array[TTimeZoneId] of String = ('Unknow',
      'Standard', 'DayLight', 'Error');
    function ToString: String;
  end;

  //Il BIAS rappresenta la differenza tra l'ora locale e UTC, partendo proprio
  //dall'ora locale e andando verso UTC; per cui l'orario di Roma ha un BIAS
  //di -1 ora: UTC è un'ora INDIETRO rispetto a Roma.
  //(BIAS = UTC - LocalTime).
  //Io invece sono più comodo a ragionare partendo da UTC e andando verso
  //l'orario locale, per cui Roma è un'ora AVANTI rispetto a UTC.
  //(BIAS = LocalTime - UTC).
  //Ne consegue che per comodità (e per non fare un torto a nessuno) ho
  //creato un alias ed un helper per gestire entrambi i casi.
  TTzBias = Integer;

  TTzBiasHelper = record helper for TTzBias
  private
    function GetUTCToLocalTime: Integer;
    procedure SetUTCToLocalTime(const Value: Integer);  //Il BIAS originale
  public
    constructor Create(const aBias: Integer; const IsOriginal: Boolean = true);

    //Il mio BIAS che ha il segno opposto
    property UTCToLocalTime: Integer read GetUTCToLocalTime
      write SetUTCToLocalTime;
  end;

  //Le date di transizione tra ora solare e legale sono in formato
  //SYSTEMTIME (TSystemTime in Delphi). Per renderle un po' più Delphi
  //friendly ho deciso di creare un alias a questo tipo, in modo da poter
  //agganciare un helper solo a questo caso specifico e anche per
  //decodificare le date in formato relativo
  TTzSystemTime = TSystemTime;

  TTzSystemTimeHelper = record helper for TTzSystemTime
  private
    function GetDateTime: TDateTime;
    function GetDayOfWeek: TDayOfWeek;
    function GetMonthName: TMonthName;
    function GetOrdinalDayOfWeek: TOrdinalDayOfWeek;
    function GetEncodingFormat: TDateEncodingFormat;
  public
    property Month: TMonthName read GetMonthName;
    property DayOfWeek: TDayOfWeek read GetDayOfWeek;
    property OrdinalDayOfWeek: TOrdinalDayOfWeek read GetOrdinalDayOfWeek;
    property DateTime: TDateTime read GetDateTime;
    property EncodingFormat: TDateEncodingFormat read GetEncodingFormat;

    function ToString: String;
  end;

  //Per comodità raggruppo le informazioni su un TimeZone
  TZoneInfo = record
  private
    FName: String;
    FDate: TTzSystemTime;
    FBias: TTzBias;
  public
    constructor Create(const aName: String; const aDate: TSystemTime;
      const aBias: Integer);

    property Name: String read FName write FName;
    property Date: TTzSystemTime read FDate write FDate;
    property Bias: TTzBias read FBias write FBias;
  end;

  //Infine, ma non per importanza (last but not least, come direbbero gli
  //inglesi..) la struttura che contiene tutto.
  //Siccome non posso definire un costruttore senza paramteri l'ho cammuffato
  //nel metodo Init che usa la funzione windows GetTimeZoneInformation a cui
  //rimando per ulteriori informazioni.
  //Init ritorna vero se la chiamata ha avuto successo, atrimenti falso, e
  //in questo caso si può interrogare la proprietà ErrorId per avere info
  //sull'errore.
  TTimeZoneInfo = record
  private
    FBias: TTzBias;
    FStandardInfo: TZoneInfo;
    FDaylightInfo: TZoneInfo;
    FCurrentTimeZone: TTimeZoneId;
    FCurrentBias: TTzBias;

    FErrorId: Integer;
  public
    function Init: Boolean;

    property Bias: TTzBias read FBias write FBias;
    property StandardInfo: TZoneInfo read FStandardInfo write FStandardInfo;
    property DaylightInfo: TZoneInfo read FDaylightInfo write FDaylightInfo;
    property CurrentTimeZone: TTimeZoneId read FCurrentTimeZone
      write FCurrentTimeZone;
    property CurrentBias: TTzBias read FCurrentBias write FCurrentBias;

    property ErrorId: Integer read FErrorId;
  end;


implementation

uses
  System.Types;

{ TConsole }

class function TConsole.Area: DWORD;
begin
  Result:=Size.X*Size.Y
end;

class procedure TConsole.ClearRect(const aRect: TSmallRect;
  const aAttributes: TConsoleAttributes);
var
  CharCount: Cardinal;
begin
  Attributes:=aAttributes;

  Win32Check(FillConsoleOutputCharacter(FStdOut, ' ', aRect.Area, aRect.LeftTop,
    CharCount));
  Win32Check(FillConsoleOutputAttribute(FStdOut, RawAttributes, aRect.Area, aRect.LeftTop,
    CharCount));
  CursorPosition:=aRect.LeftTop
end;

class procedure TConsole.ClrEOL;
begin
  ClrEOL(Attributes)
end;

class procedure TConsole.ClrEOL(const aAttributes: TConsoleAttributes);
var
  Rect: TSmallRect;
begin
  Rect:=TSmallRect.Create(CursorX, CursorY, MaxX, CursorY);
  ClearRect(Rect, aAttributes)
end;

class procedure TConsole.ClrEOL(const aFgColor, aBgColor: TConsoleColor);
begin
  ClrEOL(TConsoleAttributes.Create(aFgColor, aBgColor))
end;

class procedure TConsole.ClrScr(const aFgColor, aBgColor: TConsoleColor);
begin
  ClrScr(TConsoleAttributes.Create(aFgColor, aBgColor))
end;

class procedure TConsole.ClrScr;
begin
  ClrScr(Attributes)
end;

class procedure TConsole.ClrScr(const aAttributes: TConsoleAttributes);
var
  Rect: TSmallRect;
begin
  Rect:=TSmallRect.Create(0, 0, Width, Height);
  ClearRect(Rect, aAttributes)
end;

class constructor TConsole.Create;
begin
  FStdIn:=GetStdIn(true);
  FStdOut:=GetStdOut(true);
  FStdError:=GetStdError(true);
end;

class function TConsole.GetRawAttributes: Word;
begin
  Result:=GetBufferInfo.wAttributes;
end;

class function TConsole.GetAttributes: TConsoleAttributes;
begin
  Result:=TConsoleAttributes.Create(RawAttributes);
end;

class function TConsole.GetBgColor: TConsoleColor;
begin
  Result:=TConsoleAttributes.ExtractBgColor(RawAttributes)
end;

class function TConsole.GetBufferInfo: TConsoleScreenBufferInfo;
begin
  Win32Check(GetConsoleScreenBufferInfo(FStdOut, Result));
end;

class function TConsole.GetCheckStdHandle(nStdHandle: Cardinal;
  aCheck: Boolean): NativeUInt;
begin
  Result:=GetStdHandle(nStdHandle);
  if aCheck then
    Win32Check(Result<>INVALID_HANDLE_VALUE)
end;

class function TConsole.GetCursorPosition: TCoord;
begin
  Result:=GetBufferInfo.dwCursorPosition
end;

class function TConsole.GetCursorX: SmallInt;
begin
  Result:=GetBufferInfo.dwCursorPosition.X;
end;

class function TConsole.GetCursorY: Smallint;
begin
  Result:=GetBufferInfo.dwCursorPosition.Y;
end;

class function TConsole.GetFgColor: TConsoleColor;
begin
  Result:=TConsoleAttributes.ExtractFgColor(RawAttributes)
end;

class function TConsole.GetHeight: SmallInt;
begin
  Result:=GetBufferInfo.dwSize.Y;
end;

class function TConsole.GetMaxX: SmallInt;
begin
  Result:=Width-1
end;

class function TConsole.GetMaxY: SmallInt;
begin
  Result:=Height-1
end;

class function TConsole.GetSize: TCoord;
begin
  Result:=GetBufferInfo.dwSize;
end;

class function TConsole.GetStdError(aCheck: Boolean): THandle;
begin
  Result:=GetCheckStdHandle(STD_ERROR_HANDLE,aCheck)
end;

class function TConsole.GetStdIn(aCheck: Boolean): THandle;
begin
  Result:=GetCheckStdHandle(STD_INPUT_HANDLE,aCheck)
end;

class function TConsole.GetStdOut(aCheck: Boolean): THandle;
begin
  Result:=GetCheckStdHandle(STD_OUTPUT_HANDLE,aCheck)
end;

class function TConsole.GetWidth: SmallInt;
begin
  Result:=GetBufferInfo.dwSize.X;
end;

class procedure TConsole.SetAttributes(const Value: TConsoleAttributes);
begin
  RawAttributes:=Value.ChangeRawAttributes(RawAttributes)
end;

class procedure TConsole.SetBgColor(const Value: TConsoleColor);
begin
  RawAttributes:=TConsoleAttributes.ChangeRawBgColor(RawAttributes, Value)
end;

class procedure TConsole.SetCursorPosition(const Value: TCoord);
begin
  Win32Check(SetConsoleCursorPosition(FStdOut, Value));
end;

class procedure TConsole.SetCursorX(const Value: SmallInt);
begin
  CursorPosition:=TCoord.Create(Value, GetCursorY)
end;

class procedure TConsole.SetCursorY(const Value: Smallint);
begin
  CursorPosition:=TCoord.Create(GetCursorX,Value)
end;

class procedure TConsole.SetFgColor(const Value: TConsoleColor);
begin
  RawAttributes:=TConsoleAttributes.ChangeRawFgColor(RawAttributes, Value)
end;

class procedure TConsole.SetRawAttributes(const Value: Word);
begin
  Win32Check(SetConsoleTextAttribute(FStdOut,Value));
end;

{ TMBCoordHelper }

constructor TCoordHelper.Create(X, Y: SmallInt);
begin
  Self.X:=X;
  Self.Y:=Y;
end;

class operator TCoordHelper.Implicit(Coord: TCoord): String;
begin
  Result:=Coord.ToString
end;

function TCoordHelper.ToString: String;
begin
  Result:='('+Self.X.ToString+','+Self.Y.ToString+')'
end;

{ TSmallRectHelper }

constructor TSmallRectHelper.Create(const aLeftTop, aRightBottom: TCoord);
begin
  Create(aLeftTop.X, aLeftTop.Y, aRightBottom.X, aRightBottom.Y)
end;

function TSmallRectHelper.GetArea: Cardinal;
begin
  Result:=Self.Width * Self.Height;
end;

function TSmallRectHelper.GetHeight: SmallInt;
begin
  Result:=Self.Bottom - Self.Top + 1;
end;

function TSmallRectHelper.GetLeftTop: TCoord;
begin
  Result:=TCoord.Create(Self.Left, Self.Top)
end;

function TSmallRectHelper.GetRightBottom: TCoord;
begin
  Result:=TCoord.Create(Self.Right, Self.Bottom)
end;

function TSmallRectHelper.GetWidth: SmallInt;
begin
  Result:=Self.Right - Self.Left + 1
end;

procedure TSmallRectHelper.SetHeight(const Value: SmallInt);
begin
  Inc(Self.Bottom,Value-Height)
end;

procedure TSmallRectHelper.SetWidth(const Value: SmallInt);
begin
  Inc(Self.Right,Value-Width)
end;

constructor TSmallRectHelper.Create(const aLeft, aTop, aRight,
  aBottom: SmallInt);
begin
  Self.Left:=aLeft;
  Self.Top:=aTop;
  Self.Right:=aRight;
  Self.Bottom:=aBottom
end;

{ TConsoleColorRecordHelper }

class operator TConsoleColorHelper.Implicit(Color: TConsoleColor): String;
begin
  Result:=Color.ToString
end;

function TConsoleColorHelper.ToString: String;
begin
  Result:=CONSOLE_COLOR_STRINGS[Self]
end;

{ TConsoleAttributes }

constructor TConsoleAttributes.Create(const aFgColor, aBgColor: TConsoleColor);
begin
  FgColor:=aFgColor;
  BgColor:=aBgColor
end;

function TConsoleAttributes.ChangeRawAttributes(
  const aRawAttributes: Word): Word;
begin
  Result:=TConsoleAttributes.ChangeRawFgColor(aRawAttributes, Self.FgColor);
  Result:=TConsoleAttributes.ChangeRawBgColor(Result,Self.BgColor);
end;

class function TConsoleAttributes.ChangeRawBgColor(
  const aRawAttributes: Word; const Color: TConsoleColor): Word;
begin
  Result:=(aRawAttributes and $FF0F) or (Word(Color) shl 4);
end;

class function TConsoleAttributes.ChangeRawFgColor(
  const aRawAttributes: Word; const Color: TConsoleColor): Word;
begin
  Result:=(aRawAttributes and $FFF0) or Word(Color);
end;

constructor TConsoleAttributes.Create(const aRawAttributes: Word);
begin
  FgColor:=TConsoleAttributes.ExtractFgColor(aRawAttributes);
  BgColor:=TConsoleAttributes.ExtractBgColor(aRawAttributes);
end;

class function TConsoleAttributes.ExtractBgColor(
  const aRawAttributes: Word): TConsoleColor;
begin
  Result:=TConsoleColor((aRawAttributes and $F0) shr 4)
end;

class function TConsoleAttributes.ExtractFgColor(
  const aRawAttributes: Word): TConsoleColor;
begin
  Result:=TConsoleColor(aRawAttributes and $F)
end;

{ TVSFixedFileInfoHelper }

function TVSFixedFileInfoHelper.GetFileVersion: TProductFileVersion;
begin
  Result.Create(Self.dwFileVersionMS,Self.dwFileVersionLS);
end;

function TVSFixedFileInfoHelper.GetProductVersion: TProductFileVersion;
begin
  Result.Create(Self.dwProductVersionMS,Self.dwProductVersionLS);
end;

function TVSFixedFileInfoHelper.Init(FileName: String): Boolean;
var
  RawSize, ValueSize, DUMMY: DWORD;
  RawInfo: Pointer;
  PInfo: PVSFixedFileInfo;
begin
  RawSize:=GetFileVersionInfoSize(PChar(FileName),DUMMY);
  Result:=RawSize>0;
  if Result then
  begin
      GetMem(RawInfo, RawSize);
      try
        Result:=GetFileVersionInfo(PChar(FileName), 0, RawSize, RawInfo);
        if Result then
        begin
          VerQueryValue(RawInfo, '\', Pointer(PInfo), ValueSize);
          Self:=PInfo^
        end;
      finally
        FreeMem(RawInfo, RawSize);
      end;
  end;
end;

{ TTimeZoneBias }

constructor TTzBiasHelper.Create(const aBias: Integer;
  const IsOriginal: Boolean);
begin
  if IsOriginal then
    Self:=aBias
  else
    Self:=-aBias
end;

function TTzBiasHelper.GetUTCToLocalTime: Integer;
begin
  Result:=-Self
end;

procedure TTzBiasHelper.SetUTCToLocalTime(const Value: Integer);
begin
  Self:=-Value
end;

{ TTzSystemTimeHelper }

function TTzSystemTimeHelper.GetDateTime: TDateTime;
begin
  Result:=TDatetime.Create(Self.wYear,Self.wMonth,Self.wDay,
    Self.wHour,Self.wMinute,Self.wSecond,Self.wMilliseconds);
end;

function TTzSystemTimeHelper.GetDayOfWeek: TDayOfWeek;
begin
  Result:=TDayOfWeek(Self.wDayOfWeek+1)
end;

function TTzSystemTimeHelper.GetEncodingFormat: TDateEncodingFormat;
begin
  if Self.Month<>mnUnknown then
    if Self.wYear>0 then
      Result:=efAbsolute
    else
      Result:=efRelative
  else
    Result:=efUnknown
end;

function TTzSystemTimeHelper.GetMonthName: TMonthName;
begin
  Result:=TMonthName(Self.wMonth)
end;

function TTzSystemTimeHelper.GetOrdinalDayOfWeek: TOrdinalDayOfWeek;
begin
  if Self.EncodingFormat=efRelative then
    Result:=TOrdinalDayOfWeek(Self.wDay)
  else
    Result:=odError
end;

function TTzSystemTimeHelper.ToString: String;
begin
  //
end;

{ TTimeZoneIdHelper }

function TTimeZoneIdHelper.ToString: String;
begin
  Result:=TIME_ZONE_ID_STRINGS[Self]
end;

{ TDateEncodingFormatHelper }

function TDateEncodingFormatHelper.ToString: String;
begin
  Result:=DATE_ENCODING_FORMAT_STRINGS[Self]
end;

{ TOrdinalDayOfWeekHelper }

function TOrdinalDayOfWeekHelper.ToString: String;
begin
  Result:=ORDINAL_DAY_OF_WEEK_STRINGS[Self]
end;

{ TZoneInfo }

constructor TZoneInfo.Create(const aName: String; const aDate: TSystemTime;
  const aBias: Integer);
begin
  Name:=aName;
  Date:=aDate;
  Bias:=TTzBias.Create(aBias)
end;

{ TTimeZoneInfo }

function TTimeZoneInfo.Init: Boolean;
var
  Info: Time_Zone_Information;
  R: Integer;
begin
  R:=GetTimeZoneInformation(Info);
  Result:=R in [ TIME_ZONE_ID_UNKNOWN..TIME_ZONE_ID_DAYLIGHT];
  if Result  then
  begin
    Bias:=TTzBias.Create(Info.Bias);
    StandardInfo:=TZoneInfo.Create(Info.StandardName,Info.StandardDate,
      Info.StandardBias);
    DaylightInfo:=TZoneInfo.Create(Info.DaylightName,Info.DaylightDate,
      Info.DaylightBias);
    CurrentTimeZone:=TTimeZoneId(R);
    case CurrentTimeZone of
      tzUnknown : CurrentBias:=Bias;
      tzStandard: CurrentBias:=Bias+StandardInfo.Bias;
      tzDaylight: CurrentBias:=Bias+DaylightInfo.Bias
    end;
  end
  else
  begin
    CurrentTimeZone:=tzError;
    FErrorId:=GetLastError
  end;

end;

end.
