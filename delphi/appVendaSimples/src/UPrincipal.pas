unit UPrincipal;

interface

uses
  app.Funcoes,
  model.Pedido,
  model.Cliente,
  model.Notificacao,
  dao.Usuario,
  dao.Loja,
  dao.Pedido,
  dao.Cliente,
  dao.Produto,
  dao.Notificacao,
  dao.Configuracao,
  interfaces.Usuario,
  interfaces.Cliente,
  interfaces.Pedido,

  System.StrUtils,
  System.Math,
  System.JSON,
  Web.HTTPApp,

  {$IFDEF ANDROID}
  FMX.VirtualKeyBoard,
  FMX.Platform,
  {$ENDIF}

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Ani;

type
  TFrmPrincipal = class(TForm, IObservadorCliente, IObservadorPedido, IObservadorUsuario)
    StyleBook: TStyleBook;
    layoutTabs: TLayout;
    layoutTabPedido: TLayout;
    layoutTabCliente: TLayout;
    layoutTabNotificacao: TLayout;
    layoutTabMais: TLayout;
    labelTabPedido: TLabel;
    imageTabPedido: TImage;
    labelTabCliente: TLabel;
    imageTabCliente: TImage;
    labelTabNotificacao: TLabel;
    imageTabNotificacao: TImage;
    labelTabMais: TLabel;
    imageTabMais: TImage;
    circleNotification: TCircle;
    labelNotification: TLabel;
    TabPedido: TLayout;
    rectangleTituloPedido: TRectangle;
    layoutBuscaPedido: TLayout;
    rectangleBuscaPedido: TRectangle;
    editBuscaPedido: TEdit;
    ListViewPedido: TListView;
    labelTituloPedido: TLabel;
    imageAddPedido: TImage;
    imageBuscaPedido: TImage;
    TabCliente: TLayout;
    rectangleTituloCliente: TRectangle;
    labelTituloCliente: TLabel;
    imageAddCliente: TImage;
    layoutBuscaCliente: TLayout;
    rectangleBuscaCliente: TRectangle;
    editBuscaCliente: TEdit;
    imageBuscaCliente: TImage;
    ListViewCliente: TListView;
    TabNotificacao: TLayout;
    rectangleTituloNotificacao: TRectangle;
    labelTituloNotificacao: TLabel;
    ListViewNotificacao: TListView;
    TabMais: TLayout;
    rectangleTituloMais: TRectangle;
    labelTituloMais: TLabel;
    layoutMaisOpcoes: TLayout;
    layoutMaisOpcoesL1: TLayout;
    imageProduto: TImage;
    labelProduto: TLabel;
    imageSincronizar: TImage;
    labelSincronizar: TLabel;
    layoutMaisOpcoesL2: TLayout;
    imageMeuPerfil: TImage;
    labelMeuPerfil: TLabel;
    imageIndicarApp: TImage;
    labelIndicarApp: TLabel;
    layoutMaisOpcoesL3: TLayout;
    imageSair: TImage;
    labelSair: TLabel;
    img_faturado: TImage;
    img_sinc: TImage;
    img_nao_sinc: TImage;
    img_lida: TImage;
    img_nao_lida: TImage;
    img_update: TImage;
    ImgSemPedido: TImage;
    lblSemPedido: TLabel;
    imgSemCliente: TImage;
    lblSemCliente: TLabel;
    imgSemNotificacao: TImage;
    lblSemNotificacao: TLabel;
    LayoutMenuNotificacao: TLayout;
    RectangleMenuNotificacao: TRectangle;
    fltNotificacaoEntrada: TFloatAnimation;
    fltNotificacaoSaida: TFloatAnimation;
    lytCancelarNotificacao: TLayout;
    rectangleCancelarImagem: TRectangle;
    lblCancelarImagem: TLabel;
    lytOpcoesNotificacao: TLayout;
    rectangleOpcoesNotificacao: TRectangle;
    lblMarcarNotificacao: TLabel;
    imgMarcarNotificacao: TImage;
    lineOpcoesNotificacao: TLine;
    lblExcluirNotificacao: TLabel;
    imgExcluirNotificacao: TImage;
    img_opcoes: TImage;
    TmrNotificacao: TTimer;
    img_entregue: TImage;
    procedure DoFecharApp(Sender: TObject);
    procedure DoCloseApp(Sender: TObject);
    procedure DoSelecinarTab(Sender: TObject);
    procedure DoExibirProdutos(Sender: TObject);
    procedure DoExibirPerfil(Sender: TObject);
    procedure DoCompartilharApp(Sender: TObject);
    procedure DoSincronizarDados(Sender: TObject);

    procedure DoBuscaPedidos(Sender: TObject);
    procedure DoBuscaClientes(Sender: TObject);
    procedure DoBuscaNotificacoes(Sender: TObject);

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imageAddPedidoClick(Sender: TObject);
    procedure imageAddClienteClick(Sender: TObject);
    procedure ListViewNotificacaoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewPedidoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure ListViewClienteUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure lblCancelarImagemClick(Sender: TObject);
    procedure ListViewNotificacaoItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure lblMarcarNotificacaoClick(Sender: TObject);
    procedure lblExcluirNotificacaoClick(Sender: TObject);
    procedure ListViewClienteItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure ListViewPedidoItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure TmrNotificacaoTimer(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    { Private declarations }
    procedure DefinirIndices;
    procedure SelecionarTab(const aTab : Smallint);
    procedure ExibirMenuNotificacao;
    procedure OcultarMenuNotificacao;
    procedure ContarNotificacoes;
    procedure BaixarNotificacoes;

    procedure BuscarPedidos(aBusca : String; aPagina : Integer);
    procedure BuscarClientes(aBusca : String; aPagina : Integer);
    procedure BuscarNotificacoes(aBusca : String; aPagina : Integer);

    procedure FormatarItemPedidoListView(aItem  : TListViewItem);
    procedure FormatarItemClienteListView(aItem  : TListViewItem);
    procedure FormatarItemNotificacaoListView(aItem  : TListViewItem);

    procedure AddPedidoListView(aPedido : TPedido);
    procedure AddClienteListView(aCliente : TCliente);
    procedure AddNotificacaoListView(aNotificacao : TNotificacao); virtual; abstract;

    procedure AtualizarNotificacao;
    procedure AtualizarCliente;
    procedure AtualizarUsuario;
    procedure AtualizarPedido;
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

const
  idxTabPedido      = 1;
  idxTabCliente     = 2;
  idxTabNotificacao = 3;
  idxTabMais        = 4;

implementation

{$R *.fmx}

uses
  UConstantes,
  UMensagem,
  UCliente,
  UProduto,
  UPedido,
  UPerfil,
  UCompartilhar,
  USincronizar,
  ULogin,
  UDM;

{ TFrmPrincipal }

procedure TFrmPrincipal.AddClienteListView(aCliente : TCliente);
var
  aItem  : TListViewItem;
begin
  aItem := ListViewCliente.Items.Add;
  aItem.TagObject := aCliente;
  FormatarItemClienteListView(aItem);
end;

procedure TFrmPrincipal.AddPedidoListView(aPedido: TPedido);
var
  aItem  : TListViewItem;
begin
  aItem := ListViewPedido.Items.Add;
  aItem.TagObject := aPedido;
  FormatarItemPedidoListView(aItem);
end;

procedure TFrmPrincipal.AtualizarCliente;
var
  dao : TClienteDao;
  aItem : TListViewItem;
  aItemIndex : Integer;
begin
  dao := TClienteDao.GetInstance;

  if (dao.Operacao = TTipoOperacaoDao.toIncluido) then
  begin
    AddClienteListView(dao.Model);
    ListViewCliente.ItemIndex := (ListViewCliente.Items.Count - 1);
  end
  else
  if (dao.Operacao = TTipoOperacaoDao.toEditado) then
  begin
    aItem := TListViewItem(ListViewCliente.Items.Item[ListViewCliente.ItemIndex]);
    aItem.TagObject := dao.Model;
    FormatarItemClienteListView(aItem);
  end
  else
  if (dao.Operacao = TTipoOperacaoDao.toExcluido) then
  begin
    aItemIndex := ListViewCliente.ItemIndex;
    ListViewCliente.Items.Delete(aItemIndex);
  end;

  ImgSemCliente.Visible := (ListViewCliente.Items.Count = 0);
end;

procedure TFrmPrincipal.AtualizarNotificacao;
var
  dao : TNotificacaoDao;
  aItem : TListViewItem;
  aItemIndex : Integer;
begin
  dao := TNotificacaoDao.GetInstance;

  if (dao.Operacao = TTipoOperacaoDao.toEditado) then
  begin
    aItem := TListViewItem(ListViewNotificacao.Items.Item[ListViewNotificacao.ItemIndex]);
    aItem.TagObject := dao.Model;
    FormatarItemNotificacaoListView(aItem);
  end
  else
  if (dao.Operacao = TTipoOperacaoDao.toExcluido) then
  begin
    aItemIndex := ListViewNotificacao.ItemIndex;
    ListViewNotificacao.Items.Delete(aItemIndex);
  end;

//  if (dao.Operacao = TTipoOperacaoDao.toIncluido) then
//  begin
//    AddClienteListView(dao.Model);
//    ListViewCliente.ItemIndex := (ListViewCliente.Items.Count - 1);
//  end;

  imgSemNotificacao.Visible  := (ListViewNotificacao.Items.Count = 0);
end;

procedure TFrmPrincipal.AtualizarPedido;
var
  dao   : TPedidoDao;
  aItem : TListViewItem;
  aItemIndex : Integer;
begin
  dao := TPedidoDao.GetInstance;

  if (dao.Operacao = TTipoOperacaoDao.toIncluido) then
  begin
    AddPedidoListView(dao.Model);
    ListViewPedido.ItemIndex := (ListViewPedido.Items.Count - 1);
  end
  else
  if (dao.Operacao = TTipoOperacaoDao.toEditado) then
  begin
    aItem := TListViewItem(ListViewPedido.Items.Item[ListViewPedido.ItemIndex]);
    aItem.TagObject := dao.Model;
    FormatarItemPedidoListView(aItem);
  end
  else
  if (dao.Operacao = TTipoOperacaoDao.toExcluido) then
  begin
    aItemIndex := ListViewPedido.ItemIndex;
    ListViewPedido.Items.Delete(aItemIndex);
  end;

  ImgSemPedido.Visible := (ListViewPedido.Items.Count = 0);
end;

procedure TFrmPrincipal.AtualizarUsuario;
var
  dao   : TUsuarioDao;
  emp   : TLojaDao;
  aJson ,
  aEmpr : TJSONObject;
  aRetorno : String;
  aID : TGUID;
  OK  : Boolean;
begin
  try
    aJson := DM.GetEditarPerfil;
    dao   := TUsuarioDao.GetInstance;
    emp   := TLojaDao.GetInstance();

    if Assigned(aJson) then
    begin
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));

      if (aRetorno.ToUpper = 'OK') then
      begin
        // Recuperar dados da empresa
        aEmpr := aJson.Get('empresa').JsonValue as TJSONObject;
        aID   := StringToGUID(StrClearValueJson(HTMLDecode(aEmpr.Get('id').JsonValue.ToString)));
        OK    := emp.Find(aID, emp.Model.CpfCnpj, False);

        emp.Model.ID       := StringToGUID(StrClearValueJson(HTMLDecode(aEmpr.Get('id').JsonValue.ToString)));
        emp.Model.Codigo   := StrToCurr(StrClearValueJson(HTMLDecode(aEmpr.Get('codigo').JsonValue.ToString)));
        emp.Model.Nome     := StrClearValueJson(HTMLDecode(aEmpr.Get('nome').JsonValue.ToString));
        emp.Model.Fantasia := StrClearValueJson(HTMLDecode(aEmpr.Get('fantasia').JsonValue.ToString));

        if (not OK) then
          emp.Insert()
        else
          emp.Update();

        TConfiguracaoDao.GetInstance().SetValue('empresa_padrao', emp.Model.ID.ToString);
      end
      else
        ExibirMsgAlerta(aRetorno);
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar gravar altera��o no perfil do usu�rio.');
  end;
