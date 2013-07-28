unit dData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, mysql55dyn, mysql55conn,LCLType,
  Forms, process, BaseUnix;

const
  cDB_COMN_VER = 1;

type

  { TdmData }

  TdmData = class(TDataModule)
    dsrDXCluster: TDatasource;
    dsrLogList: TDatasource;
    mQ: TSQLQuery;
    qLogList: TSQLQuery;
    scCommon: TSQLScript;
    Q: TSQLQuery;
    qDXClusters: TSQLQuery;
    trDXClusters: TSQLTransaction;
    trLogList: TSQLTransaction;
    trQ: TSQLTransaction;
    trmQ: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    fAppHomeDir : String;
    MysqlProcess : TProcess;

    function  GetMysqldPath : String;

    procedure PrepareMysqlConfigFile;
    procedure PrepareBandDatabase;
    procedure PrepareDXClusterDatabase;
    procedure PrepareDXCCData;
    procedure PrepareCtyData;
    procedure PrepareDirectories;
  public
    MainCon : TMysql55Connection;
    DxccCon : TMysql55Connection;
    property AppHomeDir : String read fAppHomeDir write fAppHomeDir;

    function  OpenConnections(host,port,user,pass : String) : Boolean;
    function  QueryLocate(qry : TSQLQuery; Column : String; Value : Variant; DisableGrid : Boolean; exatly : Boolean = True) : Boolean;

    procedure StartMysqldProcess;
    procedure CheckForDatabases;
  end;

var
  dmData: TdmData;

implementation

{$R *.lfm}

{ TdmData }

uses dUtils, fImportProgress;

function TdmData.OpenConnections(host,port,user,pass : String) : Boolean;
begin
  Result := True;

  if MainCon.Connected then
    MainCon.Connected := False;
  if DxccCon.Connected then
    DxccCon.Connected := False;

  MainCon.HostName     := host;
  MainCon.port         := StrToInt(port);
  MainCon.UserName     := user;
  MainCon.Password     := pass;
  MainCon.DatabaseName := 'information_schema';

  DxccCon.HostName     := host;
  DxccCon.port         := StrToInt(port);
  DxccCon.UserName     := user;
  DxccCon.Password     := pass;
  DxccCon.DatabaseName := 'information_schema';

  try
    MainCon.Connected := True;
    DxccCon.Connected := True
  except
    on E : Exception do
    begin
      Application.MessageBox(PChar('Error during connection to database: '+E.Message),
                             'Error',mb_ok + mb_IconError);
      Result := False
    end
  end
end;

procedure TdmData.PrepareDirectories;
begin
  //creting directory in $HOME/.config
  if not DirectoryExistsUTF8(fAppHomeDir) then
    CreateDirUTF8(fAppHomeDir);

  if not DirectoryExistsUTF8(fAppHomeDir+'database') then
    CreateDir(fAppHomeDir+'database');

  if not DirectoryExistsUTF8(fAppHomeDir+'images') then
    CreateDirUTF8(fAppHomeDir+'images');

  if not DirectoryExistsUTF8(fAppHomeDir+'dxcc_data') then
    CreateDirUTF8(fAppHomeDir+'dxcc_data');
  if not DirectoryExistsUTF8(fAppHomeDir+'ctyfiles') then
    CreateDirUTF8(fAppHomeDir+'ctyfiles')
end;

procedure TdmData.PrepareCtyData;
var
  s,d : String;
