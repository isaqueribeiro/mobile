unit UProduto;

interface

uses
  System.StrUtils,
  System.Math,
  System.Generics.Collections,

  u99Permissions,
  model.Produto,
  dao.Produto,
  interfaces.Produto,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Actions, UPadrao, UPadraoCadastro, FMX.ActnList, FMX.TabControl, FMX.Ani,
  FMX.Memo, FMX.Edit, FMX.Objects, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms,
  FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.DateTimeCtrls,
  FMX.ScrollBox, FMX.MediaLibrary.Actions, FMX.StdActns;

type
  TFrmProduto = class(TFrmPadrao, IProdutoObservado)
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
    procedure DoSalvarProduto(Sender: TObject);
    procedure DoExcluirProduto(Sender : TObject);
    procedure DoTeclaBackSpace(Sender : TObject);
    procedure DoTeclaNumero(Sender : TObject);
    procedure DoTakePhotoFinishTaking(Image: TBitmap);

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
    procedure ListViewProdutoItemClickEx(const Sender: TObject;
      ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  strict private
    { Private declarations }
    aDao : TProdutoDao;
    aSelecionarProduto : Boolean;
    FObservers : TList<IObservadorProduto>;
    FPermissao : T99Permissions;
    procedure FormatarItemProdutoListView(aItem  : TListViewItem);
    procedure AdicionarProdutoListView(aProduto : TProduto);

    procedure NovoProduto;
    procedure TeclaBackSpace;
    procedure TeclaNumero(const aValue : String);
    procedure BuscarProdutos(aBusca : String; aPagina : Integer);
    procedure EditarProduto(const aItemIndex : Integer);
    procedure ExcluirProduto(Sender: TObject);
    procedure ErroPermissao(Sender : TObject);

    function DevolverValorEditado : Boolean;

    class var aInstance : TFrmProduto;
  public
    { Public declarations }
    property Dao : TProdutoDao read aDao;
    property SelecionarProduto : Boolean read aSelecionarProduto write aSelecionarProduto;

    procedure ControleEdicao(const aEditar : Boolean);
    procedure AdicionarObservador(Observer : IObservadorProduto);
    procedure RemoverObservador(Observer : IObservadorProduto);
    procedure RemoverTodosObservadores;
    procedure Notificar;

    class function GetInstance : TFrmProduto;
  end;

  procedure ExibirListaProdutos;
  procedure ExibirCadastroProduto(Observer : IObservadorProduto; const aEditar : Boolean);
  procedure SelecionarProduto(Observer : IObservadorProduto);

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

  with aForm do
  begin
    tbsControle.ActiveTab       := tbsConsulta;
    imageVoltarConsulta.OnClick := imageVoltarConsultaClick;

    SelecionarProduto := False;
    ControleEdicao(True);
  end;

  aForm.Show;
end;

procedure ExibirCadastroProduto(Observer : IObservadorProduto; const aEditar : Boolean);
var
  aForm : TFrmProduto;
begin
  aForm := TFrmProduto.GetInstance;
  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab       := tbsCadastro;
    imageVoltarConsulta.OnClick := imageVoltarClick;

    labelTituloCadastro.Text      := IfThen(aEditar, 'EDITAR PRODUTO', 'PRODUTO');
    labelTituloCadastro.TagString := GUIDToString(Model.ID); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro

    imageSalvarCadastro.Visible := aEditar;

    lblProdutoDescricao.Text  := Model.Descricao;
    lblProdutoValor.TagString := ',0.00';
    lblProdutoValor.Text      := FormatFloat(lblProdutoValor.TagString, Model.Valor);

    lblProdutoDescricao.TagFloat := IfThen(Trim(Model.Descricao) = EmptyStr, 0, 1); // Flags: 0 - Sem edição; 1 - Dado editado
    lblProdutoValor.TagFloat     := IfThen(Model.Valor = 0.0, 0, 1);

    if (Model.Foto = nil) then
    begin
      imgProdutoFoto.Bitmap   := img_foto_novo_produto.Bitmap;
      imgProdutoFoto.TagFloat := 0;
    end
    else
    begin
      //imgProdutoFoto.Bitmap.LoadFromStream(Model.Foto);
      imgProdutoFoto.Bitmap.Assign( Model.Foto );
      imgProdutoFoto.TagFloat := 1;
    end;

    lytProdutoExcluir.Visible := aEditar;
    SelecionarProduto         := False;

    ControleEdicao(aEditar);
  end;

  aForm.Show;
end;

procedure SelecionarProduto(Observer : IObservadorProduto);
var
  aForm : TFrmProduto;
begin
  aForm := TFrmProduto.GetInstance;
  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab       := tbsConsulta;
    imageVoltarConsulta.OnClick := imageVoltarConsultaClick;

    labelTitulo.Text       := 'BUSCAR PRODUTO';
    imageAdicionar.Visible := False;
    editBuscaProduto.Text  := EmptyStr;

    ListViewProduto.BeginUpdate;
    ListViewProduto.Items.Clear;
    ListViewProduto.EndUpdate;

    SelecionarProduto := True;
    ControleEdicao(False);
  end;

  aForm.Show;
  aForm.editBuscaProduto.SetFocus;
end;

{ TFrmProduto }

class function TFrmProduto.GetInstance: TFrmProduto;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmProduto, aInstance);
    Application.RealCreateForms;
  end;

  if not Assigned(aInstance.FObservers) then
    aInstance.FObservers := TList<IObservadorProduto>.Create;

  aInstance.aDao := TProdutoDao.GetInstance;

  Result := aInstance;
