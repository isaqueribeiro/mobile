unit UCadastroUsuario;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Objects;

type
  TFrmCadastroUsuario = class(TForm)
    layoutBase: TLayout;
    LayoutTopo: TLayout;
    LayoutFoto: TLayout;
    LayoutUsuario: TLayout;
    LabelEntidade: TLabel;
    CaptionEntidade: TLabel;
    LabelLogin: TLabel;
    CaptionLogin: TLabel;
    LabelNome: TLabel;
    EditNome: TEdit;
    LayoutForm: TLayout;
    LabelEmail: TLabel;
    EditEmail: TEdit;
    ImageLogoApp: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadastroUsuario: TFrmCadastroUsuario;

implementation

{$R *.fmx}

end.
