unit fCommonGlobal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type

  { TfrmCommon }

  TfrmCommonGlobal = class(TForm)
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure SaveWindowPos;
    procedure LoadWindowPos;

    function GetGlobalConfigFile : String;
  public

  end;

var
  frmCommonGlobal: TfrmCommonGlobal;

implementation

{$R *.lfm}

uses uCfgStorage;

procedure TfrmCommonGlobal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveWindowPos
end;

procedure TfrmCommonGlobal.FormCreate(Sender: TObject);
begin
  if (iniLocal = nil) then
  begin
    iniLocal  := TCfgStorage.Create(GetGlobalConfigFile)
  end
end;

procedure TfrmCommonGlobal.FormShow(Sender: TObject);
begin
  LoadWindowPos
end;

function TfrmCommonGlobal.GetGlobalConfigFile : String;
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
    if (not FileExistsUTF8(dir+'cqrtest.global.cfg')) then
      CreateEmptyFile(dir+'cqrtest.global.cfg')
  end
  else begin
    CreateDir(dir);
    CreateEmptyFile(dir+'cqrtest.global.cfg')
  end;
  Result := dir+'cqrtest.global.cfg'
end;

procedure TfrmCommonGlobal.SaveWindowPos;
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

procedure TfrmCommonGlobal.LoadWindowPos;
begin
  if iniLocal.ReadBool(name,'Max',False) then
    WindowState := wsMaximized
  else begin
    if (BorderStyle <> bsDialog) then
    begin
      Height := iniLocal.ReadInteger(name,'Height',100);
      Width  := iniLocal.ReadInteger(name,'Width',500)
    end;
    Top  := iniLocal.ReadInteger(name,'Top',Top);
    Left := iniLocal.ReadInteger(name,'Left',Left)
  end
end;


end.

