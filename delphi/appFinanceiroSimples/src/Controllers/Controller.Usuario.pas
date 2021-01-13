unit Controller.Usuario;

interface

uses
  System.SysUtils, Classes.ScriptDDL, Model.Usuario, FireDAC.Comp.Client, Data.DB;

type
  TUsuarioController = class
    strict private
      class var _instance : TUsuarioController;
    private
      FDDL   : TScriptDDL;
      FModel : TUsuarioModel;
      procedure SetAtributes(const aDataSet : TDataSet; aModel : TUsuarioModel);
    protected
      constructor Create;
      destructor Destroy; override;
    public
      class function GetInstance : TUsuarioController;

      property Attributes : TUsuarioModel read  FModel;

      procedure Load(out aErro : String);
      procedure RenovarHash(out aErro : String);

      function Insert(out aErro : String) : Boolean;
      function Update(out aErro : String) : Boolean;
      function Delete(out aErro : String) : Boolean;

      function Find(aLogin : String; out aErro : String; const RETURN_ATTRIBUTES : Boolean = False) : Boolean;
      function Autenticar(aLogin, aSenha : String; out aErro : String) : Boolean;
  end;

implementation

uses
  System.StrUtils, System.Classes, FMX.Graphics,
  DataModule.Conexao, Services.Hash;

{ TUsuarioController }

const
  FLAG_SIM = 'S';
  FLAG_NAO = 'N';

