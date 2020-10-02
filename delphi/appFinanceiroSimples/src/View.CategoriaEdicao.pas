unit View.CategoriaEdicao;

interface

uses
  Controller.Categoria,
  Views.Interfaces.Observers,
  System.Generics.Collections,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Layouts, FMX.Edit, FMX.ListBox;

type
  TFrmCategoriaEdicao = class(TForm, ISubjectCategoriaEdicao)
    LayoutTool: TLayout;
    LabelTitulo: TLabel;
    ImageFechar: TImage;
    ImageSalvar: TImage;
    LayoutDescricao: TLayout;
    LabelDescricao: TLabel;
    edtDescricao: TEdit;
    LineDescricao: TLine;
    LayoutValor: TLayout;
    LabelIcone: TLabel;
    ListBoxIcone: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    ListBoxItem13: TListBoxItem;
    ListBoxItem14: TListBoxItem;
    ListBoxItem15: TListBoxItem;
    ListBoxItem16: TListBoxItem;
    Image1: TImage;
    ImgSelecao: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    ListBoxItem17: TListBoxItem;
    ListBoxItem18: TListBoxItem;
    ListBoxItem19: TListBoxItem;
    ListBoxItem20: TListBoxItem;
    ListBoxItem21: TListBoxItem;
    ListBoxItem22: TListBoxItem;
    ListBoxItem23: TListBoxItem;
    ListBoxItem24: TListBoxItem;
    ListBoxItem25: TListBoxItem;
    ListBoxItem26: TListBoxItem;
    Image17: TImage;
    Image18: TImage;
    Image19: TImage;
    Image20: TImage;
    Image21: TImage;
    Image22: TImage;
    Image23: TImage;
    Image24: TImage;
    Image25: TImage;
    Image26: TImage;
    ListBoxItem27: TListBoxItem;
    ListBoxItem28: TListBoxItem;
    Image27: TImage;
    Image28: TImage;
    LayoutBototes: TLayout;
    RectangleBotoes: TRectangle;
    ImageExcluir: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ImageFecharClick(Sender: TObject);
    procedure SelecionarIcone(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImageSalvarClick(Sender: TObject);
    procedure ImageExcluirClick(Sender: TObject);
  strict private
    class var _instance : TFrmCategoriaEdicao;
  private
    { Private declarations }
    FObservers : TList<IObserverCategoriaEdicao>;
    FError : String;
    FController : TCategoriaController;
    procedure CarregarImagens;
    procedure CarregarRegistro;
    procedure ExcluirCategoria(Sender : TObject);

    procedure AdicionarObservador(Observer : IObserverCategoriaEdicao);
    procedure RemoverObservador(Observer   : IObserverCategoriaEdicao);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  public
    { Public declarations }
    class function GetInstance(Observer : IObserverCategoriaEdicao) : TFrmCategoriaEdicao;

    property Error : String read FError;
  end;

//var
//  FrmCategoriaEdicao: TFrmCategoriaEdicao;

implementation

{$R *.fmx}

uses
    DataModule.Recursos
  , Services.Utils
  , Services.ComplexTypes
  , Services.MessageDialog;

{ TFrmCategoriaEdicao }

procedure TFrmCategoriaEdicao.AdicionarObservador(Observer: IObserverCategoriaEdicao);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

procedure TFrmCategoriaEdicao.CarregarImagens;
var
  I : Integer;
  aImage : TComponent;
begin
  for I := 1 to ListBoxIcone.Count do
  begin
    aImage := Self.FindComponent('Image' + I.ToString);
    if Assigned(aImage) then
      TServicesUtils.ResourceImage('categoria_' + I.ToString, TImage(aImage));
  end;
end;

procedure TFrmCategoriaEdicao.CarregarRegistro;
var
  aItem : TListBoxItem;
  aParente : TComponent;
begin
  with FController do
  begin
    Find(Attributes.Codigo, FError, True);

    if not FError.IsEmpty then
      TServicesMessageDialog.Error('Categoria', FError);

    edtDescricao.Text      := Attributes.Descricao;
    ListBoxIcone.ItemIndex := Attributes.Indice;

    aItem := ListBoxIcone.ItemByIndex( ListBoxIcone.ItemIndex );

    if Assigned(aItem) then
    begin
      ImgSelecao.Parent := aItem;
      ListBoxIcone.ScrollToItem( ListBoxIcone.ItemByIndex(Attributes.Indice) );
    end;
  end;
end;

procedure TFrmCategoriaEdicao.ExcluirCategoria(Sender: TObject);
begin
  FController.Delete(FError);

  if (not FError.IsEmpty) then
    TServicesMessageDialog.Error('Excluir', FError)
  else
  begin
    Notificar;
    Close;
  end;
end;

procedure TFrmCategoriaEdicao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RemoverTodosObservadores;
  FObservers.DisposeOf;

  Action    := TCloseAction.caFree;
  _instance := nil;
end;

procedure TFrmCategoriaEdicao.FormCreate(Sender: TObject);
begin
  ListBoxIcone.Columns := Trunc(LabelIcone.Width / 80);
  CarregarImagens;

  FError := EmptyStr;
  FController := TCategoriaController.GetInstance();
  FObservers  := TList<IObserverCategoriaEdicao>.Create;
end;

procedure TFrmCategoriaEdicao.FormResize(Sender: TObject);
begin
  ListBoxIcone.Columns := Trunc(LabelIcone.Width / 80);
end;

procedure TFrmCategoriaEdicao.FormShow(Sender: TObject);
begin
  CarregarRegistro;

  if (FController.Attributes.Codigo = 0) then
    LabelTitulo.Text := 'Nova Categoria'
  else
    LabelTitulo.Text := 'Editar Categoria';

  LayoutBototes.Visible := (FController.Attributes.Codigo > 0);
end;

class function TFrmCategoriaEdicao.GetInstance(Observer : IObserverCategoriaEdicao): TFrmCategoriaEdicao;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmCategoriaEdicao, _instance);

  if not Assigned(_instance.FObservers) then
    _instance.FObservers  := TList<IObserverCategoriaEdicao>.Create;

  _instance.AdicionarObservador(Observer);
  Result := _instance;
