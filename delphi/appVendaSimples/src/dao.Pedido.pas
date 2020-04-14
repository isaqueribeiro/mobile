unit dao.Pedido;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Pedido,

  System.StrUtils,
  System.Math,

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
      procedure InserirItensTemp();
      procedure GravarItens();
      procedure CalcularValorTotalPedidoTemp();
      procedure RecalcularValorTotalPedido();

      function Find(const aCodigo : Currency; const IsLoadModel : Boolean) : Boolean;
      function GetCount() : Integer;
      function GetCountSincronizar() : Integer;
      function PodeExcluir : Boolean;

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

procedure TPedidoDao.CalcularValorTotalPedidoTemp;
var
  aQry : TFDQuery;
  aValorTotal   ,
  aValorDesconto,
  aValorPedido  : Currency;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    aValorTotal    := 0.0;
    aValorDesconto := 0.0;
    aValorPedido   := 0.0;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select');
      SQL.Add('    sum(i.vl_total)    as vl_total    ');
      SQL.Add('  , sum(i.vl_desconto) as vl_desconto ');
      SQL.Add('  , sum(i.vl_liquido)  as vl_liquido  ');
      SQL.Add('from ' + aDDL.getTableNamePedidoItem + '_temp i ');
      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        if not FieldByName('vl_total').IsNull then
        begin
          aValorTotal    := FieldByName('vl_total').AsCurrency;
          aValorDesconto := FieldByName('vl_desconto').AsCurrency;
          aValorPedido   := FieldByName('vl_liquido').AsCurrency;
        end
        else
        begin
          aValorTotal    := 0.0;
          aValorDesconto := 0.0;
          aValorPedido   := 0.0;
        end;
      end;

      aQry.Close;
    end;

    aModel.ValorTotal    := aValorTotal;
    aModel.ValorDesconto := aValorDesconto;
    aModel.ValorPedido   := aValorPedido;
  finally
    aQry.DisposeOf;
  end;
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
      SQL.Add('Delete from ' + aDDL.getTableNamePedido);
      SQL.Add('where id_pedido = :id_pedido ');
      SQL.EndUpdate;

      ParamByName('id_pedido').AsString := GUIDToString(aModel.ID);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TPedidoDao.Find(const aCodigo: Currency;
  const IsLoadModel: Boolean): Boolean;
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
      SQL.Add('    p.* ');
      SQL.Add('  , c.cd_cliente  ');
      SQL.Add('  , c.nm_cliente  ');
      SQL.Add('  , c.nr_cpf_cnpj ');
      SQL.Add('  , l.nm_empresa  ');
      SQL.Add('  , l.nm_fantasia ');
      SQL.Add('  , l.nr_cpf_cnpj as nr_cpf_cnpj_loja ');
      SQL.Add('from ' + aDDL.getTableNamePedido + ' p ');
      SQL.Add('  left join ' + aDDL.getTableNameCliente + ' c on (c.id_cliente = p.id_cliente)');
      SQL.Add('  left join ' + aDDL.getTableNameLoja    + ' l on (l.id_empresa = p.id_loja)');
      SQL.Add('where p.cd_pedido = ' + CurrToStr(aCodigo));
      SQL.EndUpdate;

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

function TPedidoDao.GetCount: Integer;
var
  aRetorno : Integer;
  aQry : TFDQuery;
begin
  aRetorno := 0;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select ');
      SQL.Add('  count(*) as qt_pedidos');
      SQL.Add('from ' + aDDL.getTableNamePedido);
      SQL.EndUpdate;

      OpenOrExecute;

      aRetorno := FieldByName('qt_pedidos').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TPedidoDao.GetCountSincronizar: Integer;
var
  aRetorno : Integer;
  aQry : TFDQuery;
begin
  aRetorno := 0;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select ');
      SQL.Add('  count(*) as qt_pedidos');
      SQL.Add('from ' + aDDL.getTableNamePedido);
      SQL.Add('where (sn_sincronizado = ' + QuotedStr(FLAG_NAO) +')');
      SQL.EndUpdate;

      OpenOrExecute;

      aRetorno := FieldByName('qt_pedidos').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

class function TPedidoDao.GetInstance: TPedidoDao;
begin
  if not Assigned(aInstance) then
    aInstance := TPedidoDao.Create();

  Result := aInstance;
end;

