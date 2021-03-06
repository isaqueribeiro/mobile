unit USincronizar;

interface

uses
  app.Funcoes,
  dao.Usuario,
  dao.Loja,
  dao.Cliente,
  dao.Produto,
  dao.Pedido,
  dao.PedidoItem,
  dao.Configuracao,

  System.StrUtils,
  System.JSON,
  Web.HTTPApp,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadrao, System.Actions, FMX.ActnList,
  FMX.TabControl, FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmSincronizar = class(TFrmPadrao)
    layoutDados: TLayout;
    layoutCliente: TLayout;
    layoutClienteIcone: TLayout;
    imageCliente: TImage;
    labelCliente: TLabel;
    layoutClienteBarra: TLayout;
    recBarraClienteCinza: TRoundRect;
    recBarraClienteAzul: TRoundRect;
    layoutSincronizar: TLayout;
    rectangleSincronizar: TRectangle;
    labelSincronizar: TLabel;
    lblBarraCliente: TLabel;
    layoutProduto: TLayout;
    layoutProdutoIcone: TLayout;
    imageProduto: TImage;
    labelProduto: TLabel;
    layoutProdutoBarra: TLayout;
    recBarraProdutoCinza: TRoundRect;
    recBarraProdutoAzul: TRoundRect;
    lblBarraProduto: TLabel;
    layoutPedido: TLayout;
    layoutPedidoIcone: TLayout;
    imagePedido: TImage;
    labelPedido: TLabel;
    layoutPedidoBarra: TLayout;
    recBarraPedidoCinza: TRoundRect;
    recBarraPedidoAzul: TRoundRect;
    lblBarraPedido: TLabel;
    recSincronizar: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure labelSincronizarClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  strict private
    { Private declarations }
    procedure TotalizarDados;
    procedure SetProgressoBarra(const aBarra : TRoundRect; const aTexto : TLabel;
      aMaximo : Single; aPercentual : Currency; aInforme : String); overload;
    procedure SetProgressoBarra(const aBarra : TRectangle; const aTexto : TLabel;
      aMaximo : Single; aPercentual : Currency; aInforme : String); overload;

    procedure Sincronizar;

    function UploadClientes : String;
    function ProcessarClientes : String;
    function DownloadClientes : String;

    function UploadProdutos : String;
    function ProcessarProdutos : String;
    function DownloadProdutos : String;

    function UploadPedidos : String;
    function ProcessarPedidos : String;
    function DownloadPedidos : String;

    class var aInstance : TFrmSincronizar;
  public
    { Public declarations }
    class function GetInstance : TFrmSincronizar;
  end;

  procedure SincronizarDados;

//var
//  FrmSincronizar: TFrmSincronizar;

implementation

{$R *.fmx}

uses
  UConstantes,
  UMensagem, UDM;

procedure SincronizarDados;
var
  aForm : TFrmSincronizar;
begin
  aForm := TFrmSincronizar.GetInstance;
  with aForm do
  begin
    tbsControle.ActiveTab := tbsCadastro;
    Show;
  end;
end;

{ TFrmSincronizar }

function TFrmSincronizar.DownloadClientes: String;
var
  aRetorno : String;
  aLista   : TJSONArray;
  aCliente ,
  aJson    : TJSONObject;
  daoCliente : TClienteDao;
  I     ,
  aTudo : Integer;
  aParte: Currency;
  aID   : TGUID;
  aCnpj ,
  aData : String;
