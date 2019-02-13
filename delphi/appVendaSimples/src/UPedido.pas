unit UPedido;

interface

uses
  System.StrUtils,
  System.Math,
  System.DateUtils,
  System.Generics.Collections,

  model.Cliente,
  model.Pedido,
  model.PedidoItem,
  dao.Pedido,
  dao.PedidoItem,
  dao.Cliente,
  interfaces.Cliente,
  interfaces.PedidoItem,
  interfaces.Pedido,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.DateTimeCtrls;

type
  TFrmPedido = class(TFrmPadraoCadastro, IObservadorCliente, IObservadorPedidoItem, IPedidoObservado)
    imgDuplicar: TImage;
    lblDuplicar: TLabel;
    lytAbaPedido: TLayout;
    recAbaDadoPedido: TRectangle;
    lblAbaDadoPedido: TLabel;
    recAbaItemPedido: TRectangle;
    lblAbaItemPedido: TLabel;
    LayoutDadoPedido: TLayout;
    LayoutItemPedido: TLayout;
    lytTipo: TLayout;
    lineTipo: TLine;
    LabelTipo: TLabel;
    imgTipo: TImage;
    lblTipo: TLabel;
    lytCliente: TLayout;
    lineCliente: TLine;
    LabelCliente: TLabel;
    imgCliente: TImage;
    lblCliente: TLabel;
    recCliente: TRectangle;
    LayoutCliente: TLayout;
    iconCliente: TImage;
    lineItem: TLine;
    lytData: TLayout;
    lineData: TLine;
    LabelData: TLabel;
    imgData: TImage;
    lblData: TLabel;
    lytContato: TLayout;
    lineContato: TLine;
    LabelContato: TLabel;
    imgContato: TImage;
    lblContato: TLabel;
    lytObs: TLayout;
    lineObs: TLine;
    LabelObs: TLabel;
    imgObs: TImage;
    lblObs: TLabel;
    lytRodapePedido: TLayout;
    recInserirItem: TRectangle;
    lblInserirItem: TLabel;
    lytTotalPedido: TLayout;
    LabelTotalPedido: TLabel;
    lblTotalPedido: TLabel;
    ListViewItemPedido: TListView;
    img_produto_sem_foto: TImage;
    imgSemItemPedido: TImage;
    lblSemProduto: TLabel;
    img_item_menos: TImage;
    img_item_mais: TImage;
    lineRodapePedido: TLine;
    procedure DoMudarAbaPedido(Sender: TObject);
    procedure DoBuscarCliente(Sender: TObject);
    procedure DoEditarCampo(Sender: TObject);
    procedure DoSalvarPedido(Sender: TObject);
    procedure DoExcluirPedido(Sender: TObject);
    procedure DoDuplicarPedido(Sender: TObject);
    procedure DoInserirItemPedido(Sender: TObject);
    procedure DoCarregarItens(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure imgClienteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListViewItemPedidoItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  strict private
    { Private declarations }
    aDao : TPedidoDao;
    FObservers : TList<IObservadorPedido>;

    procedure AtualizarCliente;
    procedure AtualizarPedidoItem;

    procedure ControleEdicao(const aEditar : Boolean);
    procedure CarregarItens(aPedidoID: TGUID; aPagina: Integer);
    procedure ExcluirPedido(Sender: TObject);
    procedure DuplicarPedido(Sender: TObject);

    procedure FormatarItemPedidoListView(aItem  : TListViewItem);
    procedure AdicionarItemPedidoListView(aPedidoIten : TPedidoItem);

//    procedure AdicionarObservador(Observer : IObservadorPedido);
    procedure RemoverObservador(Observer : IObservadorPedido);
    procedure RemoverTodosObservadores;
    procedure Notificar;

    class var aInstance : TFrmPedido;
  public
    { Public declarations }
    property Dao : TPedidoDao read aDao;

    procedure AdicionarObservador(Observer : IObservadorPedido);
//    procedure RemoverObservador(Observer : IObservadorPedido);
//    procedure RemoverTodosObservadores;
//    procedure Notificar;
//
    class function GetInstance : TFrmPedido;
  end;

  procedure NovoCadastroPedido(Observer : IObservadorPedido);
  procedure ExibirCadastroPedido(Observer : IObservadorPedido);

//var
//  FrmPedido: TFrmPedido;

implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UDM
  , UMensagem
  , UCliente
  , UPedidoItem;

procedure NovoCadastroPedido(Observer : IObservadorPedido);
var
  aForm : TFrmPedido;
begin
  aForm := TFrmPedido.GetInstance;
  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab       := tbsCadastro;
    imageVoltarConsulta.OnClick := imageVoltarClick;

    Model.ID   := GUID_NULL;
    Model.Tipo := TTipoPedido.tpOrcamento;
    Model.DataEmissao := Date;

    labelTituloCadastro.Text      := 'NOVO PEDIDO';
    labelTituloCadastro.TagString := GUIDToString(GUID_NULL); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := 0;                       // Destinado a guardar o CODIGO numérico do registro

    lblCliente.Text      := 'Informe aqui o cliente do novo pedido';
    lblCliente.TagString := GUIDToString(GUID_NULL);
    lblTipo.Text         := GetDescricaoTipoPedidoStr(Model.Tipo); // 'Informe aqui o tipo do novo pedido';
    lblTipo.TagString    := GetTipoPedidoStr(Model.Tipo);
    lblData.Text         := FormatDateTime('dd/mm/yyyy', Dao.Model.DataEmissao);
    lblData.TagString    := 'dd/mm/yyyy';
    lblContato.Text      := 'Informe aqui o(s) contato(s) do novo pedido';
    lblObs.Text          := 'Informe aqui as observações para o novo pedido';

    ListViewItemPedido.BeginUpdate;
    ListViewItemPedido.Items.Clear;
    ListViewItemPedido.EndUpdate;

    lblTotalPedido.TagString := ',0.00';
    lblTotalPedido.Text      := FormatFloat(lblTotalPedido.TagString, 0);

    lblCliente.TagFloat := 0; // Flags: 0 - Sem edição; 1 - Dado editado
    lblTipo.TagFloat    := 0;
    lblData.TagFloat    := 0;
    lblContato.TagFloat := 0;
    lblObs.TagFloat     := 0;
    lblTotalPedido.TagFloat := 0;

    lytExcluir.Visible := False;

    DoMudarAbaPedido(lblAbaDadoPedido);
  end;

  aForm.Show;
end;

procedure ExibirCadastroPedido(Observer : IObservadorPedido);
var
  aForm : TFrmPedido;
begin
  aForm := TFrmPedido.GetInstance;
  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab       := tbsCadastro;
    imageVoltarConsulta.OnClick := imageVoltarClick;

    if (Model.Tipo = TTipoPedido.tpOrcamento) then
      labelTituloCadastro.Text := 'EDITAR PEDIDO'
    else
      labelTituloCadastro.Text := 'PEDIDO #' + FormatFloat('00000', Model.Codigo);

    labelTituloCadastro.TagString := GUIDToString(Model.ID); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro

    lblCliente.Text      := Model.Cliente.Nome + ' - ' + Model.Cliente.CpfCnpj;
    lblCliente.TagString := GUIDToString(Model.Cliente.ID);
    lblTipo.Text         := GetDescricaoTipoPedidoStr(Model.Tipo); // 'Informe aqui o tipo do novo pedido';
    lblTipo.TagString    := GetTipoPedidoStr(Model.Tipo);
    lblData.Text         := FormatDateTime('dd/mm/yyyy', Model.DataEmissao);
    lblData.TagString    := 'dd/mm/yyyy';
    lblContato.Text      := Model.Contato;
    lblObs.Text          := Model.Observacao;

    lblTotalPedido.TagString := ',0.00';
    lblTotalPedido.Text      := FormatFloat(lblTotalPedido.TagString, Model.ValorPedido);

    lblCliente.TagFloat     := IfThen(Trim(Model.Cliente.Nome) = EmptyStr, 0, 1); // Flags: 0 - Sem edição; 1 - Dado editado
    lblTipo.TagFloat        := 0;
    lblData.TagFloat        := 0;
    lblContato.TagFloat     := IfThen(Trim(Model.Contato)    = EmptyStr, 0, 1);
    lblObs.TagFloat         := IfThen(Trim(Model.Observacao) = EmptyStr, 0, 1);
    lblTotalPedido.TagFloat := IfThen(Model.ValorTotal      <= 0.0     , 0, 1);

    lytExcluir.Visible := True;

    DoMudarAbaPedido(lblAbaDadoPedido);
  end;

  aForm.Show;
end;

procedure TFrmPedido.AdicionarItemPedidoListView(aPedidoIten: TPedidoItem);
var
  aItem   : TListViewItem;
  aImage  : TListItemImage;
  aBitmat : TBitmap;
begin
  aItem := ListViewItemPedido.Items.Add;
  aItem.TagObject := aPedidoIten;

  // Foto
  aImage := TListItemImage(aItem.Objects.FindDrawable('Image4'));
  if Assigned(aPedidoIten.Produto.Foto) then
  begin
    aBitmat := TBitmap.Create;
    aBitmat.LoadFromStream(aPedidoIten.Produto.Foto);
    aImage.OwnsBitmap  := True; // Para imagens que vêm da base de dados
    aImage.Bitmap      := aBitmat;
    aImage.ScalingMode := TImageScalingMode.Stretch;
  end
  else
  begin
    aImage.Bitmap      := img_produto_sem_foto.Bitmap;
    aImage.ScalingMode := TImageScalingMode.Original;
  end;

  // Ícone (-)
  aImage := TListItemImage(aItem.Objects.FindDrawable('Image5'));
  aImage.Bitmap      := img_item_menos.Bitmap;
  aImage.ScalingMode := TImageScalingMode.Stretch;

  // Ícone (+)
  aImage := TListItemImage(aItem.Objects.FindDrawable('Image6'));
  aImage.Bitmap      := img_item_mais.Bitmap;
  aImage.ScalingMode := TImageScalingMode.Stretch;

  FormatarItemPedidoListView(aItem);
end;

procedure TFrmPedido.AdicionarObservador(Observer: IObservadorPedido);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

procedure TFrmPedido.AtualizarCliente;
var
  daoCliente : TClienteDao;
begin
  daoCliente := TClienteDao.GetInstance;
  lblCliente.Text      := daoCliente.Model.Nome + ' - ' + daoCliente.Model.CpfCnpj;
  lblCliente.TagString := GUIDToString(daoCliente.Model.ID);
  lblCliente.TagFloat  := 1;
  Dao.Model.Cliente    := daoCliente.Model;
end;

procedure TFrmPedido.AtualizarPedidoItem;
var
  daoItem : TPedidoItemDao;
  aItem   : TListViewItem;
  aItemIndex : Integer;
begin
  daoItem    := TPedidoItemDao.GetInstance;
  aItemIndex := ListViewItemPedido.ItemIndex;

  if (daoItem.Operacao = TTipoOperacaoDao.toIncluido) then
  begin
    AdicionarItemPedidoListView(daoItem.Model);
    ListViewItemPedido.ItemIndex := (ListViewItemPedido.Items.Count - 1);
  end
  else
  if (daoItem.Operacao = TTipoOperacaoDao.toEditado) and (aItemIndex > -1) then
  begin
    aItem := TListViewItem(ListViewItemPedido.Items.Item[aItemIndex]);
    aItem.TagObject := daoItem.Model;
    FormatarItemPedidoListView(aItem);
  end
  else
  if (daoItem.Operacao = TTipoOperacaoDao.toExcluido) and (aItemIndex > -1) then
    ListViewItemPedido.Items.Delete(aItemIndex);

  imgSemItemPedido.Visible := (ListViewItemPedido.Items.Count = 0);

  Dao.RecalcularValorTotalPedido();

  lblTotalPedido.TagFloat := IfThen(Dao.Model.ValorTotal <= 0.0, 0, 1);
  lblTotalPedido.Text     := FormatFloat(lblTotalPedido.TagString, Dao.Model.ValorPedido);

  Self.Notificar;
end;

procedure TFrmPedido.CarregarItens(aPedidoID: TGUID; aPagina: Integer);
var
  daoItem : TPedidoItemDao;
  I : Integer;
begin
  daoItem := TPedidoItemDao.GetInstance;
  daoItem.Load(aPedidoID);
  for I := Low(daoItem.Lista) to High(daoItem.Lista) do
    AdicionarItemPedidoListView(daoItem.Lista[I]);
end;

procedure TFrmPedido.ControleEdicao(const aEditar: Boolean);
begin
  imageSalvarCadastro.Visible := aEditar;
  imageSalvarEdicao.Visible   := aEditar;
end;

procedure TFrmPedido.DoBuscarCliente(Sender: TObject);
begin
  if Dao.Model.Tipo = TTipoPedido.tpOrcamento then
    SelecionarCliente(Self);
end;

procedure TFrmPedido.DoCarregarItens(Sender: TObject);
begin
  try
    imgSemItemPedido.Visible := False;

    ListViewItemPedido.BeginUpdate;
    ListViewItemPedido.Items.Clear;

    CarregarItens(Dao.Model.ID, 0);

    ListViewItemPedido.EndUpdate;
    imgSemItemPedido.Visible := (ListViewItemPedido.Items.Count = 0);
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar carregar os itens do pedido.' + #13 + E.Message);
  end;
end;

procedure TFrmPedido.DoDuplicarPedido(Sender: TObject);
begin
  ExibirMsgConfirmacao('Duplicar', 'Deseja duplicar o pedido selecionado?', DuplicarPedido);
end;

procedure TFrmPedido.DoEditarCampo(Sender: TObject);
var
  aTag : Integer;
begin
  // Propriedade TAG é usada para armazenar as sequencia dos campos no formulário
  if (Sender is TLabel) then
    aTag := TLabel(Sender).Tag
  else
  if (Sender is TImage) then
    aTag := TImage(Sender).Tag
  else
    aTag := 0;

  layoutEditCampo.Visible  := False;
  layoutDataCampo.Visible  := False;
  layoutMemoCampo.Visible  := False;
  layoutValorCampo.Visible := False;

  Case aTag of
    2 : // Data
      begin
        layoutDataCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelData.Text);
        labelTituloEditar.TagString := EmptyStr;
        labelTituloEditar.TagString := '*'; // Campo obrigatório

        editDateCampo.DateTime  := StrToDate('dd/mm/yyyy', lblData.Text);
        editDateCampo.TagString := EmptyStr;
        editDateCampo.TagObject := TObject(lblData);
      end;

    3 : // Contato(s)
      begin
        layoutMemoCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelContato.Text);
        labelTituloEditar.TagString := EmptyStr;
        labelTituloEditar.TagString := '*'; // Campo obrigatório

        mmMemoCampo.Text         := IfThen(lblContato.TagFloat = 0, EmptyStr, lblContato.Text);
        mmMemoCampo.MaxLength    := 100;
        mmMemoCampo.TextAlign    := TTextAlign.Leading;
        mmMemoCampo.KeyboardType := TVirtualKeyboardType.Default;
        mmMemoCampo.TagString    := EmptyStr;
        mmMemoCampo.TagObject    := TObject(lblContato);
      end;

    4 : // Observações
      begin
        layoutMemoCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelObs.Text);
        labelTituloEditar.TagString := EmptyStr;

        mmMemoCampo.Text         := IfThen(lblObs.TagFloat = 0, EmptyStr, lblObs.Text);
        mmMemoCampo.MaxLength    := 500;
        mmMemoCampo.TextAlign    := TTextAlign.Leading;
        mmMemoCampo.KeyboardType := TVirtualKeyboardType.Default;
        mmMemoCampo.TagString    := EmptyStr;
        mmMemoCampo.TagObject    := TObject(lblObs);
      end;
  End;

  ChangeTabActionEditar.ExecuteTarget(Sender);
