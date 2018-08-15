unit USplash;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls;

type
  TFrmSplash = class(TForm)
    LayoutSplash: TLayout;
    Panel1: TPanel;
    LabelAppTitle: TLabel;
    LabelVersion: TLabel;
    LabelCarregando: TLabel;
    ProgressBar: TProgressBar;
    ImageLogoApp: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure Load;
  public
    { Public declarations }
  end;

var
  FrmSplash: TFrmSplash;

implementation

{$R *.fmx}

uses UDados;
{$R *.iPhone4in.fmx IOS}
{$R *.iPhone55in.fmx IOS}

procedure TFrmSplash.FormActivate(Sender: TObject);
begin
  Load;
end;

procedure TFrmSplash.FormCreate(Sender: TObject);
begin
  ; //ProgressBar.Value := 0;
end;

procedure TFrmSplash.Load;
begin
  DtmDados.IsConectado;
end;

end.
