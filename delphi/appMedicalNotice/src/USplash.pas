unit USplash;

interface

uses
  System.SysUtils, System.Types, System.UITypes,
  System.Classes, System.Variants, System.Threading,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TFrmSplash = class(TForm)
    LayoutSplash: TLayout;
    PanelSplash: TPanel;
    LabelAppTitle: TLabel;
    LabelVersion: TLabel;
    LabelCarregando: TLabel;
    ProgressBar: TProgressBar;
    ImageLogoApp: TImage;
    ImageLogoEntidade: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure Load;
    procedure UpdateEspecialidades;
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
  , classes.HttpConnect
  , classes.Constantes
  , dao.Especialidade;

{$R *.iPhone4in.fmx IOS}
{$R *.iPhone55in.fmx IOS}

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
  ProgressBar.Value := 0;
  LabelVersion.Text := 'Versão ' + VERSION_NAME;
//  {$IF DEFINED (ANDROID)}
//  PkgInfo := SharedActivity.getPackageManager.getPackageInfo(SharedActivity.getPackageName, 0);
//  LabelVersion.Text := 'Versão ' + JStringToString(PkgInfo.versionName);
//  {$ENDIF}
end;

procedure TFrmSplash.Load;
var
  aTask : ITask;
  aKey  : String;
  aHttpConnect : THttpConnectJSON;
begin
  aKey := FormatDateTime('dd/mm/yyyy', Date);
  aHttpConnect := THttpConnectJSON.GetInstance(DtmDados, URL_SERVER_JSON + PAGE_ESPECIALIDADE, aKey);

  aTask := TTask.Create(
    procedure
    var
      aMsg : String;
      aEsp : TEspecialidadeDao;
    begin
      aMsg := 'Conectando...';
      try
        LabelCarregando.Text := aMsg;
        aEsp := TEspecialidadeDao.GetInstance;
      finally
        UpdateEspecialidades;
      end;
    end
  );
  aTask.Start;
end;

procedure TFrmSplash.UpdateEspecialidades;
begin
  ;
end;

end.
