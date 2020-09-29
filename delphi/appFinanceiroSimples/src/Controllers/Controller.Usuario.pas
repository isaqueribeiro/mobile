unit Controller.Usuario;

interface

uses
  System.SysUtils, Model.Usuario, FireDAC.Comp.Client, Data.DB;

type
  TUsuarioController = class
    strict private
      class var _instance : TUsuarioController;
    private
      FModel : TUsuarioModel;
      procedure SetAtributes(const aDataSet : TDataSet; aModel : TUsuarioModel);
    protected
      constructor Create;
      destructor Destroy; override;
    public
      class function GetInstance : TUsuarioController;

      property Attributes : TUsuarioModel read  FModel;

      procedure Load(out aErro : String);

      function Insert(out aErro : String) : Boolean;
      function Update(out aErro : String) : Boolean;
      function Delete(out aErro : String) : Boolean;
  end;

implementation

uses
  DataModule.Conexao, Classes.ScriptDDL, FMX.Graphics, System.StrUtils;

{ TUsuarioController }

const
  FLAG_SIM = 'S';
  FLAG_NAO = 'N';

constructor TUsuarioController.Create;
begin
  FModel := TUsuarioModel.New;
  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(TScriptDDL.getInstance().getCreateTableUsuario.Text, True);
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
        Add('Delete from ' + TScriptDDL.getInstance().getTableNameUsuario);
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
  FModel.DisposeOf;
  inherited;
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
        Add('Insert Into ' + TScriptDDL.getInstance().getTableNameUsuario + '(');
        Add('    id_usuario ');
        Add('  , cd_usuario ');
        Add('  , nm_usuario ');
        Add('  , ds_email   ');
        Add('  , ds_senha   ');
        Add('  , ft_usuario ');
        Add('  , sn_logado  ');
        Add(') values (');
        Add('    :id_usuario ');
        Add('  , :cd_usuario ');
        Add('  , :nm_usuario ');
        Add('  , :ds_email   ');
        Add('  , :ds_senha   ');
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
          .GetNexID(TScriptDDL.getInstance().getTableNameUsuario, 'cd_usuario');

        ParamByName('id_usuario').Value := FModel.ID.ToString;
        ParamByName('cd_usuario').Value := FModel.Codigo;
        ParamByName('nm_usuario').Value := FModel.Nome;
        ParamByName('ds_email').Value   := FModel.Email;
        ParamByName('ds_senha').Value   := FModel.Senha;
        ParamByName('sn_logado').Value  := IfThen(FModel.Logado, FLAG_SIM, FLAG_NAO);

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
        Add('  , ft_usuario ');
        Add('  , sn_logado  ');
        Add('from ' + TScriptDDL.getInstance().getTableNameUsuario);
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

procedure TUsuarioController.SetAtributes(const aDataSet: TDataSet; aModel: TUsuarioModel);
begin
  with aDataSet, aModel do
  begin
    ID     := StringToGUID(FieldByName('id_usuario').AsString);
    Codigo := FieldByName('cd_usuario').AsInteger;
    Nome   := FieldByName('nm_usuario').AsString;
    Email  := FieldByName('ds_email').AsString;
    Senha  := FieldByName('ds_senha').AsString;
    Logado := (FieldByName('sn_logado').AsString = FLAG_SIM);

    // #0#0#0#0'IEND®B`‚'
    try
      if (Trim(FieldByName('ft_usuario').AsString) <> EmptyStr) then
      begin
        Foto := TBitmap.Create;
        Foto.LoadFromStream( CreateBlobStream(FieldByName('ft_usuario'), TBlobStreamMode.bmRead) );
      end
      else
        Foto := nil;
    except
      Foto := nil;
    end;
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
        Add('Update ' + TScriptDDL.getInstance().getTableNameUsuario + ' set ');
        Add('    nm_usuario = :nm_usuario ');
        Add('  , ds_email   = :ds_email ');
        Add('  , ds_senha   = :ds_senha ');
        Add('  , ft_usuario = :ft_usuario ');
        Add('  , sn_logado  = :sn_logado ');
        Add('where id_usuario = :id_usuario');
        EndUpdate;

        ParamByName('id_usuario').Value := FModel.ID.ToString;
        ParamByName('nm_usuario').Value := FModel.Nome;
        ParamByName('ds_email').Value   := FModel.Email;
        ParamByName('ds_senha').Value   := FModel.Senha;
        ParamByName('sn_logado').Value  := IfThen(FModel.Logado, FLAG_SIM, FLAG_NAO);

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
