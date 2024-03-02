unit MBSoft.Vcl.Dialogs;
//****************************************************************************
//Aggiunte alla Unit Vcl.Dialogs
//
//Alcune parti di codice erano vecchie e sono state rimodernate :)
//
//Copyright MBSoft(2020-2021)
//****************************************************************************

interface

uses
  System.SysUtils,
  Vcl.Dialogs;

type
  //Eccezioni
  EMBSoftVclDlgException = class(Exception);

  //Mi sono accorto che molto spesso uso la funzione "MessageDlg" mettendo solo
  //il pulsante OK. Allora ne ho create 3 (su 5) di personalizzate con i vari
  //tipi di dialogo (mtInformation, mtError, mtWarning)
  TMBDlg = record
    class function Information(const Msg: String; Buttons: TMsgDlgButtons = [mbOk];
      HelpCtx: Longint = 0): Word; static;
    class function Error(const Msg: String; Buttons: TMsgDlgButtons = [mbOk];
      HelpCtx: Longint = 0): Word; static;
    class function Warning(const Msg: String; Buttons: TMsgDlgButtons = [mbOk];
      HelpCtx: Longint = 0): Word; static;
  end;

implementation

uses
  System.UITypes;

{ TMBDlg }

class function TMBDlg.Error(const Msg: String; Buttons: TMsgDlgButtons;
  HelpCtx: Longint): Word;
begin
  Result:=MessageDlg(Msg,mtError,Buttons,HelpCtx)
end;

class function TMBDlg.Information(const Msg: String; Buttons: TMsgDlgButtons;
  HelpCtx: Longint): Word;
begin
  Result:=MessageDlg(Msg,mtInformation,Buttons,HelpCtx)
end;

class function TMBDlg.Warning(const Msg: String; Buttons: TMsgDlgButtons;
  HelpCtx: Longint): Word;
begin
  Result:=MessageDlg(Msg,mtWarning,Buttons,HelpCtx)
end;

end.
