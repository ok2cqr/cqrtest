unit fGlobalSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Spin, ColorBox;

type

  { TfrmGlobalSettings }

  TfrmGlobalSettings = class(TForm)
    btnCancel: TButton;
    btnFldigiPath: TButton;
    btnFrequencies: TButton;
    btnHelp: TButton;
    btnKeyText: TButton;
    btnOK: TButton;
    cb10m: TCheckBox;
    cb125m: TCheckBox;
    cb12m: TCheckBox;
    cb136kHz: TCheckBox;
    cb13cm: TCheckBox;
    cb15m: TCheckBox;
    cb160m: TCheckBox;
    cb17m: TCheckBox;
    cb1cm: TCheckBox;
    cb20m: TCheckBox;
    cb23cm: TCheckBox;
    cb2m: TCheckBox;
    cb30cm: TCheckBox;
    cb30m: TCheckBox;
    cb3cm: TCheckBox;
    cb40m: TCheckBox;
    cb47GHz: TCheckBox;
    cb4m: TCheckBox;
    cb5cm: TCheckBox;
    cb60m: TCheckBox;
    cb6m: TCheckBox;
    cb70cm: TCheckBox;
    cb76GHz: TCheckBox;
    cb80m: TCheckBox;
    cb8cm: TCheckBox;
    chkAutoSearch: TCheckBox;
    chkAward: TCheckBox;
    chkCallSign: TCheckBox;
    chkClearRIT: TCheckBox;
    chkCont: TCheckBox;
    chkCountry: TCheckBox;
    chkCounty: TCheckBox;
    chkDate: TCheckBox;
    chkDXCC: TCheckBox;
    chkeQSLRcvd: TCheckBox;
    chkeQSLRcvdDate: TCheckBox;
    chkeQSLSent: TCheckBox;
    chkeQSLSentDate: TCheckBox;
    chkFreq: TCheckBox;
    chkIOTA: TCheckBox;
    chkITU: TCheckBox;
    chkLoc: TCheckBox;
    chkLoTWQSLR: TCheckBox;
    chkLoTWQSLRDate: TCheckBox;
    chkLoTWQSLS: TCheckBox;
    chkLoTWQSLSDate: TCheckBox;
    chkMode: TCheckBox;
    chkMyLoc: TCheckBox;
    chkName: TCheckBox;
    chkNewDXCCTables: TCheckBox;
    chkPotSpeed: TCheckBox;
    chkPower: TCheckBox;
    chkQSLRAll: TCheckBox;
    chkQSLRcvdDate: TCheckBox;
    chkQSLSentDate: TCheckBox;
    chkQSL_R: TCheckBox;
    chkQSL_S: TCheckBox;
    chkQSL_VIA: TCheckBox;
    chkQTH: TCheckBox;
    chkR1RunRigCtld: TCheckBox;
    chkR1SendCWR: TCheckBox;
    chkR2RunRigCtld: TCheckBox;
    chkR2SendCWR: TCheckBox;
    chkRemarks: TCheckBox;
    chkRST_R: TCheckBox;
    chkRST_S: TCheckBox;
    chkRunFldigi: TCheckBox;
    chkState: TCheckBox;
    chkTimeOff: TCheckBox;
    chkTimeOn: TCheckBox;
    chkWAZ: TCheckBox;
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
    edtCall: TEdit;
    edtCbPass: TEdit;
    edtCbUser: TEdit;
    edtCWAddress: TEdit;
    edtCWPort: TEdit;
    edtCWSpeed: TSpinEdit;
    edtDefaultFreq: TEdit;
    edtDefaultRST: TEdit;
    edtFldigiPath: TEdit;
    edtLoadFromFldigi: TSpinEdit;
    edtLoc: TEdit;
    edtName: TEdit;
    edtPasswd: TEdit;
    edtPoll1: TEdit;
    edtPoll2: TEdit;
    edtPort: TEdit;
    edtProxy: TEdit;
    edtQTH: TEdit;
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
    edtWinMaxSpeed: TSpinEdit;
    edtWinMinSpeed: TSpinEdit;
    edtWinPort: TEdit;
    edtWinSpeed: TSpinEdit;
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
    Label1: TLabel;
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
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label27: TLabel;
    Label3: TLabel;
    Label4: TLabel;
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
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmGlobalSettings: TfrmGlobalSettings;

implementation

{$R *.lfm}

end.

