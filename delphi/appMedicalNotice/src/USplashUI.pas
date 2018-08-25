unit USplashUI;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Math, System.Threading, System.JSON,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.TabControl, System.Actions, FMX.ActnList;

type
  TFrmSplashUI = class(TForm)
    layoutBase: TLayout;
    ScrollBoxForm: TScrollBox;
    LayoutCadastro: TLayout;
    TabControlSplash: TTabControl;
    TabSplash: TTabItem;
    TabLogin: TTabItem;
    LayoutSplash: TLayout;
    LayoutPainel: TLayout;
    ImageLogoApp: TImage;
    ImageLogoEntidade: TImage;
    LabelAppTitle: TLabel;
    LabelCarregando: TLabel;
    LabelVersion: TLabel;
    ProgressBar: TProgressBar;
    ActionListSplash: TActionList;
    acMudarForm: TChangeTabAction;
    TabPrincipal: TTabItem;
    TabCadastro: TTabItem;
    LayoutLogin: TLayout;
    LayoutPrincipal: TLayout;
    acIrFormLogin: TChangeTabAction;
    acIrFormCadastro: TChangeTabAction;
    acIrFormPrincipal: TChangeTabAction;
    LayoutForm: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean;
      const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean;
      const Bounds: TRect);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FWBounds        : TRectF;
    FNeedOffSet     ,
    FActivateLoaded : Boolean;

    aLayoutLogin    ,
    aLayoutCadastro : TComponent;

    procedure Carregar;
    procedure CarregarFormulario;
    procedure AtualizarEspecialidades;

    procedure MudarForm(TabItem : TTabItem; Sender : TObject);
    procedure AbrirLogin;
  public
    { Public declarations }
    procedure CalcContentBounds(Sender : TObject; var ContentBounds : TRectF);
    procedure RestorePosition;
    procedure UpdatePosition;

    procedure AbrirCadastroUsuario;
    procedure AbrirMenu;
  end;

var
  FrmSplashUI: TFrmSplashUI;

implementation

{$R *.fmx}

uses
    UDados
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers
  , Androidapi.JNI.JavaTypes
  , Androidapi.JNI.GraphicsContentViewText
  {$ENDIF}
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
  , ULogin
  , UPrincipal
  , UCadastroUsuario;

{ TFrmPadrao }

procedure TFrmSplashUI.AbrirCadastroUsuario;
begin
//  TabControlSplash.ActiveTab := TabVazio;
//
//  if Assigned(FrmLogin) then
//  begin
//    LayoutForm.RemoveObject(TLayout(aLayoutLogin));
//
//    {$IF DEFINED (IOS)}
//    FrmLogin.DisposeOf;
//    {$ELSE}
//    FrmLogin.Close;
//    {$ENDIF}
//    FrmLogin := nil;
//  end;
//
  if not Assigned(FrmCadastroUsuario) then
    Application.CreateForm(TFrmCadastroUsuario, FrmCadastroUsuario);

  aLayoutCadastro := FrmCadastroUsuario.FindComponent('layoutBase');
  if Assigned(aLayoutCadastro) then
    LayoutCadastro.AddObject(TLayout(aLayoutCadastro));

  //TabControlSplash.ActiveTab := TabCadastro;
  acIrFormCadastro.ExecuteTarget(Self);
end;

procedure TFrmSplashUI.AbrirLogin;
begin
  if not Assigned(FrmLogin) then
    Application.CreateForm(TFrmLogin, FrmLogin);

  aLayoutLogin := FrmLogin.FindComponent('layoutBase');
  if Assigned(aLayoutLogin) then
    LayoutLogin.AddObject(TLayout(aLayoutLogin));

  //TabControlSplash.ActiveTab := TabLogin;
  acIrFormLogin.ExecuteTarget(Self);
end;

procedure TFrmSplashUI.AbrirMenu;
var
  aLayoutPadrao : TComponent;
