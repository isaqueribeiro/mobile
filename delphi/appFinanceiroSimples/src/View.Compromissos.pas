unit View.Compromissos;

interface

uses
  Classe.ObjetoItemListView,
  Services.ComplexTypes,
  View.CompromissoEdicao,
  Controller.Compromisso,
  Controllers.Interfaces.Observers,
  Views.Interfaces.Observers,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFrmCompromissos = class(TForm, IObserverCompromissoController, IObserverCompromissoEdicao)
    ImgSemImage: TImage;
    LayoutHeader: TLayout;
    LabelTitulo: TLabel;
    ImageFechar: TImage;
    LayoutFilter: TLayout;
    ImageVoltarMes: TImage;
    ImageProximoMes: TImage;
    RectangleMes: TRectangle;
    LabelMes: TLabel;
    LayoutResumo: TLayout;
    RectangleResumo: TRectangle;
    ImageAdicionar: TImage;
    LayoutComprometer: TLayout;
    lblValorComprometer: TLabel;
    LabelComprometer: TLabel;
    LayoutComprometido: TLayout;
    lblValorComprometido: TLabel;
    LabelComprometido: TLabel;
    LayoutPendente: TLayout;
    lblValorPendente: TLabel;
    LabelPendente: TLabel;
    LayoutBody: TLayout;
    LayoutCalendar: TLayout;
    LayoutItens: TLayout;
    ListViewCompromissos: TListView;
    procedure DefinirMesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImageFecharClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ImageAdicionarClick(Sender: TObject);
    procedure ListViewCompromissosItemClick(const Sender: TObject; const AItem: TListViewItem);
  strict private
    class var _instance : TFrmCompromissos;
  private
    { Private declarations }
    FTipo : TTipoCompromisso;
    FDataFiltro : TDateTime;
    FRecarregar : Boolean;
    FCompromissoController : TCompromissoController;
    FEdicao : TFrmCompromissoEdicao;

    procedure CarregarCompromissos(aLimparLista : Boolean);
    procedure InicializarComponentes;
    procedure AtualizarCompromisso;
    procedure AtualizarItemCompromisso;
    procedure LimparListView;
  public
    { Public declarations }
    class function GetInstance(const ATipo : TTipoCompromisso) : TFrmCompromissos;
    class function Instanciado : Boolean;
  end;

implementation

uses
    DataModule.Recursos
  , Services.Utils
  , System.DateUtils
  , Services.MessageDialog;

{$R *.fmx}

{ TFrmCompromissos }

procedure TFrmCompromissos.AtualizarCompromisso;
begin
  ;
end;

procedure TFrmCompromissos.AtualizarItemCompromisso;
var
  aError : String;
  aTotal     : TTotalCompromissos;
  aRegistros ,
  aItemIndex : Integer;
  aItem      : TListViewItem;
  o : TObjetoItemListView;
begin
  if (YearOf(FCompromissoController.Attributes.Data) = YearOf(FDataFiltro)) and (MonthOf(FCompromissoController.Attributes.Data) = MonthOf(FDataFiltro)) then
  begin
    aRegistros := 30;

    case FCompromissoController.Operacao of
      TTipoOperacaoController.operControllerInsert :
        begin
//          o := TObjetoItemListView.Create;
//
//          o.ID        := FLAncamentoController.Attributes.ID;
//          o.Codigo    := FLAncamentoController.Attributes.Codigo;
//          o.Descricao := FLAncamentoController.Attributes.Descricao;
//          o.Valor     := FormatFloat(',0.00', FLAncamentoController.Attributes.Valor);
//          o.Categoria := FLAncamentoController.Attributes.Categoria.Descricao;
//          o.DataMovimento := FormatDateTime('dd/mm', FLAncamentoController.Attributes.Data);
//          o.Image     := TServicesUtils.Base64FromBitmap( FLAncamentoController.Attributes.Categoria.Icone );
//
//          addItemLancamento(o);
//          Inc(aRegistros);
        end;

      TTipoOperacaoController.operControllerUpdate :
        begin
//          aItem := TListViewItem(ListViewLancamentos.Items.Item[ListViewLancamentos.ItemIndex]);
//
//          if Assigned(aItem.TagObject) then
//            o := TObjetoItemListView(aItem.TagObject)
//          else
//            o := TObjetoItemListView.Create;
//
//          o.ID        := FLAncamentoController.Attributes.ID;
//          o.Codigo    := FLAncamentoController.Attributes.Codigo;
//          o.Descricao := FLAncamentoController.Attributes.Descricao;
//          o.Valor     := FormatFloat(',0.00', FLAncamentoController.Attributes.Valor);
//          o.Categoria := FLAncamentoController.Attributes.Categoria.Descricao;
//          o.DataMovimento := FormatDateTime('dd/mm', FLAncamentoController.Attributes.Data);
//          o.Image     := TServicesUtils.Base64FromBitmap( FLAncamentoController.Attributes.Categoria.Icone );
//
//          aItem.TagObject := o;
//          formatItemLancamento( aItem );
        end;

      TTipoOperacaoController.operControllerDelete :
        begin
          aItemIndex := ListViewCompromissos.ItemIndex;
          aItem      := TListViewItem(ListViewCompromissos.Items.Item[aItemIndex]);

          if Assigned(aItem.TagObject) then
            aItem.TagObject.DisposeOf;

          ListViewCompromissos.Items.Delete(aItemIndex);
        end;

      TTipoOperacaoController.operControllerBrowser :
        CarregarCompromissos(True);
    end;

    FCompromissoController.Load(aRegistros, 0, 0, FTipo, aTotal, aError);

    lblValorComprometer.Text  := 'R$' + #13 + FormatFloat(',0.00', aTotal.Comprometer);
    lblValorComprometido.Text := 'R$' + #13 + FormatFloat(',0.00', aTotal.Comprometido);
    lblValorPendente.Text     := 'R$' + #13 + FormatFloat(',0.00', aTotal.Pendente);
  end;
