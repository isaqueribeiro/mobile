unit dao.PedidoItem;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.PedidoItem,

  System.StrUtils,
  System.Math,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TPedidoItemDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TPedidoItem;
      aLista : TPedidoItens;
      aOperacao : TTipoOperacaoDao;
      constructor Create();
      procedure SetValues(const aDataSet : TFDQuery; const aObject : TPedidoItem);
      procedure ClearLista;

      class var aInstance : TPedidoItemDao;
    public
      property Model : TPedidoItem  read aModel write aModel;
      property Lista : TPedidoItens read aLista write aLista;
      property Operacao : TTipoOperacaoDao read aOperacao;

      procedure Load(const aPedidoID : TGUID);
      procedure Insert();
      procedure Update();
      procedure Delete();
      procedure AddLista; overload;
      procedure AddLista(aPedidoItem : TPedidoItem); overload;
      procedure IncrementarQuantidade();
      procedure DecrementarQuantidade();

      class function GetInstance : TPedidoItemDao;
  end;

implementation

{ TPedidoItemDao }

uses
  UDM;

procedure TPedidoItemDao.AddLista(aPedidoItem: TPedidoItem);
var
  I : Integer;
begin
  I := High(aLista) + 2;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := aPedidoItem;
end;

procedure TPedidoItemDao.AddLista;
var
  I : Integer;
  o : TPedidoItem;
begin
  I := High(aLista) + 2;
  o := TPedidoItem.Create;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := o;
end;

procedure TPedidoItemDao.ClearLista;
begin
  SetLength(aLista, 0);
end;

constructor TPedidoItemDao.Create;
begin
  inherited Create;
  aDDL      := TScriptDDL.GetInstance;
  aModel    := TPedidoItem.Create;
  aOperacao := TTipoOperacaoDao.toBrowser;
  SetLength(aLista, 0);
end;

procedure TPedidoItemDao.IncrementarQuantidade;
begin
  aModel.Quantidade := aModel.Quantidade + 1;
end;

procedure TPedidoItemDao.DecrementarQuantidade;
var
  aQUantidade : Currency;
begin
  aQUantidade := aModel.Quantidade - 1;

  if (aQUantidade > 0) then
    aModel.Quantidade := aQUantidade
  else
    aModel.Quantidade := 1;
end;

procedure TPedidoItemDao.Delete;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Delete from ' + aDDL.getTableNamePedidoItem);
    aSQL.Add('where id_item = :id_item ');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_item').AsString := GUIDToString(aModel.ID);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluido;
    end;
  finally
    aSQL.Free;
  end;
end;

class function TPedidoItemDao.GetInstance: TPedidoItemDao;
begin
  if not Assigned(aInstance) then
    aInstance := TPedidoItemDao.Create();

  Result := aInstance;
end;

