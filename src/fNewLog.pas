unit fNewLog;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLType, fCommonLocal;

type

  { TfrmNewLog }

  TfrmNewLog = class(TfrmCommonLocal)
    btnOK: TButton;
    Button2: TButton;
    edtLogName: TEdit;
    edtLogNR: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmNewLog: TfrmNewLog;

implementation

uses dUtils, dData;

{ TfrmNewLog }

procedure TfrmNewLog.FormShow(Sender: TObject);
begin
  if edtLogNR.Enabled then
    edtLogNR.SetFocus
  else
    edtLogName.SetFocus
end;

procedure TfrmNewLog.btnOKClick(Sender: TObject);
var
  nr : Integer;
begin
  if edtLogNR.Enabled then
  begin
    if not TryStrToInt(edtLogNR.Text,nr) then
    begin
      Application.MessageBox('Please enter correct log number!','Info ...', mb_ok + mb_IconInformation);
      exit
    end;
    if dmData.LogExists(nr) then
    begin
      Application.MessageBox('Log with this number already exists!','Info ...', mb_ok + mb_IconInformation);
      exit
    end
  end;
  ModalResult := mrOK
end;

initialization
  {$I fNewLog.lrs}

end.

