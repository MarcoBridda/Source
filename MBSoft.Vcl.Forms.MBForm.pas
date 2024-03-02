unit MBSoft.Vcl.Forms.MBForm;
//****************************************************************************
//Un form per automatizzare le operazioni più comuni:
// -il caricamento e il salvataggio delle impostazioni con un file INI,
//  eseguendo l'overload dei metodi "LoadSettings" e "SaveSettings";
//
// -la gestione automatica della minimizzazione sulla system tray,
//  impostando la proprieta "IsTrayApp" nell'evento "OnCreate";
//
// -gestione del drag&drop dalla shell, definendo un gestore per l'evento
//  "OnShellDragDrop" e assegnandolo via codice nell' evento "OnCreate".
//
//Per usare questa classe basta aggiungere questa unit al progetto con il
//comando Project->Add to Project (Shift+F11) e poi ereditare il form da
//questo con il comando File->New->Other...->Inheritable Items, e poi scegliere
//TMBForm.
//
//Copyright MBSoft (2020-2022)
//****************************************************************************

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.IniFiles,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.ExtCtrls,
  MBSoft.System.IOUtils, MBSoft.Winapi.ShellApi, MBSoft.Winapi.Messages;

type
  //Eccezioni
  EMBSoftVclFormsMBForm = class(Exception);
  EMBForm = class(EMBSoftVclFormsMBForm);

  //Un evento che mi serve per gestire il drad&drop dalla shell
  TShellDragDropEvent = procedure(Sender: TObject; FileList: TFileNameDynArray;
    X: Integer; Y: Integer) of object;

type
  TMBForm = class(TForm)
    //Componenti per la gestione dell'icona nell'area di notifica
    TrayIcon: TTrayIcon;
    AppEvents: TApplicationEvents;

    //Gestione della Tray Icon - Eventi da ancorare ai componenti
    procedure TrayIconDblClick(Sender: TObject);
    procedure AppEventsIdle(Sender: TObject; var Done: Boolean);
    procedure AppEventsMinimize(Sender: TObject);
  private
    //Campi di servizio per la gestione dell'icona nell'area di notifica
    FWindowState: TWindowState;
    FIsOnTray: Boolean;
    FShowTrayIcon: Boolean;

    //L'applicazione deve minimizzarsi nell'area di notifica?
    FIsTrayApp: Boolean;

    //Gestore del drag&drop dalla shell
    FSHLDragDropManager: TSHLDragDropManager;
    //Evento drag&drop dalla shell
    FOnShellDragDrop: TShellDragDropEvent;

    //Getter/Setter per le proprietà
    function GetIsMainForm: Boolean;
    procedure SetIsTrayApp(const Value: Boolean);
  protected
    property IsMainForm: Boolean read GetIsMainForm;
    property IsTrayApp: Boolean read FIsTrayApp write SetIsTrayApp;
    property IsOnTray: Boolean read FIsOnTray;
    property ShowTrayIcon: Boolean read FShowTrayIcon write FShowTrayIcon;

    //Evento drag&drop dalla shell
    //property OnShellDragDrop: TShellDragDropEvent read FOnShellDragDrop
      //write FOnShellDragDrop;

    procedure DoCreate; override;
    procedure DoClose(var Action: TCloseAction); override;
    procedure DoDestroy; override;

    //Innesca l'evento drag&drop dalla shell
    procedure DoShellDragDrop(List: TFileNameDynarray; Point: TPoint); dynamic;

    //Evento drag&drop dalla shell
    property OnShellDragDrop: TShellDragDropEvent read FOnShellDragDrop
      write FOnShellDragDrop;

    //Eseguire l'override di questi due metodi per caricare/salvare le
    //impostazioni nel file INI
    procedure LoadSettings(Ini: TIniFile); virtual;
    procedure SaveSettings(Ini: TIniFile); virtual;

    //Eseguire l'override di questo metodo per analizzare i parametri
    //della linea di comando
    procedure ParseParams; virtual;

    //Gestione della Tray Icon - Azioni
    procedure MinimizeToTray;
    procedure RestoreApp;

    //Messaggio drag&drop da shell
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;

    //Messaggio personalizzato per gestire il pattern Singleton (vedi la
    //unit MBSoft.Vcl.Forms)
    procedure WMMbAppRestore(var Msg: TMessage); message WM_MBAPPRESTORE;
  public
    { Public declarations }
  end;

var
  MBForm: TMBForm;

implementation

{$R *.dfm}

uses
  MBSoft.System, MBSoft.Vcl.Forms;

const
  //Eccezioni
  CANT_CHANGE_PROPERTY = 'Impossibile modificare quì il valore della proprietà:';
  IS_NOT_MAIN_FORM = ' non è il form principale';
  USE_ONCREATE_EVENT = ' usare l''evento "OnCreate"';

procedure TMBForm.AppEventsIdle(Sender: TObject; var Done: Boolean);
begin
  if WindowState<>wsMinimized then
    FWindowState:=WindowState;
