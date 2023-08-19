unit appCatalogo.Views.Produto.Lista;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, appCatalogo.Views.Default, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit;

type
  TViewProdutoLista = class(TViewDefault)
    lblCatalogo: TLabel;
    lytSearch: TLayout;
    Rectangle1: TRectangle;
    imgSearch: TImage;
    edtSearch: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewProdutoLista: TViewProdutoLista;

implementation

{$R *.fmx}

end.
