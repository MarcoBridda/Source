unit MBSoft.System.SysUtils;
//******************************************************************************
//Aggiunte alla Unit System.SysUtils
//
//Copyright MBSoft(2020-2021)
//******************************************************************************

interface

uses
  System.SysUtils;

type
  //Eccezioni
  EMBSoftSystemSysUtils = class(Exception);
  ECopyLabel = class(EMBSoftSystemSysUtils);

  //Supporto per le informazioni di copyright (©MBSoft 2019-2021)
  TCopyInfo = record
  private
    const COMPANY_NAME = 'MBSoft';
    const COPY_SYMBOL = '©';
  public
    class function GetLabel(const StartYear: Integer; const Surround: Boolean = true): String; static;
  end;

implementation

const
  //Eccezioni
  CANT_FUTURE_DEV = 'Impossibile sviluppare un''applicazione nel futuro';

{ TCopyInfo }

class function TCopyInfo.GetLabel(const StartYear: Integer;
  const Surround: Boolean): String;
begin
  Result:=COPY_SYMBOL+COMPANY_NAME+' '+IntToStr(StartYear);
  if StartYear<CurrentYear then
    Result:=Result+'-'+IntToStr(CurrentYear);
  if Surround then
    Result:='('+Result+')';

  {$IFDEF DEBUG}
    if StartYear>CurrentYear then
      raise ECopyLabel.Create(CANT_FUTURE_DEV
        +' ('+StartYear.ToString+')');
  {$ENDIF}
end;

end.
