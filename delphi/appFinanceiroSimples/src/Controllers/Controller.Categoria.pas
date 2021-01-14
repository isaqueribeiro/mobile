unit Controller.Categoria;

interface

uses
    Services.ComplexTypes
  , Classes.ScriptDDL
  , Model.Categoria
  , System.Generics.Collections
  , FireDAC.Comp.Client
  , Data.DB;

type
  TCategoriaController = class
    strict private
      class var _instance : TCategoriaCOntroller;
    private
      FOperacao : TTipoOperacaoController;
      FDDL   : TScriptDDL;
      FModel : TCategoriaModel;
      FLista : TDictionary<integer, TCategoriaModel>;
      FSelecao : TList<TCategoriaModel>;
      procedure SetAtributes(const aDataSet : TDataSet; aModel : TCategoriaModel);
    protected
      constructor Create;
      destructor Destroy; override;
    public
      class function GetInstance : TCategoriaCOntroller;

      property Operacao : TTipoOperacaoController read FOperacao;
      property Attributes : TCategoriaModel read  FModel;
      property Lista : TDictionary<integer, TCategoriaModel> read FLista;
      property Selecao : TList<TCategoriaModel> read FSelecao;

      procedure New;
      procedure Load(out aErro : String);

      function Insert(out aErro : String) : Boolean;
      function Update(out aErro : String) : Boolean;
      function Delete(out aErro : String) : Boolean;
      function Find(aCodigo : Integer; out aErro : String;
        const RETURN_ATTRIBUTES : Boolean = FALSE) : Boolean;

      function ValidarExclusao(out aErro : String) : Boolean;
  end;

implementation

{ TCategoriaController }

uses
    DataModule.Conexao
  , System.SysUtils
  , FMX.Graphics;

constructor TCategoriaCOntroller.Create;
begin
  FOperacao := TTipoOperacaoController.operControllerBrowser;
  FDDL   := TScriptDDL.getInstance();
  FModel := TCategoriaModel.New;
  FLista := TDictionary<integer, TCategoriaModel>.Create;
  FSelecao := TList<TCategoriaModel>.Create;

  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(FDDL.getCreateTableCategoria.Text, True);
end;

