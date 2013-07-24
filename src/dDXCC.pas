unit dDXCC;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil;

type
  TExplodeArray = Array of String;

type
  TDXCCRef = record
    adif    : Word;
    pref    : String[20];
    name    : String[100];
    cont    : String[6];
    utc     : String[12];
    lat     : String[10];
    longit  : String[10];
    itu     : String[20];
    waz     : String[20];
    deleted : Word
  end;

const
   NotExactly = 0;
   Exactly    = 1;
   ExNoEquals = 2;


type
  TdmDXCC = class(TDataModule)
    Q: TSQLQuery;
    Q1: TSQLQuery;
    qDXCCRef: TSQLQuery;
    trQ: TSQLTransaction;
    trQ1: TSQLTransaction;
    trDXCCRef: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    csDXCC         : TRTLCriticalSection;
    DXCCRefArray   : Array of TDXCCRef;
    DXCCDelArray   : Array of Integer;
    AmbiguousArray : Array of String;
    ExceptionArray : Array of String;

    function  WhatSearch(call : String; date : TDateTime; var AlreadyFound : Boolean;var ADIF : Integer) : String;
    function  FindCountry(call : String; date : TDateTime; var ADIF : Integer; Precision : Integer = NotExactly) : Boolean; overload;
    function  FindCountry(call : String; date : TDateTime; var pfx, country,
              cont, ITU, WAZ, offset, lat, long : String; var ADIF : Integer; Precision : Integer = NotExactly) : Boolean;
    function  Explode(const cSeparator, vString: String): TExplodeArray;
    function  DateToDDXCCDate(date : TDateTime) : String;
  public
    function  AdifFromPfx(pfx : String) : Word;
    function  PfxFromADIF(adif : Word) : String;
    function  IsException(call : String) : Boolean;
    function  DXCCCount : Integer;
    function  IsAmbiguous(call : String) : Boolean;
    function  IsPrefix(pref : String; Date : TDateTime) : Boolean;
    function  GetCont(call : String; Date : TDateTime) : String;
    function  id_country(call: string; date : TDateTime; var pfx, cont, country, WAZ,
                                offset, ITU, lat, long: string) : Word; overload;
    function  id_country(call : String; date : TDateTime; var pfx,country : String) : Word; overload;
    function  id_country(call : String; date : TDateTime) : String; overload;

    procedure ReloadDXCCTables;
    procedure LoadDXCCRefArray;
    procedure LoadAmbiguousArray;
    procedure LoadExceptionArray;
  end;

var
  dmDXCC: TdmDXCC;

implementation

uses dData, znacmech;

type Tchyb1 = object(Tchyby) // podedim objekt a prepisu "hlaseni"
       //procedure hlaseni(vzkaz,kdo:string);virtual;
     end;
     Pchyb1=^Tchyb1;

var
  uhej   : Pseznam;
  sez1   : Pseznam;
  chy1   : Pchyb1;
  sez2   : Pseznam;

{ TdmDXCC }

procedure TdmDXCC.DataModuleCreate(Sender: TObject);
var
  i : Integer;
begin
  for i:=0 to ComponentCount-1 do
  begin
    if Components[i] is TSQLQuery then
      (Components[i] as TSQLQuery).DataBase := dmData.DxccCon;
    if Components[i] is TSQLTransaction then
      (Components[i] as TSQLTransaction).DataBase := dmData.DxccCon
  end;
  InitCriticalSection(csDXCC);

  chy1 := new(Pchyb1,init);
  sez1 := new(Pseznam,init(dmData.AppHomeDir + 'dxcc_data/country.tab',chy1));
  uhej := sez1;
  sez2 := new(Pseznam,init(dmData.AppHomeDir + 'dxcc_data/country_del.tab',chy1))
end;

function TdmDXCC.id_country(call : String; Date : TDateTime) : String;
var
  cont, WAZ, posun, ITU, lat, long, pfx, country: string;
begin
  EnterCriticalsection(csDXCC);
  try
    cont := '';WAZ := '';posun := '';ITU := '';lat := '';long := '';
    country := '';pfx :='';
    Result := DXCCRefArray[id_country(call,date,pfx,country,cont,itu,waz,posun,lat,long)].pref
  finally
    LeaveCriticalsection(csDXCC)
  end
