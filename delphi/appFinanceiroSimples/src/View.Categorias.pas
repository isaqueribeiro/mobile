unit View.Categorias;

interface

uses
  Classe.ObjetoItemListView,
  View.CategoriaEdicao,
  Controller.Categoria,

  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFrmCategorias = class(TForm)
    LayoutTool: TLayout;
    LabelTitulo: TLabel;
    ImageFechar: TImage;
    LayoutAdicionar: TLayout;
    RectangleResumo: TRectangle;
    ImageAdicionar: TImage;
    lblQuantidadeCategorias: TLabel;
    ListViewCategorias: TListView;
    ImgSemImage: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImageFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewCategoriasUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ImageAdicionarClick(Sender: TObject);
  strict private
    class var _instance : TFrmCategorias;
  private
    { Private declarations }
    FEdicao : TFrmCategoriaEdicao;
    FCategogiaController : TCategoriaController;
    procedure addItemCategoria(const aObjeto : TObjetoItemListView);
    procedure formatItemCategoria(const aItem: TListViewItem);

    procedure CarregarCategorias;
  public
    { Public declarations }
    class function GetInstance() : TFrmCategorias;
  end;

//var
//  FrmCategorias: TFrmCategorias;

implementation

{$R *.fmx}

uses
    DataModule.Recursos;

{ TFrmCategorias }

procedure TFrmCategorias.addItemCategoria(const aObjeto: TObjetoItemListView);
var
  aItem : TListViewItem;
begin
  aItem := ListViewCategorias.Items.Add;
  aItem.TagString := aObjeto.ID.ToString;
  aItem.TagObject := aObjeto;

  formatItemCategoria(aItem);
end;

procedure TFrmCategorias.CarregarCategorias;
begin
  // FCategogiaController
end;

procedure TFrmCategorias.formatItemCategoria(const aItem: TListViewItem);
var
  aObjeto : TObjetoItemListView;
  aTexto  : TListItemText;
  aImage  : TListItemImage;
begin
  if (aItem <> nil) then
  begin
    aObjeto := TObjetoItemListView(aItem.TagObject);
    if (aObjeto <> nil) then
    begin
      // Categoria
      aTexto := TListItemText(aItem.Objects.FindDrawable('TextCategoria'));
      aTexto.Text  := IfThen(aObjeto.Categoria.Trim.IsEmpty, '. . . ', aObjeto.Categoria);
      aTexto.Width := Self.Width - (44 + 6);

       // Ícone
      aImage := TListItemImage(aItem.Objects.FindDrawable('ImageCategoria'));
      aImage.Opacity := 0.5;
      if aObjeto.Categoria.Trim.IsEmpty then
        aImage.Bitmap := ImgSemImage.Bitmap
      else
      begin
        aImage.Bitmap := nil;
      end;

      aItem.Height := 60;
    end;
  end;
end;

procedure TFrmCategorias.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action    := TCloseAction.caFree;
  _instance := nil;
end;

procedure TFrmCategorias.FormCreate(Sender: TObject);
begin
  ImgSemImage.Visible  := False;
  FCategogiaController := TCategoriaController.GetInstance();

  CarregarCategorias;
end;

class function TFrmCategorias.GetInstance: TFrmCategorias;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmCategorias, _instance);

  Result := _instance;
end;

procedure TFrmCategorias.ImageAdicionarClick(Sender: TObject);
var
  o : TObjetoItemListView;
begin
  o := TObjetoItemListView.Create;
  o.Descricao := 'Transporte';

  addItemCategoria( o );

  o := TObjetoItemListView.Create;
  o.Descricao := 'Lazer';

  addItemCategoria( o );

  o := TObjetoItemListView.Create;
  o.Descricao := 'Viagem';

  addItemCategoria( o );

  FEdicao := TFrmCategoriaEdicao.GetInstance();
  FEdicao.Show;
end;

procedure TFrmCategorias.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmCategorias.ListViewCategoriasUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  formatItemCategoria(AItem);
end;

end.
