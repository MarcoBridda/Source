unit MBSoft.Graphics;
//*****************************************************************************
//Unità di supporto per il disegno e la conversione di coordinate tra sistemi
//di riferimento Cartesiani e Polari.
//Sviluppato con Delpi 10.2 (Tokyo) (mica bruscolini...)
//
//Copyright MBSoft (2017-2019)
//*****************************************************************************

interface

uses
 System.SysUtils, System.Types;

type
  //Errori
  EMBSoftGraphicsException = class(Exception);

  //Sistemi di riferimento
  TCoordSystem = (csDefault, csCartesian, csPolar);

  //Unità di misura angolari
  TAngleUnit = (auDefault, auDegrees, auRadians, auGrads);

  //Intervallo angolare:
  TAngleRange = (arDefault, arPositive, arSimmetric);

const
  //Valori di default
  DEFAULT_COORD_SYSTEM = csCartesian;   //Coordinate Cartesiane
  DEFAULT_ANGLE_UNIT   = auDegrees;     //Angoli in gradi sessagegimali
  DEFAULT_ANGLE_RANGE  = arPositive;    //Angoli sempre positivi

  //Campi di valori angolari in base a TAngleUnit e TAngleRange:
//|-------------------------------------------------------------|
//|            | arSimmetric | arPositive | Descrizione         |
//|------------|------------------------------------------------|
//| auDegrees  |  -180..180  |   0..360   | Gradi sessagesimali |
//| auRadians  |   -Pi..+Pi  |   0..2*Pi  | Radianti            |
//| auGrads    |  -200..200  |   0..400   | Gradi centesimali   |
//|-------------------------------------------------------------|

type
//RecordHelper per TCoordSystem, TAngleUnit, TAngleRange
//Il metodo ToString restituisce la descrizione testuale del valore
//Il metodo Value restituisce il valore corrente, ma converte il valore di
//default. Per esempio:
//-----------------------------------------------------------------------
//var
//  cs: TCoordSystem;
//begin
//  cs:=csDefault;
//-----------------------------------------------------------------------
//A questo punto la variabile cs vale csDefault, mentre cs.Value restituisce
//csCartesian.
//Questo vale anche per il metodo ToString che, in questo caso, non restituisce
//'Default', ma la stringa corrispondente al valore di default, 'Cartesiano'
  TCoordSystemHelper = record helper for TCoordSystem
    function ToString: String;
    function Value: TCoordSystem;
  end;

  TAngleUnitHelper = record helper for TAngleUnit
    function ToString: String;
    function Value: TAngleUnit;
  end;

  TAngleRangeHelper = record helper for TAngleRange
    function ToString: String;
    function Value: TAngleRange;
  end;

