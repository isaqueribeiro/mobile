unit View.Lancamentos;

interface

uses
  Classe.ObjetoItemListView,
  View.LancamentoEdicao,
  Controller.Lancamento,
  Controllers.Interfaces.Observers,
  Views.Interfaces.Observers,

  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFrmLancamentos = class(TForm, IObserverLancamentoController, IObserverLancamentoEdicao)
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
    FLancamentoController : TLancamentoController;
    FEdicao : TFrmLancamentoEdicao;
    FDataFiltro : TDateTime;
    procedure LimparListView;
    procedure AtualizarLancamento;
    procedure AtualizarItemLancamento; virtual; abstract;

    procedure addItemLancamento(const aObjeto : TObjetoItemListView);
    procedure formatItemLancamento(const aItem: TListViewItem);

    procedure CarregarLancamentos(aLimparLista : Boolean);
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
  , System.DateUtils
  , Services.ComplexTypes
  , Services.MessageDialog;

procedure TFrmLancamentos.addItemLancamento(const aObjeto: TObjetoItemListView);
var
  aItem : TListViewItem;
begin
  aItem := ListViewLancamentos.Items.Add;
  aItem.TagString := aObjeto.ID.ToString;
  aItem.TagObject := aObjeto;

  formatItemLancamento(aItem);
end;

procedure TFrmLancamentos.AtualizarLancamento;
begin
  ;
end;

procedure TFrmLancamentos.CarregarLancamentos(aLimparLista : Boolean);
var
  aError : String;
  a : TGUID;
  o : TObjetoItemListView;
  aTotal : TTotalLancamentos;
begin
  FLAncamentoController.Load(0, YearOf(FDataFiltro), MonthOf(FDataFiltro), aTotal, aError);

  if not aError.IsEmpty then
    TServicesMessageDialog.Error('Lançamentos', aError)
  else
  begin

    ListViewLancamentos.BeginUpdate;
    try
      if aLimparLista then
        LimparListView;

      for a in FLAncamentoController.Lista.Keys do
      begin
        o := TObjetoItemListView.Create;

        o.ID        := FLAncamentoController.Lista[a].ID;
        o.Codigo    := FLAncamentoController.Lista[a].Codigo;
        o.Descricao := FLAncamentoController.Lista[a].Descricao;
        o.Valor     := FormatFloat(',0.00', FLAncamentoController.Lista[a].Valor);
        o.Categoria := FLAncamentoController.Lista[a].Categoria.Descricao;
        o.DataMovimento := FormatDateTime('dd/mm', FLAncamentoController.Lista[a].Data);
        o.Image     := TServicesUtils.Base64FromBitmap( FLAncamentoController.Lista[a].Categoria.Icone );

        addItemLancamento(o);
      end;
    finally
      ListViewLancamentos.EndUpdate;
    end;

  end;

  lblValorReceitas.Text := 'R$' + #13 + FormatFloat(',0.00', aTotal.Receitas);
  lblValorDespesas.Text := 'R$' + #13 + FormatFloat(',0.00', aTotal.Despesas);
  lblValorSaldo.Text    := 'R$' + #13 + FormatFloat(',0.00', aTotal.Saldo);
end;

procedure TFrmLancamentos.DefinirMesClick(Sender: TObject);
var
  aIncremento : Integer;
begin
  aIncremento   := TFmxObject(Sender).Tag;
  FDataFiltro   := IncMonth(FDataFiltro, aIncremento);
  LabelMes.Text := TServicesUtils.MonthName(FDataFiltro).ToUpper + '/' + YearOf(FDataFiltro).ToString;

  CarregarLancamentos(True);
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

procedure TFrmLancamentos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LimparListView;
  FLancamentoController.RemoverObservador(Self);
end;

procedure TFrmLancamentos.FormCreate(Sender: TObject);
begin
  FLancamentoController := TLancamentoController.GetInstance(Self);

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
  FEdicao := TFrmLancamentoEdicao.GetInstance(Self);
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

procedure TFrmLancamentos.LimparListView;
begin
  // Voltar o Scroll para o índice 0 (zero)
  ListViewLancamentos.ScrollTo(0);
  ListViewLancamentos.Items.Clear;
end;

procedure TFrmLancamentos.ListViewLancamentosUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  formatItemLancamento(AItem);
end;

end.
