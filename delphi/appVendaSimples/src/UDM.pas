unit UDM;

interface

uses
  UConstantes,
  app.Funcoes,
  dao.Versao,
  dao.Usuario,

  System.Threading,
  System.IOUtils,
  System.Json,
  System.UITypes,

  FMX.DialogService,
  Web.HttpApp,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.UI, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,

  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,

  System.SysUtils, System.Classes, FMX.Types, FMX.Controls;

type
  TDM = class(TDataModule)
    conn: TFDConnection;
    drvSQLiteDriver: TFDPhysSQLiteDriverLink;
    trans: TFDTransaction;
    waitCursor: TFDGUIxWaitCursor;
    qrySQL: TFDQuery;
    updPedido: TFDUpdateSQL;
    qryPedido: TFDQuery;
    rscUsuario: TRESTClient;
    rscFuncoes: TRESTClient;
    procedure DataModuleCreate(Sender: TObject);
    procedure connAfterConnect(Sender: TObject);
  private
    { Private declarations }
    procedure SetArquivoDB(const aFileName : String);
    procedure ConfigurarUrlUsuario;
    procedure ConfigurarUrlFuncoes;
  public
    { Public declarations }
    procedure ConectarDB;
    procedure UpgradeDB;
    procedure LimparDB; virtual; abstract;
    procedure CriarTabela;

    function IsConectado : Boolean;
    function GetDateTimeServer : TDataHoraServer;
    function GetEncriptString(aValue : String)  : String;
    function GetValidarLogin : TJSONObject;
    function GetCriarNovaCOnta : TJSONObject;
  end;

var
  DM: TDM;

//  function IfThen(aExpressao : Boolean; aTrue, aFalse : TGUID) : TGUID; overload;
  function IfThen(aExpressao : Boolean; aTrue, aFalse : TTipoPedido) : TTipoPedido; overload;
  function IfThen(aExpressao : Boolean; aTrue, aFalse : TTipoCliente) : TTipoCliente; overload;
  function GetTipoClienteStr(aTipo : TTipoCliente) : String;
  function GetTipoPedidoStr(aTipo : TTipoPedido) : String;
  function GetDescricaoTipoPedidoStr(aTipo : TTipoPedido) : String;
  function GetTipoPedido(aStrTipo : String) : TTipoPedido;

  function GetNewID(const aTabela, aCampo, aFiltro : String) : Currency;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses
  classes.ScriptDDL, UMensagem;

{$R *.dfm}

//function IfThen(aExpressao : Boolean; aTrue, aFalse : TGUID) : TGUID;
//begin
//  if aExpressao then
//    Result := aTrue
//  else
//    Result := aFalse;
//end;
//
function IfThen(aExpressao : Boolean; aTrue, aFalse : TTipoPedido) : TTipoPedido;
begin
  if aExpressao then
    Result := aTrue
  else
    Result := aFalse;
end;

function IfThen(aExpressao : Boolean; aTrue, aFalse : TTipoCliente) : TTipoCliente;
begin
  if aExpressao then
    Result := aTrue
  else
    Result := aFalse;
end;

function GetTipoClienteStr(aTipo: TTipoCliente): String;
begin
  case aTipo of
    tcPessoaFisica   : Result := 'F';
    tcPessoaJuridica : Result := 'J';
  end;
end;

function GetTipoPedidoStr(aTipo : TTipoPedido) : String;
begin
  case aTipo of
    TTipoPedido.tpOrcamento : Result := 'O';
    TTipoPedido.tpPedido    : Result := 'P';
  end;
end;

function GetDescricaoTipoPedidoStr(aTipo : TTipoPedido) : String;
begin
  case aTipo of
    TTipoPedido.tpOrcamento : Result := 'Orçamento';
    TTipoPedido.tpPedido    : Result := 'Pedido';
  end;
end;

function GetTipoPedido(aStrTipo : String) : TTipoPedido;
var
  aTipo : String;
begin
  aTipo := AnsiUpperCase(Trim(aStrTipo));
  if aTipo = GetTipoPedidoStr(TTipoPedido.tpOrcamento) then
    Result := TTipoPedido.tpOrcamento
  else
  if aTipo = GetTipoPedidoStr(TTipoPedido.tpPedido) then
    Result := TTipoPedido.tpPedido;
end;