begin
  s := ExpandFileNameUTF8('..'+PathDelim+'share'+PathDelim+'cqrlog'+PathDelim+'ctyfiles'+PathDelim);
  d := fAppHomeDir+'ctyfiles'+PathDelim;

  if not FileExistsUTF8(fAppHomeDir+'ctyfiles'+PathDelim+'AreaOK1RR.tbl') then
  begin
    dmUtils.DebugMsg('');
    dmUtils.DebugMsg('Ctyfiles dir: '+ExpandFileNameUTF8(s));
    dmUtils.DebugMsg('Local ctyfiles dir: '+d);

    CopyFile(s+'AreaOK1RR.tbl',d+'AreaOK1RR.tbl',True);
    CopyFile(s+'CallResolution.tbl',d+'CallResolution.tbl',True);
    CopyFile(s+'Country.tab',d+'Country.tab',True);
    CopyFile(s+'CountryDel.tab',d+'CountryDel.tab',True);
    CopyFile(s+'Ambiguous.tbl',d+'Ambiguous.tbl',True);
    CopyFile(s+'Exceptions.tbl',d+'Exceptions.tbl',True);
    CopyFile(s+'iota.tbl',d+'iota.tbl',True);
    CopyFile(s+'qslmgr.csv',d+'qslmgr.csv',True)
  end;

  {
  if not FileExistsUTF8(fHomeDir+'lotw1.txt') then
    CopyFile(s+'lotw1.txt',fHomeDir+'lotw1.txt',True);
  if not FileExistsUTF8(fHomeDir+'eqsl.txt') then
    CopyFile(s+'eqsl.txt',fHomeDir+'eqsl.txt',True);
  }
  if not FileExistsUTF8(fAppHomeDir+'MASTER.SCP') then
    CopyFile(s+'MASTER.SCP',fAppHomeDir+'MASTER.SCP',True)
end;

procedure TdmData.PrepareDXCCData;
var
  l,ll : TStringList;
begin
  if FileExistsUTF8(fAppHomeDir+'dxcc_data'+PathDelim+'country.tab') then
    exit;
  l  := TStringList.Create;
  ll := TStringList.Create;
  try
    l.Clear;
    ll.Clear;
    ll.LoadFromFile(fAppHomeDir+'ctyfiles'+PathDelim+'Country.tab');
    l.AddStrings(ll);
    ll.LoadFromFile(fAppHomeDir+'ctyfiles'+PathDelim+'CallResolution.tbl');
    l.AddStrings(ll);
    ll.LoadFromFile(fAppHomeDir+'ctyfiles'+PathDelim+'AreaOK1RR.tbl');
    l.AddStrings(ll);
    l.SaveToFile(fAppHomeDir+'dxcc_data'+PathDelim+'country.tab');
    CopyFile(fAppHomeDir+'ctyfiles'+PathDelim+'CountryDel.tab',
             fAppHomeDir+'dxcc_data'+PathDelim+'country_del.tab');
    CopyFile(fAppHomeDir+'ctyfiles'+PathDelim+'Exceptions.tbl',
             fAppHomeDir+'dxcc_data'+PathDelim+'exceptions.tab');
    CopyFile(fAppHomeDir+'ctyfiles'+PathDelim+'Ambiguous.tbl',
             fAppHomeDir+'dxcc_data'+PathDelim+'ambiguous.tab')
  finally
    l.Free;
    ll.Free
  end
end;

procedure TdmData.PrepareBandDatabase;
begin
  trQ.StartTransaction;
  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                 QuotedStr('2190M')+',0.135,0.139,0.135,0.139,0.139)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('160M')+',1.80,2.0,1.838,1.839,1.843)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('80M')+',3.5,3.8,3.580,3.580,3.620)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('60M')+',5.0,5.9,5.2,5.2,5.3)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('40M')+',7.0,7.200,7.035,7.035,7.043)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('30M')+',10.100,10.150,10.140,10.142,10.150)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('20M')+',14.000,14.350,14.070,14.070,14.112)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('17M')+',18.068,18.168,18.095,18.095,18.111)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('15M')+',21.000,21.450,21.070,21.070,21.120)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('12M')+',24.890,24.990,24.915,24.915,24.931)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('10M')+',28.000,30.000,28.070,28.070,28.300)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('6M')+',50.000,52.000,50.110,50.110,50.120)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('4M')+',70.000,71.000,70.150,70.150,70.150)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('2M')+',144.00,146.00,144.110,144.110,144.150)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('1.25M')+',219.00,225.00,221.0,221.0,222.0)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('70CM')+',430.000,440.000,432.100,432.100,433.600)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('33CM')+',902.000,928.000,903.000,903.000,910.000)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('23CM')+',1240.000,1300.000,1245.000,1250.000,1260.000)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('13CM')+',2300,2450,2310,2310,2320)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('9CM')+',3400,3475,3400,3400,3420)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('6CM')+',5650,5850,5670,5670,5675)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('3CM')+',10000,10500,10500,10500,10500)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('1.25CM')+',24000,24250,24240,24250,24250)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('6MM')+',47000,47200,47100,47100,47200)';
  Q.ExecSQL;

  Q.SQL.Text := 'INSERT INTO cqrtest_common.bands (band,b_begin,b_end,cw,rtty,ssb) VALUES (' +
                QuotedStr('4MM')+',77500,84000,77500,81000,81000)';
  Q.ExecSQL;

  trQ.Commit;
  Q.Close
           //band,begin,end,cw,rtty,ssb - cw to, rtty from, ssb from
