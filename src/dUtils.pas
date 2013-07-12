unit dUtils; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Unix;

type
  TdmUtils = class(TDataModule)
  private
    { private declarations }
  public
    function  GetDateTime(delta : Currency) : TDateTime;

    procedure DebugMsg(what : String; Level : Integer=1);
  end; 

var
  dmUtils: TdmUtils;

implementation

{$R *.lfm}

function TdmUtils.GetDateTime(delta : Currency) : TDateTime;
var
  tv: ttimeval;
  res: longint;
begin
  fpgettimeofday(@tv,nil);
  res    := tv.tv_sec;
  Result := (res / 86400) + 25569.0;  // Same line as used in Unixtodatetime
  if delta <> 0 then
    Result :=  Result - (delta/24)
end;

procedure TdmUtils.DebugMsg(what : String; Level : Integer=1);
begin
  Writeln(what)
end;

end.