procedure TPedidoItemDao.Insert;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Insert Into ' + aDDL.getTableNamePedidoItem + '(');
    aSQL.Add('    id_item         ');
    aSQL.Add('  , cd_item         ');
    aSQL.Add('  , id_pedido       ');
    aSQL.Add('  , id_produto      ');
    aSQL.Add('  , qt_item         ');
    aSQL.Add('  , vl_item         ');
    aSQL.Add('  , vl_total        ');
    aSQL.Add('  , vl_desconto     ');
    aSQL.Add('  , vl_liquido      ');
    aSQL.Add('  , ds_observacao   ');

    if (aModel.Referencia <> GUID_NULL) then
      aSQL.Add('  , cd_referencia   ');

    aSQL.Add(') values (');
    aSQL.Add('    :id_item        ');
    aSQL.Add('  , :cd_item        ');
    aSQL.Add('  , :id_pedido      ');
    aSQL.Add('  , :id_produto     ');
    aSQL.Add('  , :qt_item        ');
    aSQL.Add('  , :vl_item        ');
    aSQL.Add('  , :vl_total       ');
    aSQL.Add('  , :vl_desconto    ');
    aSQL.Add('  , :vl_liquido     ');
    aSQL.Add('  , :ds_observacao  ');

    if (aModel.Referencia <> GUID_NULL) then
      aSQL.Add('  , :cd_referencia  ');

    aSQL.Add(')');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      if (aModel.Codigo = 0) then
        aModel.Codigo := Round( GetNewID(aDDL.getTableNamePedidoItem, 'cd_item', 'id_pedido = ' + QuotedStr(GUIDToString(Model.PedidoID))) );

      ParamByName('id_item').AsString       := GUIDToString(Model.ID);
      ParamByName('cd_item').AsInteger      := Model.Codigo;
      ParamByName('id_pedido').AsString     := GUIDToString(Model.PedidoID);
      ParamByName('id_produto').AsString    := GUIDToString(Model.ProdutoID);
      ParamByName('qt_item').AsCurrency     := Model.Quantidade;
      ParamByName('vl_item').AsCurrency     := Model.ValorUnitario;
      ParamByName('vl_total').AsCurrency    := Model.ValorTotal;
      ParamByName('vl_desconto').AsCurrency := Model.ValorTotalDesconto;
      ParamByName('vl_liquido').AsCurrency  := Model.ValorLiquido;
      ParamByName('ds_observacao').AsString := Trim(Model.Observacao);

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TPedidoItemDao.Load(const aPedidoID: TGUID);
var
  aSQL : TStringList;
  aPedidoItem : TPedidoItem;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    i.* ');
    aSQL.Add('  , p.cd_produto  ');
    aSQL.Add('  , p.br_produto  ');
    aSQL.Add('  , p.ds_produto  ');
    aSQL.Add('  , p.ft_produto ');
    aSQL.Add('  , p.vl_produto ');
    aSQL.Add('from ' + aDDL.getTableNamePedidoItem + ' i ');
    aSQL.Add('  join ' + aDDL.getTableNameProduto + ' p on (p.id_produto = i.id_produto)');
    aSQL.Add('where (i.id_pedido = :id_pedido) ');
    aSQL.Add('order by');
    aSQL.Add('    i.cd_item ');

    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_pedido').AsString := GUIDToString(Model.ID);

      if qrySQL.OpenOrExecute then
      begin
        ClearLista;
        if (qrySQL.RecordCount > 0) then
          while not qrySQL.Eof do
          begin
            aPedidoItem := TPedidoItem.Create;
            SetValues(qrySQL, aPedidoItem);

            AddLista(aPedidoItem);
            qrySQL.Next;
          end;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TPedidoItemDao.SetValues(const aDataSet: TFDQuery;
  const aObject: TPedidoItem);
begin
  with aDataSet, aObject do
  begin
    ID     := StringToGUID(FieldByName('id_item').AsString);
    Codigo := FieldByName('cd_item').AsInteger;

    if (Trim(FieldByName('id_pedido').AsString) <> EmptyStr) then
      Pedido.ID := StringToGUID(FieldByName('id_pedido').AsString)
    else
      Pedido.ID := GUID_NULL;

    if (Trim(FieldByName('id_produto').AsString) <> EmptyStr) then
      Produto.ID := StringToGUID(FieldByName('id_produto').AsString)
    else
      Produto.ID := GUID_NULL;

    Produto.Codigo    := FieldByName('cd_produto').AsCurrency;
    Produto.CodigoEan := FieldByName('br_produto').AsString;
    Produto.Descricao := Trim(FieldByName('ds_produto').AsString);
    Produto.Valor     := FieldByName('vl_produto').AsCurrency;

    if (not FieldByName('ft_produto').IsNull) then
    begin
      Produto.Foto := TStream.Create;
      Produto.Foto := CreateBlobStream(FieldByName('ft_produto'), TBlobStreamMode.bmRead);
    end
    else
      Produto.Foto := nil;

    Quantidade    := FieldByName('qt_item').AsCurrency;
    ValorUnitario := FieldByName('vl_item').AsCurrency;
    ValorTotal    := FieldByName('vl_total').AsCurrency;
    ValorTotalDesconto := FieldByName('vl_desconto').AsCurrency;
    ValorLiquido  := FieldByName('vl_liquido').AsCurrency;
    Observacao    := FieldByName('ds_observacao').AsString;

    if (Trim(FieldByName('cd_referencia').AsString) <> EmptyStr) then
      Referencia := StringToGUID(FieldByName('cd_referencia').AsString)
    else
      Referencia := GUID_NULL;
  end;
end;

procedure TPedidoItemDao.Update;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Update ' + aDDL.getTableNamePedidoItem + ' Set ');
    aSQL.Add('    cd_item       = :cd_item       ');
    aSQL.Add('  , id_pedido     = :id_pedido     ');
    aSQL.Add('  , id_produto    = :id_produto    ');
    aSQL.Add('  , qt_item       = :qt_item       ');
    aSQL.Add('  , vl_item       = :vl_item       ');
    aSQL.Add('  , vl_total      = :vl_total      ');
    aSQL.Add('  , vl_desconto   = :vl_desconto   ');
    aSQL.Add('  , vl_liquido    = :vl_liquido    ');
    aSQL.Add('  , ds_observacao = :ds_observacao ');

    if (aModel.Referencia <> GUID_NULL) then
      aSQL.Add('  , cd_referencia = :cd_referencia ');

    aSQL.Add('where id_item = :id_item ');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_item').AsString       := GUIDToString(Model.ID);
      ParamByName('cd_item').AsInteger      := Model.Codigo;
      ParamByName('id_pedido').AsString     := GUIDToString(Model.PedidoID);
      ParamByName('id_produto').AsString    := GUIDToString(Model.ProdutoID);
      ParamByName('qt_item').AsCurrency     := Model.Quantidade;
      ParamByName('vl_item').AsCurrency     := Model.ValorUnitario;
      ParamByName('vl_total').AsCurrency    := Model.ValorTotal;
      ParamByName('vl_desconto').AsCurrency := Model.ValorTotalDesconto;
      ParamByName('vl_liquido').AsCurrency  := Model.ValorLiquido;
      ParamByName('ds_observacao').AsString := Trim(Model.Observacao);

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aSQL.Free;
  end;
end;

end.