end;

procedure TFrmCompromissos.CarregarCompromissos(aLimparLista: Boolean);
var
  aError : String;
  I : Integer;
  a : TGUID;
  o : TObjetoItemListView;
  aTotal : TTotalCompromissos;
begin
  FCompromissoController.Load(0, YearOf(FDataFiltro), MonthOf(FDataFiltro), FTipo, aTotal, aError);

  if not aError.IsEmpty then
    TServicesMessageDialog.Error(LabelTitulo.Text, aError)
  else
  begin

    ListViewCompromissos.BeginUpdate;
    try
      if aLimparLista then
        LimparListView;



    finally
      ListViewCompromissos.EndUpdate;
    end;
  end;

  lblValorComprometer.Text  := 'R$' + #13 + FormatFloat(',0.00', aTotal.Comprometer);
  lblValorComprometido.Text := 'R$' + #13 + FormatFloat(',0.00', aTotal.Comprometido);
  lblValorPendente.Text     := 'R$' + #13 + FormatFloat(',0.00', aTotal.Pendente);
end;

procedure TFrmCompromissos.DefinirMesClick(Sender: TObject);
var
  aIncremento : Integer;
begin
  aIncremento   := TFmxObject(Sender).Tag;
  FDataFiltro   := IncMonth(FDataFiltro, aIncremento);
  LabelMes.Text := TServicesUtils.MonthName(FDataFiltro).ToUpper + '/' + YearOf(FDataFiltro).ToString;

  CarregarCompromissos(True);
end;

procedure TFrmCompromissos.FormActivate(Sender: TObject);
begin
  InicializarComponentes;
end;

procedure TFrmCompromissos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FRecarregar := True;

  LimparListView;
  FCompromissoController.RemoverObservador(Self);
end;

procedure TFrmCompromissos.FormCreate(Sender: TObject);
begin
  FCompromissoController := TCompromissoController.GetInstance(Self);

  ImgSemImage.Visible := False;
  FDataFiltro := Date;
  FRecarregar := True;
end;

procedure TFrmCompromissos.FormShow(Sender: TObject);
begin
  if FRecarregar then
    DefinirMesClick(Self);
end;

class function TFrmCompromissos.GetInstance(const ATipo: TTipoCompromisso): TFrmCompromissos;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmCompromissos, _instance);

  _instance.FTipo := ATipo;
  Result := _instance;
end;

procedure TFrmCompromissos.ImageAdicionarClick(Sender: TObject);
begin
  FCompromissoController.New;
  FCompromissoController.Attributes.Tipo := FTipo;

  FEdicao := TFrmCompromissoEdicao.GetInstance(FTipo, Self);
  FEdicao.Show;
end;

procedure TFrmCompromissos.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmCompromissos.InicializarComponentes;
begin
  case FTipo of
    TTipoCompromisso.tipoCompromissoAReceber :
      begin
        LabelTitulo.Text       := 'Contas A Receber';
        LabelComprometer.Text  := 'A Receber (+)';
        LabelComprometido.Text := 'Recebido';
        LabelPendente.Text     := 'Pendente (+)';
      end;

    TTipoCompromisso.tipoCompromissoAPagar   :
      begin
        LabelTitulo.Text       := 'Contas A Pagar';
        LabelComprometer.Text  := 'A Pagar (-)';
        LabelComprometido.Text := 'Pago';
        LabelPendente.Text     := 'Pendente (-)';
      end;
  end;

  lblValorComprometer.Text  := 'R$' + #13 + FormatFloat(',0.00', 0);
  lblValorComprometido.Text := 'R$' + #13 + FormatFloat(',0.00', 0);
  lblValorPendente.Text     := 'R$' + #13 + FormatFloat(',0.00', 0);
end;

class function TFrmCompromissos.Instanciado: Boolean;
begin
  Result := Assigned(_instance);
end;

procedure TFrmCompromissos.LimparListView;
begin
  // Voltar o Scroll para o índice 0 (zero)
  ListViewCompromissos.ScrollTo(0);
  ListViewCompromissos.Items.Clear;
end;

procedure TFrmCompromissos.ListViewCompromissosItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  FRecarregar := False;

  if (ListViewCompromissos.Selected <> nil) then
    if Assigned(AItem.TagObject) then
    begin
      FCompromissoController
        .Attributes
        .ID := TObjetoItemListView(AItem.TagObject).ID;

      FEdicao := TFrmCompromissoEdicao.GetInstance(FTipo, Self);
      FEdicao.Show;
    end;
end;

end.
