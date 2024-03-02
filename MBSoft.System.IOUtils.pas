unit MBSoft.System.IOUtils;
//******************************************************************************
//Aggiunte alla Unit System.IOUtils.
//
//Copyright MBSoft(2017-2022)
//
//Codice originale scritto per Delphi 10.1 aggiornato a Delphi 10.4
//******************************************************************************

interface

uses
  System.Types, System.SysUtils;

type
  //Eccezioni
  EMBSoftIOUtils = class(Exception);

  //Questi valori sono mappati direttamente sulle corrispondenti costanti relative
  //alla funzione GetDriveType definita in Kernel32.dll e nella corrispondente
  //unit Delphi Winapi.Windows. Per maggiori informazioni consultare la pagina:
  //https://msdn.microsoft.com/en-us/library/windows/desktop/aa364939(v=vs.85).aspx
  TDriveType = (dtUnknow, dtNoRootDir, dtRemoveable, dtFixed, dtRemote, dtCDRom,
                dtRamDisk);

  TDriveTypeHelper = record helper for TDriveType
    function ToString: String;
  end;

  TVolumeSerialNumber = type Cardinal;

  TVolumeSerialNumberHelper = record helper for TVolumeSerialNumber
    function ToString(UseBrackets: Boolean = true): String;
  end;

  TDriveInfo = record
  private
    FVolumeName: String;
    FSerialNumber: TVolumeSerialNumber;
    FVolumeLabel: String;
    FVolumeType: TDriveType;
    FIsReady: Boolean;
    FIndex: Integer;
  public
    constructor Create(const Drive: String);

    function Exists: Boolean;
    function Refresh: Boolean;

    function FreeSpace: Int64;
    function TotalSpace: Int64;

    property VolumeName: String read FVolumeName;
    property SerialNumber: TVolumeSerialNumber read FSerialNumber;
    property VolumeLabel: String read FVolumeLabel;
    property VolumeType: TDriveType read FVolumeType;
    property IsReady: Boolean read FIsReady;
    property Id: Integer read FIndex;
  end;

  TDriveInfoDynArray = array of TDriveInfo;

  TDrive = record
  public
    class function GetDrivesList: TStringDynArray; static;
    class function GetDrives: TDriveInfoDynArray; static;
  end;

  TFileNameDynArray = array of TFileName;

  //Una struttura per raggruppare tutti i vari ExtractFileXxx
  TMBFileNameHelper = record helper for TFileName
  public
    function Name: TFileName;
    function Ext: String;
    function ExtIs(Ext: String): Boolean;
    function Dir: TFileName;    //Senza '\' finale (C:\MiaCartella)
    function Path: TFileName;   //Con '\' finale (C:\MiaCartella\)
    function Parent: TFileName; //La cartella che contiene questo elemento
    function ParentIs(Parent: String): Boolean;
    function ShortPathName: String;
    function Drive: String;
    function Root: TFileName;  //Percorso radice (C:\)
    function ChangePath(NewPath: TFileName): TFileName;
    function ChangeExt(NewExt: String): TFileName;
    function Exists: Boolean;
    function IsDir: Boolean;
    function IsFile: Boolean;
    function IsHidden: Boolean;
    function IsSystem: Boolean;
    function IsRoot: Boolean;
  end;

implementation

uses
  System.IOUtils, Winapi.Windows;

const
  DRIVE_TYPE_STRINGS: array[TDriveType] of String = ('Sconosciuto', 'NoRootDir',
    'Rimovibile', 'Fisso','Remoto', 'CDRom', 'RamDisk');

{TDriveTypeHelper}
function TDriveTypeHelper.ToString: String;
begin
  Result:=DRIVE_TYPE_STRINGS[Self]
end;

{TVolumeSerialNumberHelper}
function TVolumeSerialNumberHelper.ToString(UseBrackets: Boolean): String;
begin
  if Self<>0 then
  begin
    Result:=Cardinal(Self).ToHexString.Insert(4,'-');
    if UseBrackets then
      Result:='['+Result+']'
  end
  else
    Result:=''
end;

{TDriveInfo}
constructor TDriveInfo.Create(const Drive: String);
begin
  FVolumeName:=UpperCase(Drive);
  try
    Exists;
    Refresh
  except
    FVolumeName:='';
    raise
  end;
end;

