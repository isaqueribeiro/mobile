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
    property Lista : TListaCategoria read FLista;

    procedure New;
    procedure Load(var aErro : String); virtual; abstract;

    function Insert(var aErro : String) : Boolean;
    function Update(var aErro : String) : Boolean;
    function Delete(var aErro : String) : Boolean;
    function Find(aCodigo : Integer; var aErro : String;
      const RETURN_ATTRIBUTES : Boolean = FALSE) : Boolean; virtual; abstract;
  end;

implementation

{ TCategoriaController }

uses
    DataModule.Conexao
  , Classes.ScriptDDL
  , System.SysUtils
  , FireDAC.Comp.Client
  , Data.DB;

constructor TCategoriaCOntroller.Create;
begin
  FModel := TCategoriaModel.New;
  SetLength(FLista, 0);

  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(TScriptDDL.getInstance().getCreateTableCategoria.Text, True);
end;

function TCategoriaController.Delete(var aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Codigo < 1 then
  begin
    aErro := 'Informe o código da categoria';
    Abort;
  end;

  // Verificar se existe lançamentos para a categoria
  // ???



  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Delete from ' + TScriptDDL.getInstance().getTableNameCategoria);
        Add('where cd_categoria = :cd_categoria');
        EndUpdate;

        ParamByName('cd_categoria').Value := FModel.Codigo;

        ExecSQL;

        Result := True;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar excluir a categoria: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
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

function TCategoriaController.Insert(var aErro : String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Descricao.IsEmpty then
  begin
    aErro := 'Informe a descrição da categoria';
    Abort;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Insert Into ' + TScriptDDL.getInstance().getTableNameCategoria + '(');
        Add('    ds_categoria  ');
        Add('  , ic_categoria  ');
        Add('  , ix_categoria  ');
        Add(') values (');
        Add('    :ds_categoria ');
        Add('  , :ic_categoria ');
        Add('  , :ix_categoria ');
        Add(')');
        EndUpdate;

        ParamByName('ds_categoria').Value := FModel.Descricao;
        ParamByName('ix_categoria').Value := FModel.Indice;
        ParamByName('ds_categoria').Assign( FModel.Icone );

        ExecSQL;

        FModel.Codigo := TDMConexao.GetInstance().GetLastInsertRowID;

        Result := (FModel.Codigo > 0);
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar inserir a categoria: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TCategoriaController.New;
begin
  with FModel do
  begin
    Codigo    := 0;
    Descricao := EmptyStr;
    Indice    := 0;
    Icone     := nil;
  end;
end;

function TCategoriaController.Update(var aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Codigo < 1 then
  begin
    aErro := 'Informe o código da categoria';
    Abort;
  end;

  if FModel.Descricao.IsEmpty then
  begin
    aErro := 'Informe a descrição da categoria';
    Abort;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Update ' + TScriptDDL.getInstance().getTableNameCategoria + ' set ');
        Add('    ds_categoria = :ds_categoria ');
        Add('  , ic_categoria = :ic_categoria ');
        Add('  , ix_categoria = :ix_categoria ');
        Add('where cd_categoria = :cd_categoria');
        EndUpdate;

        ParamByName('cd_categoria').Value := FModel.Codigo;
        ParamByName('ds_categoria').Value := FModel.Descricao;
        ParamByName('ix_categoria').Value := FModel.Indice;
        ParamByName('ds_categoria').Assign( FModel.Icone );

        ExecSQL;

        Result := True;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar atualizar a categoria: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