end;

procedure TFrmPedido.DoExcluirPedido(Sender: TObject);
begin
  ExibirMsgConfirmacao('Excluir', 'Deseja excluir o pedido selecionado?', ExcluirPedido);
end;

procedure TFrmPedido.DoInserirItemPedido(Sender: TObject);
begin
  if (lblCliente.TagFloat = 0) then
    ExibirMsgAlerta('Selecione um cliente para que o orçamento antes de inserir um item')
  else
  begin
    if (dao.Model.ID = GUID_NULL) then
    begin
      dao.Insert();
      Self.Notificar;

      labelTituloCadastro.TagString := GUIDToString(dao.Model.ID); // Destinado a guardar o ID guid do registro
      labelTituloCadastro.TagFloat  := dao.Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro
    end;

    NovoItemPedido(dao.Model, Self);
  end;
end;

procedure TFrmPedido.DoMudarAbaPedido(Sender: TObject);
begin
  LayoutDadoPedido.Visible := (Sender = lblAbaDadoPedido);
  LayoutItemPedido.Visible := (Sender = lblAbaItemPedido);

  if (LayoutDadoPedido.Visible) then
  begin
    recAbaDadoPedido.Opacity   := 1;
    recAbaDadoPedido.Fill.Color:= crAzul;
    lblAbaDadoPedido.FontColor := crBranco;
    recAbaItemPedido.Opacity   := 0.5;
    recAbaItemPedido.Fill.Color:= crCinzaClaro;
    lblAbaItemPedido.FontColor := crCinzaEscuro;
  end
  else
  if (LayoutItemPedido.Visible) then
  begin
    recAbaDadoPedido.Opacity   := 0.5;
    recAbaDadoPedido.Fill.Color:= crCinzaClaro;
    lblAbaDadoPedido.FontColor := crCinzaEscuro;
    recAbaItemPedido.Opacity   := 1;
    recAbaItemPedido.Fill.Color:= crAzul;
    lblAbaItemPedido.FontColor := crBranco;

    DoCarregarItens(Sender);
  end;

