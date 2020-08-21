unit View.Login;

interface

uses
  u99Permissions,

  {$IFDEF ANDROID}
  FMX.VirtualKeyBoard, FMX.Platform,
  {$ENDIF}

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.Edit, FMX.TabControl, FMX.StdCtrls, System.Actions, FMX.ActnList, FMX.Ani, FMX.MediaLibrary.Actions, FMX.StdActns;

type
  TFrmLogin = class(TForm)
    tabControles: TTabControl;
    tbsLogin: TTabItem;
    tbsCadastro: TTabItem;
    tbsFoto: TTabItem;
    tbsEscolherFoto: TTabItem;
    LayoutLogin: TLayout;
    LayoutEmail: TLayout;
    RoundRectEmail: TRoundRect;
    edlEmail: TEdit;
    LayoutSenha: TLayout;
    RoundRectSenha: TRoundRect;
    edtSenha: TEdit;
    LayoutAcessar: TLayout;
    LabelAcessar: TLabel;
    ImageAcessar: TImage;
    iconLogin: TImage;
    LayoutCadastro: TLayout;
    LayoutNomeCadastro: TLayout;
    RoundRectNomeCadastro: TRoundRect;
    edtNomeCadastro: TEdit;
    LayoutSenhaCadastro: TLayout;
    RoundRectSenhaCadastro: TRoundRect;
    edtSenhaCadastro: TEdit;
    LayoutProximo: TLayout;
    ImageProximo: TImage;
    LabelProximo: TLabel;
    iconCadastro: TImage;
    LayoutEmailCadastro: TLayout;
    RoundRectEmailCadastro: TRoundRect;
    edtEmailCadastro: TEdit;
    LayoutFoto: TLayout;
    LayoutLabelCriarMinhaConta: TLayout;
    ImageLabelCriarMinhaConta: TImage;
    LabelCriarMinhaConta: TLabel;
    LayoutFotoTool: TLayout;
    CircleFoto: TCircle;
    ImageVoltarAoCadastro: TImage;
    LayoutEscolherFotoTool: TLayout;
    ImageVoltarAFoto: TImage;
    LayoutEscolherFoto: TLayout;
    LabelEscolherFoto: TLabel;
    ImageTirarFoto: TImage;
    LabelTirarFoto: TLabel;
    ImageBibliotecaFOto: TImage;
    LabelBibliotecaFOto: TLabel;
    MyActionList: TActionList;
    LayoutAbasLogin: TLayout;
    lblAtivarLogin: TLabel;
    lblAtivarCriarConta: TLabel;
    RectangleAbasLogin: TRectangle;
    ChangeTabActionLogin: TChangeTabAction;
    ChangeTabActionCadastro: TChangeTabAction;
    FloatAnimationBarra: TFloatAnimation;
    ChangeTabActionFoto: TChangeTabAction;
    ChangeTabActionEscolherFoto: TChangeTabAction;
    TakePhotoFromLibrary: TTakePhotoFromLibraryAction;
    TakePhotoFromCamera: TTakePhotoFromCameraAction;
    procedure lblAtivarLoginClick(Sender: TObject);
    procedure lblAtivarCriarContaClick(Sender: TObject);
    procedure FloatAnimationBarraFinish(Sender: TObject);
    procedure LabelProximoClick(Sender: TObject);
    procedure ImageVoltarAoCadastroClick(Sender: TObject);
    procedure ImageVoltarAFotoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CircleFotoClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImageTirarFotoClick(Sender: TObject);
    procedure ImageBibliotecaFOtoClick(Sender: TObject);
    procedure TakeImageFinishTaking(Image: TBitmap);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LabelAcessarClick(Sender: TObject);
  private
    { Private declarations }
    FPermissao : T99Permissions;

    procedure ErroPermissao(Sender : TObject);
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

uses
    DataModule.Recursos
  , DataModule.Conexao
  , View.Principal;

procedure TFrmLogin.CircleFotoClick(Sender: TObject);
begin
  ChangeTabActionEscolherFoto.Execute;
end;

procedure TFrmLogin.ErroPermissao(Sender: TObject);
begin
  ShowMessage('Voc� n�o possui permiss�o de acesso para este recurso.');
end;

procedure TFrmLogin.FloatAnimationBarraFinish(Sender: TObject);
begin
  if (RectangleAbasLogin.Tag = 1) then
  begin
    ChangeTabActionCadastro.Execute;
    LayoutAbasLogin.Parent := LayoutCadastro;
  end
  else
  begin
    ChangeTabActionLogin.Execute;
    LayoutAbasLogin.Parent := LayoutLogin;
  end;
end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action   := TCloseAction.caFree;
  FrmLogin := nil;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  FPermissao := T99Permissions.Create;
  tabControles.ActiveTab := tbsLogin;
end;

procedure TFrmLogin.FormDestroy(Sender: TObject);
begin
  FPermissao.DisposeOf;
end;

procedure TFrmLogin.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
{$IFDEF ANDROID}
var
  FService : IFMXVirtualKeyBoardService;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  if (Key = vkHardwareBack) then
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyBoardService, IInterface(FService));

    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyboardState) then
    begin
      // Bot�o BACK pressionado e teclado virtual vis�vel
      // { apenas fecha o teclado }
    end
    else
    begin
      if (tabControles.ActiveTab <> tbsLogin) then
        Key := 0;

      if (tabControles.ActiveTab = tbsCadastro) then
        ChangeTabActionLogin.Execute
      else
      if (tabControles.ActiveTab = tbsFoto) then
        ChangeTabActionCadastro.Execute
      else
      if (tabControles.ActiveTab = tbsEscolherFoto) then
        ChangeTabActionFoto.Execute;
    end;
  end;
  {$ENDIF}
end;

procedure TFrmLogin.ImageBibliotecaFOtoClick(Sender: TObject);
begin
  FPermissao.PhotoLibrary(TakePhotoFromLibrary, ErroPermissao);
end;

procedure TFrmLogin.ImageTirarFotoClick(Sender: TObject);
begin
  FPermissao.Camera(TakePhotoFromCamera, ErroPermissao);
end;

procedure TFrmLogin.ImageVoltarAFotoClick(Sender: TObject);
begin
  ChangeTabActionFoto.Execute;
end;

procedure TFrmLogin.ImageVoltarAoCadastroClick(Sender: TObject);
begin
  ChangeTabActionCadastro.Execute;
end;

procedure TFrmLogin.LabelAcessarClick(Sender: TObject);
begin
  TDMConexao.GetInstance();

  CarregarPrincipal;
  Self.Close;
end;

procedure TFrmLogin.LabelProximoClick(Sender: TObject);
begin
  ChangeTabActionFoto.Execute;
end;

procedure TFrmLogin.lblAtivarCriarContaClick(Sender: TObject);
begin
  if not FloatAnimationBarra.Inverse then
    Exit;

  RectangleAbasLogin.Tag      := 1;
  FloatAnimationBarra.Inverse := False;
  FloatAnimationBarra.Start;
end;

procedure TFrmLogin.lblAtivarLoginClick(Sender: TObject);
begin
  if FloatAnimationBarra.Inverse then
    Exit;

  RectangleAbasLogin.Tag      := 0;
  FloatAnimationBarra.Inverse := True;
  FloatAnimationBarra.Start;
end;

procedure TFrmLogin.TakeImageFinishTaking(Image: TBitmap);
begin
  CircleFoto.Fill.Bitmap.Bitmap := Image;
  ChangeTabActionFoto.Execute;
end;

end.
