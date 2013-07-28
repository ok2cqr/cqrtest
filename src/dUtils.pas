unit dUtils; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Unix, process;

type
  TExplodeArray = Array of String;

const
    AllowedChars = ['A'..'Z','a'..'z','0'..'9','/',',','.','?','!',' ',':','|','-','=','+','@','#','*',
                  '%','_','(',')','$'];

type
  TdmUtils = class(TDataModule)
  private
    { private declarations }
  public
    function  GetDateTime(delta : Currency) : TDateTime;
    function  Explode(const cSeparator, vString: String): TExplodeArray;
    function  UnTarFiles(FileName,TargetDir : String) : Boolean;
    function  MyTrim(text : String) : String;

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

function TdmUtils.Explode(const cSeparator, vString: String): TExplodeArray;
var
  i: Integer;
  S: String;
begin
  S := vString;
  SetLength(Result, 0);
  i := 0;
  while Pos(cSeparator, S) > 0 do
  begin
    SetLength(Result, Length(Result) +1);
    Result[i] := Copy(S, 1, Pos(cSeparator, S) -1);
    Inc(i);
    S := Copy(S, Pos(cSeparator, S) + Length(cSeparator), Length(S))
  end;
  SetLength(Result, Length(Result) +1);
  Result[i] := Copy(S, 1, Length(S))
end;

function TdmUtils.UnTarFiles(FileName,TargetDir : String) : Boolean;
var
  AProcess : TProcess;
  dir      : String;
begin
  Result := True;
  dir := GetCurrentDir;
  SetCurrentDir(TargetDir);
  AProcess := TProcess.Create(nil);
  try
    AProcess.CommandLine := 'tar -xvzf '+FileName;
    AProcess.Options := [poNoConsole,poNewProcessGroup,poWaitOnExit];
    DebugMsg('Command line: '+AProcess.CommandLine);
    try
      AProcess.Execute
    except
      Result := False
    end
  finally
    SetCurrentDir(dir);
    AProcess.Free
  end
end;

function TdmUtils.MyTrim(text : String) : String;
var
  i : Integer;
begin
  text := Trim(text);
  Result := '';
  for i:=1 to Length(text) do
  begin
    if (text[i] in AllowedChars) then
     Result := Result + text[i]
  end
end;

end.

