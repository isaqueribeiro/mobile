unit appCatalogo.Views.Default;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls;

type
  TViewDefault = class(TForm)
    LayoutView: TLayout;
    lytToolBar: TLayout;
    lytBtnBack: TLayout;
    lytBtnPlus: TLayout;
    recBackgroundToolBar: TRectangle;
    lbtTitle: TLabel;
    imBtnBack: TImage;
    imgBtnPlus: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewDefault: TViewDefault;

implementation

{$R *.fmx}

end.
