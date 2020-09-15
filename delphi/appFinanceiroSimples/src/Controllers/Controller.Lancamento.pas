unit Controller.Lancamento;

interface

uses
    System.SysUtils
  , Model.Lancamento
  , Services.ComplexTypes
  , System.Generics.Collections
  , FireDAC.Comp.Client
  , Data.DB;

type
  TLancamentoController = class
    strict private
      class var _instance : TLancamentoController;
    protected
      constructor Create;
      destructor Destroy; override;
    private
      FOperacao : TTipoOperacaoController;
      FModel : TLancamentoModel;
      FLista : TDictionary<TGUID, TLancamentoModel>;
      procedure SetAtributes(const aDataSet : TDataSet; aModel : TLancamentoModel);
    public
      class function GetInstance : TLancamentoController;

      property Operacao : TTipoOperacaoController read FOperacao;
      property Attributes : TLancamentoModel read  FModel;
      property Lista : TDictionary<TGUID, TLancamentoModel> read FLista;

      procedure New;
      procedure Load(const aQuantidadeRegistros: Integer; aAno, aMes : Word;
        var aTotal : TTotalLancamentos; out aErro : String);

      function Insert(out aErro : String) : Boolean;
      function Update(out aErro : String) : Boolean;
      function Delete(out aErro : String) : Boolean;
      function Find(aGuid : TGUID; out aErro : String;
        const RETURN_ATTRIBUTES : Boolean = FALSE) : Boolean; overload; virtual; abstract;
      function Find(aCodigo : Integer; out aErro : String;
        const RETURN_ATTRIBUTES : Boolean = FALSE) : Boolean; overload; virtual; abstract;
  end;

implementation

{ TLancamentoController }

uses
    DataModule.Conexao
  , Classes.ScriptDDL
  , FMX.Graphics
  , System.DateUtils
  , System.Math;

class function TLancamentoController.GetInstance: TLancamentoController;
begin
  if not Assigned(_instance) then
    _instance := TLancamentoController.Create;

  Result := _instance;
end;

function TLancamentoController.Insert(out aErro: String): Boolean;
var
  aQry   : TFDQuery;
  aGuid  : TGUID;
begin
  Result := False;

  if FModel.Descricao.IsEmpty then
  begin
    aErro := 'Informe a descrição do lançamento';
    Exit;
  end;

  if (FModel.Valor = 0) then
  begin
    aErro := 'Informe o valor do lançamento';
    Exit;
  end;

  if (FModel.Categoria.Codigo = 0) then
  begin
    aErro := 'Informe a categoria do lançamento';
    Exit;
  end;

  if (FModel.ID = TGuid.Empty) then
  begin
    CreateGUID(aGuid);
    FModel.ID := aGuid;
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
        Add('Insert Into ' + TScriptDDL.getInstance().getTableNameLancamento + '(');
        Add('    id_lancamento ');
        Add('  , tp_lancamento ');
        Add('  , ds_lancamento ');
        Add('  , dt_lancamento ');
        Add('  , vl_lancamento ');
        Add('  , cd_categoria  ');
        Add(') values (');
        Add('    :id_lancamento ');
        Add('  , :tp_lancamento ');
        Add('  , :ds_lancamento ');
        Add('  , :dt_lancamento ');
        Add('  , :vl_lancamento ');
        Add('  , :cd_categoria  ');
        Add(')');
        EndUpdate;

        ParamByName('id_lancamento').Value := FModel.ID.ToString;
        ParamByName('tp_lancamento').Value := Ord(FModel.Tipo);
        ParamByName('ds_lancamento').Value := FModel.Descricao;
        ParamByName('dt_lancamento').Value := FModel.Data;
        ParamByName('cd_categoria').Value  := FModel.Categoria.Codigo;

        // Tratar valor
        if (FModel.Tipo = TTipoLancamento.tipoReceita) and (FModel.Valor < 0) then
          FModel.Valor := FModel.Valor * (-1)  // Transformar para positivo (+)
        else
        if (FModel.Tipo = TTipoLancamento.tipoDespesa) and (FModel.Valor > 0) then
          FModel.Valor := FModel.Valor * (-1); // Transformar para negativo (-)

        ParamByName('vl_lancamento').Value := FModel.Valor;

        ExecSQL;

        FModel.Codigo := TDMConexao.GetInstance().GetLastInsertRowID;

        Result := (FModel.Codigo > 0);
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar inserir o lançamento: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TLancamentoController.Load(const aQuantidadeRegistros: Integer; aAno, aMes : Word;
  var aTotal : TTotalLancamentos; out aErro : String);
