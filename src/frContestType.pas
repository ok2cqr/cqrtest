unit frContestType;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, IniFiles;

type
  TContestType = class
    private
      fContestName : String;
      fFileName    : String;
      fFilePath    : String;
      fGlobalFile  : Boolean;
    public
      property ContestName : String read fContestName;
      property FileName    : String read fFileName;
      property FilePath    : String read fFilePath;
      property GlobalFile  : Boolean read fGlobalFile;

      constructor Create(TestName,TestFileName,TestFilePath : String;TestGlobalFile : Boolean);
  end;


type

  { TfraContestType }

  TfraContestType = class(TFrame)
    btnCopyContestType: TButton;
    btnModifyContestType: TButton;
    btnDeleteContestType: TButton;
    cmbContestType: TComboBox;
    Label1: TLabel;
    procedure btnCopyContestTypeClick(Sender: TObject);
    procedure cmbContestTypeChange(Sender: TObject);
  private
    fContestFileName : String;
    fContestFilePath : String;

    function getContestFileName : String;
    function getContestFilePath : String;
  public
    property ContestTypeFileName : String read getContestFileName write fContestFileName;
    property ContestTypeFilePath : String read getContestFilePath write fContestFilePath;

    procedure Init;
    procedure LoadContestList;
  end;

implementation

{$R *.lfm}

uses dData;

{ TfraContestType }

constructor TContestType.Create(TestName,TestFileName,TestFilePath : String;TestGlobalFile : Boolean);
begin
  fContestName := TestName;
  fFilePath    := TestFilePath;
  fFileName    := TestFileName;
  fGlobalFile  := TestGlobalFile
end;

procedure TfraContestType.Init;
var
  selected : TContestType;
  i        : Integer;
begin
  LoadContestList;
  if ContestTypeFileName <> '' then
  begin
    for i:=0 to cmbContestType.Items.Count-1 do
    begin
      selected := cmbContestType.Items.Objects[cmbContestType.ItemIndex] as TContestType;
      if (selected.FileName=fContestFileName) and (selected.FilePath=fContestFilePath) then
      begin
        cmbContestType.ItemIndex := i;
        break
      end
    end
  end
end;

procedure TfraContestType.cmbContestTypeChange(Sender: TObject);
var
  selected : TContestType;
begin
  selected := cmbContestType.Items.Objects[cmbContestType.ItemIndex] as TContestType;
  btnCopyContestType.Enabled   := Pos('>>>>',selected.ContestName)=1;
  btnDeleteContestType.Enabled := Pos('>>>>',selected.ContestName)=1;
  btnModifyContestType.Enabled := Pos('>>>>',selected.ContestName)=1;
  btnModifyContestType.Enabled := not selected.GlobalFile
end;

procedure TfraContestType.btnCopyContestTypeClick(Sender: TObject);
begin

end;

procedure TfraContestType.LoadContestList;

  procedure SearchForContestRules(Path : String; Global : Boolean=False);
  var
    s         : String;
    res       : Byte;
    SearchRec : TSearchRec;
    ini       : TIniFile;
    TestName  : String;
  begin
    res := FindFirst(Path + '*.'+cRulesExt, faAnyFile, SearchRec);
    while Res = 0 do
    begin
      if (FileExistsUTF8(SearchRec.Name)) then
      begin
        Writeln(s+SearchRec.Name);
        ini := TIniFile.Create(s+SearchRec.Name);
        try
          TestName := ini.ReadString('contest','name','');
          if TestName<>'' then
          begin
            cmbContestType.AddItem(ini.ReadString('contest','name',''),
              TContestType.Create(TestName,SearchRec.Name,s,Global)
            )
          end
        finally
          FreeAndNil(ini)
        end
      end;
      Res := FindNext(SearchRec)
    end;
    FindClose(SearchRec)
  end;

var
  s : String;
begin
  cmbContestType.Clear;

  cmbContestType.AddItem('>>>> GLOBAL CONTEST RULES <<<<',
    TContestType.Create('>>>> GLOBAL CONTEST RULES <<<<','','',False)
  );
  s := ExpandFileNameUTF8('..'+PathDelim+'share'+PathDelim+'cqrtest'+PathDelim+cRulesDir+PathDelim);
  SearchForContestRules(s,True);

  cmbContestType.AddItem('>>>> LOCAL CONTESTS RULES <<<<',
    TContestType.Create('>>>> LOCAL CONTESTS RULES <<<<','','',False)
  );
  s := dmData.AppHomeDir+cRulesDir+PathDelim;
  SearchForContestRules(s,False)
end;

function TfraContestType.getContestFileName : String;
var
  selected : TContestType;
begin
  selected := cmbContestType.Items.Objects[cmbContestType.ItemIndex] as TContestType;
  Result   := selected.FileName
end;

function TfraContestType.getContestFilePath : String;
var
  selected : TContestType;
begin
  selected := cmbContestType.Items.Objects[cmbContestType.ItemIndex] as TContestType;
  Result   := selected.FilePath
end;


end.

