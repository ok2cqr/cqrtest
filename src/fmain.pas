unit fMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ActnList,
  Menus, ComCtrls, fCommonLocal;

type

  { TfrmMain }

  TfrmMain = class(TfrmCommonLocal)
    acClose: TAction;
    acOpenLog: TAction;
    acGlobalSettings: TAction;
    acContestSettings: TAction;
    acNewQSOWindow1: TAction;
    acNewQSOWindow2: TAction;
    acBandMapVFOA1: TAction;
    acBandMapVFOA2: TAction;
    acBandMapVFOB2: TAction;
    acBandMapVFOB1: TAction;
    acQSOList: TAction;
    acScore: TAction;
    acGrayLine: TAction;
    ActionList1: TActionList;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    mnuRadio2: TMenuItem;
    mnuRado1: TMenuItem;
    mnuMain: TMainMenu;
    StatusBar1: TStatusBar;
    procedure acBandMapVFOA1Execute(Sender: TObject);
    procedure acBandMapVFOA2Execute(Sender: TObject);
    procedure acBandMapVFOB1Execute(Sender: TObject);
    procedure acBandMapVFOB2Execute(Sender: TObject);
    procedure acCloseExecute(Sender: TObject);
    procedure acContestSettingsExecute(Sender: TObject);
    procedure acGlobalSettingsExecute(Sender: TObject);
    procedure acGrayLineExecute(Sender: TObject);
    procedure acNewQSOWindow1Execute(Sender: TObject);
    procedure acNewQSOWindow2Execute(Sender: TObject);
    procedure acOpenLogExecute(Sender: TObject);
    procedure acQSOListExecute(Sender: TObject);
    procedure acScoreExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    { public declarations }
  end; 

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

uses uCfgStorage, fDBConnect;

{ TfrmMain }

procedure TfrmMain.acCloseExecute(Sender: TObject);
begin
  Close
end;

procedure TfrmMain.acBandMapVFOA1Execute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acBandMapVFOA2Execute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acBandMapVFOB1Execute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acBandMapVFOB2Execute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acContestSettingsExecute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acGlobalSettingsExecute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acGrayLineExecute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acNewQSOWindow1Execute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acNewQSOWindow2Execute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acOpenLogExecute(Sender: TObject);
begin
  //
end;

procedure TfrmMain.acQSOListExecute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acScoreExecute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(iniLocal);
  FreeAndNil(iniGlobal)
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  inherited;
  with TfrmDBConnect.Create(self) do
  try
    ShowModal;
    if ModalResult <> mrOK then
      Application.Terminate
  finally
    Free
  end
end;

end.

