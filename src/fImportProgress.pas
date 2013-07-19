(*
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *                                                                         *
 ***************************************************************************
*)


unit fImportProgress;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls,lcltype, synachar, ExtCtrls, httpsend, blcksock, iniFiles, FileUtil;

type

  { TfrmImportProgress }

  TfrmImportProgress = class(TForm)
    lblCount: TLabel;
    lblErrors: TLabel;
    lblComment: TLabel;
    pBarProg: TProgressBar;
    tmrImport: TTimer;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrImportTimer(Sender: TObject);
  private
    running : Boolean;
    FileSize : Int64;
    procedure ImportDXCCTables;
    procedure DownloadDXCCData;
    procedure SockCallBack (Sender: TObject; Reason:  THookSocketReason; const  Value: string);

  public
    ImportType : Integer;
    FileName   : String;
    Directory  : String;
    CloseAfImport : Boolean;
  end;

var
  frmImportProgress: TfrmImportProgress; 

implementation

{ TfrmImportProgress }

uses dData, dUtils, dDXCC, uCfgStorage;

procedure TfrmImportProgress.FormActivate(Sender: TObject);
begin
  tmrImport.Enabled := False;
  if not running then
  begin
    running := True;
    case ImportType of
      1 : ImportDXCCTables;
      3 : DownloadDXCCData;
    end // case
  end
end;

procedure TfrmImportProgress.FormCreate(Sender: TObject);
begin
  CloseAfImport := False;
  FileSize      := 0
end;

procedure TfrmImportProgress.FormDestroy(Sender: TObject);
begin
end;

procedure TfrmImportProgress.FormShow(Sender: TObject);
begin
  running := False;
  tmrImport.Enabled := True
end;

procedure TfrmImportProgress.tmrImportTimer(Sender: TObject);
begin
  FormActivate(nil)
end;

procedure TfrmImportProgress.ImportDXCCTables;
var
  f        : TStringList;
  i,z,y,c  : Integer;
  Result   : TExplodeArray;
  Prefixes : TExplodeArray;
  ADIF     : Integer;
  List     : TStringList;
  tmp      : String;
