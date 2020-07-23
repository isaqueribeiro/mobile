unit ULoja;

interface

uses
  System.StrUtils,
  System.Math,
  System.Generics.Collections,

  model.Loja,
  dao.Loja,
  interfaces.Loja,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.DateTimeCtrls;

type
  TFrmLoja = class(TFrmPadraoCadastro, ILojaObservado)
    LayoutCPF_CNPJ: TLayout;
    LineCPF_CNPJ: TLine;
    LabelCPF_CNPJ: TLabel;
    imgCPF_CNPJ: TImage;
    lblCPF_CNPJ: TLabel;
    lytFantasia: TLayout;
    LineFantasia: TLine;
    LabelFantasia: TLabel;
    imgFantasia: TImage;
    lblFantasia: TLabel;
    lytTelefone: TLayout;
    LineTelefone: TLine;
    LabelTelefone: TLabel;
    imgTelefone: TImage;
    lblTelefone: TLabel;
    lytEmail: TLayout;
    LineEmail: TLine;
    LabelEmail: TLabel;
    imgEmail: TImage;
    lblEmail: TLabel;
    lytObs: TLayout;
    LineObs: TLine;
    LabelObs: TLabel;
    imgObs: TImage;
    lblObs: TLabel;
    layoutBuscaLoja: TLayout;
    rectangleBuscaLoja: TRectangle;
    editBuscaLoja: TEdit;
    imageBuscaLoja: TImage;
    ListViewLoja: TListView;
    imgSemLoja: TImage;
    lblSemLoja: TLabel;
    img_sinc: TImage;
    img_nao_sinc: TImage;
    procedure DoEditarCampo(Sender: TObject);
    procedure DoSalvarLoja(Sender: TObject);
    procedure DoExcluirLoja(Sender : TObject);
    procedure DoBuscaLojas(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListViewLojaUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewLojaItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure FormShow(Sender: TObject);
  strict private
    { Private declarations }
    aDao : TLojaDao;
    aSelecionarLoja : Boolean;
    FObservers : TList<IObservadorLoja>;
    FEditar : Boolean;
    procedure FormatarValorCampo(var aStr : String);
    procedure ExcluirLoja(Sender: TObject);
    procedure BuscarLojas(aBusca : String; aPagina : Integer);

    procedure FormatarItemLojaListView(aItem  : TListViewItem);
    procedure AddLojaListView(aLoja : TLoja);

    class var aInstance : TFrmLoja;
  public
    { Public declarations }
    property Dao : TLojaDao read aDao;
    property SelecionarLoja : Boolean read aSelecionarLoja write aSelecionarLoja;
    property Editar : Boolean read FEditar write FEditar;

    procedure TeclaBackSpace; override;
    procedure TeclaNumero(const aValue : String); override;
    procedure ControleEdicao(const aEditar : Boolean);

    procedure AdicionarObservador(Observer : IObservadorLoja);
    procedure RemoverObservador(Observer : IObservadorLoja);
    procedure RemoverTodosObservadores;
    procedure Notificar;

    class function GetInstance : TFrmLoja;
  end;

//  procedure NovoCadastroLoja(Observer : IObservadorLoja);
  procedure ExibirCadastroLoja(Observer : IObservadorLoja; const aEditar : Boolean);
  procedure SelecionarLoja(Observer : IObservadorLoja);

//var
//  FrmLoja: TFrmLoja;
//
implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UMensagem;

//procedure NovoCadastroLoja(Observer : IObservadorLoja);
//var
//  aForm : TFrmLoja;
//begin
//  aForm := TFrmLoja.GetInstance;
//  aForm.AdicionarObservador(Observer);
//
//  with aForm do
//  begin
//    tbsControle.ActiveTab       := tbsCadastro;
//    imageVoltarConsulta.OnClick := imageVoltarClick;
//
//    labelTituloCadastro.Text      := 'NOVO Loja';
//    labelTituloCadastro.TagString := GUIDToString(GUID_NULL); // Destinado a guardar o ID guid do registro
//    labelTituloCadastro.TagFloat  := 0;                       // Destinado a guardar o CODIGO numérico do registro
//
//    lblCPF_CNPJ.Text  := 'Informe aqui o número de CPF/CNPJ do novo Loja';
//    lblDescricao.Text := 'Informe aqui o nome do novo Loja';
//    lblEndereco.Text  := 'Informe aqui o endereço do novo Loja';
//    lblTelefone.Text  := 'Informe aqui o númeor de telefone do novo Loja';
//    lblEmail.Text     := 'Informe aqui o e-mail do novo Loja';
//    lblObs.Text       := 'Insira aqui as observações sobre o Loja';
//
//    lblCPF_CNPJ.TagFloat  := 0; // Flags: 0 - Sem edição; 1 - Dado editado
//    lblDescricao.TagFloat := 0;
//    lblEndereco.TagFloat  := 0;
//    lblTelefone.TagFloat  := 0;
//    lblEmail.TagFloat     := 0;
//    lblObs.TagFloat       := 0;
//
//    lytExcluir.Visible := False;
//    SelecionarLoja  := False;
//
//    ControleEdicao(True);
//  end;
//
//  aForm.Show;
//end;
//
procedure ExibirCadastroLoja(Observer : IObservadorLoja; const aEditar : Boolean);
var
  aForm : TFrmLoja;
begin
  aForm := TFrmLoja.GetInstance;
  aForm.AdicionarObservador(Observer);
  aForm.Editar := aEditar;

  with aForm, dao do
  begin
    tbsControle.ActiveTab       := tbsCadastro;
    imageVoltarConsulta.OnClick := imageVoltarClick;

    labelTituloCadastro.Text      := IfThen(aEditar, 'EDITAR LOJA', 'LOJA');
    labelTituloCadastro.TagString := GUIDToString(Model.ID); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro

    imageSalvarCadastro.Visible := aEditar;

    lblCPF_CNPJ.Text  := Model.CpfCnpj;
    lblDescricao.Text := Model.Nome;
    lblFantasia.Text  := Model.Fantasia;
//    lblTelefone.Text  := Model.Telefone;
//    lblEmail.Text     := Model.Email;
//    lblObs.Text       := Model.Observacao;

    lblCPF_CNPJ.TagFloat  := IfThen(Trim(Model.CpfCnpj)    = EmptyStr, 0, 1); // Flags: 0 - Sem edição; 1 - Dado editado
    lblDescricao.TagFloat := IfThen(Trim(Model.Nome)       = EmptyStr, 0, 1);
    lblFantasia.TagFloat  := IfThen(Trim(Model.Fantasia)   = EmptyStr, 0, 1);
//    lblTelefone.TagFloat  := IfThen(Trim(Model.Telefone)   = EmptyStr, 0, 1);
//    lblEmail.TagFloat     := IfThen(Trim(Model.Email)      = EmptyStr, 0, 1);
//    lblObs.TagFloat       := IfThen(Trim(Model.Observacao) = EmptyStr, 0, 1);

    lytExcluir.Visible := aEditar;
    SelecionarLoja  := False;

    ControleEdicao(aEditar);
  end;

  aForm.Show;
end;

procedure SelecionarLoja(Observer : IObservadorLoja);
var
  aForm : TFrmLoja;
begin
  aForm := TFrmLoja.GetInstance;
  aForm.AdicionarObservador(Observer);
  aForm.Editar := False;

  with aForm, dao do
  begin
    tbsControle.ActiveTab       := tbsConsulta;
    imageVoltarConsulta.OnClick := imageVoltarConsultaClick;

    labelTitulo.Text       := 'BUSCAR LOJA';
    imageAdicionar.Visible := False;
    editBuscaLoja.Text  := EmptyStr;

    ListViewLoja.BeginUpdate;
    ListViewLoja.Items.Clear;
    ListViewLoja.EndUpdate;

    SelecionarLoja := True;
    ControleEdicao(False);
  end;

  aForm.Show;
  aForm.editBuscaLoja.SetFocus;
end;

{ TFrmLoja }

procedure TFrmLoja.AddLojaListView(aLoja: TLoja);
var
  aItem  : TListViewItem;
begin
  aItem := ListViewLoja.Items.Add;
  aItem.TagObject := aLoja;
  FormatarItemLojaListView(aItem);
end;

procedure TFrmLoja.AdicionarObservador(Observer: IObservadorLoja);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

procedure TFrmLoja.BuscarLojas(aBusca: String; aPagina: Integer);
var
  dao : TLojaDao;
  I : Integer;
begin
  dao := TLojaDao.GetInstance;
  dao.Load(aBusca);
  for I := Low(dao.Lista) to High(dao.Lista) do
    AddLojaListView(dao.Lista[I]);
end;

procedure TFrmLoja.ControleEdicao(const aEditar: Boolean);
begin
  imgCPF_CNPJ.Visible  := aEditar;
  imgDescricao.Visible := aEditar;
  imgFantasia.Visible  := aEditar;
//  imgTelefone.Visible  := aEditar;
//  imgEmail.Visible     := aEditar;
//  imgObs.Visible       := aEditar;

  lblCPF_CNPJ.Margins.Right  := IfThen(aEditar, 5, imgCPF_CNPJ.Margins.Right);
  lblDescricao.Margins.Right := IfThen(aEditar, 5, imgDescricao.Margins.Right);
  lblFantasia.Margins.Right  := IfThen(aEditar, 5, imgFantasia.Margins.Right);
//  lblTelefone.Margins.Right  := IfThen(aEditar, 5, imgTelefone.Margins.Right);
//  lblEmail.Margins.Right     := IfThen(aEditar, 5, imgEmail.Margins.Right);
//  lblObs.Margins.Right       := IfThen(aEditar, 5, imgObs.Margins.Right);
end;

procedure TFrmLoja.DoBuscaLojas(Sender: TObject);
begin
  try
    ImgSemLoja.Visible := False;

    ListViewLoja.BeginUpdate;
    ListViewLoja.Items.Clear;

    BuscarLojas(editBuscaLoja.Text, 0);

    ListViewLoja.EndUpdate;
    ImgSemLoja.Visible := (ListViewLoja.Items.Count = 0);
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tenta carregar as Lojas.' + #13 + E.Message);
  end;
end;

procedure TFrmLoja.DoEditarCampo(Sender: TObject);
var
  aTag : Integer;
begin
  if not FEditar then
    Exit;

  // Propriedade TAG é usada para armazenar as sequencia dos campos no formulário
  if (Sender is TLabel) then
    aTag := TLabel(Sender).Tag
  else
  if (Sender is TImage) then
    aTag := TImage(Sender).Tag
  else
    aTag := 0;

  layoutEditCampo.Visible  := False;
  layoutDataCampo.Visible  := False;
  layoutMemoCampo.Visible  := False;
  layoutValorCampo.Visible := False;

  Case aTag of
    0 :
      begin
        layoutValorCampo.Visible    := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelCPF_CNPJ.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        labelValorCampo.Text      := IfThen(lblCPF_CNPJ.TagFloat = 0, EmptyStr, lblCPF_CNPJ.Text);
        labelValorCampo.TagString := 'cpf/cnpj';           // Flag para formatação do valor
        labelValorCampo.TagObject := TObject(lblCPF_CNPJ); // Objeto de origem da informação. O dado editado será devolvido para ele.
      end;

    1 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelDescricao.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        editEditCampo.Text         := IfThen(lblDescricao.TagFloat = 0, EmptyStr, lblDescricao.Text);
        editEditCampo.MaxLength    := 250;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
        editEditCampo.TextPrompt   := 'Informe aqui a razão social da nova loja';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblDescricao);
