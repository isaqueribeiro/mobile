unit UDM;

interface

uses
  System.Threading,
  System.IOUtils,
  FMX.DialogService,
  System.UITypes,

  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client;

type
  TDM = class(TDataModule)
    conn: TFDConnection;
    drvSQLiteDriver: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure connAfterConnect(Sender: TObject);
  private
    { Private declarations }
    procedure SetArquivoDB(const aFileName : String);
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses
  UConstantes, classes.ScriptDDL;

{$R *.dfm}

procedure TDM.connAfterConnect(Sender: TObject);
var
  aScriptDDL : TScriptDDL;
begin
  aScriptDDL := TScriptDDL.GetInstance;
  conn.ExecSQL(aScriptDDL.getCreateTableVersao.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableUsuario.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableCliente.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTablePedido.Text, True);
  conn.ExecSQL(aScriptDDL.getCreateTableNotificacao.Text, True);
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
  try
    conn.Params.Values['DriverID'] := 'SQLite';
    conn.Params.Values['Database'] := aFileName;
    conn.Connected := True;
  except
    On E : Exception do
      raise Exception.Create('Erro ao tentar conectar-se com o banco de dados. ' + #13 + E.Message);
  end;
end;

end.
