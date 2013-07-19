unit fGlobalSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Spin, ColorBox, fCommonLocal, uCfgStorage, frStation,
  frBands, frVisibleColumns;

type

  { TfrmGlobalSettings }

  TfrmGlobalSettings = class(TfrmCommonLocal)
    btnCancel: TButton;
    btnFldigiPath: TButton;
    btnHelp: TButton;
    btnKeyText: TButton;
    btnOK: TButton;
    chkAutoSearch: TCheckBox;
    chkClearRIT: TCheckBox;
    chkNewDXCCTables: TCheckBox;
    chkPotSpeed: TCheckBox;
    chkR1RunRigCtld: TCheckBox;
    chkR1SendCWR: TCheckBox;
    chkR2RunRigCtld: TCheckBox;
    chkR2SendCWR: TCheckBox;
    chkRunFldigi: TCheckBox;
    cmbDataBitsR1: TComboBox;
    cmbDataBitsR2: TComboBox;
    cmbDefaultMode: TComboBox;
    cmbDTRR1: TComboBox;
    cmbDTRR2: TComboBox;
    cmbHanshakeR1: TComboBox;
    cmbHanshakeR2: TComboBox;
    cmbIfaceType: TComboBox;
    cmbParityR1: TComboBox;
    cmbParityR2: TComboBox;
    cmbRTSR1: TComboBox;
    cmbRTSR2: TComboBox;
    cmbSpeedR1: TComboBox;
    cmbSpeedR2: TComboBox;
    cmbStopBitsR1: TComboBox;
    cmbStopBitsR2: TComboBox;
    edtCbPass: TEdit;
    edtCbUser: TEdit;
    edtCWAddress: TEdit;
    edtCWPort: TEdit;
    edtCWSpeed: TSpinEdit;
    edtDefaultFreq: TEdit;
    edtDefaultRST: TEdit;
    edtFldigiPath: TEdit;
    edtGridSquare: TEdit;
    edtLoadFromFldigi: TSpinEdit;
    edtPasswd: TEdit;
    edtPoll1: TEdit;
    edtPoll2: TEdit;
    edtPort: TEdit;
    edtProxy: TEdit;
    edtQTH: TEdit;
    edtQTH1: TEdit;
    edtR1Device: TEdit;
    edtR1Host: TEdit;
    edtR1RigCtldArgs: TEdit;
    edtR1RigCtldPort: TEdit;
    edtR2Device: TEdit;
    edtR2Host: TEdit;
    edtR2RigCtldArgs: TEdit;
    edtR2RigCtldPort: TEdit;
    edtRadio1: TEdit;
    edtRadio2: TEdit;
    edtRigCtldPath: TEdit;
    edtRigID1: TEdit;
    edtRigID2: TEdit;
    edtUser: TEdit;
    edtWAZ: TEdit;
    edtWinMaxSpeed: TSpinEdit;
    edtWinMinSpeed: TSpinEdit;
    edtWinPort: TEdit;
    edtWinSpeed: TSpinEdit;
    fraBand: TfraBands;
    fraStn: TfraStation;
    fraVisibleColumn: TfraVisibleColumns;
    grbSerialR1: TGroupBox;
    grbSerialR2: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox29: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox30: TGroupBox;
    GroupBox31: TGroupBox;
    GroupBox34: TGroupBox;
    GroupBox38: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox40: TGroupBox;
    Label111: TLabel;
    Label112: TLabel;
    Label12: TLabel;
    Label126: TLabel;
    Label127: TLabel;
    Label13: TLabel;
    Label130: TLabel;
    Label131: TLabel;
    Label132: TLabel;
    Label133: TLabel;
    Label134: TLabel;
    Label135: TLabel;
    Label136: TLabel;
    Label137: TLabel;
    Label138: TLabel;
    Label139: TLabel;
    Label14: TLabel;
    Label140: TLabel;
    Label141: TLabel;
    Label142: TLabel;
    Label143: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label27: TLabel;
    Label83: TLabel;
    Label84: TLabel;
    Label85: TLabel;
    Label86: TLabel;
    Label87: TLabel;
    Label88: TLabel;
    Label89: TLabel;
    Label90: TLabel;
    Label91: TLabel;
    Label92: TLabel;
    Label95: TLabel;
    Label96: TLabel;
    Label97: TLabel;
    Label98: TLabel;
    lbPreferences: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    pgPreferences: TPageControl;
    pgTRXControl: TPageControl;
    rbHamQTH: TRadioButton;
    rbQRZ: TRadioButton;
    rgFreqFrom: TRadioGroup;
    rgModeFrom: TRadioGroup;
    rgRSTFrom: TRadioGroup;
    tabBands: TTabSheet;
    tabCallbook: TTabSheet;
    tabCWInterface: TTabSheet;
    tabFldigi1: TTabSheet;
    tabNewQSO: TTabSheet;
    tabProgram: TTabSheet;
    tabStation: TTabSheet;
    tabTRX1: TTabSheet;
    tabTRX2: TTabSheet;
    tabTRXcontrol: TTabSheet;
    tabVisibleColumns: TTabSheet;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmGlobalSettings: TfrmGlobalSettings;

