unit MBSoft.System.DateUtils;
//*****************************************************************************
//Unità di supporto per manipolare le informazioni su data e ora.
//Siccome vengono usate routines da due namespace (System.SysUtils e
//System.DateUtils) ho deciso di espandere quello più specifico.
//
//Copyright MBSoft (2018-2022)
//*****************************************************************************

interface

uses
  System.SysUtils, System.DateUtils;


type
  //I mesi e i giorni della settimana, un po' più delphi friendly. Siccome i
  //valori possibili vanno da 1 a 7 per i giorni della settimana, e da 1 a 12
  //per i mesi, ho usato il valore ordinale 0 per identificare il fatto che la
  //variabile non sia stata ancora assegnata, o l'assegnazione abbia causato un
  //errore
  TMonthName = (mnUnknown, mnJanuary, mnFebruary, mnMarch, mnApril, mnMay, mnJune,
                mnJuly, mnAugust, mnSeptember, mnOctober, mnNovember, mnDecember);

  TDayOfWeek = (dwUnknown, dwSunday, dwMonday, dwTuesday, dwWednesday, dwThursday,
                dwFriday, dwSaturday);

  TDateTimeToStringConvertMode = (cmDateTime, cmOnlyDate, cmOnlyTime);

  //Un Record Helper per il tipo TDateTime. I vari metodi implementati fanno
  //riferimento alle funzioni equivalenti definite nelle unit SysUtils e DateUtils
  TDateTimeHelper = record helper for TDateTime
  private
    function GetDate: TDateTime;
    function GetTime: TDateTime;
    function GetDay: Word;
    function GetDayOfTheWeek: Word;
    function GetDayOfWeek: Word;
    function GetHour: Word;
    function GetMilliSecond: Word;
    function GetMinute: Word;
    function GetMonth: Word;
    function GetSecond: Word;
    function GetYear: Word;
    function GetWeek: Word;
    function GetDayOfWeekName: TDayOfWeek;
    function GetMonthName: TMonthName;
    procedure SetYear(const aValue: Word);
    procedure SetMonthName(const aValue: TMonthName);
    procedure SetMonth(const aValue: Word);
    procedure SetDay(const aValue: Word);
    procedure SetHour(const aValue: Word);
    procedure SetMinute(const aValue: Word);
    procedure SetSecond(const aValue: Word);
    procedure SetMillisecond(const aValue: Word);
  public
    class function CurrentDate: TDateTime; static;
    class function CurrentTime: TDateTime; static;
    class function Now: TDateTime; static;
    class function Yesterday: TDateTime; static;
    class function Today: TDateTime; static;
    class function Tomorrow: TDateTime; static;

    property Date: TDateTime read GetDate;
    property Time: TDateTime read GetTime;

    property Year: Word read GetYear write SetYear;
    property MonthName: TMonthName read GetMonthName write SetMonthName;
    property Month: Word read GetMonth write SetMonth;
    property Week: Word read GetWeek;
    property Day: Word read GetDay write SetDay;
    property DayOfWeekName: TDayOfWeek read GetDayOfWeekName;
    property DayOfWeek: Word read GetDayOfWeek;       //Domenica=1; Sabato=7
    property DayOfTheWeek: Word read GetDayOfTheWeek; //Lunedì=1; Domenica=7
    property Hour: Word read GetHour write SetHour;
    property Minute: Word read GetMinute write SetMinute;
    property Second: Word read GetSecond write SetSecond;
    property MilliSecond: Word read GetMilliSecond write SetMilliSecond;

    constructor Create(const aDateTime: TDateTime); overload;
    constructor Create(const aYear, aMonth, aDay, aHour, aMin, aSec, aMSec: Word); overload;

    function ToString(const ConvertMode: TDateTimeToStringConvertMode = cmDateTime): String; overload;
    function ToString(const AFormatSettings: TFormatSettings; const ConvertMode: TDateTimeToStringConvertMode = cmDateTime): String; overload;

    function ToFileName: String; overload;
    function ToFileName(const AFormatSettings: TFormatSettings): String; overload;

    function IsYesterday: Boolean;
    function IsToday: Boolean;
    function IsTomorrow: Boolean;
    function IsInLeapYear: Boolean;
    function IsAM: Boolean;
    function IsPM: Boolean;

    //I metodi ShiftXXX restituiscono un valore TDateTime incrementando o
    //decrementando le porzioni di data/ora di una quantità specificata, come
    //fanno le rispettive funzioni IncXXX.
    //Se il parametro UpdateSelf è true, che è il valore di default, viene anche
    //aggiornata la variabile sulla quale il metodo è stato chiamato.
    function ShiftYear(const aShift: Integer = 1; const UpdateSelf: Boolean = true): TDateTime;
    function ShiftMonth(const aShift: Integer = 1; const UpdateSelf: Boolean = true): TDateTime;
    function ShiftWeek(const aShift: Integer = 1; const UpdateSelf: Boolean = true): TDateTime;
    function ShiftDay(const aShift: Integer = 1; const UpdateSelf: Boolean = true): TDateTime;
    function ShiftHour(const aShift: Int64 = 1; const UpdateSelf: Boolean = true): TDateTime;
    function ShiftMinute(const aShift: Int64 = 1; const UpdateSelf: Boolean = true): TDateTime;
    function ShiftSecond(const aShift: Int64 = 1; const UpdateSelf: Boolean = true): TDateTime;
    function ShiftMillisecond(const aShift: Int64 = 1; const UpdateSelf: Boolean = true): TDateTime;
  end;

  //Due Record Helper per i mesi e i giorni della settimana
  TMonthNameHelper = record helper for TMonthName
    function ToString(const Lower: Boolean = true): String;
  end;

  TDayOfWeekHelper = record helper for TDayOfWeek
    function ToString(const Lower: Boolean = true): String;
  end;