begin
  aRetorno := 'OK';
  try
    aJson := DM.GetDownloadClientes;
    if Assigned(aJson) then
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));

    if aRetorno.Trim.Equals('OK') then
    begin
      aLista := aJson.Get('clientes').JsonValue as TJSONArray;
      aTudo  := aLista.Count - 1;


      for I := 0 to aLista.Count - 1 do
      begin
        daoCliente := TClienteDao.GetInstance();
        aCliente   := aLista.Items[I] as TJSONObject;

        aID   := StringToGUID( StrClearValueJson(HTMLDecode(aCliente.Get('id').JsonValue.ToString)) );
        aCnpj := StrClearValueJson(HTMLDecode(aCliente.Get('cp').JsonValue.ToString));

        with daoCliente.Model do
        begin
          ID       := StringToGUID(StrClearValueJson(HTMLDecode(aCliente.Get('id').JsonValue.ToString)));
          Codigo   := StrToCurr(StrClearValueJson(HTMLDecode(aCliente.Get('cd').JsonValue.ToString)));
          Nome     := StrClearValueJson(HTMLDecode(aCliente.Get('nm').JsonValue.ToString));
          CpfCnpj  := StrClearValueJson(HTMLDecode(aCliente.Get('cp').JsonValue.ToString));
          Contato  := StrClearValueJson(HTMLDecode(aCliente.Get('ct').JsonValue.ToString));
          Telefone := StrClearValueJson(HTMLDecode(aCliente.Get('fn').JsonValue.ToString));
          Celular  := StrClearValueJson(HTMLDecode(aCliente.Get('ce').JsonValue.ToString));
          Email    := StrClearValueJson(HTMLDecode(aCliente.Get('em').JsonValue.ToString));
          Endereco     := StrClearValueJson(HTMLDecode(aCliente.Get('ed').JsonValue.ToString));
          Observacao   := StrClearValueJson(HTMLDecode(aCliente.Get('ob').JsonValue.ToString));
          Ativo        := (StrClearValueJson(HTMLDecode(aCliente.Get('at').JsonValue.ToString)) = FLAG_SIM);
          Sincronizado := True;
        end;

        if daoCliente.Find(aId, aCnpj, False) then
          daoCliente.Update()
        else
          daoCliente.Insert();

        aParte := (((I + 1) / aTudo) * 33.33) + 66.66;
        SetProgressoBarra(recBarraClienteAzul, lblBarraCliente , recBarraClienteCinza.Width, aParte, 'Baixando clientes...');
      end;

      // Pegar a data/hora retornada removendo o milisegundo
      aData := Copy(StrClearValueJson(HTMLDecode(aJson.Get('data').JsonValue.ToString)), 1, 19);
      TConfiguracaoDao.GetInstance().SetValue('dt-atualizacao-cliente', aData);
    end;
  finally
    Result := aRetorno;
  end;
end;

function TFrmSincronizar.DownloadPedidos: String;
var
  aRetorno   : String;
  aListaPed  ,
  aListaItens: TJSONArray;
  aPedido    ,
  aItem      ,
  aJson      : TJSONObject;
  daoPedido  : TPedidoDao;
  daoPedidoItem : TPedidoItemDao;
  I, X  ,
  aTudo : Integer;
  aParte: Currency;
  aID   : TGUID;
  aNumero ,
  aCpfCnpj,
  aData   : String;