procedure TDM.ConectarDB;
begin
  try
    conn.Connected := True;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar conectar-se com o banco de dados. ' + #13 + E.Message);
  end;
end;

function GetNewID(const aTabela, aCampo, aFiltro : String) : Currency;
var
  aRetorno : Currency;
  aQuery   : TFDQuery;
begin
  aRetorno := 0;
  aQuery   := TFDQuery.Create(DM);
  try
    with DM, aQuery do
    begin
      aQuery.Connection  := conn;
      aQuery.Transaction := trans;

      SQL.BeginUpdate;
      SQL.Clear;
      SQL.Add('Select');
      SQL.Add('  ifnull(max(' + aCampo + '), 0) as valor');
      SQL.Add('from ' + aTabela);

      if (Trim(aFiltro) <> EmptyStr) then
        SQL.Add('where ' + Trim(aFiltro));

      SQL.EndUpdate;

      if OpenOrExecute then
        if not FieldByName('valor').IsNull then
          aRetorno := FieldByName('valor').AsCurrency + 1
        else
          aRetorno := 1;
    end;
  finally
    aQuery.Close;
    aQuery.Free;

    Result := aRetorno;
  end;
end;

procedure TDM.ConfigurarUrlFuncoes;
begin
  with rscFuncoes do
  begin
    BaseURL := URL_ROOT + URL_FUNCOES;
    Accept  := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
    AcceptCharset := 'utf-8, *;q=0.8';
  end;
end;

procedure TDM.ConfigurarUrlUsuario;
begin
  with rscUsuario do
  begin
    BaseURL := URL_ROOT + URL_USUARIO;
    Accept  := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
    AcceptCharset := 'utf-8, *;q=0.8';
  end;
end;

procedure TDM.connAfterConnect(Sender: TObject);
begin
  CriarTabela;
end;

procedure TDM.CriarTabela;
var
  aScriptDDL : TScriptDDL;
begin
  aScriptDDL := TScriptDDL.GetInstance;
  conn.ExecSQL(aScriptDDL.getCreateTableVersao.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableConfiguracao.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableLoja.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableUsuario.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableCliente.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTablePedido.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTablePedidoItem.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableNotificacao.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableProduto.Text, True);
end;

procedure TDM.DataModuleCreate(Sender: TObject);
var
  aFileDB : String;
begin
  // .\assets\internal\ -- Android
  // StartUp\Documents\ -- ISO
  aFileDB := EmptyStr;

  {$IF DEFINED (ANDROID) || (IOS)}
  aFileDB := TPath.Combine(TPath.GetDocumentsPath, cnsNameDB);
  {$ENDIF}
  {$IF DEFINED (MSWINDOWS)}
  //aFileDB := '.\db\' + cnsNameDB;
  aFileDB := System.SysUtils.GetCurrentDir + '\db\' + cnsNameDB;
  {$ENDIF}

  if (Trim(aFileDB) = EmptyStr) then
    aFileDB := TPath.Combine(TPath.GetDocumentsPath, cnsNameDB);

  SetArquivoDB(aFileDB);
end;

function TDM.GetCriarNovaCOnta: TJSONObject;
var
  aRetorno : TJSONObject;
  aRequestConta : TRESTRequest;
  aKey ,
  aSen : String;
  aStr : AnsiString;
  aUsr : TUsuarioDao;
begin
  try
    ConfigurarUrlUsuario;

    aUsr := TUsuarioDao.GetInstance;
    aKey := AnsiUpperCase( '0x' + MD5(KEY_ENCRIPT + GetDateTimeServer.Data) );
    aSen := GetEncriptString(aUsr.Model.Senha);

    aRetorno := nil;
    aRequestConta := TRESTRequest.Create(rscUsuario);

    with aRequestConta do
    begin
      Client := rscUsuario;
      Method := TRESTRequestMethod.rmPOST;
      Accept := rscUsuario.Accept;
      AcceptCharset      := rscUsuario.AcceptCharset;
      AutoCreateParams   := True;
      SynchronizedEvents := False;
      Resource := 'CriarLogin';
      Timeout  := 30000;

      Params.Clear;
      AddParameter('nome',  HTTPEncode(aUsr.Model.Nome),  TRESTRequestParameterKind.pkGETorPOST);
      AddParameter('email', HTTPEncode(aUsr.Model.Email), TRESTRequestParameterKind.pkGETorPOST);
      AddParameter('senha', HTTPEncode(aSen), TRESTRequestParameterKind.pkGETorPOST);
      AddParameter('token', HTTPEncode(aKey) , TRESTRequestParameterKind.pkGETorPOST);
      Execute;

      if Assigned(Response) then
        if (Pos('retorno', Response.Content) > 0) then
        begin
          aStr := Response.JSONValue.ToString;

          aStr := StringReplace(aStr, '[', '', [rfReplaceAll]);
          aStr := StringReplace(aStr, ']', '', [rfReplaceAll]);

          aRetorno := TJSONObject.ParseJSONValue(TEncoding.ANSI.GetBytes(aStr), 0) as TJSONObject;
        end;
    end;
  finally
    aRequestConta.DisposeOf;
    Result := aRetorno;
  end;
