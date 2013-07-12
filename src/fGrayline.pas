unit fGrayline;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, gline2,
  ExtCtrls, Buttons, inifiles, FileUtil;

type

  { TfrmGrayline }

  TfrmGrayline = class(TForm)
    tmrGrayLine: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrGrayLineTimer(Sender: TObject);
  private
    { private declarations }
  public
    offset : Currency;
    ob  : Pgrayline;
    s,d : String;
    pfx : String;
    procedure kresli;
  end;

var
  frmGrayline : TfrmGrayline;
implementation

{ TfrmGrayline }

uses dUtils, dData, uCfgStorage;

procedure TfrmGrayline.FormCreate(Sender: TObject);
var
  ImageFile : String;
begin
  ImageFile := dmData.AppHomeDir+'images'+PathDelim+'grayline.bmp';
  if not FileExists(ImageFile) then
    ImageFile := ExpandFileNameUTF8('..'+PathDelim+'share'+PathDelim+'cqrlog'+
                 PathDelim+'images'+PathDelim+'grayline.bmp');
  ob:=new(Pgrayline,init(ImageFile))
end;

procedure TfrmGrayline.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  tmrGrayLine.Enabled := False
end;

procedure TfrmGrayline.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  tmrGrayLine.Enabled := False;
end;

procedure TfrmGrayline.FormDestroy(Sender: TObject);
begin
  dispose(ob,done)
end;

procedure TfrmGrayline.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not (Shift = [ssCtrl,ssAlt]) then
    key := 0;
end;

procedure TfrmGrayline.FormPaint(Sender: TObject);
var
  r:Trect;
begin
  r.left:=0;r.right:=width-1;
  r.top:=0;r.bottom:=width*obvy div obsi-1;
  ob^.VypocitejSunClock(now);//dmUtils.GetDateTime(0));
  ob^.kresli(r,Canvas)
end;

procedure TfrmGrayline.FormShow(Sender: TObject);
begin
  tmrGrayLine.Enabled := True;
  tmrGrayLineTimer(nil)
end;

procedure TfrmGrayline.tmrGrayLineTimer(Sender: TObject);
var r:Trect;
begin
  r.left:=0;r.right:=width-1;
  r.top:=0;r.bottom:=width*obvy div obsi-1;
  ob^.VypocitejSunClock(dmUtils.GetDateTime(0));
  Refresh
end;

procedure TfrmGrayline.kresli;
var
  lat,long : Currency;
  lat1,long1 : Currency;
  my_loc : String;
begin
  my_loc := iniLocal.ReadString('Station','Grid','');
  if (s='') or (d='') then
    //dmUtils.GetCoordinate(pfx,lat1,long1)
  else begin
    if s[Length(s)] = 'S' then  //pokud je tam S musi byt udaj zaporny
      s := '-' +s ;
    s := copy(s,1,Length(s)-1);
    if pos('.',s) > 0 then
      s[pos('.',s)] := DecimalSeparator;
    if not TryStrToCurr(s,lat1) then
      lat1 := 0;

    if d[Length(d)] = 'W' then  //pokud je tam W musi byt udaj zaporny
      d := '-' + d ;
    d := copy(d,1,Length(d)-1);
    if pos('.',d) > 0 then
      d[pos('.',d)] := DecimalSeparator;
    if not TryStrToCurr(d,long1) then
      long1 := 0
  end;
  s := '';
  d := '';
  //dmUtils.CoordinateFromLocator(my_loc,lat,long);
  lat := lat*-1;
  lat1 := lat1*-1;
  ob^.jachcucaru(true,long,lat,long1,lat1);
  Refresh
end;

initialization
  {$I fGrayline.lrs}

end.

