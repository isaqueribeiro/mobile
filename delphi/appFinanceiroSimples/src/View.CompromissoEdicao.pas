unit View.CompromissoEdicao;

interface

uses
  System.Generics.Collections,
  Services.ComplexTypes,
  Classe.ObjetoItemListView,
  Controller.Compromisso,
  Controllers.Interfaces.Observers,
  Views.Interfaces.Observers,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.DateTimeCtrls;

type
  TFrmCompromissoEdicao = class(TForm, IObserverCompromissoController, ISubjectCompromissoEdicao)
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
    ImgRealizado: TImage;
    ImgPendente: TImage;
    TmrFechar: TTimer;
    LayoutSituacao: TLayout;
    Line1: TLine;
    ImageSituacao: TImage;
    LabelSituacao: TLabel;
    LayoutTipoAReceber: TLayout;
    ImageTipoAReceber: TImage;
    LabelTipoAReceber: TLabel;
    LayoutTipoAPagar: TLayout;
    ImageTipoAPagar: TImage;
    LabelTipoAPagar: TLabel;
    procedure ImageFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
//    procedure SelecionarTipo(Sender: TObject);
    procedure InformarData(Sender: TObject);
    procedure ImageSalvarClick(Sender: TObject);
    procedure edtValorTyping(Sender: TObject);
    procedure ImageSelecionarCategoriaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TmrFecharTimer(Sender: TObject);
    procedure ImageExcluirClick(Sender: TObject);
  strict private
    class var _instance : TFrmCompromissoEdicao;
  private
    { Private declarations }
    FError : String;
    FObservers  : TList<IObserverCompromissoEdicao>;
    FController : TCompromissoController;
    FTipo       : TTipoCompromisso;
    procedure CarregarRegistro;
    procedure SelecionarTipo(ATipo : TTipoCompromisso);
    procedure ExcluirCompromisso(Sender : TObject);

    procedure AtualizarCompromisso;

    procedure AdicionarObservador(Observer : IObserverCompromissoEdicao);
    procedure RemoverObservador(Observer   : IObserverCompromissoEdicao);
    procedure RemoverTodosObservadores;

    procedure Notificar;
  public
    { Public declarations }
    class function GetInstance(const ATipo : TTipoCompromisso; Observer : IObserverCompromissoEdicao) : TFrmCompromissoEdicao;
  end;

implementation

{$R *.fmx}

uses
    DataModule.Recursos
  , Services.Format
  , System.StrUtils
  , Services.MessageDialog
  , View.CategoriaSelecao
  , Controller.Categoria;

{ TFrmLancamentoEdicao }

procedure TFrmCompromissoEdicao.AdicionarObservador(Observer: IObserverCompromissoEdicao);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

procedure TFrmCompromissoEdicao.AtualizarCompromisso;
begin
  ;
end;

procedure TFrmCompromissoEdicao.CarregarRegistro;
begin
  with FController do
  begin
    Find(Attributes.ID, FError, True);

    if not FError.IsEmpty then
      TServicesMessageDialog.Error('Compromisso', FError);

    edtCategoria.Tag   := 0;
    edtCategoria.Text  := EmptyStr;
    ImageCategoria.Tag := 0;
    ImageCategoria.Bitmap.Assign( ImgSemImage.Bitmap );

    edtDescricao.Text := Attributes.Descricao;
    edtData.DateTime  := Attributes.Data;
    edtValor.Text     := IfThen(Attributes.Valor = 0, EmptyStr, FormatFloat(',0.00', Attributes.Valor)).Replace('-', '');
    edtCategoria.Text := Attributes.Categoria.Descricao;

    SelecionarTipo( Attributes.Tipo );

    if (Attributes.Tipo = TTipoCompromisso.tipoCompromissoAReceber) then
      LabelSituacao.Text := IfThen(Attributes.Realizado, 'RECEBIMENTO REALIZADO', 'RECEBIMENTO PENDENTE')
    else
    if (Attributes.Tipo = TTipoCompromisso.tipoCompromissoAPagar) then
      LabelSituacao.Text := IfThen(Attributes.Realizado, 'PAGAMENTO REALIZADO', 'PAGAMENTO PENDENTE');

    if Attributes.Realizado then
      ImageSituacao.Bitmap := ImgRealizado.Bitmap
    else
      ImageSituacao.Bitmap := ImgPendente.Bitmap;

    if Assigned(Attributes.Categoria.Icone) then
      ImageCategoria.Bitmap := Attributes.Categoria.Icone
    else
      ImageCategoria.Bitmap := ImgSemImage.Bitmap;

    ImageSalvar.Visible := not Attributes.Realizado;
  end;
end;

procedure TFrmCompromissoEdicao.edtValorTyping(Sender: TObject);
begin
  TServicesFormat.Formatar(Sender, TTypeFormat.typeFormatValor);
end;

procedure TFrmCompromissoEdicao.ExcluirCompromisso(Sender: TObject);
begin
  FController.Delete(FError);

  if FError.IsEmpty then
  begin
    Notificar;
    TmrFechar.Enabled := True;
  end;
end;

procedure TFrmCompromissoEdicao.FormActivate(Sender: TObject);
begin
  if (FController.Operacao = TTipoOperacaoController.operControllerDelete) then
    TmrFechar.Enabled := True;
end;

procedure TFrmCompromissoEdicao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RemoverTodosObservadores;
  FObservers.DisposeOf;

  Action    := TCloseAction.caFree;
  _instance := nil;
end;

