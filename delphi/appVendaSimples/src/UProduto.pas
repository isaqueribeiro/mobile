unit UProduto;

interface

uses
  System.StrUtils,
  model.Produto,
  dao.Produto,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadrao, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, System.Actions, FMX.ActnList,
  FMX.TabControl, FMX.MediaLibrary.Actions, FMX.StdActns, FMX.Ani,
  FMX.ScrollBox, FMX.Memo;

type
  TFrmProduto = class(TFrmPadrao)
    layoutBuscaProduto: TLayout;
    rectangleBuscaProduto: TRectangle;
    editBuscaProduto: TEdit;
    imageBuscaProduto: TImage;
    ListViewProduto: TListView;
    img_produto_sem_foto: TImage;
    lytProdutoFoto: TLayout;
    imgProdutoFoto: TImage;
    lblAlterarImagem: TLabel;
    lytProdutoDescricao: TLayout;
    lineProdutoDescricao: TLine;
    LabelProdutoDescricao: TLabel;
    imgProdutoDescricao: TImage;
    lblProdutoDescricao: TLabel;
    lytProdutoValor: TLayout;
    lineProdutoValor: TLine;
    LabelProdutoValor: TLabel;
    imgProdutoValor: TImage;
    lblProdutoValor: TLabel;
    lytProdutoEan: TLayout;
    lineProdutoEan: TLine;
    img_foto_novo_produto: TImage;
    LabelProdutoEan: TLabel;
    lytCancelarImagem: TLayout;
    rectangleCancelarImagem: TRectangle;
    lblCancelarImagem: TLabel;
    lytCapturarImagem: TLayout;
    rectangleCapturarImagem: TRectangle;
    lblCapturarImagemCamera: TLabel;
    lineCapturarImagem: TLine;
    imgCapturarImagemCamera: TImage;
    actTakePhotoFromCamera: TTakePhotoFromCameraAction;
    actTakePhotoFromLibrary: TTakePhotoFromLibraryAction;
    lblCapturarImagemBiblioteca: TLabel;
    imgCapturarImagemBiblioteca: TImage;
    tbsEditar: TTabItem;
    LayoutFormEdicao: TLayout;
    rectangleTituloEdicao: TRectangle;
    labelTituloEdicao: TLabel;
    imageVoltarCadastro: TImage;
    imageSalvarEdicao: TImage;
    ChangeTabActionEditar: TChangeTabAction;
    layoutEditarCampo: TLayout;
    rectangleEditarCampo: TRectangle;
    editEditarCampo: TEdit;
    layoutMemoCampo: TLayout;
    rectangleMemoCampo: TRectangle;
    mmMemoCampo: TMemo;
    lytProdutoExcluir: TLayout;
    lineProdutoExcluir: TLine;
    imgProdutoExcluir: TImage;
    lblProdutoExcluir: TLabel;
    layoutValorCampo: TLayout;
    labelValorCampo: TLabel;
    lineValorCampo: TLine;
    lytTecla7: TLayout;
    lblTecla7: TLabel;
    lytTecla8: TLayout;
    lblTecla8: TLabel;
    lytTecla9: TLayout;
    lblTecla9: TLabel;
    lytTecla4: TLayout;
    lblTecla4: TLabel;
    lytTecla5: TLayout;
    lblTecla5: TLabel;
    lytTecla6: TLayout;
    lblTecla6: TLabel;
    lytTecla1: TLayout;
    lblTecla1: TLabel;
    lytTecla2: TLayout;
    lblTecla2: TLabel;
    lytTecla3: TLayout;
    lblTecla3: TLabel;
    lytTeclas: TLayout;
    lytTecla00: TLayout;
    lblTecla00: TLabel;
    lytTecla0: TLayout;
    lblTecla0: TLabel;
    lytTeclaBackSpace: TLayout;
    imgTeclaBackSpace: TImage;
    imgSemProduto: TImage;
    lblSemProduto: TLabel;
    procedure DoBuscaProdutos(Sender: TObject);
    procedure DoEditarDescricao(Sender: TObject);
    procedure DoEditarValor(Sender: TObject);
    procedure DoSalvarProdutos(Sender: TObject);
    procedure DoExcluirProduto(Sender : TObject);
    procedure DoTeclaBackSpace(Sender : TObject);
    procedure DoTeclaNumero(Sender : TObject);

    procedure ListViewProdutoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imageAdicionarClick(Sender: TObject);
    procedure imageVoltarCadastroClick(Sender: TObject);
    procedure imageSalvarEdicaoClick(Sender: TObject);
    procedure imgProdutoFotoClick(Sender: TObject);
    procedure lblCancelarImagemClick(Sender: TObject);
    procedure lblCapturarImagemCameraClick(Sender: TObject);
    procedure lblCapturarImagemBibliotecaClick(Sender: TObject);
    procedure actTakePhotoFromLibraryDidFinishTaking(Image: TBitmap);
    procedure actTakePhotoFromCameraDidFinishTaking(Image: TBitmap);
    procedure ListViewProdutoItemClickEx(const Sender: TObject;
      ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure imageSalvarCadastroClick(Sender: TObject);
  strict private
    { Private declarations }
    procedure FormatarItemProdutoListView(aItem  : TListViewItem);
    procedure AdicionarProdutoListView(aProduto : TProduto);

    procedure NovoProduto;
    procedure TeclaBackSpace;
    procedure TeclaNumero(const aValue : String);
    procedure BuscarProdutos(aBusca : String; aPagina : Integer);
    procedure EditarProduto(const aItemIndex : Integer);
    procedure ExcluirProduto(Sender: TObject);

    function DevolverValorEditado : Boolean;

    class var aInstance : TFrmProduto;
  public
    { Public declarations }
    class function GetInstance : TFrmProduto;
  end;

  procedure ExibirListaProdutos;

implementation

{$R *.fmx}

uses
  UConstantes,
  UMensagem;

procedure ExibirListaProdutos;
var
  aForm : TFrmProduto;
begin
  aForm := TFrmProduto.GetInstance;
  aForm.Show;
end;

{ TFrmProduto }

class function TFrmProduto.GetInstance: TFrmProduto;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmProduto, aInstance);
    Application.RealCreateForms;
  end;

  Result := aInstance;
