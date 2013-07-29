unit fMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ActnList,
  Menus, ComCtrls, fCommonLocal, fBandMap;

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
    acAbout: TAction;
    acDXCluster: TAction;
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
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
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
    procedure acAboutExecute(Sender: TObject);
    procedure acBandMapVFOA1Execute(Sender: TObject);
    procedure acBandMapVFOA2Execute(Sender: TObject);
    procedure acBandMapVFOB1Execute(Sender: TObject);
    procedure acBandMapVFOB2Execute(Sender: TObject);
    procedure acCloseExecute(Sender: TObject);
    procedure acContestSettingsExecute(Sender: TObject);
    procedure acDXClusterExecute(Sender: TObject);
    procedure acGlobalSettingsExecute(Sender: TObject);
    procedure acGrayLineExecute(Sender: TObject);
    procedure acNewQSOWindow1Execute(Sender: TObject);
    procedure acNewQSOWindow2Execute(Sender: TObject);
    procedure acOpenLogExecute(Sender: TObject);
    procedure acQSOListExecute(Sender: TObject);
    procedure acScoreExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure UpdateMenu;
  public
    frmBandMapRig1VfoA : TfrmBandMap;
    frmBandMapRig1VfoB : TfrmBandMap;
    frmBandMapRig2VfoA : TfrmBandMap;
    frmBandMapRig2VfoB : TfrmBandMap;
  end; 

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

uses uCfgStorage, fDBConnect, fGlobalSettings, fAbout, fGrayline, fDXCluster, dData;

{ TfrmMain }

procedure TfrmMain.acCloseExecute(Sender: TObject);
begin
  Close
end;

procedure TfrmMain.acBandMapVFOA1Execute(Sender: TObject);
begin
  frmBandMapRig1VfoA.Caption := iniLocal.ReadString('TRX1', 'Desc','Radio1')+' VFO A';
  frmBandMapRig1VfoA.Show
end;

procedure TfrmMain.acAboutExecute(Sender: TObject);
var
  frmAbout : TfrmAbout;
begin
  frmAbout := TfrmAbout.Create(self);
  try
    frmAbout.ShowModal
  finally
     FreeAndNil(frmAbout)
  end
end;

procedure TfrmMain.acBandMapVFOA2Execute(Sender: TObject);
begin
  frmBandMapRig2VfoA.Caption := iniLocal.ReadString('TRX2', 'Desc','Radio2')+' VFO A';
  frmBandMapRig2VfoA.Show
end;

procedure TfrmMain.acBandMapVFOB1Execute(Sender: TObject);
begin
  frmBandMapRig1VfoB.Caption := iniLocal.ReadString('TRX1', 'Desc','Radio1')+' VFO B';
  frmBandMapRig1VfoB.Show;
end;

procedure TfrmMain.acBandMapVFOB2Execute(Sender: TObject);
begin
  frmBandMapRig2VfoB.Caption := iniLocal.ReadString('TRX2', 'Desc','Radio2')+' VFO B';
  frmBandMapRig2VfoB.Show
end;

procedure TfrmMain.acContestSettingsExecute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acDXClusterExecute(Sender: TObject);
begin
  frmDXCluster.Show
end;

procedure TfrmMain.acGlobalSettingsExecute(Sender: TObject);
var
  frmGlobalSettings : TfrmGlobalSettings;
begin
  frmGlobalSettings := TfrmGlobalSettings.Create(self);
  try
    frmGlobalSettings.ShowModal
  finally
    FreeAndNil(frmGlobalSettings)
  end;
end;

procedure TfrmMain.acGrayLineExecute(Sender: TObject);
begin
  frmGrayline.Show
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
  with TfrmDBConnect.Create(self) do
  try
    ShowModal;
    if ModalResult <> mrOK then
      Application.Terminate
  finally
    Free
  end
end;

procedure TfrmMain.acQSOListExecute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.acScoreExecute(Sender: TObject);
begin
  ShowMessage('Not implemented, yet')
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(iniLocal);
  FreeAndNil(iniGlobal)
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  frmBandMapRig1VfoA := TfrmBandMap.Create(self);
  frmBandMapRig1VfoB := TfrmBandMap.Create(self);
  frmBandMapRig2VfoA := TfrmBandMap.Create(self);
  frmBandMapRig2VfoB := TfrmBandMap.Create(self);
  UpdateMenu
end;

procedure TfrmMain.UpdateMenu;
begin
  acContestSettings.Enabled := dmData.Connected;
  acNewQSOWindow1.Enabled   := dmData.Connected;
  acBandMapVFOA1.Enabled    := dmData.Connected;
  acBandMapVFOB1.Enabled    := dmData.Connected;
  acNewQSOWindow2.Enabled   := dmData.Connected;
  acBandMapVFOA2.Enabled    := dmData.Connected;
  acBandMapVFOB2.Enabled    := dmData.Connected;
  acQSOList.Enabled         := dmData.Connected;
  acScore.Enabled           := dmData.Connected;
  acDXCluster.Enabled       := dmData.Connected
end;

end.

