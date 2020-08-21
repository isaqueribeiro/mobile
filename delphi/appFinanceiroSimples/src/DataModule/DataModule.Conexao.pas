unit DataModule.Conexao;

interface

uses
  FMX.Forms, System.SysUtils, System.Classes, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs;

type
  TDMConexao = class(TDataModule)
    Conn: TFDConnection;
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
//  Conn.Params['DriverID'] := 'SQLite';
//  Conn.Params['Database'] := FFileBase;
end;

procedure TDMConexao.DataModuleCreate(Sender: TObject);
begin
  Conn.Connected := False;

  Conn.Params.BeginUpdate;
  Conn.Params.Clear;
  Conn.Params.EndUpdate;

  {$IFDEF MSWINDOWS}
  FFileBase := ExtractFilePath(ParamStr(0)) + 'db\financeiro_simples.db';
  {$ELSE}
  FFileBase := TPath.Combine();
  {$ENDIF}
//
//  Conn.Connected := True;
end;

class function TDMConexao.GetInstance: TDMConexao;
begin
  if not Assigned(_instance) then
    _instance := TDMConexao.Create(Application);

  Result := _instance;
end;

end.
