unit Controller.Categoria;

interface

uses
  Model.Categoria;

type
  TCategoriaController = class
  strict private
    class var _instance : TCategoriaCOntroller;
  private
    FModel : TCategoriaModel;
    FLista : TListaCategoria;
  protected
    constructor Create;
    destructor Destroy; override;
  public
    class function GetInstance : TCategoriaCOntroller;

    property Attributes : TCategoriaModel read  FModel;
  end;

implementation

{ TCategoriaController }

uses
    DataModule.Conexao
  , Classes.ScriptDDL;

constructor TCategoriaCOntroller.Create;
begin
  FModel := TCategoriaModel.New;
  SetLength(FLista, 0);

  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(TScriptDDL.getInstance().getCreateTableCategoria.Text, True);
end;

destructor TCategoriaCOntroller.Destroy;
begin
  FModel.DisposeOf;

  while (High(FLista) > -1) do
    FLista[0].DisposeOf;

  inherited;
end;

class function TCategoriaCOntroller.GetInstance: TCategoriaCOntroller;
begin
  if not Assigned(_instance) then
    _instance := TCategoriaCOntroller.Create;

  Result := _instance;
end;

end.
