unit ULogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation, FMX.Edit,
  System.Math, System.Actions, FMX.ActnList, FMX.StdActns;

type
  TFrmLogin = class(TForm)
    layoutBase: TLayout;
    LayoutLogin: TLayout;
    BtnEfetuarLogin: TButton;
    EditLogin: TEdit;
    EditSenha: TEdit;
    ImageLogoEntidade: TImage;
    LabelLogin: TLabel;
    LabelSenha: TLabel;
    LabelTitleLogin: TLabel;
    LabelVersion: TLabel;
    ToolBarLogin: TToolBar;
    LayoutTopo: TLayout;
    ImageLogoApp: TImage;
    ScrollBoxForm: TScrollBox;
    LayoutForm: TLayout;
    LabelAlerta: TLabel;
    procedure PrepareLogin(Sender: TObject);
    procedure OcultarAlerta(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditLoginKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure EditSenhaKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormFocusChanged(Sender: TObject);
  private
    { Private declarations }
    FWBounds    : TRectF;
    FNeedOffSet : Boolean;
  public
    { Public declarations }
    procedure CalcContentBounds(Sender : TObject; var ContentBounds : TRectF);
    procedure RestorePosition;
    procedure UpdatePosition;
  end;

var
  FrmLogin: TFrmLogin;

implementation

uses
    UDados
  , USplashUI
  , app.Funcoes
  , classes.HttpConnect
  , classes.Constantes
  , dao.Especialidade
  , dao.Usuario
  , System.Threading
  , System.JSON;


{$R *.fmx}
{$R *.iPhone55in.fmx IOS}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.NmXhdpiPh.fmx ANDROID}

procedure TFrmLogin.CalcContentBounds(Sender: TObject;
  var ContentBounds: TRectF);
begin
  if (FNeedOffSet and (FWBounds.Top > 0)) then
  begin
    ContentBounds.Bottom := Max(ContentBounds.Bottom, 2 * ClientHeight - FWBounds.Top);
  end;
end;

procedure TFrmLogin.EditLoginKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkReturn) then
    EditSenha.SetFocus;
end;

procedure TFrmLogin.EditSenhaKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkReturn) then
    PrepareLogin(BtnEfetuarLogin);
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  LabelVersion.Text := 'Versão ' + VERSION_NAME;
  ScrollBoxForm.OnCalcContentBounds := CalcContentBounds;

//  // Para teste
//  EditLogin.Text := 'edgar_sobrinho';
//  EditSenha.Text := '12345678';
end;

procedure TFrmLogin.FormFocusChanged(Sender: TObject);
begin
  UpdatePosition;
end;

procedure TFrmLogin.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FWBounds.Create(0, 0, 0, 0);
  FNeedOffSet := False;
  RestorePosition;
end;

procedure TFrmLogin.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FWBounds := TRectF.Create(Bounds);
  FWBounds.TopLeft     := ScreenToClient(FWBounds.TopLeft);
  FWBounds.BottomRight := ScreenToClient(FWBounds.BottomRight);
  UpdatePosition;
end;

procedure TFrmLogin.OcultarAlerta(Sender: TObject);
begin
  LabelAlerta.Visible := False;
end;

procedure TFrmLogin.PrepareLogin(Sender: TObject);
var
  aKey     ,
  aLogin   ,
  aSenha   : String;
  aTaskLg  : ITask;
  iError   : Integer;
  aUsuario : TUsuarioDao;
begin
  aKey := MD5(FormatDateTime('dd/mm/yyyy', Date));

  aLogin := AnsiLowerCase( Trim(EditLogin.Text) );
  aSenha := MD5( Trim(EditSenha.Text) );
  if (aLogin = EmptyStr) or (aSenha = EmptyStr) then
  begin
    LabelAlerta.Text    := 'Informar usuário e/ou senha!';
    LabelAlerta.Visible := True;
  end
  else
  begin
    // Buscar autenticação no servidor web
    aUsuario := TUsuarioDao.GetInstance;
    aTaskLg  := TTask.Create(
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
            aUsuario.Model.Senha  := aSenha;
            aJsonArray := DtmDados.HttpGetUsuario(aKey) as TJSONArray;
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
              0 :
                begin
                  aUsuario.Model.Codigo     := aJsonObject.GetValue('cd_usuario').Value;
                  aUsuario.Model.Nome       := aJsonObject.GetValue('nm_usuario').Value;
                  aUsuario.Model.Email      := aJsonObject.GetValue('ds_email').Value.Replace('...', '', [rfReplaceAll]);
                  aUsuario.Model.Prestador  := StrToCurr(aJsonObject.GetValue('cd_prestador').Value);
                  aUsuario.Model.Senha      := aSenha;
                  aUsuario.Model.Observacao := aJsonObject.GetValue('ds_observacao').Value;
                  aUsuario.Model.Ativo      := True;
                end;
              else
                aMsg := aJsonObject.GetValue('ds_error').Value;
            end;
          end;
        finally
          if (iError > 0) then
          begin
            LabelAlerta.Text    := aMsg;
            LabelAlerta.Visible := True;
          end
          else
            FrmSplashUI.AbrirCadastroUsuario;
        end;
      end
    );
    aTaskLg.Start;
  end;
end;

procedure TFrmLogin.RestorePosition;
begin
  ScrollBoxForm.ViewportPosition := PointF(ScrollBoxForm.ViewportPosition.X, 0);
  LayoutForm.Align := TAlignLayout.Client;
  ScrollBoxForm.RealignContent;
end;

procedure TFrmLogin.UpdatePosition;
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
