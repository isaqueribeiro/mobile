unit USplash;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Threading, System.JSON,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.TabControl,
  System.Math, System.Actions, FMX.ActnList, FMX.Edit;

type
  TFrmSplash = class(TForm)
    TabControlSplash: TTabControl;
    TabSplash: TTabItem;
    TabForm: TTabItem;
    LayoutForm: TLayout;
    LayoutSplash: TLayout;
    PanelSplash: TPanel;
    ImageLogoEntidade: TImage;
    LabelAppTitle: TLabel;
    LabelVersion: TLabel;
    LabelCarregando: TLabel;
    ProgressBar: TProgressBar;
    ImageLogoApp: TImage;
    LayoutGeral: TLayout;
    ActionListSplash: TActionList;
    acMudarForm: TChangeTabAction;
    ScrollBoxForm: TScrollBox;
    procedure PrepareLogin(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
  private
    { Private declarations }
    FWBounds    : TRectF;
    FNeedOffSet     ,
    FActivateLoaded : Boolean;
    //aFormActive : TForm;
    aLayoutLogin    ,
    aLayoutCadastro : TComponent;

    procedure Load;
    procedure UpdateEspecialidades;
    procedure LoadActivity;

    procedure MudarForm(TabItem : TTabItem; Sender : TObject);
    procedure AbrirLogin;
  public
    { Public declarations }
    procedure CalcContentBounds(Sender : TObject; var ContentBounds : TRectF);
    procedure RestorePosition;
    procedure UpdatePosition;

    procedure AbrirMenu;
    procedure AbrirCadastroUsuario;
  end;

var
  FrmSplash: TFrmSplash;

implementation

{$R *.fmx}

uses
    UDados
//  {$IF DEFINED (ANDROID)}
//  , Androidapi.Helpers
//  , Androidapi.JNI.JavaTypes
//  , Androidapi.JNI.GraphicsContentViewText
//  {$ENDIF}
//  {$IF DEFINED (IOS)}
//  , ?
//  , ?
//  , ?
//  {$ENDIF}
  , app.Funcoes
  , classes.HttpConnect
  , classes.Constantes
  , dao.Especialidade
  , dao.Usuario
  , ULogin, UPrincipal, UCadastroUsuario;

{$R *.iPhone4in.fmx IOS}
{$R *.iPhone55in.fmx IOS}

procedure TFrmSplash.AbrirLogin;
//var
//  aLayoutPadrao : TComponent;
begin
//  if Assigned(FrmLogin) then
//  begin
//    if (FrmLogin.ClassType = TFrmLogin) then
//      Exit
//    else
//    begin
//      FrmLogin.DisposeOf;
//      FrmLogin := nil;
//    end;
//  end;
//
//  Application.CreateForm(TFrmLogin, FrmLogin);
//
//  FrmLogin.BtnEfetuarLogin.OnClick := PrepareLogin;
//
//  aLayoutPadrao := FrmLogin.FindComponent('layoutBase');
//  if Assigned(aLayoutPadrao) then
//    LayoutForm.AddObject(TLayout(aLayoutPadrao));
//
//  Caption := FrmLogin.Caption;
//  MudarForm(TabForm, Self);

//  Application.CreateForm(TFrmLogin, FrmLogin);
//  FrmLogin.Show();

  if not Assigned(FrmLogin) then
    Application.CreateForm(TFrmLogin, FrmLogin);

  aLayoutLogin := FrmLogin.FindComponent('layoutBase');
  if Assigned(aLayoutLogin) then
    LayoutForm.AddObject(TLayout(aLayoutLogin));

  TabControlSplash.ActiveTab := TabForm;
end;

procedure TFrmSplash.AbrirMenu;
var
  aLayoutPadrao : TComponent;
begin
//  if Assigned(aFormMain) then
//  begin
//    if (aFormMain.ClassType = TFrmLogin) then
//      Exit
//    else
//    begin
//      aFormMain.DisposeOf;
//      aFormMain := nil;
//    end;
//  end;
//
//  aFormMain := FrmPrincipal;
//  Application.CreateForm(TFrmLogin, aFormMain);
//
//  aLayoutPadrao := aFormMain.FindComponent('layoutBase');
//  if Assigned(aLayoutPadrao) then
//    LayoutForm.AddObject(TLayout(aLayoutPadrao));
//
//  Caption := aFormMain.Caption;
//  MudarForm(TabForm, Self);
  if Assigned(FrmLogin) then
  begin
    LayoutForm.RemoveObject(TLayout(aLayoutLogin));

    {$IF DEFINED (IOS)}
    FrmLogin.DisposeOf;
    {$ELSE}
    FrmLogin.Close;
    {$ENDIF}
    FrmLogin := nil;
  end;

  if Assigned(FrmCadastroUsuario) then
  begin
    LayoutForm.RemoveObject(TLayout(aLayoutCadastro));

    {$IF DEFINED (IOS)}
    FrmCadastroUsuario.DisposeOf;
    {$ELSE}
    FrmCadastroUsuario.Close;
    {$ENDIF}
    FrmCadastroUsuario := nil;
  end;

  if not Assigned(FrmPrincipal) then
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);

  aLayoutPadrao := FrmPrincipal.FindComponent('layoutBase');
  if Assigned(aLayoutPadrao) then
    LayoutForm.AddObject(TLayout(aLayoutPadrao));

  TabControlSplash.ActiveTab := TabForm;