begin
  aRetorno := 'OK';
  try
    aJson := DM.GetDownloadPedidos;
    if Assigned(aJson) then
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));

    if aRetorno.Trim.Equals('OK') then
    begin
      aListaPed := aJson.Get('pedidos').JsonValue as TJSONArray;
      aTudo     := aListaPed.Count - 1;

      for I := 0 to aListaPed.Count - 1 do
      begin
        // Tratar Pedido

        daoPedido := TPedidoDao.GetInstance();
        aPedido   := aListaPed.Items[I] as TJSONObject;

        aID      := StringToGUID( StrClearValueJson(HTMLDecode(aPedido.Get('id').JsonValue.ToString)) );
        aNumero  := StrClearValueJson(HTMLDecode(aPedido.Get('nr').JsonValue.ToString));
        aCpfCnpj := StrClearValueJson(HTMLDecode(aPedido.Get('lc').JsonValue.ToString));

        with daoPedido.Model do
        begin
          ID           := StringToGUID(StrClearValueJson(HTMLDecode(aPedido.Get('id').JsonValue.ToString)));
          Codigo       := StrToCurr(StrClearValueJson(HTMLDecode(aPedido.Get('cd').JsonValue.ToString)));
          Numero       := aNumero;
          Tipo         := TTipoPedido.tpPedido; // Com este tipo, o pedido � marcado com sincronizado.
          DataEmissao  := StrToDate(StrClearValueJson(HTMLDecode(aPedido.Get('dt').JsonValue.ToString)));
          Loja.ID      := StringToGUID(StrClearValueJson(HTMLDecode(aPedido.Get('lj').JsonValue.ToString)));
          Loja.CpfCnpj := aCpfCnpj;
          Cliente.ID   := StringToGUID(StrClearValueJson(HTMLDecode(aPedido.Get('cl').JsonValue.ToString)));

          ValorTotal    := StrClearValueJson(HTMLDecode(aPedido.Get('vt').JsonValue.ToString)).ToDouble / 100.0;
          ValorDesconto := StrClearValueJson(HTMLDecode(aPedido.Get('vd').JsonValue.ToString)).ToDouble / 100.0;
          ValorPedido   := StrClearValueJson(HTMLDecode(aPedido.Get('vp').JsonValue.ToString)).ToDouble / 100.0;

          Contato    := StrClearValueJson(HTMLDecode(aPedido.Get('ct').JsonValue.ToString));
          Faturado   := (StrClearValueJson(HTMLDecode(aPedido.Get('ft').JsonValue.ToString)) = FLAG_SIM);
          Entregue   := (StrClearValueJson(HTMLDecode(aPedido.Get('et').JsonValue.ToString)) = FLAG_SIM);
          Observacao := StrClearValueJson(HTMLDecode(aPedido.Get('ob').JsonValue.ToString));
          Ativo      := (StrClearValueJson(HTMLDecode(aPedido.Get('at').JsonValue.ToString)) = FLAG_SIM);

          if daoPedido.Find(aId, Loja.ID.ToString, aNumero, False) then
            daoPedido.Sincronizado()
          else
            daoPedido.Insert();
        end;

        // Tratar Itens do Pedido

        daoPedidoItem := TPedidoItemDao.GetInstance();
        daoPedidoItem.DeleteAllTemp;

        aListaItens   := aPedido.Get('itens').JsonValue as TJSONArray;
        for X := 0 to aListaItens.Count - 1 do
        begin
          aItem := aListaItens.Items[X] as TJSONObject;

          with daoPedidoItem.Model do
          begin
            ID     := StringToGUID(StrClearValueJson(HTMLDecode(aItem.Get('id').JsonValue.ToString)));
            Codigo := StrToInt(StrClearValueJson(HTMLDecode(aItem.Get('cd').JsonValue.ToString)));
            Pedido.ID  := StringToGUID(StrClearValueJson(HTMLDecode(aItem.Get('pe').JsonValue.ToString)));
            Produto.ID := StringToGUID(StrClearValueJson(HTMLDecode(aItem.Get('pd').JsonValue.ToString)));
            Quantidade    := StrClearValueJson(HTMLDecode(aItem.Get('qt').JsonValue.ToString)).ToDouble / 100.0;
            ValorUnitario := StrClearValueJson(HTMLDecode(aItem.Get('vu').JsonValue.ToString)).ToDouble / 100.0;
            ValorTotal    := StrClearValueJson(HTMLDecode(aItem.Get('vt').JsonValue.ToString)).ToDouble / 100.0;
            ValorTotalDesconto := StrClearValueJson(HTMLDecode(aItem.Get('vd').JsonValue.ToString)).ToDouble / 100.0;
            ValorLiquido       := StrClearValueJson(HTMLDecode(aItem.Get('vl').JsonValue.ToString)).ToDouble / 100.0;

            if daoPedidoItem.Find(PedidoID, ID, False) then
              daoPedidoItem.Update()
            else
              daoPedidoItem.Insert();
          end;
        end;

        // (Fim) ... Tratar Itens do Pedido

        daoPedido.GravarItens();
        daoPedidoItem.DeleteAllTemp;

        aParte := (((I + 1) / aTudo) * 33.33) + 66.66;
        SetProgressoBarra(recBarraPedidoAzul, lblBarraPedido, recBarraPedidoCinza.Width, aParte, 'Atualizando pedidos...');
      end;

      // Pegar a data/hora retornada removendo o milisegundo
      aData := Copy(StrClearValueJson(HTMLDecode(aJson.Get('data').JsonValue.ToString)), 1, 19);
      TConfiguracaoDao.GetInstance().SetValue('dt-atualizacao-pedido', aData);
    end;
  finally
    Result := aRetorno;
  end;
end;

function TFrmSincronizar.DownloadProdutos: String;
var
  aRetorno : String;
  aLista   : TJSONArray;
  aProduto ,
  aJson    : TJSONObject;
  daoProduto : TProdutoDao;
  I     ,
  aTudo : Integer;
  aParte: Currency;
  aID   : TGUID;
  aBarra,
  aData : String;
