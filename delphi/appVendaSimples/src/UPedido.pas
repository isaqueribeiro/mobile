unit UPedido;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFrmPedido = class(TFrmPadraoCadastro)
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
    imgSemProduto: TImage;
    lblSemProduto: TLabel;
    img_item_menos: TImage;
    img_item_mais: TImage;
    lineRodapePedido: TLine;
    procedure DoMudarAbaPedido(Sender: TObject);

    procedure FormCreate(Sender: TObject);
  strict private
    { Private declarations }
    class var aInstance : TFrmPedido;
  public
    { Public declarations }
    class function GetInstance : TFrmPedido;
  end;

  procedure NovoCadastroPedido(); //(Observer : IObservadorPedido);

//var
//  FrmPedido: TFrmPedido;

implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UMensagem;

procedure NovoCadastroPedido(); //(Observer : IObservadorPedido);
var
  aForm : TFrmPedido;
begin
  aForm := TFrmPedido.GetInstance;
//  aForm.AdicionarObservador(Observer);

  with aForm do
  begin
    tbsControle.ActiveTab := tbsCadastro;

    labelTituloCadastro.Text      := 'NOVO PEDIDO';
    labelTituloCadastro.TagString := GUIDToString(GUID_NULL); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := 0;                       // Destinado a guardar o CODIGO numérico do registro

    lblCliente.Text := 'Informe aqui o cliente do novo pedido';
    lblTipo.Text    := 'Informe aqui o tipo do novo pedido';
    lblData.Text    := FormatDateTime('dd/mm/yyyy', Date);
    lblContato.Text := 'Informe aqui o(s) contato(s) do novo pedido';
    lblObs.Text     := 'Informe aqui as observações para o novo pedido';

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

    lytExcluir.Visible := False;

    DoMudarAbaPedido(lblAbaDadoPedido);
  end;

  aForm.Show;
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
  end;

end;

procedure TFrmPedido.FormCreate(Sender: TObject);
begin
  inherited;
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
end;

class function TFrmPedido.GetInstance: TFrmPedido;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmPedido, aInstance);
    Application.RealCreateForms;
  end;

//  if not Assigned(aInstance.FObservers) then
//    aInstance.FObservers := TList<IObservadorCliente>.Create;
//
//  aInstance.aDao := TClienteDao.GetInstance;
//
  Result := aInstance;
end;

end.
