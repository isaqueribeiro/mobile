unit View.CategoriaSelecao;

interface

uses
  Controller.Categoria,
  Classe.ObjetoItemListView,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;


type
  TFrmCategoriaSelecao = class(TForm)
    LayoutTool: TLayout;
    LabelTitulo: TLabel;
    ImageFechar: TImage;
    ListViewCategorias: TListView;
    ImgSemImage: TImage;
    procedure FormCreate(Sender: TObject);
    procedure ImageFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListViewCategoriasItemClick(const Sender: TObject; const AItem: TListViewItem);
  strict private
    class var _instance : TFrmCategoriaSelecao;
  private
    { Private declarations }
    FCategogiaController : TCategoriaController;

    procedure LimparListView;
    procedure CarregarCategorias;
    procedure addItemCategoria(const aObjeto : TObjetoItemListView);
    procedure formatItemCategoria(const aItem: TListViewItem);
  public
    { Public declarations }
    class function getInstance() : TFrmCategoriaSelecao;
  end;

var
  FrmCategoriaSelecao: TFrmCategoriaSelecao;

implementation

{$R *.fmx}

uses
    DataModule.Recursos
  , System.StrUtils
  , Services.MessageDialog
  , Services.Utils;

class function TFrmCategoriaSelecao.getInstance: TFrmCategoriaSelecao;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmCategoriaSelecao, _instance);

  Result := _instance;
end;

procedure TFrmCategoriaSelecao.addItemCategoria(const aObjeto: TObjetoItemListView);
var
  aItem : TListViewItem;
begin
  aItem := ListViewCategorias.Items.Add;
  aItem.TagString := aObjeto.ID.ToString;
  aItem.TagObject := aObjeto;

  formatItemCategoria(aItem);
end;

procedure TFrmCategoriaSelecao.CarregarCategorias;
var
  aError : String;
  I : Integer;
  o : TObjetoItemListView;
begin
  FCategogiaController.Load(aError);

  if not aError.IsEmpty then
    TServicesMessageDialog.Error('Categorias', aError)
  else
  begin

    ListViewCategorias.BeginUpdate;
    try
      LimparListView;

//      for I in FCategogiaController.Lista.Keys do
//      begin
//        o := TObjetoItemListView.Create;
//
//        o.Codigo    := FCategogiaController.Lista[I].Codigo;
//        o.Descricao := FCategogiaController.Lista[I].Descricao;
//        o.Image     := TServicesUtils.Base64FromBitmap( FCategogiaController.Lista[I].Icone );
//
//        addItemCategoria(o);
//      end;
      for I := 0 to FCategogiaController.Selecao.Count - 1 do
      begin
        o := TObjetoItemListView.Create;

        o.Codigo    := FCategogiaController.Selecao.Items[I].Codigo;
        o.Descricao := FCategogiaController.Selecao.Items[I].Descricao;
        o.Image     := TServicesUtils.Base64FromBitmap( FCategogiaController.Selecao.Items[I].Icone );

        addItemCategoria(o);
      end;
    finally
      ListViewCategorias.EndUpdate;
    end;

  end;
end;

procedure TFrmCategoriaSelecao.formatItemCategoria(const aItem: TListViewItem);
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
      aTexto.Text  := IfThen(aObjeto.Descricao.Trim.IsEmpty, '. . . ', aObjeto.Descricao);
      aTexto.Width := Self.Width - (44 + 6);

      // Ícone
      aImage := TListItemImage(aItem.Objects.FindDrawable('ImageCategoria'));

      if aObjeto.Image.IsEmpty then
      begin
        aImage.Bitmap := ImgSemImage.Bitmap;
        aImage.ScalingMode := TImageScalingMode.Original;
      end
      else
      begin
        // Criar uma imagem a partir de uma base de 64 bits
        aImage.Bitmap := TBitmap.Create;
        aImage.Bitmap.Assign( TServicesUtils.BitmapFromBase64(aObjeto.Image) );
        aImage.OwnsBitmap  := True;
        aImage.ScalingMode := TImageScalingMode.Stretch;
      end;

      aItem.Height := 60;
    end;
  end;
end;

procedure TFrmCategoriaSelecao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action    := TCloseAction.caFree;
  _instance := nil;
end;

procedure TFrmCategoriaSelecao.FormCreate(Sender: TObject);
begin
  ImgSemImage.Visible  := False;
  FCategogiaController := TCategoriaController.GetInstance();

  CarregarCategorias;
end;

procedure TFrmCategoriaSelecao.ImageFecharClick(Sender: TObject);
begin
  //Close;
  ModalResult := mrCancel;
end;

procedure TFrmCategoriaSelecao.LimparListView;
var
  I : Integer;
begin
  // Voltar o Scroll para o índice 0 (zero)
  ListViewCategorias.ScrollTo(0);

  // Limpar objesto de lista para evitar MemoryLeak
  for I := 0 to ListViewCategorias.Items.Count - 1 do
    if Assigned(ListViewCategorias.Items.Item[I].TagObject) then
      ListViewCategorias.Items.Item[I].TagObject.DisposeOf;

  ListViewCategorias.Items.Clear;
end;

procedure TFrmCategoriaSelecao.ListViewCategoriasItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  aError : String;
begin
  if (ListViewCategorias.Selected <> nil) then
    if Assigned(AItem.TagObject) then
    begin
      FCategogiaController.Find(TObjetoItemListView(AItem.TagObject).Codigo, aError, True);
      if not aError.IsEmpty then
        TServicesMessageDialog.Error('Categoria', aError)
      else
        ModalResult := mrOk;
    end;
end;

end.
