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

implementation

end.
