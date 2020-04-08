unit ULogin;

interface

uses
  dao.Usuario,
  dao.Loja,
  dao.Configuracao,
  Web.HttpApp,
  System.Json,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.TabControl,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, System.Actions, FMX.ActnList;

type
  TFrmLogin = class(TForm)
    imageRodape: TImage;
    TabControl: TTabControl;
    TabLogin: TTabItem;
    TabCadastro: TTabItem;
    labelLinkRodape: TLabel;
    layoutLogin: TLayout;
    imageLogin: TImage;
    layoutEmail: TLayout;
    rectangleEmail: TRectangle;
    StyleBookApp: TStyleBook;
    editEmail: TEdit;
    layoutSenha: TLayout;
    rectangleSenha: TRectangle;
    editSenha: TEdit;
    layoutAcessar: TLayout;
    rectangleAcessar: TRectangle;
    labelAcessar: TLabel;
    labelEsqueciSenha: TLabel;
    labelTituloLogin: TLabel;
    labelTituloNovaConta: TLabel;
    layoutCadastro: TLayout;
    imageCadastro: TImage;
    layoutEmailCad: TLayout;
    rectangleEmailCad: TRectangle;
    editEmailCad: TEdit;
    layoutSenhaCad: TLayout;
    rectangleSenhaCad: TRectangle;
    editSenhaCad: TEdit;
    layoutCriarConta: TLayout;
    rectangleCriarConta: TRectangle;
    labelCriarConta: TLabel;
    layoutNomeCad: TLayout;
    rectangleNomeCad: TRectangle;
    editNomeCad: TEdit;
    ActionList: TActionList;
    ChangeTabLogin: TChangeTabAction;
    ChangeTabCadastro: TChangeTabAction;
    procedure DoExecutarLink(Sender: TObject);
    procedure DoAcessar(Sender: TObject);
    procedure DoCriarConta(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FDao : TUsuarioDao;
    procedure DefinirLink;
    function Autenticar : Boolean;
    function CriarConta : Boolean;
    function RecuperarDadosEmpresa : Boolean;
  public
    { Public declarations }
    property Dao : TUsuarioDao read FDao write FDao;
  end;

var
  FrmLogin: TFrmLogin;

  procedure CadastrarNovaConta;
  procedure EfetuarLogin(const IsMain : Boolean = FALSE);

implementation

{$R *.fmx}

uses
  app.Funcoes,
  UDM,
  UMensagem,
  UInicial,
  UPrincipal;

procedure CadastrarNovaConta;
begin
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.RealCreateForms;
  try
    FrmLogin.Dao := TUsuarioDao.GetInstance;
    FrmLogin.TabControl.ActiveTab := FrmLogin.TabCadastro;
    FrmLogin.ShowModal;
  finally
    FrmLogin.DisposeOf;
  end;
end;

procedure EfetuarLogin(const IsMain : Boolean = FALSE);
begin
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.RealCreateForms;
  try
    FrmLogin.Dao := TUsuarioDao.GetInstance;
    FrmLogin.TabControl.ActiveTab := FrmLogin.TabLogin;
    FrmLogin.Show;
  finally
    if IsMain then
      Application.MainForm := FrmLogin;
  end;
end;

function TFrmLogin.Autenticar: Boolean;
var
  aID : TGUID;
  aUser : TUsuarioDao;
  aLoja : TLojaDao;
  aJson ,
  aEmpr : TJSONObject;
  aRetorno : String;
begin
  try
    aUser := TUsuarioDao.GetInstance;

    aUser.Model.Email := editEmail.Text;
    aUser.Model.Senha := editSenha.Text;

    aJson := DM.GetValidarLogin;

    if Assigned(aJson) then
    begin
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));
      Result   := (aRetorno.ToUpper = 'OK');

      if not Result then
        ExibirMsgAlerta(aRetorno)
      else
      begin
        aID := StringToGUID( StrClearValueJson(HTMLDecode(aJson.Get('id').JsonValue.ToString)) );
        if aUser.Find(aID, AnsiLowerCase(Trim(editEmail.Text)), False) then
        begin
          aUser.Model.Nome  := StrClearValueJson(HTMLDecode(aJson.Get('nome').JsonValue.ToString));
          aUser.Model.Ativo := True;
          aUser.Ativar();
        end
        else
        begin
          aUser.Model.ID    := StringToGUID( StrClearValueJson(HTMLDecode(aJson.Get('id').JsonValue.ToString)) );
          aUser.Model.Nome  := StrClearValueJson(HTMLDecode(aJson.Get('nome').JsonValue.ToString));
          aUser.Model.Email := AnsiLowerCase(Trim(editEmail.Text));
          aUser.Model.Senha := AnsiLowerCase(Trim(editSenha.Text));
          aUser.Model.Ativo := True;
          aUser.Insert();
        end;

        // Recuperar dados da empresa
        aEmpr := aJson.Get('empresa').JsonValue as TJSONObject;

        with aUser.Model do
        begin
          Empresa.ID       := StringToGUID(StrClearValueJson(HTMLDecode(aEmpr.Get('id').JsonValue.ToString)));
          Empresa.Codigo   := StrToCurr(StrClearValueJson(HTMLDecode(aEmpr.Get('codigo').JsonValue.ToString)));
          Empresa.Nome     := StrClearValueJson(HTMLDecode(aEmpr.Get('nome').JsonValue.ToString));
          Empresa.Fantasia := StrClearValueJson(HTMLDecode(aEmpr.Get('fantasia').JsonValue.ToString));
          Empresa.CpfCnpj  := StrClearValueJson(HTMLDecode(aEmpr.Get('cpf_cnpj').JsonValue.ToString));
        end;

        // Gravar dados da empresa retornada
        aLoja := TLojaDao.GetInstance();
        aLoja.Limpar();

        if (aUser.Model.Empresa.Codigo > 0) then
        begin
          aID := StringToGUID( StrClearValueJson(HTMLDecode(aEmpr.Get('id').JsonValue.ToString)) );

          if aLoja.Find(aId, aUser.Model.Empresa.CpfCnpj, False) then
          begin
            aLoja.Model := aUser.Model.Empresa;
            aLoja.Update();
          end
          else
          begin
            aLoja.Model := aUser.Model.Empresa;
            aLoja.Insert();
          end;

          TConfiguracaoDao.GetInstance().SetValue('empresa_padrao', aLoja.Model.ID.ToString);
        end;
      end;
    end
    else
      Result := False;
  except
    On E : Exception do
    begin
      ExibirMsgErro('Erro ao tentar autenticar usuário/senha.' + #13 + E.Message);
      Result := False;
    end;
  end;
end;

function TFrmLogin.CriarConta: Boolean;
var
  aID : TGUID;
  aUser : TUsuarioDao;
  aLoja : TLojaDao;
  aJson ,
  aEmpr : TJSONObject;
  aRetorno : String;
begin
  try
    aUser := TUsuarioDao.GetInstance;

    aUser.Model.ID    := GUID_NULL;
    aUser.Model.Nome  := editNomeCad.Text;
    aUser.Model.Email := editEmailCad.Text;
    aUser.Model.Senha := editSenhaCad.Text;
    aUser.Model.Cpf   := EmptyStr;
    aUser.Model.Celular := EmptyStr;
    aUser.Model.TokenID := EmptyStr;
    aUser.Model.Ativo   := False;

    aJson := DM.GetCriarNovaCOnta;

    if Assigned(aJson) then
    begin
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));
      Result   := (aRetorno.ToUpper = 'OK');

      if not Result then
        ExibirMsgAlerta(aRetorno);
    end
    else
      Result := False;
  except
    On E : Exception do
    begin
      ExibirMsgErro('Erro ao tentar criar nova conta.' + #13 + E.Message);
      Result := False;
    end;
  end;
end;

procedure TFrmLogin.DefinirLink;
begin
  if (TabControl.ActiveTab = TabLogin) then
    labelLinkRodape.Text := 'Não tem cadastro? Criar nova conta.'
  else
  if (TabControl.ActiveTab = TabCadastro) then
    labelLinkRodape.Text := 'Já tem um cadastro? Faça o login aqui.';
end;

procedure TFrmLogin.DoAcessar(Sender: TObject);
begin
  DM.ConectarDB;
  if Autenticar then
  begin
    RecuperarDadosEmpresa;

    if Assigned(FrmInicial) then
      FrmInicial.Hide;

    CriarForm(TFrmPrincipal, FrmPrincipal);

    // Ajustas manual para correção de bug
    if (Application.MainForm = Self) then
    begin
      Application.MainForm := FrmPrincipal;
      FrmPrincipal.Show;
    end;

    Self.Close;
  end;
end;

procedure TFrmLogin.DoCriarConta(Sender: TObject);
begin
  DM.ConectarDB;
  if CriarConta then
  begin
    editEmail.Text := editEmailCad.Text;
    editSenha.Text := editSenhaCad.Text;

    // Autenticar para trazer dados adicionais do Usuário do servidor web.
    Autenticar;

    if Assigned(FrmInicial) then
      FrmInicial.Hide;

    CriarForm(TFrmPrincipal, FrmPrincipal);
    Self.Close;
  end;
end;

procedure TFrmLogin.DoExecutarLink(Sender: TObject);
begin
  if (TabControl.ActiveTab = TabLogin) then
    ChangeTabCadastro.ExecuteTarget(Sender)
  else
  if (TabControl.ActiveTab = TabCadastro) then
    ChangeTabLogin.ExecuteTarget(Sender);

  DefinirLink;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  TabControl.ActiveTab   := TabLogin;
  TabControl.TabPosition := TTabPosition.None;
  FDao := TUsuarioDao.GetInstance;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
begin
  DefinirLink;
end;

function TFrmLogin.RecuperarDadosEmpresa: Boolean;
var
  I : Integer;
  aID : TGUID;
  aLoja  : TLojaDao;
  aLista : TJSONArray;
  aJson  ,
  aEmpr  : TJSONObject;
  aCnpj    ,
  aRetorno : String;
begin
  try
    aJson := DM.GetListarLojas;

    if Assigned(aJson) then
    begin
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));
      Result   := (aRetorno.ToUpper = 'OK');

      if Result then
      begin
        // Recuperar dados da empresa
        aLoja  := TLojaDao.GetInstance();
        aLista := aJson.Get('empresas').JsonValue as TJSONArray;

        for I := 0 to aLista.Count - 1 do
        begin
          aEmpr := aLista.Items[I] as TJSONObject;
          aID   := StringToGUID( StrClearValueJson(HTMLDecode(aEmpr.Get('id').JsonValue.ToString)) );
          aCnpj := StrClearValueJson(HTMLDecode(aEmpr.Get('cpf_cnpj').JsonValue.ToString));

          with aLoja.Model do
          begin
            ID       := StringToGUID(StrClearValueJson(HTMLDecode(aEmpr.Get('id').JsonValue.ToString)));
            Codigo   := StrToCurr(StrClearValueJson(HTMLDecode(aEmpr.Get('codigo').JsonValue.ToString)));
            Nome     := StrClearValueJson(HTMLDecode(aEmpr.Get('nome').JsonValue.ToString));
            Fantasia := StrClearValueJson(HTMLDecode(aEmpr.Get('fantasia').JsonValue.ToString));
            CpfCnpj  := StrClearValueJson(HTMLDecode(aEmpr.Get('cpf_cnpj').JsonValue.ToString));
          end;

          if aLoja.Find(aId, aCnpj, False) then
            aLoja.Update()
          else
            aLoja.Insert();

          if (TConfiguracaoDao.GetInstance().GetValue('empresa_padrao').Trim = EmptyStr) then
            TConfiguracaoDao.GetInstance().SetValue('empresa_padrao', aLoja.Model.ID.ToString);
        end;
      end;
    end
    else
      Result := False;
  except
    On E : Exception do
    begin
      ExibirMsgErro('Erro ao tentar recuperar dados da(s) empresa(s) do usuário.' + #13 + E.Message);
      Result := False;
    end;
  end;
end;

end.