end;

procedure TFrmProduto.imageAdicionarClick(Sender: TObject);
begin
  NovoProduto;
  inherited;
end;

procedure TFrmProduto.imageSalvarCadastroClick(Sender: TObject);
begin
  DoSalvarProdutos(Sender);
  inherited;
end;

procedure TFrmProduto.imageSalvarEdicaoClick(Sender: TObject);
begin
  if DevolverValorEditado then
    ChangeTabActionCadastro.ExecuteTarget(Sender);
end;

procedure TFrmProduto.imageVoltarCadastroClick(Sender: TObject);
begin
  ChangeTabActionCadastro.ExecuteTarget(Sender);
end;

procedure TFrmProduto.imgProdutoFotoClick(Sender: TObject);
begin
  ExibirPainelOpacity;
end;

procedure TFrmProduto.lblCancelarImagemClick(Sender: TObject);
begin
  OcultarPainelOpacity;
end;

procedure TFrmProduto.lblCapturarImagemBibliotecaClick(Sender: TObject);
begin
  actTakePhotoFromLibrary.ExecuteTarget(Sender);
  OcultarPainelOpacity;
end;

procedure TFrmProduto.lblCapturarImagemCameraClick(Sender: TObject);
begin
  actTakePhotoFromCamera.ExecuteTarget(Sender);
  OcultarPainelOpacity;
end;

procedure TFrmProduto.actTakePhotoFromCameraDidFinishTaking(Image: TBitmap);
begin
  imgProdutoFoto.Bitmap := Image;
end;

procedure TFrmProduto.actTakePhotoFromLibraryDidFinishTaking(Image: TBitmap);
begin
  imgProdutoFoto.Bitmap := Image;
end;

procedure TFrmProduto.AdicionarProdutoListView(aProduto: TProduto);
var
  aItem   : TListViewItem;
  aImage  : TListItemImage;
  aBitmat : TBitmap;
begin
  aItem := ListViewProduto.Items.Add;
  aItem.TagObject := aProduto;

  // Foto
  aImage := TListItemImage(aItem.Objects.FindDrawable('Image4'));
  if Assigned(aProduto.Foto) then
  begin
    aBitmat := TBitmap.Create;
    aBitmat.LoadFromStream(aProduto.Foto);
    aImage.OwnsBitmap  := True;
    aImage.Bitmap      := aBitmat;
    aImage.ScalingMode := TImageScalingMode.Stretch;
  end
  else
  begin
    aImage.Bitmap      := img_produto_sem_foto.Bitmap;
    aImage.ScalingMode := TImageScalingMode.Original;
  end;

  FormatarItemProdutoListView(aItem);