procedure TPedidoDao.GravarItens;
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
      SQL.Add('Update ' + aDDL.getTableNamePedidoItem + '_temp Set');
      SQL.Add('  id_pedido = :id_pedido;');

      SQL.Add('Delete ');
      SQL.Add('from   ' + aDDL.getTableNamePedidoItem);
      SQL.Add('where id_pedido = :id_pedido;');

      SQL.Add('Insert Into '   + aDDL.getTableNamePedidoItem + ' ');
      SQL.Add('Select * from ' + aDDL.getTableNamePedidoItem + '_temp;');
      SQL.EndUpdate;

      ParamByName('id_pedido').AsString := GUIDToString(Model.ID);
      ExecSQL;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TPedidoDao.InserirItensTemp;
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
      SQL.Add('Delete');
      SQL.Add('from ' + aDDL.getTableNamePedidoItem + '_temp;');

      SQL.Add('Insert Into '   + aDDL.getTableNamePedidoItem + '_temp ');
      SQL.Add('Select * from ' + aDDL.getTableNamePedidoItem + ' i');
      SQL.Add('where (i.id_pedido = :id_pedido)');
      SQL.EndUpdate;

      ParamByName('id_pedido').AsString := GUIDToString(Model.ID);
      ExecSQL;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TPedidoDao.Insert;
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
      SQL.Add('Insert Into ' + aDDL.getTableNamePedido + '(');
      SQL.Add('    id_pedido       ');
      SQL.Add('  , cd_pedido       ');
      SQL.Add('  , tp_pedido       ');
      SQL.Add('  , id_cliente      ');
      SQL.Add('  , dt_pedido       ');
      SQL.Add('  , vl_total        ');
      SQL.Add('  , vl_desconto     ');
      SQL.Add('  , vl_pedido       ');
      SQL.Add('  , ds_contato      ');
      SQL.Add('  , ds_observacao   ');
      SQL.Add('  , sn_ativo        ');
      SQL.Add('  , sn_entregue     ');
      SQL.Add('  , sn_sincronizado ');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , cd_referencia   ');

      if (aModel.Loja.ID <> GUID_NULL) then
        SQL.Add('  , id_loja         ');

      SQL.Add(') values (');
      SQL.Add('    :id_pedido      ');
      SQL.Add('  , :cd_pedido      ');
      SQL.Add('  , :tp_pedido      ');
      SQL.Add('  , :id_cliente     ');
      SQL.Add('  , :dt_pedido      ');
      SQL.Add('  , :vl_total       ');
      SQL.Add('  , :vl_desconto    ');
      SQL.Add('  , :vl_pedido      ');
      SQL.Add('  , :ds_contato     ');
      SQL.Add('  , :ds_observacao  ');
      SQL.Add('  , :sn_ativo       ');
      SQL.Add('  , :sn_entregue    ');
      SQL.Add('  , :sn_sincronizado');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , :cd_referencia  ');

      if (aModel.Loja.ID <> GUID_NULL) then
        SQL.Add('  , :id_loja        ');

      SQL.Add(')');
      SQL.EndUpdate;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      if (aModel.Codigo = 0) then
        aModel.Codigo := GetNewID(aDDL.getTableNamePedido, 'cd_pedido', EmptyStr);

      ParamByName('id_pedido').AsString     := GUIDToString(Model.ID);
      ParamByName('cd_pedido').AsCurrency   := Model.Codigo;
      ParamByName('tp_pedido').AsString     := GetTipoPedidoStr(Model.Tipo);
      ParamByName('id_cliente').AsString    := GUIDToString(Model.Cliente.ID);
      ParamByName('dt_pedido').AsDateTime   := Model.DataEmissao;
      ParamByName('vl_total').AsCurrency    := Model.ValorTotal;
      ParamByName('vl_desconto').AsCurrency := Model.ValorDesconto;
      ParamByName('vl_pedido').AsCurrency   := Model.ValorPedido;
      ParamByName('ds_contato').AsString    := Trim(Model.Contato);
      ParamByName('ds_observacao').AsString := Trim(Model.Observacao);

      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_entregue').AsString     := FLAG_NAO;
      ParamByName('sn_sincronizado').AsString := FLAG_NAO;

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      if (aModel.Loja.ID <> GUID_NULL) then
        ParamByName('id_loja').AsString := GUIDToString(aModel.Loja.ID);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TPedidoDao.Load(const aBusca : String);
var
  aQry : TFDQuery;
  aPedido : TPedido;
  aFiltro : String;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    aFiltro := AnsiUpperCase(Trim(aBusca));

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select');
      SQL.Add('    p.* ');
      SQL.Add('  , c.cd_cliente  ');
      SQL.Add('  , c.nm_cliente  ');
      SQL.Add('  , c.nr_cpf_cnpj ');
      SQL.Add('  , l.nm_empresa  ');
      SQL.Add('  , l.nm_fantasia ');
      SQL.Add('  , l.nr_cpf_cnpj as nr_cpf_cnpj_loja ');
      SQL.Add('from ' + aDDL.getTableNamePedido + ' p ');
      SQL.Add('  left join ' + aDDL.getTableNameCliente + ' c on (c.id_cliente = p.id_cliente)');
      SQL.Add('  left join ' + aDDL.getTableNameLoja    + ' l on (l.id_empresa = p.id_loja)');

      if (StrToCurrDef(aFiltro, 0) > 0) then
        SQL.Add('where p.cd_pedido = ' + aFiltro)
      else
      if (Trim(aBusca) <> EmptyStr) then
      begin
        aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
        SQL.Add('where c.nm_cliente like ' + QuotedStr(aFiltro));
      end;

      SQL.Add('order by');
      SQL.Add('    p.cd_pedido DESC ');

      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        ClearLista;
        if (RecordCount > 0) then
          while not Eof do
          begin
            aPedido := TPedido.Create;
            SetValues(aQry, aPedido);

            AddLista(aPedido);
            aQry.Next;
          end;
      end;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TPedidoDao.PodeExcluir: Boolean;
