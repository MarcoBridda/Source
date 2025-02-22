unit MBSoft.System;
//******************************************************************************
//Aggiunte alla Unit System
//
//Copyright MBSoft(2020-2024)
//******************************************************************************

interface

uses
  System.Math, System.SysUtils, System.Types, System.SyncObjs;

type
  //Eccezioni
  EMBSoftSystem = class(Exception);
  EMBCommandLine = class(EMBSoftSystem);

  //Origine dei parametri della riga di comando. Vedi piu sotto il record
  //TMBCommandLine e ,nella unit MBSoft.Vcl.Forms, L'helper TMBVclAppHelper
  TMBCmdArgumentsMode = (amCommandLine, amLoaded);

  //Una struttura per gestire meglio i parametri passati sulla linea di comando
  //Per uniformarmi alla nomenclatura di Windows Terminal e di altre app CLI
  //che possono essere invocate con dei sottocomandi che hanno i loro parametri
  //ho deciso di rinominare i parametri della riga di comando in "argomenti"
  TMBCmdLine = record
  private const
    //Estensione per il file con la lista dei parametri
    //(vedi TMBCommandLine.SaveToFile)
    ARGUMENT_LIST_EXTENSION = '.ale';
  private
    //Lista dei parametri, quando viene caricata da un file. Questa aggiunta �
    //stata fatta per supportare il passaggio dei parametri quando si implementa
    //il pattern Singleton. In questo caso, la seconda istanza dell'applicazione
    //salva i suoi parametri in un file temporaneo, con SaveToFile, e poi la
    //prima istanza li legge con LoadFromFile
    class var FArgumentsList: TStringDynArray;
    class var FArgumentsMode: TMBCmdArgumentsMode;

    class constructor Create;
    //Getter/Setter per le propriet�
    class function GetCount: Integer; static;
    class function GetArgument(Index: Integer): String; static;
    class function GetHasArguments: Boolean; static;
    class function GetArgumentsMode: TMBCmdArgumentsMode; static;
    class procedure SetArgumentsMode(Value: TMBCmdArgumentsMode); static;
    //Utilit�
    class function GetArgumentsPath(FileName: TFileName): TFileName; static;
  public
    class procedure SaveToFile(FileName: TFileName); static;
    class procedure LoadFromFile(FileName: TFileName); static;

    class function ToArray(aStart: Integer = 0): TStringDynArray;
      overload; static;
    class function ToArray(aStart, aLength: Integer): TStringDynArray;
      overload; static;

    class property Count: Integer read GetCount;
    class property Argument[Index: Integer]: String read GetArgument;
    class property HasArguments: Boolean read GetHasArguments;
    class property ArgumentsMode: TMBCmdArgumentsMode read GetArgumentsMode
      write SetArgumentsMode;
  end;

  //Un oggetto per implementare la gestione dei numeri pseudocasuali.
  //Ogni oggetto creato contiene un seme privato che usa per generare la propria
  //sequenza caricandolo nella variabile globale RandSeed e aggiornandolo ogni
  //volta.
  //Se nel costruttore si fornisce un oggetto TCriticalSection, l'oggetto TRandom
  //creato � thread-safe (o almeno spero...)
  TRandom = class(TObject)
  private
    FLocalSeed: Integer;
    FLock: TCriticalSection;
  protected
    procedure SwapSeed;
    procedure TryAcquire;
    procedure TryRelease;
  public
    constructor Create; overload;
    constructor Create(ALock: TCriticalSection); overload;
    constructor Create(const ASeed: LongInt; ALock: TCriticalSection); overload;
    function Randomize: Integer;
    function Random: Double; overload;
    function Random(const Range: Integer): Integer; overload;

    property RandSeed: Integer read FLocalSeed write FLocalSeed;
  end;

  //****************************************************************************
  //Supporto per le info di versione di un eseguibile
  //Per info vedere la unit Winapi.Windows e la unit MBSoft.Winapi.Windows
  //****************************************************************************

  //La versione come array
  TVersionArray = array[0..3] of Word;

  //Una struttura per la versione
  TProductFileVersion = record
  private
    class function CompareVersion(A, B: TProductFileVersion):
      TValueSign; static;
  public
    constructor Create(const VersionMS,VersionLS: DWORD); overload;
    constructor Create(const VersionString: String); overload;

    function ToString: String;

    class operator Equal(A, B: TProductFileVersion): Boolean;
    class operator NotEqual(A, B: TProductFileVersion): Boolean;
    class operator GreaterThan(A, B: TProductFileVersion): Boolean;
    class operator GreaterThanOrEqual(A, B: TProductFileVersion): Boolean;
    class operator LessThan(A, B: TProductFileVersion): Boolean;
    class operator LessThanOrEqual(A, B: TProductFileVersion): Boolean;
    class operator Implicit(Version: String): TProductFileVersion;
    class operator Implicit(Version: TProductFileVersion): String;

    case Integer of
      0: (Major, Minor, Build, Release: Word);
      1: (Version: TVersionArray);
  end;

