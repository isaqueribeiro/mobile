unit interfaces.PedidoItem;

interface

Type
  IObservadorPedidoItem = interface // IObserver
    ['{5781526A-EB8E-420A-8254-BBFCC37F3B2C}']
    procedure AtualizarPedidoItem;
  end;

  IPedidoItemObservado = interface  // ISubject
    ['{A2C06617-F6AA-4422-B3E0-013DDEB13EC2}']
    procedure AdicionarObservador(Observer : IObservadorPedidoItem);
    procedure RemoverObservador(Observer : IObservadorPedidoItem);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

implementation

end.