procedure TFrmCompromissoEdicao.FormCreate(Sender: TObject);
begin
  ImgSemImage.Visible  := False;
  ImgRealizado.Visible := False;
  ImgPendente.Visible  := False;

  ImageTipoAReceber.Tag := Ord(TTipoCompromisso.tipoCompromissoAReceber);
  ImageTipoAPagar.Tag   := Ord(TTipoCompromisso.tipoCompromissoAPagar);

  SelecionarTipo( TTipoCompromisso.tipoCompromissoAReceber );

  FError := EmptyStr;
  FController := TCompromissoController.GetInstance(Self);
  FObservers  := TList<IObserverCompromissoEdicao>.Create;
end;

procedure TFrmCompromissoEdicao.FormShow(Sender: TObject);
begin
  CarregarRegistro;

  if (FController.Attributes.Codigo = 0) then
    LabelTitulo.Text := 'Novo Compromisso'
  else
    LabelTitulo.Text := 'Editar Compromisso';

  LayoutSituacao.Visible := (FController.Attributes.Codigo > 0);
  LayoutBototes.Visible  := (FController.Attributes.Codigo > 0);
end;

class function TFrmCompromissoEdicao.GetInstance(const ATipo : TTipoCompromisso; Observer : IObserverCompromissoEdicao): TFrmCompromissoEdicao;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmCompromissoEdicao, _instance);

  if not Assigned(_instance.FObservers) then
    _instance.FObservers := TList<IObserverCompromissoEdicao>.Create;

  _instance.AdicionarObservador(Observer);
  _instance.SelecionarTipo(ATipo);

  Result := _instance;
end;

procedure TFrmCompromissoEdicao.ImageExcluirClick(Sender: TObject);
begin
  if FController.Attributes.Realizado then
    TServicesMessageDialog.Inform('Excluir', 'Apenas compromissos pendentes podem ser excluídos')
  else
    TServicesMessageDialog.Confirm('Excluir',
      Format('Você confirma o compromisso %s?', [FController.Attributes.Descricao.QuotedString]), ExcluirCompromisso);
end;

procedure TFrmCompromissoEdicao.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmCompromissoEdicao.ImageSalvarClick(Sender: TObject);
var
  aExecutado : Boolean;
begin
  with FController do
  begin
    Attributes.Descricao := edtDescricao.Text;
    Attributes.Data      := edtData.Date;
    Attributes.Valor     := StrToCurrDef(edtValor.Text.Trim.Replace('.', '').Replace('-', ''), 0);

    if (ImageTipoAReceber.TagString = 'S') then
      Attributes.Tipo  := TTipoCompromisso.tipoCompromissoAReceber
    else
    if (ImageTipoAPagar.TagString = 'S') then
      Attributes.Tipo := TTipoCompromisso.tipoCompromissoAPagar;
  end;

  if (FController.Attributes.Codigo = 0) then
    aExecutado := FController.Insert(FError)
  else
    aExecutado := FController.Update(FError);

  if (not FError.IsEmpty) then
    TServicesMessageDialog.Alert('Salvar', FError)
  else
  begin
    Notificar;
    Close;
  end;
end;

procedure TFrmCompromissoEdicao.ImageSelecionarCategoriaClick(Sender: TObject);
begin
  TFrmCategoriaSelecao.getInstance().ShowModal(procedure (ModalResult : TModalResult)
  begin
    if (ModalResult = mrOk) then
    begin
      FController
        .Attributes
          .Categoria.Assign( TCategoriaController.GetInstance().Attributes );

      with FController do
      begin
        edtCategoria.Tag   := Attributes.Categoria.Codigo;
        edtCategoria.Text  := Attributes.Categoria.Descricao;
        ImageCategoria.Tag := Attributes.Categoria.Indice;
        ImageCategoria.Bitmap.Assign( Attributes.Categoria.Icone );
      end;
    end;
  end);
end;

procedure TFrmCompromissoEdicao.InformarData(Sender: TObject);
begin
  edtData.Date := Date - TFmxObject(Sender).Tag;
end;

procedure TFrmCompromissoEdicao.Notificar;
var
  Observer : IObserverCompromissoEdicao;
begin
  for Observer in FObservers do
    Observer.AtualizarItemCompromisso;
end;

procedure TFrmCompromissoEdicao.RemoverObservador(Observer: IObserverCompromissoEdicao);
begin
  FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmCompromissoEdicao.RemoverTodosObservadores;
var
  I : Integer;
begin
  for I := 0 to (FObservers.Count - 1) do
    FObservers.Delete(I);

  FObservers.TrimExcess;
end;

procedure TFrmCompromissoEdicao.SelecionarTipo(ATipo: TTipoCompromisso);
begin
  FTipo := ATipo;

  case FTipo of
    TTipoCompromisso.tipoCompromissoAReceber :
      begin
        ImageTipoAReceber.TagString := 'S';
        ImageTipoAPagar.TagString   := 'N';
      end;

    TTipoCompromisso.tipoCompromissoAPagar :
      begin
        ImageTipoAReceber.TagString := 'N';
        ImageTipoAPagar.TagString   := 'S';
      end;
  end;

  LayoutTipoAReceber.Visible := (ImageTipoAReceber.TagString = 'S');
  LayoutTipoAPagar.Visible   := (ImageTipoAPagar.TagString = 'S');
end;

procedure TFrmCompromissoEdicao.TmrFecharTimer(Sender: TObject);
begin
  Self.Close;
end;

end.
