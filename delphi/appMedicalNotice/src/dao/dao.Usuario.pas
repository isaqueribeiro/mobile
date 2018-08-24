unit dao.Usuario;

interface

uses
  classes.ScriptDDL,
  model.Usuario,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.StrUtils;

type
  TUsuarioDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TUsuario;
      aMainMenu : Boolean;
      constructor Create();
      class var aInstance : TUsuarioDao;
    public
      property Model : TUsuario read aModel write aModel;
      property MainMenu : Boolean read aMainMenu write aMainMenu;

      procedure Load();
      procedure Insert();
      procedure Update();

      function Find(const aCodigo, aEmail : String; const IsLoadModel : Boolean) : Boolean;
      function IsAtivo : Boolean;

      class function GetInstance : TUsuarioDao;
  end;

implementation

{ TUsuarioDao }

uses UDados;

constructor TUsuarioDao.Create;
begin
  inherited Create;
  aDDL   := TScriptDDL.GetInstance;
  aModel := TUsuario.GetInstance;
  aMainMenu := False;
end;

function TUsuarioDao.Find(const aCodigo, aEmail: String;
  const IsLoadModel: Boolean): Boolean;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select * ');
    aSQL.Add('from ' + aDDL.getTableNameUsuario);
    aSQL.Add('where (cd_usuario = :cd_usuario)');
    aSQL.Add('  and (ds_email   = :ds_email)');
    aSQL.EndUpdate;
    with DtmDados, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      qrySQL.ParamByName('cd_usuario').AsString := aCodigo;
      qrySQL.ParamByName('ds_email').AsString   := aEmail;

      if qrySQL.OpenOrExecute then
      begin
        aRetorno := (qrySQL.RecordCount > 0);

        if aRetorno then
          Model.Id := StringToGUID(FieldByName('id_usuario').AsString);

        if aRetorno and IsLoadModel then
        begin
          Model.Codigo := FieldByName('cd_usuario').AsString;
          Model.Nome   := FieldByName('nm_usuario').AsString;
          Model.Email  := FieldByName('ds_email').AsString;
          Model.Senha  := FieldByName('ds_senha').AsString;
          Model.Prestador  := FieldByName('cd_prestador').AsCurrency;
          Model.Observacao := FieldByName('ds_observacao').AsString;
          Model.Ativo      := (FieldByName('sn_ativo').AsString = 'S');
        end;
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
    aSQL.Add('      id_usuario     ');
    aSQL.Add('    , cd_usuario     ');
    aSQL.Add('    , nm_usuario     ');
    aSQL.Add('    , ds_email       ');
    aSQL.Add('    , ds_senha       ');
    aSQL.Add('    , cd_prestador   ');
    aSQL.Add('    , ds_observacao  ');
    aSQL.Add('    , sn_ativo       ');
    aSQL.Add(') values (');
    aSQL.Add('      :id_usuario    ');
    aSQL.Add('    , :cd_usuario    ');
    aSQL.Add('    , :nm_usuario    ');
    aSQL.Add('    , :ds_email      ');
    aSQL.Add('    , :ds_senha      ');
    aSQL.Add('    , :cd_prestador  ');
    aSQL.Add('    , :ds_observacao ');
    aSQL.Add('    , :sn_ativo      ');
    aSQL.Add(')');
    aSQL.EndUpdate;
    with DtmDados, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if (aModel.Id = GUID_NULL) then
        aModel.NewId;

      ParamByName('id_usuario').AsString     := GUIDToString(aModel.Id);
      ParamByName('cd_usuario').AsString     := aModel.Codigo;
      ParamByName('nm_usuario').AsString     := aModel.Nome;
      ParamByName('ds_email').AsString       := aModel.Email;
      ParamByName('ds_senha').AsString       := aModel.Senha;
      ParamByName('cd_prestador').AsCurrency := aModel.Prestador;
      ParamByName('ds_observacao').AsString  := aModel.Observacao;
      ParamByName('sn_ativo').AsString       := IfThen(aModel.Ativo, 'S', 'N');
      ExecSQL;
    end;
  finally
    aSQL.Free;
  end;
end;

function TUsuarioDao.IsAtivo: Boolean;
begin
  Result := aModel.Ativo;
end;

procedure TUsuarioDao.Load;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select * ');
    aSQL.Add('from ' + aDDL.getTableNameUsuario);
    aSQL.Add('where sn_ativo = ' + QuotedStr('S'));
    aSQL.EndUpdate;
    with DtmDados, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if qrySQL.OpenOrExecute then
      begin
        aRetorno := (qrySQL.RecordCount > 0);
        if aRetorno then
        begin
          Model.Id     := StringToGUID(FieldByName('id_usuario').AsString);
          Model.Codigo := FieldByName('cd_usuario').AsString;
          Model.Nome   := FieldByName('nm_usuario').AsString;
          Model.Email  := FieldByName('ds_email').AsString;
          Model.Senha  := FieldByName('ds_senha').AsString;
          Model.Prestador  := FieldByName('cd_prestador').AsCurrency;
          Model.Observacao := FieldByName('ds_observacao').AsString;
          Model.Ativo      := (FieldByName('sn_ativo').AsString = 'S');
        end
        else
        begin
          Model.Id     := GUID_NULL;
          Model.Codigo := EmptyStr;
          Model.Nome   := EmptyStr;
          Model.Email  := EmptyStr;
          Model.Senha  := EmptyStr;
          Model.Prestador  := 0.0;
          Model.Observacao := EmptyStr;
          Model.Ativo      := False;
        end;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
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
    aSQL.Add('      cd_usuario     = :cd_usuario    ');
    aSQL.Add('    , nm_usuario     = :nm_usuario    ');
    aSQL.Add('    , ds_email       = :ds_email      ');
    aSQL.Add('    , ds_senha       = :ds_senha      ');
    aSQL.Add('    , cd_prestador   = :cd_prestador  ');
    aSQL.Add('    , ds_observacao  = :ds_observacao ');
    aSQL.Add('    , sn_ativo       = :sn_ativo      ');
    aSQL.Add('where id_usuario     = :id_usuario    ');
    aSQL.EndUpdate;
    with DtmDados, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('id_usuario').AsString     := GUIDToString(aModel.Id);
      ParamByName('cd_usuario').AsString     := aModel.Codigo;
      ParamByName('nm_usuario').AsString     := aModel.Nome;
      ParamByName('ds_email').AsString       := aModel.Email;
      ParamByName('ds_senha').AsString       := aModel.Senha;
      ParamByName('cd_prestador').AsCurrency := aModel.Prestador;
      ParamByName('ds_observacao').AsString  := aModel.Observacao;
      ParamByName('sn_ativo').AsString       := IfThen(aModel.Ativo, 'S', 'N');
      ExecSQL;
    end;
  finally
    aSQL.Free;
  end;
end;

end.

