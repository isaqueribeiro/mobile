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

  IPPeerClient, Data.Bind.Components, Data.Bind.ObjectScope, Data.DB;

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
    procedure DataModuleCreate(Sender: TObject);
    procedure cnnConexaoBeforeConnect(Sender: TObject);
    procedure cnnConexaoAfterConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function IsConectado : Boolean;
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
  aFile := GetEnvironmentVariable('MEDICAL_NOTICE_DB');
  {$ENDIF}

  cnnConexao.Params.Values['DriverID'] := 'SQLite';
  cnnConexao.Params.Values['Database'] := aFile;
end;

procedure TDtmDados.DataModuleCreate(Sender: TObject);
begin
(*
  // Criando base de dados

  CREATE TABLE tbl_versao (
      cd_versao INTEGER,
      dt_versao DATE
  );

*)
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

end.
