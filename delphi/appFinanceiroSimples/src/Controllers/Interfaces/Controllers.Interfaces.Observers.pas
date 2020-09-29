unit Controllers.Interfaces.Observers;

interface

type
  IObserverLancamentoController = interface
    ['{89ADCC5E-C8D8-4221-9942-3908A9A34755}']
    procedure AtualizarLancamento;
  end;

  ISubjectLancamentoController = interface
    ['{A6DEB5BB-CF30-48AA-86BA-BEC0DBA15D02}']
    procedure AdicionarObservador(Observer : IObserverLancamentoController);
    procedure RemoverObservador(Observer   : IObserverLancamentoController);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

implementation

end.
