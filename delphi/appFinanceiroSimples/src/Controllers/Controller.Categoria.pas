unit Controller.Categoria;

interface

uses
    Services.ComplexTypes
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
      FModel : TCategoriaModel;
      FLista : TDictionary<integer, TCategoriaModel>;
      procedure SetAtributes(const aDataSet : TDataSet; aModel : TCategoriaModel);
    protected
      constructor Create;
      destructor Destroy; override;
    public
      class function GetInstance : TCategoriaCOntroller;

      property Operacao : TTipoOperacaoController read FOperacao;
      property Attributes : TCategoriaModel read  FModel;
      property Lista : TDictionary<integer, TCategoriaModel> read FLista;

      procedure New;
      procedure Load(out aErro : String);

      function Insert(out aErro : String) : Boolean;
      function Update(out aErro : String) : Boolean;
      function Delete(out aErro : String) : Boolean;
      function Find(aCodigo : Integer; out aErro : String;
        const RETURN_ATTRIBUTES : Boolean = FALSE) : Boolean;
  end;

implementation

{ TCategoriaController }

uses
    DataModule.Conexao
  , Classes.ScriptDDL
  , System.SysUtils
  , FMX.Graphics;

constructor TCategoriaCOntroller.Create;
begin
  FOperacao := TTipoOperacaoController.operControllerBrowser;
  FModel := TCategoriaModel.New;
  FLista := TDictionary<integer, TCategoriaModel>.Create;

  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(TScriptDDL.getInstance().getCreateTableCategoria.Text, True);
end;

function TCategoriaController.Delete(out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Codigo < 1 then
  begin
    aErro := 'Informe o código da categoria';
    Exit;
  end;

  // Verificar se existe lançamentos para a categoria
  // ???

  FOperacao := TTipoOperacaoController.operControllerDelete;

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

        if FLista.ContainsKey(FModel.Codigo) then
        begin
          FLista.Remove(FModel.Codigo);
          FLista.TrimExcess;
        end;
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
begin
  if Assigned(FModel) then
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
        Add('from ' + TScriptDDL.getInstance().getTableNameCategoria);
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

  FOperacao := TTipoOperacaoController.operControllerInsert;

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

        if Assigned(FModel.Icone) then
          ParamByName('ic_categoria').Assign( FModel.Icone )
        else
          ParamByName('ic_categoria').Clear;

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
        Add('from ' + TScriptDDL.getInstance().getTableNameCategoria);
        Add('order by');
        Add('    ds_categoria');
        EndUpdate;

        Open;

        Lista.Clear;

        while not Eof do
        begin
          aModel := TCategoriaModel.Create;

          SetAtributes(aQry, aModel);
          Lista.AddOrSetValue(aModel.Codigo, aModel);

          Next;
        end;

        // Limitar o tamanho da lista à quantidade de objetos encontrados
        Lista.TrimExcess;
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

procedure TCategoriaController.SetAtributes(const aDataSet: TDataSet; aModel: TCategoriaModel);
begin
  with aDataSet, aModel do
  begin
    Codigo    := FieldByName('cd_categoria').AsInteger;
    Descricao := FieldByName('ds_categoria').AsString;
    Indice    := FieldByName('ix_categoria').AsInteger;

    // #0#0#0#0'IEND®B`‚'
    if (Trim(FieldByName('ic_categoria').AsString) <> EmptyStr) then
    begin
      Icone := TBitmap.Create;
      Icone.LoadFromStream( CreateBlobStream(FieldByName('ic_categoria'), TBlobStreamMode.bmRead) );
    end
    else
      Icone := nil;
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

  FOperacao := TTipoOperacaoController.operControllerUpdate;

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

        if Assigned(FModel.Icone) then
          ParamByName('ic_categoria').Assign( FModel.Icone )
        else
          ParamByName('ic_categoria').Clear;

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
