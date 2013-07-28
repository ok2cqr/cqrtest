(*
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *                                                                         *
 ***************************************************************************
*)


unit fDXCluster;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, Buttons, httpsend,  jakozememo,
  lcltype, lNetComponents, lnet;

type
  { TfrmDXCluster }

  TfrmDXCluster = class(TForm)
    btnClear: TButton;
    btnFont: TButton;
    btnFont1: TButton;
    btnHelp: TButton;
    btnSelect: TButton;
    btnTelConnect: TButton;
    btnWebConnect: TButton;
    Button1: TButton;
    Button2: TButton;
    dlgDXfnt: TFontDialog;
    edtCommand: TEdit;
    edtTelAddress: TEdit;
    Label1: TLabel;
    lblInfo: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    pgDXCluster: TPageControl;
    pnlTelnet: TPanel;
    pnlWeb: TPanel;
    tabTelnet: TTabSheet;
    tabWeb: TTabSheet;
    tmrSpots: TTimer;
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnTelConnectClick(Sender: TObject);
    procedure btnWebConnectClick(Sender: TObject);
    procedure edtCommandKeyPress(Sender: TObject; var Key: char);
    procedure tmrSpotsTimer(Sender: TObject);
  private
    telDesc    : String;
    telAddr    : String;
    telPort    : String;
    telUser    : String;
    telPass    : String;
    Running    : Boolean;
    FirstShow  : Boolean;
    ConOnShow  : Boolean;
    lTelnet    : TLTelnetClientComponent;
    procedure WebDbClick(where:longint;mb:TmouseButton;ms:TShiftState);
    procedure TelDbClick(where:longint;mb:TmouseButton;ms:TShiftState);
    procedure ConnectToWeb;
    procedure ConnectToTelnet;
    procedure SynWeb;
    procedure SynTelnet;
    procedure lConnect(aSocket: TLSocket);
    procedure lDisconnect(aSocket: TLSocket);
    procedure lReceive(aSocket: TLSocket);

    function  ShowSpot(spot : String; var sColor : Integer; var Country : String) : Boolean;
    function  GetFreq(spot : String) : String;
    function  GetCall(spot : String; web : Boolean = False) : String;
    function  GetSplit(spot : String) :String;
  public
    ConWeb    : Boolean;
    ConTelnet : Boolean;
    csTelnet  : TRTLCriticalSection;

    procedure SavePosition;
    procedure SendCommand(cmd : String);
    procedure StopAllConnections;

  end;

  type
    TWebThread = class(TThread)
    protected
      procedure Execute; override;
  end;

  type
    TTelThread = class(TThread)
    protected
      procedure Execute; override;
  end;

var
  frmDXCluster : TfrmDXCluster;
  Spots        : TStringList;
  WebSpots     : Tjakomemo;
  TelSpots     : Tjakomemo;
  mindex       : Integer;
  ThInfo       : String;
  ThSpot       : String;
  ThColor      : Integer;
  ThBckColor   : Integer;
  TelThread    : TTelThread;

implementation

{ TfrmDXCluster }

uses dUtils, fDXClusterList, dData, uCfgStorage, dDXCC;

procedure TfrmDXCluster.ConnectToWeb;
var
  WebThread : TWebThread = nil;
begin
  tmrSpots.Enabled := True;
  if not Running then
  begin
    Running := True;
    if WebThread = nil then
      WebThread := TWebThread.Create(True);
    WebThread.Resume;
  end;
end;