begin
//  TabControlSplash.ActiveTab := TabVazio;
//
//  if Assigned(FrmLogin) then
//  begin
//    LayoutForm.RemoveObject(TLayout(aLayoutLogin));
//    {$IF DEFINED (IOS)}
//    FrmLogin.DisposeOf;
//    {$ELSE}
//    FrmLogin.Close;
//    {$ENDIF}
//    FrmLogin := nil;
//  end;
//
//  if Assigned(FrmCadastroUsuario) then
//  begin
//    LayoutForm.RemoveObject(TLayout(aLayoutCadastro));
//    {$IF DEFINED (IOS)}
//    FrmCadastroUsuario.DisposeOf;
//    {$ELSE}
//    FrmCadastroUsuario.Close;
//    {$ENDIF}
//    FrmCadastroUsuario := nil;
//  end;
//
  if not Assigned(FrmPrincipal) then
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);

  aLayoutPadrao := FrmPrincipal.FindComponent('layoutBase');
  if Assigned(aLayoutPadrao) then
    LayoutPrincipal.AddObject(TLayout(aLayoutPadrao));

  //TabControlSplash.ActiveTab := TabPrincipal;
  acIrFormPrincipal.ExecuteTarget(Self);
end;

procedure TFrmSplashUI.AtualizarEspecialidades;
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
        CarregarFormulario;
      end;
    end
  );
  aTaskE.Start;
end;

procedure TFrmSplashUI.CalcContentBounds(Sender: TObject; var ContentBounds: TRectF);
begin
  if (FNeedOffSet and (FWBounds.Top > 0)) then
    ContentBounds.Bottom := Max(ContentBounds.Bottom, 2 * ClientHeight - FWBounds.Top);
end;

procedure TFrmSplashUI.Carregar;
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
        if not aErr then
          AtualizarEspecialidades;
      end;
    end
  );
  aTask.Start;
end;

procedure TFrmSplashUI.CarregarFormulario;
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

procedure TFrmSplashUI.FormActivate(Sender: TObject);
var
  aEspecilidades : TEspecialidadeDao;
begin
  if (FActivateLoaded = False) then
  begin
    aEspecilidades := TEspecialidadeDao.GetInstance;
    if DtmDados.IsConectado then
      if (aEspecilidades.GetCount() = 0) then
        Carregar
      else
        CarregarFormulario;
  end;
end;

procedure TFrmSplashUI.FormCreate(Sender: TObject);
{$IF DEFINED (ANDROID)}
var
  PkgInfo : JPackageInfo;
{$ENDIF}
begin
  ProgressBar.Max   := 0;
  ProgressBar.Value := 0;
  LabelVersion.Text := 'Versão ' + VERSION_NAME;
  {$IF DEFINED (ANDROID)}
  PkgInfo := SharedActivity.getPackageManager.getPackageInfo(SharedActivity.getPackageName, 0);
  LabelVersion.Text := 'Versão ' + JStringToString(PkgInfo.versionName);
  {$ENDIF}
  TabControlSplash.ActiveTab := TabSplash;
  ScrollBoxForm.OnCalcContentBounds := CalcContentBounds;

  FActivateLoaded := False;
  aLayoutLogin    := nil;
  aLayoutCadastro := nil;
end;

procedure TFrmSplashUI.FormFocusChanged(Sender: TObject);
begin
  UpdatePosition;
end;

procedure TFrmSplashUI.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean;
  const Bounds: TRect);
begin
  FWBounds.Create(0, 0, 0, 0);
  FNeedOffSet := False;
  RestorePosition;
end;

procedure TFrmSplashUI.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean;
  const Bounds: TRect);
begin
  FWBounds := TRectF.Create(Bounds);
  FWBounds.TopLeft     := ScreenToClient(FWBounds.TopLeft);
  FWBounds.BottomRight := ScreenToClient(FWBounds.BottomRight);
  UpdatePosition;
end;

procedure TFrmSplashUI.MudarForm(TabItem: TTabItem; Sender: TObject);
begin
  acMudarForm.Tab := TabItem;
  acMudarForm.ExecuteTarget(Sender);
end;

procedure TFrmSplashUI.RestorePosition;
begin
  ScrollBoxForm.ViewportPosition := PointF(ScrollBoxForm.ViewportPosition.X, 0);
  LayoutForm.Align := TAlignLayout.Client;
  ScrollBoxForm.RealignContent;
end;

procedure TFrmSplashUI.UpdatePosition;
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
