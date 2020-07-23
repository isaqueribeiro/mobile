unit UPedido;

interface

uses
  System.StrUtils,
  System.SysUtils,
  System.Math,
  System.DateUtils,
  System.Generics.Collections,

  model.Cliente,
  model.Pedido,
  model.PedidoItem,
  dao.Pedido,
  dao.PedidoItem,
  dao.Cliente,
  dao.Configuracao,
  dao.Loja,
  interfaces.Cliente,
  interfaces.Loja,
  interfaces.PedidoItem,
  interfaces.Pedido,

  System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.DateTimeCtrls;

type
  TFrmPedido = class(TFrmPadraoCadastro, IObservadorLoja, IObservadorCliente, IObservadorPedidoItem, IPedidoObservado)
    imgDuplicar: TImage;
    lblDuplicar: TLabel;
    lytAbaPedido: TLayout;
    recAbaDadoPedido: TRectangle;
    lblAbaDadoPedido: TLabel;
    recAbaItemPedido: TRectangle;
    lblAbaItemPedido: TLabel;
    LayoutItemPedido: TLayout;
    lineItem: TLine;
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
    img_item_excluir: TImage;
    LayoutDadoPedido: TLayout;
    lytTipo: TLayout;
    lineTipo: TLine;
    LabelTipo: TLabel;
    imgTipo: TImage;
    lblTipo: TLabel;
    LayoutCliente: TLayout;
    recCliente: TRectangle;
    lytCliente: TLayout;
    LabelCliente: TLabel;
    imgCliente: TImage;
    lblCliente: TLabel;
    iconCliente: TImage;
    lineCliente: TLine;
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
    LayoutLoja: TLayout;
    recLoja: TRectangle;
    lytLoja: TLayout;
    LabelLoja: TLabel;
    imgLoja: TImage;
    lblLoja: TLabel;
    iconLoja: TImage;
    lineLoja: TLine;
    procedure DoMudarAbaPedido(Sender: TObject);
    procedure DoBuscarCliente(Sender: TObject);
    procedure DoBuscarLoja(Sender: TObject);
    procedure DoEditarCampo(Sender: TObject);
    procedure DoSalvarPedido(Sender: TObject);
    procedure DoExcluirPedido(Sender: TObject);
    procedure DoDuplicarPedido(Sender: TObject);
    procedure DoInserirItemPedido(Sender: TObject);
    procedure DoCarregarItens(Sender: TObject);
    procedure DoExcluirItem(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure imgClienteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListViewItemPedidoItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure imgLojaClick(Sender: TObject);
  strict private
    { Private declarations }
    aDao : TPedidoDao;
    FObservers : TList<IObservadorPedido>;

    procedure AtualizarLoja;
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
  , ULoja
  , UCliente
  , UPedidoItem;

procedure NovoCadastroPedido(Observer : IObservadorPedido);
var
  aLojaID : String;
  aLoja : TLojaDao;
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

    aLojaID := TConfiguracaoDao.GetInstance().GetValue('empresa_padrao');
    if (aLojaID.Trim <> EmptyStr) then
    begin
      aLoja := TLojaDao.GetInstance();
      aLoja.Find(aLojaID, True);
      Model.Loja := aLoja.Model;
    end;

    labelTituloCadastro.Text      := 'NOVO PEDIDO';
    labelTituloCadastro.TagString := GUIDToString(GUID_NULL); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := 0;                       // Destinado a guardar o CODIGO numérico do registro

    lblLoja.Text      := Model.Loja.Fantasia + ' - ' + Model.Loja.CpfCnpj;
    lblLoja.TagString := GUIDToString(Model.Loja.ID);
    lblLoja.TagFloat  := IfThen(Model.Loja.ID = GUID_NULL, 0, 1);

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

    dao.InserirItensTemp();
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
      labelTituloCadastro.Text := 'PEDIDO #' + IfThen(Model.Numero.Trim = EmptyStr, FormatFloat('00000', Model.Codigo), Model.Numero);

    labelTituloCadastro.TagString := GUIDToString(Model.ID); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro

    lblLoja.Text      := Model.Loja.Fantasia + ' - ' + Model.Loja.CpfCnpj;
    lblLoja.TagString := GUIDToString(Model.Loja.ID);
    lblLoja.TagFloat  := IfThen(Model.Loja.ID = GUID_NULL, 0, 1);

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

    dao.InserirItensTemp();
    DoMudarAbaPedido(lblAbaDadoPedido);
    DoCarregarItens(nil);
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
    //aBitmat.LoadFromStream(aPedidoIten.Produto.Foto);
    aBitmat.Assign( aPedidoIten.Produto.Foto );
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

  // Excluir
  aImage := TListItemImage(aItem.Objects.FindDrawable('Image8'));
  aImage.Bitmap      := img_item_excluir.Bitmap;
  aImage.ScalingMode := TImageScalingMode.Stretch;
  aImage.Visible     := not Dao.Model.Entregue;

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

procedure TFrmPedido.AtualizarLoja;
var
  daoLoja : TLojaDao;
begin
  daoLoja := TLojaDao.GetInstance;
  lblLoja.Text      := daoLoja.Model.Fantasia + ' - ' + daoLoja.Model.CpfCnpj;
  lblLoja.TagString := GUIDToString(daoLOja.Model.ID);
  lblLoja.TagFloat  := 1;
  Dao.Model.Loja    := daoLoja.Model;
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

  dao.CalcularValorTotalPedidoTemp();

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
  recInserirItem.Visible      := aEditar;
end;

procedure TFrmPedido.DoBuscarCliente(Sender: TObject);
begin
  if Dao.Model.Tipo = TTipoPedido.tpOrcamento then
    SelecionarCliente(Self);
end;

procedure TFrmPedido.DoBuscarLoja(Sender: TObject);
begin
  if Dao.Model.Tipo = TTipoPedido.tpOrcamento then
    SelecionarLoja(Self);
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
  if (dao.Model.Tipo = TTipoPedido.tpPedido) then
    Exit;

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
    3 : // Data
      begin
        layoutDataCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelData.Text);
        labelTituloEditar.TagString := EmptyStr;
        labelTituloEditar.TagString := '*'; // Campo obrigatório

        editDateCampo.DateTime  := StrToDateLocal('dd/mm/yyyy', lblData.Text);
        editDateCampo.TagString := EmptyStr;
        editDateCampo.TagObject := TObject(lblData);
      end;

    4 : // Contato(s)
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

    5 : // Observações
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

