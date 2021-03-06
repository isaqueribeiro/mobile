unit DataModule.Conexao;

interface

uses
  FMX.Forms, System.SysUtils, System.Classes, System.IOUtils, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDMConexao = class(TDataModule)
    Conn: TFDConnection;
    Qry: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
  strict private
    class var _instance : TDMConexao;
  private
    { Private declarations }
    FFileBase : String;
  public
    { Public declarations }
    class function GetInstance() : TDMConexao;
    class function Instanciado : Boolean;
    class function GetLastInsertRowID : Integer;
    class function GetNexID(aTableName, aFieldName : String) : Integer;
  end;

//var
//  DMConexao: TDMConexao;
//
implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TDMConexao }

uses
  System.UITypes;

procedure TDMConexao.ConnBeforeConnect(Sender: TObject);
begin
  Conn.Params.Values['DriverID'] := 'SQLite';
  Conn.Params.Values['Database'] := FFileBase;
end;

procedure TDMConexao.DataModuleCreate(Sender: TObject);
begin
  Conn.Connected := False;

  Conn.Params.BeginUpdate;
  Conn.Params.Clear;
  Conn.Params.EndUpdate;

  {$IFDEF MSWINDOWS}
  FFileBase := TPath.Combine(System.SysUtils.GetCurrentDir, 'db\financeiro_simples.db');
  {$ELSE}
  FFileBase := TPath.Combine(TPath.GetDocumentsPath, 'financeiro_simples.db');
  {$ENDIF}
end;

class function TDMConexao.GetInstance: TDMConexao;
begin
  if not Assigned(_instance) then
    _instance := TDMConexao.Create(Application);

  Result := _instance;
end;

class function TDMConexao.GetLastInsertRowID: Integer;
var
  aQry : TFDQuery;
begin
  Result := 0;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    with aQry, SQL do
    begin
      BeginUpdate;
      Clear;

      Add('SELECT last_insert_rowid() as ID');

      EndUpdate;
      Open;

      Result := FieldByName('ID').AsInteger;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

class function TDMConexao.GetNexID(aTableName, aFieldName: String): Integer;
var
  aQry : TFDQuery;
begin
  Result := 0;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    with aQry, SQL do
    begin
      BeginUpdate;
      Clear;

      Add('SELECT max(' + aFieldName + ') as ID from ' + aTableName);

      EndUpdate;
      Open;

      if not FieldByName('ID').IsNull then
        Result := (FieldByName('ID').AsInteger + 1)
      else
        Result := 1;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

class function TDMConexao.Instanciado: Boolean;
begin
  Result := Assigned(_instance);
end;

end.
