unit dData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, mysql55dyn, mysql55conn,LCLType,
  Forms, process, BaseUnix;

type

  { TdmData }

  TdmData = class(TDataModule)
    dsrLogList: TDatasource;
    qLogList: TSQLQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    fAppHomeDir : String;
    MysqlProcess : TProcess;

    function GetMysqldPath : String;
  public
    MainCon : TMysql55Connection;
    property AppHomeDir : String read fAppHomeDir write fAppHomeDir;

    procedure StartMysqldProcess;
  end;

var
  dmData: TdmData;

implementation

{$R *.lfm}

{ TdmData }


procedure TdmData.StartMysqldProcess;
var
  mysqld : String;
begin
  mysqld := GetMysqldPath;
  MySQLProcess := TProcess.Create(nil);
  MySQLProcess.CommandLine := mysqld+' --defaults-file='+fAppHomeDir+'database/'+'my.cnf'+
                              ' --default-storage-engine=InnoDB --datadir='+fAppHomeDir+'database/'+
                              ' --socket='+fAppHomeDir+'database/sock'+
                              ' --skip-grant-tables --port=65000 --key_buffer_size=32M'+
                              ' --key_buffer_size=4096K';
  MySQLProcess.Execute
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

procedure TdmData.DataModuleCreate(Sender: TObject);
begin
  fAppHomeDir := ExtractFilePath(GetAppConfigFile(False))+'cqrtest'+DirectorySeparator;
  if not DirectoryExistsUTF8(fAppHomeDir+'database') then
    CreateDirUTF8(fAppHomeDir+'database');
  MainCon := TMySQL55Connection.Create(nil);
end;

procedure TdmData.DataModuleDestroy(Sender: TObject);
begin
  MainCon.Close;
  FreeAndNil(MainCon);
  if MysqlProcess.Running then
    fpkill(MysqlProcess.Handle,SIGTERM)
end;

end.