end;

function TdmDXCC.id_country(call : String; Date : TDateTime; var pfx,country : String) : Word;
var
  cont, WAZ, posun, ITU, lat, long: string;
begin
  EnterCriticalsection(csDXCC);
  try
    cont := '';WAZ := '';posun := '';ITU := '';lat := '';long := '';
    Result := id_country(call,date,pfx,country,cont,itu,waz,posun,lat,long)
  finally
    LeaveCriticalsection(csDXCC)
  end
end;

function TdmDXCC.GetCont(call : String; Date : TDateTime) : String;
var
  cont, WAZ, posun, ITU, lat, long, country, pfx: string;
begin
  EnterCriticalsection(csDXCC);
  try
    cont := '';WAZ := '';posun := '';ITU := '';lat := '';long := '';
    country := ''; pfx := '';
    id_country(call,date,pfx,country,cont,itu,waz,posun,lat,long);
    Result := Cont
  finally
    LeaveCriticalsection(csDXCC)
  end
end;


function TdmDXCC.id_country(call: string;date : TDateTime; var pfx, cont, country, WAZ,
  offset, ITU, lat, long: string) : Word;
var
  ADIF   : Integer;
  UzNasel : Boolean;
  sdatum : String;
  NoDXCC : Boolean;
  x :longint;
  sZnac : string_mdz;
  sADIF : String;
begin
  EnterCriticalsection(csDXCC);
  try
    if (length(call)=0) then
    begin
      exit;
    end;
    UzNasel := False;
    ADIF := 0;

    sZnac := call;
    sZnac := WhatSearch(call,date,UzNasel,ADIF);
    sDatum  := DateToDDXCCDate(Date);// DateToStr(Datum);
    x := sez2^.najdis_s2(sZnac,sDatum,NotExactly);
    if x <>-1 then
    begin
      country  := sez2^.znacka_popis_ex(x,0);
      ITU      := sez2^.znacka_popis_ex(x,5);
      WAZ      := sez2^.znacka_popis_ex(x,6);
      offset   := sez2^.znacka_popis_ex(x,2);
      lat      := sez2^.znacka_popis_ex(x,3);
      long     := sez2^.znacka_popis_ex(x,4);
      sADIF    := sez2^.znacka_popis_ex(x,11);
      cont     := UpperCase(sez2^.znacka_popis_ex(x,1));
      NoDXCC   := Pos('no DXCC',country) > 0;
      if TryStrToInt(sAdif,ADIF) then
      begin
        if ADIF > 0 then
        begin
          pfx := DXCCRefArray[adif].pref;
          Result := ADIF
        end
        else begin
          if NoDXCC then
            pfx := '#'
          else
            pfx := '!';
          Result := 0
        end
      end
      else
        Result := 0;
      exit
    end
    else begin
      pfx := '!';
      Result := 0
    end;

    x := uhej^.najdis_s2(sZnac,sDatum,NotExactly);
    if x <>-1 then
    begin
      country  := uhej^.znacka_popis_ex(x,0);
      ITU      := uhej^.znacka_popis_ex(x,5);
      WAZ      := uhej^.znacka_popis_ex(x,6);
      offset   := uhej^.znacka_popis_ex(x,2);
      lat      := uhej^.znacka_popis_ex(x,3);
      long     := uhej^.znacka_popis_ex(x,4);
      sADIF    := uhej^.znacka_popis_ex(x,11);
      cont     := UpperCase(uhej^.znacka_popis_ex(x,1));
      NoDXCC   := Pos('no DXCC',country) > 0;
      if TryStrToInt(sAdif,ADIF) then
      begin
        if ADIF > 0 then
        begin
          pfx    := DXCCRefArray[adif].pref;
          Result := ADIF
        end
        else begin
          if NoDXCC then
            pfx := '#'
          else
            pfx := '!';
          Result := 0
        end;
        exit
      end
    end
    else begin
      pfx := '!';
      Result := 0
    end
  finally
    LeaveCriticalsection(csDXCC)
  end
end;


function TdmDXCC.IsPrefix(pref : String; Date : TDateTime) : Boolean;
var
  adif : Integer;
begin
  EnterCriticalsection(csDXCC);
  try
    if FindCountry(pref,Date,adif,Exactly) then
      Result := True
    else
      Result := False
  finally
    LeaveCriticalsection(csDXCC)
  end