const
  LIB_VERSION: TProductFileVersion = (Major: 1; Minor: 2; Build: 0; Release: 0);

implementation

uses
  System.Classes, System.IOUtils,
  MBSoft.System.IOUtils;

const
  //Eccezioni
  INVALID_ARGUMENTSMODE = 'ArgumentsMode non valido';

{ TMBCommandLine }

class constructor TMBCmdLine.Create;
begin
  //Inizializza i campi statici
  FArgumentsList:=nil;
  FArgumentsMode:=amCommandLine
end;

class function TMBCmdLine.GetCount: Integer;
begin
  case ArgumentsMode of
    amCommandLine: Result:=ParamCount;
    amLoaded: Result:=Length(FArgumentsList)
  else
    raise EMBCommandLine.Create(INVALID_ARGUMENTSMODE);
  end;
end;

class function TMBCmdLine.GetHasArguments: Boolean;
begin
  Result:=GetCount>0
end;

class function TMBCmdLine.GetArgument(Index: Integer): String;
begin
  if Index=0 then
  Result:=ParamStr(0)
  else
    case ArgumentsMode of
      amCommandLine: Result:=ParamStr(Index);
      amLoaded: Result:=FArgumentsList[Index-1]
    else
      raise EMBCommandLine.Create(INVALID_ARGUMENTSMODE);
    end;
end;

class function TMBCmdLine.GetArgumentsMode: TMBCmdArgumentsMode;
begin
  Result:=FArgumentsMode
end;

class function TMBCmdLine.GetArgumentsPath(FileName: TFileName): TFileName;
var
  TempDir: TFileName;
begin
  TempDir:=GetEnvironmentVariable('TEMP');
  Result:=TPath.Combine(TempDir,FileName.Name);
  Result:=FileName.ChangeExt(ARGUMENT_LIST_EXTENSION)
end;

class procedure TMBCmdLine.LoadFromFile(FileName: TFileName);
var
  I: Integer;
  Arguments: TStringList;
begin
  FileName:=GetArgumentsPath(FileName);
  if FileName.Exists then
  begin
    Arguments:=TStringList.Create;
    try
      Arguments.LoadFromFile(FileName);
      if Arguments.Count>0 then
      begin
        SetLength(FArgumentsList,Arguments.Count);
        for I:=0 to Arguments.Count-1 do
          FArgumentsList[I]:=Arguments[I];
        ArgumentsMode:=amLoaded;
        System.SysUtils.DeleteFile(FileName)
      end;
    finally
      Arguments.Free
    end;
  end
  else
    ArgumentsMode:=amCommandLine
end;

class procedure TMBCmdLine.SaveToFile(FileName: TFileName);
var
  I: Integer;
  Arguments: TStringList;
begin
  if Count>0 then
  begin
    Arguments:=TStringList.Create;
    try
      for I:=1 to Count do
        Arguments.Add(Argument[I]);
      Arguments.SaveToFile(GetArgumentsPath(FileName))
    finally
      Arguments.Free
    end
  end
end;

class procedure TMBCmdLine.SetArgumentsMode(Value: TMBCmdArgumentsMode);
begin
  FArgumentsMode:=Value
end;

class function TMBCmdLine.ToArray(aStart, aLength: Integer): TStringDynArray;
var
  Index: Integer;
begin
  //Correggiamo se gli argomenti passati non sono conformi
  if aStart<0 then
    aStart:=0;

  if (aLength<1) or (aStart+aLength>Count+1) then
    aLength:=Count+1-aStart;

  //Ora facciamo l'array
  SetLength(Result,aLength);
  for Index:=aStart to aStart+aLength-1 do
    Result[Index-aStart]:=Argument[Index]
end;

