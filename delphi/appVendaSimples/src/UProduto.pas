unit UProduto;

interface

uses
  model.Produto,
  dao.Produto,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadrao, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, System.Actions, FMX.ActnList,
  FMX.TabControl;

type
  TFrmProduto = class(TFrmPadrao)
    layoutBuscaProduto: TLayout;
    rectangleBuscaProduto: TRectangle;
    editBuscaProduto: TEdit;
    imageBuscaProduto: TImage;
    ListViewProduto: TListView;
    img_produto_sem_foto: TImage;
    lytProdutoFoto: TLayout;
    imgProdutoFoto: TImage;
    lblAlterarImagem: TLabel;
    lytProdutoDescricao: TLayout;
    lineProdutoDescricao: TLine;
    LabelProdutoDescricao: TLabel;
    imgProdutoDescricao: TImage;
    lblProdutoDescricao: TLabel;
    lytProdutoValor: TLayout;
    lineProdutoValor: TLine;
    LabelProdutoValor: TLabel;
    imgProdutoValor: TImage;
    lblProdutoValor: TLabel;
    lytProdutoEan: TLayout;
    lineProdutoEan: TLine;
    img_foto_novo_produto: TImage;
    LabelProdutoEan: TLabel;
    procedure DoBuscaProdutos(Sender: TObject);
    procedure ListViewProdutoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imageAdicionarClick(Sender: TObject);
  strict private
    { Private declarations }
    procedure FormatarItemProdutoListView(aItem  : TListViewItem);
    procedure AdicionarProdutoListView(aProduto : TProduto);
    procedure BuscarProdutos(aBusca : String; aPagina : Integer);
    procedure NovoProduto;

    class var aInstance : TFrmProduto;
  public
    { Public declarations }
    class function GetInstance : TFrmProduto;
  end;

  procedure ExibirListaProdutos;

implementation

{$R *.fmx}

uses
  UConstantes,
  UMensagem;

procedure ExibirListaProdutos;
var
  aForm : TFrmProduto;
begin
  aForm := TFrmProduto.GetInstance;
  aForm.Show;
end;

{ TFrmProduto }

class function TFrmProduto.GetInstance: TFrmProduto;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmProduto, aInstance);
    Application.RealCreateForms;
  end;

  Result := aInstance;
end;

procedure TFrmProduto.imageAdicionarClick(Sender: TObject);
begin
  inherited;
  NovoProduto;
end;

procedure TFrmProduto.AdicionarProdutoListView(aProduto: TProduto);
var
  aItem  : TListViewItem;
begin
  aItem := ListViewProduto.Items.Add;
  aItem.TagObject := aProduto;
  FormatarItemProdutoListView(aItem);
end;

procedure TFrmProduto.BuscarProdutos(aBusca: String; aPagina: Integer);
var
  dao : TProdutoDao;
  I : Integer;
begin
  dao := TProdutoDao.GetInstance;
  dao.Load(aBusca);
  for I := Low(dao.Lista) to High(dao.Lista) do
    AdicionarProdutoListView(dao.Lista[I]);
end;

procedure TFrmProduto.DoBuscaProdutos(Sender: TObject);
begin
  try
    ListViewProduto.BeginUpdate;
    ListViewProduto.Items.Clear;

    BuscarProdutos(editBuscaProduto.Text, 0);

    ListViewProduto.EndUpdate;
    ListViewProduto.Visible  := (ListViewProduto.Items.Count > 0);
    //layoutSemProduto.Visible := not ListViewPedido.Visible;
  except
    On E : Exception do
      ExibirMsgErro(E.Message);
  end;
end;

procedure TFrmProduto.FormatarItemProdutoListView(aItem: TListViewItem);
var
  aText    : TListItemText;
  aImage   : TListItemImage;
  aProduto : TProduto;
begin
  with aItem do
  begin
    aProduto := TProduto(aItem.TagObject);

    // Descrição
    aText := TListItemText(Objects.FindDrawable('Text2'));
    aText.Text     := aProduto.Descricao;
    aText.WordWrap := True;

    // Valor (R$)
    aText := TListItemText(Objects.FindDrawable('Text1'));
    aText.Text := 'R$ ' + FormatFloat(',0.00', aProduto.Valor);

    // Foto
    aImage := TListItemImage(Objects.FindDrawable('Image4'));
    if (aProduto.Foto <> nil) then
      aImage.Bitmap.LoadFromStream(aProduto.Foto)
    else
      aImage.Bitmap := img_produto_sem_foto.Bitmap;
  end;
end;

procedure TFrmProduto.FormCreate(Sender: TObject);
begin
  inherited;
  img_produto_sem_foto.Visible  := False;
  img_foto_novo_produto.Visible := False;
end;

procedure TFrmProduto.FormShow(Sender: TObject);
begin
  inherited;
  DoBuscaProdutos(nil);
end;

procedure TFrmProduto.ListViewProdutoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  FormatarItemProdutoListView(AItem);
end;

procedure TFrmProduto.NovoProduto;
begin
  labelTituloCadastro.Text := 'NOVO PRODUTO';
  imgProdutoFoto.Bitmap    := img_foto_novo_produto.Bitmap;
  lblProdutoDescricao.Text := 'Informe aqui a descrição do novo produto';
  lblProdutoValor.Text     := '0,00';
end;

end.