function TUsuarioController.Autenticar(aLogin, aSenha: String; out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if aLogin.Trim.IsEmpty then
  begin
    aErro := 'Informe o e-mail';
    Exit;
  end;

  if aSenha.Trim.IsEmpty then
  begin
    aErro := 'Informe a senha';
    Exit;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Select ');
        Add('    id_usuario ');
        Add('  , cd_usuario ');
        Add('  , nm_usuario ');
        Add('  , ds_email   ');
        Add('  , ds_senha   ');
        Add('  , sn_temfoto ');
        Add('  , ft_usuario ');
        Add('  , sn_logado  ');
        Add('from ' + FDDL.getTableNameUsuario);
        Add('where (ds_email = :login)');
        EndUpdate;

        ParamByName('login').AsString := aLogin.Trim.ToLower;
        Open;

        if not IsEmpty then
        begin
          Result := TServicesHash.StrCompareHash(FieldByName('ds_senha').AsString, aSenha, aLogin.Trim.ToLower);

          if not Result then
            aErro := 'Usuário e senha inválidos!'
          else
            SetAtributes(aQry, FModel);
        end
        else
          aErro := 'Usuário e senha não cadastrados!';
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar autenticar o usuário: ' + E.Message;
    end;
  finally
    aQry.Close;
    aQry.DisposeOf;
  end;
end;

constructor TUsuarioController.Create;
begin
  FDDL   := TScriptDDL.getInstance();
  FModel := TUsuarioModel.New;
  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(FDDL.getCreateTableUsuario.Text, True);
end;

function TUsuarioController.Delete(out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if (FModel.ID = TGUID.Empty) then
  begin
    aErro := 'Informe o código do usuário';
    Exit;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Delete from ' + FDDL.getTableNameUsuario);
        Add('where id_usuario = :id_usuario');
        EndUpdate;

        ParamByName('id_usuario').Value := FModel.ID.ToString;

        ExecSQL;

        Result := True;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar excluir o usuário: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

destructor TUsuarioController.Destroy;
begin
  FDDL.DisposeOf;
  FModel.DisposeOf;
  inherited;
end;

function TUsuarioController.Find(aLogin: String; out aErro: String; const RETURN_ATTRIBUTES: Boolean): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if aLogin.Trim.IsEmpty then
  begin
    aErro := 'Informe o e-mail';
    Exit;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Select ');
        Add('    id_usuario ');
        Add('  , cd_usuario ');
        Add('  , nm_usuario ');
        Add('  , ds_email   ');
        Add('  , ds_senha   ');
        Add('  , sn_temfoto ');
        Add('  , ft_usuario ');
        Add('  , sn_logado  ');
        Add('from ' + FDDL.getTableNameUsuario);
        Add('where (ds_email = :login)');
        EndUpdate;

        ParamByName('login').AsString := aLogin.Trim.ToLower;
        Open;

        Result := not IsEmpty;

        if Result then
        begin
          if RETURN_ATTRIBUTES then
            SetAtributes(aQry, FModel)
          else
          begin
            FModel.ID     := StringToGUID(FieldByName('id_usuario').AsString);
            FModel.Codigo := FieldByName('cd_usuario').AsInteger;
          end;
        end;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar localizar o usuário: ' + E.Message;
    end;
  finally
    aQry.Close;
    aQry.DisposeOf;
  end;
end;

class function TUsuarioController.GetInstance: TUsuarioController;
begin
  if not Assigned(_instance) then
    _instance := TUsuarioController.Create;

  Result := _instance;
end;

function TUsuarioController.Insert(out aErro: String): Boolean;
var
  aQry   : TFDQuery;
  aGuid  : TGUID;
begin
  Result := False;

  if FModel.Nome.IsEmpty then
  begin
    aErro := 'Informe o nome';
    Exit;
  end;

  if FModel.Email.IsEmpty then
  begin
    aErro := 'Informe o e-mail';
    Exit;
  end;

  if FModel.Senha.IsEmpty then
  begin
    aErro := 'Informe a senha';
    Exit;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Insert Into ' + FDDL.getTableNameUsuario + '(');
        Add('    id_usuario ');
        Add('  , cd_usuario ');
        Add('  , nm_usuario ');
        Add('  , ds_email   ');
        Add('  , ds_senha   ');
        Add('  , sn_temfoto ');
        Add('  , ft_usuario ');
        Add('  , sn_logado  ');
        Add(') values (');
        Add('    :id_usuario ');
        Add('  , :cd_usuario ');
        Add('  , :nm_usuario ');
        Add('  , :ds_email   ');
        Add('  , :ds_senha   ');
        Add('  , :sn_temfoto ');
        Add('  , :ft_usuario ');
        Add('  , :sn_logado  ');
        Add(')');
        EndUpdate;

        // Gerar o ID
        if (FModel.ID = TGuid.Empty) then
        begin
          CreateGUID(aGuid);
          FModel.ID := aGuid;
        end;

        // Gerar o CÓDIGO
        FModel.Codigo := TDMConexao
          .GetInstance()
          .GetNexID(FDDL.getTableNameUsuario, 'cd_usuario');

        ParamByName('id_usuario').Value := FModel.ID.ToString;
        ParamByName('cd_usuario').Value := FModel.Codigo;
        ParamByName('nm_usuario').Value := FModel.Nome;
        ParamByName('ds_email').Value   := FModel.Email;
        ParamByName('ds_senha').Value   := TServicesHash.StrToHash(FModel.Senha, FModel.Email);
        ParamByName('sn_logado').Value  := IfThen(FModel.Logado, FLAG_SIM, FLAG_NAO);
        ParamByName('sn_temfoto').Value := IfThen(FModel.TemFoto, FLAG_SIM, FLAG_NAO);

        if Assigned(FModel.Foto) then
          ParamByName('ft_usuario').Assign( FModel.Foto )
        else
          ParamByName('ft_usuario').Clear;

        ExecSQL;

        Result := True;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar inserir o usuário: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioController.Load(out aErro: String);
var
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Select ');
        Add('    id_usuario ');
        Add('  , cd_usuario ');
        Add('  , nm_usuario ');
        Add('  , ds_email   ');
        Add('  , ds_senha   ');
        Add('  , sn_temfoto ');
        Add('  , ft_usuario ');
        Add('  , sn_logado  ');
        Add('from ' + FDDL.getTableNameUsuario);
        Add('where (sn_logado = ' + QuotedStr(FLAG_SIM) + ')');
        Add('order by');
        Add('    cd_usuario');
        EndUpdate;

        Open;

        if not IsEmpty then
          SetAtributes(aQry, FModel);
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar carregar o usuário: ' + E.Message;
    end;
  finally
    aQry.Close;
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioController.RenovarHash(out aErro : String);
var
  aQry : TFDQuery;
begin
  if FModel.Email.IsEmpty then
  begin
    aErro := 'Informe o e-mail';
    Exit;
  end;

  if FModel.Senha.IsEmpty then
  begin
    aErro := 'Informe a senha';
    Exit;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Update ' + FDDL.getTableNameUsuario + ' set ');
        Add('    ds_senha   = :ds_senha ');
        Add('  , sn_logado  = :sn_logado ');
        Add('where id_usuario = :id_usuario');
        EndUpdate;

        ParamByName('id_usuario').Value := FModel.ID.ToString;
        ParamByName('ds_senha').Value   := TServicesHash.StrRenewHash(FModel.Senha, FModel.Email);
        ParamByName('sn_logado').Value  := FLAG_SIM;

        ExecSQL;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar renovar o hash da senha do usuário: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TUsuarioController.SetAtributes(const aDataSet: TDataSet; aModel: TUsuarioModel);
var
  aStream : TStream;
begin
  aStream := TStream.Create;
  try
    with aDataSet, aModel do
    begin
      ID      := StringToGUID(FieldByName('id_usuario').AsString);
      Codigo  := FieldByName('cd_usuario').AsInteger;
      Nome    := FieldByName('nm_usuario').AsString;
      Email   := FieldByName('ds_email').AsString;
      Senha   := FieldByName('ds_senha').AsString;
      Logado  := (FieldByName('sn_logado').AsString = FLAG_SIM);
      TemFoto := (FieldByName('sn_temfoto').AsString = FLAG_SIM);

      // #0#0#0#0'IEND®B`‚'
      try
        if (Trim(FieldByName('ft_usuario').AsString) <> EmptyStr) then
        begin
          Foto    := TBitmap.Create;
          aStream := CreateBlobStream(FieldByName('ft_usuario'), TBlobStreamMode.bmRead);

          Foto.LoadFromStream( aStream );
        end
        else
          Foto := nil;
      except
        Foto := nil;
      end;
    end;
  finally
    aStream.DisposeOf;
  end;
end;

function TUsuarioController.Update(out aErro: String): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  if FModel.Codigo < 1 then
  begin
    aErro := 'Informe o código do usuário';
    Exit;
  end;

  if FModel.Nome.IsEmpty then
  begin
    aErro := 'Informe o nome';
    Exit;
  end;

  if FModel.Email.IsEmpty then
  begin
    aErro := 'Informe o e-mail';
    Exit;
  end;

  if FModel.Senha.IsEmpty then
  begin
    aErro := 'Informe a senha';
    Exit;
  end;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Update ' + FDDL.getTableNameUsuario + ' set ');
        Add('    nm_usuario = :nm_usuario ');
        Add('  , ds_email   = :ds_email ');
        Add('  , ds_senha   = :ds_senha ');
        Add('  , sn_temfoto = :sn_temfoto ');
        Add('  , ft_usuario = :ft_usuario ');
        Add('  , sn_logado  = :sn_logado ');
        Add('where id_usuario = :id_usuario');
        EndUpdate;

        ParamByName('id_usuario').Value := FModel.ID.ToString;
        ParamByName('nm_usuario').Value := FModel.Nome;
        ParamByName('ds_email').Value   := FModel.Email;

        if TServicesHash.StrIsHash(FModel.Senha) then
          ParamByName('ds_senha').Value := TServicesHash.StrRenewHash(FModel.Senha, FModel.Email)
        else
          ParamByName('ds_senha').Value := TServicesHash.StrToHash(FModel.Senha, FModel.Email);

        ParamByName('sn_logado').Value  := IfThen(FModel.Logado, FLAG_SIM, FLAG_NAO);
        ParamByName('sn_temfoto').Value := IfThen(FModel.TemFoto, FLAG_SIM, FLAG_NAO);

        if Assigned(FModel.Foto) then
          ParamByName('ft_usuario').Assign( FModel.Foto )
        else
          ParamByName('ft_usuario').Clear;

        ExecSQL;

        Result := True;
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar atualizar ao usuário: ' + E.Message;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