end;

procedure TdmData.PrepareDXClusterDatabase;
begin
  Q.Close;
  trQ.StartTransaction;
  Q.SQL.Text := 'INSERT INTO dxclusters (description,address,port) ' +
                'VALUES ('+QuotedStr('HamQTH') + ',' + QuotedStr('hamqth.com') +
                ','+QuotedStr('7300')+')';
  dmUtils.DebugMsg(Q.SQL.Text);
  Q.ExecSQL;

  trQ.Commit
end;

procedure TdmData.CheckForDatabases;
var
  Exists : Boolean = False;
begin
  if trmQ.Active then
    trmQ.Rollback;
  mQ.SQL.Clear;
  mQ.SQL.Text := 'select * from tables where table_schema = '+
                  QuotedStr('cqrtest_common');
  trmQ.StartTransaction;
  mQ.Open;
  if mQ.RecordCount > 0 then
    Exists := True;
  mQ.Close;
  trmQ.Rollback;
  if not Exists then
  begin
    trmQ.StartTransaction;
    dmUtils.DebugMsg(scCommon.Script.Text);
    scCommon.ExecuteScript;
    trmQ.Commit;

    trmQ.StartTransaction;
    mQ.Close;
    mQ.SQL.Text := 'insert into db_version (nr) values('+IntToStr(cDB_COMN_VER)+')';
    mQ.ExecSQL;
    trmQ.Commit;

    PrepareBandDatabase;
    PrepareDXClusterDatabase;

    //we must incialize dxcc tables, first
    with TfrmImportProgress.Create(self) do
    try
      lblComment.Caption := 'Importing DXCC data ...';
      Directory  := dmData.AppHomeDir + 'ctyfiles' + PathDelim;
      ImportType := 1;
      ShowModal
    finally
      Free
    end

    //CreateDatabase(1,'Log 001');
  end;
  mQ.SQL.Clear;
  qLogList.Close;
  if trLogList.Active then
    trLogList.Rollback;
  qLogList.SQL.Text := 'SELECT log_nr,log_name FROM cqrtest_common.log_list order by log_nr';
  trLogList.StartTransaction;
  qLogList.Open;
end;


procedure TdmData.StartMysqldProcess;
var
  mysqld : String;
begin
  mysqld := GetMysqldPath;
  PrepareMysqlConfigFile;
  MySQLProcess := TProcess.Create(nil);
  MySQLProcess.CommandLine := mysqld+' --defaults-file='+fAppHomeDir+'database/'+'my.cnf'+
                              ' --default-storage-engine=InnoDB --datadir='+fAppHomeDir+'database/'+
                              ' --socket='+fAppHomeDir+'database/sock'+
                              ' --skip-grant-tables --port=65000 --key_buffer_size=32M'+
                              ' --key_buffer_size=4096K';
  MySQLProcess.Execute;
  sleep(2000)
end;


procedure TdmData.PrepareMysqlConfigFile;
var
  f : TextFile;
begin
  if not FileExistsUTF8(fAppHomeDir+'database'+DirectorySeparator+'my.cnf') then
  begin
    AssignFile(f,fAppHomeDir+'database'+DirectorySeparator+'my.cnf');
    Rewrite(f);
    Writeln(f,'[mysqld]');
    Writeln(f,'performance_schema = Off');
    CloseFile(f)
  end