begin
  Result := not aModel.Entregue;
end;

procedure TPedidoDao.RecalcularValorTotalPedido;
var
  aQry : TFDQuery;
  aValorTotal   ,
  aValorDesconto,
  aValorPedido  : Currency;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    aValorTotal    := 0.0;
    aValorDesconto := 0.0;
    aValorPedido   := 0.0;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select');
      SQL.Add('    sum(i.vl_total)    as vl_total    ');
      SQL.Add('  , sum(i.vl_desconto) as vl_desconto ');
      SQL.Add('  , sum(i.vl_liquido)  as vl_liquido  ');
      SQL.Add('from ' + aDDL.getTableNamePedidoItem + ' i ');
      SQL.Add('where (i.id_pedido = :id_pedido)');
      SQL.EndUpdate;

      ParamByName('id_pedido').AsString := GUIDToString(Model.ID);
      if OpenOrExecute then
      begin
        if not FieldByName('vl_total').IsNull then
        begin
          aValorTotal    := FieldByName('vl_total').AsCurrency;
          aValorDesconto := FieldByName('vl_desconto').AsCurrency;
          aValorPedido   := FieldByName('vl_liquido').AsCurrency;
        end
        else
        begin
          aValorTotal    := 0.0;
          aValorDesconto := 0.0;
          aValorPedido   := 0.0;
        end;
      end;

      aQry.Close;
    end;

    aModel.ValorTotal    := aValorTotal;
    aModel.ValorDesconto := aValorDesconto;
    aModel.ValorPedido   := aValorPedido;

    if (aModel.ID <> GUID_NULL) then
      Self.Update();
  finally
    aQry.DisposeOf;
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
    begin
      Loja.ID := StringToGUID(FieldByName('id_loja').AsString);
      Loja.Nome     := FieldByName('nm_empresa').AsString;
      Loja.Fantasia := FieldByName('nm_fantasia').AsString;
      Loja.CpfCnpj  := FieldByName('nr_cpf_cnpj_loja').AsString;
    end
    else
    begin
      Loja.ID := GUID_NULL;
      Loja.Nome     := EmptyStr;
      Loja.Fantasia := EmptyStr;
    end;
  end;
end;

procedure TPedidoDao.Update;
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
      SQL.Add('Update ' + aDDL.getTableNamePedido + ' Set');
      SQL.Add('    cd_pedido       = :cd_pedido      ');
      SQL.Add('  , tp_pedido       = :tp_pedido      ');
      SQL.Add('  , id_cliente      = :id_cliente     ');
      SQL.Add('  , dt_pedido       = :dt_pedido      ');
      SQL.Add('  , vl_total        = :vl_total       ');
      SQL.Add('  , vl_desconto     = :vl_desconto    ');
      SQL.Add('  , vl_pedido       = :vl_pedido      ');
      SQL.Add('  , ds_contato      = :ds_contato     ');
      SQL.Add('  , ds_observacao   = :ds_observacao  ');
      SQL.Add('  , sn_ativo        = :sn_ativo       ');
      SQL.Add('  , sn_entregue     = :sn_entregue    ');
      SQL.Add('  , sn_sincronizado = :sn_sincronizado');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , cd_referencia   = :cd_referencia  ');

      if (aModel.Loja.ID <> GUID_NULL) then
        SQL.Add('  , id_loja         = :id_loja  ');

      SQL.Add('where id_pedido = :id_pedido');
      SQL.EndUpdate;

      ParamByName('id_pedido').AsString     := GUIDToString(Model.ID);
      ParamByName('cd_pedido').AsCurrency   := Model.Codigo;
      ParamByName('tp_pedido').AsString     := GetTipoPedidoStr(Model.Tipo);
      ParamByName('id_cliente').AsString    := GUIDToString(Model.Cliente.ID);
      ParamByName('dt_pedido').AsDateTime   := Model.DataEmissao;
      ParamByName('vl_total').AsCurrency    := Model.ValorTotal;
      ParamByName('vl_desconto').AsCurrency := Model.ValorDesconto;
      ParamByName('vl_pedido').AsCurrency   := Model.ValorPedido;
      ParamByName('ds_contato').AsString    := Trim(Model.Contato);
      ParamByName('ds_observacao').AsString := Trim(Model.Observacao);

      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_entregue').AsString     := FLAG_NAO;
      ParamByName('sn_sincronizado').AsString := FLAG_NAO;

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      if (aModel.Loja.ID <> GUID_NULL) then
        ParamByName('id_loja').AsString := GUIDToString(aModel.Loja.ID);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