//
//        editEditCampo.SetFocus;
//        editEditCampo.SelStart := Length(editEditCampo.Text);
      end;

    2 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelFantasia.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        editEditCampo.Text         := IfThen(lblFantasia.TagFloat = 0, EmptyStr, lblFantasia.Text);
        editEditCampo.MaxLength    := 250;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
        editEditCampo.TextPrompt   := 'Informe aqui o nome fantasia da nova loja';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblDescricao);
//
//        editEditCampo.SetFocus;
//        editEditCampo.SelStart := Length(editEditCampo.Text);
      end;
//
//    3 :
//      begin
//        layoutValorCampo.Visible    := True;
//        labelTituloEditar.Text      := AnsiUpperCase(LabelTelefone.Text);
//        labelTituloEditar.TagString := EmptyStr;
//
//        labelValorCampo.Text      := IfThen(lblTelefone.TagFloat = 0, EmptyStr, lblTelefone.Text);
//        labelValorCampo.TagString := 'fone';               // Flag para formatação do valor
//        labelValorCampo.TagObject := TObject(lblTelefone);
//      end;
//
//    4 :
//      begin
//        layoutEditCampo.Visible     := True;
//        labelTituloEditar.Text      := AnsiUpperCase(LabelEmail.Text);
//        labelTituloEditar.TagString := EmptyStr;
//
//        editEditCampo.Text         := IfThen(lblEmail.TagFloat = 0, EmptyStr, lblEmail.Text);
//        editEditCampo.MaxLength    := 150;
//        editEditCampo.TextAlign    := TTextAlign.Leading;
//        editEditCampo.KeyboardType := TVirtualKeyboardType.EmailAddress;
//        editEditCampo.TextPrompt   := 'Informe aqui o e-mail';
//        editEditCampo.TagString    := EmptyStr;
//        editEditCampo.TagObject    := TObject(lblEmail);
////
////        editEditCampo.SetFocus;
////        editEditCampo.SelStart := Length(editEditCampo.Text);
//      end;
//
//    5 :
//      begin
//        layoutMemoCampo.Visible     := True;
//        labelTituloEditar.Text      := AnsiUpperCase(LabelObs.Text);
//        labelTituloEditar.TagString := EmptyStr;
//
//        mmMemoCampo.Text         := IfThen(lblObs.TagFloat = 0, EmptyStr, lblObs.Text);
//        mmMemoCampo.MaxLength    := 500;
//        mmMemoCampo.TextAlign    := TTextAlign.Leading;
//        mmMemoCampo.KeyboardType := TVirtualKeyboardType.Default;
//        mmMemoCampo.TagString    := EmptyStr;
//        mmMemoCampo.TagObject    := TObject(lblObs);
////
////        mmMemoCampo.SetFocus;
////        mmMemoCampo.SelStart := Length(mmMemoCampo.Text);
//      end;
  end;

  ChangeTabActionEditar.ExecuteTarget(Sender);
