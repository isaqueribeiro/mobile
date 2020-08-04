unit model.Pedido;

interface

uses
  UConstantes,
  model.Cliente,
  model.Loja,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TPedido = class(TObject)
    private
      aID      : TGUID;
      aCodigo  : Currency;
      aNumero  : String;
      aTipo    : TTipoPedido;
      aCliente : TCliente;
      aContato : String;
      aDataEmissao  : TDate;
      aValorTotal   ,
      aValorDesconto,
      aValorPedido  : Currency;
      aAtivo        ,
      aFaturado     ,
      aEntregue     : Boolean;
      aObservacao   : String;
      aReferencia   : TGUID;
      aLoja : TLoja;
      function GetSincronizado : Boolean;
    public
      constructor Create; overload;
      destructor Destroy; overload;

      property ID      : TGUID read aID write aID;
      property Codigo  : Currency read aCodigo write aCodigo;
      property Numero  : String read aNumero write aNumero;
      property Tipo    : TTipoPedido read aTipo write aTipo;
      property Cliente : TCliente read aCliente write aCliente;
      property Contato : String read aContato write aContato;
      property DataEmissao   : TDate read aDataEmissao write aDataEmissao;
      property ValorTotal    : Currency read aValorTotal write aValorTotal;
      property ValorDesconto : Currency read aValorDesconto write aValorDesconto;
      property ValorPedido   : Currency read aValorPedido write aValorPedido;
      property Ativo         : Boolean read aAtivo write aAtivo;
      property Faturado      : Boolean read aFaturado write aFaturado;
      property Entregue      : Boolean read aEntregue write aEntregue;
      property Sincronizado  : Boolean read GetSincronizado;
      property Observacao    : String read aObservacao write aObservacao;
      property Referencia    : TGUID read aReferencia write aReferencia;
      property Loja : TLoja read aLoja write aLoja;

      procedure NewID;

      function ToString : String; override;
      function GetValorTotalInteiro : Int64;
      function GetValorDescontoInteiro : Int64;
      function GetValorPedidoInteiro : Int64;
  end;

  TPedidos = Array of TPedido;

implementation

{ TPedido }

constructor TPedido.Create;
begin
  inherited Create;
  aId      := GUID_NULL;
  aCodigo  := 0;
  aNumero  := EmptyStr;
  aTipo    := tpOrcamento;
  aContato := EmptyStr;
  aDataEmissao   := Date;
  aValorTotal    := 0.0;
  aValorDesconto := 0.0;
  aValorPedido   := 0.0;
  aAtivo         := True;
  aFaturado      := False;
  aEntregue      := False;
  aObservacao    := EmptyStr;
  aReferencia    := GUID_NULL;

  aCliente := TCliente.Create;
  aLoja    := TLoja.Create;
end;

destructor TPedido.Destroy;
begin
  aCliente.Free;
  aLoja.Free;
  inherited Destroy;
end;

function TPedido.GetSincronizado : Boolean;
begin
  Result := (aTipo = tpPedido);
end;

function TPedido.GetValorDescontoInteiro: Int64;
begin
  Result := Trunc(aValorDesconto * 100);
end;

function TPedido.GetValorPedidoInteiro: Int64;
begin
  Result := Trunc(aValorPedido * 100);
end;

function TPedido.GetValorTotalInteiro: Int64;
begin
  Result := Trunc(aValorTotal * 100);
end;

procedure TPedido.NewID;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

function TPedido.ToString: String;
begin
  if (aTipo = TTipoPedido.tpPedido) then
  begin
    if (aNumero.Trim = EmptyStr) then
      Result := 'Pedido #' + FormatFloat('00000', aCodigo)
    else
      Result := 'Pedido #' + aNumero.Trim;
  end
  else
    Result := 'Orçamento #' + FormatFloat('00000', aCodigo);
end;

end.