procedure TfrmDXCluster.ConnectToTelnet;
begin
  if edtTelAddress.Text='' then
    exit;
  if ConTelnet then
  begin
    btnTelConnect.Caption := 'Connect';
    StopAllConnections;
    ConTelnet := False;
    exit
  end;
  try
    lTelnet.Host    := telAddr;
    lTelnet.Port    := StrToInt(telPort);
    lTelnet.Connect;
    lTelnet.CallAction;
  except
    on E : Exception do
    begin
      Application.MessageBox(Pchar('Cannot connect to telnet!:'+#13+'Error: '+E.Message),'Error!',mb_ok+mb_IconError)
    end
  end;

  if lTelnet.Connected then
  begin
    edtCommand.SetFocus;
    btnTelConnect.Caption := 'Disconnect';
    ConTelnet := True
  end
end;

procedure TfrmDXCluster.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  iniLocal.WriteInteger('DXCluster','Tab',pgDXCluster.ActivePageIndex);
  iniLocal.WriteString('DXCluster','Desc',telDesc);
  iniLocal.WriteString('DXCluster','Addr',telAddr);
  iniLocal.WriteString('DXCluster','Port',telPort);
  iniLocal.WriteString('DXCluster','User',telUser);
  iniLocal.WriteString('DXCluster','Pass',telPass);
  iniLocal.SaveToDisk;
  if ConWeb then
    btnWebConnect.Click;
  if ConTelnet then
    btnTelConnect.Click;
  tmrSpots.Enabled := False
end;

procedure TfrmDXCluster.btnHelpClick(Sender: TObject);
begin
  ShowHelp
end;

procedure TfrmDXCluster.FormDestroy(Sender: TObject);
begin
  TelThread.Terminate;
  WebSpots.Free;
  TelSpots.Free
end;

procedure TfrmDXCluster.FormActivate(Sender: TObject);
begin
  if FirstShow and ConOnShow then
  begin
    btnTelConnect.Click;
    FirstShow := False;
  end;
end;

procedure TfrmDXCluster.Button2Click(Sender: TObject);
var
  TelThread : TTelThread = nil;
begin
  //Spots.Add('10368961.9  GB3CCX/B    17-Jan-2009 1905Z  51S IO81XW>IO81JM           <GW3TKH>')
  //Spots.Add('DX de GW3TKH  10368961.9  GB3CCX/B                                    1905Z     ');
  Spots.Add('DX de WT4Y:      14207.0  HI3CCP/MM                                    1905Z EL88');
  if not Running then
  begin
    Writeln('aa');
    if TelThread = nil then
    begin
      Writeln('ab');
      TelThread := TTelThread.Create(True);
    end;
    Writeln('bb');
    TelThread.Resume;
    Writeln('cc');
  end;
end;

procedure TfrmDXCluster.FormCreate(Sender: TObject);
begin
  InitCriticalSection(csTelnet);
  FirstShow := True;
  ConOnShow := False;
  lTelnet := TLTelnetClientComponent.Create(nil);

  lTelnet.OnConnect    := @lConnect;
  lTelnet.OnDisconnect := @lDisconnect;
  lTelnet.OnReceive    := @lReceive;

    WebSpots             := Tjakomemo.Create(pnlWeb);
    WebSpots.parent      := pnlWeb;
    WebSpots.autoscroll  := True;
    WebSpots.oncdblclick := @WebDbClick;
    WebSpots.Align       := alClient;
    WebSpots.nastav_jazyk(1);


    TelSpots             := Tjakomemo.Create(pnlTelnet);
    TelSpots.parent      := pnlTelnet;
    TelSpots.autoscroll  := True;
    TelSpots.oncdblclick := @TelDbClick;
    TelSpots.Align       := alClient;
    TelSpots.nastav_jazyk(1);

    Spots := TStringList.Create;
    Spots.Clear;
    Running := False;
    mindex  := 1;

    TelThread := TTelThread.Create(True);
    TelThread.FreeOnTerminate := True;
    TelThread.Resume
end;

procedure TfrmDXCluster.WebDbClick(where:longint;mb:TmouseButton;ms:TShiftState);
var
  spot : String = '';
  tmp  : Integer = 0;
  freq : String = '';
  mode : String = '';
  call : String = '';
  etmp : Extended = 0;
  stmp : String = '';
  i    : Integer = 0;
begin
  WebSpots.cti_vetu(spot,tmp,tmp,tmp,where);
  spot := copy(spot,i+6,Length(spot)-i-5);
  spot := Trim(spot);
  freq := GetFreq(spot);
  call := GetCall(spot,True);
  {
  Writeln('WebDbClick*****');
  Writeln('Spot:',spot);
  Writeln('Freq:',freq);
  Writeln('Call:',call);
  Writeln('***************');
  }
  if NOT TryStrToFloat(freq,etmp) then
    exit;
  //if (not dmDXCluster.BandModFromFreq(freq,mode,stmp)) or (mode='') then
  //  exit;

  //frmNewQSO.NewQSOFromSpot(call,freq,mode)
end;

procedure TfrmDXCluster.TelDbClick(where:longint;mb:TmouseButton;ms:TShiftState);
var
  spot : String = '';
  tmp  : Integer = 0;
  freq : String = '';
  mode : String = '';
  call : String = '';
  etmp : Extended = 0;
  stmp : String = '';
  i    : Integer = 0;
  f    : Currency;
begin
  TelSpots.cti_vetu(spot,tmp,tmp,tmp,where);
  if TryStrToCurr(copy(spot,1,Pos(' ',spot)-1),f)  then
  begin
    freq := copy(spot,1,Pos(' ',spot)-1);
    call := trim(copy(spot,Pos('.',spot)+2,14))
  end
  else begin
    spot := copy(spot,i+6,Length(spot)-i-5);
    spot := Trim(spot);
    freq := GetFreq(Spot);
    call := GetCall(Spot, ConWeb)
  end;
  {
  Writeln('TelDbClick*****');
  Writeln('Spot:',spot);
  Writeln('Freq:',freq);
  Writeln('Call:',call);
  Writeln('***************');
  }

  if NOT TryStrToFloat(freq,etmp) then
    exit;
  //frmNewQSO.NewQSOFromSpot(call,freq,mode)
end;


procedure TfrmDXCluster.FormShow(Sender: TObject);
var
  f : TFont;
begin
  f := TFont.Create;
  try
    WebSpots.nastav_font(f);
    TelSpots.nastav_font(f)
  finally
    f.Free
  end;
  pgDXCluster.ActivePageIndex :=  iniLocal.ReadInteger('DXCluster','Tab',1);;
  telDesc := iniLocal.ReadString('DXCluster','Desc','');
  telAddr := iniLocal.ReadString('DXCluster','Addr','');
  telPort := iniLocal.ReadString('DXCluster','Port','');
  telUser := iniLocal.ReadString('DXCluster','User','');
  telPass := iniLocal.ReadString('DXCluster','Pass','');
  edtTelAddress.Text := telDesc
end;

procedure TfrmDXCluster.btnClearClick(Sender: TObject);
begin
  WebSpots.smaz_vse;
end;

procedure TfrmDXCluster.btnFontClick(Sender: TObject);
begin
  dlgDXfnt.Font.Name := iniLocal.ReadString('DXCluster','Font','DejaVu Sans Mono');
  dlgDXfnt.Font.Size := iniLocal.ReadInteger('DXCluster','FontSize',12);
  if dlgDXfnt.Execute then
  begin
    iniLocal.WriteString('DXCluster','Font',dlgDXfnt.Font.Name);
    iniLocal.WriteInteger('DXCluster','FontSize',dlgDXfnt.Font.Size);
    WebSpots.nastav_font(dlgDXfnt.Font);
    TelSpots.nastav_font(dlgDXfnt.Font)
  end
end;

procedure TfrmDXCluster.btnSelectClick(Sender: TObject);
begin
  frmDXClusterList := TfrmDXClusterList.Create(self);
  try
    frmDXClusterList.OldDesc := edtTelAddress.Text;
    frmDXClusterList.ShowModal;
    if frmDXClusterList.ModalResult = mrOK then
    begin
      telDesc            := dmData.qDXClusters.Fields[1].AsString;
      telAddr            := dmData.qDXClusters.Fields[2].AsString;
      telPort            := dmData.qDXClusters.Fields[3].AsString;
      telUser            := dmData.qDXClusters.Fields[4].AsString;
      telPass            := dmData.qDXClusters.Fields[5].AsString;
      edtTelAddress.Text := telDesc;
      SavePosition
    end
  finally
    frmDXClusterList.Free
  end
end;

procedure TfrmDXCluster.btnTelConnectClick(Sender: TObject);
begin
  if ConWeb then
  begin
    Application.MessageBox('You are connected to web, you must disconnect it before connect to telnet.',
                            'Info ...',mb_ok + mb_IconInformation);
    exit
  end;

  if ConTelnet then
  begin
    StopAllConnections;
    btnTelConnect.Caption := 'Connect';
    ConWeb := False
  end
  else begin
    ConnectToTelnet;
    btnTelConnect.Caption := 'Disconnect';
    ConTelnet := True;
    edtCommand.SetFocus;
  end;
end;

procedure TfrmDXCluster.btnWebConnectClick(Sender: TObject);
begin
  if ConTelnet then
  begin
    Application.MessageBox('You are connected with telnet, you must disconnect it before connect to web cluster.',
                            'Info ...',mb_ok + mb_IconInformation);
    exit
  end;

  if ConWeb then
  begin
    StopAllConnections;
    btnWebConnect.Caption := 'Connect';
    ConWeb := False
  end
  else begin
    ConnectToWeb;
    btnWebConnect.Caption := 'Disconnect';
    ConWeb := True;
  end;
end;

procedure TfrmDXCluster.edtCommandKeyPress(Sender: TObject; var Key: char);
begin
  if key=#13 then
  begin
    key := #0;
   SendCommand(edtCommand.Text);
   edtCommand.Clear
  end;
end;

procedure TfrmDXCluster.lConnect(aSocket: TLSocket);
begin
  btnTelConnect.Caption := 'Disconnect';
  ConTelnet := True;
  edtCommand.SetFocus
end;

procedure TfrmDXCluster.lDisconnect(aSocket: TLSocket);
begin
  btnTelConnect.Caption := 'Connect';
  ConTelnet := False
end;

procedure TfrmDXCluster.lReceive(aSocket: TLSocket);
const
  CR = #13;
  LF = #10;
var
  sStart, sStop: Integer;
  tmp : String;
  itmp : Integer;
  buffer : String;
  f : Double;
begin
  if lTelnet.GetMessage(buffer) = 0 then
    exit;
  sStart := 1;
  sStop := Pos(CR, Buffer);
  if sStop = 0 then
    sStop := Length(Buffer) + 1;
  while sStart <= Length(Buffer) do
  begin
    tmp  := Copy(Buffer, sStart, sStop - sStart);
    tmp  := trim(tmp);
    dmUtils.DebugMsg(tmp);
    itmp := Pos('DX DE',UpperCase(tmp));
    if (itmp > 0) or TryStrToFloat(copy(tmp,1,Pos(' ',tmp)-1),f)  then
    begin
      EnterCriticalsection(frmDXCluster.csTelnet);
      dmUtils.DebugMsg('Enter critical section On Receive');
      try
        Spots.Add(tmp)
      finally
        LeaveCriticalsection(csTelnet);
        dmUtils.DebugMsg('Leave critical section On Receive')
      end
    end
    else begin
      if (Pos('LOGIN',UpperCase(tmp)) > 0) and (telUser <> '') then
        lTelnet.SendMessage(telUser+#13+#10);
      if (Pos('please enter your call:',LowerCase(tmp)) > 0) and (telUser <> '') then
        lTelnet.SendMessage(telUser+#13+#10);
      if (Pos('PASSWORD',UpperCase(tmp)) > 0) and (telPass <> '') then
        lTelnet.SendMessage(telPass+#13+#10);
      TelSpots.pridej_vetu(tmp,clBlack,clWhite,0)
    end;
    sStart := sStop + 1;
    if sStart > Length(Buffer) then
      Break;
    if Buffer[sStart] = LF then
      sStart := sStart + 1;
    sStop := sStart;
    while (Buffer[sStop] <> CR) and (sStop <= Length(Buffer)) do
      sStop := sStop + 1
  end;
  lTelnet.CallAction
end;

procedure TfrmDXCluster.SendCommand(cmd : String);
begin
  if lTelnet.Connected then
  begin
    lTelnet.SendMessage(cmd + #13#10);
    TelSpots.pridej_vetu(cmd,clBlack,clWhite,0)
  end
end;

procedure TfrmDXCluster.tmrSpotsTimer(Sender: TObject);
begin
  if pgDXCluster.ActivePageIndex = 0 then
    ConnectToWeb;
end;

function TfrmDXCluster.GetFreq(spot : String) : String;
var
  tmp : String;
begin
  tmp    := copy(spot,Pos(' ',spot),Pos('.',spot)+2 - Pos(' ',spot));
  Result := trim(tmp)
end;

function TfrmDXCluster.GetSplit(spot : String) : String;
var
  tmp : String;
  spl : String;
  spn : String;
  l : Integer;
begin
  tmp := copy(spot,34,Length(spot)-34);
  //Writeln('tmp: ',tmp);
  if Pos('UP',tmp)>0 then begin
    spl:= copy(tmp,Pos('UP',tmp),13);
    spn:='UP';
    for l:=3 to Length(spl) do
       if Pos(spl[l],' 0123456789.,-+')>0 then
           spn:=spn+spl[l]
        else break;
    end;
  if Pos('DOWN',tmp)>0 then begin
    spl:= copy(tmp,Pos('DOWN',tmp),13);
    spn:='DOWN';
    for l:=5 to Length(spl) do
       if Pos(spl[l],' 0123456789.,-+')>0 then
           spn:=spn+spl[l]
        else break;
    end;
  if Pos('QSX',tmp)>0 then begin
    spl:= copy(tmp,Pos('QSX',tmp),13);
    spn:='QSX';
    for l:=4 to Length(spl) do
       if Pos(spl[l],' 0123456789.,-+')>0 then
           spn:=spn+spl[l]
        else break;
    end;
  Result := trim(spn)
end;

function TfrmDXCluster.GetCall(spot : String; web : Boolean = False) : String;
var
  tmp : String='';
begin
  //these all horrible lines because of bug in dxsummit.fi cluster
  if web then
  begin
    //Writeln('spot:',spot);
    tmp    := trim(copy(spot,Pos(' ',spot)+1, Length(spot) -(Pos(' ',spot))));
    //Writeln('tmp: ',tmp);
    tmp    := copy(tmp,Pos(' ',tmp)+1, Length(tmp) -(Pos(' ',tmp)));
    //Writeln('tmp: ',tmp);
    if Pos(' ',tmp) > 0 then
      tmp    := trim(copy(tmp,1,Pos(' ',tmp)));
    //Writeln('tmp: ',tmp);
  end
  else begin
    tmp    := copy(spot,Pos('.',spot)+2,Length(spot)-Pos('.',spot)-1);
    tmp    := trim(tmp);
    tmp    := trim(copy(tmp,1,Pos(' ',tmp)))
  end;
  Result := tmp
end;

procedure TfrmDXCluster.StopAllConnections;
begin
  if ConWeb then
    tmrSpots.Enabled := False;
  if ConTelnet then
  begin
    if lTelnet.Connected then
      lTelnet.Disconnect;
    ConTelnet := False;
  end;
end;

function TfrmDXCluster.ShowSpot(spot : String; var sColor : Integer; var Country : String) : Boolean;
var
  kmitocet : Extended = 0.0;
  call     : String  = '';
  freq     : String  = '';
  tmp      : Integer = 0;
  band     : String  = '';
  mode     : String  = '';
  seznam   : TStringList;
  i        : Integer = 0;
  prefix   : String  = '';
  waz      : String = '';
  itu      : String = '';
  cont     : String = '';
  lat      : String = '';
  long     : String = '';
  adif     : Word   = 0;
  f        : Currency;
  splitstr : String;
begin
  sColor  := 0; //cerna

  spot := UpperCase(spot);
  i := Pos('DX DE ',spot);
  if i > 0 then
    spot := copy(spot,i+6,Length(spot)-i-5);

  if TryStrToCurr(copy(spot,1,Pos(' ',spot)-1),f)  then
  begin
    freq := copy(spot,1,Pos(' ',spot)-1);
    call := trim(copy(spot,Pos('.',spot)+2,14))
  end
  else begin
    freq     := GetFreq(Spot);
    call     := GetCall(Spot, ConWeb)
  end;

  splitstr := GetSplit(Spot);

  Writeln('Freq:',freq);
  Writeln('Call:',call);
  Writeln('Split:',splitstr);

  tmp := Pos('.',freq);
  if tmp > 0 then
    freq[tmp] := DecimalSeparator;
  tmp := Pos(',',freq);
  if tmp > 0 then
    freq[tmp] := DecimalSeparator;

  ThBckColor := clWhite;

  if not TryStrToFloat(freq,kmitocet) then
  begin
    Result := False;
    exit
  end;

  //freq    := FloatToStr(freq);
  adif    := dmDXCC.id_country(call,now,prefix,waz,itu,cont,lat,long);
  prefix  := dmDXCC.PfxFromADIF(adif);
  Country := dmDXCC.CountryFromADIF(adif);

  Result  := True;

  {
  frmBandMap.AddFromDXCluster(call,mode,prefix,band,lat,long,kmitocet,
                               cqrini.ReadInteger('BandMap','ClusterColor',clBlack),ThBckColor,splitstr)
  }
end;

procedure TTelThread.Execute;
var
  dx      : String;
  sColor  : TColor;
  Country : String;
begin
  while true do
  begin
    while Spots.Count > 0 do
    begin
      dmUtils.DebugMsg('TelThread.Execute - enter critical section ',2);
      EnterCriticalsection(frmDXCluster.csTelnet);
      try
        dx := dmUtils.MyTrim(spots.Strings[0]);
        spots.Delete(0)
      finally
        LeaveCriticalsection(frmDXCluster.csTelnet);
        dmUtils.DebugMsg('TelThread.Execute - leave critical section ',2);
      end;
      dmUtils.DebugMsg('Spot: '+dx,2);
      if frmDXCluster.ShowSpot(dx,sColor, Country) then
      begin
        if iniLocal.ReadBool('DXCluster','ShowDxcCountry',False) then
          ThSpot := dx + ' ' + Country
        else
          ThSpot := dx;
        ThColor   := sColor;
        ThInfo    := '';
        dmUtils.DebugMsg('Spot nr. '+IntToStr(mindex),2);
        dmUtils.DebugMsg('ThSpot: '+ThSpot,2);
        dmUtils.DebugMsg('ThColor: '+IntToStr(ThColor),2);
        dmUtils.DebugMsg('TelThread.Execute - before Synchronize(@frmDXCluster.SynTelnet)',2);
        Synchronize(@frmDXCluster.SynTelnet);
        dmUtils.DebugMsg('TelThread.Execute - after Synchronize(@frmDXCluster.SynTelnet)',2)
      end
    end;
    sleep(500)
  end
end;

procedure TWebThread.Execute;
var
  i,tmp  : Integer;
  HTTP   : THTTPSend;
  sp     : TStringList;
begin
  dmUtils.DebugMsg('In TWebThread.Execute',1);
  FreeOnTerminate      := True;
  frmDXCluster.Running := True;
  HTTP   := THTTPSend.Create;
  sp     := TStringList.Create;
  try
    sp.Clear;
    ThInfo := 'Connecting ...';
    Synchronize(@frmDXCluster.SynWeb);
    HTTP.ProxyHost := iniLocal.ReadString('Program','Proxy','');
    HTTP.ProxyPort := iniLocal.ReadString('Program','Port','');
    HTTP.UserName  := iniLocal.ReadString('Program','User','');
    HTTP.Password  := iniLocal.ReadString('Program','Passwd','');
    if not HTTP.HTTPMethod('GET','http://www.dxsummit.fi/text/Default.aspx') then
    begin
      frmDXCluster.StopAllConnections;
      frmDXCluster.btnWebConnect.Click;
      exit
    end;
    ThInfo := 'Downloading spots ...';
    Synchronize(@frmDXCluster.SynWeb);
    sp.LoadFromStream(HTTP.Document);
    tmp := Pos('<pre>',sp.Text);
    sp.Text := copy(sp.Text,tmp+5,Length(sp.Text)-tmp+5);
    tmp := Pos('</pre>',sp.Text);
    sp.Text := copy(sp.Text,1,tmp-1);
    Writeln(sp.Text);
    for i:=0 to sp.Count-1 do
    begin
      EnterCriticalsection(frmDXCluster.csTelnet);
      dmUtils.DebugMsg('Enter critical section TWebThread.Execute',2);
      try
        dmUtils.DebugMsg('Adding from web:'+dmUtils.MyTrim('DX DE ' + sp.Strings[i]),2);
        Spots.Add(dmUtils.MyTrim('DX DE ' + sp.Strings[i]));
      finally
        LeaveCriticalsection(frmDXCluster.csTelnet);
        dmUtils.DebugMsg('Leave critical section TWebThread.Execute')
      end
    end
  finally
    ThInfo := '';
    Synchronize(@frmDXCluster.SynWeb);
    HTTP.Free;
    sp.Free;
    frmDXCluster.Running := False
  end
end;

procedure TfrmDXCluster.SavePosition;
begin
end;

procedure TfrmDXCluster.SynWeb;
begin
  lblInfo.Caption := ThInfo;
  {
  if ThSpot = '' then
    exit;
  Writeln('******************* Hledam:',ThSpot,'********');
  if WebSpots.hledej(ThSpot,1,True,True) = -1 then
  begin
    Writeln('*****************Nenasel:',ThSpot,'********');
    WebSpots.zakaz_kresleni(true);
    WebSpots.vloz_vetu(ThSpot,ThColor,clWhite,0,0);
    WebSpots.zakaz_kresleni(false);
    Sleep(200)
  end
  else
    Writeln('*****************Nenasel:',ThSpot,'********');
  }
end;

procedure TfrmDXCluster.SynTelnet;
begin
  //if dmData.DebugLevel>=1 then Writeln('TfrmDXCluster.SynTelnet - begin ');
  if ThSpot = '' then
    exit;
  //if dmData.DebugLevel>=1 then Writeln('TfrmDXCluster.SynTelnet - before MapToScreen');
  //frmBandMap.MapToScreen;
  //if dmData.DebugLevel>=1 then Writeln('TfrmDXCluster.SynTelnet - Before ]'yu
  if ConTelnet then
  begin
    TelSpots.zakaz_kresleni(true);
    TelSpots.pridej_vetu(ThSpot,ThColor,ThBckColor,0);
    TelSpots.zakaz_kresleni(false)
  end
  else begin
    if WebSpots.hledej(ThSpot,0,True,True) = -1 then
    begin
      WebSpots.zakaz_kresleni(true);
      WebSpots.vloz_vetu(ThSpot,ThColor,ThBckColor,0,0);
      WebSpots.zakaz_kresleni(false);
    end
  end;
  //if dmData.DebugLevel>=1 then Writeln('TfrmDXCluster.SynTelnet - before PridejVetu ');
  //if dmData.DebugLevel>=1 then Writeln('TfrmDXCluster.SynTelnet - after zakaz_kresleni');
  //Sleep(200)
end;

initialization
  {$I fDXCluster.lrs}

end.

                                 
