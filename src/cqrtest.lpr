program cqrtest;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, fMain, uCfgStorage, dData, dUtils, fCommonLocal, fCommonGlobal,
  fDBConnect, fGlobalSettings, frStation, frBands, frVisibleColumns;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdmData, dmData);
  Application.CreateForm(TdmUtils, dmUtils);
  Application.CreateForm(TfrmGlobalSettings, frmGlobalSettings);
  Application.Run;
end.