end;

function TdmData.GetMysqldPath : String;
var
  l : TStringList;
  info : String;
begin
  if FileExistsUTF8('/usr/bin/mysqld') then
    Result := '/usr/bin/mysqld';
  if FileExistsUTF8('/usr/bin/mysqld_safe') then //Fedora
    Result := '/usr/bin/mysqld_safe';
  if FileExistsUTF8('/usr/sbin/mysqld') then //openSUSE
    Result := '/usr/sbin/mysqld';
  if Result = '' then  //don't know where mysqld is, so hopefully will be in  $PATH
    Result := 'mysqld';

  if FileExistsUTF8('/etc/apparmor.d/usr.sbin.mysqld') then
  begin
    l := TStringList.Create;
    try
      l.LoadFromFile('/etc/apparmor.d/usr.sbin.mysqld');
      l.Text := UpperCase(l.Text);
      if Pos(UpperCase('@{HOME}/.config/cqrtest/database/** rwk,'),l.Text) = 0 then
      begin
        info := 'It looks like apparmor is running in your system. CQRTest needs to add this :'+
                LineEnding+
                '@{HOME}/.config/cqrtest/database/** rwk,'+
                LineEnding+
                'into /etc/apparmor.d/usr.sbin.mysqld'+
                LineEnding+
                LineEnding+
                'You can do that by running /usr/share/cqrtest/cqrtest-apparmor-fix or you can add the line '+
                'and restart apparmor manually.'+
                LineEnding+
                LineEnding+
                'Click OK to continue (program may not work correctly) or Cancel and modify the file '+
                'first.';
         if Application.MessageBox(PChar(info),'Information ...',mb_OKCancel+mb_IconInformation) = idCancel then
           Application.Terminate
      end
    finally
      l.Free
    end
  end
end;

function TdmData.QueryLocate(qry : TSQLQuery; Column : String; Value : Variant; DisableGrid : Boolean; exatly : Boolean = True) : Boolean;
//
// Workaround for bug http://mantis.freepascal.org/bug_view_page.php?bug_id=17624
//
begin
  Result := False;
  if DisableGrid then
    qry.DisableControls;
  qry.First;
  try
    while not qry.EOF do
    begin
      if exatly then
      begin
        if UpperCase(qry.FieldByName(Column).AsVariant) = UpperCase(Value) then
        begin
          Result := True;
          break
        end
        else
          qry.Next
      end
      else begin
        if Pos(UpperCase(Value),UpperCase(qry.FieldByName(Column).AsVariant))=1 then
        begin
          Result := True;
          break
        end
        else
          qry.Next
      end
    end
  finally
    if DisableGrid then
      qry.EnableControls
  end
end;


procedure TdmData.DataModuleCreate(Sender: TObject);
var
  i : Integer;
begin
  chdir(ExtractFilePath(ParamStr(0)));

  fAppHomeDir := ExtractFilePath(GetAppConfigFile(False))+'cqrtest'+DirectorySeparator;
  if not DirectoryExistsUTF8(fAppHomeDir+'database') then
    CreateDirUTF8(fAppHomeDir+'database');
  MainCon := TMysql55Connection.Create(nil);
  DxccCon := TMysql55Connection.Create(nil);
  MainCon.KeepConnection := True;
  DxccCon.KeepConnection := True;

  scCommon.DataBase := MainCon;
  scCommon.Transaction := trmQ;

  for i:=0 to ComponentCount-1 do
   begin
     if Components[i] is TSQLQuery then
       (Components[i] as TSQLQuery).DataBase := MainCon;
     if Components[i] is TSQLTransaction then
       (Components[i] as TSQLTransaction).DataBase := MainCon
   end;

  PrepareDirectories;
  PrepareCtyData;
  PrepareDXCCData
end;

procedure TdmData.DataModuleDestroy(Sender: TObject);
begin
  MainCon.Close;
  DxccCon.Close;
  FreeAndNil(MainCon);
  FreeAndNil(DxccCon);
  if MysqlProcess.Running then
    fpkill(MysqlProcess.Handle,SIGTERM)
end;

end.