function TDriveInfo.Exists: Boolean;
begin
  Result:=(not FVolumeName.IsEmpty) and TPath.DriveExists(FVolumeName)
end;

function TDriveInfo.FreeSpace: Int64;
begin
  Result:=DiskFree(FIndex);
end;

function TDriveInfo.Refresh: Boolean;
var
  OldDir: String;
  Volume: PChar;
  Serial: PDWORD;
  Dummy: DWORD;
begin
  Result:=false;
  OldDir:=GetCurrentDir;
  FVolumeType:=TDriveType(GetDriveType(PChar(FVolumeName)));
  FIndex:=Ord(FVolumeName[1])-Ord('A')+1;
  if SetCurrentDir(FVolumeName) then
  begin
    GetMem(Volume,255);
    New(Serial);
    try
      Result:=GetVolumeInformation(nil,Volume,255,Serial,Dummy,Dummy,nil,0);
      if Result then
      begin
        FVolumeLabel:=Volume;
        FSerialNumber:=Serial^
      end;
    finally
      FreeMem(Volume);
      Dispose(Serial)
    end;
    SetCurrentDir(OldDir);
    FIsReady:=Result
  end;
end;

function TDriveInfo.TotalSpace: Int64;
begin
  Result:=DiskSize(FIndex);
end;

{TDrive}
class function TDrive.GetDrivesList: TStringDynArray;
begin
  Result:=TDirectory.GetLogicalDrives;
end;

class function TDrive.GetDrives: TDriveInfoDynArray;
var
  List: TStringDynArray;
  Index: Integer;
begin
  List:=GetDrivesList;
  SetLength(Result,Length(List));
  for Index:=Low(Result) to High(Result) do
    Result[Index].Create(List[Index]);
end;

{ TFileNameHelper }

function TMBFileNameHelper.ChangeExt(NewExt: String): TFileName;
begin
  Result:=ChangeFileExt(Self,NewExt)
end;

function TMBFileNameHelper.ChangePath(NewPath: TFileName): TFileName;
begin
  Result:=ChangeFilePath(Self,NewPath)
end;

function TMBFileNameHelper.Dir: TFileName;
begin
  Result:=ExtractFileDir(Self)
end;

function TMBFileNameHelper.Drive: String;
begin
  Result:=ExtractFileDrive(Self)
end;

function TMBFileNameHelper.Exists: Boolean;
begin
  Result:=(Self<>'') and (FileExists(Self) or DirectoryExists(Self))
end;

function TMBFileNameHelper.Ext: String;
begin
  Result:=ExtractFileExt(Self)
end;

function TMBFileNameHelper.ExtIs(Ext: String): Boolean;
begin
  Result:=Self.Ext.ToLower = Ext.ToLower;
end;

function TMBFileNameHelper.IsDir: Boolean;
begin
  if Self.Exists then
    Result:=(FileGetAttr(Self,false) and faDirectory) = faDirectory
  else
    Result:=false
end;

function TMBFileNameHelper.IsFile: Boolean;
begin
  if Self.Exists then
    Result:=not ((FileGetAttr(Self,false) and faDirectory) = faDirectory)
  else
    Result:=false
end;

function TMBFileNameHelper.IsHidden: Boolean;
begin
  if Self.Exists then
    Result:=(FileGetAttr(Self,false) and faHidden) = faHidden
  else
    Result:=false
end;

function TMBFileNameHelper.IsRoot: Boolean;
begin
  Result:=Self=Root
end;

function TMBFileNameHelper.IsSystem: Boolean;
begin
  if Self.Exists then
    Result:=(FileGetAttr(Self,false) and faSysFile) = faSysFile
  else
    Result:=false
end;

function TMBFileNameHelper.Name: TFileName;
begin
  Result:=ExtractFileName(Self)
end;

function TMBFileNameHelper.Parent: TFileName;
begin
  Result:=Self.Dir.Name
end;

function TMBFileNameHelper.ParentIs(Parent: String): Boolean;
begin
  Result:=String(Self.Parent).ToLower = Parent.ToLower
end;

function TMBFileNameHelper.Path: TFileName;
begin
  Result:=ExtractFilePath(Self)
end;

function TMBFileNameHelper.Root: TFileName;
begin
  Result:=TPath.GetPathRoot(Self)
end;

function TMBFileNameHelper.ShortPathName: String;
begin
  Result:=ExtractShortPathName(Self)
end;

end.