end;

procedure TFrmPrincipal.BaixarNotificacoes;
var
  aRetorno   ,
  aUsuarioID : String;
  aEmpresaID : TStringList;
  aJson  ,
  aNotificacaoWeb : TJSONObject;
  aNotificacaoDao : TNotificacaoDao;
  aLista : TJSONArray;
  I ,
  X ,
  N : Integer;
begin
  N := 0;
  try
    TmrNotificacao.Enabled := False;
    try

      aUsuarioID := TUsuarioDao.GetInstance().Model.ID.ToString;
      aEmpresaID := TLojaDao.GetInstance().EmpresasID;

      for X := 0 to aEmpresaID.Count - 1 do
      begin
        Application.ProcessMessages;

        aJson := DM.GetListarNotificacoes(aUsuarioID, aEmpresaID.Strings[X]);
        if Assigned(aJson) then
        begin
          aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));
          if (aRetorno.ToUpper = 'OK') then
          begin
            aLista := aJson.Get('notificacoes').JsonValue as TJSONArray;
            aNotificacaoDao := TNotificacaoDao.GetInstance();

            for I := 0 to aLista.Count - 1 do
            begin
              aNotificacaoWeb := aLista.Items[I] as TJSONObject;

              with aNotificacaoDao do
              begin
                Model.ID       := StringToGUID(StrClearValueJson(HTMLDecode(aNotificacaoWeb.Get('id').JsonValue.ToString)));
                Model.Codigo   := StrToCurr(StrClearValueJson(HTMLDecode(aNotificacaoWeb.Get('codigo').JsonValue.ToString)));

                Model.Data     :=
                  StrToDateLocal('dd/mm/yyyy', StrClearValueJson(HTMLDecode(aNotificacaoWeb.Get('data').JsonValue.ToString))) +
                  StrToTime(StrClearValueJson(HTMLDecode(aNotificacaoWeb.Get('hora').JsonValue.ToString)));

                Model.Titulo   := StrClearValueJson(HTMLDecode(aNotificacaoWeb.Get('titulo').JsonValue.ToString));
                Model.Mensagem := StrClearValueJson(HTMLDecode(aNotificacaoWeb.Get('texto').JsonValue.ToString));
                Model.Lida     := False;
                Model.Destacar := (StrToInt(StrClearValueJson(HTMLDecode(aNotificacaoWeb.Get('destacar').JsonValue.ToString))) = 1);

                if not Find(Model.Codigo, False) then
                  Insert();
              end;

              Inc(N);
            end;
          end;
        end;
      end;

      if (N > 0) then
      begin
        BuscarNotificacoes(EmptyStr, 0);
        ImgSemNotificacao.Visible := (ListViewNotificacao.Items.Count = 0);
        ContarNotificacoes;
      end;

      Application.ProcessMessages;
    except
      ;
    end;
  finally
    if Assigned(aNotificacaoWeb) then
      aNotificacaoWeb.DisposeOf;

    if Assigned(aJson) then
      aJson.DisposeOf;

    if Assigned(aLista) then
      aLista.DisposeOf;

    TmrNotificacao.Enabled := False;
  end;
