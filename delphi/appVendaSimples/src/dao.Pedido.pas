unit dao.Pedido;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Pedido,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TPedidoDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TPedido;
      aLista : TPedidos;
      aOperacao : TTipoOperacaoDao;
      constructor Create();
      procedure SetValues(const aDataSet : TFDQuery; const aObject : TPedido);
      procedure ClearLista;
      class var aInstance : TPedidoDao;
    public
      property Model : TPedido read aModel write aModel;
      property Lista : TPedidos read aLista write aLista;
      property Operacao : TTipoOperacaoDao read aOperacao;

      procedure Load(const aBusca : String);
      procedure Insert();
      procedure Update();
      procedure Delete();
      procedure AddLista; overload;
      procedure AddLista(aPedido : TPedido); overload;

      function Find(const aCodigo : Currency; const IsLoadModel : Boolean) : Boolean;
      function GetCount() : Integer;

      class function GetInstance : TPedidoDao;
  end;

implementation

{ TPedidoDao }

uses
  UDM;

procedure TPedidoDao.AddLista;
var
  I : Integer;
  o : TPedido;
begin
  I := High(aLista) + 2;
  o := TPedido.Create;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := o;
end;

procedure TPedidoDao.AddLista(aPedido: TPedido);
var
  I : Integer;
begin
  I := High(aLista) + 2;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := aPedido;
end;

procedure TPedidoDao.ClearLista;
begin
  SetLength(aLista, 0);
end;

constructor TPedidoDao.Create;
begin
  inherited Create;
  aDDL      := TScriptDDL.GetInstance;
  aModel    := TPedido.Create;
  aOperacao := TTipoOperacaoDao.toBrowser;
  SetLength(aLista, 0);
end;

procedure TPedidoDao.Delete;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Delete from ' + aDDL.getTableNamePedido);
    aSQL.Add('where id_pedido = :id_pedido ');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_pedido').AsString := GUIDToString(aModel.ID);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluido;
    end;
  finally
    aSQL.Free;
  end;
end;

