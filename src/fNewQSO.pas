unit fNewQSO;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, fCommonLocal, uRigControl, uCfgStorage, uCWKeying;

const
  C_EMPTY_FREQ = '0.00000';

type
  TRadio = (trRadio1, trRadio2);

type

  { TfrmNewQSO }

  TfrmNewQSO = class(TfrmCommonLocal)
    edtCall: TEdit;
    edtExch1: TEdit;
    edtExch2: TEdit;
    edtExch3: TEdit;
    Label1: TLabel;
    lblCWSpeed: TLabel;
    lblExch1: TLabel;
    lblExch2: TLabel;
    lblExch3: TLabel;
    Panel3: TPanel;
    pnlCallsign: TPanel;
    pnlExch1: TPanel;
    pnlExch2: TPanel;
    pnlExch3: TPanel;
    sbNewQSO: TStatusBar;
    tmrRadio: TTimer;
    procedure edtCallChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure tmrRadioTimer(Sender: TObject);
  private
    radio : TRigControl;

    procedure CheckDXCCInfo;
    procedure ClearAll;
    procedure InicializeRig;
    procedure InitializeCW;
    //procedure SetMode(mode : String;bandwidth :Integer);

    //function  GetActualMode : String;
    //function  GetModeNumber(mode : String) : Cardinal;
  public
    RadioOperated : TRadio;
    CWint         : TCWKeying;
  end; 

var
  frmNewQSO: TfrmNewQSO;

implementation

{$R *.lfm}

uses dDXCC, dUtils;

{ TfrmNewQSO }

procedure TfrmNewQSO.FormShow(Sender: TObject);
begin
  inherited;
  InitializeCW;
  edtCall.SetFocus
end;

procedure TfrmNewQSO.tmrRadioTimer(Sender: TObject);
var
  b : String;
  f : Double;
  m : String;
begin
  if Assigned(radio) then
  begin
    f := radio.GetFreqMHz;
    m := radio.GetModeOnly
  end
  else
    f := 0;
  sbNewQSO.Panels[sbNewQSO.Panels.Count-2].Text := FormatFloat(C_EMPTY_FREQ+';;',f);
  sbNewQSO.Panels[sbNewQSO.Panels.Count-1].Text := m
end;

procedure TfrmNewQSO.ClearAll;
begin
  sbNewQSO.Panels[0].Text := '';
  edtCall.Clear;
  edtExch1.Clear;
  edtExch2.Clear;
  edtExch3.Clear
end;

procedure TfrmNewQSO.edtCallChange(Sender: TObject);
begin
  if (Length(edtCall.Text) > 2) then
    CheckDXCCInfo
end;

procedure TfrmNewQSO.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if Assigned(CWint) then
  begin
    CWint.Close;
    FreeAndNil(CWint)
  end;
  if Assigned(radio) then
    FreeAndNil(radio)
end;

procedure TfrmNewQSO.CheckDXCCInfo;
var
  pfx, cont, country, WAZ, offset, ITU, lat, long : String;
begin
  //function TdmDXCC.id_country(call: string;date : TDateTime; var pfx, cont, country, WAZ,
  //  offset, ITU, lat, long: string) : Word;
  dmDXCC.id_country(edtCall.Text, now, pfx, cont, country, WAZ, offset, ITU, lat, long);
  sbNewQSO.Panels[0].Text := country
end;

procedure TfrmNewQSO.InicializeRig;
var
  n      : String = '';
  id     : Integer = 0;
  Resume : Boolean = False;
begin
  if Assigned(radio) then
  begin
    //Writeln('huu0');
    FreeAndNil(radio);
  end;
  //Writeln('huu1');
  Application.ProcessMessages;
  Sleep(500);
  //Writeln('huu2');

  tmrRadio.Enabled := False;

  if RadioOperated = trRadio1 then
    n := '1'
  else
    n := '2';

  radio := TRigControl.Create;

  //if dmData.DebugLevel>0 then
    radio.DebugMode := True;
  //Writeln('huu3');
  if not TryStrToInt(iniLocal.ReadString('TRX'+n,'model',''),id) then
    radio.RigId := 1
  else
    radio.RigId := id;
  //Writeln('huu4');
  radio.RigCtldPath := iniLocal.ReadString('TRX','RigCtldPath','/usr/bin/rigctld');
  radio.RigCtldArgs := dmUtils.GetRadioRigCtldCommandLine(StrToInt(n));
  radio.RunRigCtld  := iniLocal.ReadBool('TRX'+n,'RunRigCtld',False);
  radio.RigDevice   := iniLocal.ReadString('TRX'+n,'device','');
  radio.RigCtldPort := StrToInt(iniLocal.ReadString('TRX'+n,'RigCtldPort','4532'));
  radio.RigCtldHost := iniLocal.ReadString('TRX'+n,'host','localhost');
  radio.RigPoll     := StrToInt(iniLocal.ReadString('TRX'+n,'poll','500'));
  radio.RigSendCWR  := iniLocal.ReadBool('TRX'+n,'CWR',False);

  tmrRadio.Interval := radio.RigPoll;
  tmrRadio.Enabled  := True;
  if not radio.Connected then
  begin
    //Writeln('huu5');
    FreeAndNil(radio)
  end
end;

procedure TfrmNewQSO.InitializeCW;
begin
  if Assigned(CWint) then
    FreeAndNil(CWint);

  dmUtils.DebugMsg('CW init');
  CWint := TCWKeying.Create;
  CWint.DebugMode := True;
  if iniLocal.ReadInteger('CW','Type',0) > 0 then
  begin
    if iniLocal.ReadInteger('CW','Type',0) = 1 then
    begin
      CWint.KeyType := ktWinKeyer;
      CWint.Port    := iniLocal.ReadString('CW','wk_port','');
      CWint.Device  := iniLocal.ReadString('CW','wk_port','');
      CWint.Open;
      CWint.SetSpeed(iniLocal.ReadInteger('CW','wk_speed',30));
      lblCWSpeed.Caption := IntToStr(iniLocal.ReadInteger('CW','wk_speed',30)) + ' WPM'
    end
    else begin
      CWint.KeyType := ktCWdaemon;
      CWint.Port    := iniLocal.ReadString('CW','cw_port','');
      CWint.Device  := iniLocal.ReadString('CW','cw_address','');
      CWint.Open;
      CWint.SetSpeed(iniLocal.ReadInteger('CW','cw_speed',30));
      lblCWSpeed.Caption := IntToStr(iniLocal.ReadInteger('CW','cw_speed',30)) + ' WPM'
    end
  end
end;


end.