end;

procedure TFrmPrincipal.BuscarClientes(aBusca: String; aPagina: Integer);
var
  dao : TClienteDao;
  I : Integer;
begin
  dao := TClienteDao.GetInstance;
  dao.Load(aBusca);
  for I := Low(dao.Lista) to High(dao.Lista) do
    AddClienteListView(dao.Lista[I]);
end;

procedure TFrmPrincipal.BuscarNotificacoes(aBusca: String; aPagina: Integer);
var
  dao : TNotificacaoDao;
  I : Integer;
begin
  dao := TNotificacaoDao.GetInstance;
  dao.Load(aBusca);
  for I := Low(dao.Lista) to High(dao.Lista) do
    AddNotificacaoListView(dao.Lista[I]);
end;

procedure TFrmPrincipal.BuscarPedidos(aBusca: String; aPagina: Integer);
var
  dao : TPedidoDao;
  I : Integer;
begin
  dao := TPedidoDao.GetInstance;
  dao.Load(aBusca);
  for I := Low(dao.Lista) to High(dao.Lista) do
    AddPedidoListView(dao.Lista[I]);
end;

procedure TFrmPrincipal.ContarNotificacoes;
var
  dao : TNotificacaoDao;
  aNotificacoes : Integer;
begin
  dao := TNotificacaoDao.GetInstance;
  aNotificacoes := dao.GetCountNotRead();

  circleNotification.Visible := (aNotificacoes > 0);
  labelNotification.Text     := IfThen(aNotificacoes > 9, '9+', aNotificacoes.ToString);
