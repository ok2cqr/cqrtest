unit fAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, fCommonLocal;

type

  { TfrmAbout }

  TfrmAbout = class(TfrmCommonLocal)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

end.