end;

procedure TFrmProduto.BuscarProdutos(aBusca: String; aPagina: Integer);
var
  dao : TProdutoDao;
  I : Integer;
begin
  dao := TProdutoDao.GetInstance;
  dao.Load(aBusca);
  for I := Low(dao.Lista) to High(dao.Lista) do
    AdicionarProdutoListView(dao.Lista[I]);
end;

function TFrmProduto.DevolverValorEditado : Boolean;
var
  aObj : TObject;
  aStr : String;
begin
  aObj := nil;
  aStr := EmptyStr;
  if layoutEditarCampo.Visible then
  begin
    aObj := editEditarCampo.TagObject;
    aStr := Trim(editEditarCampo.Text);
    if (Trim(editEditarCampo.TagString) <> EmptyStr) then  // M�scara para formata��o num�rica
    begin
      aStr := aStr.Replace('.', '', [rfReplaceAll]);
      aStr := FormatFloat(Trim(editEditarCampo.TagString), StrToCurrDef(aStr, 0));
    end;
  end
  else
  if layoutMemoCampo.Visible then
  begin
    aObj := mmMemoCampo.TagObject;
    aStr := Trim(mmMemoCampo.Text);
  end
  else
  if layoutValorCampo.Visible then
  begin
    aObj := labelValorCampo.TagObject;
    aStr := Trim(labelValorCampo.Text);
    if (Trim(labelValorCampo.TagString) <> EmptyStr) then  // M�scara para formata��o num�rica
    begin
      aStr := aStr.Replace('.', '', [rfReplaceAll]);
      aStr := FormatFloat(Trim(labelValorCampo.TagString), StrToCurrDef(aStr, 0));
    end;
  end;

  if (aObj <> nil) then
  begin
    if aObj is TLabel then
      TLabel(aObj).Text := aStr
    else
    if aObj is TEdit then
      TEdit(aObj).Text := aStr;
  end;

  if (Trim(aStr) = EmptyStr) then
    ExibirMsgAlerta('Este campo � obrigat�rio!')
  else
    Result := ( (Trim(aStr) <> EmptyStr) or (aObj <> nil) );
end;

procedure TFrmProduto.DoBuscaProdutos(Sender: TObject);
begin
  try
    imgSemProduto.Visible := False;

    ListViewProduto.BeginUpdate;
    ListViewProduto.Items.Clear;

    BuscarProdutos(editBuscaProduto.Text, 0);

    ListViewProduto.EndUpdate;
    imgSemProduto.Visible := (ListViewProduto.Items.Count = 0);
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar carregar os produtos.' + #13 + E.Message);
  end;
end;

procedure TFrmProduto.DoEditarDescricao(Sender: TObject);
begin
  layoutEditarCampo.Visible := False;
  layoutMemoCampo.Visible   := True;
  layoutValorCampo.Visible  := False;

  labelTituloEdicao.Text   := AnsiUpperCase(LabelProdutoDescricao.Text);
  mmMemoCampo.Text         := IfThen(labelTituloCadastro.TagFloat = 0, EmptyStr, lblProdutoDescricao.Text);
  mmMemoCampo.MaxLength    := 250;
  mmMemoCampo.TextAlign    := TTextAlign.Leading;
  mmMemoCampo.KeyboardType := TVirtualKeyboardType.Default;
  mmMemoCampo.TagString    := EmptyStr;
  mmMemoCampo.TagObject    := TObject(lblProdutoDescricao);

  ChangeTabActionEditar.ExecuteTarget(Sender);

  mmMemoCampo.SetFocus;
  mmMemoCampo.SelStart := Length(mmMemoCampo.Text);
end;

procedure TFrmProduto.DoEditarValor(Sender: TObject);
begin
  layoutEditarCampo.Visible := False;
  layoutMemoCampo.Visible   := False;
  layoutValorCampo.Visible  := True;

