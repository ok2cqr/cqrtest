unit fDBConnect;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, DBGrids, LCLType, Menus,fCommonLocal;

type

  { TfrmDBConnect }

  TfrmDBConnect = class(TfrmCommonLocal)
    btnConnect: TButton;
    btnDisconnect: TButton;
    btnNewLog: TButton;
    btnEditLog: TButton;
    btnDeleteLog: TButton;
    btnOpenLog: TButton;
    btnCancel: TButton;
    btnUtils: TButton;
    chkAutoOpen: TCheckBox;
    chkSaveToLocal: TCheckBox;
    chkAutoConn: TCheckBox;
    chkSavePass: TCheckBox;
    dbgrdLogs: TDBGrid;
    edtPass: TEdit;
    edtUser: TEdit;
    edtPort: TEdit;
    edtServer: TEdit;
    grbLogin: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    mnuRepair : TMenuItem;
    MenuItem5 : TMenuItem;
    mnuClearLog: TMenuItem;
    mnuImport: TMenuItem;
    mnuExport: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    popUtils: TPopupMenu;
    tmrAutoConnect: TTimer;
    procedure btnCancelClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDeleteLogClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnEditLogClick(Sender: TObject);
    procedure btnNewLogClick(Sender: TObject);
    procedure btnOpenLogClick(Sender: TObject);
    procedure btnUtilsClick(Sender: TObject);
    procedure chkSavePassChange(Sender: TObject);
    procedure chkSaveToLocalClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuClearLogClick(Sender: TObject);
    procedure mnuRepairClick(Sender : TObject);
    procedure tmrAutoConnectTimer(Sender: TObject);
  private
    AskForDB : Boolean;

    procedure SaveLogin;
    procedure LoadLogin;
    procedure UpdateGridFields;
    procedure EnableButtons;
    procedure DisableButtons;
    procedure OpenDefaultLog;
  public
    OpenFromMenu : Boolean;
  end; 

var
  frmDBConnect: TfrmDBConnect;


implementation

uses dData, uCfgStorage;//, fNewLog;

procedure TfrmDBConnect.EnableButtons;
begin
  btnOpenLog.Enabled   := True;
  btnNewLog.Enabled    := True;
  btnEditLog.Enabled   := True;
  btnDeleteLog.Enabled := True;
  btnUtils.Enabled     := True
end;

procedure TfrmDBConnect.DisableButtons;
begin
  btnOpenLog.Enabled   := False;
  btnNewLog.Enabled    := False;
  btnEditLog.Enabled   := False;
  btnDeleteLog.Enabled := False;
  btnUtils.Enabled     := False
end;

procedure TfrmDBConnect.UpdateGridFields;
begin
  dbgrdLogs.Columns[0].Width       := 50;
  dbgrdLogs.Columns[1].Width       := 180;
  dbgrdLogs.Columns[0].DisplayName := 'Log nr';
  dbgrdLogs.Columns[1].DisplayName := 'Log name'
end;

procedure TfrmDBConnect.SaveLogin;
begin
  if not chkSaveToLocal.Checked then
  begin
    iniLocal.WriteBool('Login','SaveToLocal',False);
    iniLocal.WriteString('Login','Server',edtServer.Text);
    iniLocal.WriteString('Login','Port',edtPort.Text);
    iniLocal.WriteString('Login','User',edtUser.Text);

    if chkSavePass.Checked then
      iniLocal.WriteString('Login','Pass',edtPass.Text)
    else
      iniLocal.WriteString('Login','Pass','');

    iniLocal.WriteBool('Login','SavePass',chkSavePass.Checked);
    iniLocal.WriteBool('Login','AutoConnect',chkAutoConn.Checked)
  end
  else
    iniLocal.WriteBool('Login','SaveToLocal',True);
  iniLocal.SaveToDisk
end;

