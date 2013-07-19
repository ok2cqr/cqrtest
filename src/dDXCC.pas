unit dDXCC;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil;

type

  { TdmDXCC }

  TdmDXCC = class(TDataModule)
    Q: TSQLQuery;
    Q1: TSQLQuery;
    qDXCCRef: TSQLQuery;
    trQ: TSQLTransaction;
    trQ1: TSQLTransaction;
    trDXCCRef: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  dmDXCC: TdmDXCC;

implementation

uses dData;

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
end;

{$R *.lfm}

end.

