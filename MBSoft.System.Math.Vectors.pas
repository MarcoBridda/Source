unit MBSoft.System.Math.Vectors;
//******************************************************************************
//Aggiunte alla Unit System.Math.Vectors
//
//Copyright MBSoft(2024)
//******************************************************************************

interface

uses
  System.Types,
  System.Math.Vectors,
  System.Generics.Collections,
  MBSoft.System;

type
  //Un record helper per il tipo TPolygon per aggiungere e togliere punti
  TPolygonHelper = record helper for TPolygon
    //Pulisce l'array eliminado tutti i punti
    procedure Clear;

    //Aggiunge un punto alla fine del poligono solo se non è uguale al precedente
    procedure Add(const Point: TPointF);

    //Chiude la polilinea aggiungendo un punto alla fine, coincidente con il primo
    procedure Close;

    //Vera se la variabile non contiene elementi
    function IsEmpty: Boolean;

    //Vera se la variabile contiene almeno 2 elementi (almeno una linea)
    function IsPolyline: Boolean;

    //Vera se la polilinea è chiusa (l'ultimo punto coincide con il primo)
    function IsClosed: Boolean;

    //Vera se la polilinea è aperta
    function IsOpened: Boolean;

    //Vera se questa polilinea è uguale a quella passata come argomento
    function IsEqual(aPolygon: TPolygon): Boolean;
  end;

  TPolygonList = class(TList<TPolygon>)
  public
    function Add(const Value: TPolygon): Integer;
  end;

const
  LIB_VERSION: TProductFileVersion = (Major: 1; Minor: 2; Build: 0; Release: 0);

implementation

{ TPolygonHelper }

procedure TPolygonHelper.Add(const Point: TPointF);
begin
  if IsEmpty or IsOpened and (Self[High(Self)]<>Point) then
    Self:=Self+[Point]
  else if IsClosed and (Self[High(Self)-1]<>Point) then
  begin
    Self[High(Self)]:=Point;
    Close
  end;
end;

procedure TPolygonHelper.Clear;
begin
  SetLength(Self,0);
end;

procedure TPolygonHelper.Close;
begin
  if IsOpened then
    Add(Self[low(Self)])
end;

function TPolygonHelper.IsClosed: Boolean;
begin
  if Length(Self) in [0..2] then
    Result:=false
  else
    Result:=(Self[Low(Self)] = Self[High(Self)])
end;

function TPolygonHelper.IsEmpty: Boolean;
begin
  Result:=Length(Self)=0
end;

function TPolygonHelper.IsEqual(aPolygon: TPolygon): Boolean;
var
  I: Integer;
begin
  Result:=Length(Self)=Length(aPolygon);

  I:=Low(Self);
  while Result and (I<=High(Self)) do
  begin
    Result:=Self[I] = aPolygon[I];
    Inc(I)
  end;
end;

function TPolygonHelper.IsOpened: Boolean;
begin
  case Length(Self) of
    0: Result:=false;
    1,
    2: Result:=true;
  else
    Result:=Self[Low(Self)] <> Self[High(Self)]
  end;
end;

function TPolygonHelper.IsPolyline: Boolean;
begin
  Result:=Length(Self)>=2;
end;

{ TPolygonList }

function TPolygonList.Add(const Value: TPolygon): Integer;
begin
  if Count>0 then
    for var Poly: TPolygon in Self do
      if Poly.IsEqual(Value) then
        Exit(Count-1);

  Result:=inherited Add(Value)
end;

end.
