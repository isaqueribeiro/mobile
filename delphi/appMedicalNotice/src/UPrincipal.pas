unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.TabControl, System.Actions, FMX.ActnList, FMX.Objects,
  FMX.MultiView, FMX.Controls.Presentation;

type
  TFrmPrincipal = class(TForm)
    layoutBase: TLayout;
    TabControlPrincipal: TTabControl;
    TabPrincipal: TTabItem;
    TabDetalhe: TTabItem;
    ToolBarForm: TToolBar;
    BtnVoltar: TSpeedButton;
    ActionListPrincipal: TActionList;
    acChangeTabAction: TChangeTabAction;
    LabelTitleDetalhe: TLabel;
    acPreviousTabAction: TPreviousTabAction;
    MultiViewMenu: TMultiView;
    LayoutFoto: TLayout;
    ToolBarPrincipal: TToolBar;
    BtnMenu: TSpeedButton;
    BtnRefresh: TSpeedButton;
    LabelTitlePrincipal: TLabel;
    LayoutUser: TLayout;
    LabelUserName: TLabel;
    LabelUserEmail: TLabel;
    ImageUser: TImage;
    LayoutImage: TLayout;
    RectangleUser: TRectangle;
    LayoutSair: TLayout;
    RoundRectSair: TRoundRect;
    ImageSair: TImage;
    Line1: TLine;
    LabelSair: TLabel;
    RoundRectCadastro: TRoundRect;
    ImageCadastro: TImage;
    LabelCadastro: TLabel;
    LayoutForm: TLayout;
    procedure UsuarioSair(Sender: TObject);
    procedure UsuarioCadastro(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure LimparForms;
  public
    { Public declarations }
    procedure MenuPrincipal;
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
    UDados
  {$IF DEFINED (ANDROID)}
  , FMX.Helpers.Android
  {$ENDIF}
  {$IF DEFINED (IOS)}
  , FMX.Helpers.Mac
  {$ENDIF}
  , app.Funcoes
  , classes.Constantes
  , dao.Usuario
  , System.Threading
  , System.JSON, USplash, UCadastroUsuario;

{$R *.fmx}
{$R *.iPhone55in.fmx IOS}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
var
  aUsuario : TUsuarioDao;
begin
  aUsuario := TUsuarioDao.GetInstance;
  aUsuario.MainMenu := True;

  TabControlPrincipal.ActiveTab := TabPrincipal;
  MultiViewMenu.Visible         := False;
  LabelUserName.Text  := AnsiUpperCase(aUsuario.Model.Nome);
  LabelUserEmail.Text := AnsiLowerCase(aUsuario.Model.Email);
end;

procedure TFrmPrincipal.LimparForms;
begin
  if Assigned(FrmCadastroUsuario) then
  begin
//    {$IF DEFINED (ANDROID) || (IOS)}
//    FrmCadastroUsuario.DisposeOf;
//    {$ELSE}
//    FrmCadastroUsuario.Close;
//    {$ENDIF}
    FrmCadastroUsuario.DisposeOf;
    FrmCadastroUsuario := nil;
  end;
end;

procedure TFrmPrincipal.MenuPrincipal;
begin
  LimparForms;
  TabControlPrincipal.ActiveTab := TabPrincipal;
end;

procedure TFrmPrincipal.UsuarioCadastro(Sender: TObject);
var
  aLayoutPadrao : TComponent;
begin
  MultiViewMenu.HideMaster;

  if not Assigned(FrmCadastroUsuario) then
    Application.CreateForm(TFrmCadastroUsuario, FrmCadastroUsuario);

  aLayoutPadrao := FrmCadastroUsuario.FindComponent('layoutBase');
  if Assigned(aLayoutPadrao) then
    LayoutForm.AddObject(TLayout(aLayoutPadrao));

  FrmCadastroUsuario.ToolBarCadastro.Visible := False;

  acChangeTabAction.ExecuteTarget(Sender);
  //TabControlPrincipal.ActiveTab := TabDetalhe;
end;

procedure TFrmPrincipal.UsuarioSair(Sender: TObject);
var
  aUsuario : TUsuarioDao;
begin
  aUsuario := TUsuarioDao.GetInstance;
  aUsuario.Model.Ativo := False;
  aUsuario.Update();

  {$IF DEFINED (ANDROID)}
  ;
  {$ELSE}
    {$IF DEFINED (IOS)}
    ;
    {$ENDIF}
  {$ENDIF}

  MultiViewMenu.HideMaster;
  {$IF DEFINED (ANDROID) || (IOS)}
  FrmSplash.DisposeOf;
  {$ELSE}
  Application.Terminate;
  {$ENDIF}
end;

end.
