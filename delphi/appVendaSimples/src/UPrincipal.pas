unit UPrincipal;

interface

uses
  model.Pedido,
  dao.Pedido,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
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
    procedure DoFecharApp(Sender: TObject);
    procedure DoSelecinarTab(Sender: TObject);

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imageAddPedidoClick(Sender: TObject);
  private
    { Private declarations }
    procedure DefinirIndices;
    procedure SelecionarTab(const aTab : Smallint);
    procedure AddPedidoListView(aPedido : TPedido);
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

uses UConstantes, UMensagem;

{ TFrmPrincipal }

procedure TFrmPrincipal.AddPedidoListView(aPedido: TPedido);
var
  aItem : TListViewItem;
  aText : TListItemText;
begin
  aItem := ListViewPedido.Items.Add;
  with aItem do
  begin
//    // MODO 1
//    // Número
//    aText := TListItemText(Objects.FindDrawable('Text1'));
//    aText.Text := aPedido.ToString;
//    // Cliente
//    aText := TListItemText(Objects.FindDrawable('Text2'));
//    aText.Text := aPedido.Cliente.ToString;
//    // Data
//    aText := TListItemText(Objects.FindDrawable('Text3'));
//    aText.Text := FormatDateTime('dd/mm/yyyy', aPedido.Data);
//    // Valor
//    aText := TListItemText(Objects.FindDrawable('Text4'));
//    aText.Text := 'R$ ' +  FormatFloat(',0.00', aPedido.ValorPedido);
    // MODO 2
    TListItemText(Objects.FindDrawable('Text1')).Text := aPedido.ToString;
    TListItemText(Objects.FindDrawable('Text2')).Text := aPedido.Cliente.ToString;
    TListItemText(Objects.FindDrawable('Text3')).Text := FormatDateTime('dd/mm/yyyy', aPedido.Data);
    TListItemText(Objects.FindDrawable('Text4')).Text := 'R$ ' + FormatFloat(',0.00', aPedido.ValorPedido);
  end;
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
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  SelecionarTab(idxTabPedido);
end;

procedure TFrmPrincipal.imageAddPedidoClick(Sender: TObject);
var
  aPedido : TPedido;
begin
  aPedido := TPedido.Create;
  AddPedidoListView(aPedido);
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
        imageTabPedido.Opacity   := 1;
        labelTabPedido.FontColor := crAzul;
      end;
    idxTabCliente :
      begin
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