end;

procedure TFrmLoja.DoExcluirLoja(Sender: TObject);
begin
  ExibirMsgConfirmacao('Excluir', 'Deseja excluir o Loja selecionado?', ExcluirLoja);
end;

procedure TFrmLoja.DoSalvarLoja(Sender: TObject);
var
  ins : Boolean;
  inf : Extended;
begin
  try
    inf :=
      lblCPF_CNPJ.TagFloat  +
      lblDescricao.TagFloat +
      lblFantasia.TagFloat; //  +
//      lblTelefone.TagFloat  +
//      lblEmail.TagFloat     +
//      lblObs.TagFloat;

    if (inf = 0) then
      ExibirMsgAlerta('Sem dados informados!')
    else
    if (lblCPF_CNPJ.TagFloat = 0) or (Trim(lblCPF_CNPJ.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe o número de CPF/CNPJ!')
    else
    if (lblDescricao.TagFloat = 0) or (Trim(lblDescricao.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe a razão social!')
    else
    if (lblFantasia.TagFloat = 0) or (Trim(lblFantasia.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe o nome fantasia!')
    else
    if (not StrIsCPF(lblCPF_CNPJ.Text)) and (not StrIsCNPJ(lblCPF_CNPJ.Text)) then
      ExibirMsgAlerta('Número de CPF/CNPJ inválido!')
    else
    begin
      dao.Model.ID        := StringToGUID(labelTituloCadastro.TagString);
      dao.Model.Codigo    := labelTituloCadastro.TagFloat;

      dao.Model.CpfCnpj    := IfThen(lblCPF_CNPJ.TagFloat  = 0, EmptyStr, lblCPF_CNPJ.Text);  // Postar dados na classe caso ele tenha sido editado
      dao.Model.Nome       := IfThen(lblDescricao.TagFloat = 0, EmptyStr, lblDescricao.Text);
      dao.Model.Fantasia   := IfThen(lblFantasia.TagFloat  = 0, EmptyStr, lblFantasia.Text);
//      dao.Model.Telefone   := IfThen(lblTelefone.TagFloat  = 0, EmptyStr, lblTelefone.Text);
//      dao.Model.Email      := IfThen(lblEmail.TagFloat     = 0, EmptyStr, lblEmail.Text);
//      dao.Model.Observacao := IfThen(lblObs.TagFloat       = 0, EmptyStr, lblObs.Text);

      ins := (dao.Model.ID = GUID_NULL);

      if ins then
        dao.Insert()
      else
        dao.Update();

      Self.Notificar;
      Self.Close;
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar salvar o Loja.' + #13 + E.Message);
  end;
end;

procedure TFrmLoja.ExcluirLoja(Sender: TObject);
var
  msg : TFrmMensagem;
begin
  try
    msg := TFrmMensagem.GetInstance;
    if Assigned(dao.Model) then
    begin
      msg.Close;
      if dao.PodeExcluir then
      begin
        dao.Delete();

        Self.Notificar;
        Self.Close;
      end
      else
        ExibirMsgAlerta('Loja não pode ser excluído por está sendo usado em pedidos');
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar excluir o Loja.' + #13 + E.Message);
  end;
end;

procedure TFrmLoja.FormActivate(Sender: TObject);
begin
  inherited;
  lytExcluir.Visible := (Trim(labelTituloCadastro.TagString) <> EmptyStr) and (labelTituloCadastro.TagString <> GUIDToString(GUID_NULL));
  lytExcluir.Visible := lytExcluir.Visible and imageSalvarCadastro.Visible;
end;

procedure TFrmLoja.FormatarItemLojaListView(aItem: TListViewItem);
var
  aText  : TListItemText;
  aImage : TListItemImage;
  aLoja : TLoja;
begin
  with aItem do
  begin
    aLoja := TLoja(aItem.TagObject);

    TListItemText(Objects.FindDrawable('Text1')).Text := aLoja.Fantasia;
    TListItemText(Objects.FindDrawable('Text2')).Text := aLoja.CpfCnpj;
    TListItemText(Objects.FindDrawable('Text3')).Text := aLoja.Nome;

    // Sincronizado com o Servidor Web
    aImage := TListItemImage(Objects.FindDrawable('Image4'));
    aImage.Bitmap := img_sinc.Bitmap
//    if StrIsCNPJ(aLoja.CpfCnpj) then
//      aImage.Bitmap := img_sinc.Bitmap
//    else
//      aImage.Bitmap := img_nao_sinc.Bitmap;
  end;
end;

procedure TFrmLoja.FormatarValorCampo(var aStr : String);
begin
  if (labelValorCampo.TagString = 'cpf/cnpj') then
  begin
    if (Length(aStr) > 11) then
      aStr := FormatarTexto('99.999.999/9999-99;0', aStr)
    else
      aStr := FormatarTexto('999.999.999-99;0', aStr);
  end
  else
  if (labelValorCampo.TagString = 'fone') then
  begin
    if (Length(aStr) > 10) then
      aStr := FormatarTexto('(99) 99999-9999;0', aStr)
    else
      aStr := FormatarTexto('(99) 9999-9999;0', aStr);
  end;

  labelValorCampo.Text := aStr;
end;

procedure TFrmLoja.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  RemoverTodosObservadores;
end;

procedure TFrmLoja.FormCreate(Sender: TObject);
begin
  inherited;
  aSelecionarLoja := False;
  FObservers := TList<IObservadorLoja>.Create;

  img_sinc.Visible     := False;
  img_nao_sinc.Visible := False;

  lytTelefone.Visible := False;
  lytEmail.Visible    := False;
  lytObs.Visible      := False;

  FEditar := True;
end;

procedure TFrmLoja.FormShow(Sender: TObject);
begin
  inherited;
  if (tbsControle.ActiveTab = tbsConsulta) then
    DoBuscaLojas(imageBuscaLoja);
end;

class function TFrmLoja.GetInstance: TFrmLoja;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmLoja, aInstance);
    Application.RealCreateForms;
  end;

  if not Assigned(aInstance.FObservers) then
    aInstance.FObservers := TList<IObservadorLoja>.Create;

  aInstance.aDao := TLojaDao.GetInstance;

  Result := aInstance;
end;

procedure TFrmLoja.ListViewLojaItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
begin
  if (TListView(Sender).Selected <> nil) then
  begin
    Dao.Model := TLoja(ListViewLoja.Items.Item[ItemIndex].TagObject);

    if SelecionarLoja then
    begin
      Self.Notificar;
      Self.Close;
    end;
  end;
end;

procedure TFrmLoja.ListViewLojaUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  FormatarItemLojaListView(AItem);
end;

procedure TFrmLoja.Notificar;
var
  Observer : IObservadorLoja;
begin
  for Observer in FObservers do
     Observer.AtualizarLoja;
end;

procedure TFrmLoja.RemoverObservador(Observer: IObservadorLoja);
begin
  FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmLoja.RemoverTodosObservadores;
var
  I : Integer;
//var
//  Observer : IObservadorLoja;
begin
  for I := 0 to (FObservers.Count - 1) do
    FObservers.Delete(I);
//  for Observer in FObservers do
//    FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmLoja.TeclaBackSpace;
var
  aStr : String;
begin
  aStr := Trim(labelValorCampo.Text);
  aStr := aStr.Replace('(', '', [rfReplaceAll]);
  aStr := aStr.Replace(')', '', [rfReplaceAll]);
  aStr := aStr.Replace('.', '', [rfReplaceAll]);
  aStr := aStr.Replace('-', '', [rfReplaceAll]);
  aStr := aStr.Replace('/', '', [rfReplaceAll]);
  aStr := aStr.Replace(' ', '', [rfReplaceAll]);

  if Length(aStr) > 1 then
    aStr := Copy(aStr, 1, Length(aStr) - 1)
  else
    aStr := '';

  FormatarValorCampo(aStr);
end;

procedure TFrmLoja.TeclaNumero(const aValue: String);
var
  aStr   : String;
  aValor : Currency;
begin
  if (labelValorCampo.TagString = ',0.00') then
    inherited
  else
  begin
    aStr := Trim(labelValorCampo.Text) + Trim(aValue);
    aStr := aStr.Replace('(', '', [rfReplaceAll]);
    aStr := aStr.Replace(')', '', [rfReplaceAll]);
    aStr := aStr.Replace('.', '', [rfReplaceAll]);
    aStr := aStr.Replace('-', '', [rfReplaceAll]);
    aStr := aStr.Replace('/', '', [rfReplaceAll]);
    aStr := aStr.Replace(' ', '', [rfReplaceAll]);

    FormatarValorCampo(aStr);
  end;
end;

end.