end;

procedure TFrmPrincipal.DefinirIndices;
begin
  imageTabPedido.Tag  := idxTabPedido;
  labelTabPedido.Tag  := idxTabPedido;
  imageTabCliente.Tag := idxTabCliente;
  labelTabCliente.Tag := idxTabCliente;
  imageTabNotificacao.Tag := idxTabNotificacao;
  labelTabNotificacao.Tag := idxTabNotificacao;
  imageTabMais.Tag := idxTabMais;
  labelTabMais.Tag := idxTabMais;
end;

procedure TFrmPrincipal.DoBuscaClientes(Sender: TObject);
begin
  try
    ImgSemCliente.Visible := False;

    ListViewCliente.BeginUpdate;
    ListViewCliente.Items.Clear;

    BuscarClientes(editBuscaCliente.Text, 0);

    ListViewCliente.EndUpdate;
    ImgSemCliente.Visible := (ListViewCliente.Items.Count = 0);
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tenta carregar os clientes.' + #13 + E.Message);
  end;
end;

procedure TFrmPrincipal.DoBuscaNotificacoes(Sender: TObject);
begin
  try
    ImgSemNotificacao.Visible := False;

    ListViewNotificacao.BeginUpdate;
    ListViewNotificacao.Items.Clear;

    BuscarNotificacoes(EmptyStr, 0);

    ListViewNotificacao.EndUpdate;
    ImgSemNotificacao.Visible := (ListViewNotificacao.Items.Count = 0);
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tenta carregar as notifica��es.' + #13 + E.Message);
  end;
