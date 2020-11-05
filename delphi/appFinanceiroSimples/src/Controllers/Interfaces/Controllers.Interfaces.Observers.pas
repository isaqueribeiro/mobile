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

  IObserverCompromissoController = interface
    ['{3CAAA306-DC7F-438B-9705-30A36DCDD2C0}']
    procedure AtualizarCompromisso;
  end;

  ISubjectCompromissoController = interface
    ['{154A9D01-153A-48FA-86E3-3593F302512E}']
    procedure AdicionarObservador(Observer : IObserverCompromissoController);
    procedure RemoverObservador(Observer   : IObserverCompromissoController);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

implementation

end.
