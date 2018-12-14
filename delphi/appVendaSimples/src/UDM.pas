unit UDM;

interface

uses
  UConstantes,
  System.Threading,
  System.IOUtils,
  FMX.DialogService,
  System.UITypes,

  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.UI,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TDM = class(TDataModule)
    conn: TFDConnection;
    drvSQLiteDriver: TFDPhysSQLiteDriverLink;
    trans: TFDTransaction;
    waitCursor: TFDGUIxWaitCursor;
    qrySQL: TFDQuery;
    updPedido: TFDUpdateSQL;
    qryPedido: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure connAfterConnect(Sender: TObject);
  private
    { Private declarations }
    procedure SetArquivoDB(const aFileName : String);
    procedure CriarTabela;
  public
    { Public declarations }
    procedure ConectarDB;
  end;

var
  DM: TDM;

//  function IfThen(aExpressao : Boolean; aTrue, aFalse : TGUID) : TGUID; overload;
  function IfThen(aExpressao : Boolean; aTrue, aFalse : TTipoPedido) : TTipoPedido; overload;
  function IfThen(aExpressao : Boolean; aTrue, aFalse : TTipoCliente) : TTipoCliente; overload;
  function GetTipoClienteStr(aTipo : TTipoCliente) : String;

  function GetNewID(const aTabela, aCampo : String) : Currency;

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

procedure TDM.ConectarDB;
begin
  try
    conn.Connected := True;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar conectar-se com o banco de dados. ' + #13 + E.Message);
  end;
end;

function GetNewID(const aTabela, aCampo : String) : Currency;
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
      SQL.Add('  max(' + aCampo + ') as valor');
      SQL.Add('from ' + aTabela);
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
  conn.ExecSQL(aScriptDDL.getCreateTableUsuario.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableCliente.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTablePedido.Text, True);
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

procedure TDM.SetArquivoDB(const aFileName : String);
begin
  conn.Params.Values['DriverID'] := 'SQLite';
  conn.Params.Values['Database'] := aFileName;
end;

end.
