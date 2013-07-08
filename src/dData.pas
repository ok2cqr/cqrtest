unit dData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil;

type

  { TdmData }

  TdmData = class(TDataModule)
    qLogList: TSQLQuery;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  dmData: TdmData;

implementation

{$R *.lfm}

end.

