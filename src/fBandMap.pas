unit fBandMap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  jakozememo, lclproc, Math;

type
  TBandMapClick = procedure(Sender:TObject;Call,Mode : String; Freq : Currency) of object;

const
  MAX_ITEMS = 500;
  DELTA_FREQ = 0.3; //freq tolerance between radio freq and freq in bandmap
  CURRENT_STATION_CHAR = '|'; //this character will be placed before the bandmap item when the radio freq is close enough

type
  TBandMapItem =  record
    Freq      : Double;
    Call      : String[30];
    Mode      : String[10];
    Band      : String[10];
    SplitInfo : String[20];
    Lat       : Double;
    Long      : Double;
    Color     : LongInt;
    BgColor   : LongInt;
    TimeStamp : TDateTime;
    Flag      : String[1];
    TextValue : String[80];
    FrmNewQSO : Boolean;
  end;

type
  TBandMapThread = class(TThread)
  protected
    function  IncColor(AColor: TColor; AQuantity: Byte) : TColor;
    procedure Execute; override;
end;

type
  TfrmBandMap = class(TForm)
    Panel1: TPanel;
    pnlBandMap: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    BandMap  : TJakoMemo;
    BandMapItemsCount : Word;
    BandMapCrit : TRTLCriticalSection;
    FFirstInterval : Word;
    FSecondInterval : Word;
    FDeleteAfter    : Word;
    FBandFilter     : String;
    FModeFilter     : String;
    FCurrentFreq    : Currency;
    FBandMapClick   : TBandMapClick;

    procedure SortBandMapArray(l,r : Integer);
    procedure BandMapDbClick(where:longint;mb:TmouseButton;ms:TShiftState);
    procedure EmitBandMapClick(Sender:TObject;Call,Mode : String; Freq : Currency);
    procedure ClearAll;

    function FindFirstEmptyPos : Word;
    function FormatItem(freq : Double; Call, SplitInfo : String) : String;
    function SetSizeLeft(Value : String;Len : Integer) : String;
  public
    BandMapItems  : Array [1..MAX_ITEMS] of TBandMapItem;
    BandMapThread : TBandMapThread;

    //after XX seconds items get older
    property FirstInterval  : Word write FFirstInterval;
    property SecondInterval : Word Write FSecondInterval;
    property DeleteAfter    : Word write FDeleteAfter;
    property BandFilter     : String write FBandFilter;
    property ModeFilter     : String write FModeFilter;
    property CurrentFreq    : Currency write FCurrentFreq;
    property OnBandMapClick : TBandMapClick read FBandMapClick write FBandMapClick;
                            //Freq in kHz
    procedure AddToBandMap(Freq : Double; Call, Mode, Band, SplitInfo : String; Lat,Long : Double; ItemColor, BgColor : LongInt;
                           fromNewQSO : Boolean=False);
    procedure SyncBandMap;
  end; 

var
  frmBandMap: TfrmBandMap;

implementation

{ TfrmBandMap }

procedure TfrmBandMap.AddToBandMap(Freq : Double; Call, Mode, Band, SplitInfo : String; Lat,Long : Double; ItemColor, BgColor : LongInt;
                                   fromNewQSO : Boolean=False);
var
  i : integer;
begin
  EnterCriticalSection(BandMapCrit);
  try
    i := FindFirstemptyPos;
    if (i=0) then
    begin
      ShowMessage('CRITICAL ERROR: BANDMAP IS FULL');
      exit
    end;
    BandMapItems[i].frmNewQSO := fromNewQSO;
    BandMapItems[i].Freq      := Freq;
    BandMapItems[i].Call      := Call;
    BandMapItems[i].Mode      := Mode;
    BandMapItems[i].Band      := Band;
    BandMapItems[i].SplitInfo := SplitInfo;
    BandMapItems[i].Lat       := Lat;
    BandMapItems[i].Long      := Long;
    BandMapItems[i].Color     := ItemColor;
    BandMapItems[i].BgColor   := BgColor;
    BandMapItems[i].TimeStamp := now;
    BandMapItems[i].TextValue := FormatItem(Freq, Call, SplitInfo)
  finally
    LeaveCriticalSection(BandMapCrit)
  end
end;

procedure TfrmBandMap.ClearAll;
begin
  BandMap.smaz_vse
end;

function TfrmBandMap.FormatItem(freq : Double; Call, SplitInfo : String) : String;
begin
  Result := SetSizeLeft(FloatToStrF(freq,ffFixed,8,3),12)+SetSizeLeft(call,10) +
            ' ' + SplitInfo
end;

procedure TfrmBandMap.SyncBandMap;
var
  i : Integer;
  s : String;
begin
  if Active then exit;
  ClearAll;
  FBandFilter := UpperCase(FBandFilter);
  FModeFilter := UpperCase(FModeFilter);
  BandMap.zakaz_kresleni(True);
  try
    for i:=1 to MAX_ITEMS do
    begin
      if (BandMapItems[i].Freq = 0) then
        Continue;
      if (FBandFilter<>'') then
      begin
        if BandMapItems[i].Band<>FBandFilter then
          Continue
      end;
      if (FModeFilter<>'') then
      begin
        if BandMapItems[i].Mode<>FModeFilter then
          Continue
      end;
      if abs(FCurrentFreq-BandMapItems[i].Freq)<=DELTA_FREQ then
        s := CURRENT_STATION_CHAR + BandMapItems[i].TextValue
      else
        s := ' ' + BandMapItems[i].TextValue;
      BandMap.pridej_vetu(s,BandMapItems[i].Color,BandMapItems[i].BgColor,i)
    end
  finally
    BandMap.zakaz_kresleni(False)
  end
