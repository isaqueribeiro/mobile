unit View.Principal;

interface

uses
  Classe.ObjetoItemListView,

  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Ani;

type
  TFrmPrincipal = class(TForm)
    LayoutTitulo: TLayout;
    ImageMenu: TImage;
    CircleFoto: TCircle;
    ImageNotificacao: TImage;
    LayoutSaldo: TLayout;
    LayoutGrupos: TLayout;
    ImageTitulo: TImage;
    lblTituloSaldo: TLabel;
    lblValorSaldo: TLabel;
    LayoutReceitaDespesa: TLayout;
    LayoutReceita: TLayout;
    ImageReceita: TImage;
    lblValorReceitas: TLabel;
    LabelReceita: TLabel;
    Layout1: TLayout;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    RectangleAdicionar: TRectangle;
    ImageAdicionar: TImage;
    RectangleLista: TRectangle;
    LayoutFiltro: TLayout;
    lblUltimosLancamentos: TLabel;
    lblVerTodos: TLabel;
    ListViewLancamentos: TListView;
    LayoutPrincipal: TLayout;
    ImgSemImage: TImage;
    RectangleMenu: TRectangle;
    AnimationMenu: TFloatAnimation;
    LayoutFecharMenu: TLayout;
    ImageFecharMenu: TImage;
    lytMenuCategoria: TLayout;
    imgMenuCategoria: TImage;
    lblMenuCategoria: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ListViewLancamentosUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ImageAdicionarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblVerTodosClick(Sender: TObject);
    procedure ImageMenuClick(Sender: TObject);
    procedure AnimationMenuFinish(Sender: TObject);
    procedure AnimationMenuProcess(Sender: TObject);
    procedure lytMenuCategoriaClick(Sender: TObject);
  private
    { Private declarations }
    procedure addItemLancamento(const aObjeto : TObjetoItemListView);
    procedure formatItemLancamento(const aItem: TListViewItem);
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

  procedure CarregarPrincipal;

implementation

{$R *.fmx}

uses
    DataModule.Recursos
  , DataModule.Conexao
  , Classes.ScriptDDL
  , View.Lancamentos
  , View.Categorias;

procedure CarregarPrincipal;
begin
  if not Assigned(FrmPrincipal) then
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);

  Application.MainForm := FrmPrincipal;
  FrmPrincipal.Show;
end;

procedure TFrmPrincipal.addItemLancamento(const aObjeto: TObjetoItemListView);
var
  aItem : TListViewItem;
begin
  aItem := ListViewLancamentos.Items.Add;
  aItem.TagString := aObjeto.ID.ToString;
  aItem.TagObject := aObjeto;

  formatItemLancamento(aItem);
end;

procedure TFrmPrincipal.AnimationMenuFinish(Sender: TObject);
begin
  LayoutPrincipal.Enabled := AnimationMenu.Inverse;
  AnimationMenu.Inverse := not AnimationMenu.Inverse;
end;

procedure TFrmPrincipal.AnimationMenuProcess(Sender: TObject);
begin
  LayoutPrincipal.Margins.Right := (RectangleMenu.Width * (-1)) - RectangleMenu.Margins.Left;
end;

procedure TFrmPrincipal.formatItemLancamento(const aItem: TListViewItem);
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
      // Descrição
      aTexto := TListItemText(aItem.Objects.FindDrawable('TextDescricao'));
      aTexto.Text  := aObjeto.Descricao;
      aTexto.Width := Self.Width - (38 + 89 + 6);

      // Valor
      aTexto := TListItemText(aItem.Objects.FindDrawable('TextValor'));
      aTexto.Text := aObjeto.Valor;

      // Categoria
      aTexto := TListItemText(aItem.Objects.FindDrawable('TextCategoria'));
      aTexto.Text  := IfThen(aObjeto.Categoria.Trim.IsEmpty, '. . . ', aObjeto.Categoria);
      aTexto.Width := Self.Width - (38 + 89 + 6);

      // Data do Movimento
      aTexto := TListItemText(aItem.Objects.FindDrawable('TextData'));
      aTexto.Text := aObjeto.DataMovimento;

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

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
var
  aLancamentos : TFrmLancamentos;
  I : Integer;
begin
  TScriptDDL.getInstance().DisposeOf;
  TDMConexao.getInstance().DisposeOf;

  // Limpar objesto de lista para evitar MemoryLeak
  for I := 0 to ListViewLancamentos.Items.Count - 1 do
    if Assigned(ListViewLancamentos.Items.Item[I].TagObject) then
      ListViewLancamentos.Items.Item[I].TagObject.DisposeOf;

  if TFrmLancamentos.Instanciado then
  begin
    aLancamentos := TFrmLancamentos.GetInstance();
    aLancamentos.DisposeOf;
    aLancamentos := nil;
  end;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  ImageNotificacao.Visible := False;
  ImgSemImage.Visible      := False;

  // Configurar os parâmetros de animação do menu
  RectangleMenu.Align   := TAlignLayout.Left;
  RectangleMenu.Visible := True;
  RectangleMenu.Width   := 0;
  AnimationMenu.StartValue   := 0;
  AnimationMenu.StopValue    := (Self.Width * 80) / 100;
//
//  // Notificar, caso haja vazamento de memória
//  ReportMemoryLeaksOnShutdown := True;
end;

procedure TFrmPrincipal.ImageAdicionarClick(Sender: TObject);
var
  o : TObjetoItemListView;
begin
  o := TObjetoItemListView.Create;
  o.Descricao := 'Teste';
  o.Valor     := '125,45';

  addItemLancamento( o );
end;

procedure TFrmPrincipal.ImageMenuClick(Sender: TObject);
begin
  AnimationMenu.Start;
end;

procedure TFrmPrincipal.lblVerTodosClick(Sender: TObject);
var
  aLancamentos : TFrmLancamentos;
begin
  aLancamentos := TFrmLancamentos.GetInstance();
  aLancamentos.Show;
end;

procedure TFrmPrincipal.ListViewLancamentosUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  formatItemLancamento(AItem);
end;

procedure TFrmPrincipal.lytMenuCategoriaClick(Sender: TObject);
begin
  AnimationMenu.Start;
  TFrmCategorias.GetInstance().Show;
end;

end.
