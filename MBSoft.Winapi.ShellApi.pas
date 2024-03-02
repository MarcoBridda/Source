unit MBSoft.Winapi.ShellApi;
//****************************************************************************
//Aggiunte alla unit Winapi.ShellApi
//
//Copyright MBSoft(2020)
//****************************************************************************

interface

uses
  System.SysUtils, System.Types,
  Winapi.Messages, Winapi.Windows, Winapi.ShellApi,
  MBSoft.System.IOUtils;

type
  //Eccezioni
  EMBSoftShellapi = class(Exception);

  //**************************************************************************
  //Per la parte relativa alla gestione del drag&drop dalla shell, si veda il
  //sito DelphiDabbler.com (https://delphidabbler.com/articles/article-11)
  //Ho tratto "ispirazione" da lì...
  //**************************************************************************

  //Informazioni sui files trascinati dalla shell
  TSHLFileInfo = record
  private
    FFileList: TFileNameDynArray;
    FDropPoint: TPoint;

    function GetCount: Integer;
  public
    constructor Create(const AList: TFileNameDynArray; const APoint: TPoint);

    property FileList: TFileNameDynArray read FFileList;
    property DropPoint: TPoint read FDropPoint;
    property Count: Integer read GetCount;
  end;

  //Una classe che gestisce le operazioni di trascinamento dalla shell
  TSHLDragDropManager = class(TObject)
  private
    FHandle: HWND;
  public
    constructor Create(AHandle: HWND);
    destructor Destroy; override;

    //Gestione del messaggio WM_DROPFILES di Windows
    function GetDroppedFiles(var Msg: TWMDropFiles): TSHLFileInfo;
  end;

implementation

{ TSHLFileInfo }

constructor TSHLFileInfo.Create(const AList: TFileNameDynArray; const APoint: TPoint);
begin
  FFilelist:=AList;
  FDropPoint:=APoint
end;

function TSHLFileInfo.GetCount: Integer;
begin
  Result:=Length(FFileList)
end;

{ TSHLDragDropManager }

constructor TSHLDragDropManager.Create(AHandle: HWND);
begin
  FHandle:=AHandle;
  DragAcceptFiles(FHandle,true)
end;

destructor TSHLDragDropManager.Destroy;
begin
  DragAcceptFiles(FHandle,false);
  inherited;
end;

function TSHLDragDropManager.GetDroppedFiles(var Msg: TWMDropFiles): TSHLFileInfo;
var
  H: HDROP;                 // drop handle
  Count: Integer;           // quanti file ci sono?
  FLength: Integer;         // lunghezza di un nome file
  FileName: string;         // il nome del file
  I: Integer;               // contatore
  DropPoint: TPoint;        // punto di rilascio
  List: TFileNameDynArray;  // lista dei files
begin
  H:=Msg.Drop;
  try
    Count:=DragQueryFile(H,$FFFFFFFF,nil,0);
    DragQueryPoint(H,DropPoint);
    if Count>0 then
      SetLength(List,Count);
    for I :=0 to Count-1 do
    begin
      FLength:=DragQueryFile(H,I,nil,0);
      SetLength(FileName,FLength);
      DragQueryFile(H,I,PChar(FileName),FLength + 1);
      List[I]:=FileName
    end;
  finally
    Result.Create(List,DropPoint);
    DragFinish(H)
  end;
  Msg.Result:=0
end;

end.