begin
  SetLength(Prefixes,0);
  SetLength(Result,0);
  f       := TStringList.Create;
  List    := TStringList.Create;
  List.Clear;
  dmDXCC.Q.Close;
  dmDXCC.trQ.StartTransaction;
  dmDXCC.Q.SQL.Text := 'DELETE FROM cqrtest_common.dxcc_ref';
  dmDXCC.Q.ExecSQL;
  dmDXCC.trQ.Commit;
  c := 0;
  try
    /////////////////////////////////////////////////////////////////////////// country.tab
    dmDXCC.trQ.StartTransaction;
    f.Clear;
    lblComment.Caption := 'Importing file country.tab ...';
    Application.ProcessMessages;
    f.LoadFromFile(Directory+'Country.tab');

    for z:=0 to f.Count-1 do
    begin
      inc(c);
      Result := dmUtils.Explode('|',f.Strings[z]);
      Prefixes  := dmUtils.Explode(' ',Result[0]);
      ADIF := StrToInt(Result[8]);
      if ADIF > 0 then
      begin
        dmDXCC.Q.SQL.Text := 'INSERT INTO cqrtest_common.dxcc_ref (pref,name,cont,utc,lat,'+
                                    'longit,itu,waz,adif,deleted) VALUES ('+
                                    QuotedStr(Prefixes[0])+','+ QuotedStr(Result[1])+','+
                                    QuotedStr(Result[2])+','+QuotedStr(Result[3])+','+
                                    QuotedStr(Result[4])+','+QuotedStr(Result[5])+','+
                                    QuotedStr(Result[6])+','+QuotedStr(Result[7])+','+
                                    IntToStr(ADIF)+',0)';
        dmUtils.DebugMsg(dmDXCC.Q.SQL.Text);
        dmDXCC.Q.ExecSQL
      end
    end;
    List.AddStrings(f);
    dmDXCC.trQ.Commit;
    ////////////////////////////////////////////////////////////// countrydel.tab
    dmDXCC.trQ.StartTransaction;
    f.Clear;
    lblComment.Caption := 'Importing file countrydel.tab ...';
    Application.ProcessMessages;
    f.LoadFromFile(Directory+'CountryDel.tab');
    for z:=0 to f.Count-1 do
    begin
      Result := dmUtils.Explode('|',f.Strings[z]);
      Prefixes  := dmUtils.Explode(' ',Result[0]);
      ADIF := StrToInt(Result[8]);
      if ADIF > 0 then
      begin
        dmDXCC.Q.SQL.Text := 'INSERT INTO cqrtest_common.dxcc_ref (pref,name,cont,utc,lat,'+
                                    'longit,itu,waz,adif,deleted) VALUES ('+
                                    QuotedStr(Prefixes[0]+'*')+','+ QuotedStr(Result[1])+','+
                                    QuotedStr(Result[2])+','+QuotedStr(Result[3])+','+
                                    QuotedStr(Result[4])+','+QuotedStr(Result[5])+','+
                                    QuotedStr(Result[6])+','+QuotedStr(Result[7])+','+
                                    IntToStr(ADIF)+','+'1'+')';
        dmUtils.DebugMsg(dmDXCC.Q.SQL.Text);
        dmDXCC.Q.ExecSQL
      end;
    end;
    dmDXCC.trQ.Commit;
    f.SaveToFile(dmData.AppHomeDir+'dxcc_data'+PathDelim+'country_del.tab');

    /////////////////////////////////////////////////////////////////// exceptions.tbl
    CopyFile(Directory+'Exceptions.tab',dmData.AppHomeDir+'dxcc_data'+PathDelim+'exceptions.tab');

    ////////////////////////////////////////////////////////////////// callresolution.tbl
    f.Clear;
    lblComment.Caption := 'Importing file Callresolution.tbl ...';
    Application.ProcessMessages;
    f.LoadFromFile(Directory+'CallResolution.tbl');
    List.AddStrings(f);
    ////////////////////////////////////////////////////////////////// AreaOK1RR.tab

    f.Clear;
    f.LoadFromFile(Directory+'AreaOK1RR.tbl');
    List.AddStrings(f);

    for y:=0 to List.Count-1 do
    begin
      if List.Strings[y][1] = '%' then
      begin
        for i:=65 to 90 do
          list.Add(chr(i)+copy(list.Strings[y],2,Length(list.Strings[y])-1));
      end;
    end;

    List.SaveToFile(dmData.AppHomeDir+'dxcc_data'+PathDelim+'country.tab');

    //////////////////////////////////////////////////////////// ambigous.tbl;
    CopyFile(Directory+'Ambiguous.tbl',dmData.AppHomeDir+'dxcc_data'+PathDelim+'ambiguous.tab');

    lblComment.Caption := 'Importing LoTW and eQSL users ...';
    Application.ProcessMessages;
    if FileExistsUTF8(Directory+'lotw1.txt') then
    begin
      DeleteFileUTF8(dmData.AppHomeDir+'lotw1.txt');
      CopyFile(Directory+'lotw1.txt',dmData.AppHomeDir+'lotw1.txt');
      //dmData.LoadLoTWCalls
    end;
    if FileExistsUTF8(Directory+'eqsl.txt') then
    begin
      DeleteFileUTF8(dmData.AppHomeDir+'eqsl.txt');
      CopyFile(Directory+'eqsl.txt',dmData.AppHomeDir+'eqsl.txt');
      //dmData.LoadeQSLCalls
    end;
    if FileExistsUTF8(Directory+'MASTER.SCP') then
    begin
      DeleteFileUTF8(dmData.AppHomeDir+'MASTER.SCP');
      CopyFile(Directory+'MASTER.SCP',dmData.AppHomeDir+'MASTER.SCP');

    end;

    lblComment.Caption := 'Importing IOTA table ...';
    Application.ProcessMessages;
    dmData.Q.Close();
    dmData.Q.SQL.Text := 'DELETE FROM cqrtest_common.iota_list';
    dmData.trQ.StartTransaction;
    dmData.Q.ExecSQL;
    dmData.trQ.Commit;

    f.Clear;
    f.LoadFromFile(Directory + 'iota.tbl');
    dmData.trQ.StartTransaction;
    for i:= 0 to f.Count-1 do
    begin
      Result := dmUtils.Explode('|',f.Strings[i]);
      if Length(Result) = 3 then
        dmData.Q.SQL.Text := 'INSERT INTO cqrtest_common.iota_list (iota_nr,island_name,dxcc_ref)'+
                                     ' VALUES ('+QuotedStr(Result[0]) + ',' +
                                     QuotedStr(Result[1]) + ',' + QuotedStr(Result[2]) + ')'
      else begin
        tmp := Result[3];
        if pos('/',tmp) > 0 then
          tmp := Copy(tmp,1,pos('/',tmp)-1)+ '.*' + Copy(tmp,pos('/',tmp),Length(tmp)-pos('/',tmp)+1);
        dmData.Q.SQL.Text := 'INSERT INTO cqrtest_common.iota_list (iota_nr,island_name,dxcc_ref,pref)'+
                                     ' VALUES ('+QuotedStr(Result[0]) + ',' +
                                     QuotedStr(Result[1]) + ',' + QuotedStr(Result[2])
                                     + ',' + QuotedStr(tmp) + ')'
      end;
      dmUtils.DebugMsg(dmData.Q.SQL.Text);

      if length(Result[1]) > 250 then ShowMessage(Result[0]);
      if length(Result[2]) > 15 then ShowMessage(Result[0]);
      if length(Result) > 3 then
        if length(Result[3]) > 15 then ShowMessage(Result[0]);
      dmData.Q.ExecSQL;
    end;
    dmData.trQ.Commit;

  finally
    //dmDXCC.trDXCCRef.StartTransaction;
    dmDXCC.qDXCCRef.SQL.Text := 'SELECT * FROM cqrtest_common.dxcc_ref ORDER BY adif';
    dmDXCC.qDXCCRef.Open;
    f.Free;
    List.Free;
    Close
  end
