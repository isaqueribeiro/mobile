unit UCadastroUsuario;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Objects;

type
  TFrmCadastroUsuario = class(TForm)
    layoutBase: TLayout;
    LayoutTopo: TLayout;
    LabelNome: TLabel;
    EditNome: TEdit;
    LayoutForm: TLayout;
    LabelEmail: TLabel;
    EditEmail: TEdit;
    LabelObservacao: TLabel;
    EditObservacao: TEdit;
    ScrollBoxForm: TScrollBox;
    ToolBarCadastro: TToolBar;
    LabelTitleCadastro: TLabel;
    RectangleUser: TRectangle;
    LayoutFoto: TLayout;
    ImageLogoApp: TImage;
    LayoutUsuario: TLayout;
    LabelEntidade: TLabel;
    CaptionEntidade: TLabel;
    LabelLogin: TLabel;
    CaptionLogin: TLabel;
    RoundRectCadastro: TRoundRect;
    ImageSalvar: TImage;
    LabelSalvar: TLabel;
    LayoutSalvar: TLayout;
    procedure GravarUsuario(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean;
      const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean;
      const Bounds: TRect);
    procedure EditNomeKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditEmailKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditObservacaoKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
    FWBounds    : TRectF;
    FNeedOffSet : Boolean;
    procedure GravarUsuarioApp;
  public
    { Public declarations }
    procedure CalcContentBounds(Sender : TObject; var ContentBounds : TRectF);
    procedure RestorePosition;
    procedure UpdatePosition;
  end;

var
  FrmCadastroUsuario: TFrmCadastroUsuario;

implementation

uses
    UDados
  , USplash
  , app.Funcoes
  , classes.Constantes
  , dao.Usuario
  , System.Threading
  , System.JSON, UPrincipal;

{$R *.fmx}
{$R *.iPhone55in.fmx IOS}

procedure TFrmCadastroUsuario.CalcContentBounds(Sender: TObject; var ContentBounds: TRectF);
begin
  if (FNeedOffSet and (FWBounds.Top > 0)) then
  begin
    ContentBounds.Bottom := Max(ContentBounds.Bottom, 2 * ClientHeight - FWBounds.Top);
  end;
end;

procedure TFrmCadastroUsuario.EditEmailKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if (Key = vkReturn) then
    EditObservacao.SetFocus;
end;

procedure TFrmCadastroUsuario.EditNomeKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if (Key = vkReturn) then
    EditEmail.SetFocus;
end;

procedure TFrmCadastroUsuario.EditObservacaoKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if (Key = vkReturn) then
    GravarUsuario(RoundRectCadastro);
end;

procedure TFrmCadastroUsuario.FormCreate(Sender: TObject);
var
  aUsuario : TUsuarioDao;
begin
  aUsuario := TUsuarioDao.GetInstance;
  CaptionEntidade.Text := AnsiUpperCase(COMPANY_NAME);
  CaptionLogin.Text    := AnsiUpperCase(aUsuario.Model.Codigo);
  EditNome.Text        := aUsuario.Model.Nome;
  EditEmail.Text       := aUsuario.Model.Email;
  EditObservacao.Text  := aUsuario.Model.Observacao;

  ScrollBoxForm.OnCalcContentBounds := CalcContentBounds;
end;

procedure TFrmCadastroUsuario.FormFocusChanged(Sender: TObject);
begin
  UpdatePosition;
end;

procedure TFrmCadastroUsuario.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean;
  const Bounds: TRect);
begin
  FWBounds.Create(0, 0, 0, 0);
  FNeedOffSet := False;
  RestorePosition;
end;

procedure TFrmCadastroUsuario.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean;
  const Bounds: TRect);
begin
  FWBounds := TRectF.Create(Bounds);
  FWBounds.TopLeft     := ScreenToClient(FWBounds.TopLeft);
  FWBounds.BottomRight := ScreenToClient(FWBounds.BottomRight);
  UpdatePosition;
end;

procedure TFrmCadastroUsuario.GravarUsuario(Sender: TObject);
var
  aKey   ,
  aLogin ,
  aNome  ,
  aEmail ,
  aObs   ,
  aMsg   : String;
  aControle : TComponent;
  iError    : Integer;
  aUsuario  : TUsuarioDao;
  aTaskPost : ITask;