//  aFoto   : TBitmap;
//  aStream : TStream;
begin
  aRetorno := 'OK';
  try
    aJson := DM.GetDownloadProdutos;
    if Assigned(aJson) then
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));

    if aRetorno.Trim.Equals('OK') then
    begin
      aLista := aJson.Get('produtos').JsonValue as TJSONArray;
      aTudo  := aLista.Count - 1;


      for I := 0 to aLista.Count - 1 do
      begin
        daoProduto := TProdutoDao.GetInstance();
        aProduto   := aLista.Items[I] as TJSONObject;

        aID    := StringToGUID( StrClearValueJson(HTMLDecode(aProduto.Get('id').JsonValue.ToString)) );
        aBarra := StrClearValueJson(HTMLDecode(aProduto.Get('br').JsonValue.ToString));

        with daoProduto.Model do
        begin
          ID        := StringToGUID(StrClearValueJson(HTMLDecode(aProduto.Get('id').JsonValue.ToString)));
          Codigo    := StrToCurr(StrClearValueJson(HTMLDecode(aProduto.Get('cd').JsonValue.ToString)));
          Descricao := StrClearValueJson(HTMLDecode(aProduto.Get('ds').JsonValue.ToString));
          CodigoEan := StrClearValueJson(HTMLDecode(aProduto.Get('br').JsonValue.ToString));
          Valor     := StrClearValueJson(HTMLDecode(aProduto.Get('vl').JsonValue.ToString)).ToDouble / 100.0;
          Ativo        := (StrClearValueJson(HTMLDecode(aProduto.Get('at').JsonValue.ToString)) = FLAG_SIM);
          Sincronizado := True;
        end;

        if (StrClearValueJson(HTMLDecode(aProduto.Get('ft').JsonValue.ToString)) = EmptyStr) then
          daoProduto.Model.Foto := nil
        else
        begin
//          aFoto   := BitmapFromBase64( StrClearValueJson(HTMLDecode(aProduto.Get('ft').JsonValue.ToString)) );
//          aStream := TMemoryStream.Create;
//          aStream.Position := 0;
//          aFoto.SaveToStream(aStream);
//          daoProduto.Model.Foto := aStream;
          daoProduto.Model.Foto := TBitmap.Create;
          daoProduto.Model.Foto.Assign( BitmapFromBase64( StrClearValueJson(HTMLDecode(aProduto.Get('ft').JsonValue.ToString)) ) );
        end;

        if daoProduto.Find(aId, aBarra, False) then
          daoProduto.Update()
        else
          daoProduto.Insert();

        aParte := (((I + 1) / aTudo) * 33.33) + 66.66;
        SetProgressoBarra(recBarraProdutoAzul, lblBarraProduto , recBarraProdutoCinza.Width, aParte, 'Baixando produtos...');
      end;

      // Pegar a data/hora retornada removendo o milisegundo
      aData := Copy(StrClearValueJson(HTMLDecode(aJson.Get('data').JsonValue.ToString)), 1, 19);
      TConfiguracaoDao.GetInstance().SetValue('dt-atualizacao-produto', aData);
    end;
  finally
    Result := aRetorno;
  end;
end;

procedure TFrmSincronizar.FormActivate(Sender: TObject);
begin
  inherited;
  TLojaDao.GetInstance().Load(EmptyStr);
  TUsuarioDao.GetInstance().Model.Empresa := TLojaDao.GetInstance().Model;
end;

procedure TFrmSincronizar.FormCreate(Sender: TObject);
begin
  inherited;
  // Barra Cliente
  recBarraClienteAzul.Width       := 0;
  recBarraClienteAzul.Fill.Color  := crAzul;
  recBarraClienteCinza.Fill.Color := crCinzaClaro;

  // Barra Produtos
  recBarraProdutoAzul.Width       := 0;
  recBarraProdutoAzul.Fill.Color  := crAzul;
  recBarraProdutoCinza.Fill.Color := crCinzaClaro;

  // Barra Pedidos
  recBarraPedidoAzul.Width       := 0;
  recBarraPedidoAzul.Fill.Color  := crAzul;
  recBarraPedidoCinza.Fill.Color := crCinzaClaro;

  // Barra bot�o Sincronizar
  recSincronizar.Width := 0;
end;

procedure TFrmSincronizar.FormShow(Sender: TObject);
begin
  inherited;
  imageCliente.Opacity := (1.0 - vlOpacityIcon);
  imageProduto.Opacity := (1.0 - vlOpacityIcon);
  imagePedido.Opacity  := (1.0 - vlOpacityIcon);

  TotalizarDados;
end;

class function TFrmSincronizar.GetInstance: TFrmSincronizar;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmSincronizar, aInstance);
    Application.RealCreateForms;
  end;

  Result := aInstance;
end;

procedure TFrmSincronizar.labelSincronizarClick(Sender: TObject);
begin
  TotalizarDados;
  Sincronizar;
