unit UPedidoItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UPadraoCadastro, System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani,
  FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation;

type
  TFrmPedidoItem = class(TFrmPadraoCadastro)
    LayoutProduto: TLayout;
    recCliente: TRectangle;
    lytProduto: TLayout;
    LabelProduto: TLabel;
    imgProduto: TImage;
    lblProduto: TLabel;
    iconProduto: TImage;
    lineCliente: TLine;
    lytQuantidade: TLayout;
    lineQuantidade: TLine;
    LabelQuantidade: TLabel;
    imgQuantidade: TImage;
    lblQuantidade: TLabel;
    imgQuantidadeMais: TImage;
    imgQuantidadeMenos: TImage;
    lytValorUnit: TLayout;
    lineValorUnit: TLine;
    LabelValorUnit: TLabel;
    imgValorUnit: TImage;
    lblValorUnit: TLabel;
  strict private
    { Private declarations }
    class var aInstance : TFrmPedidoItem;
  public
    { Public declarations }
    class function GetInstance : TFrmPedidoItem;
  end;

  procedure NovoItemPedido(); //(Observer : IObservadorItemPedido);

//var
//  FrmPedidoItem: TFrmPedidoItem;
//
implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UMensagem;

procedure NovoItemPedido(); //(Observer : IObservadorItemPedido);
var
  aForm : TFrmPedidoItem;
begin
  aForm := TFrmPedidoItem.GetInstance;
//  aForm.AdicionarObservador(Observer);

  with aForm do
  begin
    tbsControle.ActiveTab := tbsCadastro;

    labelTituloCadastro.Text      := 'INSERIR ITEM';
    labelTituloCadastro.TagString := GUIDToString(GUID_NULL); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := 0;                       // Destinado a guardar o CODIGO numérico do registro

    lblProduto.Text    := 'Informe aqui o produto para o pedido';

    lblQuantidade.TagString := ',0.###';
    lblQuantidade.Text      := FormatFloat(lblQuantidade.TagString, 1);
    lblValorUnit.TagString  := ',0.00';
    lblValorUnit.Text       := FormatFloat(lblValorUnit.TagString, 0);
    lblDescricao.TagString  := ',0.00';
    lblDescricao.Text       := FormatFloat(lblDescricao.TagString, 0);

    lblProduto.TagFloat    := 0; // Flags: 0 - Sem edição; 1 - Dado editado
    lblQuantidade.TagFloat := 0;
    lblValorUnit.TagFloat  := 0;
    lblDescricao.TagFloat  := 0;

    lytExcluir.Visible := False;
  end;

  aForm.Show;
end;

{ TFrmPedidoItem }

class function TFrmPedidoItem.GetInstance: TFrmPedidoItem;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmPedidoItem, aInstance);
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