end;

procedure TFrmSplash.CalcContentBounds(Sender: TObject;
  var ContentBounds: TRectF);
begin
  if (FNeedOffSet and (FWBounds.Top > 0)) then
    ContentBounds.Bottom := Max(ContentBounds.Bottom, 2 * ClientHeight - FWBounds.Top);
end;

procedure TFrmSplash.AbrirCadastroUsuario;
//var
//  aLayoutPadrao : TComponent;
begin

  if Assigned(FrmLogin) then
  begin
    TabControlSplash.ActiveTab := TabSplash;
    LayoutForm.RemoveObject(TLayout(aLayoutLogin));

    {$IF DEFINED (IOS)}
    FrmLogin.DisposeOf;
    {$ELSE}
    FrmLogin.Close;
    {$ENDIF}
    FrmLogin := nil;
  end;

  if not Assigned(FrmCadastroUsuario) then
    Application.CreateForm(TFrmCadastroUsuario, FrmCadastroUsuario);

  aLayoutCadastro := FrmCadastroUsuario.FindComponent('layoutBase');
  if Assigned(aLayoutCadastro) then
    LayoutForm.AddObject(TLayout(aLayoutCadastro));

  TabControlSplash.ActiveTab := TabForm;
end;

procedure TFrmSplash.PrepareLogin(Sender: TObject);
//var
//  aKey     ,
//  aLogin   ,
//  aSenha   : String;
//  aTaskLg  : ITask;
//  iError   : Integer;
//  aUsuario : TUsuarioDao;
begin
//  aKey := MD5(FormatDateTime('dd/mm/yyyy', Date));
//
//  if (FrmLogin <> nil)  then
//  begin
//    with FrmLogin do
//    begin
//      aLogin := AnsiLowerCase( Trim(EditLogin.Text) );
//      aSenha := MD5( Trim(EditSenha.Text) );
//      if (aLogin = EmptyStr) or (aSenha = EmptyStr) then
//      begin
//        LabelAlerta.Text    := 'Informar usuário e/ou senha!';
//        LabelAlerta.Visible := True;
//      end
//      else
//      begin
//        // Buscar autenticação no servidor web
//        aUsuario := TUsuarioDao.GetInstance;
//        aTaskLg  := TTask.Create(
//          procedure
//          var
//            aMsg    ,
//            aParams : String;
//            aJsonArray  : TJSONArray;
//            aJsonObject : TJSONObject;
//            I : Integer;
//            aErr : Boolean;
//          begin
//            aMsg := 'Autenticando...';
//            try
//              aErr := False;
//              try
//                aUsuario.Model.Codigo := aLogin;
//                aUsuario.Model.Senha  := aSenha;
//                aJsonArray := DtmDados.HttpGetUsuario(aKey) as TJSONArray;
//              except
//                On E : Exception do
//                begin
//                  aErr := True;
//                  aMsg := 'Servidor da entidade não responde ...' + #13 + E.Message;
//                end;
//              end;
//
//              if not aErr then
//              begin
//                aJsonObject := aJsonArray.Items[I] as TJSONObject;
//                iError  := StrToInt(aJsonObject.GetValue('cd_error').Value);
//                case iError of
//                  0 :
//                    begin
//                      aUsuario.Model.Codigo     := aJsonObject.GetValue('cd_usuario').Value;
//                      aUsuario.Model.Nome       := aJsonObject.GetValue('nm_usuario').Value;
//                      aUsuario.Model.Email      := aJsonObject.GetValue('ds_email').Value.Replace('...', '', [rfReplaceAll]);
//                      aUsuario.Model.Prestador  := StrToCurr(aJsonObject.GetValue('cd_prestador').Value);
//                      aUsuario.Model.Senha      := aSenha;
//                      aUsuario.Model.Observacao := aJsonObject.GetValue('ds_observacao').Value;
//                      aUsuario.Model.Ativo      := True;
//
//                      FrmLogin.DisposeOf;
//                      FrmLogin := nil;
//                    end;
//                  else
//                    aMsg := aJsonObject.GetValue('ds_error').Value;
//                end;
//              end;
//            finally
//              if (iError > 0) then
//              begin
//                LabelAlerta.Text    := aMsg;
//                LabelAlerta.Visible := True;
//              end
//              else
//                CarregarCadastroActivity;
//            end;
//          end
//        );
//        aTaskLg.Start;
//      end;
//    end;
//  end;
end;

procedure TFrmSplash.RestorePosition;
begin
  ScrollBoxForm.ViewportPosition := PointF(ScrollBoxForm.ViewportPosition.X, 0);
  LayoutForm.Align := TAlignLayout.Client;
  ScrollBoxForm.RealignContent;
