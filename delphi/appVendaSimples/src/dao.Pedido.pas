unit dao.Pedido;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Pedido,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TPedidoDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TPedido;
      aLista : TPedidos;
      constructor Create();
      class var aInstance : TPedidoDao;
    public
      property Model : TPedido read aModel write aModel;
      property Lista : TPedidos read aLista write aLista;

      procedure Load(); virtual; abstract;
      procedure Insert();
      procedure Update();
      procedure AddLista; overload;
      procedure AddLista(aPedido : TPedido); overload;

      function Find(const aCodigo : Integer; const IsLoadModel : Boolean) : Boolean;
      function GetCount() : Integer;

      class function GetInstance : TPedidoDao;
  end;

implementation

{ TPedidoDao }

uses UDM;

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

constructor TPedidoDao.Create;
begin
  inherited Create;
  aDDL   := TScriptDDL.GetInstance;
  aModel := TPedido.Create;
  SetLength(aLista, 0);
end;

function TPedidoDao.Find(const aCodigo: Integer;
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
        begin
          Model.ID     := StringToGUID(FieldByName('id_pedido').AsString);
          Model.Codigo := FieldByName('cd_pedido').AsCurrency;
          Model.Tipo   := IfThen(AnsiUpperCase(FieldByName('tp_pedido').AsString) = 'P', tpPedido, tpOrcamento);
          Model.Cliente.ID     := StringToGUID(FieldByName('id_pedido').AsString);
          Model.Cliente.Codigo := FieldByName('cd_cliente').AsCurrency;
          Model.Cliente.Nome   := FieldByName('nm_cliente').AsString;
          Model.Contato        := FieldByName('ds_contato').AsString;
          Model.Data           := FieldByName('dt_pedido').AsDateTime;
          Model.ValorTotal     := FieldByName('vl_total').AsCurrency;
          Model.ValorDesconto  := FieldByName('vl_desconto').AsCurrency;
          Model.ValorPedido    := FieldByName('vl_pedido').AsCurrency;
          Model.Ativo          := (AnsiUpperCase(FieldByName('sn_ativo').AsString) = 'S');
          Model.Entregue       := (AnsiUpperCase(FieldByName('sn_entregue').AsString) = 'S');
          Model.Sincronizado   := (AnsiUpperCase(FieldByName('sn_sincronizado').AsString) = 'S');
          Model.Referencia := IfThen(Trim(FieldByName('cd_referencia').AsString) = EmptyStr, GUID_NULL, StringToGUID(FieldByName('cd_referencia').AsString));
          Model.Loja.ID    := IfThen(Trim(FieldByName('id_loja').AsString) = EmptyStr, GUID_NULL, StringToGUID(FieldByName('id_loja').AsString));
        end;
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
//    aSQL.BeginUpdate;
//    aSQL.Add('Select *');
//    aSQL.Add('from ' + aDDL.getTableNamePedido);
//    aSQL.EndUpdate;
//    with DM, qrySQL do
//    begin
//      qrySQL.Close;
//      qrySQL.SQL.Text := aSQL.Text;
//      OpenOrExecute;
//
//      aRetorno := RecordCount;
//      qrySQL.Close;
//    end;
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
    end;
  finally
    aSQL.Free;
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
//      ExecSQL;
//    end;
//  finally
//    aSQL.Free;
//  end;
end;

end.