end;

function TFrmSincronizar.ProcessarClientes: String;
var
  aRetorno : String;
  aCliente ,
  aJson    : TJSONObject;
  daoCliente : TClienteDao;
begin
  aRetorno := 'OK';
  try
    aJson := DM.GetProcessarClientes;
    if Assigned(aJson) then
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));

    SetProgressoBarra(recBarraClienteAzul, lblBarraCliente , recBarraClienteCinza.Width, 66.66, 'Processando...');
  finally
    Result := aRetorno;
  end;
end;

function TFrmSincronizar.ProcessarPedidos: String;
var
  aRetorno: String;
  aPedido ,
  aJson   : TJSONObject;
  daoPedido : TPedidoDao;
begin
  aRetorno := 'OK';
  try
    aJson := DM.GetProcessarPedidos;
    if Assigned(aJson) then
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));

    SetProgressoBarra(recBarraPedidoAzul, lblBarraPedido, recBarraPedidoCinza.Width, 66.66, 'Processando...');
  finally
    Result := aRetorno;
  end;
end;

function TFrmSincronizar.ProcessarProdutos: String;
var
  aRetorno : String;
  aProduto ,
  aJson    : TJSONObject;
  daoProduto : TProdutoDao;
begin
  aRetorno := 'OK';
  try
    aJson := DM.GetProcessarProdutos;
    if Assigned(aJson) then
      aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));

    SetProgressoBarra(recBarraProdutoAzul, lblBarraProduto, recBarraProdutoCinza.Width, 66.66, 'Processando...');
  finally
    Result := aRetorno;
  end;
end;

procedure TFrmSincronizar.SetProgressoBarra(const aBarra: TRoundRect; const aTexto: TLabel;
  aMaximo: Single; aPercentual : Currency; aInforme: String);
begin
  if Assigned(aBarra) then
    aBarra.Width := Trunc((aMaximo * aPercentual) / 100);

  if Assigned(aTexto) then
    aTexto.Text := aInforme.Trim;

  Application.ProcessMessages;
end;

procedure TFrmSincronizar.SetProgressoBarra(const aBarra: TRectangle; const aTexto: TLabel;
  aMaximo: Single; aPercentual : Currency; aInforme: String);
begin
  if Assigned(aBarra) then
    aBarra.AnimateFloat('Width', Trunc((aMaximo * aPercentual) / 100), 0.2, TAnimationType.&In, TInterpolationType.Linear);

  if Assigned(aTexto) then
    aTexto.Text := aInforme.Trim;

  Application.ProcessMessages;
end;

procedure TFrmSincronizar.Sincronizar;
var
  aJson : TJSONObject;
  aRetorno : String;
begin
  try
    // CLIENTES ============================================================
    imageCliente.AnimateFloat('Opacity', 1.0, 0.5, TAnimationType.&In, TInterpolationType.Linear);

    // Step 1: 33 de 100 - Enviando lista de clientes
    aRetorno := UploadClientes;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((1 / 9) * 100), 'SINCRONIZAR')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 1: (FIM)

    // Step 2: 66 de 100 - Processando lista enviada
    aRetorno := ProcessarClientes;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((2 / 9) * 100), 'SINCRONIZAR')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 2: (FIM)

    // Step 3: 99 de 100 - Baixando lista enviada
    aRetorno := DownloadClientes;
    if (aRetorno.ToUpper = 'OK') then
    begin
      SetProgressoBarra(recBarraClienteAzul, lblBarraCliente, recBarraClienteCinza.Width, 100, 'Clientes sincronizados');
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((3 / 9) * 100), 'SINCRONIZAR');
    end
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 3: (FIM)

    // PRODUTOS ============================================================
    imageProduto.AnimateFloat('Opacity', 1.0, 0.5, TAnimationType.&In, TInterpolationType.Linear);

    // Step 1: 33 de 100 - Enviando lista de produtos
    aRetorno := UploadProdutos;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((4 / 9) * 100), 'SINCRONIZAR')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 1: (FIM)

    // Step 2: 66 de 100 - Processando lista enviada
    aRetorno := ProcessarProdutos;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((5 / 9) * 100), 'SINCRONIZAR')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 2: (FIM)

    // Step 3: 99 de 100 - Baixando lista enviada
    aRetorno := DownloadProdutos;
    if (aRetorno.ToUpper = 'OK') then
    begin
      SetProgressoBarra(recBarraProdutoAzul, lblBarraProduto, recBarraProdutoCinza.Width, 100, 'Produtos sincronizados');
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((6 / 9) * 100), 'SINCRONIZAR');
    end
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 3: (FIM)

    // PEDIDOS ============================================================
    imagePedido.AnimateFloat('Opacity', 1.0, 0.5, TAnimationType.&In, TInterpolationType.Linear);

    // Step 1: 33 de 100 - Enviando lista de pedidos
    aRetorno := UploadPedidos;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((7 / 9) * 100), 'SINCRONIZAR')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 1: (FIM)

    // Step 2: 66 de 100 - Processando lista enviada
    aRetorno := ProcessarPedidos;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((8 / 9) * 100), 'SINCRONIZAR')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 2: (FIM)

    // Step 3: 99 de 100 - Baixando lista enviada
    aRetorno := DownloadPedidos;
    if (aRetorno.ToUpper = 'OK') then
    begin
      SetProgressoBarra(recBarraPedidoAzul, lblBarraPedido, recBarraPedidoCinza.Width, 100, 'Pedidos sincronizados');
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((9 / 9) * 100), 'SINCRONIZAR');
    end
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);
    // Step 3: (FIM)

    SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, 100, 'SINCRONIZAR');

    ExibirMsgSucesso('Sincronia de dados realizada com sucesso');
  except
    On E : Exception do
    begin
      ExibirMsgErro('Erro ao tentar sincronizar dados.' + #13 + E.Message);
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, 0, 'SINCRONIZAR');
    end;
  end;
