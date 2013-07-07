unit uCfgStorage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Unix;

type
  TCfgStorage = class
  private
    ini         : TIniFile;
    crit        : TRTLCriticalSection;
  public
    constructor Create(IniFile : String);
    destructor  Destroy; override;

    function  ReadString(Section, Ident, Default: string): string;
    function  ReadInteger(Section, Ident: string; Default: Longint): Longint;
    function  ReadBool(Section, Ident: string; Default: Boolean): Boolean;
    function  ReadFloat(Section, Ident: string; Default: Double): Double;
    procedure ReadSection(const Section: string; Strings: TStrings);
    procedure ReadSectionRaw(const Section: string; Strings: TStrings);

    procedure WriteString(const Section, Ident, Value: String);
    procedure WriteInteger(const Section, Ident: string; Value: Longint);
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    procedure WriteFloat(const Section, Ident: string; Value: Double);

    procedure DeleteKey(const Section, Ident: String);
    procedure SaveToDisk;
    function  SectionExists(Section : String) : Boolean;
  end;

var
  iniLocal  : TCfgStorage;
  iniGlobal : TCfgStorage;

implementation

constructor TcfgStorage.Create(IniFile : String);
begin
  ini         := TIniFile.Create(IniFile);
  InitCriticalSection(crit)
end;

function TcfgStorage.ReadString(Section, Ident, Default: string): string;
begin
  Result := Default;
  EnterCriticalsection(crit);
  try
    Result := ini.ReadString(Section,Ident,Default)
  finally
    LeaveCriticalsection(crit)
  end
end;

function TcfgStorage.ReadInteger(Section, Ident: string; Default: Longint): Longint;
begin
  Result := Default;
  EnterCriticalsection(crit);
  try
    Result := ini.ReadInteger(Section,Ident,Default)
  finally
    LeaveCriticalsection(crit)
  end
end;

function TcfgStorage.ReadBool(Section, Ident: string; Default: Boolean): Boolean;
begin
  Result := Default;
  EnterCriticalsection(crit);
  try
    Result := ini.ReadBool(Section,Ident,Default)
  finally
    LeaveCriticalsection(crit)
  end
end;

function TcfgStorage.ReadFloat(Section, Ident: string; Default: Double): Double;
begin
  Result := Default;
  EnterCriticalsection(crit);
  try
    Result := ini.ReadFloat(Section,Ident,Default)
  finally
    LeaveCriticalsection(crit)
  end
end;

procedure TcfgStorage.ReadSection(const Section: string; Strings: TStrings);
begin
  EnterCriticalsection(crit);
  try
    ini.ReadSection(Section,Strings)
  finally
    LeaveCriticalsection(crit)
  end
end;

procedure TcfgStorage.ReadSectionRaw(const Section: string; Strings: TStrings);
begin
  EnterCriticalsection(crit);
  try
    ini.ReadSectionRaw(Section,Strings)
  finally
    LeaveCriticalsection(crit)
  end
end;

procedure TcfgStorage.WriteString(const Section, Ident, Value: String);
begin
  EnterCriticalsection(crit);
  try
    ini.WriteString(Section,Ident,Value)
  finally
    LeaveCriticalsection(crit)
  end
end;

procedure TcfgStorage.WriteInteger(const Section, Ident: string; Value: Longint);
begin
  EnterCriticalsection(crit);
  try
    ini.WriteInteger(Section,Ident,Value)
  finally
    LeaveCriticalsection(crit)
  end
end;

procedure TcfgStorage.WriteBool(const Section, Ident: string; Value: Boolean);
begin
  EnterCriticalsection(crit);
  try
    ini.WriteBool(Section,Ident,Value)
  finally
    LeaveCriticalsection(crit)
  end
end;

procedure TcfgStorage.WriteFloat(const Section, Ident: string; Value: Double);
begin
  EnterCriticalsection(crit);
  try
    ini.WriteFloat(Section,Ident,Value)
  finally
    LeaveCriticalsection(crit)
  end
end;

procedure TcfgStorage.DeleteKey(const Section, Ident: String);
begin
  EnterCriticalsection(crit);
  try
    ini.DeleteKey(Section,Ident)
  finally
    LeaveCriticalsection(crit)
  end
end;

procedure TcfgStorage.SaveToDisk;
begin
  ini.UpdateFile
end;

function TcfgStorage.SectionExists(Section : String) : Boolean;
begin
  Result := False;
  EnterCriticalsection(crit);
  try
    Result := ini.SectionExists(Section)
  finally
    LeaveCriticalsection(crit)
  end
end;

destructor TcfgStorage.Destroy;
begin
  FreeAndNil(ini);
  DoneCriticalsection(crit)
end;

end.

