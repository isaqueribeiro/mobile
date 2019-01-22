unit UPedido;

interface

uses
  model.Cliente,
  dao.Pedido,
  dao.Cliente,
  interfaces.Cliente,

  System.StrUtils,
  System.Math,
  System.DateUtils,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.DateTimeCtrls;

type
  TFrmPedido = class(TFrmPadraoCadastro, IObservadorCliente)
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
    procedure DoBuscarCliente(Sender: TObject);
    procedure DoEditarCampo(Sender: TObject);
    procedure DoSalvarPedido(Sender: TObject);
    procedure DoInserirItemPedido(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure imgClienteClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  strict private
    { Private declarations }
    aDao : TPedidoDao;

    procedure AtualizarCliente;

    procedure ControleEdicao(const aEditar : Boolean);

//    procedure AdicionarObservador(Observer : IObservadorCliente);
//    procedure RemoverObservador(Observer : IObservadorCliente);
//    procedure RemoverTodosObservadores;
    procedure Notificar;

    class var aInstance : TFrmPedido;
  public
    { Public declarations }
    property Dao : TPedidoDao read aDao;

    class function GetInstance : TFrmPedido;
  end;

  procedure NovoCadastroPedido(); //(Observer : IObservadorPedido);
  procedure ExibirCadastroPedido(); //(Observer : IObservadorPedido);

//var
//  FrmPedido: TFrmPedido;

implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UDM
  , UMensagem
  , UCliente
  , UPedidoItem;

procedure NovoCadastroPedido(); //(Observer : IObservadorPedido);
var
  aForm : TFrmPedido;
begin
  aForm := TFrmPedido.GetInstance;
//  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab       := tbsCadastro;
    imageVoltarConsulta.OnClick := imageVoltarClick;

    Model.ID   := GUID_NULL;
    Model.Tipo := TTipoPedido.tpOrcamento;
    Model.DataEmissao := Date;

    labelTituloCadastro.Text      := 'NOVO PEDIDO';
    labelTituloCadastro.TagString := GUIDToString(GUID_NULL); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := 0;                       // Destinado a guardar o CODIGO numérico do registro

    lblCliente.Text      := 'Informe aqui o cliente do novo pedido';
    lblCliente.TagString := GUIDToString(GUID_NULL);
    lblTipo.Text         := GetDescricaoTipoPedidoStr(Model.Tipo); // 'Informe aqui o tipo do novo pedido';
    lblTipo.TagString    := GetTipoPedidoStr(Model.Tipo);
    lblData.Text         := FormatDateTime('dd/mm/yyyy', Dao.Model.DataEmissao);
    lblData.TagString    := 'dd/mm/yyyy';
    lblContato.Text      := 'Informe aqui o(s) contato(s) do novo pedido';
    lblObs.Text          := 'Informe aqui as observações para o novo pedido';

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
    lblTotalPedido.TagFloat := 0;

    lytExcluir.Visible := False;

    DoMudarAbaPedido(lblAbaDadoPedido);
  end;

  aForm.Show;
end;

procedure ExibirCadastroPedido(); //(Observer : IObservadorPedido);
var
  aForm : TFrmPedido;
begin
  aForm := TFrmPedido.GetInstance;
//  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab       := tbsCadastro;
    imageVoltarConsulta.OnClick := imageVoltarClick;

    if (Model.Tipo = TTipoPedido.tpOrcamento) then
      labelTituloCadastro.Text := 'EDITAR PEDIDO'
    else
      labelTituloCadastro.Text := 'PEDIDO #' + FormatFloat('00000', Model.Codigo);

    labelTituloCadastro.TagString := GUIDToString(Model.ID); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro

    lblCliente.Text      := Model.Cliente.Nome + ' - ' + Model.Cliente.CpfCnpj;
    lblCliente.TagString := GUIDToString(Model.Cliente.ID);
    lblTipo.Text         := GetDescricaoTipoPedidoStr(Model.Tipo); // 'Informe aqui o tipo do novo pedido';
    lblTipo.TagString    := GetTipoPedidoStr(Model.Tipo);
    lblData.Text         := FormatDateTime('dd/mm/yyyy', Model.DataEmissao);
    lblData.TagString    := 'dd/mm/yyyy';
    lblContato.Text      := Model.Contato;
    lblObs.Text          := Model.Observacao;

    lblTotalPedido.TagString := ',0.00';
    lblTotalPedido.Text      := FormatFloat(lblTotalPedido.TagString, Model.ValorPedido);

    lblCliente.TagFloat     := IfThen(Trim(Model.Cliente.Nome) = EmptyStr, 0, 1); // Flags: 0 - Sem edição; 1 - Dado editado
    lblTipo.TagFloat        := 0;
    lblData.TagFloat        := 0;
    lblContato.TagFloat     := IfThen(Trim(Model.Contato)    = EmptyStr, 0, 1);
    lblObs.TagFloat         := IfThen(Trim(Model.Observacao) = EmptyStr, 0, 1);
    lblTotalPedido.TagFloat := IfThen(Model.ValorTotal      <= 0.0     , 0, 1);

    lytExcluir.Visible := True;

    DoMudarAbaPedido(lblAbaDadoPedido);
  end;

  aForm.Show;
end;

procedure TFrmPedido.AtualizarCliente;
var
  daoCliente : TClienteDao;
begin
  daoCliente := TClienteDao.GetInstance;
  lblCliente.Text      := daoCliente.Model.Nome + ' - ' + daoCliente.Model.CpfCnpj;
  lblCliente.TagString := GUIDToString(daoCliente.Model.ID);
  lblCliente.TagFloat  := 1;
  Dao.Model.Cliente    := daoCliente.Model;
end;

procedure TFrmPedido.ControleEdicao(const aEditar: Boolean);
begin
  imageSalvarCadastro.Visible := aEditar;
  imageSalvarEdicao.Visible   := aEditar;
end;

procedure TFrmPedido.DoBuscarCliente(Sender: TObject);
begin
  if Dao.Model.Tipo = TTipoPedido.tpOrcamento then
    SelecionarCliente(Self);
end;

procedure TFrmPedido.DoEditarCampo(Sender: TObject);
var
  aTag : Integer;
begin
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
    2 : // Data
      begin
        layoutDataCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelData.Text);
        labelTituloEditar.TagString := EmptyStr;
        labelTituloEditar.TagString := '*'; // Campo obrigatório

        editDateCampo.DateTime  := StrToDate('dd/mm/yyyy', lblData.Text);
        editDateCampo.TagString := EmptyStr;
        editDateCampo.TagObject := TObject(lblData);
      end;

    3 : // Contato(s)
      begin
        layoutMemoCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelContato.Text);
        labelTituloEditar.TagString := EmptyStr;
        labelTituloEditar.TagString := '*'; // Campo obrigatório

        mmMemoCampo.Text         := IfThen(lblContato.TagFloat = 0, EmptyStr, lblContato.Text);
        mmMemoCampo.MaxLength    := 100;
        mmMemoCampo.TextAlign    := TTextAlign.Leading;
        mmMemoCampo.KeyboardType := TVirtualKeyboardType.Default;
        mmMemoCampo.TagString    := EmptyStr;
        mmMemoCampo.TagObject    := TObject(lblContato);
      end;

    4 : // Observações
      begin
        layoutMemoCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelObs.Text);
        labelTituloEditar.TagString := EmptyStr;

        mmMemoCampo.Text         := IfThen(lblObs.TagFloat = 0, EmptyStr, lblObs.Text);
        mmMemoCampo.MaxLength    := 500;
        mmMemoCampo.TextAlign    := TTextAlign.Leading;
        mmMemoCampo.KeyboardType := TVirtualKeyboardType.Default;
        mmMemoCampo.TagString    := EmptyStr;
        mmMemoCampo.TagObject    := TObject(lblObs);
      end;
  End;

  ChangeTabActionEditar.ExecuteTarget(Sender);
