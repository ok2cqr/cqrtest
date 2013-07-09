unit dUtils; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil; 

type
  TdmUtils = class(TDataModule)
  private
    { private declarations }
  public
    procedure DebugMsg(what : String; Level : Integer=1);
  end; 

var
  dmUtils: TdmUtils;

implementation

{$R *.lfm}

procedure TdmUtils.DebugMsg(what : String; Level : Integer=1);
begin
  Writeln(what)
end;

end.

