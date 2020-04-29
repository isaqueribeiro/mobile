unit dao.PedidoItem;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.PedidoItem,

  System.StrUtils,
  System.Math,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FMX.Graphics;

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
      procedure DeleteAllTemp();
      procedure AddLista; overload;
      procedure AddLista(aPedidoItem : TPedidoItem); overload;
      procedure IncrementarQuantidade();
      procedure DecrementarQuantidade();
      procedure CarregarDadosToSynchrony;

      function Find(const aPedidoID, aItemID : TGUID; const IsLoadModel : Boolean) : Boolean;

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

procedure TPedidoItemDao.CarregarDadosToSynchrony;
var
  aQry : TFDQuery;
  aPedidoItem : TPedidoItem;
  aFiltro  : String;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select');
      SQL.Add('    i.* ');
      SQL.Add('  , p.cd_produto  ');
      SQL.Add('  , p.br_produto  ');
      SQL.Add('  , p.ds_produto  ');
      SQL.Add('  , p.ft_produto ');
      SQL.Add('  , p.vl_produto ');
      SQL.Add('from ' + aDDL.getTableNamePedido + ' x');
      SQL.Add('  join ' + aDDL.getTableNamePedidoItem + ' i on (i.id_pedido = x.id_pedido)');
      SQL.Add('  join ' + aDDL.getTableNameProduto + ' p on (p.id_produto = i.id_produto)');
      SQL.Add('where (x.sn_sincronizado = ' + QuotedStr(FLAG_NAO) +')');
      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        ClearLista;
        if (RecordCount > 0) then
          while not Eof do
          begin
            aPedidoItem := TPedidoItem.Create;
            SetValues(aQry, aPedidoItem);

            AddLista(aPedidoItem);
            Next;
          end;
      end;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
  end;
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
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Delete from ' + aDDL.getTableNamePedidoItem + '_temp ');
      SQL.Add('where (id_item = :id_item) ');
      SQL.EndUpdate;

      ParamByName('id_item').AsString := GUIDToString(aModel.ID);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TPedidoItemDao.DeleteAllTemp;
var
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Delete from ' + aDDL.getTableNamePedidoItem + '_temp ');
      SQL.EndUpdate;

      ExecSQL;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TPedidoItemDao.Find(const aPedidoID, aItemID: TGUID; const IsLoadModel: Boolean): Boolean;
var
  aQry : TFDQuery;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select');
      SQL.Add('    i.* ');
      SQL.Add('  , p.cd_produto  ');
      SQL.Add('  , p.br_produto  ');
      SQL.Add('  , p.ds_produto  ');
      SQL.Add('  , p.ft_produto ');
      SQL.Add('  , p.vl_produto ');
      SQL.Add('from ' + aDDL.getTableNamePedidoItem + '_temp i ');
      SQL.Add('  join ' + aDDL.getTableNameProduto + ' p on (p.id_produto = i.id_produto)');
      SQL.Add('where (i.id_pedido = :id_pedido) ');
      SQL.Add('  and (i.id_item   = :id_item) ');
      SQL.EndUpdate;

      ParamByName('id_pedido').AsString := aPedidoID.ToString;
      ParamByName('id_item').AsString   := aItemID.ToString;

      if OpenOrExecute then
      begin
        aRetorno := (RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(aQry, aModel);
      end;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
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
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Insert Into ' + aDDL.getTableNamePedidoItem + '_temp (');
      SQL.Add('    id_item         ');
      SQL.Add('  , cd_item         ');
      SQL.Add('  , id_pedido       ');
      SQL.Add('  , id_produto      ');
      SQL.Add('  , qt_item         ');
      SQL.Add('  , vl_item         ');
      SQL.Add('  , vl_total        ');
      SQL.Add('  , vl_desconto     ');
      SQL.Add('  , vl_liquido      ');
      SQL.Add('  , ds_observacao   ');
      SQL.Add(') values (');
      SQL.Add('    :id_item        ');
      SQL.Add('  , :cd_item        ');
      SQL.Add('  , :id_pedido      ');
      SQL.Add('  , :id_produto     ');
      SQL.Add('  , :qt_item        ');
      SQL.Add('  , :vl_item        ');
      SQL.Add('  , :vl_total       ');
      SQL.Add('  , :vl_desconto    ');
      SQL.Add('  , :vl_liquido     ');
      SQL.Add('  , :ds_observacao  ');
      SQL.Add(')');
      SQL.EndUpdate;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      if (aModel.Codigo = 0) then
        aModel.Codigo := Round( GetNewID(aDDL.getTableNamePedidoItem + '_temp', 'cd_item', 'id_pedido = ' + QuotedStr(Model.PedidoID.ToString)) );

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

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TPedidoItemDao.Load(const aPedidoID: TGUID);
var
  aQry : TFDQuery;
  aPedidoItem : TPedidoItem;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select');
      SQL.Add('    i.* ');
      SQL.Add('  , p.cd_produto  ');
      SQL.Add('  , p.br_produto  ');
      SQL.Add('  , p.ds_produto  ');
      SQL.Add('  , p.ft_produto ');
      SQL.Add('  , p.vl_produto ');
      SQL.Add('from ' + aDDL.getTableNamePedidoItem + '_temp i ');
      SQL.Add('  join ' + aDDL.getTableNameProduto + ' p on (p.id_produto = i.id_produto)');
      SQL.Add('where (i.id_pedido = :id_pedido) ');
      SQL.Add('order by');
      SQL.Add('    i.cd_item ');
      SQL.EndUpdate;

      ParamByName('id_pedido').AsString := GUIDToString(aPedidoID);

      if OpenOrExecute then
      begin
        ClearLista;
        if (RecordCount > 0) then
          while not Eof do
          begin
            aPedidoItem := TPedidoItem.Create;
            SetValues(aQry, aPedidoItem);

            AddLista(aPedidoItem);
            aQry.Next;
          end;
      end;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
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
//      Produto.Foto := TStream.Create;
//      Produto.Foto := CreateBlobStream(FieldByName('ft_produto'), TBlobStreamMode.bmRead);
      Produto.Foto := TBitmap.Create;
      Produto.Foto.LoadFromStream( CreateBlobStream(FieldByName('ft_produto'), TBlobStreamMode.bmRead) );
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
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Update ' + aDDL.getTableNamePedidoItem + '_temp Set ');
      SQL.Add('    cd_item       = :cd_item       ');
      SQL.Add('  , id_pedido     = :id_pedido     ');
      SQL.Add('  , id_produto    = :id_produto    ');
      SQL.Add('  , qt_item       = :qt_item       ');
      SQL.Add('  , vl_item       = :vl_item       ');
      SQL.Add('  , vl_total      = :vl_total      ');
      SQL.Add('  , vl_desconto   = :vl_desconto   ');
      SQL.Add('  , vl_liquido    = :vl_liquido    ');
      SQL.Add('  , ds_observacao = :ds_observacao ');
      SQL.Add('where (id_item = :id_item) ');
      SQL.EndUpdate;

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
      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
