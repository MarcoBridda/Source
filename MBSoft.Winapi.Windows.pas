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
  TMBCoordHelper = record helper for TCoord
    constructor Create(X, Y: SmallInt);
    function ToString: String;

    class operator Implicit(Coord: TCoord): String;
  end;

  TConsoleColor = (ccBlack, ccBlue, ccGreen, ccCyan, ccRed, ccMagenta,
    ccBrown, ccLightGray, ccDarkGray, ccLightBlue, ccLightGreen,
    ccLightCyan, ccLightRed, ccLightMagenta, ccYellow, ccWhite);

  TConsoleColorHelper = record helper for TConsoleColor
    function ToString: String;

    class operator Implicit(Color: TConsoleColor): String;
  end;

  TConsole = record
  private
    class var
      FStdIn: THandle;
      FStdOut: THandle;
      FStdError: THandle;

    class function GetCheckStdHandle(nStdHandle: Cardinal;
      aCheck: Boolean): NativeUInt; static;

    class function GetStdOut(aCheck: Boolean = false): THandle; static;
    class function GetStdIn(aCheck: Boolean = false): THandle; static;
    class function GetStdError(aCheck: Boolean = false): THandle; static;

    class function GetBufferInfo: TConsoleScreenBufferInfo; static;
    class function GetHeight: SmallInt; static;
    class function GetSize: TCoord; static;
    class function GetWidth: SmallInt; static;
    class function GetAttributes: Word; static;
    class function GetCursorPosition: TCoord; static;
    class procedure SetCursorPosition(const Value: TCoord); static;
    class function GetCursorX: SmallInt; static;
    class function GetCursorY: Smallint; static;
    class procedure SetCursorX(const Value: SmallInt); static;
    class procedure SetCursorY(const Value: Smallint); static;

    class procedure ClearScreen(aAttributes: Integer = -1); static;
    class function GetBgColor: TConsoleColor; static;
    class function GetFgColor: TConsoleColor; static;
    class procedure SetBgColor(const Value: TConsoleColor); static;
    class procedure SetFgColor(const Value: TConsoleColor); static;
  public
    class constructor Create;

    class procedure ClrScr; overload; static;
    class procedure ClrScr(aAttributes: Integer); overload; static;
    class procedure ClrScr(const aBgColor, aFgColor: TConsoleColor); overload; static;
    class function Area: DWORD; static;

    class property BufferInfo: TConsoleScreenBufferInfo read GetBufferInfo;
    class property Size: TCoord read GetSize;
    class property Width: SmallInt read GetWidth;
    class property Height: SmallInt read GetHeight;
    class property Attributes: Word read GetAttributes;
    class property CursorPosition: TCoord read GetCursorPosition
      write SetCursorPosition;
    class property CursorX: SmallInt read GetCursorX write SetCursorX;
    class property CursorY: Smallint read GetCursorY write SetCursorY;

    class property BgColor: TConsoleColor read GetBgColor write SetBgColor;
    class property FgColor: TConsoleColor read GetFgColor write SetFgColor;

    class property StdIn: THandle read FStdIn;
    class property StdOut: THandle read FStdOut;
    class property StdError: THandle read FStdError;
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
    function ToString: String;
  end;

  TOrdinalDayOfWeekHelper = record helper for TOrdinalDayOfWeek
    function ToString: String;
  end;

  TTimeZoneIdHelper = record helper for TTimeZoneId
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

const
  //Stringhe per il metodo ToString del TConsoleColorHelper
  CONSOLE_COLOR_STRINGS: array[TConsoleColor] of String = ('Black', 'Blue',
    'Green', 'Cyan', 'Red', 'Magenta', 'Brown', 'Lightgray', 'DarkGray',
    'LightBlue', 'LightGreen', 'LightCyan', 'LightRed', 'LightMagenta',
    'Yellow', 'White');

{ TConsole }

class function TConsole.Area: DWORD;
begin
  Result:=Size.X*Size.Y
end;

class procedure TConsole.ClearScreen(aAttributes: Integer);
var
  NumWritten: DWORD;
  Origin: TCoord;
begin
  if (aAttributes>=0) and (aAttributes<=255) then
    SetConsoleTextAttribute(FStdOut,aAttributes);

  Origin:=TCoord.Create(0,0);

  Win32Check(FillConsoleOutputCharacter(FStdOut, ' ', Area, Origin,
    NumWritten));
  Win32Check(FillConsoleOutputAttribute(FStdOut, Attributes, Area, Origin,
    NumWritten));
  CursorPosition:=Origin
end;

class procedure TConsole.ClrScr(const aBgColor, aFgColor: TConsoleColor);
begin
  TConsole.BgColor:=aBgColor;
  TConsole.FgColor:=aFgColor;
  TConsole.ClrScr
end;

class procedure TConsole.ClrScr;
begin
  ClearScreen(TConsole.Attributes)
end;

class procedure TConsole.ClrScr(aAttributes: Integer);
begin
  ClearScreen(aAttributes)
end;

class constructor TConsole.Create;
begin
  FStdIn:=GetStdIn(true);
  FStdOut:=GetStdOut(true);
  FStdError:=GetStdError(true);
end;

class function TConsole.GetAttributes: Word;
begin
  Result:=GetBufferInfo.wAttributes;
end;

class function TConsole.GetBgColor: TConsoleColor;
begin
  Result:=TConsoleColor((GetAttributes and $F0) shr 4)
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
  Result:=TConsoleColor(GetAttributes and $F)
end;

class function TConsole.GetHeight: SmallInt;
begin
  Result:=GetBufferInfo.dwSize.Y;
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

class procedure TConsole.SetBgColor(const Value: TConsoleColor);
var
  Attrib: Word;
begin
  Attrib:=(Attributes and $FF0F) or (Word(Value) shl 4);
  Win32Check(SetConsoleTextAttribute(FStdOut,Attrib));
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
var
  Attrib: Word;
begin
  Attrib:=(Attributes and $FFF0) or Word(Value);
  Win32Check(SetConsoleTextAttribute(FStdOut,Attrib));
end;

{ TMBCoordHelper }

constructor TMBCoordHelper.Create(X, Y: SmallInt);
begin
  Self.X:=X;
  Self.Y:=Y;
end;

class operator TMBCoordHelper.Implicit(Coord: TCoord): String;
begin
  Result:=Coord.ToString
end;

function TMBCoordHelper.ToString: String;
begin
  Result:='('+Self.X.ToString+','+Self.Y.ToString+')'
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

const
  //Stringe per il metodo ToString del TDateEncodingFormatHelper
  DATE_ENCODING_FORMAT_STRINGS: array[TDateEncodingFormat] of String = (
    'Unknow', 'Absolute', 'Relative', 'Error');

  //Stringe per il metodo ToString del TOrdinalDayOfWeekHelper
  ORDINAL_DAY_OF_WEEK_STRINGS: array[TOrdinalDayOfWeek] of String = (
    'Unknow', 'First', 'Second', 'Third', 'Forth', 'Last', 'Error');

  //Stringe per il metodo ToString del TTimeZoneIdHelper
  TIME_ZONE_ID_STRINGS: array[TTimeZoneId] of String = ('Unknow',
    'Standard', 'DayLight', 'Error');

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
