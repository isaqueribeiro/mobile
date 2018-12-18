unit dao.Cliente;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Cliente,

  System.StrUtils, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TClienteDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TCliente;
      aLista : TClientes;
      aOperacao : TTipoOperacaoDao;
      constructor Create();
      procedure SetValues(const aDataSet : TFDQuery; const aObject : TCliente);
      procedure ClearLista;
      class var aInstance : TClienteDao;
    public
      property Model : TCliente read aModel write aModel;
      property Lista : TClientes read aLista write aLista;
      property Operacao : TTipoOperacaoDao read aOperacao;

      procedure Load(const aBusca : String);
      procedure Insert();
      procedure Update();
      procedure Delete();
      procedure AddLista; overload;
      procedure AddLista(aCliente : TCliente); overload;

      function Find(const aCodigo : Currency; const IsLoadModel : Boolean) : Boolean;
      function GetCount() : Integer;
      function PodeExcluir : Boolean;

      class function GetInstance : TClienteDao;
  end;

implementation

{ TClienteDao }

uses
  UDM;

procedure TClienteDao.AddLista;
var
  I : Integer;
  o : TCliente;
begin
  I := High(aLista) + 2;
  o := TCliente.Create;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := o;
end;

procedure TClienteDao.AddLista(aCliente: TCliente);
var
  I : Integer;
begin
  I := High(aLista) + 2;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := aCliente;
end;

procedure TClienteDao.ClearLista;
begin
  SetLength(aLista, 0);
end;

constructor TClienteDao.Create;
begin
  inherited Create;
  aDDL      := TScriptDDL.GetInstance;
  aModel    := TCliente.Create;
  aOperacao := TTipoOperacaoDao.toBrowser;
  SetLength(aLista, 0);
end;

procedure TClienteDao.Delete;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Delete from ' + aDDL.getTableNameCliente);
    aSQL.Add('where id_cliente    = :id_cliente ');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_cliente').AsString := GUIDToString(aModel.ID);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluido;
    end;
  finally
    aSQL.Free;
  end;
end;