implementation

const
  MONTH_STR: array[TMonthName] of String = ('Sconosciuto','Gennaio', 'Febbraio',
    'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre',
    'Ottobre', 'Novembre', 'Dicembre');

  DAY_OF_WEEK_STR: array[TDayOfWeek] of String = ('Sconosciuto', 'Domenica',
    'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato');

{ TDateTimeHelper }

constructor TDateTimeHelper.Create(const aDateTime: TDateTime);
begin
  Self:=aDateTime;
end;

constructor TDateTimeHelper.Create(const aYear, aMonth, aDay, aHour, aMin, aSec,
  aMSec: Word);
begin
  if aYear<>0 then
    Self:=System.DateUtils.EncodeDateTime(aYear,aMonth,aDay,aHour,aMin,aSec,aMSec)
  else
    Self:=System.SysUtils.EncodeTime(aHour,aMin,aSec,aMSec)
end;

function TDateTimeHelper.ToString(const ConvertMode: TDateTimeToStringConvertMode): String;
begin
  case ConvertMode of
    cmDateTime: Result:=DateTimeToStr(Self);
    cmOnlyDate: Result:=DateToStr(Self);
    cmOnlyTime: Result:=TimeToStr(Self);
  end
end;

function TDateTimeHelper.ToFileName: String;
begin
  Result:=Self.ToString;
  Result:=StringReplace(Result,FormatSettings.DateSeparator,'',[rfReplaceAll]);
  Result:=StringReplace(Result,FormatSettings.TimeSeparator,'',[rfReplaceAll]);
  Result:=StringReplace(Result,' ','_',[rfReplaceAll]);
end;

class function TDateTimeHelper.CurrentDate: TDateTime;
begin
  Result:=System.SysUtils.Date;
end;

function TDateTimeHelper.IsAM: Boolean;
begin
  Result:=System.DateUtils.IsAM(Self)
end;

function TDateTimeHelper.IsInLeapYear: Boolean;
begin
  Result:=System.DateUtils.IsInLeapYear(Self)
end;

