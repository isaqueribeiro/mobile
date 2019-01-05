unit dao.Usuario;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Usuario,

  System.StrUtils, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TUsuarioDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TUsuario;
      aOperacao : TTipoOperacaoDao;
      constructor Create();
      procedure SetValues(const aDataSet : TFDQuery; const aObject : TUsuario);
      procedure ClearValues;

      class var aInstance : TUsuarioDao;
    public
      property Model    : TUsuario read aModel write aModel;
      property Operacao : TTipoOperacaoDao read aOperacao;

      procedure Load(const aBusca : String);
      procedure Insert();
      procedure Update();

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
    aSQL.Free;
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
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Insert Into ' + aDDL.getTableNameUsuario + '(');
    aSQL.Add('    id_usuario     ');
    aSQL.Add('  , nm_usuario     ');
    aSQL.Add('  , ds_email       ');
    aSQL.Add('  , ds_senha       ');
    aSQL.Add('  , nr_celular     ');
    aSQL.Add('  , nr_cpf         ');
    aSQL.Add('  , tk_dispositivo ');
    aSQL.Add('  , sn_ativo       ');
    aSQL.Add(') values (');
    aSQL.Add('    :id_usuario    ');
    aSQL.Add('  , :nm_usuario    ');
    aSQL.Add('  , :ds_email      ');
    aSQL.Add('  , :ds_senha      ');
    aSQL.Add('  , :nr_celular    ');
    aSQL.Add('  , :nr_cpf        ');
    aSQL.Add('  , :tk_dispositivo');
    aSQL.Add('  , :sn_ativo      ');
    aSQL.Add(')');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      ParamByName('id_usuario').AsString := GUIDToString(aModel.ID);
      ParamByName('nm_usuario').AsString := aModel.Nome;
      ParamByName('ds_email').AsString   := aModel.Email;
      ParamByName('ds_senha').AsString   := aModel.Senha;
      ParamByName('nr_celular').AsString := aModel.Celular;
      ParamByName('nr_cpf').AsString     := aModel.Cpf;
      ParamByName('tk_dispositivo').AsString := aModel.TokenID;
      ParamByName('sn_ativo').AsString       := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TUsuarioDao.Load(const aBusca: String);
var
  aSQL : TStringList;
  aUsuario : TUsuario;
  aFiltro  : String;
begin
  aSQL := TStringList.Create;
  try
    aFiltro := AnsiUpperCase(Trim(aBusca));

    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    u.* ');
    aSQL.Add('from ' + aDDL.getTableNameUsuario + ' u');
    aSQL.Add('where (u.sn_ativo = ' + QuotedStr('S') + ')');

    if (Trim(aBusca) <> EmptyStr) then
    begin
      aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
      aSQL.Add('  and (u.nm_usuario like ' + QuotedStr(aFiltro) + ')');
    end;

    aSQL.Add('order by');
    aSQL.Add('    u.nm_usuario ');

    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if qrySQL.OpenOrExecute then
      begin
        if (qrySQL.RecordCount > 0) then
          while not qrySQL.Eof do
          begin
            aUsuario := TUsuario.GetInstance;
            SetValues(qrySQL, aUsuario);
            qrySQL.Next;
          end
        else
          ClearValues;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
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
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Update ' + aDDL.getTableNameUsuario + ' Set');
    aSQL.Add('    nm_usuario     = :nm_usuario ');
    aSQL.Add('  , ds_email       = :ds_email ');
    aSQL.Add('  , ds_senha       = :ds_senha ');
    aSQL.Add('  , nr_celular     = :nr_celular ');
    aSQL.Add('  , nr_cpf         = :nr_cpf ');
    aSQL.Add('  , sn_ativo       = :sn_ativo ');

    if (Trim(aModel.TokenID) <> EmptyStr) then
      aSQL.Add('  , tk_dispositivo = :tk_dispositivo ');

    aSQL.Add('where id_usuario   = :id_usuario');

    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_usuario').AsString := GUIDToString(aModel.ID);
      ParamByName('nm_usuario').AsString := aModel.Nome;
      ParamByName('ds_email').AsString   := aModel.Email;
      ParamByName('ds_senha').AsString   := aModel.Senha;
      ParamByName('nr_celular').AsString := aModel.Celular;
      ParamByName('nr_cpf').AsString     := aModel.Cpf;
      ParamByName('sn_ativo').AsString   := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);

      if (Trim(aModel.TokenID) <> EmptyStr) then
        ParamByName('tk_dispositivo').AsString := aModel.TokenID;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aSQL.Free;
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
