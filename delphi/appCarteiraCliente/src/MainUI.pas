unit MainUI;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.TabControl, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects;

type
  TFrmMain = class(TForm)
    TabControl: TTabControl;
    TabSplash: TTabItem;
    TabLogin: TTabItem;
    TabPrincipal: TTabItem;
    LayoutSplash: TLayout;
    LayoutLogo: TLayout;
    LayoutSplashTexto: TLayout;
    LabelVersao: TLabel;
    LabelCarregando: TLabel;
    ProgressBarCarregando: TProgressBar;
    ImageLogo: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

end.