function TPedidoDao.Find(const aCodigo: Currency;
  const IsLoadModel: Boolean): Boolean;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    p.* ');
    aSQL.Add('  , c.cd_cliente  ');
    aSQL.Add('  , c.nm_cliente  ');
    aSQL.Add('  , c.nr_cpf_cnpj ');
    aSQL.Add('from ' + aDDL.getTableNamePedido + ' p ');
    aSQL.Add('  left join ' + aDDL.getTableNameCliente + ' c on (c.id_cliente = p.id_cliente)');
    aSQL.Add('where p.cd_pedido = ' + CurrToStr(aCodigo));
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if qrySQL.OpenOrExecute then
      begin
        aRetorno := (qrySQL.RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(qrySQL, aModel);
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
    Result := aRetorno;
  end;
end;

function TPedidoDao.GetCount: Integer;
var
  aRetorno : Integer;
  aSQL : TStringList;
begin
  aRetorno := 0;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select ');
    aSQL.Add('  count(*) as qt_pedidos');
    aSQL.Add('from ' + aDDL.getTableNamePedido);
    aSQL.EndUpdate;
    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;
      OpenOrExecute;

      aRetorno := FieldByName('qt_pedidos').AsInteger;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
    Result := aRetorno;
  end;
end;

class function TPedidoDao.GetInstance: TPedidoDao;
begin
  if not Assigned(aInstance) then
    aInstance := TPedidoDao.Create();

  Result := aInstance;
end;

procedure TPedidoDao.Insert;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Insert Into ' + aDDL.getTableNamePedido + '(');
    aSQL.Add('    id_pedido ');
    aSQL.Add('  , cd_pedido ');
    aSQL.Add(') values (');
    aSQL.Add('    :id_pedido ');
    aSQL.Add('  , :cd_pedido ');
    aSQL.Add(')');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_pedido').AsString   := GUIDToString(Model.ID);
      ParamByName('cd_pedido').AsCurrency := Model.Codigo;
      //ParamByName('ds_especialidade').AsString  := Model.Descricao;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TPedidoDao.Load(const aBusca : String);
var
  aSQL : TStringList;
  aPedido : TPedido;
  aFiltro : String;
begin
  aSQL := TStringList.Create;
  try
    aFiltro := AnsiUpperCase(Trim(aBusca));

    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    p.* ');
    aSQL.Add('  , c.cd_cliente  ');
    aSQL.Add('  , c.nm_cliente  ');
    aSQL.Add('  , c.nr_cpf_cnpj ');
    aSQL.Add('from ' + aDDL.getTableNamePedido + ' p ');
    aSQL.Add('  join ' + aDDL.getTableNameCliente + ' c on (c.id_cliente = p.id_cliente)');

    if (StrToCurrDef(aFiltro, 0) > 0) then
      aSQL.Add('where p.cd_pedido = ' + aFiltro)
    else
    if (Trim(aBusca) <> EmptyStr) then
    begin
      aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
      aSQL.Add('where c.nm_cliente like ' + QuotedStr(aFiltro));
    end;

    aSQL.Add('order by');
    aSQL.Add('    p.cd_pedido DESC ');

    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if qrySQL.OpenOrExecute then
      begin
        ClearLista;
        if (qrySQL.RecordCount > 0) then
          while not qrySQL.Eof do
          begin
            aPedido := TPedido.Create;
            SetValues(qrySQL, aPedido);

            AddLista(aPedido);
            qrySQL.Next;
          end;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TPedidoDao.SetValues(const aDataSet: TFDQuery;
  const aObject: TPedido);
begin
  with aDataSet, aObject do
  begin
    ID     := StringToGUID(FieldByName('id_pedido').AsString);
    Codigo := FieldByName('cd_pedido').AsCurrency;
    Tipo   := IfThen(AnsiUpperCase(FieldByName('tp_pedido').AsString) = 'P', tpPedido, tpOrcamento);
    DataEmissao := FieldByName('dt_pedido').AsDateTime;

    if (Trim(FieldByName('id_cliente').AsString) <> EmptyStr) then
      Cliente.ID := StringToGUID(FieldByName('id_cliente').AsString)
    else
      Cliente.ID := GUID_NULL;

    Cliente.Codigo  := FieldByName('cd_cliente').AsCurrency;
    Cliente.Nome    := FieldByName('nm_cliente').AsString;
    Cliente.CpfCnpj := FieldByName('nr_cpf_cnpj').AsString;
    Contato         := FieldByName('ds_contato').AsString;
    Observacao      := FieldByName('ds_observacao').AsString;
    ValorTotal      := FieldByName('vl_total').AsCurrency;
    ValorDesconto   := FieldByName('vl_desconto').AsCurrency;
    ValorPedido     := FieldByName('vl_pedido').AsCurrency;
    Ativo           := (AnsiUpperCase(FieldByName('sn_ativo').AsString) = 'S');
    Entregue        := (AnsiUpperCase(FieldByName('sn_entregue').AsString) = 'S');

    if (Trim(FieldByName('cd_referencia').AsString) <> EmptyStr) then
      Referencia := StringToGUID(FieldByName('cd_referencia').AsString)
    else
      Referencia := GUID_NULL;

    if (Trim(FieldByName('id_loja').AsString) <> EmptyStr) then
      Loja.ID := StringToGUID(FieldByName('id_loja').AsString)
    else
      Loja.ID := GUID_NULL;
  end;
end;

procedure TPedidoDao.Update;
var
  aSQL : TStringList;
begin
//  aSQL := TStringList.Create;
//  try
//    aSQL.BeginUpdate;
//    aSQL.Add('Update ' + aDDL.getTableNameEspecialidade + ' Set');
//    aSQL.Add('  ds_especialidade     = :ds_especialidade');
//    aSQL.Add('where cd_especialidade = :cd_especialidade');
//    aSQL.EndUpdate;
//    with DtmDados, qrySQL do
//    begin
//      qrySQL.Close;
//      qrySQL.SQL.Text := aSQL.Text;
//
//      ParamByName('cd_especialidade').AsInteger := Model.Codigo;
//      ParamByName('ds_especialidade').AsString  := Model.Descricao;
//
//      ExecSQL;
//      aOperacao := TTipoOperacaoDao.toEditado;
//    end;
//  finally
//    aSQL.Free;
//  end;
end;

end.