end;

procedure TFrmPedido.DoSalvarPedido(Sender: TObject);
var
  ins : Boolean;
  inf : Extended;
begin
  try
    inf :=
      lblCliente.TagFloat  +
//      lblTipo.TagFloat     +
//      lblData.TagFloat     +
      lblContato.TagFloat  +
      lblObs.TagFloat      +
      lblTotalPedido.TagFloat;

    if (inf = 0) then
      ExibirMsgAlerta('Sem dados informados!')
    else
    if (lblCliente.TagFloat = 0) or (Trim(lblCliente.Text) = EmptyStr) then
      ExibirMsgAlerta('Selecione um cliente para o pedido!')
    else
    if (lblTotalPedido.TagFloat = 0) then
      ExibirMsgAlerta('Pedido não possuem itens!')
    else
    begin
      dao.Model.ID     := StringToGUID(labelTituloCadastro.TagString);
      dao.Model.Codigo := labelTituloCadastro.TagFloat;

      dao.Model.Cliente.ID   := StringToGUID( IfThen(lblCliente.TagFloat  = 0, GUIDToString(GUID_NULL), lblCliente.TagString) );  // Postar dados na classe caso ele tenha sido editado
      dao.Model.Tipo         := GetTipoPedido(lblTipo.TagString);
      dao.Model.DataEmissao  := StrToDate(lblData.TagString, lblData.Text);
      dao.Model.Contato      := IfThen(lblContato.TagFloat   = 0, EmptyStr, lblContato.Text);
      dao.Model.Observacao   := IfThen(lblObs.TagFloat       = 0, EmptyStr, lblObs.Text);

      if (lblTotalPedido.TagFloat = 0) then
        dao.Model.ValorPedido := 0.0
      else
        dao.Model.ValorPedido := StrToCurr(lblTotalPedido.Text.Replace('.', '').Replace(',', '')) / 100;

      ins := (dao.Model.ID = GUID_NULL);

      if ins then
        dao.Insert()
      else
        dao.Update();

      Self.Notificar;
      Self.Close;
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar salvar o pedido.' + #13 + E.Message);
  end;
