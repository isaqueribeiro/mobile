unit Views.Interfaces.Mensagem;

interface

type
  IViewMensagem = interface
    ['{CB6F35A6-0796-48EA-8719-C34D8746A2CD}']
    function Titulo(Value : String) : IViewMensagem;
    function Mensagem(Value : String) : IViewMensagem;
  end;

implementation

end.
