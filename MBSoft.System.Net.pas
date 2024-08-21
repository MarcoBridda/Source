unit MBSoft.System.Net;
//****************************************************************************
//Unità di supporto per internet
//
//Copyright MBSoft (2024)
//****************************************************************************

interface

uses
  System.SysUtils, MBSoft.System;

type
  //Un indirizzo IP versione 4 bytes
  TIPv4 = record
  private const
    LOOPBACK_NET  = $7F000000;
    LOOPBACK_MASK = $FF000000;
    LOOPBACK_IP   = $7F000001;
  private
    FValue: Cardinal;
  public
    class function GetRandomIP: TIPv4; static;

    class operator Implicit(const Value: string): TIPv4;
    class operator Implicit(Value: TIPv4): string;

    procedure FromString(const Value: string);
    function ToString: string;

    function IsLocalhost: Boolean;

    procedure RandomInit;

    //Per ragioni tecniche espongo il valore interno, anche se si ragiona meglio
    //con la versione stringa
    property Value: Cardinal read FValue write FValue;
  end;

const
  LIB_VERSION: TProductFileVersion = (Major: 1; Minor: 0; Build: 0; Release: 0);

implementation

uses
  System.Math;

{ TIPv4 }

procedure TIPv4.FromString(const Value: string);
var
  Part: TArray<string>;
  I: Cardinal;
  B: Byte;
begin
  if Value.ToLower = 'localhost' then
    FValue:=LOOPBACK_IP
  else
  begin
    Part:=Value.Split(['.']);
    FValue:=0;
    for I:=0 to 3 do
    begin
      FValue:=(FValue shl $8);
      if (I<=High(Part)) and(Byte.TryParse(Part[I], B)) then
        Inc(FValue,B);
    end
  end
end;

class function TIPv4.GetRandomIP: TIPv4;
begin
  Result.Value:=Cardinal(RandomRange(Integer.MinValue, Integer.MaxValue))
end;

class operator TIPv4.Implicit(Value: TIPv4): string;
begin
  Result:=Value.ToString;
end;

function TIPv4.IsLocalhost: Boolean;
begin
  Result:=(FValue and LOOPBACK_MASK) = LOOPBACK_NET
end;

procedure TIPv4.RandomInit;
begin
  Self:=TIPv4.GetRandomIP
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