end;

procedure TfrmImportProgress.DownloadDXCCData;
var
  HTTP   : THTTPSend;
  m      : TFileStream;
begin
  FileName := dmData.AppHomeDir+'ctyfiles/cqrlog-cty.tar.gz';
  if FileExists(FileName) then
    DeleteFile(FileName);
  http   := THTTPSend.Create;
  m      := TFileStream.Create(FileName,fmCreate);
  try
    HTTP.Sock.OnStatus := @SockCallBack;
    HTTP.ProxyHost := iniLocal.ReadString('Program','Proxy','');
    HTTP.ProxyPort := iniLocal.ReadString('Program','Port','');
    HTTP.UserName  := iniLocal.ReadString('Program','User','');
    HTTP.Password  := iniLocal.ReadString('Program','Passwd','');

    if HTTP.HTTPMethod('GET', 'http://www.ok2cqr.com/linux/cqrlog/ctyfiles/cqrlog-cty.tar.gz') then
    begin
      http.Document.Seek(0,soBeginning);
      m.CopyFrom(http.Document,HTTP.Document.Size);
      if dmUtils.UnTarFiles(FileName,ExtractFilePath(FileName)) then
      begin
        Directory := ExtractFilePath(FileName);
        ImportDXCCTables
      end;
    end;
  finally
    http.Free;
    m.Free;
  end
end;

procedure TfrmImportProgress.SockCallBack (Sender: TObject; Reason:   THookSocketReason; const  Value: string);
begin
  if Reason = HR_ReadCount then
  begin
    FileSize := FileSize + StrToInt(Value);
    lblCount.Caption := IntToStr(FileSize);
    Repaint;
    Application.ProcessMessages
  end
end;


initialization

  {$I fImportProgress.lrs}

end.

