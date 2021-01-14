unit Views.Interfaces.Observers;

interface

type
  IObserverCategoriaEdicao = interface
    ['{E49ECA91-7D31-4683-ADE6-2C613D861FD1}']
    procedure AtualizarCategoria;
  end;

  ISubjectCategoriaEdicao = interface
    ['{086DAA9A-75CE-4E1E-85B8-2D831C11069D}']
    procedure AdicionarObservador(Observer : IObserverCategoriaEdicao);
    procedure RemoverObservador(Observer   : IObserverCategoriaEdicao);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

  IObserverLancamentoEdicao = interface
    ['{4D15F73F-8AF9-4476-9F98-DCFC1CC38EAC}']
    procedure AtualizarItemLancamento;
  end;

  ISubjectLancamentoEdicao = interface
    ['{BA3C15C1-A37E-4449-8C44-809E630A42B8}']
    procedure AdicionarObservador(Observer : IObserverLancamentoEdicao);
    procedure RemoverObservador(Observer   : IObserverLancamentoEdicao);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

  IObserverCompromissoEdicao = interface
    ['{CF5D9749-D3ED-4455-883E-ED39E9FEADA0}']
    procedure AtualizarItemCompromisso;
  end;

  ISubjectCompromissoEdicao = interface
    ['{9AF5A0DB-3AD5-4E7F-A697-2FCE0AB9C2AD}']
    procedure AdicionarObservador(Observer : IObserverCompromissoEdicao);
    procedure RemoverObservador(Observer   : IObserverCompromissoEdicao);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

implementation

end.
