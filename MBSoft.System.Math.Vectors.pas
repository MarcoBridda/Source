unit MBSoft.System.Math.Vectors;
//******************************************************************************
//Aggiunte alla Unit System.Math.Vectors
//
//Copyright MBSoft(2024)
//******************************************************************************

interface

uses
  System.Types,
  System.Math.Vectors;

type
  //Un record helper per il tipo TPolygon per aggiungere e togliere punti
  TPolygonHelper = record helper for TPolygon
    //Pulisce l'array eliminado tutti i punti
    procedure Clear;

    //Aggiunge un punto alla fine del poligono solo se non è uguale al precedente
    procedure Add(const Point: TPointF);

    //Vera se la variabile non contiene elementi
    function IsEmpty: Boolean;

    //Vera se la variabile contiene almeno 2 elementi (almeno una linea)
    function IsPolyline: Boolean;
  end;

implementation

{ TPolygonHelper }

procedure TPolygonHelper.Add(const Point: TPointF);
var
  MaxI: Integer;
begin
  MaxI:=High(Self);

  if (Length(Self)=0) or (Self[MaxI]<>Point) then
  begin
    Inc(MaxI);
    SetLength(Self,MaxI+1);
    Self[MaxI]:=Point
  end;

end;

procedure TPolygonHelper.Clear;
begin
  SetLength(Self,0);
end;

function TPolygonHelper.IsEmpty: Boolean;
begin
  Result:=Length(Self)=0
end;

function TPolygonHelper.IsPolyline: Boolean;
begin
  Result:=Length(Self)>=2;
end;

end.
