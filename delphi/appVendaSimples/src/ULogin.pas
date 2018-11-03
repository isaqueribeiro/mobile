unit ULogin;

interface

uses
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

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    aConfirmado : Boolean;
    procedure DefinirLink;
  public
    { Public declarations }
    property Confirmado : Boolean read aConfirmado;
  end;

//var
//  FrmLogin: TFrmLogin;
//
  procedure CadastrarNovaConta;
  function EfetuarLogin : Boolean;

implementation

{$R *.fmx}

uses
  UDM;

procedure CadastrarNovaConta;
var
  aForm : TFrmLogin;
begin
  Application.CreateForm(TFrmLogin, aForm);
  Application.RealCreateForms;
  try
    aForm.TabControl.ActiveTab := aForm.TabCadastro;
    aForm.ShowModal;
  finally
    aForm.DisposeOf;
  end;
end;

function EfetuarLogin : Boolean;
var
  aForm : TFrmLogin;
begin
  Application.CreateForm(TFrmLogin, aForm);
  Application.RealCreateForms;
  try
    aForm.TabControl.ActiveTab := aForm.TabLogin;
    aForm.ShowModal;
  finally
    Result := aForm.Confirmado;
    aForm.DisposeOf;
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

  aConfirmado := True;
  Self.Close;
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
  aConfirmado := False;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
begin
  DefinirLink;
end;

end.
