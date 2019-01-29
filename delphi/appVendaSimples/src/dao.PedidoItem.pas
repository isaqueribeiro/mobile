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

procedure TPedidoItemDao.Delete;
begin

end;

class function TPedidoItemDao.GetInstance: TPedidoItemDao;
begin
  if not Assigned(aInstance) then
    aInstance := TPedidoItemDao.Create();

  Result := aInstance;
end;

procedure TPedidoItemDao.Insert;
begin

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
    aSQL.Add('  , c.cd_cliente  ');
    aSQL.Add('  , c.nm_cliente  ');
    aSQL.Add('  , c.nr_cpf_cnpj ');
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
    Codigo := FieldByName('cd_item').AsCurrency;

    if (Trim(FieldByName('id_pedido').AsString) <> EmptyStr) then
      Pedido.ID := StringToGUID(FieldByName('id_pedido').AsString)
    else
      Pedido.ID := GUID_NULL;

    if (Trim(FieldByName('id_produto').AsString) <> EmptyStr) then
      Produto.ID := StringToGUID(FieldByName('id_produto').AsString)
    else
      Produto.ID := GUID_NULL;

    Produto.Codigo    := FieldByName('cd_produto').AsCurrency;
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
    ValorDesconto := FieldByName('vl_desconto').AsCurrency;
    ValorLiquido  := FieldByName('vl_liquido').AsCurrency;
    Observacao    := FieldByName('ds_observacao').AsString;

    if (Trim(FieldByName('cd_referencia').AsString) <> EmptyStr) then
      Referencia := StringToGUID(FieldByName('cd_referencia').AsString)
    else
      Referencia := GUID_NULL;
  end;
end;

procedure TPedidoItemDao.Update;
begin

end;

end.
