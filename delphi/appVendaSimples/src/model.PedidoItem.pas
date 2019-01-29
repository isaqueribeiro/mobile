unit model.PedidoItem;

interface

uses
  UConstantes,
  model.Pedido,
  model.Produto,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TPedidoItem = class(TObject)
    private
      aID       : TGUID;
      aCodigo   : Currency;
      aPedido   : TPedido;
      aProduto  : TProduto;
      aQuantidade   ,
      aValorUnitario,
      aValorTotal   ,
      aValorDesconto,
      aValorLiquido : Currency;
      aObservacao   : String;
      aReferencia   : TGUID;

      function GetPedidoID : TGUID;
    public
      constructor Create; overload;
      destructor Destroy; overload;

      property ID       : TGUID read aID write aID;
      property Codigo   : Currency read aCodigo write aCodigo;
      property PedidoID : TGUID read GetPedidoID;
      property Pedido   : TPedido read aPedido write aPedido;
      property Produto  : TProduto read aProduto write aProduto;
      property Quantidade    : Currency read aQuantidade write aQuantidade;
      property ValorUnitario : Currency read aValorUnitario write aValorUnitario;
      property ValorTotal    : Currency read aValorTotal write aValorTotal;
      property ValorDesconto : Currency read aValorDesconto write aValorDesconto;
      property ValorLiquido  : Currency read aValorLiquido write aValorLiquido;
      property Observacao    : String read aObservacao write aObservacao;
      property Referencia    : TGUID read aReferencia write aReferencia;

      procedure NewID;

      function ToString : String; override;
  end;

  TPedidoItens = Array of TPedidoItem;

implementation

{ TPedidoItem }

constructor TPedidoItem.Create;
begin
  inherited Create;
  aId       := GUID_NULL;
  aCodigo   := 0;
  aQuantidade    := 1;
  aValorUnitario := 0.0;
  aValorTotal    := 0.0;
  aValorDesconto := 0.0;
  aValorLiquido  := 0.0;
  aObservacao    := EmptyStr;
  aReferencia    := GUID_NULL;

  aPedido   := TPedido.Create;
  aProduto  := TProduto.Create;
end;

destructor TPedidoItem.Destroy;
begin
  aPedido.Free;
  aProduto.Free;
  inherited Destroy;
end;

function TPedidoItem.GetPedidoID: TGUID;
begin
  Result := aPedido.ID;
end;

procedure TPedidoItem.NewID;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

function TPedidoItem.ToString: String;
begin
  Result := 'Item #' + FormatFloat('#00', aCodigo);
end;

end.
