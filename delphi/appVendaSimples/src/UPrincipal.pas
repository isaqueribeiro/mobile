unit UPrincipal;

interface

uses
  model.Pedido,
  model.Cliente,
  dao.Pedido,
  dao.Cliente,

  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFrmPrincipal = class(TForm)
    StyleBook: TStyleBook;
    layoutTabs: TLayout;
    layoutTabPedido: TLayout;
    layoutTabCliente: TLayout;
    layoutTabNotificacao: TLayout;
    layoutTabMais: TLayout;
    labelTabPedido: TLabel;
    imageTabPedido: TImage;
    labelTabCliente: TLabel;
    imageTabCliente: TImage;
    labelTabNotificacao: TLabel;
    imageTabNotificacao: TImage;
    labelTabMais: TLabel;
    imageTabMais: TImage;
    circleNotification: TCircle;
    labelNotification: TLabel;
    TabPedido: TLayout;
    rectangleTituloPedido: TRectangle;
    layoutBuscaPedido: TLayout;
    rectangleBuscaPedido: TRectangle;
    editBuscaPedido: TEdit;
    ListViewPedido: TListView;
    labelTituloPedido: TLabel;
    imageAddPedido: TImage;
    imageBuscaPedido: TImage;
    TabCliente: TLayout;
    rectangleTituloCliente: TRectangle;
    labelTituloCliente: TLabel;
    imageAddCliente: TImage;
    layoutBuscaCliente: TLayout;
    rectangleBuscaCliente: TRectangle;
    editBuscaCliente: TEdit;
    imageBuscaCliente: TImage;
    ListViewCliente: TListView;
    TabNotificacao: TLayout;
    rectangleTituloNotificacao: TRectangle;
    labelTituloNotificacao: TLabel;
    ListViewNotificacao: TListView;
    TabMais: TLayout;
    rectangleTituloMais: TRectangle;
    labelTituloMais: TLabel;
    layoutMaisOpcoes: TLayout;
    layoutMaisOpcoesL1: TLayout;
    imageProduto: TImage;
    labelProduto: TLabel;
    imageSincronizar: TImage;
    labelSincronizar: TLabel;
    layoutMaisOpcoesL2: TLayout;
    imageMeuPerfil: TImage;
    labelMeuPerfil: TLabel;
    imageIndicarApp: TImage;
    labelIndicarApp: TLabel;
    layoutMaisOpcoesL3: TLayout;
    imageSair: TImage;
    labelSair: TLabel;
    img_entregue: TImage;
    img_sinc: TImage;
    img_nao_sinc: TImage;
    layoutSemPedido: TLayout;
    Image1: TImage;
    Label1: TLabel;
    img_lida: TImage;
    img_nao_lida: TImage;
    procedure DoFecharApp(Sender: TObject);
    procedure DoSelecinarTab(Sender: TObject);
    procedure DoBuscaPedidos(Sender: TObject);
    procedure DoBuscaClientes(Sender: TObject);

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imageAddPedidoClick(Sender: TObject);
  private
    { Private declarations }
    procedure DefinirIndices;
    procedure SelecionarTab(const aTab : Smallint);
    procedure BuscarPedidos(aBusca : String; aPagina : Integer);
    procedure BuscarClientes(aBusca : String; aPagina : Integer);
    procedure AddPedidoListView(aPedido : TPedido);
    procedure AddClienteListView(aCliente : TCliente);
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

const
  idxTabPedido      = 1;
  idxTabCliente     = 2;
  idxTabNotificacao = 3;
  idxTabMais        = 4;

implementation

{$R *.fmx}

uses
  UConstantes,
    UMensagem;

{ TFrmPrincipal }

procedure TFrmPrincipal.AddClienteListView(aCliente : TCliente);
var
  aItem  : TListViewItem;
  aText  : TListItemText;
  aImage : TListItemImage;
begin
  aItem := ListViewCliente.Items.Add;
  with aItem do
  begin
    aItem.Data['cliente'] := aCliente;

    TListItemText(Objects.FindDrawable('Text1')).Text := aCliente.Nome;
    TListItemText(Objects.FindDrawable('Text2')).Text := IfThen(Trim(aCliente.Endereco) = EmptyStr, '* SEM ENDEREÇO INFORMADO!', Trim(aCliente.Endereco));
    if (aCliente.DataUltimaCompra <> StrToDate(EMPTY_DATE)) then
    begin
      TListItemText(Objects.FindDrawable('Text3')).Text :=
        '** Última Compra : ' + FormatDateTime('dd/mm/yyyy', aCliente.DataUltimaCompra) + ', ' +
        'R$ ' + FormatFloat(',0.00', aCliente.ValorUltimaCompra);
    end
    else
      TListItemText(Objects.FindDrawable('Text3')).Text := '**';

    // Status
    aImage := TListItemImage(Objects.FindDrawable('Image4'));
    if aCliente.Ativo then
      aImage.Bitmap := img_sinc.Bitmap
    else
      aImage.Bitmap := img_nao_sinc.Bitmap;
  end;
end;

procedure TFrmPrincipal.AddPedidoListView(aPedido: TPedido);
var
  aItem  : TListViewItem;
  aText  : TListItemText;
  aImage : TListItemImage;