function TCategoriaController.Delete(out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  aQry  := TFDQuery.Create(nil);
  try
    aQry.Connection  := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Delete from ' + FDDL.getTableNameCategoria);
        Add('where cd_categoria = :cd_categoria');
        EndUpdate;

        ParamByName('cd_categoria').Value := FModel.Codigo;

        ExecSQL;

        Result := True;

        if FLista.ContainsKey(FModel.Codigo) then
        begin
          FLista.Remove(FModel.Codigo);
          FLista.TrimExcess;
        end;

        if (FSelecao.IndexOf(FModel) > -1) then
        begin
          FSelecao.Remove(FModel);
          FSelecao.TrimExcess;
        end;

        FOperacao := TTipoOperacaoController.operControllerDelete;
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
var
  aObj : TCategoriaModel;
  I : Integer;
begin
  FDDL.DisposeOf;
  FModel.DisposeOf;

  if Assigned(FLista) then
  begin
    for aObj in FLista.Values do
    begin
      FLista.Remove(aObj.Codigo);
      aObj.DisposeOf;
    end;

    FLista.Clear;
    FLista.TrimExcess;
    FLista.DisposeOf;
  end;

  if Assigned(FSelecao) then
  begin
    for I := 0 to FSelecao.Count - 1 do
    begin
      aObj := FSelecao.Items[I];
      FSelecao.Delete(I);
      aObj.DisposeOf;
    end;

    FSelecao.Clear;
    FSelecao.TrimExcess;
    FSelecao.DisposeOf;
  end;

  inherited;
end;

function TCategoriaController.Find(aCodigo: Integer; out aErro: String; const RETURN_ATTRIBUTES: Boolean): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  FOperacao := TTipoOperacaoController.operControllerBrowser;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Select ');
        Add('    cd_categoria  ');
        Add('  , ds_categoria  ');
        Add('  , ic_categoria  ');
        Add('  , ix_categoria  ');
        Add('from ' + FDDL.getTableNameCategoria);
        Add('where (cd_categoria = :cd_categoria)');
        EndUpdate;

        ParamByName('cd_categoria').Value := aCodigo;

        Open;

        Result := not IsEmpty;

        if Result and RETURN_ATTRIBUTES then
          SetAtributes(aQry, FModel);
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar localizar a categoria: ' + E.Message;
    end;
  finally
    aQry.Close;
    aQry.DisposeOf;
  end;
end;

class function TCategoriaCOntroller.GetInstance: TCategoriaCOntroller;
begin
  if not Assigned(_instance) then
    _instance := TCategoriaCOntroller.Create;

  Result := _instance;
end;

function TCategoriaController.Insert(out aErro : String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Descricao.IsEmpty then
  begin
    aErro := 'Informe a descrição da categoria';
    Exit;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Insert Into ' + FDDL.getTableNameCategoria + '(');
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

        if Assigned(FModel.Icone) then
          ParamByName('ic_categoria').Assign( FModel.Icone )
        else
          ParamByName('ic_categoria').Clear;

        ExecSQL;

        FModel.Codigo := TDMConexao.GetInstance().GetLastInsertRowID;

        Result    := (FModel.Codigo > 0);
        FOperacao := TTipoOperacaoController.operControllerInsert;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar inserir a categoria: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TCategoriaController.Load(out aErro: String);
var
  aModel : TCategoriaModel;
  aQry : TFDQuery;
begin
  FOperacao := TTipoOperacaoController.operControllerBrowser;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Select ');
        Add('    cd_categoria  ');
        Add('  , ds_categoria  ');
        Add('  , ic_categoria  ');
        Add('  , ix_categoria  ');
        Add('from ' + FDDL.getTableNameCategoria);
        Add('order by');
        Add('    ds_categoria');
        EndUpdate;

        Open;

        Lista.Clear;
        FSelecao.Clear;

        while not Eof do
        begin
          aModel := TCategoriaModel.Create;

          SetAtributes(aQry, aModel);
          FLista.AddOrSetValue(aModel.Codigo, aModel);
          FSelecao.Add(aModel);

          Next;
        end;

        // Limitar o tamanho da lista à quantidade de objetos encontrados
        Lista.TrimExcess;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar carregar as categorias: ' + E.Message;
    end;
  finally
    aQry.Close;
    aQry.DisposeOf;
  end;
end;

procedure TCategoriaController.New;
begin
  FModel := TCategoriaModel.New;
end;

procedure TCategoriaController.SetAtributes(const aDataSet: TDataSet; aModel: TCategoriaModel);
begin
  with aDataSet, aModel do
  begin
    Codigo    := FieldByName('cd_categoria').AsInteger;
    Descricao := FieldByName('ds_categoria').AsString;
    Indice    := FieldByName('ix_categoria').AsInteger;

    // #0#0#0#0'IEND®B`‚'
    try
      if (Trim(FieldByName('ic_categoria').AsString) <> EmptyStr) then
      begin
        Icone := TBitmap.Create;
        Icone.LoadFromStream( CreateBlobStream(FieldByName('ic_categoria'), TBlobStreamMode.bmRead) );
      end
      else
        Icone := nil;
    except
      Icone := nil;
    end;
  end;
end;

function TCategoriaController.Update(out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Codigo < 1 then
  begin
    aErro := 'Informe o código da categoria';
    Exit;
  end;

  if FModel.Descricao.IsEmpty then
  begin
    aErro := 'Informe a descrição da categoria';
    Exit;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Update ' + FDDL.getTableNameCategoria + ' set ');
        Add('    ds_categoria = :ds_categoria ');
        Add('  , ic_categoria = :ic_categoria ');
        Add('  , ix_categoria = :ix_categoria ');
        Add('where cd_categoria = :cd_categoria');
        EndUpdate;

        ParamByName('cd_categoria').Value := FModel.Codigo;
        ParamByName('ds_categoria').Value := FModel.Descricao;
        ParamByName('ix_categoria').Value := FModel.Indice;

        if Assigned(FModel.Icone) then
          ParamByName('ic_categoria').Assign( FModel.Icone )
        else
          ParamByName('ic_categoria').Clear;

        ExecSQL;

        Result    := True;
        FOperacao := TTipoOperacaoController.operControllerUpdate;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar atualizar a categoria: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TCategoriaController.ValidarExclusao(out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Codigo < 1 then
  begin
    aErro := 'Informe o código da categoria';
    Exit;
  end;

  aQry  := TFDQuery.Create(nil);
  try
    aQry.Connection  := TDMConexao.GetInstance().Conn;

    try
      // Verificar se existe lançamentos para a categoria
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Select ');
        Add('  count(cd_categoria) as qt_lancamento ');
        Add('from ' + FDDL.getTableNameLancamento);
        Add('where (cd_categoria = :cd_categoria)');
        EndUpdate;

        ParamByName('cd_categoria').Value := FModel.Codigo;

        Open;

        Result := (FieldByName('qt_lancamento').AsInteger = 0);

        if (not Result) then
          aErro := 'Categoria com lançamentos não poderá ser excluída';
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar validar a exclusão da categoria: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
