unit UDados;

interface

uses
  REST.Client,
  Web.HTTPApp,
  REST.Types,
  System.IOUtils,

  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Phys, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.Comp.Client, FireDAC.FMXUI.Wait, FireDAC.Comp.UI,
  IPPeerClient, Data.Bind.Components, Data.Bind.ObjectScope;

type
  TDtmDados = class(TDataModule)
    FdBase: TFDManager;
    FdSQLiteDriver: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    procedure DataModuleCreate(Sender: TObject);
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

{$R *.dfm}

{ TDtmDados }

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
  aFile : String;
begin
  aFile := TPath.Combine(TPath.GetDocumentsPath, 'medical_notice.db');
end;

end.