//Impostazioni Globali
  TGraphicSettings = record
    CoordSystem: TCoordSystem;
    AngleUnit: TAngleUnit;
    AngleRange: TAngleRange;

    class function Create: TGraphicSettings; overload; static;
    class function Create(CS: TCoordSystem; AU: TAngleUnit; AR: TAngleRange): TGraphicSettings; overload; static;
  end;

  //Gestione di angoli
  TAngle = record
  private
    FOriginalUnit: TAngleUnit;
    FRange: TAngleRange;
    FValue: Single;

    procedure Init(const AValue: Single; AUnit: TAngleUnit; ARange: TAngleRange);
    procedure AngleInRange;

    class function Normalize(A: TAngle): TAngle; overload; static;
    class function Normalize(A: TAngle; var B: Tangle): TAngle; overload; static;

    procedure SetOriginalUnit(AValue: TAngleUnit);
    procedure SetRange(AValue: TAngleRange);

    function GetDeg: Single;
    function GetRad: Single;
    function GetGrad: Single;
    procedure SetDeg(AValue: Single);
    procedure SetRad(AValue: Single);
    procedure SetGrad(AValue: Single);
  public
    constructor Create(const AUnit: TAngleUnit; const ARange: TAngleRange = arPositive); overload;
    constructor Create(const AValue: Single; const ARange: TAngleRange = arPositive); overload;
    constructor Create(const AValue: Single; AUnit: TAngleUnit; const ARange: TAngleRange = arPositive); overload;

    property OriginalUnit: TAngleUnit read FOriginalUnit write SetOriginalUnit;
    property Range: TAngleRange read FRange write SetRange;

    property Deg: Single read GetDeg write SetDeg;
    property Rad: Single read GetRad write SetRad;
    property Grad: Single read GetGrad write SetGrad;

    //Overload degli Operatori
    //Operazioni aritmetiche
    class operator Add(A, B: TAngle): TAngle;
    class operator Subtract(A, B: TAngle): TAngle;
    class operator Multiply(A: TAngle; B: Single): TAngle;
    class operator Multiply(A: Single; B: TAngle): TAngle;
    class operator Divide(A: TAngle; B: Single): TAngle;
    //Confronti
    class operator Equal(A, B: TAngle): Boolean;
    class operator NotEqual(A, B: TAngle): Boolean;
    class operator GreaterThan(A, B: TAngle): Boolean;
    class operator GreaterThanOrEqual(A, B: TAngle): Boolean;
    class operator LessThan(A, B: TAngle): Boolean;
    class operator LessThanOrEqual(A, B: TAngle): Boolean;
  end;

  //Un punto a 3 dimensioni con le coordinate in virgola mobile
  T3DPoint = record
    X: Single;
    Y: Single;
    Z: Single;
    constructor Create(const aX, aY, aZ: Single); overload;
    constructor Create(const Point: T3DPoint); overload;
    constructor Create(const Point, Origin: TPoint; Zoom: Single); overload;
    constructor Create(const Point: TPoint; oX, oY: Integer; Zoom: Single); overload;
    constructor Create(const aX, aY: Integer; Origin: TPoint; Zoom: Single); overload;
    constructor Create(const aX, aY, oX, oY: Integer; Zoom: Single); overload;

    function ToScreenX(const Origin: TPoint; Zoom: Single): Integer; overload;
    function ToScreenX(const Ox: Integer; Zoom: Single): Integer; overload;

    function ToScreenY(const Origin: TPoint; Zoom: Single): Integer; overload;
    function ToScreenY(const Oy: Integer; Zoom: Single): Integer; overload;

    function ToScreenPoint(const Origin: TPoint; Zoom: Single): TPoint; overload;
    function ToScreenPoint(const Ox, Oy: Integer; Zoom: Single): TPoint; overload;

    function ToString(const Precision, Digits: Integer; const Settings: TFormatSettings): String;

    function IsEqual(const Point: T3DPoint): Boolean;
  end;


implementation

uses
  System.Math;

const
  //Messaggi di errore
  ANGLE_UNIT_NOT_VALID   = 'Unità di misura angolare non supportata.';
  ANGLE_RANGE_NOT_VALID  = 'Intervallo angolare non valido.';
  COORD_SYSTEM_NOT_VALID = 'Sistema di riferimento non valido.';

  //Valori testuali per i record helper. Il valore di default non viene usato
  //ma lo metto per completezza (non si sa mai...)
  COORD_SYSTEM_STRINGS: array[TCoordSystem] of String =
    ('Default', 'Cartesiane', 'Polari');
  ANGLE_UNIT_STRINGS: array[TAngleUnit] of String =
    ('Default', 'Gradi sessagesimali', 'Radianti', 'Gradi centesimali');
  ANGLE_RANGE_STRINGS: array[TAngleRange] of String =
    ('Default', 'Positivo','Simmetrico');

{ TCoordSystemHelper }
function TCoordSystemHelper.ToString: String;
begin
  Result:=COORD_SYSTEM_STRINGS[Self.Value]
end;

