program cqrtest;

{$mode objfpc}{$H+}

uses
  cthreads,
  Interfaces, // this includes the LCL widgetset
  Forms, fMain, uCfgStorage, dData, dUtils, fCommonLocal, fCommonGlobal,
  fDBConnect, fGlobalSettings, frStation, frBands, frVisibleColumns, fAbout,
  fGrayline, fImportProgress, dDXCC, jakozememo, fBandMap, fDXCluster,
  fDXClusterList, fNewDXCluster;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdmData, dmData);
  Application.CreateForm(TdmDXCC, dmDXCC);
  Application.CreateForm(TdmUtils, dmUtils);
  Application.CreateForm(TfrmGrayline, frmGrayline);
  Application.CreateForm(TfrmDXCluster, frmDXCluster);
  Application.Run;
end.