//  labelTituloEdicao.Text       := AnsiUpperCase(LabelProdutoValor.Text);
//  editEditarCampo.Text         := IfThen(labelTituloCadastro.TagFloat = 0, EmptyStr, lblProdutoValor.Text);
//  editEditarCampo.MaxLength    := 15;
//  editEditarCampo.TextAlign    := TTextAlign.Trailing;
//  editEditarCampo.KeyboardType := TVirtualKeyboardType.DecimalNumberPad;
//  editEditarCampo.TextPrompt   := 'Informe aqui o valor (R$)';
//  editEditarCampo.TagString    := ',0.00';
//  editEditarCampo.TagObject    := TObject(lblProdutoValor);

  labelTituloEdicao.Text       := AnsiUpperCase(LabelProdutoValor.Text);
  labelValorCampo.Text         := Trim(lblProdutoValor.Text);
  labelValorCampo.TagString    := ',0.00';
  labelValorCampo.TagObject    := TObject(lblProdutoValor);

  ChangeTabActionEditar.ExecuteTarget(Sender);

  editEditarCampo.SetFocus;
  editEditarCampo.SelStart := Length(editEditarCampo.Text);
end;

procedure TFrmProduto.DoExcluirProduto(Sender: TObject);
begin
  ExibirMsgConfirmacao('Excluir', 'Deseja excluir o produto selecionado?', ExcluirProduto);
end;

procedure TFrmProduto.DoSalvarProdutos(Sender: TObject);
var
  ins : Boolean;
  dao : TProdutoDao;
  aItem  : TListViewItem;
  aValor : String;
begin
  try
    dao := TProdutoDao.GetInstance;
    dao.Model.ID        := StringToGUID(labelTituloCadastro.TagString);
    dao.Model.Codigo    := labelTituloCadastro.TagFloat;
    dao.Model.Descricao := lblProdutoDescricao.Text;

    aValor := Trim(lblProdutoValor.Text);
    aValor := aValor.Replace('.', '', [rfReplaceAll]);
    aValor := aValor.Replace(',', '', [rfReplaceAll]);

    dao.Model.Valor := StrToCurrDef(aValor, 0) / 100;

    if (imgProdutoFoto.TagFloat > 0) then
    begin
      dao.Model.Foto := TMemoryStream.Create;
      dao.Model.Foto.Position := 0;
      imgProdutoFoto.Bitmap.SaveToStream(dao.Model.Foto);
    end;

    ins := (dao.Model.ID = GUID_NULL);

    if ins then
      dao.Insert()
    else
      dao.Update();

    if ins then
    begin
      AdicionarProdutoListView(dao.Model);
      ListViewProduto.ItemIndex := (ListViewProduto.Items.Count - 1);
    end
    else
    begin
      aItem := TListViewItem(ListViewProduto.Items.Item[ListViewProduto.ItemIndex]);
      aItem.TagObject := dao.Model;
      FormatarItemProdutoListView(aItem);
    end;

    ChangeTabActionConsulta.ExecuteTarget(Sender);
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar salvar o produto.' + #13 + E.Message);
  end;
end;

procedure TFrmProduto.DoTeclaBackSpace(Sender: TObject);
begin
  TeclaBackSpace;
end;

procedure TFrmProduto.DoTeclaNumero(Sender: TObject);
begin
  TeclaNumero( TLabel(Sender).Text );
end;

procedure TFrmProduto.NovoProduto;
begin
  labelTituloCadastro.Text      := 'NOVO PRODUTO';
  labelTituloCadastro.TagString := GUIDToString(GUID_NULL);
  labelTituloCadastro.TagFloat  := 0;

  lblProdutoDescricao.Text := 'Informe aqui a descri��o do novo produto';
  lblProdutoValor.Text     := '0,00';
  imgProdutoFoto.Bitmap    := img_foto_novo_produto.Bitmap;
  imgProdutoFoto.TagFloat  := 0;

  lytProdutoExcluir.Visible := False;
end;

procedure TFrmProduto.TeclaBackSpace;
var
  aStr   : String;
  aValor : Currency;
begin
  aStr := Trim(labelValorCampo.Text);
  aStr := aStr.Replace('.', '', [rfReplaceAll]);
  aStr := aStr.Replace(',', '', [rfReplaceAll]);

  if Length(aStr) > 1 then
    aStr := Copy(aStr, 1, Length(aStr) - 1)
  else
    aStr := '0';

  aValor := StrToCurrDef(aStr, 0) / 100;
  labelValorCampo.Text := FormatFloat(labelValorCampo.TagString, aValor);