end;

procedure TFrmPedido.DuplicarPedido(Sender: TObject);
var
  daoItem : TPedidoItemDao;
  msg : TFrmMensagem;
  I : Integer;
  aPedidoID : TGUID;
begin
  try
    msg := TFrmMensagem.GetInstance;
    msg.Close;

    if Assigned(dao.Model) then
    begin
      aPedidoID := dao.Model.ID;

      // Preparar para duplicação do Pedido
      dao.Model.ID     := GUID_NULL;
      dao.Model.Codigo := 0;
      dao.Model.Tipo   := TTipoPedido.tpOrcamento;
      dao.Model.Entregue    := False;
      dao.Model.DataEmissao := Date;

      dao.Insert(); // Inserir novo pedido

      // Guarda referências do novo pedido
      labelTituloCadastro.TagString := GUIDToString(dao.Model.ID); // Destinado a guardar o ID guid do registro
      labelTituloCadastro.TagFloat  := dao.Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro
      lblTipo.Text      := GetDescricaoTipoPedidoStr(dao.Model.Tipo);
      lblTipo.TagString := GetTipoPedidoStr(dao.Model.Tipo);
      lblData.Text      := FormatDateTime('dd/mm/yyyy', Dao.Model.DataEmissao);

      daoItem := TPedidoItemDao.GetInstance;
      daoItem.Load(aPedidoID);

      for I := Low(daoItem.Lista) to High(daoItem.Lista) do
      begin
        daoItem.Model := daoItem.Lista[I];
        daoItem.Model.ID         := GUID_NULL;
        daoItem.Model.Pedido     := Dao.Model;
        daoItem.Model.Referencia := GUID_NULL;
        daoItem.Insert();
      end;

      Self.Notificar;
      CarregarItens(dao.Model.ID, 0);

      ExibirMsgSucesso('Pedido duplicado com sucesso');
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar duplicar o pedido.' + #13 + E.Message);
  end;
