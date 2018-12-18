unit interfaces.Cliente;

interface

Type
  IObservadorCliente = interface // IObserver
    ['{2488845B-6F57-483E-916A-280344B7D196}']
    procedure AtualizarCliente;
  end;

  IClienteObservado = interface  // ISubject
    ['{DE682D40-0EE4-4E94-A9D2-05BC024B542D}']
    procedure AdicionarObservador(Observer : IObservadorCliente);
    procedure RemoverObservador(Observer : IObservadorCliente);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

implementation

end.