end;

procedure TFrmSincronizar.TotalizarDados;
var
  aTextoCliente ,
  aTextoProduto ,
  aTextoPedido  : String;
begin
  (*
    OBSERVA��ES:

    Clientes - Pertencem ao usu�rio
    Produtos - Pertencem ao usu�rio
    Pedidos  - Pertencem � loja e ao usu�rio
  *)

  labelCliente.TagFloat := TClienteDao.GetInstance().GetCountSincronizar;
  labelCliente.Text     := FormatFloat('00', labelCliente.TagFloat) + ' Cliente' + IfThen(labelCliente.TagFloat > 1, 's', EmptyStr);

  labelProduto.TagFloat := TProdutoDao.GetInstance().GetCountSincronizar;
  labelProduto.Text     := FormatFloat('00', labelProduto.TagFloat) + ' Produto' + IfThen(labelProduto.TagFloat > 1, 's', EmptyStr);

  labelPedido.TagFloat := TPedidoDao.GetInstance().GetCountSincronizar;
  labelPedido.Text     := FormatFloat('00', labelPedido.TagFloat) + ' Pedido' + IfThen(labelPedido.TagFloat > 1, 's', EmptyStr);

  aTextoCliente := IfThen(labelCliente.TagFloat > 0, 'Aguardando sincronia...', 'Aguardando...');
  aTextoProduto := IfThen(labelProduto.TagFloat > 0, 'Aguardando sincronia...', 'Aguardando...');
  aTextoPedido  := IfThen(labelPedido.TagFloat  > 0, 'Aguardando sincronia...', 'Aguardando...');

  SetProgressoBarra(recBarraClienteAzul, lblBarraCliente , recBarraClienteCinza.Width, 0, aTextoCliente);
  SetProgressoBarra(recBarraProdutoAzul, lblBarraProduto , recBarraProdutoCinza.Width, 0, aTextoProduto);
  SetProgressoBarra(recBarraPedidoAzul , lblBarraPedido  , recBarraPedidoCinza.Width , 0, aTextoPedido);
  SetProgressoBarra(recSincronizar     , labelSincronizar, rectangleSincronizar.Width, 0, 'SINCRONIZAR');
end;

function TFrmSincronizar.UploadClientes: String;
var
  aRetorno  : String;
  aClientes : TJSONArray;
  aCliente,
  aJson   : TJSONObject;
  daoCliente : TClienteDao;
  aTudo,
  I    : Integer;
  aParte : Currency;
