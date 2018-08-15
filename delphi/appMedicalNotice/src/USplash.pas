unit USplash;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls;

type
  TFrmSplash = class(TForm)
    LayoutSplash: TLayout;
    PanelSplash: TPanel;
    ImageIconApp: TImage;
    LabelVersao: TLabel;
    LabelProgresso: TLabel;
    ProgressBar: TProgressBar;
    LabelAppTitle: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSplash: TFrmSplash;

implementation

{$R *.fmx}
{$R *.iPhone4in.fmx IOS}
{$R *.iPhone55in.fmx IOS}

procedure TFrmSplash.FormCreate(Sender: TObject);
begin
  ProgressBar.Value := 0;
end;

end.
