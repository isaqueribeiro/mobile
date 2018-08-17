unit UDados;

interface

uses
  REST.Client,
  Web.HTTPApp,
  REST.Types,

  System.IOUtils,

  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Phys, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, FireDAC.Comp.Client, FireDAC.FMXUI.Wait,
  FireDAC.Comp.UI, FireDAC.Stan.Pool, FireDAC.Stan.Async,

  IPPeerClient, Data.Bind.Components, Data.Bind.ObjectScope, Data.DB,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TDtmDados = class(TDataModule)
    FdSQLiteDriver: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    RESTClientGET: TRESTClient;
    RESTRequestGET: TRESTRequest;
    RESTResponseGET: TRESTResponse;
    cnnConexao: TFDConnection;
    FDTransaction: TFDTransaction;
    RESTClientPOST: TRESTClient;
    RESTRequestPOST: TRESTRequest;
    RESTResponsePOST: TRESTResponse;
    qrySQL: TFDQuery;
    procedure cnnConexaoBeforeConnect(Sender: TObject);
    procedure cnnConexaoAfterConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetSQLExecute(aSQL : TStringList);

    function IsConectado : Boolean;
    function GetNextValue(aTableName, aFieldName : String) : Integer;
  end;

var
  DtmDados: TDtmDados;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses
  classes.ScriptDDL;

{$R *.dfm}

{ TDtmDados }

procedure TDtmDados.cnnConexaoAfterConnect(Sender: TObject);
var
  aScriptDDL : TScriptDDL;
begin
  aScriptDDL := TScriptDDL.GetInstance;
  cnnConexao.ExecSQL(aScriptDDL.getCreateTableVersao.Text, True);
  cnnConexao.ExecSQL(aScriptDDL.getCreateTableEspecialidade.Text, True);
  cnnConexao.ExecSQL(aScriptDDL.getCreateTableUsuario.Text, True);
end;

procedure TDtmDados.cnnConexaoBeforeConnect(Sender: TObject);
var
  aFile : String;
begin
  // .\assets\internal\ -- Android
  // StartUp\Documents\ -- ISO

  {$IF DEFINED (ANDROID) || (IOS)}
  aFile := TPath.Combine(TPath.GetDocumentsPath, 'medical_notice.db');
  {$ENDIF}
  {$IF DEFINED (MSWINDOWS)}
  //aFile := GetEnvironmentVariable('MEDICAL_NOTICE_DB');
  aFile := 'medical_notice.db';
  {$ENDIF}

  cnnConexao.Params.Values['DriverID'] := 'SQLite';
  cnnConexao.Params.Values['Database'] := aFile;
end;

function TDtmDados.GetNextValue(aTableName, aFieldName : String): Integer;
var
  aValue : Integer;
begin
  aValue := 0;
  try
    qrySQL.Close;
    qrySQL.SQL.Text := 'Select max(' + aFieldName + ') as valor from ' + aTableName;
    qrySQL.OpenOrExecute;
    aValue := (qrySQL.FieldByName('valor').AsInteger + 1);
  finally
    if qrySQL.Active then
      qrySQL.Close;

    Result := aValue;
  end;
end;

function TDtmDados.IsConectado: Boolean;
var
  aRetorno : Boolean;
begin
  aRetorno := False;
  try
    if not cnnConexao.Connected then
      cnnConexao.Connected := True;
    aRetorno := True;
  finally
    Result := aRetorno;
  end;
end;

procedure TDtmDados.SetSQLExecute(aSQL: TStringList);
begin
  if qrySQL.Active then
    qrySQL.Close;
  qrySQL.SQL.Clear;
  qrySQL.ClearFields;
  qrySQL.SQL.AddStrings( aSQL );
end;

end.