begin
  aMsg      := EmptyStr;
  aControle := nil;
  aKey      := MD5(FormatDateTime('dd/mm/yyyy', Date));

  aLogin := Trim(CaptionLogin.Text);
  aNome  := Trim(EditNome.Text);
  aEmail := Trim(EditEmail.Text);
  aObs   := Trim(EditObservacao.Text);

  if (Trim(EditNome.Text) = EmptyStr) then
  begin
    aControle := EditNome;
    aMsg := 'Informe seu nome.';
  end
  else
  if (Trim(EditEmail.Text) = EmptyStr) then
  begin
    aControle := EditEmail;
    aMsg := 'Informe seu e-mail.';
  end
  else
  if not IsEmailValido(EditEmail.Text) then
  begin
    aControle := EditEmail;
    aMsg := 'E-mail inválido.';
  end;

  if (aMsg <> EmptyStr) then
  begin
    {$IF (DEFINED (MACOS)) || (DEFINED (IOS))}
    MessageDlg(aMsg, TMsgDlgType.mtwarning, [TMsgDlgBtn.mbok], 0);
    {$ELSE}
    ShowMessage(aMsg);
    {$ENDIF}
    if (aControle <> nil) then
      TEdit(aControle).SetFocus;
  end
  else
  begin
    aUsuario  := TUsuarioDao.GetInstance;

    if (aUsuario.Model.Id = GUID_NULL) then
      aUsuario.Model.NewId;

    aTaskPost := TTask.Create(
      procedure
      var
        aMsg : String;
        aJsonArray  : TJSONArray;
        aJsonObject : TJSONObject;
        aErr : Boolean;
      begin
        aMsg := 'Autenticando...';
        try
          aErr := False;
          try
            aUsuario.Model.Codigo := aLogin;
            aUsuario.Model.Nome   := aNome;
            aUsuario.Model.Email  := aEmail;
            aUsuario.Model.Observacao := aObs;
            aUsuario.Model.Ativo      := False;

            aJsonArray := DtmDados.HttpPostUsuario(aKey) as TJSONArray;
          except
            On E : Exception do
            begin
              iError := 99;
              aErr   := True;
              aMsg   := 'Servidor da entidade não responde ...' + #13 + E.Message;
            end;
          end;

          if not aErr then
          begin
            aJsonObject := aJsonArray.Items[0] as TJSONObject;
            iError  := StrToInt(aJsonObject.GetValue('cd_error').Value);
            case iError of
              0 : aUsuario.Model.Ativo := True;
              else
                aMsg := aJsonObject.GetValue('ds_error').Value;
            end;
          end;
        finally
          if (iError > 0) then
          begin
            TThread.queue(nil,
              procedure
              begin
                {$IF (DEFINED (MACOS)) || (DEFINED (IOS))}
                MessageDlg(aMsg, TMsgDlgType.mtwarning, [TMsgDlgBtn.mbok], 0);
                {$ELSE}
                ShowMessage(aMsg);
                {$ENDIF}
              end);
          end
          else
          begin
            if (iError = 0) then
              GravarUsuarioApp;
          end;
        end;
      end
    );
    aTaskPost.Start;
  end;
end;

procedure TFrmCadastroUsuario.GravarUsuarioApp;
var
  aUsuario : TUsuarioDao;
begin
  aUsuario := TUsuarioDao.GetInstance;
  try
    if not aUsuario.Find(aUsuario.Model.Codigo, aUsuario.Model.Email, False) then
      aUsuario.Insert()
    else
      aUsuario.Update();
  finally
    if (aUsuario.MainMenu and Assigned(FrmPrincipal)) then
      FrmPrincipal.MenuPrincipal
    else
      FrmSplash.AbrirMenu;
  end;
end;

procedure TFrmCadastroUsuario.RestorePosition;
begin
  ScrollBoxForm.ViewportPosition := PointF(ScrollBoxForm.ViewportPosition.X, 0);
  LayoutForm.Align := TAlignLayout.Client;
  ScrollBoxForm.RealignContent;
end;

procedure TFrmCadastroUsuario.UpdatePosition;
var
  LFocused   : TControl;
  LFocusRect : TRectF;
begin
  FNeedOffSet := False;
  if Assigned(Focused) then
  begin
    LFocused   := TControl(Focused.GetObject);
    LFocusRect := LFocused.AbsoluteRect;
    LFocusRect.Offset(ScrollBoxForm.ViewportPosition);

    if (LFocusRect.IntersectsWith(TRectF.Create(FWBounds)) and (LFocusRect.Bottom > FWBounds.Top)) then
    begin
      FNeedOffSet := True;
      LayoutForm.Align := TAlignLayout.Horizontal;
      ScrollBoxForm.RealignContent;
      Application.ProcessMessages;
      ScrollBoxForm.ViewportPosition := PointF(ScrollBoxForm.ViewportPosition.X, LFocusRect.Bottom - FWBounds.Top);
    end;
  end;

  if not FNeedOffSet then
    RestorePosition;
end;

end.
