unit interfaces.Loja;

interface
Type
  IObservadorLoja = interface // IObserver
    ['{D4ED02EA-3504-4E33-8E8B-219DFB41C7D0}']
    procedure AtualizarLoja;
  end;

  ILojaObservado = interface  // ISubject
    ['{8197DF15-44EA-4153-AA9F-05CB7EA0594D}']
    procedure AdicionarObservador(Observer : IObservadorLoja);
    procedure RemoverObservador(Observer : IObservadorLoja);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;


implementation

end.