end;

procedure TFrmSplash.FormActivate(Sender: TObject);
var
  aEspecilidades : TEspecialidadeDao;
begin
  if (FActivateLoaded = False) then
  begin
    aEspecilidades := TEspecialidadeDao.GetInstance;
    if DtmDados.IsConectado then
      if (aEspecilidades.GetCount() = 0) then
        Load
      else
        LoadActivity;
  end;
//  Load;
end;

procedure TFrmSplash.FormCreate(Sender: TObject);
//{$IF DEFINED (ANDROID)}
//var
//  PkgInfo : JPackageInfo;
//{$ENDIF}
begin
  ProgressBar.Max   := 0;
  ProgressBar.Value := 0;
  LabelVersion.Text := 'Versão ' + VERSION_NAME;
//  {$IF DEFINED (ANDROID)}
//  PkgInfo := SharedActivity.getPackageManager.getPackageInfo(SharedActivity.getPackageName, 0);
//  LabelVersion.Text := 'Versão ' + JStringToString(PkgInfo.versionName);
//  {$ENDIF}
  TabControlSplash.ActiveTab := TabSplash;
  ScrollBoxForm.OnCalcContentBounds := CalcContentBounds;

  FActivateLoaded := False;
  aLayoutLogin    := nil;
  aLayoutCadastro := nil;
end;

procedure TFrmSplash.FormFocusChanged(Sender: TObject);
begin
  UpdatePosition;
end;

procedure TFrmSplash.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FWBounds.Create(0, 0, 0, 0);
  FNeedOffSet := False;
  RestorePosition;
end;

procedure TFrmSplash.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FWBounds := TRectF.Create(Bounds);
  FWBounds.TopLeft     := ScreenToClient(FWBounds.TopLeft);
  FWBounds.BottomRight := ScreenToClient(FWBounds.BottomRight);
  UpdatePosition;
end;

procedure TFrmSplash.Load;
var
  aTask : ITask;
  aKey  : String;
begin
  aKey := MD5(FormatDateTime('dd/mm/yyyy', Date));

  aTask := TTask.Create(
    procedure
    var
      aMsg : String;
      IEsp : TEspecialidadeDao;
      aJsonArray  : TJSONArray;
      aJsonObject : TJSONObject;
      I : Integer;
      aErr : Boolean;
    begin
      aMsg := 'Conectando...';
      try
        IEsp := TEspecialidadeDao.GetInstance;
        aErr := False;
        try
          aJsonArray := DtmDados.HttpGetEspecialidade(aKey) as TJSONArray;
        except
          On E : Exception do
          begin
            aErr := True;
            aMsg := 'Servidor da entidade não responde ...' + #13 + E.Message;
          end;
        end;

        LabelCarregando.Text := aMsg;
        if not aErr then
          for I := 0 to aJsonArray.Count - 1 do
          begin
            aJsonObject := aJsonArray.Items[I] as TJSONObject;

            IEsp.AddLista;
            IEsp.Lista[I].Codigo    := StrToInt(aJsonObject.GetValue('cd_especilidade').Value);
            IEsp.Lista[I].Descricao := Trim(aJsonObject.GetValue('ds_especilidade').Value);
          end;
      finally
        UpdateEspecialidades;
      end;
    end
  );
  aTask.Start;
end;

procedure TFrmSplash.UpdateEspecialidades;
var
  aTaskE : ITask;
begin
  aTaskE := TTask.Create(
    procedure
    var
      aMsg : String;
      aEsp : TEspecialidadeDao;
      I : Integer;
    begin
      aMsg := 'Atualizando dados...';
      try
        aEsp := TEspecialidadeDao.GetInstance;
        LabelCarregando.Text := aMsg;
        ProgressBar.Max      := High(aEsp.Lista);
        ProgressBar.Value    := 0;
        for I := Low(aEsp.Lista) to High(aEsp.Lista) do
        begin
          if Assigned(aEsp.Lista[I]) then
          begin
            aEsp.Model := aEsp.Lista[I];
            if not aEsp.Find(aEsp.Model.Codigo, False) then
              aEsp.Insert()
            else
              aEsp.Update();
          end;
          ProgressBar.Value := (I + 1);
        end;
      finally
        ProgressBar.Value := ProgressBar.Max;
        LoadActivity;
      end;
    end
  );
  aTaskE.Start;
end;

procedure TFrmSplash.UpdatePosition;
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

procedure TFrmSplash.LoadActivity;
var
  aUsuario : TUsuarioDao;
begin
  aUsuario := TUsuarioDao.GetInstance;
  aUsuario.Load;
  FActivateLoaded := True;
  if aUsuario.IsAtivo then
    AbrirMenu
  else
    AbrirLogin;
end;

procedure TFrmSplash.MudarForm(TabItem: TTabItem; Sender: TObject);
begin
//  acMudarForm.Tab := TabItem;
//  acMudarForm.ExecuteTarget(Sender);
end;

end.
