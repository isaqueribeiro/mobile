unit USincronizar;

interface

uses
  app.Funcoes,
  dao.Usuario,
  dao.Loja,
  dao.Cliente,
  dao.Produto,
  dao.Pedido,
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

  // Barra botão Sincronizar
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
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((1 / 9) * 100), 'SINCRONIZANDO...')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);

    // Step 2: 66 de 100 - Processando lista enviada
    aRetorno := ProcessarClientes;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((2 / 9) * 100), 'SINCRONIZANDO...')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);

    // Step 3: 99 de 100 - Baixando lista enviada
    aRetorno := DownloadClientes;
    if (aRetorno.ToUpper = 'OK') then
    begin
      SetProgressoBarra(recBarraClienteAzul, lblBarraCliente, recBarraClienteCinza.Width, 100, 'Clientes sincronizados');
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((3 / 9) * 100), 'SINCRONIZANDO...');
    end
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);

    // PRODUTOS ============================================================
    imageProduto.AnimateFloat('Opacity', 1.0, 0.5, TAnimationType.&In, TInterpolationType.Linear);

    // Step 1: 33 de 100 - Enviando lista de produtos
    aRetorno := UploadProdutos;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((4 / 9) * 100), 'SINCRONIZANDO...')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);

    // Step 2: 66 de 100 - Processando lista enviada
    aRetorno := ProcessarProdutos;
    if (aRetorno.ToUpper = 'OK') then
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((5 / 9) * 100), 'SINCRONIZANDO...')
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);

    // Step 3: 99 de 100 - Baixando lista enviada
    aRetorno := DownloadProdutos;
    if (aRetorno.ToUpper = 'OK') then
    begin
      SetProgressoBarra(recBarraProdutoAzul, lblBarraProduto, recBarraProdutoCinza.Width, 100, 'Produtos sincronizados');
      SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, ((6 / 9) * 100), 'SINCRONIZANDO...');
    end
    else
    begin
      ExibirMsgAlerta(aRetorno);
      Exit;
    end;

    Sleep(250);

    // PEDIDOS ============================================================
    imagePedido.AnimateFloat('Opacity', 1.0, 0.5, TAnimationType.&In, TInterpolationType.Linear);








    //SetProgressoBarra(recSincronizar, labelSincronizar, rectangleSincronizar.Width, 100, 'SINCRONIZADO');
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
    OBSERVAÇÕES:

    Clientes - Pertencem ao usuário
    Produtos - Pertencem ao usuário
    Pedidos  - Pertencem à loja e ao usuário
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

      // Parte do todo que é de 33.33%
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

      // Parte do todo que é de 33.33%
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