procedure TFrmPedido.DoExcluirItem(Sender: TObject);
var
  aMsg  : TFrmMensagem;
  aItem : TPedidoItemDao;
begin
  aMsg  := TFrmMensagem.GetInstance;
  aMsg.Close;

  aItem := TPedidoItemDao.GetInstance;
  if not dao.Model.Entregue then
  begin
    aItem.Delete();
    ListViewItemPedido.Items.Delete(ListViewItemPedido.ItemIndex);

    dao.CalcularValorTotalPedidoTemp();

    lblTotalPedido.Text     := FormatFloat(lblTotalPedido.TagString, dao.Model.ValorPedido);
    lblTotalPedido.TagFloat := IfThen(dao.Model.ValorTotal <= 0.0, 0, 1);
  end;
end;

procedure TFrmPedido.DoExcluirPedido(Sender: TObject);
begin
  ExibirMsgConfirmacao('Excluir', 'Deseja excluir o pedido selecionado?', ExcluirPedido);
end;

procedure TFrmPedido.DoInserirItemPedido(Sender: TObject);
begin
  NovoItemPedido(dao.Model, Self);
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
    if (ListViewItemPedido.Items.Count = 0) then
      ExibirMsgAlerta('Pedido não possuem produto(s)!')
    else
    begin
      dao.Model.ID     := StringToGUID(labelTituloCadastro.TagString);
      dao.Model.Codigo := labelTituloCadastro.TagFloat;

      dao.Model.Cliente.ID   := StringToGUID( IfThen(lblCliente.TagFloat  = 0, GUIDToString(GUID_NULL), lblCliente.TagString) );  // Postar dados na classe caso ele tenha sido editado
      dao.Model.Tipo         := GetTipoPedido(lblTipo.TagString);
      dao.Model.DataEmissao  := StrToDateLocal(lblData.TagString, lblData.Text);
      dao.Model.Contato      := IfThen(lblContato.TagFloat   = 0, EmptyStr, lblContato.Text);
      dao.Model.Observacao   := IfThen(lblObs.TagFloat       = 0, EmptyStr, lblObs.Text);

      if (lblTotalPedido.TagFloat = 0) then
        dao.Model.ValorPedido := 0.0
      else
        dao.Model.ValorPedido := StrToCurr(lblTotalPedido.Text.Replace('.', '').Replace(',', '')) / 100;

      ins := (dao.Model.ID = GUID_NULL);

      if ins then
      begin
        dao.Insert();
        Self.Notificar; // Notifica inserção
      end
      else
        dao.Update();

      dao.GravarItens();
      dao.RecalcularValorTotalPedido();

      Self.Notificar; // Notifica atualizãção de valores
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

      // Guarda referências do novo pedido
      labelTituloCadastro.Text      := 'NOVO PEDIDO';
      labelTituloCadastro.TagString := GUIDToString(dao.Model.ID); // Destinado a guardar o ID guid do registro
      labelTituloCadastro.TagFloat  := dao.Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro
      lblTipo.Text      := GetDescricaoTipoPedidoStr(dao.Model.Tipo);
      lblTipo.TagString := GetTipoPedidoStr(dao.Model.Tipo);
      lblData.Text      := FormatDateTime('dd/mm/yyyy', Dao.Model.DataEmissao);

      daoItem := TPedidoItemDao.GetInstance;
      daoItem.DeleteAllTemp();

      for I := Low(daoItem.Lista) to High(daoItem.Lista) do
      begin
        daoItem.Model := daoItem.Lista[I];
        daoItem.Model.ID         := GUID_NULL;
        daoItem.Model.Pedido     := Dao.Model;
        daoItem.Model.Referencia := GUID_NULL;
        daoItem.Insert();
      end;

      lytExcluir.Visible := False;
      DoCarregarItens(Sender);

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
    aText.Text := 'R$ ' + FormatFloat(',0.00', IfThen(aPedidoItem.ValorUnitario > 0, aPedidoItem.ValorUnitario, aPedidoItem.Produto.Valor));

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
  img_item_mais.Visible    := False;
  img_item_menos.Visible   := False;
  img_item_excluir.Visible := False;

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