end;

procedure TFrmPedido.ExcluirPedido(Sender: TObject);
var
  msg : TFrmMensagem;
begin
  try
    msg := TFrmMensagem.GetInstance;
    if Assigned(dao.Model) then
    begin
      msg.Close;
      if dao.PodeExcluir then
      begin
        dao.Delete();
        Self.Notificar;
        Self.Close;
      end
      else
        ExibirMsgAlerta('Pedido não pode ser excluído por já ter sido entregue');
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar excluir o pedido.' + #13 + E.Message);
  end;
end;

procedure TFrmPedido.FormActivate(Sender: TObject);
begin
  inherited;
  ControleEdicao( (Dao.Model.Tipo = TTipoPedido.tpOrcamento) );
end;

procedure TFrmPedido.FormatarItemPedidoListView(aItem: TListViewItem);
var
  aPedidoItem : TPedidoItem;
  aText    : TListItemText;
//  aImage   : TListItemImage;
//  aBitmat  : TBitmap;
begin
  with aItem do
  begin
    aPedidoItem := TPedidoItem(aItem.TagObject);

    // Descrição
    aText := TListItemText(Objects.FindDrawable('Text2'));
    aText.Text     := aPedidoItem.Produto.Descricao;
    aText.WordWrap := True;

    // Valor Unitário (R$)
    aText := TListItemText(Objects.FindDrawable('Text1'));
    aText.Text := 'R$ ' + FormatFloat(',0.00', aPedidoItem.Produto.Valor);

    // Quantidade
    aText := TListItemText(Objects.FindDrawable('Text7'));
    aText.Text := FormatFloat(',0.###', aPedidoItem.Quantidade);

    // Total Líquido (R$)
    aText := TListItemText(Objects.FindDrawable('Text4'));
    aText.Text := 'R$ ' + FormatFloat(',0.00', aPedidoItem.ValorLiquido);