procedure TfrmDBConnect.LoadLogin;
begin
    if iniLocal.ReadBool('Login','SaveTolocal',True) then
    begin
      edtServer.Text         := '127.0.0.1';
      edtPort.Text           := '65000';
      edtUser.Text           := 'cqrlog';
      edtPass.Text           := 'cqrlog';
      tmrAutoConnect.Enabled := True;
      chkAutoConn.Checked    := False;
      chkSaveToLocal.Checked := True;
      chkSaveToLocalClick(nil)
    end
    else begin
      chkSaveToLocal.Checked := False;
      grbLogin.Visible     := True;
      edtServer.Text       := iniLocal.ReadString('Login','Server','127.0.0.1');
      edtPort.Text         := iniLocal.ReadString('Login','Port','3306');
      edtUser.Text         := iniLocal.ReadString('Login','User','');
      chkSavePass.Checked  := iniLocal.ReadBool('Login','SavePass',False);

        if chkSavePass.Checked then
        edtPass.Text := iniLocal.ReadString('Login','Pass','')
      else
        edtPass.Text := iniLocal.ReadString('Login','Pass','');

        chkAutoConn.Checked := iniLocal.ReadBool('Login','AutoConnect',False);
      chkSavePassChange(nil);
      if (chkAutoConn.Checked) and (chkAutoConn.Enabled) then
        tmrAutoConnect.Enabled := True
    end;
    chkAutoOpen.Checked := iniLocal.ReadBool('Login','AutoOpen',False)
end;

procedure TfrmDBConnect.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveLogin
end;

procedure TfrmDBConnect.FormCreate(Sender: TObject);
begin
  inherited;
  OpenFromMenu := False;
  AskForDB := not iniLocal.ValueExists('Login','SaveToLocal')
end;

procedure TfrmDBConnect.btnConnectClick(Sender: TObject);
begin
  SaveLogin;
  {
  if dmData.OpenConnections(edtServer.Text,edtPort.Text,edtUser.Text,edtPass.Text) then
  begin
    dmData.CheckForDatabases;
    UpdateGridFields;
    EnableButtons;
    OpenDefaultLog
  end
  }
end;

procedure TfrmDBConnect.btnDeleteLogClick(Sender: TObject);
begin
  if dmData.qLogList.Fields[0].AsInteger = 1 then
  begin
    Application.MessageBox('You can not delete the first log!','Info ...',mb_ok +
                          mb_IconInformation);
    exit
  end;
  if Application.MessageBox('Do you really want to delete this log?','Question ...',
                           mb_YesNo + mb_IconQuestion) = idYes then
  begin
    if Application.MessageBox('LOG WILL BE _DELETED_. Are you sure?','Question ...',
                             mb_YesNo + mb_IconQuestion) = idYes then
    begin
      //dmData.DeleteLogDatabase(dmData.qLogList.Fields[0].AsInteger);
      UpdateGridFields
    end
  end
end;

procedure TfrmDBConnect.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;

procedure TfrmDBConnect.btnDisconnectClick(Sender: TObject);
begin
  {
  if dmData.MainCon.Connected then
    dmData.MainCon.Connected := False;
  }
  DisableButtons
end;

procedure TfrmDBConnect.btnEditLogClick(Sender: TObject);
begin
  {
  frmNewLog := TfrmNewLog.Create(nil);
  try
    frmNewLog.Caption := 'Edit existing log ...';
    frmNewLog.edtLogNR.Text   := dmData.qLogList.Fields[0].AsString;
    frmNewLog.edtLogName.Text := dmData.qLogList.Fields[1].AsString;
    frmNewLog.edtLogNR.Enabled := False;
    frmNewLog.ShowModal;
    if frmNewLog.ModalResult = mrOK then
    begin
      dmData.EditDatabaseName(StrToInt(frmNewLog.edtLogNR.Text),
                            frmNewLog.edtLogName.Text);
      UpdateGridFields
    end
  finally
    frmNewLog.Free
  end
  }
end;

