unit UPadrao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects;

type
  TFrmPadrao = class(TForm)
    StyleBook: TStyleBook;
    LayoutForm: TLayout;
    rectangleTitulo: TRectangle;
    labelTitulo: TLabel;
    imageAdicionar: TImage;
    imageVoltar: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPadrao: TFrmPadrao;

implementation

{$R *.fmx}

end.