end;


function TdmDXCC.IsAmbiguous(call : String) : Boolean;
var
  i : Integer;
begin
  EnterCriticalsection(csDXCC);
  try
    Result := False;
    if Pos('/',call) < 1 then
    begin
      for i:=0 to Length(AmbiguousArray)-1 do
      begin
        if Pos(AmbiguousArray[i],call) = 1 then
        begin
          Result := True;
          Break
        end
      end
    end
    else begin
      if Length(call) < 4 then
        exit;
      call := call[1] + call[2] + '/' + copy(call,pos('/',call)+1,1);
      for i:=0 to Length(AmbiguousArray)-1 do
      begin
        if AmbiguousArray[i] = call then
        begin
          Result := True;
          Break
        end
      end
    end
  finally
    LeaveCriticalsection(csDXCC)
  end
end;

function TdmDXCC.DXCCCount : Integer;
begin
  EnterCriticalsection(csDXCC);
  try
    dmData.Q.Close;
    if dmData.trQ.Active then
      dmData.trQ.Rollback;
    Q.SQL.Text := 'select count(*) from (select distinct adif from cqrtest_main where adif <> 0) as foo ';
    trQ.StartTransaction;
    try
      Q.Open;
      Result := Q.Fields[0].AsInteger
    finally
      Q.Close;
      trQ.Rollback
    end
  finally
    LeaveCriticalsection(csDXCC)
  end
end;

function TdmDXCC.IsException(call : String) : Boolean;

  function IsString(call : String) : Boolean;
  var
    i : Integer;
  begin
    Result := True;
    for i:=1 to Length(call) do
    begin
      if (call[i] in ['0'..'9']) then
      begin
        Result := False;
        break
      end
    end
  end;

var
  y : Integer;
begin
  EnterCriticalsection(csDXCC);
  try
    Result := False;
    for y:=0 to Length(ExceptionArray)-1 do
    begin
      if ExceptionArray[y] = call then
      begin
        Result := True;
        Break
      end
    end;
    if (call = 'QRP') or (call='QRPP') or (call='P') then
      Result := True;
    if (IsString(call) and (Length(call) > 3)) then
      Result := True
  finally
    LeaveCriticalsection(csDXCC)
  end
end;

procedure TdmDXCC.ReloadDXCCTables;
begin
  dispose(sez1,done);
  dispose(sez2,done);

  chy1 := new(Pchyb1,init);
  sez1 := new(Pseznam,init(dmData.AppHomeDir + 'dxcc_data/country.tab',chy1));
  uhej := sez1;
  sez2 := new(Pseznam,init(dmData.AppHomeDir + 'dxcc_data/country_del.tab',chy1));
  LoadDXCCRefArray
end;

procedure TdmDXCC.LoadDXCCRefArray;
var
  adif : Integer;
begin
  if trQ.Active then
    trQ.Rollback;
  Q.SQL.Text := 'SELECT * FROM cqrtest_common.dxcc_ref ORDER BY ADIF';
  try
    trQ.StartTransaction;
    Q.Open;
    Q.Last;
    SetLength(DXCCRefArray,StrToInt(Q.FieldByName('adif').AsString)+1);
    SetLength(DXCCDelArray,0);
    DXCCRefArray[0].adif := 0;
    DXCCRefArray[0].pref := '';
    Q.First;
    while not Q.Eof do
    begin
      adif := StrToInt(Q.FieldByName('adif').AsString);
      DXCCRefArray[adif].adif    := adif;
      DXCCRefArray[adif].pref    := Q.FieldByName('pref').AsString;
      DXCCRefArray[adif].name    := Q.FieldByName('name').AsString;
      DXCCRefArray[adif].cont    := Q.FieldByName('cont').AsString;
      DXCCRefArray[adif].utc     := Q.FieldByName('utc').AsString;
      DXCCRefArray[adif].lat     := Q.FieldByName('lat').AsString;
      DXCCRefArray[adif].longit  := Q.FieldByName('longit').AsString;
      DXCCRefArray[adif].itu     := Q.FieldByName('itu').AsString;
      DXCCRefArray[adif].waz     := Q.FieldByName('waz').AsString;
      DXCCRefArray[adif].deleted := Q.FieldByName('deleted').AsInteger;
      if DXCCRefArray[adif].deleted > 0 then
      begin
        SetLength(DXCCDelArray,Length(DXCCDelArray)+1);
        DXCCDelArray[Length(DXCCDelArray)-1] := adif
      end;
      Q.Next
    end;
  finally
    Q.Close;
    trQ.Rollback
  end