end;

procedure TFrmPrincipal.DoBuscaPedidos(Sender: TObject);
begin
  try
    ImgSemPedido.Visible := False;

    ListViewPedido.BeginUpdate;
    ListViewPedido.Items.Clear;

    BuscarPedidos(editBuscaPedido.Text, 0);

    ListViewPedido.EndUpdate;
    ImgSemPedido.Visible := (ListViewPedido.Items.Count = 0);
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tenta carregar os pedidos.' + #13 + E.Message);
  end;
end;

procedure TFrmPrincipal.DoFecharApp(Sender: TObject);
begin
  ExibirMsgConfirmacao('Fechar', 'Deseja encerrar o aplicativo?', DoCloseApp);
end;

procedure TFrmPrincipal.DoCloseApp(Sender: TObject);
var
  msg   : TFrmMensagem;
  aUser : TUsuarioDao;
  aEmpr : TLojaDao;
  aNoti : TNotificacaoDao;
  aPedido  : TPedidoDao;
  aCliente : TClienteDao;
  aProduto : TProdutoDao;
begin
  TmrNotificacao.Enabled := False;

  msg := TFrmMensagem.GetInstance;
  msg.Close;

  aPedido := TPedidoDao.GetInstance();
  aPedido.Limpar();

  aNoti := TNotificacaoDao.GetInstance();
  aNoti.Limpar();

  aUser := TUsuarioDao.GetInstance();
  aUser.Limpar();

  aEmpr := TLojaDao.GetInstance();
  aEmpr.Limpar();

  aCliente := TClienteDao.GetInstance();
  aCliente.Limpar();

  aProduto := TProdutoDao.GetInstance();
  aProduto.Limpar();

  TConfiguracaoDao.GetInstance().Delete('empresa_padrao');
  TConfiguracaoDao.GetInstance().Delete('dt-atualizacao-cliente');
  TConfiguracaoDao.GetInstance().Delete('dt-atualizacao-produto');
  TConfiguracaoDao.GetInstance().Delete('dt-atualizacao-pedido');

  EfetuarLogin(True);
  Self.Close;
end;

procedure TFrmPrincipal.DoCompartilharApp(Sender: TObject);
begin
  CompartilharApp;
end;

procedure TFrmPrincipal.DoExibirPerfil(Sender: TObject);
begin
  ExibirPerfilUsuario(Self);
