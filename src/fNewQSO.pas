unit fNewQSO;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, fCommonLocal;

type

  { TfrmNewQSO }

  TfrmNewQSO = class(TfrmCommonLocal)
    edtCall: TEdit;
    edtExch1: TEdit;
    edtExch2: TEdit;
    edtExch3: TEdit;
    Label1: TLabel;
    lblExch1: TLabel;
    lblExch2: TLabel;
    lblExch3: TLabel;
    Panel3: TPanel;
    pnlCallsign: TPanel;
    pnlExch1: TPanel;
    pnlExch2: TPanel;
    pnlExch3: TPanel;
    sbNewQSO: TStatusBar;
    procedure edtCallChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure CheckDXCCInfo;
    procedure ClearAll;
  public
    { public declarations }
  end; 

var
  frmNewQSO: TfrmNewQSO;

implementation

{$R *.lfm}

uses dDXCC;

{ TfrmNewQSO }

procedure TfrmNewQSO.FormShow(Sender: TObject);
begin
  inherited;
  edtCall.SetFocus
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

procedure TfrmNewQSO.CheckDXCCInfo;
var
  pfx, cont, country, WAZ, offset, ITU, lat, long : String;
begin
  //function TdmDXCC.id_country(call: string;date : TDateTime; var pfx, cont, country, WAZ,
  //  offset, ITU, lat, long: string) : Word;
  dmDXCC.id_country(edtCall.Text, now, pfx, cont, country, WAZ, offset, ITU, lat, long);
  sbNewQSO.Panels[0].Text := country
end;

end.

