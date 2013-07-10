unit frVisibleColumns;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, uCfgStorage;

type

  { TfraVisibleColumns }

  TfraVisibleColumns = class(TFrame)
    chkExchange1: TCheckBox;
    chkCallSign: TCheckBox;
    chkCont: TCheckBox;
    chkDate: TCheckBox;
    chkDXCC: TCheckBox;
    chkExchange2: TCheckBox;
    chkFreq: TCheckBox;
    chkIOTA: TCheckBox;
    chkITU: TCheckBox;
    chkLoc: TCheckBox;
    chkMode: TCheckBox;
    chkMyLoc: TCheckBox;
    chkName: TCheckBox;
    chkPower: TCheckBox;
    chkQTH: TCheckBox;
    chkRST_R: TCheckBox;
    chkRST_S: TCheckBox;
    chkState: TCheckBox;
    chkTimeOn: TCheckBox;
    chkWAZ: TCheckBox;
  private
    { private declarations }
  public
    procedure LoadSettings(ini : TCfgStorage);
    procedure SaveSettings(ini : TCfgStorage);
  end; 

implementation

{$R *.lfm}

procedure TfraVisibleColumns.LoadSettings(ini : TCfgStorage);
begin
  chkDate.Checked      := ini.ReadBool('Columns','Date',True);
  chkTimeOn.Checked    := ini.ReadBool('Columns','Time',True);
  chkCallSign.Checked  := ini.ReadBool('Columns','Call',True);
  chkMode.Checked      := ini.ReadBool('Columns','Mode',True);
  chkFreq.Checked      := ini.ReadBool('Columns','Freq',True);
  chkRST_S.Checked     := ini.ReadBool('Columns','RST_S',True);
  chkRST_R.Checked     := ini.ReadBool('Columns','RST_R',True);
  chkName.Checked      := ini.ReadBool('Columns','Name',False);
  chkQTH.Checked       := ini.ReadBool('Columns','QTH',False);
  chkMyLoc.Checked     := ini.ReadBool('Columns','MyLoc',False);
  chkLoc.Checked       := ini.ReadBool('Columns','Loc',False);
  chkIOTA.Checked      := ini.ReadBool('Columns','IOTA',False);
  chkPower.Checked     := ini.ReadBool('Columns','Power',False);
  chkDXCC.Checked      := ini.ReadBool('Columns','DXCC',False);
  chkWAZ.Checked       := ini.ReadBool('Columns','WAZ',False);
  chkITU.Checked       := ini.ReadBool('Columns','ITU',False);
  chkState.Checked     := ini.ReadBool('Columns','State',False);
  chkCont.Checked      := ini.ReadBool('Columns','Continent',False);
  chkExchange1.Checked := ini.ReadBool('Columns','Exchange1',True);
  chkExchange2.Checked := ini.ReadBool('Columns','Exchange2',False)
end;

procedure TfraVisibleColumns.SaveSettings(ini : TCfgStorage);
begin
  ini.WriteBool('Columns','Date',chkDate.Checked);
  ini.WriteBool('Columns','Time',chkTimeOn.Checked);
  ini.WriteBool('Columns','Call',chkCallSign.Checked);
  ini.WriteBool('Columns','Mode',chkMode.Checked);
  ini.WriteBool('Columns','Freq',chkFreq.Checked);
  ini.WriteBool('Columns','RST_S',chkRST_S.Checked);
  ini.WriteBool('Columns','RST_R',chkRST_R.Checked);
  ini.WriteBool('Columns','Name',chkName.Checked);
  ini.WriteBool('Columns','QTH',chkQTH.Checked);
  ini.WriteBool('Columns','MyLoc',chkMyLoc.Checked);
  ini.WriteBool('Columns','Loc',chkLoc.Checked);
  ini.WriteBool('Columns','IOTA',chkIOTA.Checked);
  ini.WriteBool('Columns','Power',chkPower.Checked);
  ini.WriteBool('Columns','DXCC',chkDXCC.Checked);
  ini.WriteBool('Columns','WAZ',chkWAZ.Checked);
  ini.WriteBool('Columns','ITU',chkITU.Checked);
  ini.WriteBool('Columns','State',chkState.Checked);
  ini.WriteBool('Columns','Continent',chkCont.Checked);
  ini.WriteBool('Columns','Exchange1',chkExchange1.Checked);
  ini.WriteBool('Columns','Exchange2',chkExchange2.Checked)
end;

end.