end;


procedure TdmDXCC.LoadAmbiguousArray;
var
  f    : TextFile;
  s    : String;
begin
  SetLength(AmbiguousArray,0);
  AssignFile(f,dmData.AppHomeDir+'dxcc_data'+PathDelim+'ambiguous.tab');
  Reset(f);
  while not Eof(f) do
  begin
    ReadLn(f,s);
    //file has only a few lines so there is no need to SetLength in higher blocks
    SetLength(AmbiguousArray,Length(AmbiguousArray)+1);
    AmbiguousArray[Length(AmbiguousArray)-1]:=s
  end;
  CloseFile(f)
end;

procedure TdmDXCC.LoadExceptionArray;
var
  f    : TextFile;
  s    : String;
begin
  SetLength(ExceptionArray,0);
  AssignFile(f,dmData.AppHomeDir+'dxcc_data'+PathDelim+'exceptions.tab');
  Reset(f);
  while not Eof(f) do
  begin
    ReadLn(f,s);
    //file has only a few lines so there is no need to SetLength in higher blocks
    SetLength(ExceptionArray,Length(ExceptionArray)+1);
    ExceptionArray[Length(ExceptionArray)-1]:=s
  end;
  CloseFile(f)
end;


function TdmDXCC.AdifFromPfx(pfx : String) : Word;
var
  i : Integer;
begin
  EnterCriticalsection(csDXCC);
  try
    Result := 0;
    for i:=0 to Length(DXCCRefArray)-1 do
    begin
      if DXCCRefArray[i].pref = pfx then
      begin
        Result := DXCCRefArray[i].adif;
        exit
      end
    end
  finally
    LeaveCriticalsection(csDXCC)
  end
end;

function TdmDXCC.PfxFromADIF(adif : Word) : String;
begin
  EnterCriticalsection(csDXCC);
  try
    Result := DXCCRefArray[adif].pref
  finally
    LeaveCriticalsection(csDXCC)
  end
end;

function TdmDXCC.Explode(const cSeparator, vString: String): TExplodeArray;
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


function TdmDXCC.FindCountry(call : String; date : TDateTime; var pfx, country, cont, ITU, WAZ, offset,
                             lat, long : String; var ADIF : Integer; Precision : Integer = NotExactly) : Boolean;

   function Datumek(sdatum : String) : TDateTime;
   var
     tmp : TExplodeArray;
   begin
     tmp    := Explode('.',sdatum);
     Result := EncodeDate(StrToInt(tmp[2]),StrToInt(tmp[1]),strToInt(tmp[0]));
   end;

var
  sZnac  : string_mdz;
  sADIF  : String;
  sdatum : String;
  x      : LongInt;
begin
  Result := False;
  sZnac  := call;
  sDatum  := DateToDDXCCDate(date);
  x := sez2^.najdis_s2(sZnac,sDatum,Precision);
  if x <>-1 then
  begin
    country  := sez2^.znacka_popis_ex(x,0);
    ITU      := sez2^.znacka_popis_ex(x,5);
    WAZ      := sez2^.znacka_popis_ex(x,6);
    offset   := sez2^.znacka_popis_ex(x,2);
    lat      := sez2^.znacka_popis_ex(x,3);
    long     := sez2^.znacka_popis_ex(x,4);
    sADIF    := sez2^.znacka_popis_ex(x,11);
    cont     := UpperCase(sez2^.znacka_popis_ex(x,1));
    Result   := True;
    if not TryStrToInt(sAdif,ADIF) then
      ADIF := 0;
    exit
  end
  else begin
    pfx := '!'
  end;

  x := uhej^.najdis_s2(sZnac,sDatum,Precision);
  if x <>-1 then
  begin
    country  := uhej^.znacka_popis_ex(x,0);
    ITU      := uhej^.znacka_popis_ex(x,5);
    WAZ      := uhej^.znacka_popis_ex(x,6);
    offset   := uhej^.znacka_popis_ex(x,2);
    lat      := uhej^.znacka_popis_ex(x,3);
    long     := uhej^.znacka_popis_ex(x,4);
    sADIF    := uhej^.znacka_popis_ex(x,11);
    cont     := UpperCase(uhej^.znacka_popis_ex(x,1));
    Result   := True;
    if not TryStrToInt(sAdif,ADIF) then
      ADIF := 0
  end
  else begin
    pfx := '!'
  end
