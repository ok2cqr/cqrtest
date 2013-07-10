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
  fraVisibleColumn.LoadSettings(iniLocal)
end;

end.

