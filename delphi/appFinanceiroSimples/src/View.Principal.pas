unit View.Principal;

interface

uses
  Classe.ObjetoItemListView,
  Controller.Lancamento,
  Controllers.Interfaces.Observers,
  View.LancamentoEdicao,
  Views.Interfaces.Observers,

  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Ani;

type
  TFrmPrincipal = class(TForm, IObserverLancamentoController, IObserverLancamentoEdicao)
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
    LayoutDespesa: TLayout;
    ImageDespesa: TImage;
    lblValorDespesas: TLabel;
    LabelDespesa: TLabel;
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
    lytMenuCompromisso: TLayout;
    lblMenuCompromisso: TLabel;
    lytMenuCompromissoPagar: TLayout;
    imgMenuCompromissoPagar: TImage;
    lblMenuCompromissoPagar: TLabel;
    lytMenuCompromissoReceber: TLayout;
    imgMenuCompromissoReceber: TImage;
    lblMenuCompromissoReceber: TLabel;
    lytMenuConfiguracoes: TLayout;
    imgMenuConfiguracoes: TImage;
    lblMenuConfiguracoes: TLabel;
    lnMenuCompromisso: TLine;
    lnMenuCategoria: TLine;
    lnMenuConfiguracoes: TLine;
    procedure FormCreate(Sender: TObject);
    procedure ListViewLancamentosUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ImageAdicionarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblVerTodosClick(Sender: TObject);
    procedure ImageMenuClick(Sender: TObject);
    procedure AnimationMenuFinish(Sender: TObject);
    procedure AnimationMenuProcess(Sender: TObject);
    procedure lytMenuCategoriaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ListViewLancamentosItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure lytMenuCompromissoPagarClick(Sender: TObject);
    procedure lytMenuCompromissoReceberClick(Sender: TObject);
  private
    { Private declarations }
    FEdicaoLancamento : TFrmLancamentoEdicao;
    FLancamentoController : TLancamentoController;
    FDataFiltro : TDateTime;
    procedure LimparListView;
    procedure AtualizarLancamento;
    procedure AtualizarItemLancamento;

    procedure addItemLancamento(const aObjeto : TObjetoItemListView);
    procedure formatItemLancamento(const aItem: TListViewItem);

    procedure CarregarLancamentos;
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

  procedure CarregarPrincipal;

implementation

{$R *.fmx}

uses
    System.DateUtils
  , DataModule.Recursos
  , DataModule.Conexao
  , Classes.ScriptDDL
  , View.Compromissos
  , View.Lancamentos
  , View.Categorias
  , Services.Utils
  , Services.ComplexTypes
  , Services.MessageDialog;

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

procedure TFrmPrincipal.AtualizarItemLancamento;
var
  aError : String;
  aTotal     : TTotalLancamentos;
  aRegistros ,
  aItemIndex : Integer;
  aItem      : TListViewItem;
  o : TObjetoItemListView;
begin
  if (YearOf(FLancamentoController.Attributes.Data) = YearOf(FDataFiltro)) and (MonthOf(FLancamentoController.Attributes.Data) = MonthOf(FDataFiltro)) then
  begin
    aRegistros := 30;

    case FLancamentoController.Operacao of
      TTipoOperacaoController.operControllerInsert :
        begin
          o := TObjetoItemListView.Create;

          o.ID        := FLAncamentoController.Attributes.ID;
          o.Codigo    := FLAncamentoController.Attributes.Codigo;
          o.Descricao := FLAncamentoController.Attributes.Descricao;
          o.Valor     := FormatFloat(',0.00', FLAncamentoController.Attributes.Valor);
          o.Categoria := FLAncamentoController.Attributes.Categoria.Descricao;
          o.DataMovimento := FormatDateTime('dd/mm', FLAncamentoController.Attributes.Data);
          o.Image     := TServicesUtils.Base64FromBitmap( FLAncamentoController.Attributes.Categoria.Icone );

          addItemLancamento(o);
          Inc(aRegistros);
        end;

      TTipoOperacaoController.operControllerUpdate :
        begin
          aItem := TListViewItem(ListViewLancamentos.Items.Item[ListViewLancamentos.ItemIndex]);

          if Assigned(aItem.TagObject) then
            o := TObjetoItemListView(aItem.TagObject)
          else
            o := TObjetoItemListView.Create;

          o.ID        := FLAncamentoController.Attributes.ID;
          o.Codigo    := FLAncamentoController.Attributes.Codigo;
          o.Descricao := FLAncamentoController.Attributes.Descricao;
          o.Valor     := FormatFloat(',0.00', FLAncamentoController.Attributes.Valor);
          o.Categoria := FLAncamentoController.Attributes.Categoria.Descricao;
          o.DataMovimento := FormatDateTime('dd/mm', FLAncamentoController.Attributes.Data);
          o.Image     := TServicesUtils.Base64FromBitmap( FLAncamentoController.Attributes.Categoria.Icone );

          aItem.TagObject := o;
          formatItemLancamento( aItem );
        end;

      TTipoOperacaoController.operControllerDelete :
        begin
          aItemIndex := ListViewLancamentos.ItemIndex;
          aItem      := TListViewItem(ListViewLancamentos.Items.Item[aItemIndex]);

          if Assigned(aItem.TagObject) then
            aItem.TagObject.DisposeOf;

          ListViewLancamentos.Items.Delete(aItemIndex);
        end;
    end;

    FLAncamentoController.Load(aRegistros, 0, 0, aTotal, aError);

    lblValorReceitas.Text := 'R$ ' + FormatFloat(',0.00', aTotal.Receitas);
    lblValorDespesas.Text := 'R$ ' + FormatFloat(',0.00', aTotal.Despesas);
    lblValorSaldo.Text    := FormatFloat(',0.00', aTotal.Saldo);
  end;