function TCoordSystemHelper.Value: TCoordSystem;
begin
  if Self = csDefault then
    Result:=DEFAULT_COORD_SYSTEM
  else
    Result:=Self
end;

{ TAngleUnitHelper }
function TAngleUnitHelper.ToString: String;
begin
  Result:=ANGLE_UNIT_STRINGS[Self.Value]
end;

function TAngleUnitHelper.Value: TAngleUnit;
begin
  if Self = auDefault then
    Result:=DEFAULT_ANGLE_UNIT
  else
    Result:=Self
end;

{ TAngleRangeHelper }
function TAngleRangeHelper.ToString: String;
begin
  Result:=ANGLE_RANGE_STRINGS[Self.Value]
end;

function TAngleRangeHelper.Value: TAngleRange;
begin
  if Self = arDefault then
    Result:=DEFAULT_ANGLE_RANGE
  else
    Result:=Self
end;

{ TGraphicSettings }
class function TGraphicSettings.Create: TGraphicSettings;
begin
  Result:=TGraphicSettings.Create(csDefault,auDefault,arDefault);
end;

class function TGraphicSettings.Create(CS: TCoordSystem; AU: TAngleUnit; AR: TAngleRange): TGraphicSettings;
begin
  Result.CoordSystem:=CS.Value;
  Result.AngleUnit:=AU.Value;
  Result.AngleRange:=AR.Value
end;

{ TAngle }
procedure TAngle.Init(const AValue: Single; AUnit: TAngleUnit; ARange: TAngleRange);
var
  GS: TGraphicSettings;
begin
  GS:=TGraphicSettings.Create(csDefault,AUnit,ARange);
  FOriginalUnit:=GS.AngleUnit;
  FRange:=GS.AngleRange;
  FVAlue:=AValue;
  AngleInRange
end;

procedure TAngle.AngleInRange;
var
  FullCycle: Single;
begin
  //Calcola un giro intero nell'unità di misura usata
  case OriginalUnit of
    auDegrees: FullCycle:=360;
    auRadians: FullCycle:=2*Pi;
    auGrads  : FullCycle:=400
  else
    raise EMBSoftGraphicsException.Create(ANGLE_UNIT_NOT_VALID);
  end;
  //Forza l'angolo all'interno di un unico giro
  FValue:=Frac(FValue/FullCycle)*FullCycle;
  //Forza l'angolo all'interno dell'intervallo di valori usato
  case Range of
    arPositive : if FValue<0 then
                   FValue:=FullCycle+FValue;
    arSimmetric: if (FValue>FullCycle/2) then
                   FValue:=FValue-FullCycle;
  else
    raise EMBSoftGraphicsException.Create(ANGLE_RANGE_NOT_VALID);
  end
end;

class function TAngle.Normalize(A: TAngle): TAngle;
var
  GS: TGraphicSettings;
begin
  GS:=TGraphicSettings.Create(csDefault,A.OriginalUnit,A.Range);
  Result.Create(GS.AngleUnit,GS.AngleRange)
end;

class function TAngle.Normalize(A: TAngle; var B: TAngle): TAngle;
begin
  Result:=Normalize(A);
  //Converti il secondo angolo nell'unità di misura del primo.
  B.OriginalUnit:=A.OriginalUnit
end;

constructor TAngle.Create(const AUnit: TAngleUnit; const ARange: TAngleRange);
begin
  Init(0,AUnit,ARange)
end;

constructor TAngle.Create(const AValue: Single; const ARange: TAngleRange);
begin
  Init(AValue,auDefault,ARange)
end;

constructor TAngle.Create(const AValue: Single; AUnit: TAngleUnit; const ARange: TAngleRange);
begin
  Init(AValue,AUnit,ARange)
end;

procedure TAngle.SetOriginalUnit(AValue: TAngleUnit);
var
  GS: TGraphicSettings;
