unit fNewQSO;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, fCommonLocal;

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
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmNewQSO: TfrmNewQSO;

implementation

{$R *.lfm}

end.

