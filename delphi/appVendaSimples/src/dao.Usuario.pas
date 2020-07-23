unit dao.Usuario;

interface

uses
  UConstantes,
  app.Funcoes,
  classes.ScriptDDL,
  model.Usuario,

  System.StrUtils, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TUsuarioDao = class(TObject)
    strict private
      class var aInstance : TUsuarioDao;
    private
      aDDL   : TScriptDDL;
      aModel : TUsuario;
      aOperacao : TTipoOperacaoDao;
      constructor Create();

      procedure SetValues(const aDataSet : TFDQuery; const aObject : TUsuario);
      procedure ClearValues;
    public
      property Model    : TUsuario read aModel write aModel;
      property Operacao : TTipoOperacaoDao read aOperacao;

      procedure Load(const aBusca : String);
      procedure Insert();
      procedure Update();
      procedure Limpar();
      procedure Ativar();
      procedure Desativar();

      function Find(const aID : TGUID; const aEmail : String; const IsLoadModel : Boolean) : Boolean;

      class function GetInstance : TUsuarioDao;
  end;

implementation

uses
  UDM;

{ TUsuarioDao }

function TUsuarioDao.Find(const aID: TGUID; const aEmail: String; const IsLoadModel: Boolean): Boolean;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    u.* ');
    aSQL.Add('from ' + aDDL.getTableNameUsuario + ' u');

    if (aID <> GUID_NULL) then
      aSQL.Add('where u.id_usuario = :id_usuario')
    else
    if (Trim(aEmail) <> EmptyStr) then
      aSQL.Add('where u.ds_email = :ds_email');

    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if (aID <> GUID_NULL) then
        ParamByName('id_usuario').AsString := GUIDToString(aID)
      else
      if (Trim(aEmail) <> EmptyStr) then
        ParamByName('ds_email').AsString   := AnsiLowerCase(Trim(aEmail));

      if qrySQL.OpenOrExecute then
      begin
        aRetorno := (qrySQL.RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(qrySQL, aModel)
        else
          ClearValues;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.DisposeOf;
    Result := aRetorno;
  end;
end;

class function TUsuarioDao.GetInstance: TUsuarioDao;
begin
  if not Assigned(aInstance) then
    aInstance := TUsuarioDao.Create();

  Result := aInstance;
end;

procedure TUsuarioDao.Insert;
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
      SQL.Add('Insert Into ' + aDDL.getTableNameUsuario + '(');
      SQL.Add('    id_usuario     ');
      SQL.Add('  , nm_usuario     ');
      SQL.Add('  , ds_email       ');
      SQL.Add('  , ds_senha       ');
      SQL.Add('  , nr_celular     ');

      if (aModel.Cpf <> EmptyStr) then
        SQL.Add('  , nr_cpf         ');

      SQL.Add('  , tk_dispositivo ');
      SQL.Add('  , sn_ativo       ');
      SQL.Add(') values (');
      SQL.Add('    :id_usuario    ');
      SQL.Add('  , :nm_usuario    ');
      SQL.Add('  , :ds_email      ');
      SQL.Add('  , :ds_senha      ');
      SQL.Add('  , :nr_celular    ');

      if (aModel.Cpf <> EmptyStr) then
        SQL.Add('  , :nr_cpf        ');

      SQL.Add('  , :tk_dispositivo');
      SQL.Add('  , :sn_ativo      ');
      SQL.Add(')');
      SQL.EndUpdate;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      ParamByName('id_usuario').AsString := GUIDToString(aModel.ID);
      ParamByName('nm_usuario').AsString := aModel.Nome;
      ParamByName('ds_email').AsString   := aModel.Email;
      ParamByName('ds_senha').AsString   := MD5(aModel.Senha + aModel.Email);
      ParamByName('nr_celular').AsString := aModel.Celular;

      if (aModel.Cpf <> EmptyStr) then
        ParamByName('nr_cpf').AsString := aModel.Cpf;

      ParamByName('tk_dispositivo').AsString := aModel.TokenID;
      ParamByName('sn_ativo').AsString       := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioDao.Limpar;
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
      SQL.Add('Delete from ' + aDDL.getTableNameUsuario);
      SQL.EndUpdate;

      ExecSQL;
      aModel.Ativo := False;
      aOperacao := TTipoOperacaoDao.toExcluir;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioDao.Load(const aBusca: String);
var
  aQry : TFDQuery;
  aUsuario : TUsuario;
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
      SQL.Add('    u.* ');
      SQL.Add('from ' + aDDL.getTableNameUsuario + ' u');
      SQL.Add('where (u.sn_ativo = ' + QuotedStr('S') + ')');

      if (Trim(aBusca) <> EmptyStr) then
      begin
        aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
        SQL.Add('  and (u.nm_usuario like ' + QuotedStr(aFiltro) + ')');
      end;

      SQL.Add('order by');
      SQL.Add('    u.nm_usuario ');
      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        if (RecordCount > 0) then
          while not Eof do
          begin
            aUsuario := TUsuario.GetInstance;
            SetValues(aQry, aUsuario);
            aQry.Next;
          end
        else
          ClearValues;
      end;

      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioDao.SetValues(const aDataSet: TFDQuery; const aObject: TUsuario);
begin
  with aDataSet, aObject do
  begin
    ID      := StringToGUID(FieldByName('id_usuario').AsString);
    Nome    := FieldByName('nm_usuario').AsString;
    Email   := FieldByName('ds_email').AsString;
    Senha   := FieldByName('ds_senha').AsString;
    Cpf     := FieldByName('nr_cpf').AsString;
    Celular := FieldByName('nr_celular').AsString;
    TokenID := FieldByName('tk_dispositivo').AsString;
    Ativo   := (AnsiUpperCase(FieldByName('sn_ativo').AsString) = 'S');
  end;
end;

procedure TUsuarioDao.Update;
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
      SQL.Add('Update ' + aDDL.getTableNameUsuario + ' Set');
      SQL.Add('    nm_usuario     = :nm_usuario ');
      SQL.Add('  , ds_email       = :ds_email ');

      if (Trim(aModel.Senha) <> EmptyStr) then
        SQL.Add('  , ds_senha       = :ds_senha ');

      SQL.Add('  , nr_celular     = :nr_celular ');

      if (aModel.Cpf <> EmptyStr) then
        SQL.Add('  , nr_cpf         = :nr_cpf ');

      SQL.Add('  , sn_ativo       = :sn_ativo ');

      if (Trim(aModel.TokenID) <> EmptyStr) then
        SQL.Add('  , tk_dispositivo = :tk_dispositivo ');

      SQL.Add('where id_usuario   = :id_usuario');
      SQL.EndUpdate;

      ParamByName('id_usuario').AsString := GUIDToString(aModel.ID);
      ParamByName('nm_usuario').AsString := aModel.Nome;
      ParamByName('ds_email').AsString   := aModel.Email;

      if (Trim(aModel.Senha) <> EmptyStr) then
        ParamByName('ds_senha').AsString := MD5(aModel.Senha + aModel.Email);

      ParamByName('nr_celular').AsString := aModel.Celular;

      if (aModel.Cpf <> EmptyStr) then
        ParamByName('nr_cpf').AsString := aModel.Cpf;

      ParamByName('sn_ativo').AsString   := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);

      if (Trim(aModel.TokenID) <> EmptyStr) then
        ParamByName('tk_dispositivo').AsString := aModel.TokenID;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioDao.Ativar;
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
      SQL.Add('Update ' + aDDL.getTableNameUsuario + ' Set');
      SQL.Add('    nm_usuario   = :nm_usuario ');
      SQL.Add('  , sn_ativo     = :sn_ativo ');
      SQL.Add('where id_usuario = :id_usuario');
      SQL.EndUpdate;

      ParamByName('id_usuario').AsString := GUIDToString(aModel.ID);
      ParamByName('nm_usuario').AsString := aModel.Nome;
      ParamByName('sn_ativo').AsString   := FLAG_SIM;

      ExecSQL;
      aModel.Ativo := True;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioDao.Desativar;
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
      SQL.Add('Update ' + aDDL.getTableNameUsuario + ' Set');
      SQL.Add('    sn_ativo     = :sn_ativo ');
      SQL.Add('where id_usuario = :id_usuario');
      SQL.EndUpdate;

      ParamByName('id_usuario').AsString := GUIDToString(aModel.ID);
      ParamByName('sn_ativo').AsString   := FLAG_NAO;

      ExecSQL;
      aModel.Ativo := False;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioDao.ClearValues;
begin
  with aModel do
  begin
    ID      := GUID_NULL;
    Nome    := EmptyStr;
    Email   := EmptyStr;
    Senha   := EmptyStr;
    Cpf     := EmptyStr;
    Celular := EmptyStr;
    TokenID := EmptyStr;
    Ativo   := False;
  end;
end;

constructor TUsuarioDao.Create;
begin
  inherited Create;
  aDDL      := TScriptDDL.GetInstance;
  aModel    := TUsuario.GetInstance;
  aOperacao := TTipoOperacaoDao.toBrowser;
end;

end.