end;

procedure TMBForm.AppEventsMinimize(Sender: TObject);
begin
  if IsTrayApp then
    MinimizeToTray;
end;

procedure TMBForm.DoClose(var Action: TCloseAction);
var
  Ini: TIniFile;
begin
  //Prima gli eventi OnCloseQuery e OnClose
  inherited DoClose(Action);

  //E poi, se veramente vuoi chiudere, salva lo stato
  if (Action = caFree) or (Application.MainForm = Self) then
  begin
    Ini:=TIniFile.Create(Application.DefaultIniFileName);
    try
      SaveSettings(Ini)
    finally
      Ini.Free
    end;
  end;
end;

procedure TMBForm.DoCreate;
var
  Ini: TIniFile;
begin
  FShowTrayIcon:=true;

  ParseParams;

  //Un trick, dato che nel costruttore questo flag viene disabilitato
  //prima di chiamare DoCreate, lo reimposto giusto il tempo per eseguire
  //l'evento OnCreate
  Include(FFormState, fsCreating);
  inherited;
  Exclude(FFormState, fsCreating);

  //Crea il file ini e carica le impostazioni
  Ini:=TIniFile.Create(Application.DefaultIniFileName);
  try
    LoadSettings(Ini)
  finally
    Ini.Free
  end;

  //Solo se è il form principale, inizializza il manager del drag&drop dalla shell
  if IsMainForm then
    FSHLDragDropManager:=TSHLDragDropManager.Create(Self.Handle);
end;

procedure TMBForm.DoDestroy;
begin
  //Libera le risorse occupate del gestore del drag&drop dalla shell
  FSHLDragDropManager.Free;

  inherited;
end;

procedure TMBForm.DoShellDragDrop(List: TFileNameDynarray; Point: TPoint);
begin
  if Assigned(FOnShellDragDrop) then
    FOnShellDragDrop(Self,List,Point.X,Point.Y)
end;

function TMBForm.GetIsMainForm: Boolean;
begin
  Result:=(Application.MainForm=nil) or (Self=Application.MainForm)
end;

procedure TMBForm.LoadSettings(Ini: TIniFile);
begin
  //Eseguire l'override di questo metodo nei form derivati e mettere il
  //codice per caricare le impostazioni dal file ini.
  //Questo metodo verrà chiamato automaticamente dopo aver innescato l'evento
  //OnCreate, fornendo un'istanza di TIniFile dalla quale leggere i dati
end;

procedure TMBForm.WMMbAppRestore(var Msg: TMessage);
begin
  TMBCmdLine.LoadFromFile(Msg.WParam.ToString);
  ParseParams;
  RestoreApp
end;

procedure TMBForm.MinimizeToTray;
begin
  Self.Hide;
  Self.WindowState:=wsMinimized;
  TrayIcon.Visible:=FShowTrayIcon;
  FIsOnTray:=true;
end;

procedure TMBForm.ParseParams;
begin
  //Eseguire l'override di questo metodo nei form derivati e mettere il
  //codice analizzare la riga di comado e inizializzare l'app.
  //Questo metodo verrà chiamato automaticamente nel metodo DoCreate e
  //nel gestore del messaggio WM_MBAPPRESTORE
end;

procedure TMBForm.RestoreApp;
begin
  if IsTrayApp then
  begin
    TrayIcon.Visible:=false;
    FIsOnTray:=false;
    Self.Show;
  end;

  Self.WindowState:=FWindowState;
  Application.BringToFront;
end;

procedure TMBForm.SaveSettings(Ini: TIniFile);
begin
  //Eseguire l'override di questo metodo nei form derivati e mettere il
  //codice per salvare le impostazioni nel file ini.
  //Questo metodo verrà chiamato automaticamente prima di innescare l'evento
  //OnDestroy, fornendo un'istanza di TIniFile sulla quale scrivere i dati
end;

procedure TMBForm.SetIsTrayApp(const Value: Boolean);
//Questa proprietà si può impostare solo dentro l'evento "OnCreate" del
//form principale
begin
  if fsCreating in Self.FormState then
  begin
    if IsMainForm then
    begin
      FIsTrayApp:=Value;
    end
    else
      raise EMBForm.Create(CANT_CHANGE_PROPERTY+Self.Name+IS_NOT_MAIN_FORM);
  end
  else
    raise EMBForm.Create(CANT_CHANGE_PROPERTY+USE_ONCREATE_EVENT);
end;

procedure TMBForm.TrayIconDblClick(Sender: TObject);
begin
  RestoreApp;
end;

procedure TMBForm.WMDropFiles(var Msg: TWMDropFiles);
var
  Info: TSHLFileInfo;
begin
  Info:=FSHLDragDropManager.GetDroppedFiles(Msg);
  DoShellDragDrop(Info.FileList,Info.DropPoint)
end;

end.
