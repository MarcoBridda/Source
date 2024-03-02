unit MBSoft.Links;
//*****************************************************************************
//Gestione dei file .lnk, usati da Windows per creare collegamenti ad altri file
//
//Il codice originale non è farina del mio sacco ma proviene dal sito di Carlo
//Pasolini (http://pasotech.altervista.org/delphi/articolo9.htm)
//
//Copyright MBSoft (2019)
//*****************************************************************************

interface

uses
  Winapi.Windows, System.SysUtils, System.Win.ComObj, Winapi.ShlObj,
  Winapi.ActiveX;

type
  TSpecialLocations = (slNone, slDesktop, slFavorites, slFonts, slNetHood,
                       slPersonal, slPrograms, slRecent, slSendTo, slStartMenu,
                       slStartup, slTemplates);

type
  TMBFileLink = class(TObject)
  private
    FIObj : IUnknown;
    FLink : IShellLink;
    FIPFile : IPersistFile;
    FTargetW : WideString;
    FTarget : string;
    FArgs : string;
    FWorkDir : string;
    FLinkName : string;
    FSpecialLocation : TSpecialLocations;

    function GetSpecialFolderPath(Folder: integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute;

    property Target: string read FTarget write FTarget;
    property Args: string read FArgs write FArgs;
    property WorkDir: string read FWorkDir write FWorkDir;
    property LinkName: string read FLinkName write FLinkName;
    property SpecialLocation: TSpecialLocations read FSpecialLocation write FSpecialLocation;
end;

implementation

{ TMBFileLink }

constructor TMBFileLink.Create;
begin
  { Creiamo un oggetto ShellLink e ricaviamo 2 riferimenti ad esso
  rispettivamente di tipo IShellLink e IPersistFile}
  FIObj := CreateComObject(CLSID_ShellLink);
  FLink := FIObj as IShellLink;
  FIPFile := FIObj as IPersistFile;
end;

destructor TMBFileLink.Destroy;
begin
  { Free the ShellLink object. }
  FIObj := nil;
  FLink := nil;
  FIPFile := nil;
  inherited;
end;

function TMBFileLink.GetSpecialFolderPath(Folder: integer): string;
var
  ItemIdList: PItemIdList;
  CharStr: array[0..MAX_PATH] of Char;
  Directory: string;
  Cartelle: string;
  Index: integer;
  Lung: integer;
begin
  OleCheck(ShGetSpecialFolderLocation(0, Folder, ItemIdList));
  if ShGetPathFromIdList(ItemIdList, CharStr) then
  begin
    Index := LastDelimiter('\', FLinkName);
    if Index <> 0 then //ci sono sottocartelle
    begin
      Cartelle := Copy(FLinkName, 1, Index - 1);
      Directory := string(CharStr) + '\' + Cartelle;
      if not DirectoryExists(Directory) then
        ForceDirectories(Directory);
    end;

    Result := string(CharStr) + '\' + FLinkName;
  end;
end;

procedure TMBFileLink.Execute;
begin
  with FLink do
  begin
    SetPath(PChar(FTarget));
    SetArguments(PChar(FArgs));
    SetWorkingDirectory(PChar(FWorkDir));
  end;

  case FSpecialLocation of
    slDesktop : FTargetW := GetSpecialFolderPath(CSIDL_DESKTOPDIRECTORY);
    slFavorites : FTargetW := GetSpecialFolderPath(CSIDL_FAVORITES);
    slFonts : FTargetW := GetSpecialFolderPath(CSIDL_FONTS);
    slNetHood : FTargetW := GetSpecialFolderPath(CSIDL_NETHOOD);
    slPersonal : FTargetW := GetSpecialFolderPath(CSIDL_PERSONAL);
    slPrograms : FTargetW := GetSpecialFolderPath(CSIDL_PROGRAMS);
    slRecent : FTargetW := GetSpecialFolderPath(CSIDL_RECENT);
    slSendTo : FTargetW := GetSpecialFolderPath(CSIDL_SENDTO);
    slStartMenu : FTargetW := GetSpecialFolderPath(CSIDL_STARTMENU);
    slStartup : FTargetW := GetSpecialFolderPath(CSIDL_STARTUP);
    slTemplates : FTargetW := GetSpecialFolderPath(CSIDL_TEMPLATES);
  else
    FTargetW := FLinkName;
  end;

 FIPFile.Save(PWChar(FTargetW),False);

end;

end.
