unit UDados;

interface

uses
  REST.Client,
  REST.Types,
  Web.HTTPApp,
  System.JSON,
  classes.Constantes,


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
    cnnConexao: TFDConnection;
    FDTransaction: TFDTransaction;
    qrySQL: TFDQuery;
    RESTClientUsuario: TRESTClient;
    RESTRequestUsuario: TRESTRequest;
    RESTResponseUsuario: TRESTResponse;
    RESTClientEspecialidade: TRESTClient;
    RESTRequestEspecialidade: TRESTRequest;
    RESTResponseEspecialidade: TRESTResponse;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    procedure cnnConexaoBeforeConnect(Sender: TObject);
    procedure cnnConexaoAfterConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    aFileDB : String;
    procedure DefinirArquivoDB;
  public
    { Public declarations }
    procedure SetSQLExecute(aSQL : TStringList);

    function IsConectado : Boolean;
    function GetNextValue(aTableName, aFieldName : String) : Integer;

    function HttpGetEspecialidade(const aKey : String) : TJSONValue;
    function HttpGetUsuario(const aKey : String) : TJSONValue;
    function HttpPostUsuario(const aKey : String) : TJSONValue;
  end;

var
  DtmDados: TDtmDados;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses
    classes.ScriptDDL
  , dao.Usuario;

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
begin
  cnnConexao.Params.Values['DriverID'] := 'SQLite';
  cnnConexao.Params.Values['Database'] := aFileDB;
end;

procedure TDtmDados.DataModuleCreate(Sender: TObject);
begin
  aFileDB := EmptyStr;

  {$IF DEFINED (ANDROID) || (IOS)}
  aFileDB := TPath.Combine(TPath.GetDocumentsPath, 'medical_notice.db');
  {$ENDIF}
  {$IF DEFINED (MSWINDOWS)}
  //aFileDB := GetEnvironmentVariable('MEDICAL_NOTICE_DB');
  aFileDB := 'medical_notice.db';
  {$ENDIF}

  if (Trim(aFileDB) = EmptyStr) then
    aFileDB := TPath.Combine(TPath.GetDocumentsPath, 'medical_notice.db');
end;

procedure TDtmDados.DefinirArquivoDB;
begin
  // .\assets\internal\ -- Android
  // StartUp\Documents\ -- ISO
  cnnConexao.Params.Values['DriverID'] := 'SQLite';
  cnnConexao.Params.Values['Database'] := aFileDB;
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

function TDtmDados.HttpGetEspecialidade(const aKey: String): TJSONValue;
var
  aRetorno : TJSONValue;
begin
  try
    with RESTRequestEspecialidade, Params do
    begin
      Method   := rmGET;
      Resource := PAGE_ESPECIALIDADE + '?hash={hash}';
      Params.AddUrlSegment('hash', aKey);
      Execute;

      aRetorno := Response.JSONValue;
    end;
  finally
    Result := aRetorno;
  end;
end;

function TDtmDados.HttpGetUsuario(const aKey : String): TJSONValue;
var
  aRetorno    : TJSONValue;
  aUsuarioDao : TUsuarioDao;
  aParams     : String;
begin
  try
    aUsuarioDao := TUsuarioDao.GetInstance;
    aParams     := 'user=' + aUsuarioDao.Model.Codigo + '&pwd=' + aUsuarioDao.Model.Senha;

    with RESTRequestUsuario, Params do
    begin
      Method   := rmGET;
      Resource := PAGE_USUARIO + '?hash={hash}&' + aParams;
      Params.AddUrlSegment('hash', aKey);
      Execute;

      aRetorno := Response.JSONValue;
    end;
  finally
    Result := aRetorno;
  end;
end;

function TDtmDados.HttpPostUsuario(const aKey: String): TJSONValue;
var
  aRetorno     : TJSONValue;
  aUsuarioDao  : TUsuarioDao;
  aUsuarioJson : TJSONObject;
begin
  aUsuarioJson := TJSONObject.Create;
  try
    aUsuarioDao  := TUsuarioDao.GetInstance;

    aUsuarioJson.AddPair('id_usuario',    GUIDToString(aUsuarioDao.Model.Id));
    aUsuarioJson.AddPair('cd_usuario',    aUsuarioDao.Model.Codigo);
    aUsuarioJson.AddPair('ds_email',      aUsuarioDao.Model.Email);
    aUsuarioJson.AddPair('ds_observacao', aUsuarioDao.Model.Observacao);

    with RESTRequestUsuario, Params do
    begin
      Method   := rmPOST;
      Resource := PAGE_USUARIO + '?hash={hash}&id_acao=saveUser';
      Params.AddUrlSegment('hash', aKey);
      AddBody(aUsuarioJson);
      Execute;

      Sleep(500);

      aRetorno := Response.JSONValue;
    end;
  finally
    aUsuarioJson.Free;
    Result := aRetorno;
  end;
end;

function TDtmDados.IsConectado: Boolean;
var
  aRetorno : Boolean;
begin
  aRetorno := False;
  try
    try
      if not cnnConexao.Connected then
        cnnConexao.Connected := True;
      aRetorno := True;
    except
      aFileDB := StringReplace(TPath.GetDocumentsPath, 'Documents', 'medical_notice.db', []);
      if not cnnConexao.Connected then
        cnnConexao.Connected := True;
      aRetorno := True;
    end;
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