implementation

{$R *.lfm}

{ TfrmGlobalSettings }

procedure TfrmGlobalSettings.FormShow(Sender: TObject);
begin
  inherited;
  edtProxy.Text  := iniLocal.ReadString('Program', 'Proxy', '');
  edtPort.Text   := iniLocal.ReadString('Program', 'Port', '');
  edtUser.Text   := iniLocal.ReadString('Program', 'User', '');
  edtPasswd.Text := iniLocal.ReadString('Program', 'Passwd', '');

  fraStn.LoadSettings(iniLocal);
  fraBand.LoadSettings(iniLocal);
  fraVisibleColumn.LoadSettings(iniLocal);

  edtRigCtldPath.Text     := iniLocal.ReadString('TRX', 'RigCtldPath', '/usr/bin/rigctld');
  edtR1Device.Text        := iniLocal.ReadString('TRX1', 'device', '');
  edtRigID1.Text          := iniLocal.ReadString('TRX1', 'model', '');
  edtPoll1.Text           := iniLocal.ReadString('TRX1', 'poll', '500');
  edtRadio1.Text          := iniLocal.ReadString('TRX1', 'Desc', 'Radio 1');
  chkR1SendCWR.Checked    := iniLocal.ReadBool('TRX1', 'CWR', False);
  edtR1RigCtldPort.Text   := iniLocal.ReadString('TRX1', 'RigCtldPort', '4532');
  edtR1RigCtldArgs.Text   := iniLocal.ReadString('TRX1', 'ExtraRigCtldArgs', '');
  chkR1RunRigCtld.Checked := iniLocal.ReadBool('TRX1', 'RunRigCtld', False);
  edtR1Host.Text          := iniLocal.ReadString('TRX1', 'host', 'localhost');
  cmbSpeedR1.ItemIndex    := iniLocal.ReadInteger('TRX1', 'SerialSpeed', 0);
  cmbDataBitsR1.ItemIndex := iniLocal.ReadInteger('TRX1', 'DataBits', 0);
  cmbStopBitsR1.ItemIndex := iniLocal.ReadInteger('TRX1', 'StopBits', 0);
  cmbParityR1.ItemIndex   := iniLocal.ReadInteger('TRX1', 'Parity', 0);
  cmbHanshakeR1.ItemIndex := iniLocal.ReadInteger('TRX1', 'HandShake', 0);
  cmbDTRR1.ItemIndex      := iniLocal.ReadInteger('TRX1', 'DTR', 0);
  cmbRTSR1.ItemIndex      := iniLocal.ReadInteger('TRX1', 'RTS', 0);
  edtR1Device.Text        := iniLocal.ReadString('TRX2', 'device', '');
  edtRigID1.Text          := iniLocal.ReadString('TRX2', 'model', '');
  edtPoll1.Text           := iniLocal.ReadString('TRX2', 'poll', '500');
  edtRadio1.Text          := iniLocal.ReadString('TRX2', 'Desc', 'Radio 1');
  chkR1SendCWR.Checked    := iniLocal.ReadBool('TRX2', 'CWR', False);
  edtR1RigCtldPort.Text   := iniLocal.ReadString('TRX2', 'RigCtldPort', '4532');
  edtR1RigCtldArgs.Text   := iniLocal.ReadString('TRX2', 'ExtraRigCtldArgs', '');
  chkR1RunRigCtld.Checked := iniLocal.ReadBool('TRX2', 'RunRigCtld', False);
  edtR1Host.Text          := iniLocal.ReadString('TRX2', 'host', 'localhost');
  cmbSpeedR1.ItemIndex    := iniLocal.ReadInteger('TRX2', 'SerialSpeed', 0);
  cmbDataBitsR1.ItemIndex := iniLocal.ReadInteger('TRX2', 'DataBits', 0);
  cmbStopBitsR1.ItemIndex := iniLocal.ReadInteger('TRX2', 'StopBits', 0);
  cmbParityR1.ItemIndex   := iniLocal.ReadInteger('TRX2', 'Parity', 0);
  cmbHanshakeR1.ItemIndex := iniLocal.ReadInteger('TRX2', 'HandShake', 0);
  cmbDTRR1.ItemIndex      := iniLocal.ReadInteger('TRX2', 'DTR', 0);
  cmbRTSR1.ItemIndex      := iniLocal.ReadInteger('TRX2', 'RTS', 0);

  cmbIfaceType.ItemIndex := iniLocal.ReadInteger('CW', 'Type', 0);
  edtWinPort.Text        := iniLocal.ReadString('CW', 'wk_port', '');
  chkPotSpeed.Checked    := iniLocal.ReadBool('CW', 'PotSpeed', False);
  edtWinSpeed.Value      := iniLocal.ReadInteger('CW', 'wk_speed', 30);
  edtCWAddress.Text      := iniLocal.ReadString('CW', 'cw_address', 'localhost');
  edtCWPort.Text         := iniLocal.ReadString('CW', 'cw_port', '6789');
  edtCWSpeed.Value       := iniLocal.ReadInteger('CW', 'cw_speed', 30);
  edtWinMinSpeed.Value   := iniLocal.ReadInteger('CW', 'wk_min', 5);
  edtWinMaxSpeed.Value   := iniLocal.ReadInteger('CW', 'wk_max', 60);

  rgFreqFrom.ItemIndex    := iniLocal.ReadInteger('fldigi', 'freq', 1);
  edtDefaultFreq.Text     := iniLocal.ReadString('fldigi', 'deffreq', '3.600');
  rgModeFrom.ItemIndex    := iniLocal.ReadInteger('fldigi', 'mode', 1);
  cmbDefaultMode.Text     := iniLocal.ReadString('fldigi', 'defmode', 'RTTY');
  edtDefaultRST.Text      := iniLocal.ReadString('fldigi', 'defrst', '599');
  rgRSTFrom.ItemIndex     := iniLocal.ReadInteger('fldigi', 'rst', 0);
  edtLoadFromFldigi.Value := iniLocal.ReadInteger('fldigi', 'interval', 2);
  chkRunFldigi.Checked    := iniLocal.ReadBool('fldigi', 'run', False);
  edtFldigiPath.Text      := iniLocal.ReadString('fldigi', 'path', '');

  edtCbUser.Text   := iniLocal.ReadString('CallBook', 'CBUser', '');
  edtCbPass.Text   := iniLocal.ReadString('CallBook', 'CBPass', '');
  rbHamQTH.Checked := iniLocal.ReadBool('Callbook', 'HamQTH', True);
  rbQRZ.Checked    := iniLocal.ReadBool('Callbook', 'QRZ', False);

  chkAutoSearch.Checked := iniLocal.ReadBool('NewQSO','AutoSearch',False);
  chkClearRIT.Checked   := iniLocal.ReadBool('NewQSO','ClearRit',False)
