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
      procedure Limpar();
      procedure Sincronizado();
      procedure AddLista; overload;
      procedure AddLista(aCliente : TCliente); overload;
      procedure CarregarDadosToSynchrony;

      function Find(const aCodigo : Currency; const IsLoadModel : Boolean) : Boolean; overload;
      function Find(const aID : TGUID; const aCpfCnpj : String; const IsLoadModel : Boolean) : Boolean; overload;
      function GetCount() : Integer;
      function GetCountSincronizar() : Integer;
      function PodeExcluir : Boolean;

      class function GetInstance : TClienteDao;
  end;

implementation

{ TClienteDao }

uses
  UDM, app.Funcoes;

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

procedure TClienteDao.CarregarDadosToSynchrony;
var
  aQry : TFDQuery;
  aCliente : TCliente;
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
      SQL.Add('    c.* ');
      SQL.Add('from ' + aDDL.getTableNameCliente + ' c');
      SQL.Add('where (sn_sincronizado = ' + QuotedStr(FLAG_NAO) +')');
      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        ClearLista;
        if (RecordCount > 0) then
          while not Eof do
          begin
            aCliente := TCliente.Create;
            SetValues(aQry, aCliente);

            AddLista(aCliente);
            Next;
          end;
      end;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
  end;
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
      SQL.Add('Delete from ' + aDDL.getTableNameCliente);
      SQL.Add('where id_cliente = :id_cliente ');
      SQL.EndUpdate;

      ParamByName('id_cliente').AsString := GUIDToString(aModel.ID);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TClienteDao.Find(const aID: TGUID; const aCpfCnpj: String; const IsLoadModel: Boolean): Boolean;
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
      SQL.Add('    c.* ');
      SQL.Add('from ' + aDDL.getTableNameCliente + ' c');
      SQL.Add('where (c.id_cliente  = :id_cliente)');
      SQL.Add('   or (c.nr_cpf_cnpj = :nr_cpf_cnpj)');
      SQL.EndUpdate;

      ParamByName('id_cliente').AsString  := aID.ToString;
      ParamByName('nr_cpf_cnpj').AsString := aCpfCnpj.Trim();

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

