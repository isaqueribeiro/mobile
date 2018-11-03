unit model.Pedido;

interface

uses
  model.Cliente,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TTipoPedido = (tpOrcamento, tpPedido);
  TPedido = class(TObject)
    private
      aID      : TGUID;
      aCodigo  : Currency;
      aTipo    : TTipoPedido;
      aCliente : TCliente;
      aContato : String;
      aData    : TDate;
      aValorTotal   ,
      aValorDesconto,
      aValorPedido  : Currency;
      aAtivo        ,
      aEntregue     ,
      aSincronizado : Boolean;
      aObservacao   : String;
      aReferencia   : TGUID;
    public
      constructor Create; overload;
      destructor Destroy; overload;

      property ID      : TGUID read aID write aID;
      property Codigo  : Currency read aCodigo write aCodigo;
      property Tipo    : TTipoPedido read aTipo write aTipo;
      property Cliente : TCliente read aCliente write aCliente;
      property Contato : String read aContato write aContato;
      property Data    : TDate read aData write aData;
      property ValorTotal    : Currency read aValorTotal write aValorTotal;
      property ValorDesconto : Currency read aValorDesconto write aValorDesconto;
      property ValorPedido   : Currency read aValorPedido write aValorPedido;
      property Ativo         : Boolean read aAtivo write aAtivo;
      property Entregue      : Boolean read aEntregue write aEntregue;
      property Sincronizado  : Boolean read aSincronizado write aSincronizado;
      property Observacao    : String read aObservacao write aObservacao;
      property Referencia    : TGUID read aReferencia write aReferencia;

      procedure NewID;

      function ToString : String; override;
  end;

  TPedidos = Array of TPedido;

  function IfThen(aExpressao : Boolean; aTrue, aFalse : TTipoPedido) : TTipoPedido;

implementation

function IfThen(aExpressao : Boolean; aTrue, aFalse : TTipoPedido) : TTipoPedido;
begin
  if aExpressao then
    Result := aTrue
  else
    Result := aFalse;
end;

{ TPedido }

constructor TPedido.Create;
begin
  inherited Create;
  aId      := GUID_NULL;
  aCodigo  := 0;
  aTipo    := tpOrcamento;
  aCliente := TCliente.Create;
  aContato := EmptyStr;
  aData    := Date;
  aValorTotal    := 0.0;
  aValorDesconto := 0.0;
  aValorPedido   := 0.0;
  aAtivo         := True;
  aEntregue      := False;
  aSincronizado  := False;
  aObservacao    := EmptyStr;
  aReferencia    := GUID_NULL;
end;

destructor TPedido.Destroy;
begin
  aCliente.Free;
  inherited Destroy;
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
  Result := 'Pedido #' + FormatFloat('00000', aCodigo);
end;

end.