end;

procedure TFrmPrincipal.DoExibirProdutos(Sender: TObject);
begin
  ExibirListaProdutos;
end;

procedure TFrmPrincipal.DoSelecinarTab(Sender: TObject);
var
  aTab : Smallint;
begin
  aTab := idxTabPedido;

  if Sender is TImage then
    aTab := TImage(Sender).Tag
  else
  if Sender is TLabel then
    aTab := TLabel(Sender).Tag;

  SelecionarTab(aTab);
end;

procedure TFrmPrincipal.DoSincronizarDados(Sender: TObject);
begin
  SincronizarDados;
end;

procedure TFrmPrincipal.ExibirMenuNotificacao;
begin
  fltNotificacaoEntrada.StartValue := Self.Height;
  fltNotificacaoSaida.StopValue    := Self.Height;
  RectangleMenuNotificacao.Opacity := vlOpacityIcon;
  LayoutMenuNotificacao.Visible    := True;
  LayoutMenuNotificacao.BringToFront;
end;

procedure TFrmPrincipal.FormatarItemClienteListView(aItem: TListViewItem);
var
  aText  : TListItemText;
  aImage : TListItemImage;
  aCliente : TCliente;
begin
  with aItem do
  begin
    aCliente := TCliente(aItem.TagObject);

    TListItemText(Objects.FindDrawable('Text1')).Text := aCliente.Nome;
    TListItemText(Objects.FindDrawable('Text2')).Text := IfThen(Trim(aCliente.Endereco) = EmptyStr, '* SEM ENDERE�O INFORMADO!', Trim(aCliente.Endereco));
    if (aCliente.DataUltimaCompra <> StrToDate(EMPTY_DATE)) then
    begin
      TListItemText(Objects.FindDrawable('Text3')).Text :=
        '** �ltima Compra : ' + FormatDateTime('dd/mm/yyyy', aCliente.DataUltimaCompra) + ', ' +
        'R$ ' + FormatFloat(',0.00', aCliente.ValorUltimaCompra);
    end
    else
      TListItemText(Objects.FindDrawable('Text3')).Text := '**';

    // Sincronizado com o Servidor Web
    aImage := TListItemImage(Objects.FindDrawable('Image4'));
    if aCliente.Sincronizado then
      aImage.Bitmap := img_sinc.Bitmap
    else
      aImage.Bitmap := img_nao_sinc.Bitmap;
  end;
end;

procedure TFrmPrincipal.FormatarItemNotificacaoListView(aItem: TListViewItem);
var
  aText  : TListItemText;
  aImage : TListItemImage;
  aNotificacao : TNotificacao;

  procedure DefinirDestaqueText(const xText : TListItemText;
    const aCorDestaque, aCorLida, aCorNormal : TAlphaColor);
  begin
    if aNotificacao.Destacar then
    begin
      xText.Font.Style := [TFontStyle.fsBold];
      xText.TextColor  := aCorDestaque;
    end
    else
    if not aNotificacao.Lida then
    begin
      xText.Font.Style := [TFontStyle.fsBold];
      xText.TextColor  := aCorLida;
    end
    else
    begin
      xText.Font.Style := [];
      xText.TextColor  := aCorNormal;
    end;
  end;

begin
  with aItem do
  begin
    aNotificacao := TNotificacao(aItem.TagObject);

    // Titulo
    aText := TListItemText(Objects.FindDrawable('Text1'));
    aText.Text := aNotificacao.Titulo;
    DefinirDestaqueText(aText, crVermelho, crAzul, crAzul);

    // Data
    aText := TListItemText(Objects.FindDrawable('Text2'));
    aText.Text := FormatDateTime('dd/mm/yyyy', aNotificacao.Data);
    DefinirDestaqueText(aText, crVermelho, crCinzaEscuro, crCinzaEscuro);

    // Mensagem
    aText := TListItemText(Objects.FindDrawable('Text3'));
    aText.Text := aNotificacao.Mensagem;
    aText.WordWrap := True;
    DefinirDestaqueText(aText, crVermelho, crCinzaEscuro, crCinzaEscuro);

    // Imagem �cone "mais"
    aImage := TListItemImage(Objects.FindDrawable('Image4'));
    aImage.Bitmap    := img_opcoes.Bitmap;
    aImage.TagString := GUIDToString(aNotificacao.ID);
    aImage.TagFloat  := IfThen(aNotificacao.Lida, 1, 0);
  end;
