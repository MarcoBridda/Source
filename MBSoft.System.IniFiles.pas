unit MBSoft.System.IniFiles;
//*****************************************************************************
//Gestione migliorata dei file INI. Ora il file viene visto come una lista di
//oggetti che rappresentano le varie sezioni e che si possono usare per scrivere
//o leggere le impostazioni. Si possono inoltre manipolare le proprietà published
//di un componente, usando Read/WriteComponent, nonchè salvare e recuperare la
//posizione e lo stato corrente di un Form, usando Read/WriteFormPos.
//
//Copyright MBSoft(2015-2020)
//
//Codice originale scritto per Delphi 7 e poi aggiornato a Delphi 10.3 (Rio)
//*****************************************************************************

interface

uses
  System.IniFiles, System.Classes, VCL.Forms;

type
  TMBIniSection = record
  private
    FIniFile: TIniFile;
    FSection: String;
  public
    constructor Create(const Section: String; IniFile: TIniFile);

    property Section: String read FSection;
    property Inifile: TIniFile read FIniFile;

    function ReadInteger(const Ident: String; Default: Longint): Longint;
    function ReadString(const Ident: String; Default: String): String;
    function ReadBool(const Ident: String; Default: Boolean): Boolean;
    function ReadFloat(const Ident: String; Default: Double): Double;
    function ReadDateTime(const Ident: String; Default: TDateTime): TDateTime;
    function ReadDate(const Ident: String; Default: TDateTime): TDateTime;
    function ReadTime(const Ident: String; Default: TDateTime): TDateTime;
    function ReadBinaryStream(const Ident: String; Value: TStream): Integer;

    procedure ReadComponent(AComp: TComponent; Props: array of String);
    procedure ReadFormPos(AForm: TForm);

    procedure WriteInteger(const Name: String; Value: Longint);
    procedure WriteString(const Name: String; Value: String);
    procedure WriteBool(const Name: String; Value: Boolean);
    procedure WriteFloat(const Name: String; Value: Double);
    procedure WriteDateTime(const Name: String; Value: TDateTime);
    procedure WriteDate(const Name: String; Value: TDateTime);
    procedure WriteTime(const Name: String; Value: TDateTime);
    procedure WriteBinaryStream(const Name: String; Value: TStream);

    procedure WriteComponent(AComp: TComponent; Props: array of String);
    procedure WriteFormPos(AForm: TForm);

    function ValueExists (const Ident: String): Boolean;
    function Exists: Boolean;
    procedure DeleteKey(const Ident: String);
    procedure ReadSectionValues(Strings: TStrings);
    procedure WriteSectionValues(Strings: TStrings);
  end;

  TMBIniFileHelper = class helper for TIniFile
  private
    function GetSection(const Name: String): TMBIniSection;
  public
    property Section[const Name: String]: TMBIniSection read GetSection;
  end;

implementation

uses
  System.TypInfo, System.SysUtils;

{ TMbIniFileHelper }

function TMBIniFileHelper.GetSection(const Name: String): TMBIniSection;
begin
  Result:=TMBIniSection.Create(Name,Self);
end;

{ TIniSection }

constructor TMBIniSection.Create(const Section: String; IniFile: TIniFile);
begin
  FIniFile:=IniFile;
  FSection:=Section
end;

procedure TMBIniSection.DeleteKey(const Ident: String);
begin
  FIniFile.DeleteKey(FSection,Ident);
end;

function TMBIniSection.Exists: Boolean;
begin
  Result:=Self.FIniFile.SectionExists(Self.FSection)
end;

function TMBIniSection.ReadBinaryStream(const Ident: String;
  Value: TStream): Integer;
begin
  Result:=FIniFile.ReadBinaryStream(FSection,Ident,Value)
end;

function TMBIniSection.ReadBool(const Ident: String; Default: Boolean): Boolean;
begin
  Result:=FIniFile.ReadBool(FSection,Ident,Default)
end;

procedure TMBIniSection.ReadComponent(AComp: TComponent; Props: array of String);
var
  Index: Integer;
  Prop: String;
  PrTyp: TTypeKind;
  PrVal: Variant;
  PrStr: String;
begin
  for Index:=Low(Props) to High(Props) do
  begin
    Prop:=Props[Index];
    if IsPublishedProp(AComp,Prop) then
    begin
      PrVal:=GetPropValue(AComp,Prop);
      PrTyp:=PropType(AComp,Prop);
      //Per evitare interferenze tra componenti che hanno proprietè con lo
      //stesso nome, anteponi ad esse il nome del componente
      PrStr:=AComp.Name+'.'+Prop;
      case PrTyp of
        tkInteger:     PrVal:=ReadInteger(PrStr,PrVal);
        tkEnumeration: PrVal:=ReadString(PrStr,PrVal);
        tkFloat:       PrVal:=ReadFloat(PrStr,PrVal);
        tkString,tkLString,tkWString,tkUString:
          PrVal:=ReadString(PrStr,PrVal);
      else
        //...
      end;
      SetPropValue(AComp,Prop,PrVal)
    end
  end