end;

procedure TFrmProduto.imageAdicionarClick(Sender: TObject);
begin
  NovoProduto;
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
  OcultarPainelOpacity;
  FPermissao.PhotoLibrary(actTakePhotoFromLibrary, ErroPermissao);
end;

procedure TFrmProduto.lblCapturarImagemCameraClick(Sender: TObject);
begin
  OcultarPainelOpacity;
  FPermissao.Camera(actTakePhotoFromCamera, ErroPermissao);
end;

procedure TFrmProduto.AdicionarObservador(Observer: IObservadorProduto);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

procedure TFrmProduto.AdicionarProdutoListView(aProduto: TProduto);
var
  aItem   : TListViewItem;
  aImage  : TListItemImage;
//  aBitmat : TBitmap;
begin
  aItem := ListViewProduto.Items.Add;
  aItem.TagObject := aProduto;

  // Foto
  aImage := TListItemImage(aItem.Objects.FindDrawable('Image4'));
  if Assigned(aProduto.Foto) then
  begin
//    aBitmat := TBitmap.Create;
//    aBitmat.LoadFromStream(aProduto.Foto);
//    aImage.OwnsBitmap  := True;
//    aImage.Bitmap      := aBitmat;
//    aImage.ScalingMode := TImageScalingMode.Stretch;
    aImage.OwnsBitmap  := True;
    aImage.Bitmap.Assign( aProduto.Foto );
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

procedure TFrmProduto.ControleEdicao(const aEditar: Boolean);
begin
  imageSalvarCadastro.Visible := aEditar;
  imageSalvarEdicao.Visible   := aEditar;
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
    if (Trim(editEditarCampo.TagString) <> EmptyStr) then  // Máscara para formatação numérica
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
    if (Trim(labelValorCampo.TagString) <> EmptyStr) then  // Máscara para formatação numérica
    begin
      aStr := aStr.Replace('.', '', [rfReplaceAll]);
      aStr := FormatFloat(Trim(labelValorCampo.TagString), StrToCurrDef(aStr, 0));
    end;
  end;

  if (aObj <> nil) then
  begin
    if aObj is TLabel then
    begin
      TLabel(aObj).Text     := aStr;
      TLabel(aObj).TagFloat := IfThen(aStr.Trim = EmptyStr, 0, 1);
    end
    else
    if aObj is TEdit then
    begin
      TEdit(aObj).Text     := aStr;
      TEdit(aObj).TagFloat := IfThen(aStr.Trim = EmptyStr, 0, 1);
    end;
  end;

  if (Trim(aStr) = EmptyStr) then
    ExibirMsgAlerta('Este campo é obrigatório!')
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

procedure TFrmProduto.DoSalvarProduto(Sender: TObject);
var
  ins : Boolean;
  dao : TProdutoDao;
  aItem  : TListViewItem;
  aValor : String;
  inf : Extended;
begin
  try
    inf :=
      lblProdutoDescricao.TagFloat  +
      lblProdutoValor.TagFloat;

    if (inf = 0) then
      ExibirMsgAlerta('Sem dados informados!')
    else
    begin
      dao := TProdutoDao.GetInstance;
      dao.Model.ID        := StringToGUID(labelTituloCadastro.TagString);
      dao.Model.Codigo    := labelTituloCadastro.TagFloat;
      dao.Model.Descricao := lblProdutoDescricao.Text;
      dao.Model.Sincronizado := False;

      aValor := Trim(lblProdutoValor.Text);
      aValor := aValor.Replace('.', '', [rfReplaceAll]);
      aValor := aValor.Replace(',', '', [rfReplaceAll]);

      dao.Model.Valor := StrToCurrDef(aValor, 0) / 100;

      if (imgProdutoFoto.TagFloat > 0) then
      begin