//
//    // Foto
//    aImage := TListItemImage(Objects.FindDrawable('Image4'));
//    if Assigned(aPedidoItem.Produto.Foto) then
//    begin
//      aBitmat := TBitmap.Create;
//      aBitmat.LoadFromStream(aPedidoItem.Produto.Foto);
//      aImage.OwnsBitmap  := True;
//      aImage.Bitmap      := aBitmat;
//      aImage.ScalingMode := TImageScalingMode.Stretch;
//    end
//    else
//    begin
//      aImage.Bitmap      := img_produto_sem_foto.Bitmap;
//      aImage.ScalingMode := TImageScalingMode.Original;
//    end;
  end;
end;

procedure TFrmPedido.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
//  if (lblTotalPedido.TagFloat = 0) then
//    if (Dao.Model.ID <> GUID_NULL) then
//      Dao.Delete();
//
//  Self.Notificar;
  RemoverTodosObservadores;
end;

procedure TFrmPedido.FormCreate(Sender: TObject);
begin
  inherited;
  FObservers := TList<IObservadorPedido>.Create;

  lytExcluir.Visible := False;
  lytExcluir.Align   := TAlignLayout.Bottom;
  lytExcluir.Parent  := LayoutDadoPedido;

  lblDuplicar.Margins.Bottom := 0;
  lblDuplicar.Margins.Top    := 60;
  lblExcluir.Margins.Bottom  := 0;
  lblExcluir.Margins.Top     := 60;

  img_produto_sem_foto.Visible := False;
  img_item_mais.Visible  := False;
  img_item_menos.Visible := False;

  imgTipo.Visible := False;
  lblTipo.Margins.Right := imgTipo.Margins.Right + imgTipo.Width;
