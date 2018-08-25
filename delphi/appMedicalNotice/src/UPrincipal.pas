unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.TabControl, System.Actions, FMX.ActnList, FMX.Objects,
  FMX.MultiView, FMX.Controls.Presentation, FMX.DialogService;

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
    BtnMeuPlantao: TSpeedButton;
    LayoutOpcoes: TLayout;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    Image2: TImage;
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
  , FMX.Helpers.iOS
  {$ENDIF}
//  {$IF DEFINED (MACOS)}
//  , FMX.Helpers.Mac
//  {$ENDIF}
  , app.Funcoes
  , classes.Constantes
  , dao.Usuario
  , System.Threading
  , System.JSON
  , USplashUI
  , UCadastroUsuario;

{$R *.fmx}
{$R *.iPhone55in.fmx IOS}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
var
  aUsuario : TUsuarioDao;
begin
  aUsuario := TUsuarioDao.GetInstance;
  aUsuario.MainMenu := True;

  MultiViewMenu.HideMaster;
  TabControlPrincipal.ActiveTab := TabPrincipal;
  LabelUserName.Text  := AnsiUpperCase(aUsuario.Model.Nome);
  LabelUserEmail.Text := AnsiLowerCase(aUsuario.Model.Email);
end;

procedure TFrmPrincipal.LimparForms;
begin
  if Assigned(FrmCadastroUsuario) then
  begin
    {$IF (DEFINED (MACOS)) || (DEFINED (IOS))}
    FrmCadastroUsuario.DisposeOf;
    {$ELSE}
    FrmCadastroUsuario.Close;
    {$ENDIF}
    FrmCadastroUsuario := nil;
  end;
end;

procedure TFrmPrincipal.MenuPrincipal;
begin
  LimparForms;
  //TabControlPrincipal.ActiveTab := TabPrincipal;
  acPreviousTabAction.ExecuteTarget(Self);
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

  LabelTitleDetalhe.Text := FrmCadastroUsuario.LabelTitleCadastro.Text;
  FrmCadastroUsuario.ToolBarCadastro.Visible := False;

  acChangeTabAction.ExecuteTarget(Sender);
  //TabControlPrincipal.ActiveTab := TabDetalhe;
end;

procedure TFrmPrincipal.UsuarioSair(Sender: TObject);
var
  aUsuario : TUsuarioDao;
begin
  MultiViewMenu.HideMaster;
  TDialogService.MessageDialog('Deseja sair do aplicativo?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYES:
          begin
            aUsuario := TUsuarioDao.GetInstance;
            aUsuario.Model.Ativo := False;
            aUsuario.Update();

            {$IF DEFINED (IOS)}
            Halt(0);
            {$ELSE}
              {$IF DEFINED (MACOS)}
              FrmSplashUI.DisposeOf;
              Application.Terminate;
              {$ELSE}
              Application.Terminate;
              {$ENDIF}
            {$ENDIF}
          end;
        mrNo:
          ;
        mrCancel:
          ;
      end;
    end);

end;

end.