end;

procedure TFrmPrincipal.FormatarItemPedidoListView(aItem: TListViewItem);
var
  aText   : TListItemText;
  aImage  : TListItemImage;
  aPedido : TPedido;
begin
  with aItem do
  begin
    aPedido := TPedido(aItem.TagObject);

    // N�mero
    aText := TListItemText(Objects.FindDrawable('Text1'));
    aText.Text := aPedido.ToString;
    // Cliente
    aText := TListItemText(Objects.FindDrawable('Text2'));
    aText.Text := aPedido.Cliente.Nome;
    // Data
    aText := TListItemText(Objects.FindDrawable('Text3'));
    aText.Text := FormatDateTime('dd/mm/yyyy', aPedido.DataEmissao);
    // Valor
    aText := TListItemText(Objects.FindDrawable('Text4'));
    aText.Text := 'R$ ' +  FormatFloat(',0.00', aPedido.ValorPedido);

    // Entregue
    aImage := TListItemImage(Objects.FindDrawable('Image6'));
    if aPedido.Entregue then
      aImage.Bitmap := img_entregue.Bitmap
    else
    // Faturado
    if aPedido.Faturado then
      aImage.Bitmap := img_faturado.Bitmap
    else
      aImage.Visible := False;

    // Sincronizado
    aImage := TListItemImage(Objects.FindDrawable('Image5'));
    if aPedido.Sincronizado then
      aImage.Bitmap := img_sinc.Bitmap
    else
      aImage.Bitmap := img_nao_sinc.Bitmap;
  end;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  DefinirIndices;

  img_entregue.Visible := False;
  img_faturado.Visible := False;
  img_sinc.Visible     := False;
  img_nao_sinc.Visible := False;
  img_lida.Visible     := False;
  img_nao_lida.Visible := False;
  img_update.Visible   := False;
  img_opcoes.Visible   := False;

  Application.MainForm   := Self;
  TmrNotificacao.Enabled := True;
end;

procedure TFrmPrincipal.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
{$IFDEF ANDROID}
var
  FService : IFMXVirtualKeyBoardService;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  if (Key = vkHardwareBack) then
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyBoardService, IInterface(FService));

    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyboardState) then
    begin
      // Bot�o BACK pressionado e teclado virtual vis�vel
      // { apenas fecha o teclado }
    end
    else
    begin
      if (not TabPedido.Visible) then
        Key := 0;

      if (TabCliente.Visible) then
        SelecionarTab( idxTabPedido )
      else
      if (TabNotificacao.Visible) then
        SelecionarTab( idxTabCliente )
      else
      if (TabMais.Visible) then
        SelecionarTab( idxTabNotificacao );
    end;
  end;
  {$ENDIF}
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  OcultarMenuNotificacao;
  ContarNotificacoes;
  SelecionarTab(idxTabPedido);
end;

procedure TFrmPrincipal.imageAddClienteClick(Sender: TObject);
begin
  NovoCadastroCliente(Self);
end;

procedure TFrmPrincipal.imageAddPedidoClick(Sender: TObject);
begin
//  // Para teste
//  AddPedidoListView(TPedido.Create);
  NovoCadastroPedido(Self);
end;

procedure TFrmPrincipal.lblCancelarImagemClick(Sender: TObject);
begin
  OcultarMenuNotificacao;
end;

procedure TFrmPrincipal.lblExcluirNotificacaoClick(Sender: TObject);
var
  dao : TNotificacaoDao;
