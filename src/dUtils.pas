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

  { TdmUtils }

  TdmUtils = class(TDataModule)
  private
    { private declarations }
  public
    function  GetDateTime(delta : Currency) : TDateTime;
    function  Explode(const cSeparator, vString: String): TExplodeArray;
    function  UnTarFiles(FileName,TargetDir : String) : Boolean;
    function  MyTrim(text : String) : String;
    function  GetBandFromFreq(freq : string;kHz : Boolean = False): String;
    function  GetModeFromFreq(freq : String;kHz : Boolean = False) : String;
    function  GetRadioRigCtldCommandLine(radio : Word) : String;

    procedure DebugMsg(what : String; Level : Integer=1);
    procedure GetRealCoordinates(lat,long : String; var latitude, longitude: Currency);
  end; 

var
  dmUtils: TdmUtils;

implementation

{$R *.lfm}
uses dData, uCfgStorage;

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
  Writeln('DEBUG:',what)
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

function TdmUtils.GetBandFromFreq(freq : string;kHz : Boolean = False): String;
var
  x: Integer;
  band : String;
  f : Currency;
begin
  Result := '';
  band := '';
  if Pos('.',freq) > 0 then
    freq[Pos('.',freq)] := DecimalSeparator;

  if pos(',',freq) > 0 then
    freq[pos(',',freq)] := DecimalSeparator;
  Writeln('*freq:',freq);
  if not TryStrToCurr(freq,f) then
    exit;
  if kHz then f := f/1000;
  x := trunc(f);
  Writeln('kHz:',khz);
  Writeln('**freq:',x);
  case x of
    0 : Band := '2190M';
    1 : Band := '160M';
    3 : band := '80M';
    5 : band := '60M';
    7 : band := '40M';
    10 : band := '30M';
    14 : band := '20M';
    18 : Band := '17M';
    21 : Band := '15M';
    24 : Band := '12M';
    28..30 : Band := '10M';
    50..53 : Band := '6M';
    70..72 : Band := '4M';
    144..149 : Band := '2M';
    219..225 : Band := '1.25M';
    430..440 : band := '70CM';
    900..929 : band := '33CM';
    1240..1300 : Band := '23CM';
    2300..2450 : Band := '13CM';  //12 cm
    3400..3475 : band := '9CM';
    5650..5850 : Band := '6CM';

    10000..10500 : band := '3CM';
    24000..24250 : band := '1.25CM';
    47000..47200 : band := '6MM';
    76000..84000 : band := '4MM';
  end;
  Result := band
end;

function TdmUtils.GetModeFromFreq(freq : String;kHz : Boolean = False) : String; //freq in MHz
var
  Band : String;
  tmp   : Extended;
begin
  try
  Result := '';
  band := GetBandFromFreq(freq, kHz);
  dmData.qBands.Close;
  dmData.qBands.SQL.Text := 'SELECT * FROM cqrtest_common.bands WHERE band = ' + QuotedStr(band);
  if dmData.trBands.Active then  dmData.trBands.Rollback;
  dmData.trBands.StartTransaction;
  try
    dmData.qBands.Open;
    tmp := StrToFloat(freq);
    if kHz then tmp := tmp/1000;
    if dmData.qBands.RecordCount > 0 then
    begin
      if ((tmp >= dmData.qBands.FieldByName('B_BEGIN').AsCurrency) and
         (tmp <= dmData.qBands.FieldByName('CW').AsCurrency)) then
        Result := 'CW'
      else begin
        if ((tmp > dmData.qBands.FieldByName('RTTY').AsCurrency) and
           ( tmp <= dmData.qBands.FieldByName('SSB').AsCurrency)) then
          Result := 'RTTY'
        else begin
          if tmp > 10 then
            Result := 'USB'
          else
            Result := 'LSB'
        end
      end
    end
  finally
    dmData.qBands.Close;
    dmData.trBands.Rollback
  end
  except
     on E : Exception do
      Writeln(E.Message);
  end
end;

procedure TdmUtils.GetRealCoordinates(lat,long : String; var latitude, longitude: Currency);
var
  s,d : String;