function TClienteDao.Find(const aCodigo: Currency;
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
    aSQL.Add('    c.* ');
    aSQL.Add('from ' + aDDL.getTableNameCliente + ' c');
    aSQL.Add('where c.cd_cliente = ' + CurrToStr(aCodigo));
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

function TClienteDao.GetCount: Integer;
var
  aRetorno : Integer;
  aSQL : TStringList;
begin
  aRetorno := 0;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select ');
    aSQL.Add('  count(*) as qt_clientes');
    aSQL.Add('from ' + aDDL.getTableNameCliente);
    aSQL.EndUpdate;
    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;
      OpenOrExecute;

      aRetorno := FieldByName('qt_clientes').AsInteger;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
    Result := aRetorno;
  end;
end;

class function TClienteDao.GetInstance: TClienteDao;
begin
  if not Assigned(aInstance) then
    aInstance := TClienteDao.Create();

  Result := aInstance;
end;

procedure TClienteDao.Insert;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Insert Into ' + aDDL.getTableNameCliente + '(');
    aSQL.Add('    id_cliente       ');
    aSQL.Add('  , cd_cliente       ');
    aSQL.Add('  , nm_cliente       ');
    aSQL.Add('  , tp_cliente       ');
    aSQL.Add('  , nr_cpf_cnpj      ');
    aSQL.Add('  , ds_contato       ');
    aSQL.Add('  , nr_telefone      ');
    aSQL.Add('  , nr_celular       ');
    aSQL.Add('  , ds_email         ');
    aSQL.Add('  , ds_endereco      ');
    aSQL.Add('  , ds_observacao    ');
    aSQL.Add('  , sn_ativo         ');
    aSQL.Add('  , sn_sincronizado  ');

    if (aModel.Referencia <> GUID_NULL) then
      aSQL.Add('  , cd_referencia    ');

    aSQL.Add(') values (');
    aSQL.Add('    :id_cliente      ');
    aSQL.Add('  , :cd_cliente      ');
    aSQL.Add('  , :nm_cliente      ');
    aSQL.Add('  , :tp_cliente      ');
    aSQL.Add('  , :nr_cpf_cnpj     ');
    aSQL.Add('  , :ds_contato      ');
    aSQL.Add('  , :nr_telefone     ');
    aSQL.Add('  , :nr_celular      ');
    aSQL.Add('  , :ds_email        ');
    aSQL.Add('  , :ds_endereco     ');
    aSQL.Add('  , :ds_observacao   ');
    aSQL.Add('  , :sn_ativo        ');
    aSQL.Add('  , :sn_sincronizado ');

    if (aModel.Referencia <> GUID_NULL) then
      aSQL.Add('  , :cd_referencia   ');

    aSQL.Add(')');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      if (aModel.Codigo = 0) then
        aModel.Codigo := GetNewID(aDDL.getTableNameCliente, 'cd_cliente');

      ParamByName('id_cliente').AsString   := GUIDToString(aModel.ID);
      ParamByName('cd_cliente').AsCurrency := aModel.Codigo;
      ParamByName('nm_cliente').AsString   := aModel.Nome;
      ParamByName('tp_cliente').AsString   := GetTipoClienteStr(aModel.Tipo);
      ParamByName('nr_cpf_cnpj').AsString  := aModel.CpfCnpj;
      ParamByName('ds_contato').AsString   := aModel.Contato;

      if (Length(aModel.Telefone) > 14) then // (91) 3295-3390
      begin
        ParamByName('nr_telefone').AsString := EmptyStr;
        ParamByName('nr_celular').AsString  := aModel.Telefone;
      end
      else
      begin
        ParamByName('nr_telefone').AsString := aModel.Telefone;
        ParamByName('nr_celular').AsString  := EmptyStr;
      end;

      ParamByName('ds_email').AsString      := aModel.Email;
      ParamByName('ds_endereco').AsString   := aModel.Endereco;
      ParamByName('ds_observacao').AsString := aModel.Observacao;

      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_sincronizado').AsString := FLAG_NAO;

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TClienteDao.Load(const aBusca: String);
var
  aSQL : TStringList;
  aCliente : TCliente;
  aFiltro  : String;
begin
  aSQL := TStringList.Create;
  try
    aFiltro := AnsiUpperCase(Trim(aBusca));

    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    c.* ');
    aSQL.Add('from ' + aDDL.getTableNameCliente + ' c');

    if (StrToCurrDef(aFiltro, 0) > 0) then
      aSQL.Add('where c.cd_cliente = ' + aFiltro)
    else
    if (Trim(aBusca) <> EmptyStr) then
    begin
      aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
      aSQL.Add('where c.nm_cliente like ' + QuotedStr(aFiltro));
    end;

    aSQL.Add('order by');
    aSQL.Add('    c.nm_cliente ');

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
            aCliente := TCliente.Create;
            SetValues(qrySQL, aCliente);

            AddLista(aCliente);
            qrySQL.Next;
          end;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
  end;
end;

function TClienteDao.PodeExcluir: Boolean;
var
  aRetorno : Boolean;
  aSQL : TStringList;
begin
  aRetorno := True;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select ');
    aSQL.Add('  count(id_cliente) as qt_clientes');
    aSQL.Add('from ' + aDDL.getTableNamePedido);
    aSQL.Add('where id_cliente = :id_cliente');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;
      ParamByName('id_cliente').AsString := GUIDToString(aModel.ID);
      OpenOrExecute;

      aRetorno := (FieldByName('qt_clientes').AsInteger = 0);

      qrySQL.Close;
    end;
  finally
    aSQL.Free;

    Result := aRetorno;
  end;
end;

procedure TClienteDao.SetValues(const aDataSet: TFDQuery;
  const aObject: TCliente);
begin
  with aDataSet, aObject do
  begin
    ID     := StringToGUID(FieldByName('id_cliente').AsString);
    Codigo := FieldByName('cd_cliente').AsCurrency;
    Tipo   := IfThen(AnsiUpperCase(FieldByName('tp_cliente').AsString) = 'F', tcPessoaFisica, tcPessoaJuridica);

    Nome         := FieldByName('nm_cliente').AsString;
    CpfCnpj      := FieldByName('nr_cpf_cnpj').AsString;
    Contato      := FieldByName('ds_contato').AsString;
    Telefone     := FieldByName('nr_telefone').AsString;
    Celular      := FieldByName('nr_celular').AsString;
    Email        := FieldByName('ds_email').AsString;
    Endereco     := FieldByName('ds_endereco').AsString;
    Observacao   := FieldByName('ds_observacao').AsString;
    Ativo        := (AnsiUpperCase(FieldByName('sn_ativo').AsString) = 'S');
    Sincronizado := (AnsiUpperCase(FieldByName('sn_sincronizado').AsString) = 'S');

    if (Trim(FieldByName('cd_referencia').AsString) <> EmptyStr) then
      Referencia := StringToGUID(FieldByName('cd_referencia').AsString)
    else
      Referencia := GUID_NULL;

    DataUltimaCompra  := FieldByName('dt_ultima_compra').AsDateTime;
    ValorUltimaCompra := FieldByName('vl_ultima_compra').AsCurrency;
  end;
end;

procedure TClienteDao.Update;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Update ' + aDDL.getTableNameCliente + ' Set');
    aSQL.Add('    cd_cliente      = :cd_cliente  ');
    aSQL.Add('  , nm_cliente      = :nm_cliente  ');
    aSQL.Add('  , tp_cliente      = :tp_cliente  ');
    aSQL.Add('  , nr_cpf_cnpj     = :nr_cpf_cnpj ');
    aSQL.Add('  , ds_contato      = :ds_contato  ');
    aSQL.Add('  , nr_telefone     = :nr_telefone ');
    aSQL.Add('  , nr_celular      = :nr_celular  ');
    aSQL.Add('  , ds_email        = :ds_email    ');
    aSQL.Add('  , ds_endereco     = :ds_endereco ');
    aSQL.Add('  , ds_observacao   = :ds_observacao   ');
    aSQL.Add('  , sn_ativo        = :sn_ativo        ');
    aSQL.Add('  , sn_sincronizado = :sn_sincronizado ');

    if (aModel.Referencia <> GUID_NULL) then
      aSQL.Add('  , cd_referencia = :cd_referencia   ');

    aSQL.Add('where id_cliente =  :id_cliente ');

    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_cliente').AsString   := GUIDToString(aModel.ID);
      ParamByName('cd_cliente').AsCurrency := aModel.Codigo;
      ParamByName('nm_cliente').AsString   := aModel.Nome;
      ParamByName('tp_cliente').AsString   := GetTipoClienteStr(aModel.Tipo);
      ParamByName('nr_cpf_cnpj').AsString  := aModel.CpfCnpj;
      ParamByName('ds_contato').AsString   := aModel.Contato;

      if (Length(aModel.Telefone) > 14) then // (91) 3295-3390
      begin
        ParamByName('nr_telefone').AsString := EmptyStr;
        ParamByName('nr_celular').AsString  := aModel.Telefone;
      end
      else
      begin
        ParamByName('nr_telefone').AsString := aModel.Telefone;
        ParamByName('nr_celular').AsString  := EmptyStr;
      end;

      ParamByName('ds_email').AsString      := aModel.Email;
      ParamByName('ds_endereco').AsString   := aModel.Endereco;
      ParamByName('ds_observacao').AsString := aModel.Observacao;

      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_sincronizado').AsString := FLAG_NAO;

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