end;

procedure TFrmPedido.DoInserirItemPedido(Sender: TObject);
begin
  NovoItemPedido();
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

procedure TFrmPedido.DoSalvarPedido(Sender: TObject);
var
  ins : Boolean;
  inf : Extended;
begin
  try
    inf :=
      lblCliente.TagFloat  +
//      lblTipo.TagFloat     +
//      lblData.TagFloat     +
      lblContato.TagFloat  +
      lblObs.TagFloat      +
      lblTotalPedido.TagFloat;

    if (inf = 0) then
      ExibirMsgAlerta('Sem dados informados!')
    else
    if (lblCliente.TagFloat = 0) or (Trim(lblCliente.Text) = EmptyStr) then
      ExibirMsgAlerta('Selecione um cliente para o pedido!')
    else
    if (lblTotalPedido.TagFloat = 0) then
      ExibirMsgAlerta('Pedido não possuem itens!')
    else
    begin
      dao.Model.ID     := StringToGUID(labelTituloCadastro.TagString);
      dao.Model.Codigo := labelTituloCadastro.TagFloat;

      dao.Model.Cliente.ID   := StringToGUID( IfThen(lblCliente.TagFloat  = 0, GUIDToString(GUID_NULL), lblCliente.TagString) );  // Postar dados na classe caso ele tenha sido editado
      dao.Model.Tipo         := GetTipoPedido(lblTipo.TagString);
      dao.Model.DataEmissao  := StrToDate(lblData.TagString, lblData.Text);
      dao.Model.Contato      := IfThen(lblContato.TagFloat   = 0, EmptyStr, lblContato.Text);
      dao.Model.Observacao   := IfThen(lblObs.TagFloat       = 0, EmptyStr, lblObs.Text);

      if (lblTotalPedido.TagFloat = 0) then
        dao.Model.ValorPedido := 0.0
      else
        dao.Model.ValorPedido := StrToCurr(lblTotalPedido.Text.Replace('.', '').Replace(',', '')) / 100;

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
      ExibirMsgErro('Erro ao tentar salvar o pedido.' + #13 + E.Message);
  end;
end;

procedure TFrmPedido.FormActivate(Sender: TObject);
begin
  inherited;
  ControleEdicao( (Dao.Model.Tipo = TTipoPedido.tpOrcamento) );
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

  imgTipo.Visible := False;
  lblTipo.Margins.Right := imgTipo.Margins.Right + imgTipo.Width;
end;

class function TFrmPedido.GetInstance: TFrmPedido;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmPedido, aInstance);
    Application.RealCreateForms;
  end;

//  if not Assigned(aInstance.FObservers) then
//    aInstance.FObservers := TList<IObservadorPedido>.Create;

  aInstance.aDao := TPedidoDao.GetInstance;

  Result := aInstance;
end;

procedure TFrmPedido.imgClienteClick(Sender: TObject);
var
  daoCliente : TClienteDao;
begin
  if (lblCliente.TagFloat = 1) then
  begin
    daoCliente := TClienteDao.GetInstance;
    daoCliente.Load(lblCliente.TagString);
    daoCliente.Model := daoCliente.Lista[0];
    ExibirCadastroCliente(Self, False);
  end;
end;

procedure TFrmPedido.Notificar;
begin
  ;
end;

end.
