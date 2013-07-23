unit fCommonLocal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs; 

type

  { TfrmCommonLocal }

  TfrmCommonLocal = class(TForm)
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure SaveWindowPos;
    procedure LoadWindowPos;

    function GetLocalConfigFile : String;
  public

  end; 

var
  frmCommonLocal: TfrmCommonLocal;

implementation

{$R *.lfm}

uses uCfgStorage;

procedure TfrmCommonLocal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveWindowPos
end;

procedure TfrmCommonLocal.FormCreate(Sender: TObject);
begin
  if (iniLocal = nil) then
  begin
    iniLocal := TCfgStorage.Create(GetLocalConfigFile)
  end
end;

procedure TfrmCommonLocal.FormShow(Sender: TObject);
begin
  LoadWindowPos
end;

function TfrmCommonLocal.GetLocalConfigFile : String;
         procedure CreateEmptyFile(emFile : String);
         var
           f : TextFile;
         begin
           AssignFile(f,emFile);
           Rewrite(f);
           WriteLn(f,'');
           CloseFile(f)
         end;
var
  dir : String;
begin
  dir := ExtractFilePath(GetAppConfigFile(False))+'cqrtest/';
  if DirectoryExistsUTF8(dir) then
  begin
    if (not FileExistsUTF8(dir+'cqrtest.local.cfg')) then
      CreateEmptyFile(dir+'cqrtest.local.cfg')
  end
  else begin
    CreateDir(dir);
    CreateEmptyFile(dir+'cqrtest.local.cfg')
  end;
  Result := dir+'cqrtest.local.cfg'
end;

procedure TfrmCommonLocal.SaveWindowPos;
begin
  if (WindowState = wsMaximized) then
     iniLocal.WriteBool(name,'Max',True)
  else begin
    iniLocal.WriteInteger(name,'Height',Height);
    iniLocal.WriteInteger(name,'Width',Width);
    iniLocal.WriteInteger(name,'Top',Top);
    iniLocal.WriteInteger(name,'Left',Left)
  end
end;

procedure TfrmCommonLocal.LoadWindowPos;
begin
  if iniLocal.ReadBool(name,'Max',False) then
    WindowState := wsMaximized
  else begin
    if (BorderStyle <> bsDialog) then
    begin
      Height := iniLocal.ReadInteger(name,'Height',Height);
      Width  := iniLocal.ReadInteger(name,'Width',Width)
    end;
    Top  := iniLocal.ReadInteger(name,'Top',Top);
    Left := iniLocal.ReadInteger(name,'Left',Left)
  end
end;


end.

