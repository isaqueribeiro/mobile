unit USplash;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Threading, System.JSON,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.TabControl,
  System.Actions, FMX.ActnList, FMX.Edit;

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
    procedure PrepareLogin(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    //aFormActive,
    aFormLogin ,
    aFormMain  : TForm;

    procedure Load;
    procedure UpdateEspecialidades;
    procedure LoadActivity;

    procedure MudarForm(TabItem : TTabItem; Sender : TObject);
    procedure AbrirLogin;
    procedure AbrirMenu;
  public
    { Public declarations }
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
  , ULogin, UPrincipal;

{$R *.iPhone4in.fmx IOS}
{$R *.iPhone55in.fmx IOS}

procedure TFrmSplash.AbrirLogin;
var
  aLayoutPadrao : TComponent;
begin
  //if Assigned(aFormActive) then
  if Assigned(aFormLogin) then
  begin
    //if (aFormActive.ClassType = TFrmLogin) then
    if (aFormLogin.ClassType = TFrmLogin) then
      Exit
    else
    begin
//      aFormActive.DisposeOf;
//      aFormActive := nil;
      aFormLogin.DisposeOf;
      aFormLogin := nil;
    end;
  end;

//  aFormActive := FrmLogin;
//  Application.CreateForm(TFrmLogin, aFormActive);
  aFormLogin := FrmLogin;
  Application.CreateForm(TFrmLogin, aFormLogin);

  //TFrmLogin(aFormActive).BtnEfetuarLogin.OnClick := PrepareLogin;
  TFrmLogin(aFormLogin).BtnEfetuarLogin.OnClick := PrepareLogin;

  //aLayoutPadrao := aFormActive.FindComponent('layoutBase');
  aLayoutPadrao := aFormLogin.FindComponent('layoutBase');
  if Assigned(aLayoutPadrao) then
    LayoutForm.AddObject(TLayout(aLayoutPadrao));

  //Caption := aFormActive.Caption;
  Caption := aFormLogin.Caption;
  MudarForm(TabForm, Self);
end;

procedure TFrmSplash.AbrirMenu;
var
  aLayoutPadrao : TComponent;
begin
  if Assigned(aFormMain) then
  begin
    if (aFormMain.ClassType = TFrmLogin) then
      Exit
    else
    begin
      aFormMain.DisposeOf;
      aFormMain := nil;
    end;
  end;

  aFormMain := FrmPrincipal;
  Application.CreateForm(TFrmLogin, aFormMain);

  aLayoutPadrao := aFormMain.FindComponent('layoutBase');
  if Assigned(aLayoutPadrao) then
    LayoutForm.AddObject(TLayout(aLayoutPadrao));

  Caption := aFormMain.Caption;
  MudarForm(TabForm, Self);
end;

procedure TFrmSplash.PrepareLogin(Sender: TObject);
var
  //aForm  ,
  aLogin  ,
  aSenha  ,
  aAlerta : TComponent;
  sLogin  ,
  sSenha  : String;
begin
  if (aFormLogin <> nil)  then
  begin
    aLogin  := aFormLogin.FindComponent('EditLogin');
    aSenha  := aFormLogin.FindComponent('EditSenha');
    aAlerta := aFormLogin.FindComponent('LabelAlerta');
    if (aLogin <> nil) and (aSenha <> nil) then
    begin
      sLogin := Trim(TEdit(aLogin).Text);
      sSenha := Trim(TEdit(aSenha).Text);
      if (sLogin = EmptyStr) or (sSenha = EmptyStr) then
      begin
        TEdit(aLogin).SetFocus;
        if Assigned(aAlerta) then
        begin
          TLabel(aAlerta).Text    := 'Informar usuário e/ou senha!';
          TLabel(aAlerta).Visible := True;
        end;
      end
      else
        ;
    end
    else
      raise Exception.Create('PrepareLogin() - Aplicativo desatualizado, favor entrar em contado com o DTI do ' + COMPANY_NAME + '.');
  end;
end;

procedure TFrmSplash.FormActivate(Sender: TObject);
begin
  if DtmDados.IsConectado then
    Load;
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
end;

procedure TFrmSplash.Load;
var
  aTask : ITask;
  aKey  : String;
  aHttpConnect : THttpConnectJSON;
begin
//  Sleep(100);
//  LoadActivity;
  aKey := MD5(FormatDateTime('dd/mm/yyyy', Date));
  aHttpConnect := THttpConnectJSON.GetInstance(DtmDados, URL_SERVER_JSON, aKey);

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
          aJsonArray := aHttpConnect.Get(PAGE_ESPECIALIDADE, aKey, EmptyStr) as TJSONArray;
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

procedure TFrmSplash.LoadActivity;
var
  aUsuario : TUsuarioDao;
begin
  aUsuario := TUsuarioDao.GetInstance;
  aUsuario.Load;
  if aUsuario.IsAtivo then
    AbrirMenu
  else
    AbrirLogin;
end;

procedure TFrmSplash.MudarForm(TabItem: TTabItem; Sender: TObject);
begin
  acMudarForm.Tab := TabItem;
  acMudarForm.ExecuteTarget(Sender);
end;

end.