procedure TfrmDBConnect.btnNewLogClick(Sender: TObject);
begin
  {
  frmNewLog := TfrmNewLog.Create(nil);
  try
    frmNewLog.Caption := 'New log ...';
    frmNewLog.ShowModal;
    if frmNewLog.ModalResult = mrOK then
    begin
      //if dmData.LogName <> '' then
      //  dmData.CloseDatabases;
      dmData.CreateDatabase(StrToInt(frmNewLog.edtLogNR.Text),
                            frmNewLog.edtLogName.Text);
      UpdateGridFields
    end
  finally
    frmNewLog.Free
  end
  }
end;

procedure TfrmDBConnect.btnOpenLogClick(Sender: TObject);
begin
  iniLocal.WriteBool('Login','AutoOpen',chkAutoOpen.Checked);
  iniLocal.WriteInteger('Login','LastLog',dmData.qLogList.Fields[0].AsInteger);
  if not OpenFromMenu then
  begin
    //dmData.OpenDatabase(dmData.qLogList.Fields[0].AsInteger);
    //dmData.LogName := dmData.qLogList.Fields[1].AsString
  end;
  ModalResult    := mrOK
end;

procedure TfrmDBConnect.btnUtilsClick(Sender: TObject);
var
  p : TPoint;
begin
  p.x := 10;
  p.y := 10;
  p := btnUtils.ClientToScreen(p);
  popUtils.PopUp(p.x, p.y)
end;

procedure TfrmDBConnect.chkSavePassChange(Sender: TObject);
begin
  if chkSavePass.Checked then
    chkAutoConn.Enabled := True
  else
    chkAutoConn.Enabled := False
end;

procedure TfrmDBConnect.chkSaveToLocalClick(Sender: TObject);
begin
  if chkSaveToLocal.Checked then
    grbLogin.Visible := False
  else
    grbLogin.Visible := True
end;

procedure TfrmDBConnect.FormShow(Sender: TObject);
begin
  if iniLocal.ReadBool('Login','SaveTolocal',True) then
    dmData.StartMysqldProcess;
  dbgrdLogs.DataSource := dmData.dsrLogList;
  LoadLogin;
  if OpenFromMenu then
  begin
    UpdateGridFields;
    EnableButtons
  end
end;

procedure TfrmDBConnect.mnuClearLogClick(Sender: TObject);
var
  s : PChar;
begin
  s := 'YOUR ENTIRE LOG WILL BE DELETED!'+LineEnding+LineEnding+
       'Do you want to CANCEL this operation?';
  if Application.MessageBox(s,'Question ...', mb_YesNo + mb_IconQuestion) = idNo then
  begin
    //dmData.TruncateTables(dmData.qLogList.Fields[0].AsInteger);
    ShowMessage('Log is empty')
  end
end;

procedure TfrmDBConnect.mnuRepairClick(Sender : TObject);
begin
  //dmData.RepairTables(dmData.qLogList.Fields[0].AsInteger);
  ShowMessage('Done, tables fixed')
end;

procedure TfrmDBConnect.tmrAutoConnectTimer(Sender: TObject);
begin
  tmrAutoConnect.Enabled := False;
  if AskForDB then
  begin
    if Application.MessageBox('It seems you are trying to run this program for the first time, '+
                              'are you going to save data to local machine?','Question ...',
                              mb_YesNo+mb_IconQuestion) =  idYes then
    begin
      dmData.StartMysqldProcess
    end
    else begin
      chkSaveToLocal.Checked := False;
      chkSaveToLocalClick(nil);
      edtServer.SetFocus
    end
  end;
  if not OpenFromMenu then
    btnConnect.Click;
  if btnOpenLog.Enabled then
    btnOpenLog.SetFocus
end;

procedure TfrmDBConnect.OpenDefaultLog;
begin
  if not inilocal.ReadBool('Login','AutoOpen',False) then
    exit;
  if dmData.qLogList.Locate('log_nr',iniLocal.ReadInteger('Login','LastLog',0),[]) then
    btnOpenLog.Click
end;

initialization
  {$I fDBConnect.lrs}

end.