end;

procedure TfrmGlobalSettings.btnOKClick(Sender: TObject);
begin
  iniLocal.WriteString('Program', 'Proxy',edtProxy.Text);
  iniLocal.WriteString('Program', 'Port',edtPort.Text);
  iniLocal.WriteString('Program', 'User',edtUser.Text);
  iniLocal.WriteString('Program', 'Passwd',edtPasswd.Text);

  fraStn.SaveSettings(iniLocal);
  fraBand.SaveSettings(iniLocal);
  fraVisibleColumn.SaveSettings(iniLocal);

  iniLocal.WriteString('TRX', 'RigCtldPath',edtRigCtldPath.Text);
  iniLocal.WriteString('TRX1', 'device',edtR1Device.Text);
  iniLocal.WriteString('TRX1', 'model',edtRigID1.Text);
  iniLocal.WriteString('TRX1', 'poll', edtPoll1.Text);
  iniLocal.WriteString('TRX1', 'Desc',edtRadio1.Text);
  iniLocal.WriteBool('TRX1', 'CWR', chkR1SendCWR.Checked);
  iniLocal.WriteString('TRX1', 'RigCtldPort',edtR1RigCtldPort.Text);
  iniLocal.WriteString('TRX1', 'ExtraRigCtldArgs',edtR1RigCtldArgs.Text);
  iniLocal.WriteBool('TRX1', 'RunRigCtld',chkR1RunRigCtld.Checked);
  iniLocal.WriteString('TRX1', 'host',edtR1Host.Text);
  iniLocal.WriteInteger('TRX1', 'SerialSpeed',cmbSpeedR1.ItemIndex);
  iniLocal.WriteInteger('TRX1', 'DataBits',cmbDataBitsR1.ItemIndex);
  iniLocal.WriteInteger('TRX1', 'StopBits',cmbStopBitsR1.ItemIndex);
  iniLocal.WriteInteger('TRX1', 'Parity',cmbParityR1.ItemIndex);
  iniLocal.WriteInteger('TRX1', 'HandShake',cmbHanshakeR1.ItemIndex);
  iniLocal.WriteInteger('TRX1', 'DTR',cmbDTRR1.ItemIndex);
  iniLocal.WriteInteger('TRX1', 'RTS',cmbRTSR1.ItemIndex);
  iniLocal.WriteString('TRX2', 'device',edtR1Device.Text);
  iniLocal.WriteString('TRX2', 'model',edtRigID1.Text);
  iniLocal.WriteString('TRX2', 'poll',edtPoll1.Text);
  iniLocal.WriteString('TRX2', 'Desc',edtRadio1.Text);
  iniLocal.WriteBool('TRX2', 'CWR',chkR1SendCWR.Checked);
  iniLocal.WriteString('TRX2', 'RigCtldPort',edtR1RigCtldPort.Text);
  iniLocal.WriteString('TRX2', 'ExtraRigCtldArgs',edtR1RigCtldArgs.Text);
  iniLocal.WriteBool('TRX2', 'RunRigCtld',chkR1RunRigCtld.Checked);
  iniLocal.WriteString('TRX2', 'host',edtR1Host.Text);
  iniLocal.WriteInteger('TRX2', 'SerialSpeed',cmbSpeedR1.ItemIndex);
  iniLocal.WriteInteger('TRX2', 'DataBits',cmbDataBitsR1.ItemIndex);
  iniLocal.WriteInteger('TRX2', 'StopBits',cmbStopBitsR1.ItemIndex);
  iniLocal.WriteInteger('TRX2', 'Parity',cmbParityR1.ItemIndex);
  iniLocal.WriteInteger('TRX2', 'HandShake',cmbHanshakeR1.ItemIndex);
  iniLocal.WriteInteger('TRX2', 'DTR',cmbDTRR1.ItemIndex);
  iniLocal.WriteInteger('TRX2', 'RTS',cmbRTSR1.ItemIndex);

  iniLocal.WriteInteger('CW', 'Type',cmbIfaceType.ItemIndex);
  iniLocal.WriteString('CW', 'wk_port',edtWinPort.Text);
  iniLocal.WriteBool('CW', 'PotSpeed',chkPotSpeed.Checked);
  iniLocal.WriteInteger('CW', 'wk_speed',edtWinSpeed.Value);
  iniLocal.WriteString('CW', 'cw_address',edtCWAddress.Text);
  iniLocal.WriteString('CW', 'cw_port',edtCWPort.Text);
  iniLocal.WriteInteger('CW', 'cw_speed',edtCWSpeed.Value);
  iniLocal.WriteInteger('CW', 'wk_min',Round(edtWinMinSpeed.Value));
  iniLocal.WriteInteger('CW', 'wk_max', Round(edtWinMaxSpeed.Value));

  iniLocal.WriteInteger('fldigi', 'freq',rgFreqFrom.ItemIndex);
  iniLocal.WriteString('fldigi', 'deffreq',edtDefaultFreq.Text);
  iniLocal.WriteInteger('fldigi', 'mode',rgModeFrom.ItemIndex);
  iniLocal.WriteString('fldigi', 'defmode',cmbDefaultMode.Text);
  iniLocal.WriteString('fldigi', 'defrst',edtDefaultRST.Text);
  iniLocal.WriteInteger('fldigi', 'rst',rgRSTFrom.ItemIndex);
  iniLocal.WriteInteger('fldigi', 'interval',Round(edtLoadFromFldigi.Value));
  iniLocal.WriteBool('fldigi', 'run',chkRunFldigi.Checked);
  iniLocal.WriteString('fldigi', 'path',edtFldigiPath.Text);

  iniLocal.WriteString('CallBook', 'CBUser',edtCbUser.Text);
  iniLocal.WriteString('CallBook', 'CBPass',edtCbPass.Text);
  iniLocal.WriteBool('Callbook', 'HamQTH',rbHamQTH.Checked);
  iniLocal.WriteBool('Callbook', 'QRZ',rbQRZ.Checked);

  iniLocal.WriteBool('NewQSO','AutoSearch',chkAutoSearch.Checked);
  iniLocal.WriteBool('NewQSO','ClearRit',chkClearRIT.Checked)
end;

end.

