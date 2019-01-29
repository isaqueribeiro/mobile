unit interfaces.Produto;

interface

Type
  IObservadorProduto = interface // IObserver
    ['{EB3CA961-20B3-450B-B3D2-79E8001C4556}']
    procedure AtualizarProduto;
  end;

  IProdutoObservado = interface  // ISubject
    ['{B328868F-9C5C-4A54-91B1-A12E3B8395C1}']
    procedure AdicionarObservador(Observer : IObservadorProduto);
    procedure RemoverObservador(Observer : IObservadorProduto);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;

implementation

end.