begin
  GS:=TGraphicSettings.Create(csDefault,AValue,Range);
  if GS.AngleUnit<>OriginalUnit then
  begin
    case GS.AngleUnit of
      auDegrees: FValue:=GetDeg;
      auRadians: FValue:=GetRad;
      auGrads: FVAlue:=GetGrad
    else
      raise EMBSoftGraphicsException.Create(ANGLE_UNIT_NOT_VALID);
    end;
    FOriginalUnit:=GS.AngleUnit
  end
end;

procedure TAngle.SetRange(AValue: TAngleRange);
var
  GS: TGraphicSettings;
begin
  GS:=TGraphicSettings.Create(csDefault,OriginalUnit,AValue);
  if GS.AngleRange<>Range then
  begin
    FRange:=GS.AngleRange;
    AngleInRange
  end;
end;

procedure TAngle.SetDeg(AValue: Single);
begin
  case OriginalUnit of
    auDegrees: FValue:=AValue;
    auRadians: FValue:=DegToRad(AValue);
    auGrads: FValue:=DegToGrad(AValue)
  else
    raise EMBSoftGraphicsException.Create(ANGLE_UNIT_NOT_VALID);
  end;
  AngleInRange
end;

procedure TAngle.SetRad(AValue: Single);
begin
  case OriginalUnit of
    auDegrees: FValue:=RadToDeg(AValue);
    auRadians: FValue:=AValue;
    auGrads: FValue:=RadToGrad(AValue)
  else
    raise EMBSoftGraphicsException.Create(ANGLE_UNIT_NOT_VALID);
  end;
  AngleInRange
end;

procedure TAngle.SetGrad(AValue: Single);
begin
  case OriginalUnit of
    auDegrees: FValue:=GradToDeg(AValue);
    auRadians: FValue:=GradToRad(AValue);
    auGrads: FValue:=AValue
  else
    raise EMBSoftGraphicsException.Create(ANGLE_UNIT_NOT_VALID);
  end;
  AngleInRange
end;

function TAngle.GetDeg: Single;
begin
  case OriginalUnit of
    auDegrees: Result:=FValue;
    auRadians: Result:=RadToDeg(FValue);
    auGrads: Result:=GradToDeg(FValue)
  else
    raise EMBSoftGraphicsException.Create(ANGLE_UNIT_NOT_VALID);
  end;
end;

function TAngle.GetRad: Single;
begin
  case OriginalUnit of
    auDegrees: Result:=DegToRad(FValue);
    auRadians: Result:=FValue;
    auGrads: Result:=GradToRad(FValue)
  else
    raise EMBSoftGraphicsException.Create(ANGLE_UNIT_NOT_VALID);
  end;
end;

function TAngle.GetGrad: Single;
begin
  case OriginalUnit of
    auDegrees: Result:=DegToGrad(FValue);
    auRadians: Result:=RadToGrad(FValue);
    auGrads: Result:=FValue
  else
    raise EMBSoftGraphicsException.Create(ANGLE_UNIT_NOT_VALID);
  end;
end;

class operator TAngle.Add(A, B: TAngle): TAngle;
begin
  Result:=Normalize(A,B);
  //Fai la somma
  Result.FValue:=A.FValue+B.FValue;
  Result.AngleInRange;
end;

class operator TAngle.Subtract(A, B: TAngle): TAngle;
begin
  Result:=Normalize(A,B);
  //Fai la sottrazione
  Result.FValue:=A.FValue-B.FValue;
  Result.AngleInRange
end;

class operator TAngle.Multiply(A: TAngle; B: Single): TAngle;
begin
  Result:=Normalize(A);
  //Moltiplica Angolo per Fattore
  Result.FValue:=A.FValue*B;
  Result.AngleInRange
end;

class operator TAngle.Multiply(A: Single; B: TAngle): TAngle;
begin
  //Realizza la proprietà commutativa
  Result:=B*A
end;

class operator TAngle.Divide(A: TAngle; B: Single): TAngle;
begin
  Result:=Normalize(A);
  //Divide Angolo per Fattore
  Result.FValue:=A.FValue/B;
  Result.AngleInRange