end;

function TDM.GetDateTimeServer : TDataHoraServer;
var
  aRetorno : TDataHoraServer;
  aRequestFuncoes : TRESTRequest;
  aJson : TJSONObject;
  aStr  : String;
begin
  try
    ConfigurarUrlFuncoes;

    aRetorno.Data := FormatDateTime('dd/mm/yyyy', Date);
    aRetorno.Hora := FormatDateTime('hh:mm:ss',   Time);
    aRetorno.DataHora := aRetorno.Data + ' ' + aRetorno.Hora;

    aRequestFuncoes := TRESTRequest.Create(rscFuncoes);

    with aRequestFuncoes do
    begin
      Client := rscFuncoes;
      Method := TRESTRequestMethod.rmPOST;
      Accept := rscFuncoes.Accept;
      AcceptCharset      := rscFuncoes.AcceptCharset;
      AutoCreateParams   := True;
      SynchronizedEvents := False;
      Resource := 'DataHora';
      Timeout  := 30000;

      Params.Clear;
      Execute;

      if Assigned(Response) then
        if (Pos('retorno', Response.Content) > 0) then
        begin
          aStr := Response.JSONValue.ToString;

          aStr := StringReplace(aStr, '[', '', [rfReplaceAll]);
          aStr := StringReplace(aStr, ']', '', [rfReplaceAll]);

          aJson := TJSONObject.ParseJSONValue(TEncoding.ANSI.GetBytes(aStr), 0) as TJSONObject;
          aStr  := StrClearValueJson( HTMLDecode(aJson.Get('retorno').JsonValue.ToString) );

          if (aStr.ToUpper = 'OK') then
          begin
            aRetorno.Data     := StrClearValueJson( HTMLDecode(aJson.Get('data').JsonValue.ToString) );
            aRetorno.Hora     := StrClearValueJson( HTMLDecode(aJson.Get('hora').JsonValue.ToString) );
            aRetorno.DataHora := StrClearValueJson( HTMLDecode(aJson.Get('data_hora').JsonValue.ToString) );
          end;
        end;
    end;
  finally
    aRequestFuncoes.DisposeOf;
    Result := aRetorno;
  end;
end;

function TDM.GetEncriptString(aValue: String): String;
var
  aRetorno : String;
  aRequestFuncoes : TRESTRequest;
  aJson : TJSONObject;
  aStr  : String;
begin
  try
    ConfigurarUrlFuncoes;

    aRetorno := EmptyStr;

    aRequestFuncoes := TRESTRequest.Create(rscFuncoes);

    with aRequestFuncoes do
    begin
      Client := rscFuncoes;
      Method := TRESTRequestMethod.rmPOST;
      Accept := rscFuncoes.Accept;
      AcceptCharset      := rscFuncoes.AcceptCharset;
      AutoCreateParams   := True;
      SynchronizedEvents := False;
      Resource := 'EncriptString';
      Timeout  := 30000;

      Params.Clear;
      AddParameter('texto', HTTPEncode(aValue), TRESTRequestParameterKind.pkGETorPOST);
      AddParameter('chave', HTTPEncode(KEY_ENCRIPT), TRESTRequestParameterKind.pkGETorPOST);
      Execute;

      if Assigned(Response) then
        if (Pos(aValue, Response.Content) > 0) then
        begin
          aStr := Response.JSONValue.ToString;

          aStr := StringReplace(aStr, '[', '', [rfReplaceAll]);
          aStr := StringReplace(aStr, ']', '', [rfReplaceAll]);

          aJson    := TJSONObject.ParseJSONValue(TEncoding.ANSI.GetBytes(aStr), 0) as TJSONObject;
          aRetorno := StrClearValueJson( HTMLDecode(aJson.Get('hash3').JsonValue.ToString) );
        end;
    end;
  finally
    aRequestFuncoes.DisposeOf;
    Result := aRetorno;
  end;