end;

function TMBIniSection.ReadDate(const Ident: String;
  Default: TDateTime): TDateTime;
begin
  Result:=FIniFile.ReadDate(FSection,Ident,Default)
end;

function TMBIniSection.ReadDateTime(const Ident: String;
  Default: TDateTime): TDateTime;
begin
  Result:=FIniFile.ReadDateTime(FSection,Ident,Default)
end;

function TMBIniSection.ReadFloat(const Ident: String; Default: Double): Double;
begin
  Result:=FIniFile.ReadFloat(FSection,Ident,Default)
end;

procedure TMBIniSection.ReadFormPos(AForm: TForm);
begin
  ReadComponent(AForm,['WindowState']);
  if AForm.WindowState=wsNormal then
    ReadComponent(AForm,['Left','Top','Width','Height'])
end;

function TMBIniSection.ReadInteger(const Ident: String;
  Default: Longint): Longint;
begin
  Result:=FIniFile.ReadInteger(FSection,Ident,Default)
end;

procedure TMBIniSection.ReadSectionValues(Strings: TStrings);
begin
  FIniFile.ReadSectionValues(FSection,Strings);
end;

function TMBIniSection.ReadString(const Ident: String; Default: String): String;
begin
  Result:=FIniFile.ReadString(FSection,Ident,Default)
end;

function TMBIniSection.ReadTime(const Ident: String;
  Default: TDateTime): TDateTime;
begin
  Result:=FIniFile.ReadTime(FSection,Ident,Default)
end;

function TMBIniSection.ValueExists(const Ident: String): Boolean;
begin
  Result:=FIniFile.ValueExists(FSection,Ident)
end;

procedure TMBIniSection.WriteBinaryStream(const Name: String; Value: TStream);
begin
  FIniFile.WriteBinaryStream(FSection,Name,Value);
end;

procedure TMBIniSection.WriteBool(const Name: String; Value: Boolean);
begin
  FIniFile.WriteBool(FSection,Name,Value);
end;

procedure TMBIniSection.WriteComponent(AComp: TComponent; Props: array of String);
var
  Index: Integer;
  Prop: String;
  PrTyp: TTypeKind;
  PrVal: Variant;
  PrStr: String;
begin
  for Index:=Low(Props) to High(Props) do
  begin
    Prop:=Props[Index];
    if IsPublishedProp(AComp,Prop) then
    begin
      PrVal:=GetPropValue(AComp,Prop);
      PrTyp:=PropType(AComp,Prop);
      //Per evitare interferenze tra componenti che hanno proprietè con lo
      //stesso nome, anteponi ad esse il nome del componente
      PrStr:=AComp.Name+'.'+Prop;
      case PrTyp of
        tkInteger:     WriteInteger(PrStr,PrVal);
        tkEnumeration: WriteString(PrStr,PrVal);
        tkFloat:       WriteFloat(PrStr,PrVal);
        tkString,tkLString,tkWString,tkUString:
          WriteString(PrStr,PrVal);
      else
        WriteString('<'+Prop,'Tipo non supportato...>')
      end
    end
  end
end;

procedure TMBIniSection.WriteDate(const Name: String; Value: TDateTime);
begin
  FIniFile.WriteDate(FSection,Name,Value);
end;

procedure TMBIniSection.WriteDateTime(const Name: String; Value: TDateTime);
begin
  FIniFile.WriteDateTime(FSection,Name,Value);
end;

procedure TMBIniSection.WriteFloat(const Name: String; Value: Double);
begin
  FIniFile.WriteFloat(FSection,Name,Value);
end;

procedure TMBIniSection.WriteFormPos(AForm: TForm);
begin
  WriteComponent(AForm,['WindowState']);
  if AForm.WindowState=wsNormal then
    WriteComponent(AForm,['Left','Top','Width','Height'])
end;

procedure TMBIniSection.WriteInteger(const Name: String; Value: Longint);
begin
  FIniFile.WriteInteger(FSection,Name,Value);
end;

procedure TMBIniSection.WriteSectionValues(Strings: TStrings);
var
  Row: String;
  RowPart: TArray<String>;
begin
  for Row in Strings do
  begin
    RowPart:=Row.Split(['=']);
    if Length(RowPart)=2 then
      Self.WriteString(RowPart[0],RowPart[1]);
  end;
end;

procedure TMBIniSection.WriteString(const Name: String; Value: String);
begin
  FIniFile.WriteString(FSection,Name,Value);
end;

procedure TMBIniSection.WriteTime(const Name: String; Value: TDateTime);
begin
  FIniFile.WriteTime(FSection,Name,Value);
end;

end.
