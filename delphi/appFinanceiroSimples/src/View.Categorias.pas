unit View.Categorias;

interface

uses
  Classe.ObjetoItemListView,
  View.CategoriaEdicao,
  Controller.Categoria,
  Views.Interfaces.Observers,

  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  Services.ComplexTypes
;

type
  TFrmCategorias = class(TForm, IObserverCategoriaEdicao)
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
    procedure ListViewCategoriasItemClick(const Sender: TObject; const AItem: TListViewItem);
  strict private
    class var _instance : TFrmCategorias;
  private
    { Private declarations }
    FEdicao : TFrmCategoriaEdicao;
    FCategogiaController : TCategoriaController;
    procedure LimparListView;
    procedure AtualizarCategoria;

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
    DataModule.Recursos
  , Services.Utils
  , Services.MessageDialog;

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

procedure TFrmCategorias.AtualizarCategoria;
var
  o : TObjetoItemListView;
  aItem      : TListViewItem;
  aItemIndex : Integer;
begin
  if FCategogiaController.Operacao = TTipoOperacaoController.operControllerInsert then
  begin
    o := TObjetoItemListView.Create;

    o.Codigo    := FCategogiaController.Attributes.Codigo;
    o.Descricao := FCategogiaController.Attributes.Descricao;
    o.Image     := TServicesUtils.Base64FromBitmap( FCategogiaController.Attributes.Icone );

    addItemCategoria(o);
    ListViewCategorias.ItemIndex := (ListViewCategorias.Items.Count - 1);
  end
  else
  if FCategogiaController.Operacao = TTipoOperacaoController.operControllerUpdate then
  begin
    aItem := TListViewItem(ListViewCategorias.Items.Item[ListViewCategorias.ItemIndex]);

    if Assigned(aItem.TagObject) then
      o := TObjetoItemListView(aItem.TagObject)
    else
      o := TObjetoItemListView.Create;

    o.Codigo    := FCategogiaController.Attributes.Codigo;
    o.Descricao := FCategogiaController.Attributes.Descricao;
    o.Image     := TServicesUtils.Base64FromBitmap( FCategogiaController.Attributes.Icone );

    aItem.TagObject := o;
    formatItemCategoria( aItem );
  end
  else
  if FCategogiaController.Operacao = TTipoOperacaoController.operControllerDelete then
  begin
    aItemIndex := ListViewCategorias.ItemIndex;
    aItem      := TListViewItem(ListViewCategorias.Items.Item[aItemIndex]);

    if Assigned(aItem.TagObject) then
      aItem.TagObject.DisposeOf;

    ListViewCategorias.Items.Delete(aItemIndex);
  end;

  if (ListViewCategorias.Items.Count < 2) then
    lblQuantidadeCategorias.Text := ListViewCategorias.Items.Count.ToString + ' Categoria'
  else
    lblQuantidadeCategorias.Text := ListViewCategorias.Items.Count.ToString + ' Categorias';
//
//  ImgSemPedido.Visible := (ListViewCategorias.Items.Count = 0);
end;

procedure TFrmCategorias.CarregarCategorias;
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

      for I in FCategogiaController.Lista.Keys do
      begin
        o := TObjetoItemListView.Create;

        o.Codigo    := FCategogiaController.Lista[I].Codigo;
        o.Descricao := FCategogiaController.Lista[I].Descricao;
        o.Image     := TServicesUtils.Base64FromBitmap( FCategogiaController.Lista[I].Icone );

        addItemCategoria(o);
      end;
    finally
      ListViewCategorias.EndUpdate;
    end;

  end;

  if (ListViewCategorias.Items.Count < 2) then
    lblQuantidadeCategorias.Text := ListViewCategorias.Items.Count.ToString + ' Categoria'
  else
    lblQuantidadeCategorias.Text := ListViewCategorias.Items.Count.ToString + ' Categorias';
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

procedure TFrmCategorias.FormClose(Sender: TObject; var Action: TCloseAction);
begin
// ESTE BLOCO DE CÓDIGO ESTÁ CAUSANDO VIOLAÇÃO DE MEMÓRIA
//  if Assigned(FCategogiaController) then
//    FCategogiaController.DisposeOf;
//
  LimparListView;

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
begin
  FCategogiaController.New;

  FEdicao := TFrmCategoriaEdicao.GetInstance(Self);
  FEdicao.Show;
end;

procedure TFrmCategorias.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmCategorias.LimparListView;
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

procedure TFrmCategorias.ListViewCategoriasItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  if (ListViewCategorias.Selected <> nil) then
    if Assigned(AItem.TagObject) then
    begin
      FCategogiaController
        .Attributes
        .Codigo := TObjetoItemListView(AItem.TagObject).Codigo;

      FEdicao := TFrmCategoriaEdicao.GetInstance(Self);
      FEdicao.Show;
    end;
end;

procedure TFrmCategorias.ListViewCategoriasUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  formatItemCategoria(AItem);
end;

end.
