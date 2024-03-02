unit MBSoft.Vcl.Forms;
//******************************************************************************
//Codice utile per gestire meglio un'applicazione Delphi VCL
//
//La parte che implementa il pattern Singleton di TApplication è stata presa e
//sistemata da un programma di esempio tratto dal libro Programmare in Delphi 7,
//di Marco Cantù
//
//Copyright MBSoft(2016-2021)
//
//Codice originale scritto per Delphi 7 e poi aggiornato a Delphi 10.4
//******************************************************************************

interface

uses
  System.Classes, System.Types, System.SysUtils, System.IniFiles,
  System.Generics.Collections,
  VCL.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.AppEvnts,
  Winapi.Messages,
  MBSoft.System, MBSoft.System.IOUtils,
  MBSoft.Winapi.Messages, MBSoft.Winapi.ShellApi;

type
  //Eccezioni
  EMBSoftVclForms = class(Exception);
  EMBApplication = class(EMBSoftVclForms);

  //Supporto per il pattern Singleton
  TEnumWndParams = record
  public
    Wnd: THandle;
    FormClass: TClass;
    ModuleName: String;
  end;

  PEnumWndParams = ^TEnumWndParams;

  TWinItem = (wiNone, wiModule, wiClass);

  //Per uniformità raccolgo le routine per gestire il pattern singleton
  //in un record
  TSingletonApp = record
  public
    class function CheckMutex(const MutexID: String; TimeOut: Cardinal):
      Boolean; static;
    class function GetWinItemName(const hwnd, Size: Cardinal;
      const WinItem: TWinItem):String; static;
    class function EnumWndProc (hwnd: THandle; aParam: Cardinal): Boolean;
      stdcall; static;
  end;

  //Un class helper che aggiunge funzionalità alla classe TApplication
  TMBVclAppHelper = class helper for TApplication
  private
    //Getter per le proprietà
    function GetAppName: String;
    function GetLocalFolder: TFileName;
    function GetLocalPath: TFileName;
    function GetDefaultIniFileName: TFileName;

    //Utilità
    function GetExeName: TFileName;
  public
    //Metodo da usare al posto di Run quando si vuole una sola istanza di questa
    //applicazione. Per MutexId usare una stringa univoca a piacere, oppure, per
    //comodità, si potrebbe usare un GUID...
    function SingletonRun(const MutexID: String; MainFormClass: TComponentClass;
      TimeOut: Cardinal = 0): Boolean;

    //Ridefinisco il metodo statico Run in modo da poter aggiungere codice
    //personalizzato in automatico prima di far partire l'applicazione.
    procedure Run;

    //Nome del file EXE senza estensione
    property AppName: String read GetAppName;

    //Cartella locale (senza "/")
    property LocalFolder: TFileName read GetLocalFolder;

    //Percorso locale (LocalFolder+"/")
    property LocalPath: TFileName read GetLocalPath;

    //Nome di default del file INI completo di percorso
    property DefaultIniFileName: TFileName read GetDefaultIniFileName;
  end;

implementation

uses
  Winapi.Windows, System.Math;

const
  //Eccezioni
  UNNAMED_MUTEX = 'Mutex senza nome';

{ TSingletonApp }

class function TSingletonApp.CheckMutex(const MutexID: String;
  TimeOut: Cardinal): Boolean;
var
  Mutex: THandle;
begin
  if not String.IsNullOrEmpty(MutexID) then
  begin
    Mutex := CreateMutex (nil, False, PWideChar(MutexID));
    Result:=WaitForSingleObject (Mutex, TimeOut) <> WAIT_TIMEOUT
  end
  else
    raise EMBSoftVclForms.Create(UNNAMED_MUTEX);
end;

class function TSingletonApp.EnumWndProc(hwnd: THandle;
  aParam: Cardinal): Boolean;
var
  ClassName, WinModuleName: string;
  WinInstance: THandle;
  Params: PEnumWndParams;
  Found: Boolean;
begin
  Params:=PEnumWndParams(aParam);

  ClassName:=GetWinItemName(hwnd,100,wiClass);
  Found:=Params^.FormClass.ClassNameIs(ClassName);
  if Found then
  begin
    // get the module name of the target window
    WinInstance := GetWindowLong (hwnd, GWL_HINSTANCE);
    WinModuleName:=GetWinItemName(WinInstance,200,wiModule);

    // compare module names
    Found:=WinModuleName=Params.ModuleName;
    if Found then
      Params^.Wnd := hwnd;
  end;
  Result:=not Found
end;

class function TSingletonApp.GetWinItemName(const hwnd, Size: Cardinal;
  const WinItem: TWinItem): String;
begin
  SetLength (Result, Size);
  case WinItem of
    wiModule: GetModuleFileName (hwnd, PChar (Result), Size);
    wiClass: GetClassName (hwnd, PChar (Result), Size);
  else
    Result:=''
  end;
  Result:=PChar (Result); // adjust length
end;

{ TMBVclAppHelper }

function TMBVclAppHelper.GetAppName: String;
begin
  Result:=GetExeName.Name;
  Result:=Result.Remove(Result.LastIndexOf('.'))
end;

function TMBVclAppHelper.GetDefaultIniFileName: TFileName;
begin
  Result:=GetExeName.ChangeExt('.ini')
end;

function TMBVclAppHelper.GetExeName: TFileName;
begin
  Result:=TFileName(Self.ExeName)
end;

function TMBVclAppHelper.GetLocalFolder: TFileName;
begin
  Result:=GetExeName.Dir;
end;

function TMBVclAppHelper.GetLocalPath: TFileName;
begin
  Result:=GetExeName.Path;
end;

procedure TMBVclAppHelper.Run;
begin
  inherited Run;
end;

function TMBVclAppHelper.SingletonRun(const MutexID: String;
  MainFormClass: TComponentClass; TimeOut: Cardinal): Boolean;
var
  EnumParams: TEnumWndParams;
  ParamsListID: Cardinal;
  ParamsListName: String;
begin
  Result:=TSingletonApp.CheckMutex(MutexID,TimeOut);
  if not Result then  
  begin
    // Recupera il nome del modulo corrente
    EnumParams.ModuleName:=TSingletonApp.GetWinItemName(hInstance,200,wiModule);
    //Recupera la classe del form principale e il corrispondente handle.
    //L'handle del form mi serve per distinguerlo da quello dell'istanza
    //precedente.
    EnumParams.FormClass:=MainFormClass;
    // Cerca la finestra dell'istanza precedente
    EnumParams.Wnd:=0;
    EnumWindows (@TSingletonApp.EnumWndProc, Cardinal(@EnumParams));
    if EnumParams.Wnd <> 0 then  //E, se la trova...
    begin
      //Genera in nome casuale univoco per la lista dei parametri
      Randomize;
      ParamsListID:=Cardinal(RandomRange(Integer.MinValue,Integer.MaxValue));
      ParamsListName:=ParamsListID.ToString;
      //Crea la lista dei parametri se ce ne sono
      TMBCmdLine.SaveToFile(ParamsListName);
      //Riporta in primo piano l'istanza precedente dell'applicazione
      PostMessage (EnumParams.Wnd, WM_MBAPPRESTORE, ParamsListID, 0);
      SetForegroundWindow (EnumParams.Wnd);
    end;
  end;
end;

end.