end;

procedure TFrmCategoriaEdicao.ImageExcluirClick(Sender: TObject);
begin
  TServicesMessageDialog.Confirm('Excluir',
    Format('Você confirma a exclusão da categoria %s?', [FController.Attributes.Descricao.QuotedString]), ExcluirCategoria);
end;

procedure TFrmCategoriaEdicao.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmCategoriaEdicao.ImageSalvarClick(Sender: TObject);
var
  aExecutado : Boolean;
begin
  with FController do
  begin
    Attributes.Descricao := edtDescricao.Text;

    // Garantir que uma imagem seja salva na base
    if (Attributes.Indice = 0) then
      SelecionarIcone(Image1);
  end;

  if (FController.Attributes.Codigo = 0) then
    aExecutado := FController.Insert(FError)
  else
    aExecutado := FController.Update(FError);

  if (not FError.IsEmpty) then
    TServicesMessageDIalog.Error('Salvar', FError)
  else
  begin
    Notificar;
    Close;
  end;
end;

procedure TFrmCategoriaEdicao.Notificar;
var
  Observer : IObserverCategoriaEdicao;
begin
  for Observer in FObservers do
    Observer.AtualizarCategoria;
end;

procedure TFrmCategoriaEdicao.RemoverObservador(Observer: IObserverCategoriaEdicao);
begin
  FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmCategoriaEdicao.RemoverTodosObservadores;
var
  I : Integer;
begin
  for I := 0 to (FObservers.Count - 1) do
    FObservers.Delete(I);

  FObservers.TrimExcess;
end;

procedure TFrmCategoriaEdicao.SelecionarIcone(Sender: TObject);
begin
  if Sender is TImage then
  begin
    ImgSelecao.AnimateFloatWait('Opacity', 0, 0.2, TAnimationType.Out, TInterpolationType.Circular);
    ImgSelecao.Parent := TImage(Sender).Parent;
    ImgSelecao.AnimateFloatWait('Opacity', 0.2, 0.2, TAnimationType.&In, TInterpolationType.Circular);

    FController.Attributes.Indice := TListBoxItem(TImage(Sender).Parent).Index;
    FController.Attributes.Icone  := TImage(Sender).Bitmap;
  end;
end;

end.
