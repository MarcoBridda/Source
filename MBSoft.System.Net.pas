unit MBSoft.System.Net;
//****************************************************************************
//Unità di supporto per internet
//
//Copyright MBSoft (2024)
//****************************************************************************

interface

uses
  System.SysUtils;

type
  //Un indirizzo IP versione 4 bytes
  TIPv4 = record
  private
    FValue: Cardinal;
  public
    class operator Implicit(const Value: string): TIPv4;
    class operator Implicit(Value: TIPv4): string;

    procedure FromString(const Value: string);
    function ToString: string;
  end;

implementation

{ TIPv4 }

procedure TIPv4.FromString(const Value: string);
var
  Part: TArray<string>;
  I: Cardinal;
  B: Byte;
begin
  Part:=Value.Split(['.']);
  FValue:=0;
  for I:=0 to 3 do
  begin
    FValue:=(FValue shl $8);
    if (I<=High(Part)) and(Byte.TryParse(Part[I], B)) then
      Inc(FValue,B);
  end;
end;

class operator TIPv4.Implicit(Value: TIPv4): string;
begin
  Result:=Value.ToString;
end;

class operator TIPv4.Implicit(const Value: string): TIPv4;
begin
  Result.FromString(Value)
end;

function TIPv4.ToString: string;
var
  A, I: Cardinal;
  S: array[0..3] of string;
begin
  A:=FValue;

  for I:=0 to 3 do
  begin;
    S[3-I]:=(A and $FF).ToString;
    A:=A shr $8;
  end;

  Result:=string.Join('.',S)
end;

end.