function TClienteDao.Find(const aCodigo: Currency;
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
      SQL.Add('    c.* ');
      SQL.Add('from ' + aDDL.getTableNameCliente + ' c');
      SQL.Add('where c.cd_cliente = ' + CurrToStr(aCodigo));
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

function TClienteDao.GetCount: Integer;
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
      SQL.Add('  count(*) as qt_clientes');
      SQL.Add('from ' + aDDL.getTableNameCliente);
      SQL.EndUpdate;

      OpenOrExecute;

      aRetorno := FieldByName('qt_clientes').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TClienteDao.GetCountSincronizar: Integer;
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
      SQL.Add('  count(*) as qt_clientes');
      SQL.Add('from ' + aDDL.getTableNameCliente);
      SQL.Add('where (sn_sincronizado = ' + QuotedStr(FLAG_NAO) +')');
      SQL.EndUpdate;

      OpenOrExecute;

      aRetorno := FieldByName('qt_clientes').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
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
      SQL.Add('Insert Into ' + aDDL.getTableNameCliente + '(');
      SQL.Add('    id_cliente       ');
      SQL.Add('  , cd_cliente       ');
      SQL.Add('  , nm_cliente       ');
      SQL.Add('  , tp_cliente       ');
      SQL.Add('  , nr_cpf_cnpj      ');
      SQL.Add('  , ds_contato       ');
      SQL.Add('  , nr_telefone      ');
      SQL.Add('  , nr_celular       ');
      SQL.Add('  , ds_email         ');
      SQL.Add('  , ds_endereco      ');
      SQL.Add('  , ds_observacao    ');
      SQL.Add('  , sn_ativo         ');
      SQL.Add('  , sn_sincronizado  ');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , cd_referencia    ');

      SQL.Add(') values (');
      SQL.Add('    :id_cliente      ');
      SQL.Add('  , :cd_cliente      ');
      SQL.Add('  , :nm_cliente      ');
      SQL.Add('  , :tp_cliente      ');
      SQL.Add('  , :nr_cpf_cnpj     ');
      SQL.Add('  , :ds_contato      ');
      SQL.Add('  , :nr_telefone     ');
      SQL.Add('  , :nr_celular      ');
      SQL.Add('  , :ds_email        ');
      SQL.Add('  , :ds_endereco     ');
      SQL.Add('  , :ds_observacao   ');
      SQL.Add('  , :sn_ativo        ');
      SQL.Add('  , :sn_sincronizado ');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , :cd_referencia   ');

      SQL.Add(')');
      SQL.EndUpdate;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      if (aModel.Codigo = 0) then
        aModel.Codigo := GetNewID(aDDL.getTableNameCliente, 'cd_cliente', EmptyStr);

      ParamByName('id_cliente').AsString    := GUIDToString(aModel.ID);
      ParamByName('cd_cliente').AsCurrency  := aModel.Codigo;
      ParamByName('nm_cliente').AsString    := aModel.Nome;
      ParamByName('tp_cliente').AsString    := GetTipoClienteStr(aModel.Tipo);
      ParamByName('nr_cpf_cnpj').AsString   := aModel.CpfCnpj;
      ParamByName('ds_contato').AsString    := aModel.Contato;
      ParamByName('nr_telefone').AsString   := aModel.Telefone;
      ParamByName('nr_celular').AsString    := aModel.Celular;
      ParamByName('ds_email').AsString      := aModel.Email;
      ParamByName('ds_endereco').AsString   := aModel.Endereco;
      ParamByName('ds_observacao').AsString := aModel.Observacao;

      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_sincronizado').AsString := IfThen(aModel.Sincronizado, FLAG_SIM, FLAG_NAO);

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TClienteDao.Limpar;
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
      SQL.Add('Delete from ' + aDDL.getTableNameCliente);
      SQL.EndUpdate;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluir;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TClienteDao.Load(const aBusca: String);
var
  aQry : TFDQuery;
  aCliente : TCliente;
  aFiltro  : String;
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
      SQL.Add('    c.* ');
      SQL.Add('from ' + aDDL.getTableNameCliente + ' c');

      if (StrToCurrDef(aFiltro, 0) > 0) then
        SQL.Add('where c.cd_cliente = ' + aFiltro)
      else
      if StrIsGUID(aBusca) then
        SQL.Add('where c.id_cliente = ' + QuotedStr(aFiltro))
      else
      if (Trim(aBusca) <> EmptyStr) then
      begin
        aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
        SQL.Add('where c.nm_cliente like ' + QuotedStr(aFiltro));
      end;

      SQL.Add('order by');
      SQL.Add('    c.nm_cliente ');

      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        ClearLista;
        if (RecordCount > 0) then
          while not Eof do
          begin
            aCliente := TCliente.Create;
            SetValues(aQry, aCliente);

            AddLista(aCliente);
            Next;
          end;
      end;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TClienteDao.PodeExcluir: Boolean;
var
  aRetorno : Boolean;
  aQry : TFDQuery;
begin
  aRetorno := True;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select ');
      SQL.Add('  count(id_cliente) as qt_clientes');
      SQL.Add('from ' + aDDL.getTableNamePedido);
      SQL.Add('where id_cliente = :id_cliente');
      SQL.EndUpdate;

      ParamByName('id_cliente').AsString := GUIDToString(aModel.ID);
      OpenOrExecute;

      aRetorno := (FieldByName('qt_clientes').AsInteger = 0);

      aQry.Close;
    end;
  finally
    aQry.DisposeOf;

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

procedure TClienteDao.Sincronizado;
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
      SQL.Add('Update ' + aDDL.getTableNameCliente + ' Set');
      SQL.Add('    sn_ativo        = :sn_ativo        ');
      SQL.Add('  , sn_sincronizado = :sn_sincronizado ');
      SQL.Add('where id_cliente =  :id_cliente ');

      SQL.EndUpdate;

      ParamByName('id_cliente').AsString      := GUIDToString(aModel.ID);
      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_sincronizado').AsString := IfThen(aModel.Sincronizado, FLAG_SIM, FLAG_NAO);

      ExecSQL;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TClienteDao.Update;
var
  aQry  : TFDQuery;
  aFone : String;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    aFone := aModel.Telefone.Trim();

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Update ' + aDDL.getTableNameCliente + ' Set');
      SQL.Add('    cd_cliente      = :cd_cliente  ');
      SQL.Add('  , nm_cliente      = :nm_cliente  ');
      SQL.Add('  , tp_cliente      = :tp_cliente  ');
      SQL.Add('  , nr_cpf_cnpj     = :nr_cpf_cnpj ');
      SQL.Add('  , ds_contato      = :ds_contato  ');

      if (Length(aFone) > 14) then // (91) 3295-3390
        SQL.Add('  , nr_celular    = :nr_celular  ')
      else
        SQL.Add('  , nr_telefone   = :nr_telefone ');

      SQL.Add('  , ds_email        = :ds_email    ');
      SQL.Add('  , ds_endereco     = :ds_endereco ');
      SQL.Add('  , ds_observacao   = :ds_observacao   ');
      SQL.Add('  , sn_ativo        = :sn_ativo        ');
      SQL.Add('  , sn_sincronizado = :sn_sincronizado ');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , cd_referencia = :cd_referencia   ');

      SQL.Add('where id_cliente =  :id_cliente ');

      SQL.EndUpdate;

      ParamByName('id_cliente').AsString   := GUIDToString(aModel.ID);
      ParamByName('cd_cliente').AsCurrency := aModel.Codigo;
      ParamByName('nm_cliente').AsString   := aModel.Nome;
      ParamByName('tp_cliente').AsString   := GetTipoClienteStr(aModel.Tipo);
      ParamByName('nr_cpf_cnpj').AsString  := aModel.CpfCnpj;
      ParamByName('ds_contato').AsString   := aModel.Contato;

      if (Length(aFone) > 14) then // (91) 3295-3390
        ParamByName('nr_celular').AsString  := aFone
      else
        ParamByName('nr_telefone').AsString := aFone;

      ParamByName('ds_email').AsString      := aModel.Email;
      ParamByName('ds_endereco').AsString   := aModel.Endereco;
      ParamByName('ds_observacao').AsString := aModel.Observacao;

      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_sincronizado').AsString := IfThen(aModel.Sincronizado, FLAG_SIM, FLAG_NAO);

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
