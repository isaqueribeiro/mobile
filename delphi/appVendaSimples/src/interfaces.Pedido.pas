unit interfaces.Pedido;

interface

Type
  IObservadorPedido = interface // IObserver
    ['{14F476F6-05FF-4110-92F2-8486A577AC9B}']
    procedure AtualizarPedido;
  end;

  IPedidoObservado = interface  // ISubject
    ['{15C270D8-13A7-4145-A3BD-E010DAD02E39}']
    procedure AdicionarObservador(Observer : IObservadorPedido);
    procedure RemoverObservador(Observer : IObservadorPedido);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

implementation

end.