end;

class function TFrmPedido.GetInstance: TFrmPedido;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmPedido, aInstance);
    Application.RealCreateForms;
  end;

  if not Assigned(aInstance.FObservers) then
    aInstance.FObservers := TList<IObservadorPedido>.Create;

  aInstance.aDao := TPedidoDao.GetInstance;

  Result := aInstance;
end;

procedure TFrmPedido.imgClienteClick(Sender: TObject);
var
  daoCliente : TClienteDao;
begin
  if (lblCliente.TagFloat = 1) then
  begin
    daoCliente := TClienteDao.GetInstance;
    daoCliente.Load(lblCliente.TagString);
    daoCliente.Model := daoCliente.Lista[0];
    ExibirCadastroCliente(Self, False);
  end;
end;

procedure TFrmPedido.ListViewItemPedidoItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  aItem   : TListViewItem;
  daoItem : TPedidoItemDao;
begin
  if (TListView(Sender).Selected <> nil) then
  begin
    daoItem := TPedidoItemDao.GetInstance;
    daoItem.Model := TPedidoItem(ListViewItemPedido.Items.Item[ItemIndex].TagObject);

    if ItemObject is TListItemImage then
    begin
      // Ícone (-)
      if (TListItemImage(ItemObject).Name = 'Image5') then
        daoItem.DecrementarQuantidade
      else
      // Ícone (+)
      if (TListItemImage(ItemObject).Name = 'Image6') then
        daoItem.IncrementarQuantidade;

      daoItem.Update();
      dao.RecalcularValorTotalPedido();

      lblTotalPedido.Text     := FormatFloat(lblTotalPedido.TagString, dao.Model.ValorPedido);
      lblTotalPedido.TagFloat := IfThen(dao.Model.ValorTotal <= 0.0, 0, 1);

      aItem := TListViewItem(ListViewItemPedido.Items.Item[ListViewItemPedido.ItemIndex]);
      aItem.TagObject := daoItem.Model;

      FormatarItemPedidoListView(aItem);
      Self.Notificar;
    end
    else
      EditarItemPedido(Dao.Model, Self);
  end;
end;

procedure TFrmPedido.Notificar;
var
  Observer : IObservadorPedido;
begin
  for Observer in FObservers do
     Observer.AtualizarPedido;
end;

procedure TFrmPedido.RemoverObservador(Observer: IObservadorPedido);
begin
  FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmPedido.RemoverTodosObservadores;
var
  I : Integer;
begin
  for I := 0 to (FObservers.Count - 1) do
    FObservers.Delete(I);
end;

end.