end;

function TDM.GetValidarLogin: TJSONObject;
var
  aRetorno : TJSONObject;
  aRequestLogin : TRESTRequest;
  aKey : String;
  aStr : AnsiString;
  aUsr : TUsuarioDao;
begin
  try
    ConfigurarUrlUsuario;

    aKey := AnsiUpperCase( '0x' + MD5(KEY_ENCRIPT + GetDateTimeServer.Data) );
    aRetorno := nil;
    aRequestLogin := TRESTRequest.Create(rscUsuario);

    with aRequestLogin do
    begin
      Client := rscUsuario;
      Method := TRESTRequestMethod.rmPOST;
      Accept := rscUsuario.Accept;
      AcceptCharset      := rscUsuario.AcceptCharset;
      AutoCreateParams   := True;
      SynchronizedEvents := False;
      Resource := 'ValidarLogin';
      Timeout  := 30000;

      aUsr := TUsuarioDao.GetInstance;

      Params.Clear;
      AddParameter('email', HTTPEncode(aUsr.Model.Email), TRESTRequestParameterKind.pkGETorPOST);
      AddParameter('senha', HTTPEncode(aUsr.Model.Senha), TRESTRequestParameterKind.pkGETorPOST);
      AddParameter('token', HTTPEncode(aKey) , TRESTRequestParameterKind.pkGETorPOST);
      Execute;

      if Assigned(Response) then
        if (Pos('retorno', Response.Content) > 0) then
        begin
          aStr := Response.JSONValue.ToString;

          aStr := StringReplace(aStr, '[', '', [rfReplaceAll]);
          aStr := StringReplace(aStr, ']', '', [rfReplaceAll]);

          aRetorno := TJSONObject.ParseJSONValue(TEncoding.ANSI.GetBytes(aStr), 0) as TJSONObject;
        end;
    end;
  finally
    aRequestLogin.DisposeOf;
    Result := aRetorno;
  end;
end;

function TDM.IsConectado: Boolean;
var
  aRetorno : Boolean;
  aFileDB  : String;
begin
  aRetorno := False;
  try
    try
      if not conn.Connected then
        conn.Connected := True;
      aRetorno := True;
    except
      aFileDB := EmptyStr;

      {$IF DEFINED (ANDROID) || (IOS)}
      aFileDB := TPath.Combine(TPath.GetDocumentsPath, cnsNameDB);
      {$ENDIF}
      {$IF DEFINED (MSWINDOWS)}
      //aFileDB := '.\db\' + cnsNameDB;
      aFileDB := System.SysUtils.GetCurrentDir + '\db\' + cnsNameDB;
      {$ENDIF}

      if (Trim(aFileDB) = EmptyStr) then
        aFileDB := TPath.Combine(TPath.GetDocumentsPath, cnsNameDB);

      SetArquivoDB(aFileDB);

      if not conn.Connected then
        conn.Connected := True;

      aRetorno := True;
    end;
  finally
    Result := aRetorno;
  end;
end;

procedure TDM.SetArquivoDB(const aFileName : String);
begin
  conn.Params.Values['DriverID'] := 'SQLite';
  conn.Params.Values['Database'] := aFileName;
end;

procedure TDM.UpgradeDB;
var
  aScriptDDL : TScriptDDL;
  aVersao : TVersaoDao;
begin
  if conn.Connected then
  begin
    aVersao := TVersaoDao.GetInstance;
    aVersao.Load;
    if (aVersao.Model.Codigo <> VERSION_CODE) then
    begin
      aScriptDDL := TScriptDDL.GetInstance;
      conn.ExecSQL(aScriptDDL.getUpgradeTableVersao.Text, True);

      // Manter última versão como registro
      aVersao.Delete();
      aVersao.Model.Codigo    := VERSION_CODE;
      aVersao.Model.Descricao := VERSION_NAME;
      aVersao.Insert();
    end;
  end;
end;

end.