function TDateTimeHelper.IsPM: Boolean;
begin
  Result:=System.DateUtils.IsPM(Self)
end;

function TDateTimeHelper.IsToday: Boolean;
begin
  Result:=System.DateUtils.IsToday(Self)
end;

function TDateTimeHelper.IsTomorrow: Boolean;
begin
  Result:=Self.Date=TDateTime.Tomorrow;
end;

function TDateTimeHelper.IsYesterday: Boolean;
begin
  Result:=Self.Date=TDateTime.Yesterday;
end;

class function TDateTimeHelper.Now: TDateTime;
begin
  Result:=System.SysUtils.Now;
end;

procedure TDateTimeHelper.SetDay(const aValue: Word);
begin
  if aValue<>Self.Day then
    Self:=System.DateUtils.RecodeDay(Self,aValue)
end;

procedure TDateTimeHelper.SetHour(const aValue: Word);
begin
  if aValue<>Self.Hour then
    Self:=System.DateUtils.RecodeHour(Self,aValue)
end;

procedure TDateTimeHelper.SetMillisecond(const aValue: Word);
begin
  if aValue<>Self.MilliSecond then
    Self:=System.DateUtils.RecodeMillisecond(Self,aValue)
end;

procedure TDateTimeHelper.SetMinute(const aValue: Word);
begin
  if aValue<>Self.Minute then
    Self:=System.DateUtils.RecodeMinute(Self,aValue)
end;

procedure TDateTimeHelper.SetMonth(const aValue: Word);
begin
  if aValue<>Self.Month then
    Self:=System.DateUtils.RecodeMonth(Self,aValue)
end;

procedure TDateTimeHelper.SetMonthName(const aValue: TMonthName);
begin
  SetMonth(Ord(aValue))
end;

procedure TDateTimeHelper.SetSecond(const aValue: Word);
begin
  if aValue<>Self.Second then
    Self:=System.DateUtils.RecodeSecond(Self,aValue)
end;

procedure TDateTimeHelper.SetYear(const aValue: Word);
begin
  if aValue<>Self.Year then
    Self:=System.DateUtils.RecodeYear(Self,aValue)
end;

function TDateTimeHelper.ShiftDay(const aShift: Integer;
  const UpdateSelf: Boolean): TDateTime;
begin
  Result:=System.DateUtils.IncDay(Self,aShift);
  if UpdateSelf then
    Self:=Result
end;

function TDateTimeHelper.ShiftHour(const aShift: Int64;
  const UpdateSelf: Boolean): TDateTime;
begin
  Result:=System.DateUtils.IncHour(Self,aShift);
  if UpdateSelf then
    Self:=Result
end;

function TDateTimeHelper.ShiftMillisecond(const aShift: Int64;
  const UpdateSelf: Boolean): TDateTime;
begin
  Result:=System.DateUtils.IncMillisecond(Self,aShift);
  if UpdateSelf then
    Self:=Result
end;

function TDateTimeHelper.ShiftMinute(const aShift: Int64;
  const UpdateSelf: Boolean): TDateTime;
begin
  Result:=System.DateUtils.IncMinute(Self,aShift);
  if UpdateSelf then
    Self:=Result
end;

function TDateTimeHelper.ShiftMonth(const aShift: Integer;
  const UpdateSelf: Boolean): TDateTime;
begin
  Result:=System.SysUtils.IncMonth(Self,aShift);
  if UpdateSelf then
    Self:=Result
end;

function TDateTimeHelper.ShiftSecond(const aShift: Int64;
  const UpdateSelf: Boolean): TDateTime;
begin
  Result:=System.DateUtils.IncSecond(Self,aShift);
  if UpdateSelf then
    Self:=Result
end;

function TDateTimeHelper.ShiftWeek(const aShift: Integer;
  const UpdateSelf: Boolean): TDateTime;
begin
  Result:=System.DateUtils.IncWeek(Self,aShift);
  if UpdateSelf then
    Self:=Result
end;