begin
  try
    dao := TNotificacaoDao.GetInstance;
    dao.Delete();

    AtualizarNotificacao;
    ContarNotificacoes;

    OcultarMenuNotificacao;
  except
    On E : Exception do
    begin
      OcultarMenuNotificacao;
      ExibirMsgErro('Erro ao tentar excluir notifica��o.' + #13 + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.lblMarcarNotificacaoClick(Sender: TObject);
var
  dao : TNotificacaoDao;
begin
  try
    dao := TNotificacaoDao.GetInstance;
    dao.Model.Lida := not dao.Model.Lida;
    dao.MarkRead();

    AtualizarNotificacao;
    ContarNotificacoes;

    OcultarMenuNotificacao;
  except
    On E : Exception do
    begin
      OcultarMenuNotificacao;
      ExibirMsgErro('Erro ao tentar marcar/desmarcar notifica��o.' + #13 + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.ListViewClienteItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  dao : TClienteDao;
begin
  if (TListView(Sender).Selected <> nil) then
  begin
    dao := TClienteDao.GetInstance;
    dao.Model := TCliente(ListViewCliente.Items.Item[ItemIndex].TagObject);
    ExibirCadastroCliente(Self, True);
  end;
end;

procedure TFrmPrincipal.ListViewClienteUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  FormatarItemClienteListView(AItem);
end;

procedure TFrmPrincipal.ListViewNotificacaoItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  dao : TNotificacaoDao;
begin
  if (TListView(Sender).Selected <> nil) then
  begin
    if ItemObject is TListItemImage then
    begin
      dao := TNotificacaoDao.GetInstance;
      dao.Model := TNotificacao(ListViewNotificacao.Items.Item[ItemIndex].TagObject);

      if not dao.Model.Lida then
       lblMarcarNotificacao.Text := 'Marcar como lida'
      else
       lblMarcarNotificacao.Text := 'Marcar como n�o lida';

      ExibirMenuNotificacao;
    end;
  end;
end;

procedure TFrmPrincipal.ListViewNotificacaoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  FormatarItemNotificacaoListView(AItem);
end;

procedure TFrmPrincipal.ListViewPedidoItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  dao : TPedidoDao;
begin
  if (TListView(Sender).Selected <> nil) then
  begin
    dao := TPedidoDao.GetInstance;
    dao.Model := TPedido(ListViewPedido.Items.Item[ItemIndex].TagObject);
    dao.Find(dao.Model.Codigo, True); // Atualizar objeto com dados da base

    ListViewPedido.Items.Item[ItemIndex].TagObject := dao.Model; // Devolver objeto atualizado
    ExibirCadastroPedido(Self);
  end;
end;

procedure TFrmPrincipal.ListViewPedidoUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
begin
  FormatarItemPedidoListView(AItem);
end;

procedure TFrmPrincipal.OcultarMenuNotificacao;
begin
  LayoutMenuNotificacao.Visible := False;
end;

procedure TFrmPrincipal.SelecionarTab(const aTab: Smallint);
begin
  imageTabPedido.Opacity      := vlOpacityIcon;
  imageTabCliente.Opacity     := vlOpacityIcon;
  imageTabNotificacao.Opacity := vlOpacityIcon;
  imageTabMais.Opacity        := vlOpacityIcon;

  labelTabPedido.FontColor      := crCinza;
  labelTabCliente.FontColor     := crCinza;
  labelTabNotificacao.FontColor := crCinza;
  labelTabMais.FontColor        := crCinza;

  TabPedido.Visible      := (aTab = idxTabPedido);
  TabCliente.Visible     := (aTab = idxTabCliente);
  TabNotificacao.Visible := (aTab = idxTabNotificacao);
  TabMais.Visible        := (aTab = idxTabMais);

  Case aTab of
    idxTabPedido :
      begin
        DoBuscaPedidos(nil);
        imageTabPedido.Opacity   := 1;
        labelTabPedido.FontColor := crAzul;
      end;

    idxTabCliente :
      begin
        DoBuscaClientes(nil);
        imageTabCliente.Opacity   := 1;
        labelTabCliente.FontColor := crAzul;
      end;

    idxTabNotificacao :
      begin
        DoBuscaNotificacoes(nil);
        imageTabNotificacao.Opacity   := 1;
        labelTabNotificacao.FontColor := crAzul;
      end;

    idxTabMais :
      begin
        imageTabMais.Opacity   := 1;
        labelTabMais.FontColor := crAzul;
      end;
  end;
end;

procedure TFrmPrincipal.TmrNotificacaoTimer(Sender: TObject);
begin
  BaixarNotificacoes;
end;

end.