begin
  aRetorno  := 'OK';
  aClientes := TJSONArray.Create;
  try

    daoCliente := TClienteDao.GetInstance();
    daoCliente.CarregarDadosToSynchrony;

    aTudo := (High(daoCliente.Lista) + 1);

    for I := Low(daoCliente.Lista) to High(daoCliente.Lista) do
    begin
      aCliente := TJSONObject.Create;

      aCliente.AddPair('id', daoCliente.Lista[I].ID.ToString);
      aCliente.AddPair('cd', CurrToStr(daoCliente.Lista[I].Codigo));
      aCliente.AddPair('nm', daoCliente.Lista[I].Nome);
      aCliente.AddPair('cp', daoCliente.Lista[I].CpfCnpj);
      aCliente.AddPair('ct', daoCliente.Lista[I].Contato);
      aCliente.AddPair('fn', daoCliente.Lista[I].Telefone);
      aCliente.AddPair('ce', daoCliente.Lista[I].Celular);
      aCliente.AddPair('em', daoCliente.Lista[I].Email);
      aCliente.AddPair('ed', daoCliente.Lista[I].Endereco);
      aCliente.AddPair('ob', daoCliente.Lista[I].Observacao);
      aCliente.AddPair('at', IfThen(daoCliente.Lista[I].Ativo, FLAG_SIM, FLAG_NAO));

      aClientes.Add(aCliente);

      // Parte do todo que � de 33.33%
      aParte := (((I + 1) / aTudo) * 33.33);
      SetProgressoBarra(recBarraClienteAzul, lblBarraCliente , recBarraClienteCinza.Width, aParte, 'Enviando clientes...');
    end;

    if (aTudo > 0) then
    begin
      aJson := DM.SetUploadClientes(aClientes);
      if Assigned(aJson) then
        aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));
    end;
  finally
    aClientes.DisposeOf;
    Result := aRetorno;
  end;
end;

function TFrmSincronizar.UploadPedidos: String;
var
  aRetorno  : String;
  aPedidos  ,
  aItens    : TJSONArray;
  aPedido   ,
  aItem     ,
  aJson     : TJSONObject;
  daoPedido : TPedidoDao;
  daoItem   : TPedidoItemDao;
  aTudo,
  X, I   : Integer;
  aParte : Currency;
begin
  aRetorno := 'OK';
  aPedidos := TJSONArray.Create;
  aItens   := TJSONArray.Create;
  try

    daoPedido := TPedidoDao.GetInstance();
    daoPedido.CarregarDadosToSynchrony;

    daoItem := TPedidoItemDao.GetInstance();
    daoItem.CarregarDadosToSynchrony;

    aTudo := (High(daoPedido.Lista) + 1) + (High(daoItem.Lista) + 1);

    X := Low(daoPedido.Lista);
    for I := Low(daoPedido.Lista) to High(daoPedido.Lista) do
    begin
      aPedido := TJSONObject.Create;

      aPedido.AddPair('id', daoPedido.Lista[I].ID.ToString);
      aPedido.AddPair('cd', CurrToStr(daoPedido.Lista[I].Codigo));
      aPedido.AddPair('tp', IntToStr(Ord(daoPedido.Lista[I].Tipo)));
      aPedido.AddPair('lj', daoPedido.Lista[I].Loja.ID.ToString);
      aPedido.AddPair('cl', daoPedido.Lista[I].Cliente.ID.ToString);
      aPedido.AddPair('ct', daoPedido.Lista[I].Contato);
      aPedido.AddPair('dt', FormatDateTime('dd/mm/yyyy', daoPedido.Lista[I].DataEmissao));
      aPedido.AddPair('vt', FormatFloat('0', daoPedido.Lista[I].GetValorTotalInteiro));    // Remover o ponto flutuante da moeda
      aPedido.AddPair('vd', FormatFloat('0', daoPedido.Lista[I].GetValorDescontoInteiro)); // Remover o ponto flutuante da moeda
      aPedido.AddPair('vp', FormatFloat('0', daoPedido.Lista[I].GetValorPedidoInteiro));   // Remover o ponto flutuante da moeda
      aPedido.AddPair('ob', daoPedido.Lista[I].Observacao);
      aPedido.AddPair('et', IfThen(daoPedido.Lista[I].Entregue, FLAG_SIM, FLAG_NAO));
      aPedido.AddPair('at', IfThen(daoPedido.Lista[I].Ativo, FLAG_SIM, FLAG_NAO));
      aPedido.AddPair('at', EmptyStr);

      aPedidos.Add(aPedido);

      // Parte do todo que � de 33.33%
      Inc(X);
      aParte := ((X / aTudo) * 33.33);
      SetProgressoBarra(recBarraPedidoAzul, lblBarraPedido , recBarraPedidoCinza.Width, aParte, 'Enviando pedidos...');
    end;

    for I := Low(daoItem.Lista) to High(daoItem.Lista) do
    begin
      aItem := TJSONObject.Create;

      aItem.AddPair('id', daoItem.Lista[I].ID.ToString);
      aItem.AddPair('cd', CurrToStr(daoItem.Lista[I].Codigo));
      aItem.AddPair('pe', daoItem.Lista[I].PedidoID.ToString);
      aItem.AddPair('pd', daoItem.Lista[I].ProdutoID.ToString);
      aItem.AddPair('qt', FormatFloat('0', daoItem.Lista[I].GetQuantidadeInteiro));           // Remover o ponto flutuante
      aItem.AddPair('vu', FormatFloat('0', daoItem.Lista[I].GetValorUnitarioInteiro));        // Remover o ponto flutuante da moeda
      aItem.AddPair('vt', FormatFloat('0', daoItem.Lista[I].GetValorTotalInteiro));           // Remover o ponto flutuante da moeda
      aItem.AddPair('vd', FormatFloat('0', daoItem.Lista[I].GetValorTotalDescontoInteiro));   // Remover o ponto flutuante da moeda
      aItem.AddPair('vl', FormatFloat('0', daoItem.Lista[I].GetValorLiquidoInteiro));         // Remover o ponto flutuante da moeda
      aItem.AddPair('ob', daoItem.Lista[I].Observacao);

      aItens.Add(aItem);

      // Parte do todo que � de 33.33%
      Inc(X);
      aParte := ((X / aTudo) * 33.33);
      SetProgressoBarra(recBarraPedidoAzul, lblBarraPedido , recBarraPedidoCinza.Width, aParte, 'Enviando pedidos...');
    end;

    if (aTudo > 0) then
    begin
      aJson := DM.SetUploadPedidos(aPedidos, aItens);
      if Assigned(aJson) then
        aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));
    end;
  finally
    aPedidos.DisposeOf;
    aItens.DisposeOf;

    Result := aRetorno;
  end;