end;


procedure TfrmBandMap.EmitBandMapClick(Sender:TObject;Call,Mode : String; Freq : Currency);
begin
  if Assigned(FBandMapClick) then
    FBandMapClick(Self,Call,Mode,Freq)
end;

procedure TfrmBandMap.BandMapDbClick(where:longint;mb:TmouseButton;ms:TShiftState);
var
  te  : String = '';
  bpi : TColor = clBlack;
  bpo : TColor = clBlack;
  pom : LongInt = 0;
begin
  if BandMap.cti_vetu(te,bpi,bpo,pom,where) then
  begin
    EmitBandMapClick(Self,BandMapItems[pom].Call,BandMapItems[pom].Mode,BandMapItems[pom].Freq)
  end
end;

procedure TfrmBandMap.SortBandMapArray(l,r : integer);
var
  i,j : Integer;
  w : TbandMapItem;
  x : Double;
begin
  i:=l; j:=r;
  x:=BandMapItems[(l+r) div 2].Freq;
  repeat
    while BandMapItems[i].Freq < x do i:=i+1;
    while x < BandMapItems[j].Freq do j:=j-1;
    if i <= j then
    begin
      w := BandMapItems[i];
      BandMapItems[i] := BandMapItems[j];
      BandMapItems[j] := w;
      i:=i+1; j:=j-1
    end
  until i > j;
  if l < j then SortBandMapArray(l,j);
  if i < r then SortBandMapArray(i,r)
end;

function TfrmBandMap.FindFirstEmptyPos : Word;
var
  i : Integer;
begin
  Result := 0;
  for i:=1 to MAX_ITEMS do
  begin
    if BandMapItems[i].Freq = 0 then
    begin
      Result := i;
      Break
    end
  end
end;

procedure TBandMapThread.Execute;
var
  i : Integer;
begin
  while not Terminated do
  begin
    try
      EnterCriticalSection(frmBandMap.BandMapCrit);
      for i:=1 to MAX_ITEMS do
      begin
        if frmBandMap.BandMapItems[i].Freq = 0 then
          Continue;
        if now>(frmBandMap.BandMapItems[i].TimeStamp + (frmBandMap.FDeleteAfter/86400)) then
        begin
          frmBandMap.BandMapItems[i].Freq := 0;
          frmBandMap.BandMapItems[i].Flag  := ''
        end
        else if (now>(frmBandMap.BandMapItems[i].TimeStamp + (frmBandMap.FSecondInterval/86400))) and (frmBandMap.BandMapItems[i].Flag='S') then
        begin
          frmBandMap.BandMapItems[i].Color := IncColor(frmBandMap.BandMapItems[i].Color,40);
          frmBandMap.BandMapItems[i].Flag  := 'X'
        end
        else if (now>(frmBandMap.BandMapItems[i].TimeStamp + (frmBandMap.FFirstInterval/86400))) and (frmBandMap.BandMapItems[i].Flag='') then
        begin
          frmBandMap.BandMapItems[i].Color := IncColor(frmBandMap.BandMapItems[i].Color,60);
          frmBandMap.BandMapItems[i].Flag  := 'S'
        end
      end;
      frmBandMap.SortBandMapArray(1,MAX_ITEMS)
    finally
      LeaveCriticalSection(frmBandMap.BandMapCrit)
    end;
    Synchronize(@frmBandMap.SyncBandMap);
    Sleep(500)
  end
end;


function TBandMapThread.IncColor(AColor: TColor; AQuantity: Byte) : TColor;
var
  R, G, B : Byte;
begin
  RedGreenBlue(ColorToRGB(AColor), R, G, B);
  R := Max(0, Integer(R) + AQuantity);
  G := Max(0, Integer(G) + AQuantity);
  B := Max(0, Integer(B) + AQuantity);
  Result := RGBToColor(R, G, B);
end;

function TfrmBandMap.SetSizeLeft(Value : String;Len : Integer) : String;
var
  i : Integer;
begin
  Result := Value;
  for i:=Length(Value) to Len-1 do
    Result := ' ' + Result
end;

procedure TfrmBandMap.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  FBandMapClick := @EmitBandMapClick;
  InitCriticalSection(BandMapCrit);
  BandMap             := Tjakomemo.Create(pnlBandMap);
  BandMap.parent      := pnlBandMap;
  BandMap.autoscroll  := True;
  BandMap.Align       := alClient;
  BandMap.oncdblclick := @BandMapDbClick;
  BandMap.nastav_jazyk(1);
  for i:=1 to MAX_ITEMS do
      BandMapItems[i].Freq:=0;
  BandMapItemsCount := 0;
  ClearAll;
  BandMapThread := TBandMapThread.Create(True);
  BandMapThread.Resume
end;

procedure TfrmBandMap.FormDestroy(Sender: TObject);
begin
  DoneCriticalsection(BandMapCrit)
end;


{$R *.lfm}

end.