end;

function TdmDXCC.FindCountry(call : String; date : TDateTime; var ADIF : Integer;precision : Integer = NotExactly) : Boolean;
var
  pfx,cont,country,itu,waz,posun,lat,long : String;
begin
  cont := '';WAZ := '';posun := '';ITU := '';lat := '';long := '';pfx := '';
  Country := '';
  Result := FindCountry(call,date,pfx,cont,country,itu,waz,
            posun,lat,long,adif,precision)
end;

function TdmDXCC.WhatSearch(call : String; date : TDateTime; var AlreadyFound : Boolean;var ADIF : Integer) : String;
var
  Pole  : TExplodeArray;
  pocet : Integer;
  pred_lomitkem : String;
  za_lomitkem   : String;
  mezi_lomitky  : String;
  tmp : Integer;
begin
  tmp := 0;
  Result := call;
  if pos('/',call) > 0 then
  begin
    if FindCountry(call,date,adif,Exactly) then
    begin
      Result       := call;
      AlreadyFound := True;
      exit
    end;

    SetLength(pole,0);
    pole  := Explode('/',call);
    pocet := Length(pole)-1;
    case pocet of
      1: begin
           pred_lomitkem := pole[0];
           za_lomitkem   := pole[1];
           if ((TryStrToInt(za_lomitkem,tmp)) and (Length(za_lomitkem)>1)) then
           begin
             Result := pred_lomitkem;
             exit
           end;

           if (Length(pred_lomitkem) = 0) then
           begin
             Result := za_lomitkem;
             exit
           end;
           if (Length(za_lomitkem) = 0) then
           begin
             Result := pred_lomitkem;
             exit
           end;
           if (((za_lomitkem[1]='M') and (za_lomitkem[2]='M')) or (za_lomitkem='AM')) then //nevim kde je
           begin
             Result := '?';
             exit
           end;
           if (length(za_lomitkem) = 1) then
           begin
             if (((za_lomitkem[1] = 'M') or (za_lomitkem[1] = 'P')) and (Pos('LU',pred_lomitkem) <> 1)) then
             begin
               Result := pred_lomitkem;
               exit
             end;
             if (za_lomitkem[1] in ['0'..'9']) then   //SP2AD/1
             begin
               if (((pred_lomitkem[1] = 'A') and (pred_lomitkem[2] in ['A'..'L']))  or
                  (pred_lomitkem[1] = 'K') or (pred_lomitkem[1] = 'W') or  (pred_lomitkem[1] = 'N'))   then  //KL7AA/1 = W1
                 Result := 'W'+za_lomitkem
               else begin
                 pred_lomitkem[3] := za_lomitkem[1];
                 Result := pred_lomitkem;//Result := copy(pred_lomitkem,1,3);
               end;
             end
             else begin
               if ((za_lomitkem[1] in ['A'..'D','E','H','J','L'..'V','X'..'Z'])) then //pokud je za lomitkem jen pismeno,
               begin                                    //nesmime zapomenout na chudaky Argentince
                 if (Pos('LU',pred_lomitkem) = 1) or (Pos('LW',pred_lomitkem) = 1) or
                 (Pos('AY',pred_lomitkem) = 1) or (Pos('AZ',pred_lomitkem) = 1) or
                 (Pos('LO',pred_lomitkem) = 1) or (Pos('LP',pred_lomitkem) = 1) or
                 (Pos('LQ',pred_lomitkem) = 1) or (Pos('LR',pred_lomitkem) = 1) or
                 (Pos('LS',pred_lomitkem) = 1) or (Pos('LT',pred_lomitkem) = 1) or
                 (Pos('LV',pred_lomitkem) = 1) then
                 begin
                   pred_lomitkem[4] := za_lomitkem[1];
                   Result := pred_lomitkem;
                   exit
                 end
                 else                 //pokud to neni chudak Argentinec, nechame znacku napokoji
                   Result := call
               end
               else begin
                 AlreadyFound := True;
                 Result       := za_lomitkem
               end;
               if FindCountry(copy(pred_lomitkem,1,2)+'/'+za_lomitkem,date,ADIF) then
               begin
                 AlreadyFound := True;
                 Result       := copy(pred_lomitkem,1,2)+'/'+za_lomitkem;
                 exit
               end
             end
           end
           else begin //za lomitkem je vic jak jedno pismenko
            if IsException(za_lomitkem) then
               Result := pred_lomitkem
             else begin
               if Length(za_lomitkem) >= Length(pred_lomitkem) then
               begin
                 if not FindCountry(pred_lomitkem,date,ADIF,ExNoEquals) then
                 begin
                   Result       := za_lomitkem;
                   AlreadyFound := True;
                   exit
                 end
                 else begin
                   Result  := pred_lomitkem;
                   exit
                 end
               end
               else begin  //pred lomitkem je to delsi nebo rovno
                 if not FindCountry(za_lomitkem,date,ADIF,ExNoEquals) then
                 begin
                   Result       := pred_lomitkem;
                   AlreadyFound := True;
                   exit
                 end
                 else begin
                   Result       := za_lomitkem;
                   AlreadyFound := True;
                   exit
                 end
               end
             end
           end
         end; // 1 slash

      2: begin
           pred_lomitkem := pole[0];
           mezi_lomitky  := pole[1];
           za_lomitkem   := pole[2];
           if Length(za_lomitkem) = 0 then
           begin
             Result := pred_lomitkem;
             exit
           end;
           if (((za_lomitkem[1]='M') and (za_lomitkem[2]='M')) or (za_lomitkem='AM')) then //nevim kde je
           begin
             Result := '?';
             exit
           end;

           if Length(mezi_lomitky) > 0 then
           begin
             if (mezi_lomitky[1] in ['0'..'9']) then
             begin
               if (((pred_lomitkem[1] = 'A') and (pred_lomitkem[2] in ['A'..'L']))  or
                  (pred_lomitkem[1] = 'K') or (pred_lomitkem[1] = 'W'))   then  //KL7AA/1 = W1
                   Result := 'W'+mezi_lomitky
               else begin
                 if pred_lomitkem[2] in ['0'..'9'] then //RA1AAA/2/M
                   pred_lomitkem[2] := mezi_lomitky[1]
                 else
                   pred_lomitkem[3] := mezi_lomitky[1];
                   Result := pred_lomitkem;
                 exit;
               end;
             end;
           end;

           if ((length(za_lomitkem) = 1) and (za_lomitkem[1] in ['A'..'Z'])) then
           begin
             if FindCountry(pred_lomitkem + '/'+za_lomitkem,date,ADIF) then
             begin
               Result       := pred_lomitkem + '/'+za_lomitkem;
               AlreadyFound := True
             end
             else begin
               Result := pred_lomitkem
             end
           end
           else begin
             if ((length(za_lomitkem) = 1) and (za_lomitkem[1] in ['0'..'9'])) then
             begin
               if FindCountry(pred_lomitkem[1]+pred_lomitkem[2]+za_lomitkem,date, ADIF) then //ZL1AMO/C
               begin
                 Result       := pred_lomitkem[1]+pred_lomitkem[2]+za_lomitkem;
                 AlreadyFound := True
               end
               else
                 Result := pred_lomitkem
             end
             else
               Result := pred_lomitkem
           end
         end // 2 slashes
    end //case
  end
end;

function TdmDXCC.DateToDDXCCDate(date : TDateTime) : String;
var
  d,m,y : Word;
  sd,sm : String;
begin
  DecodeDate(date,y,m,d);
  if d < 10 then
    sd := '0'+IntToStr(d)
  else
    sd := IntToStr(d);
  if m < 10 then
    sm := '0'+IntToStr(m)
  else
    sm := IntToStr(m);
  Result := IntToStr(y) + '/' + sm + '/' + sd
end;

procedure TdmDXCC.DataModuleDestroy(Sender: TObject);
begin
  dispose(sez1,done);
  dispose(sez2,done);
  LeaveCriticalsection(csDXCC)
end;

{$R *.lfm}

end.

