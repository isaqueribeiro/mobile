unit View.Lancamentos;

interface

uses
  Classe.ObjetoItemListView,
  View.LancamentoEdicao,

  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFrmLancamentos = class(TForm)
    LayoutTool: TLayout;
    ImageFechar: TImage;
    LayoutResumo: TLayout;
    RectangleResumo: TRectangle;
    ImageAdicionar: TImage;
    LayoutReceita: TLayout;
    lblValorReceitas: TLabel;
    LabelReceita: TLabel;
    LayoutDespesa: TLayout;
    lblValorDespesas: TLabel;
    LabelDespesa: TLabel;
    LayoutSaldo: TLayout;
    lblValorSaldo: TLabel;
    LabelSaldo: TLabel;
    LayoutMes: TLayout;
    ImageVoltarMes: TImage;
    ImageProximoMes: TImage;
    RectangleMes: TRectangle;
    LabelMes: TLabel;
    ImgSemImage: TImage;
    ListViewLancamentos: TListView;
    LabelTitulo: TLabel;
    procedure DefinirMesClick(Sender: TObject);
    procedure ImageFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImageAdicionarClick(Sender: TObject);
    procedure ListViewLancamentosUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  strict private
    class var _instance : TFrmLancamentos;
  private
    { Private declarations }
    FEdicao : TFrmLancamentoEdicao;
    FDataFiltro : TDateTime;
    procedure addItemLancamento(const aObjeto : TObjetoItemListView);
    procedure formatItemLancamento(const aItem: TListViewItem);
  public
    { Public declarations }
    class function GetInstance() : TFrmLancamentos;
    class function Instanciado : Boolean;
  end;

//var
//  FrmLancamentos: TFrmLancamentos;
//
implementation

{$R *.fmx}

uses
    DataModule.Recursos
  , Services.Utils
  , System.DateUtils;

procedure TFrmLancamentos.addItemLancamento(const aObjeto: TObjetoItemListView);
var
  aItem : TListViewItem;
begin
  aItem := ListViewLancamentos.Items.Add;
  aItem.TagString := aObjeto.ID.ToString;
  aItem.TagObject := aObjeto;

  formatItemLancamento(aItem);
end;

procedure TFrmLancamentos.DefinirMesClick(Sender: TObject);
var
  aIncremento : Integer;
begin
  aIncremento   := TFmxObject(Sender).Tag;
  FDataFiltro   := IncMonth(FDataFiltro, aIncremento);
  LabelMes.Text := TServicesUtils.MonthName(FDataFiltro).ToUpper + '/' + YearOf(FDataFiltro).ToString;
end;

procedure TFrmLancamentos.formatItemLancamento(const aItem: TListViewItem);
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

procedure TFrmLancamentos.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I : Integer;
begin
  // Limpar objesto de lista para evitar MemoryLeak
  for I := 0 to ListViewLancamentos.Items.Count - 1 do
    if Assigned(ListViewLancamentos.Items.Item[I].TagObject) then
      ListViewLancamentos.Items.Item[I].TagObject.DisposeOf;
end;

procedure TFrmLancamentos.FormCreate(Sender: TObject);
begin
  ImgSemImage.Visible := False;
  FDataFiltro := Date;
  DefinirMesClick(Self);
end;

class function TFrmLancamentos.GetInstance: TFrmLancamentos;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmLancamentos, _instance);

  Result := _instance;
end;

procedure TFrmLancamentos.ImageAdicionarClick(Sender: TObject);
begin
  FEdicao := TFrmLancamentoEdicao.GetInstance();
  FEdicao.Show;
end;

procedure TFrmLancamentos.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

class function TFrmLancamentos.Instanciado: Boolean;
begin
  Result := Assigned(_instance);
end;

procedure TFrmLancamentos.ListViewLancamentosUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  formatItemLancamento(AItem);
end;

end.
