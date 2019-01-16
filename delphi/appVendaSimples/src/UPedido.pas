unit UPedido;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation;

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

//    lblCPF_CNPJ.Text  := 'Informe aqui o número de CPF/CNPJ do novo cliente';
//    lblDescricao.Text := 'Informe aqui o nome do novo cliente';
//    lblEndereco.Text  := 'Informe aqui o endereço do novo cliente';
//    lblTelefone.Text  := 'Informe aqui o númeor de telefone do novo cliente';
//    lblEmail.Text     := 'Informe aqui o e-mail do novo cliente';
//    lblObs.Text       := 'Insira aqui as observações sobre o cliente';
//
//    lblCPF_CNPJ.TagFloat  := 0; // Flags: 0 - Sem edição; 1 - Dado editado
//    lblDescricao.TagFloat := 0;
//    lblEndereco.TagFloat  := 0;
//    lblTelefone.TagFloat  := 0;
//    lblEmail.TagFloat     := 0;
//    lblObs.TagFloat       := 0;

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
