unit View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Objects;

type
  TViewPrincipal = class(TForm)
    lytToolBar: TLayout;
    Rectangle1: TRectangle;
    swtAtivar: TSwitch;
    lblAtivar: TLabel;
    ImgLogo: TImage;
    lytStatusBar: TLayout;
    Rectangle2: TRectangle;
    Layout: TLayout;
    LayoutSideBar: TLayout;
    LayoutContent: TLayout;
    Rectangle3: TRectangle;
    imgConfiguracoes: TImage;
    imgHome: TImage;
    imgUsuarios: TImage;
    imgEmpresas: TImage;
    procedure FormCreate(Sender: TObject);
    procedure swtAtivarSwitch(Sender: TObject);
  private
    { Private declarations }
    procedure InicializarComponentes;
  public
    { Public declarations }
  end;

var
  ViewPrincipal: TViewPrincipal;

implementation

{$R *.fmx}

procedure TViewPrincipal.FormCreate(Sender: TObject);
begin
  Self.Left   := Screen.Width - Self.Width + 10;
  Self.Top    := 0;
  Self.Height := Screen.Height - 34;

  InicializarComponentes;
end;

procedure TViewPrincipal.InicializarComponentes;
begin
  ;
end;

procedure TViewPrincipal.swtAtivarSwitch(Sender: TObject);
begin
  if swtAtivar.IsChecked then
    lblAtivar.Text := 'ATIVO'
  else
    lblAtivar.Text := 'DESATIVADO';
end;

end.