begin
  s := lat;
  d := long;
  if ((Length(s)=0) or (Length(d)=0)) then
  begin
    longitude := 0;
    latitude  := 0;
    exit
  end;

  if s[Length(s)] = 'S' then
    s := '-' +s ;
  s := copy(s,1,Length(s)-1);
  if pos('.',s) > 0 then
    s[pos('.',s)] := DecimalSeparator;
  if not TryStrToCurr(s,latitude) then
    latitude := 0;

  if d[Length(d)] = 'W' then
    d := '-' + d ;
  d := copy(d,1,Length(d)-1);
  if pos('.',d) > 0 then
    d[pos('.',d)] := DecimalSeparator;
  if not TryStrToCurr(d,longitude) then
    longitude := 0
end;

function TdmUtils.GetRadioRigCtldCommandLine(radio : Word) : String;
var
  section  : ShortString='';
  arg      : String='';
  set_conf : String = '';
begin
  section := 'TRX'+IntToStr(radio);

  if iniLocal.ReadString(section,'model','') = '' then
  begin
    Result := '';
    exit
  end;

  Result := '-m '+ iniLocal.ReadString(section,'model','') + ' ' +
            '-r '+ iniLocal.ReadString(section,'device','') + ' ' +
            '-t '+ iniLocal.ReadString(section,'RigCtldPort','4532') + ' ';
  Result := Result + iniLocal.ReadString(section,'ExtraRigCtldArgs','') + ' ';

  case iniLocal.ReadInteger(section,'SerialSpeed',0) of
    0 : arg := '';
    1 : arg := '-s 1200 ';
    2 : arg := '-s 2400 ';
    3 : arg := '-s 4800 ';
    4 : arg := '-s 9600 ';
    5 : arg := '-s 144000 ';
    6 : arg := '-s 19200 ';
    7 : arg := '-s 38400 ';
    8 : arg := '-s 57600 ';
    9 : arg := '-s 115200 '
    else
      arg := ''
  end; //case
  Result := Result + arg;

  case iniLocal.ReadInteger(section,'DataBits',0) of
    0 : arg := '';
    1 : arg := 'data_bits=5';
    2 : arg := 'data_bits=6';
    3 : arg := 'data_bits=7';
    4 : arg := 'data_bits=8';
    5 : arg := 'data_bits=9'
    else
      arg := ''
  end; //case
  if arg<>'' then
    set_conf := set_conf+arg+',';

  if iniLocal.ReadInteger(section,'StopBits',0) > 0 then
    set_conf := set_conf+'stop_bits='+IntToStr(iniLocal.ReadInteger(section,'StopBits',0)-1)+',';

  case iniLocal.ReadInteger(section,'Parity',0) of
    0 : arg := '';
    1 : arg := 'parity=None';
    2 : arg := 'parity=Odd';
    3 : arg := 'parity=Even';
    4 : arg := 'parity=Mark';
    5 : arg := 'parity=Space'
    else
      arg := ''
  end; //case
  if arg<>'' then
    set_conf := set_conf+arg+',';

  case iniLocal.ReadInteger(section,'HandShake',0) of
    0 : arg := '';
    1 : arg := 'serial_handshake=None';
    2 : arg := 'serial_handshake=XONXOFF';
    3 : arg := 'serial_handshake=Hardware';
    else
      arg := ''
  end; //case
  if arg<>'' then
    set_conf := set_conf+arg+',';

  case iniLocal.ReadInteger(section,'DTR',0) of
    0 : arg := '';
    1 : arg := 'dtr_state=Unset';
    2 : arg := 'dtr_state=ON';
    3 : arg := 'dtr_state=OFF';
    else
      arg := ''
  end; //case
  if arg<>'' then
    set_conf := set_conf+arg+',';

  case iniLocal.ReadInteger(section,'RTS',0) of
    0 : arg := '';
    1 : arg := 'rts_state=Unset';
    2 : arg := 'rts_state=ON';
    3 : arg := 'rts_state=OFF';
    else
      arg := ''
  end; //case
  if arg<>'' then
    set_conf := set_conf+arg+',';

  if (set_conf<>'') then
  begin
    set_conf := copy(set_conf,1,Length(set_conf)-1);
    Result   := Result + ' --set-conf='+set_conf
  end
end;

end.