end;

function TFrmSincronizar.UploadProdutos: String;
var
  aRetorno  : String;
  aProdutos : TJSONArray;
  aProduto,
  aJson   : TJSONObject;
  daoProduto : TProdutoDao;
  aTudo,
  I    : Integer;
  aParte : Currency;
//  aFoto  : TBitmap;
begin
  aRetorno  := 'OK';
  aProdutos := TJSONArray.Create;
  try

    daoProduto := TProdutoDao.GetInstance();
    daoProduto.CarregarDadosToSynchrony;

    aTudo := (High(daoProduto.Lista) + 1);

    for I := Low(daoProduto.Lista) to High(daoProduto.Lista) do
    begin
      aProduto := TJSONObject.Create;

      aProduto.AddPair('id', daoProduto.Lista[I].ID.ToString);
      aProduto.AddPair('cd', CurrToStr(daoProduto.Lista[I].Codigo));
      aProduto.AddPair('ds', daoProduto.Lista[I].Descricao);
      aProduto.AddPair('br', daoProduto.Lista[I].CodigoEan);

      if (daoProduto.Lista[I].Foto <> nil) then
      begin
//        aFoto := TBitmap.Create;
//        aFoto.LoadFromStream(daoProduto.Lista[I].Foto);
//        aProduto.AddPair('ft', Base64FromBitmap(aFoto));
        aProduto.AddPair('ft', Base64FromBitmap(daoProduto.Lista[I].Foto));
      end
      else
        aProduto.AddPair('ft', EmptyStr);

      aProduto.AddPair('vl', FormatFloat('0', daoProduto.Lista[I].GetValorInteiro)); // Remover o ponto flutuante da moeda
      aProduto.AddPair('at', IfThen(daoProduto.Lista[I].Ativo, FLAG_SIM, FLAG_NAO));

      aProdutos.Add(aProduto);

      // Parte do todo que � de 33.33%
      aParte := (((I + 1) / aTudo) * 33.33);
      SetProgressoBarra(recBarraProdutoAzul, lblBarraProduto , recBarraProdutoCinza.Width, aParte, 'Enviando produtos...');
    end;

    if (aTudo > 0) then
    begin
      aJson := DM.SetUploadProdutos(aProdutos);
      if Assigned(aJson) then
        aRetorno := StrClearValueJson(HTMLDecode(aJson.Get('retorno').JsonValue.ToString));
    end;
  finally
    aProdutos.DisposeOf;
    Result := aRetorno;
  end;
end;

end.