end;

procedure TFrmProduto.TeclaNumero(const aValue: String);
var
  aStr   : String;
  aValor : Currency;
begin
  aStr := Trim(labelValorCampo.Text) + Trim(aValue);
  aStr := aStr.Replace('.', '', [rfReplaceAll]);
  aStr := aStr.Replace(',', '', [rfReplaceAll]);

  aValor := StrToCurrDef(aStr, 0) / 100;
  labelValorCampo.Text := FormatFloat(labelValorCampo.TagString, aValor);
end;

procedure TFrmProduto.EditarProduto(const aItemIndex : Integer);
var
  aProduto : TProduto;
begin
  aProduto := TProduto(ListViewProduto.Items.Item[aItemIndex].TagObject);

  labelTituloCadastro.Text      := 'EDITAR PRODUTO';
  labelTituloCadastro.TagString := GUIDToString(aProduto.ID);
  labelTituloCadastro.TagFloat  := aProduto.Codigo;

  lblProdutoDescricao.Text := aProduto.Descricao;
  lblProdutoValor.Text     := FormatFloat(',0.00', aProduto.Valor);

  if (aProduto.Foto = nil) then
  begin
    imgProdutoFoto.Bitmap   := img_foto_novo_produto.Bitmap;
    imgProdutoFoto.TagFloat := 0;
  end
  else
  begin
    imgProdutoFoto.Bitmap.LoadFromStream(aProduto.Foto);
    imgProdutoFoto.TagFloat := 1;
  end;

  lytProdutoExcluir.Visible := True;
end;

procedure TFrmProduto.ExcluirProduto(Sender: TObject);
var
  aItemIndex : Integer;
  msg : TFrmMensagem;
  dao : TProdutoDao;
begin
  try
    msg := TFrmMensagem.GetInstance;
    dao := TProdutoDao.GetInstance;
    aItemIndex := ListViewProduto.ItemIndex;
    dao.Model  := TProduto(ListViewProduto.Items.Item[aItemIndex].TagObject);
    if Assigned(dao.Model) then
    begin
      msg.Close;
      if dao.PodeExcluir then
      begin
        dao.Delete();
        ListViewProduto.Items.Delete(aItemIndex);
        ChangeTabActionConsulta.ExecuteTarget(Sender);
      end
      else
        ExibirMsgAlerta('Produto n�o pode ser exclu�do por est� sendo usado em pedidos');
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar excluir o produto.' + #13 + E.Message);
  end;
end;

procedure TFrmProduto.FormatarItemProdutoListView(aItem: TListViewItem);
var
  aProduto : TProduto;
  aText    : TListItemText;
//  aImage   : TListItemImage;
//  aBitmat  : TBitmap;
begin
  with aItem do
  begin
    aProduto := TProduto(aItem.TagObject);

    // Descri��o
    aText := TListItemText(Objects.FindDrawable('Text2'));
    aText.Text     := aProduto.Descricao;
    aText.WordWrap := True;

    // Valor (R$)
    aText := TListItemText(Objects.FindDrawable('Text1'));
    aText.Text := 'R$ ' + FormatFloat(',0.00', aProduto.Valor);
//
//    // Foto
//    aImage := TListItemImage(Objects.FindDrawable('Image4'));
//    if Assigned(aProduto.Foto) then
//    begin
//      aBitmat := TBitmap.Create;
//      aBitmat.LoadFromStream(aProduto.Foto);
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

procedure TFrmProduto.FormCreate(Sender: TObject);
begin
  inherited;
  img_produto_sem_foto.Visible  := False;
  img_foto_novo_produto.Visible := False;
end;

procedure TFrmProduto.FormShow(Sender: TObject);
begin
  inherited;
  DoBuscaProdutos(nil);
end;

procedure TFrmProduto.ListViewProdutoItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  EditarProduto(ItemIndex);
  ChangeTabActionCadastro.ExecuteTarget(Sender);
end;

procedure TFrmProduto.ListViewProdutoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  FormatarItemProdutoListView(AItem);
end;

end.