end;

class operator TAngle.Equal(A: TAngle; B: TAngle): Boolean;
begin
  Normalize(A,B);
  Result:=(A.FValue=B.FValue)
end;

class operator TAngle.NotEqual(A: TAngle; B: TAngle): Boolean;
begin
  Result:=not(A=B)
end;

class operator TAngle.GreaterThan(A: TAngle; B: TAngle): Boolean;
begin
  Normalize(A,B);
  Result:=(A.FValue>B.FValue)
end;

class operator TAngle.GreaterThanOrEqual(A: TAngle; B: TAngle): Boolean;
begin
  Result:=(A>B) or (A=B)
end;

class operator TAngle.LessThan(A: TAngle; B: TAngle): Boolean;
begin
  Normalize(A,B);
  Result:=(A.FValue<B.FValue)
end;

class operator TAngle.LessThanOrEqual(A: TAngle; B: TAngle): Boolean;
begin
  Result:=(A<B) or (A=B)
end;

{ T3DPoint }

constructor T3DPoint.Create(const aX, aY, aZ: Single);
begin
  X:=aX;
  Y:=aY;
  Z:=aZ;
end;

constructor T3DPoint.Create(const Point: T3DPoint);
begin
  Create(Point.X,Point.Y,Point.Z)
end;

constructor T3DPoint.Create(const Point: TPoint; oX, oY: Integer; Zoom: Single);
begin
  Create(Point.X,Point.Y,oX,oY,Zoom)
end;

constructor T3DPoint.Create(const Point, Origin: TPoint; Zoom: Single);
begin
  Create(Point.X,Point.Y,Origin.X,Origin.Y,Zoom)
end;

constructor T3DPoint.Create(const aX, aY, oX, oY: Integer; Zoom: Single);
begin
  X:=(aX-oX)/Zoom;
  Y:=(oY-aY)/Zoom;
  Z:=0
end;

constructor T3DPoint.Create(const aX, aY: Integer; Origin: TPoint;
  Zoom: Single);
begin
  Create(aX,aY,Origin.X,Origin.Y,Zoom)
end;

function T3DPoint.IsEqual(const Point: T3DPoint): Boolean;
begin
  Result:=(X=Point.X) and (Y=Point.Y) and (Z=Point.Z)
end;

function T3DPoint.ToScreenPoint(const Ox, Oy: Integer; Zoom: Single): TPoint;
begin
  Result.X:=Self.ToScreenX(Ox,Zoom);
  Result.Y:=Self.ToScreenY(Oy,Zoom)
end;

function T3DPoint.ToScreenPoint(const Origin: TPoint; Zoom: Single): TPoint;
begin
  Result.X:=Self.ToScreenX(Origin,Zoom);
  Result.Y:=Self.ToScreenY(Origin,Zoom)
end;

function T3DPoint.ToScreenX(const Origin: TPoint; Zoom: Single): Integer;
begin
  Result:=Origin.X+Round(Self.X*Zoom);
end;

function T3DPoint.ToScreenX(const Ox: Integer; Zoom: Single): Integer;
begin
  Result:=Ox+Round(Self.X*Zoom);
end;

function T3DPoint.ToScreenY(const Origin: TPoint; Zoom: Single): Integer;
begin
  Result:=Origin.Y-Round(Self.Y*Zoom)
end;

function T3DPoint.ToScreenY(const Oy: Integer; Zoom: Single): Integer;
begin
  Result:=Oy-Round(Self.Y*Zoom)
end;

function T3DPoint.ToString(const Precision, Digits: Integer;
  const Settings: TFormatSettings): String;
begin
  Result:=X.ToString(ffFixed,Precision,Digits,Settings)+';'+
    Y.ToString(ffFixed,Precision,Digits,Settings)+';'+
    Z.ToString(ffFixed,Precision,Digits,Settings)
end;

end.

