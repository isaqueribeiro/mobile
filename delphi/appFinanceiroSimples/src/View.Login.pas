unit View.Login;

interface

uses
  u99Permissions,
  Controller.Usuario,

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
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FPermissao : T99Permissions;
    FController : TUsuarioController;

    procedure ErroPermissao(Sender : TObject);
    procedure CarregarUsuario;
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
  , View.Principal
  , Services.MessageDialog;

procedure TFrmLogin.CarregarUsuario;
var
  aError : String;
begin
  if Assigned(FController) then
  begin
    FController.Load(aError);

    if not aError.IsEmpty then
      TServicesMessageDialog.Error('Carregar', aError)
    else
    begin
      edtNomeCadastro.TagString := FController.Attributes.ID.ToString;

      edtNomeCadastro.Text  := FController.Attributes.Nome;
      edtEmailCadastro.Text := FController.Attributes.Email;
      edtSenhaCadastro.Text := EmptyStr;

      if Assigned(FController.Attributes.Foto) then
      begin
        CircleFoto.Tag := 1;
        CircleFoto.Fill.Bitmap.Bitmap.Assign( FController.Attributes.Foto );
      end
      else
        CircleFoto.Tag := 0;
    end;
  end;
end;

procedure TFrmLogin.CircleFotoClick(Sender: TObject);
begin
  ChangeTabActionEscolherFoto.Execute;
end;

procedure TFrmLogin.ErroPermissao(Sender: TObject);
begin
  TServicesMessageDialog.Alert('Alerta', 'Você não possui permissão de acesso para este recurso.');
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

  try
    FController := TUsuarioController.GetInstance();
  except
    On E : Exception do
    begin
      TServicesMessageDialog.Error('Base de dados', E.Message);
      FController := nil;
    end;
  end;
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
      // Botão BACK pressionado e teclado virtual visível
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

procedure TFrmLogin.FormShow(Sender: TObject);
begin
  CarregarUsuario;
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
