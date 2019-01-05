unit interfaces.Usuario;

interface

Type
  IObservadorUsuario = interface // IObserver
    ['{9995A554-5320-49EA-ADD7-8DB3642845AA}']
    procedure AtualizarUsuario;
  end;

  IUsuarioObservado = interface  // ISubject
    ['{141A3C20-9201-4658-9992-D4B5059E9176}']
    procedure AdicionarObservador(Observer : IObservadorUsuario);
    procedure RemoverObservador(Observer : IObservadorUsuario);
    procedure RemoverTodosObservadores;
    procedure Notificar;
  end;


implementation

end.
