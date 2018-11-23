unit UProduto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadrao, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFrmProduto = class(TFrmPadrao)
    layoutBuscaProduto: TLayout;
    rectangleBuscaProduto: TRectangle;
    editBuscaProduto: TEdit;
    imageBuscaProduto: TImage;
    ListViewProduto: TListView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmProduto: TFrmProduto;

implementation

{$R *.fmx}

end.