class function TMBCmdLine.ToArray(aStart: Integer): TStringDynArray;
begin
  Result:=ToArray(aStart,-1); //Lunghezza non valida cos� si sistema da solo
end;

{ TRandom }

constructor TRandom.Create;
begin
  FLock:=nil;
  Randomize
end;

constructor TRandom.Create(ALock: TCriticalSection);
begin
  FLock:=ALock;
  Randomize
end;

constructor TRandom.Create(const ASeed: Integer; ALock: TCriticalSection);
begin
  FLocalSeed:=ASeed;
  FLock:=ALock
end;

procedure TRandom.TryAcquire;
begin
  if Assigned(FLock) then
    FLock.Acquire
end;

procedure TRandom.TryRelease;
begin
  if Assigned(FLock) then
    FLock.Release
end;

function TRandom.Random: Double;
begin
  TryAcquire;
  try
    SwapSeed;
    Result:=System.Random;
    SwapSeed
  finally
    TryRelease
  end;
end;

function TRandom.Random(const Range: Integer): Integer;
begin
  TryAcquire;
  try
    SwapSeed;
    Result:=System.Random(Range);
    SwapSeed
  finally
    TryRelease
  end;
end;

function TRandom.Randomize: Integer;
begin
  TryAcquire;
  try
    SwapSeed;
    System.Randomize;
    SwapSeed;
    Result:=FLocalSeed
  finally
    TryRelease
  end;
end;

procedure TRandom.SwapSeed;
var
  Temp: Integer;
begin
  Temp:=System.RandSeed;
  System.RandSeed:=FLocalSeed;
  FLocalSeed:=Temp
end;

{ TProductFileVersion }

class function TProductFileVersion.CompareVersion(A,
  B: TProductFileVersion): TValueSign;
var
  I: Integer;
begin
  I:=0;      //Parto dall'indice pi� basso
  Result:=0; //Presumo che siano uguali, poi confronto

  //Confronta i numeri di versione partendo dal pi� significativo (la Major)
  //finch� non ne trovi uno diverso
  while (I<=High(TVersionArray)) and (Result=0) do
  begin
    Result:=Sign(A.Version[I]-B.Version[I]);
    Inc(I)
  end
end;

 constructor TProductFileVersion.Create(const VersionMS, VersionLS: DWORD);
begin
  Self.Major  := VersionMS shr $10;
  Self.Minor  := VersionMS and $FFFF;
  Self.Build  := VersionLS shr $10;
  Self.Release:= VersionLS and $FFF
end;

constructor TProductFileVersion.Create(const VersionString: String);
var
  VSplit: TStringDynArray;
  I: Integer;
begin
  try
    VSplit:=VersionString.Split(['.']);
    if Length(VSplit)=4 then
      for I:=0 to 3 do
        Self.Version[I]:=VSplit[I].ToInteger
  except
    Create('0.0.0.0')
  end;
end;

class operator TProductFileVersion.Equal(A, B: TProductFileVersion): Boolean;
begin
  Result:=CompareVersion(A,B)=ZeroValue
end;

class operator TProductFileVersion.GreaterThan(A,
  B: TProductFileVersion): Boolean;
begin
  Result:=CompareVersion(A,B)=PositiveValue
end;

class operator TProductFileVersion.GreaterThanOrEqual(A,
  B: TProductFileVersion): Boolean;
begin
  Result:=CompareVersion(A,B) in [ZeroValue,PositiveValue]
end;

class operator TProductFileVersion.Implicit(
  Version: TProductFileVersion): String;
begin
  Result:=Version.ToString
end;

class operator TProductFileVersion.Implicit(
  Version: String): TProductFileVersion;
begin
  Result:=TProductFileVersion.Create(Version)
end;

class operator TProductFileVersion.LessThan(A, B: TProductFileVersion): Boolean;
begin
  Result:=CompareVersion(A,B)=NegativeValue
end;

class operator TProductFileVersion.LessThanOrEqual(A,
  B: TProductFileVersion): Boolean;
begin
  Result:=not CompareVersion(A,B)=PositiveValue
end;

class operator TProductFileVersion.NotEqual(A, B: TProductFileVersion): Boolean;
begin
  Result:=Not CompareVersion(A,B)=ZeroValue
end;

function TProductFileVersion.ToString: String;
var
  I: Integer;
begin
  Result:=Self.Version[0].ToString;
  for I:=1 to 3 do
    Result:=Result+'.'+Self.Version[I].ToString
end;

end.