function TDateTimeHelper.ShiftYear(const aShift: Integer;
  const UpdateSelf: Boolean): TDateTime;
begin
  Result:=System.DateUtils.IncYear(Self,aShift);
  if UpdateSelf then
    Self:=Result
end;

class function TDateTimeHelper.CurrentTime: TDateTime;
begin
  Result:=System.SysUtils.GetTime;
end;

function TDateTimeHelper.GetDate: TDateTime;
begin
  Result:=System.DateUtils.DateOf(Self);
end;

function TDateTimeHelper.GetDay: Word;
begin
  Result:=System.DateUtils.DayOf(Self)
end;

function TDateTimeHelper.GetDayOfTheWeek: Word;
begin
  Result:=System.DateUtils.DayOfTheWeek(Self)
end;

function TDateTimeHelper.GetDayOfWeek: Word;
begin
  Result:=System.SysUtils.DayOfWeek(Self)
end;

function TDateTimeHelper.GetDayOfWeekName: TDayOfWeek;
begin
  Result:=TDayOfWeek(GetDayOfWeek)
end;

function TDateTimeHelper.GetHour: Word;
begin
  Result:=System.DateUtils.HourOf(Self)
end;

function TDateTimeHelper.GetMilliSecond: Word;
begin
  Result:=System.DateUtils.MilliSecondOf(Self)
end;

function TDateTimeHelper.GetMinute: Word;
begin
  Result:=System.DateUtils.MinuteOf(Self)
end;

function TDateTimeHelper.GetMonth: Word;
begin
  Result:=System.DateUtils.MonthOf(Self)
end;

function TDateTimeHelper.GetMonthName: TMonthName;
begin
  Result:=TMonthName(GetMonth)
end;

function TDateTimeHelper.GetSecond: Word;
begin
  Result:=System.DateUtils.SecondOf(Self)
end;

function TDateTimeHelper.GetTime: TDateTime;
begin
  Result:=System.DateUtils.TimeOf(Self);
end;

function TDateTimeHelper.GetWeek: Word;
begin
  Result:=System.DateUtils.WeekOf(Self)
end;

function TDateTimeHelper.GetYear: Word;
begin
  Result:=System.DateUtils.YearOf(Self)
end;

class function TDateTimeHelper.Today: TDateTime;
begin
  Result:=System.DateUtils.Today
end;

function TDateTimeHelper.ToFileName(const AFormatSettings: TFormatSettings): String;
begin
  Result:=Self.ToString(AFormatSettings);
  Result:=StringReplace(Result,AFormatSettings.DateSeparator,'',[rfReplaceAll]);
  Result:=StringReplace(Result,AFormatSettings.TimeSeparator,'',[rfReplaceAll]);
  Result:=StringReplace(Result,' ','_',[rfReplaceAll]);
end;

class function TDateTimeHelper.Tomorrow: TDateTime;
begin
  Result:=System.DateUtils.Tomorrow
end;

function TDateTimeHelper.ToString(const AFormatSettings: TFormatSettings;
  const ConvertMode: TDateTimeToStringConvertMode): String;
begin
  case ConvertMode of
    cmDateTime: Result:=DateTimeToStr(Self,AFormatSettings);
    cmOnlyDate: Result:=DateToStr(Self,AFormatSettings);
    cmOnlyTime: Result:=TimeToStr(Self,AFormatSettings);
  end;
end;

class function TDateTimeHelper.Yesterday: TDateTime;
begin
  Result:=System.DateUtils.Yesterday
end;

{ TMonthNameHelper }

function TMonthNameHelper.ToString(const Lower: Boolean): String;
begin
  Result:=MONTH_STR[Self];
  if Lower then
    Result:=Result.ToLower
end;

{ TDayOfWeekHelper }

function TDayOfWeekHelper.ToString(const Lower: Boolean): String;
begin
  Result:=DAY_OF_WEEK_STR[Self];
  if Lower then
    Result:=Result.ToLower
end;

end.