var
  aModel : TLancamentoModel;
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
        Add('    a.id_lancamento');
        Add('  , a.cd_lancamento');
        Add('  , a.tp_lancamento');
        Add('  , a.ds_lancamento');
        Add('  , a.dt_lancamento');
        Add('  , a.vl_lancamento');
        Add('  , a.cd_categoria ');
        Add('  , c.ds_categoria ');
        Add('  , c.ic_categoria ');
        Add('from ' + TScriptDDL.getInstance().getTableNameLancamento + ' a');
        Add('  left join ' + TScriptDDL.getInstance().getTableNameCategoria + ' c on (c.cd_categoria = a.cd_categoria)');
        Add('where (a.cd_lancamento > 0)');

        if ((aAno > 0) and (aMes > 0)) then
          Add('  and (a.dt_lancamento between :data_inicial and :data_final)');

        Add('order by');
        Add('    a.dt_lancamento DESC');
        Add('  , a.ds_lancamento ASC');

        if (aQuantidadeRegistros > 0) then
          Add('limit :limite');

        EndUpdate;

        if ((aAno > 0) and (aMes > 0)) then
        begin
          ParamByName('data_inicial').AsDateTime := EncodeDate(aAno, aMes, 1);
          ParamByName('data_final').AsDateTime   := EndOfTheMonth( EncodeDate(aAno, aMes, 1) );
        end;

        if (aQuantidadeRegistros > 0) then
          ParamByName('limite').AsInteger := aQuantidadeRegistros;

        Open;

        Lista.Clear;

        aTotal.Receitas := 0.0;
        aTotal.Despesas := 0.0;
        aTotal.Saldo    := 0.0;

        while not Eof do
        begin
          aModel := TLancamentoModel.Create;

          SetAtributes(aQry, aModel);
          Lista.AddOrSetValue(aModel.ID, aModel);

          // Totalizar lançamentos
          if aModel.Tipo = TTipoLancamento.tipoReceita then
            aTotal.Receitas := ( aTotal.Receitas + aModel.Valor )
          else
            aTotal.Despesas := ( aTotal.Despesas + (aModel.Valor * (-1)) );

          aTotal.Saldo := aTotal.Receitas - aTotal.Despesas;

          Next;
        end;

        // Limitar o tamanho da lista à quantidade de objetos encontrados
        Lista.TrimExcess;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar carregar os lançamentos: ' + E.Message;
    end;
  finally
    aQry.Close;
    aQry.DisposeOf;
  end;
end;

procedure TLancamentoController.New;
begin
  FModel := TLancamentoModel.New;
end;

procedure TLancamentoController.SetAtributes(const aDataSet: TDataSet; aModel: TLancamentoModel);
begin
  with aDataSet, aModel do
  begin
    ID     := StringToGUID(FieldByName('id_lancamento').AsString);
    Codigo := FieldByName('cd_lancamento').AsInteger;
    Tipo   := TTipoLancamento(FieldByName('tp_lancamento').AsInteger);
    Descricao := FieldByName('ds_lancamento').AsString;
    Data      := FieldByName('dt_lancamento').AsDateTime;
    Valor     := FieldByName('vl_lancamento').AsCurrency;

    Categoria.Codigo    := FieldByName('cd_categoria').AsInteger;
    Categoria.Descricao := FieldByName('ds_categoria').AsString;

    // #0#0#0#0'IEND®B`‚'
    if (Trim(FieldByName('ic_categoria').AsString) <> EmptyStr) then
    begin
      Categoria.Icone := TBitmap.Create;
      Categoria.Icone.LoadFromStream( CreateBlobStream(FieldByName('ic_categoria'), TBlobStreamMode.bmRead) );
    end
    else
      Categoria.Icone := nil;
  end;
end;

function TLancamentoController.Update(out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Descricao.IsEmpty then
  begin
    aErro := 'Informe a descrição do lançamento';
    Exit;
  end;

  if (FModel.Valor = 0) then
  begin
    aErro := 'Informe o valor do lançamento';
    Exit;
  end;

  if (FModel.Categoria.Codigo = 0) then
  begin
    aErro := 'Informe a categoria do lançamento';
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
        Add('Update ' + TScriptDDL.getInstance().getTableNameLancamento + ' set ');
        Add('    tp_lancamento ');
        Add('  , ds_lancamento ');
        Add('  , dt_lancamento ');
        Add('  , vl_lancamento ');
        Add('  , cd_categoria  ');
        Add('where id_lancamento = :id_lancamento');
        EndUpdate;

        ParamByName('id_lancamento').Value := FModel.ID.ToString;
        ParamByName('tp_lancamento').Value := Ord(FModel.Tipo);
        ParamByName('ds_lancamento').Value := FModel.Descricao;
        ParamByName('dt_lancamento').Value := FModel.Data;
        ParamByName('cd_categoria').Value  := FModel.Categoria.Codigo;

        // Tratar valor
        if (FModel.Tipo = TTipoLancamento.tipoReceita) and (FModel.Valor < 0) then
          FModel.Valor := FModel.Valor * (-1)  // Transformar para positivo (+)
        else
        if (FModel.Tipo = TTipoLancamento.tipoDespesa) and (FModel.Valor > 0) then
          FModel.Valor := FModel.Valor * (-1); // Transformar para negativo (-)

        ParamByName('vl_lancamento').Value := FModel.Valor;

        ExecSQL;

        Result := True;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar atualizar o lançamento: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

constructor TLancamentoController.Create;
begin
  FOperacao := TTipoOperacaoController.operControllerBrowser;
  FModel := TLancamentoModel.New;
  FLista := TDictionary<TGUID, TLancamentoModel>.Create;

  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(TScriptDDL.getInstance().getCreateTableLancamento.Text, True);
end;

function TLancamentoController.Delete(out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if (FModel.ID = TGUID.Empty) then
  begin
    aErro := 'Informe o código do lançamento';
    Exit;
  end;

  FOperacao := TTipoOperacaoController.operControllerDelete;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Delete from ' + TScriptDDL.getInstance().getTableNameLancamento);
        Add('where id_lancamento = :id_lancamento');
        EndUpdate;

        ParamByName('id_lancamento').Value := FModel.ID.ToString;

        ExecSQL;

        Result := True;

        if FLista.ContainsKey(FModel.ID) then
        begin
          FLista.Remove(FModel.ID);
          FLista.TrimExcess;
        end;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar excluir o lançamento: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

destructor TLancamentoController.Destroy;
var
  aObj : TLancamentoModel;
begin
  if Assigned(FModel) then
    FModel.DisposeOf;

  if Assigned(FLista) then
  begin
    for aObj in FLista.Values do
    begin
      FLista.Remove(aObj.ID);
      aObj.DisposeOf;
    end;

    FLista.Clear;
    FLista.TrimExcess;
    FLista.DisposeOf;
  end;

  inherited;
end;

end.