//        dao.Model.Foto := TMemoryStream.Create;
//        dao.Model.Foto.Position := 0;
//        imgProdutoFoto.Bitmap.SaveToStream(dao.Model.Foto);
        dao.Model.Foto.Assign( imgProdutoFoto.Bitmap );
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
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar salvar o produto.' + #13 + E.Message);
  end;
end;

procedure TFrmProduto.DoTakePhotoFinishTaking(Image: TBitmap);
begin
  imgProdutoFoto.Bitmap := Image;
end;

procedure TFrmProduto.DoTeclaBackSpace(Sender: TObject);
begin
  TeclaBackSpace;
end;

procedure TFrmProduto.DoTeclaNumero(Sender: TObject);
begin
  TeclaNumero( TLabel(Sender).Text );
end;

procedure TFrmProduto.Notificar;
var
  Observer : IObservadorProduto;
begin
  for Observer in FObservers do
     Observer.AtualizarProduto;
end;

procedure TFrmProduto.NovoProduto;
begin
  labelTituloCadastro.Text      := 'NOVO PRODUTO';
  labelTituloCadastro.TagString := GUIDToString(GUID_NULL);
  labelTituloCadastro.TagFloat  := 0;

  lblProdutoDescricao.Text := 'Informe aqui a descrição do novo produto';
  lblProdutoValor.Text     := '0,00';
  imgProdutoFoto.Bitmap    := img_foto_novo_produto.Bitmap;

  lblProdutoDescricao.TagFloat := 0;
  lblProdutoValor.TagFloat     := 0;
  imgProdutoFoto.TagFloat      := 0;

  lytProdutoExcluir.Visible := False;
  SelecionarProduto         := False;
end;

procedure TFrmProduto.RemoverObservador(Observer: IObservadorProduto);
begin
  FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmProduto.RemoverTodosObservadores;
var
  I : Integer;
begin
  for I := 0 to (FObservers.Count - 1) do
    FObservers.Delete(I);
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

  lblProdutoDescricao.Text  := aProduto.Descricao;
  lblProdutoValor.TagString := ',0.00';
  lblProdutoValor.Text      := FormatFloat(lblProdutoValor.TagString, aProduto.Valor);

  lblProdutoDescricao.TagFloat := IfThen(Trim(aProduto.Descricao) = EmptyStr, 0, 1); // Flags: 0 - Sem edição; 1 - Dado editado
  lblProdutoValor.TagFloat     := IfThen(aProduto.Valor = 0.0, 0, 1);

  if (aProduto.Foto = nil) then
  begin
    imgProdutoFoto.Bitmap   := img_foto_novo_produto.Bitmap;
    imgProdutoFoto.TagFloat := 0;
  end
  else
  begin
    //imgProdutoFoto.Bitmap.LoadFromStream(aProduto.Foto);
    imgProdutoFoto.Bitmap.Assign( aProduto.Foto );
    imgProdutoFoto.TagFloat := 1;
  end;

  lytProdutoExcluir.Visible := True;
  SelecionarProduto         := False;
end;

procedure TFrmProduto.ErroPermissao(Sender: TObject);
var
  msg : TFrmMensagem;
begin
  msg := TFrmMensagem.GetInstance;
  msg.Close;
  ExibirMsgErro('Você não possui permissão de acesso para este recurso.');
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
        ExibirMsgAlerta('Produto não pode ser excluído por está sendo usado em pedidos');
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

    // Descrição
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

procedure TFrmProduto.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  RemoverTodosObservadores;
end;

procedure TFrmProduto.FormCreate(Sender: TObject);
begin
  inherited;
  aSelecionarProduto := False;
//  FObservers := TList<IObservadorProduto>.Create;
  FPermissao := T99Permissions.Create;

  img_produto_sem_foto.Visible  := False;
  img_foto_novo_produto.Visible := False;
end;

procedure TFrmProduto.FormDestroy(Sender: TObject);
begin
  inherited;
  FPermissao.DisposeOf;
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
  if (TListView(Sender).Selected <> nil) then
  begin
    Dao.Model := TProduto(ListViewProduto.Items.Item[ItemIndex].TagObject);

    if SelecionarProduto then
    begin
      Self.Notificar;
      Self.Close;
    end
    else
    begin
      EditarProduto(ItemIndex);
      ChangeTabActionCadastro.ExecuteTarget(Sender);
    end;
  end;
end;

procedure TFrmProduto.ListViewProdutoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  FormatarItemProdutoListView(AItem);
end;

end.