begin
  aItem := ListViewPedido.Items.Add;
  with aItem do
  begin
    aItem.Data['pedido'] := aPedido;

    // Número
    aText := TListItemText(Objects.FindDrawable('Text1'));
    aText.Text := aPedido.ToString;
    // Cliente
    aText := TListItemText(Objects.FindDrawable('Text2'));
    aText.Text := aPedido.Cliente.Nome;
    // Data
    aText := TListItemText(Objects.FindDrawable('Text3'));
    aText.Text := FormatDateTime('dd/mm/yyyy', aPedido.DataEmissao);
    // Valor
    aText := TListItemText(Objects.FindDrawable('Text4'));
    aText.Text := 'R$ ' +  FormatFloat(',0.00', aPedido.ValorPedido);

    // Entregue
    aImage := TListItemImage(Objects.FindDrawable('Image6'));
    if aPedido.Entregue then
      aImage.Bitmap := img_entregue.Bitmap
    else
      aImage.Visible := False;

    // Sincronizado
    aImage := TListItemImage(Objects.FindDrawable('Image5'));
    if aPedido.Sincronizado then
      aImage.Bitmap := img_sinc.Bitmap
    else
      aImage.Bitmap := img_nao_sinc.Bitmap;
  end;
end;

procedure TFrmPrincipal.BuscarClientes(aBusca: String; aPagina: Integer);
var
  dao : TClienteDao;
  I : Integer;
begin
  dao := TClienteDao.GetInstance;
  dao.Load(aBusca);
  for I := Low(dao.Lista) to High(dao.Lista) do
    AddClienteListView(dao.Lista[I]);
end;

procedure TFrmPrincipal.BuscarPedidos(aBusca: String; aPagina: Integer);
var
  dao : TPedidoDao;
  I : Integer;
begin
  dao := TPedidoDao.GetInstance;
  dao.Load(aBusca);
  for I := Low(dao.Lista) to High(dao.Lista) do
    AddPedidoListView(dao.Lista[I]);
end;

procedure TFrmPrincipal.DefinirIndices;
begin
  imageTabPedido.Tag  := idxTabPedido;
  labelTabPedido.Tag  := idxTabPedido;
  imageTabCliente.Tag := idxTabCliente;
  labelTabCliente.Tag := idxTabCliente;
  imageTabNotificacao.Tag := idxTabNotificacao;
  labelTabNotificacao.Tag := idxTabNotificacao;
  imageTabMais.Tag := idxTabMais;
  labelTabMais.Tag := idxTabMais;
end;

procedure TFrmPrincipal.DoBuscaClientes(Sender: TObject);
begin
  try
    ListViewCliente.BeginUpdate;
    ListViewCliente.Items.Clear;

    BuscarClientes(editBuscaCliente.Text, 0);

    ListViewCliente.EndUpdate;
    ListViewCliente.Visible  := (ListViewCliente.Items.Count > 0);
    //layoutSemCliente.Visible := not ListViewCliente.Visible;
  except
    On E : Exception do
      ExibirMsgErro(E.Message);
  end;
end;

procedure TFrmPrincipal.DoBuscaPedidos(Sender: TObject);
begin
  try
    ListViewPedido.BeginUpdate;
    ListViewPedido.Items.Clear;

    BuscarPedidos(editBuscaPedido.Text, 0);

    ListViewPedido.EndUpdate;
    ListViewPedido.Visible  := (ListViewPedido.Items.Count > 0);
    layoutSemPedido.Visible := not ListViewPedido.Visible;
  except
    On E : Exception do
      ExibirMsgErro(E.Message);
  end;
end;

procedure TFrmPrincipal.DoFecharApp(Sender: TObject);
begin
  if ExibirMsgConfirmacao('Fechar', 'Deseja encerrar o aplicativo?') then
    Halt(0);
end;

procedure TFrmPrincipal.DoSelecinarTab(Sender: TObject);
var
  aTab : Smallint;
begin
  aTab := idxTabPedido;

  if Sender is TImage then
    aTab := TImage(Sender).Tag
  else
  if Sender is TLabel then
    aTab := TLabel(Sender).Tag;

  SelecionarTab(aTab);
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  DefinirIndices;

  img_entregue.Visible := False;
  img_sinc.Visible     := False;
  img_nao_sinc.Visible := False;
  img_lida.Visible     := False;
  img_nao_lida.Visible := False;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  SelecionarTab(idxTabPedido);
end;

procedure TFrmPrincipal.imageAddPedidoClick(Sender: TObject);
begin
  // Para teste
  AddPedidoListView(TPedido.Create);
end;

procedure TFrmPrincipal.SelecionarTab(const aTab: Smallint);
begin
  imageTabPedido.Opacity      := vlOpacityIcon;
  imageTabCliente.Opacity     := vlOpacityIcon;
  imageTabNotificacao.Opacity := vlOpacityIcon;
  imageTabMais.Opacity        := vlOpacityIcon;

  labelTabPedido.FontColor      := crCinza;
  labelTabCliente.FontColor     := crCinza;
  labelTabNotificacao.FontColor := crCinza;
  labelTabMais.FontColor        := crCinza;

  TabPedido.Visible      := (aTab = idxTabPedido);
  TabCliente.Visible     := (aTab = idxTabCliente);
  TabNotificacao.Visible := (aTab = idxTabNotificacao);
  TabMais.Visible        := (aTab = idxTabMais);

  Case aTab of
    idxTabPedido :
      begin
        DoBuscaPedidos(nil);
        imageTabPedido.Opacity   := 1;
        labelTabPedido.FontColor := crAzul;
      end;
    idxTabCliente :
      begin
        DoBuscaClientes(nil);
        imageTabCliente.Opacity   := 1;
        labelTabCliente.FontColor := crAzul;
      end;
    idxTabNotificacao :
      begin
        imageTabNotificacao.Opacity   := 1;
        labelTabNotificacao.FontColor := crAzul;
      end;
    idxTabMais :
      begin
        imageTabMais.Opacity   := 1;
        labelTabMais.FontColor := crAzul;
      end;
  end;
end;

end.