end;

procedure TFrmPrincipal.AtualizarLancamento;
begin
  if (YearOf(FLancamentoController.Attributes.Data) = YearOf(FDataFiltro)) and (MonthOf(FLancamentoController.Attributes.Data) = MonthOf(FDataFiltro)) then
    CarregarLancamentos;
end;

procedure TFrmPrincipal.CarregarLancamentos;
var
  aError : String;
  I : Integer;
  a : TGUID;
  o : TObjetoItemListView;
  aTotal : TTotalLancamentos;
begin
  FLAncamentoController.Load(15, 0, 0, aTotal, aError);

  if not aError.IsEmpty then
    TServicesMessageDialog.Error('Lançamentos', aError)
  else
  begin

    ListViewLancamentos.BeginUpdate;
    try
      LimparListView;

//      for a in FLAncamentoController.Lista.Keys do
//      begin
//        o := TObjetoItemListView.Create;
//
//        o.ID        := FLAncamentoController.Lista[a].ID;
//        o.Codigo    := FLAncamentoController.Lista[a].Codigo;
//        o.Descricao := FLAncamentoController.Lista[a].Descricao;
//        o.Valor     := FormatFloat(',0.00', FLAncamentoController.Lista[a].Valor);
//        o.Categoria := FLAncamentoController.Lista[a].Categoria.Descricao;
//        o.DataMovimento := FormatDateTime('dd/mm', FLAncamentoController.Lista[a].Data);
//        o.Image     := TServicesUtils.Base64FromBitmap( FLAncamentoController.Lista[a].Categoria.Icone );
//
//        addItemLancamento(o);
//      end;
      for I := 0 to FLAncamentoController.Lista.Count - 1 do
      begin
        o := TObjetoItemListView.Create;

        o.ID        := FLAncamentoController.Lista.Items[I].ID;
        o.Codigo    := FLAncamentoController.Lista.Items[I].Codigo;
        o.Descricao := FLAncamentoController.Lista.Items[I].Descricao;
        o.Valor     := FormatFloat(',0.00', FLAncamentoController.Lista.Items[I].Valor);
        o.Categoria := FLAncamentoController.Lista.Items[I].Categoria.Descricao;
        o.DataMovimento := FormatDateTime('dd/mm', FLAncamentoController.Lista.Items[I].Data);
        o.Image     := TServicesUtils.Base64FromBitmap( FLAncamentoController.Lista.Items[I].Categoria.Icone );

        addItemLancamento(o);
      end;
    finally
      ListViewLancamentos.EndUpdate;
    end;

  end;

  lblValorReceitas.Text := 'R$ ' + FormatFloat(',0.00', aTotal.Receitas);
  lblValorDespesas.Text := 'R$ ' + FormatFloat(',0.00', aTotal.Despesas);
  lblValorSaldo.Text    := FormatFloat(',0.00', aTotal.Saldo);
end;

procedure TFrmPrincipal.FormActivate(Sender: TObject);
begin
  // Garantir que o controller seja instanciado novamente
  FLancamentoController := TLancamentoController.GetInstance(Self);
  Self.BringToFront;
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

  FDataFiltro := Date;
  FLancamentoController := TLancamentoController.GetInstance(Self);
  CarregarLancamentos;
end;

procedure TFrmPrincipal.ImageAdicionarClick(Sender: TObject);
begin
  FLancamentoController.New;

  FEdicaoLancamento := TFrmLancamentoEdicao.GetInstance(Self);
  FEdicaoLancamento.Show;
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

procedure TFrmPrincipal.LimparListView;
var
  I : Integer;
begin
  // Voltar o Scroll para o índice 0 (zero)
  ListViewLancamentos.ScrollTo(0);

  // Limpar objesto de lista para evitar MemoryLeak
  for I := 0 to ListViewLancamentos.Items.Count - 1 do
    if Assigned(ListViewLancamentos.Items.Item[I].TagObject) then
      ListViewLancamentos.Items.Item[I].TagObject.DisposeOf;

  ListViewLancamentos.Items.Clear;
end;

procedure TFrmPrincipal.ListViewLancamentosItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  if (ListViewLancamentos.Selected <> nil) then
    if Assigned(AItem.TagObject) then
    begin
      FLancamentoController
        .Attributes
        .ID := TObjetoItemListView(AItem.TagObject).ID;

      FEdicaoLancamento := TFrmLancamentoEdicao.GetInstance(Self);
      FEdicaoLancamento.Show;
    end;
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

procedure TFrmPrincipal.lytMenuCompromissoPagarClick(Sender: TObject);
begin
  AnimationMenu.Start;
  TFrmCompromissos.GetInstance(TTipoCompromisso.tipoCompromissoAPagar).Show;
end;

procedure TFrmPrincipal.lytMenuCompromissoReceberClick(Sender: TObject);
begin
  AnimationMenu.Start;
  TFrmCompromissos.GetInstance(TTipoCompromisso.tipoCompromissoAReceber).Show;
end;

end.