procedure TFrmPedido.imgLojaClick(Sender: TObject);
var
  daoLoja : TLojaDao;
begin
  if (lblLoja.TagFloat = 1) then
  begin
    daoLoja := TLojaDao.GetInstance();
    daoLoja.Find(lblLoja.TagString, True);
    ExibirCadastroLoja(Self, False);
  end;
end;

procedure TFrmPedido.ListViewItemPedidoItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  aItem   : TListViewItem;
  daoItem : TPedidoItemDao;
  aImagem ,
  aIcone  : String;
begin
  if (TListView(Sender).Selected <> nil) and (Dao.Model.Tipo = TTipoPedido.tpOrcamento) then
  begin
    aIcone  := EmptyStr;
    aImagem := EmptyStr;
    daoItem := TPedidoItemDao.GetInstance;
    daoItem.Model := TPedidoItem(ListViewItemPedido.Items.Item[ItemIndex].TagObject);

    if ItemObject is TListItemImage then
    begin
      // Recuperar o nome do objeto clicado
      aImagem := TListItemImage(ItemObject).Name;

      // Foto do produto
      if (aImagem = 'Image4') then
        EditarItemPedido(Dao.Model, Self, (dao.Model.Tipo = TTipoPedido.tpOrcamento))
      else
      begin
        // Excluir
        if (aImagem = 'Image8') then
        begin
          if Dao.Model.Entregue then
            ExibirMsgAlerta('Produto não poderá ser excluído porque o pedido já foi entregue.')
          else
            ExibirMsgConfirmacao('Excluir', 'Confirma a exclusão do produto?', DoExcluirItem);
        end
        else
        // Ícone (-)
        if (aImagem = 'Image5') then
        begin
          aIcone := 'icone_menos';
          daoItem.DecrementarQuantidade;
        end
        else
        // Ícone (+)
        if (aImagem = 'Image6') then
        begin
          aIcone := 'icone_mais';
          daoItem.IncrementarQuantidade;
        end;

        if ((aIcone = 'icone_menos') or (aIcone = 'icone_mais')) then
        begin
          daoItem.Update();

          aItem := TListViewItem(ListViewItemPedido.Items.Item[ListViewItemPedido.ItemIndex]);
          aItem.TagObject := daoItem.Model;

          dao.CalcularValorTotalPedidoTemp();

          lblTotalPedido.Text     := FormatFloat(lblTotalPedido.TagString, dao.Model.ValorPedido);
          lblTotalPedido.TagFloat := IfThen(dao.Model.ValorTotal <= 0.0, 0, 1);

          FormatarItemPedidoListView(aItem);
        end;
      end;
    end
    else
      EditarItemPedido(Dao.Model, Self, (dao.Model.Tipo = TTipoPedido.tpOrcamento));
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
