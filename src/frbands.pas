unit frBands;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, uCfgStorage;

type

  { TfraBands }

  TfraBands = class(TFrame)
    chk10m: TCheckBox;
    chk12m: TCheckBox;
    chk15m: TCheckBox;
    chk160m: TCheckBox;
    chk17m: TCheckBox;
    chk20m: TCheckBox;
    chk30m: TCheckBox;
    chk40m: TCheckBox;
    chk60m: TCheckBox;
    chk80m: TCheckBox;
  private
    { private declarations }
  public
    procedure LoadSettings(ini : TCfgStorage);
    procedure SaveSettings(ini : TCfgStorage);
  end;

implementation

{$R *.lfm}

procedure TFraBands.LoadSettings(ini : TCfgStorage);
begin
  chk160m.Checked := ini.ReadBool('Bands','160M',True);
  chk80m.Checked  := ini.ReadBool('Bands','80M',True);
  chk40m.Checked  := ini.ReadBool('Bands','40M',True);
  chk30m.Checked  := ini.ReadBool('Bands','30M',False);
  chk20m.Checked  := ini.ReadBool('Bands','20M',True);
  chk17m.Checked  := ini.ReadBool('Bands','17M',False);
  chk15m.Checked  := ini.ReadBool('Bands','15M',True);
  chk12m.Checked  := ini.ReadBool('Bands','12M',False);
  chk10m.Checked  := ini.ReadBool('Bands','10M',True);
end;

procedure TFraBands.SaveSettings(ini : TCfgStorage);
begin
  ini.WriteBool('Bands','160M',chk160m.Checked);
  ini.WriteBool('Bands','80M',chk80m.Checked);
  ini.WriteBool('Bands','40M',chk40m.Checked);
  ini.WriteBool('Bands','30M',chk30m.Checked);
  ini.WriteBool('Bands','20M',chk20m.Checked);
  ini.WriteBool('Bands','17M',chk17m.Checked);
  ini.WriteBool('Bands','15M',chk15m.Checked);
  ini.WriteBool('Bands','12M',chk12m.Checked);
  ini.WriteBool('Bands','10M',chk10m.Checked)
end;

end.

