unit View.LancamentoEdicao;

interface

uses
  Classe.ObjetoItemListView,
  Controller.Lancamento,
  Controllers.Interfaces.Observers,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.DateTimeCtrls;

type
  TFrmLancamentoEdicao = class(TForm, IObserverLancamentoController)
    LayoutTool: TLayout;
    ImageFechar: TImage;
    ImageSalvar: TImage;
    LayoutBototes: TLayout;
    RectangleBotoes: TRectangle;
    ImageExcluir: TImage;
    LabelTitulo: TLabel;
    VertScrollBox: TVertScrollBox;
    LayoutDescricao: TLayout;
    LabelDescricao: TLabel;
    edtDescricao: TEdit;
    LineDescricao: TLine;
    LayoutValor: TLayout;
    LabelValor: TLabel;
    edtValor: TEdit;
    LineValor: TLine;
    LayoutCategoria: TLayout;
    LabelCategoria: TLabel;
    edtCategoria: TEdit;
    LineCategoria: TLine;
    LayoutData: TLayout;
    LabelData: TLabel;
    LineData: TLine;
    ImageSelecionarCategoria: TImage;
    LayoutInformeData: TLayout;
    edtData: TDateEdit;
    ImageCategoria: TImage;
    ImgSemImage: TImage;
    ImageHoje: TImage;
    LabelHoje: TLabel;
    ImageOntem: TImage;
    LabelOntem: TLabel;
    LayoutTipo: TLayout;
    LabelTipo: TLabel;
    LineTipo: TLine;
    ImageTipoReceita: TImage;
    LabelTipoReceita: TLabel;
    ImageTipoDespesa: TImage;
    LabelTipoDespesa: TLabel;
    ImgMarcado: TImage;
    ImgDesmarcado: TImage;
    procedure ImageFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SelecionarTipo(Sender: TObject);
    procedure InformarData(Sender: TObject);
    procedure ImageSalvarClick(Sender: TObject);
    procedure edtValorTyping(Sender: TObject);
  strict private
    class var _instance : TFrmLancamentoEdicao;
  private
    { Private declarations }
    FError : String;
    FController : TLancamentoController;
    procedure CarregarRegistro;
    procedure AtualizarLancamento;

    procedure Notificar; virtual; abstract;
  public
    { Public declarations }
    class function GetInstance() : TFrmLancamentoEdicao;
  end;

//var
//  FrmLancamentoEdicao: TFrmLancamentoEdicao;
//
implementation

{$R *.fmx}

uses
    DataModule.Recursos
  , Services.ComplexTypes
  , Services.Format
  , System.StrUtils
  , Services.MessageDialog;

{ TFrmLancamentoEdicao }

procedure TFrmLancamentoEdicao.AtualizarLancamento;
begin
  ;
end;

procedure TFrmLancamentoEdicao.CarregarRegistro;
begin
  with FController do
  begin
    Find(Attributes.ID, FError, True);

    if not FError.IsEmpty then
      TServicesMessageDialog.Error('Lançamento', FError);

    edtDescricao.Text := Attributes.Descricao;
    edtData.DateTime  := Attributes.Data;
    edtValor.Text     := IfThen(Attributes.Valor = 0, EmptyStr, FormatFloat(',0.00', Attributes.Valor)).Replace('-', '');
    edtCategoria.Text := Attributes.Categoria.Descricao;

    if (Attributes.Tipo = TTipoLancamento.tipoReceita) then
      SelecionarTipo(ImageTipoReceita)
    else
    if (Attributes.Tipo = TTipoLancamento.tipoDespesa) then
      SelecionarTipo(ImageTipoDespesa);

    if Assigned(Attributes.Categoria.Icone) then
      ImageCategoria.Bitmap := Attributes.Categoria.Icone
    else
      ImageCategoria.Bitmap := ImgSemImage.Bitmap;
  end;
end;

procedure TFrmLancamentoEdicao.edtValorTyping(Sender: TObject);
begin
  TServicesFormat.Formatar(Sender, TTypeFormat.typeFormatValor);
end;

procedure TFrmLancamentoEdicao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action    := TCloseAction.caFree;
  _instance := nil;
end;

procedure TFrmLancamentoEdicao.FormCreate(Sender: TObject);
begin
  ImgSemImage.Visible   := False;
  ImgMarcado.Visible    := False;
  ImgDesmarcado.Visible := False;

  ImageTipoReceita.Tag := Ord(TTipoLancamento.tipoReceita);
  ImageTipoDespesa.Tag := Ord(TTipoLancamento.tipoDespesa);

  SelecionarTipo(ImageTipoDespesa);

  FError := EmptyStr;
  FController := TLancamentoController.GetInstance(Self);
end;

procedure TFrmLancamentoEdicao.FormShow(Sender: TObject);
begin
  CarregarRegistro;

  if (FController.Attributes.Codigo = 0) then
    LabelTitulo.Text := 'Novo Lançamento'
  else
    LabelTitulo.Text := 'Editar Lançamento';

  LayoutBototes.Visible := (FController.Attributes.Codigo > 0);
end;

class function TFrmLancamentoEdicao.GetInstance: TFrmLancamentoEdicao;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmLancamentoEdicao, _instance);

  Result := _instance;
end;

procedure TFrmLancamentoEdicao.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmLancamentoEdicao.ImageSalvarClick(Sender: TObject);
var
  aExecutado : Boolean;
begin
  with FController do
  begin
    Attributes.Descricao := edtDescricao.Text;
    Attributes.Data      := edtData.Date;
    Attributes.Valor     := StrToCurrDef(edtValor.Text.Trim.Replace('.', '').Replace('-', ''), 0);

    if (ImageTipoReceita.TagString = 'S') then
      Attributes.Tipo  := TTipoLancamento.tipoReceita
    else
    if (ImageTipoDespesa.TagString = 'S') then
      Attributes.Tipo := TTipoLancamento.tipoDespesa;
  end;

  if (FController.Attributes.Codigo = 0) then
    aExecutado := FController.Insert(FError)
  else
    aExecutado := FController.Update(FError);

  if (not FError.IsEmpty) then
    TServicesMessageDialog.Error('Salvar', FError)
  else
  begin
    Notificar;
    Close;
  end;
end;

procedure TFrmLancamentoEdicao.InformarData(Sender: TObject);
begin
  edtData.Date := Date - TFmxObject(Sender).Tag;
end;

procedure TFrmLancamentoEdicao.SelecionarTipo(Sender: TObject);
begin
  case TTipoLancamento(TImage(Sender).Tag) of
    TTipoLancamento.tipoReceita :
      begin
        ImageTipoReceita.Bitmap    := ImgMarcado.Bitmap;
        ImageTipoDespesa.Bitmap    := ImgDesmarcado.Bitmap;
        ImageTipoReceita.TagString := 'S';
        ImageTipoDespesa.TagString := 'N';
      end;

    TTipoLancamento.tipoDespesa :
      begin
        ImageTipoReceita.Bitmap    := ImgDesmarcado.Bitmap;
        ImageTipoDespesa.Bitmap    := ImgMarcado.Bitmap;
        ImageTipoReceita.TagString := 'N';
        ImageTipoDespesa.TagString := 'S';
      end;
  end;
end;

end.
