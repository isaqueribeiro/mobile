unit model.PedidoItem;

interface

uses
  UConstantes,
  model.Pedido,
  model.Produto,
  System.Math,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TPedidoItem = class(TObject)
    private
      aID       : TGUID;
      aCodigo   : Integer;
      aPedido   : TPedido;
      aProduto  : TProduto;
      aQuantidade   ,
      aValorUnitario,
      aValorTotal   ,
      aValorTotalDesconto,
      aValorLiquido : Currency;
      aObservacao   : String;
      aReferencia   : TGUID;

      procedure SetQuantidade(Value : Currency);
      procedure SetValorUnitario(Value : Currency);

      function GetPedidoID : TGUID;
      function GetProdutoID : TGUID;
    public
      constructor Create; overload;
      destructor Destroy; overload;

      property ID        : TGUID read aID write aID;
      property Codigo    : Integer read aCodigo write aCodigo;
      property PedidoID  : TGUID read GetPedidoID;
      property Pedido    : TPedido read aPedido write aPedido;
      property Produto   : TProduto read aProduto write aProduto;
      property ProdutoID : TGUID read GetProdutoID;
      property Quantidade    : Currency read aQuantidade write SetQuantidade;
      property ValorUnitario : Currency read aValorUnitario write SetValorUnitario;
      property ValorTotal    : Currency read aValorTotal write aValorTotal;
      property ValorTotalDesconto : Currency read aValorTotalDesconto write aValorTotalDesconto;
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
  aValorTotalDesconto := 0.0;
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

function TPedidoItem.GetProdutoID: TGUID;
begin
  Result := aProduto.ID;
end;

procedure TPedidoItem.NewID;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

procedure TPedidoItem.SetQuantidade(Value: Currency);
begin
  aQuantidade := Value;
  aValorTotal := IfThen(aProduto.Valor <= 0, (aQuantidade * aValorUnitario), (aQuantidade * aProduto.Valor));
  aValorTotalDesconto := IfThen(aProduto.Valor > aValorUnitario, (aQuantidade * (aProduto.Valor - aValorUnitario)), 0);
  aValorLiquido       := (aValorTotal - aValorTotalDesconto);
end;

procedure TPedidoItem.SetValorUnitario(Value: Currency);
begin
  aValorUnitario := Value;
  aValorTotal    := IfThen(aProduto.Valor <= 0, (aQuantidade * aValorUnitario), (aQuantidade * aProduto.Valor));
  aValorTotalDesconto := IfThen(aProduto.Valor > aValorUnitario, (aQuantidade * (aProduto.Valor - aValorUnitario)), 0);
  aValorLiquido       := (aValorTotal - aValorTotalDesconto);
end;

function TPedidoItem.ToString: String;
begin
  Result := 'Item #' + FormatFloat('#00', aCodigo);
end;

end.
