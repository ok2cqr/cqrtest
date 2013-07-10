unit frStation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, uCfgStorage;

type

  { TfraStation }

  TfraStation = class(TFrame)
    edtIOTA: TEdit;
    edtCQZ: TEdit;
    edtGrid: TEdit;
    edtZipCode: TEdit;
    edtStreet1: TEdit;
    edtCall: TEdit;
    edtState: TEdit;
    edtName: TEdit;
    edtCity: TEdit;
    edtStreet2: TEdit;
    edtITU: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
  private
    { private declarations }
  public
    procedure LoadSettings(ini : TCfgStorage);
    procedure SaveSettings(ini : TCfgStorage);
  end; 

implementation

{$R *.lfm}

procedure TfraStation.LoadSettings(ini : TCfgStorage);
begin
  edtCall.Text    := ini.ReadString('Station','Call','');
  edtName.Text    := ini.ReadString('Station','Name','');
  edtStreet1.Text := ini.ReadString('Station','Street1','');
  edtStreet2.Text := ini.ReadString('Station','Street2','');
  edtCity.Text    := ini.ReadString('Station','City','');
  edtZipCode.Text := ini.ReadString('Station','ZIP','');
  edtState.Text   := ini.ReadString('Station','State','');
  edtGrid.Text    := ini.ReadString('Station','Grid','');
  edtCQZ.Text     := ini.ReadString('Station','CQZ','');
  edtITU.Text     := ini.ReadString('Station','ITU','');
  edtIOTA.Text    := ini.ReadString('Station','IOTA','')
end;

procedure TfraStation.SaveSettings(ini : TCfgStorage);
begin
  ini.WriteString('Station','Call',edtCall.Text);
  ini.WriteString('Station','Name',edtName.Text);
  ini.WriteString('Station','Street1',edtStreet1.Text);
  ini.WriteString('Station','Street2',edtStreet2.Text);
  ini.WriteString('Station','City',edtCity.Text);
  ini.WriteString('Station','ZIP',edtZipCode.Text);
  ini.WriteString('Station','State',edtState.Text);
  ini.WriteString('Station','Grid',edtGrid.Text);
  ini.WriteString('Station','CQZ',edtCQZ.Text);
  ini.WriteString('Station','ITU',edtITU.Text);
  ini.WriteString('Station','IOTA',edtIOTA.Text)
end;

end.

