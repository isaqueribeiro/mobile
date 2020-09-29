unit Services.ComplexTypes;

interface

type
  TTipoMensagem = (tipoMensagemInformacao, tipoMensagemAlerta, tipoMensagemErro, tipoMensagemSucesso, tipoMensagemPergunta);
  TTipoOperacaoController = (operControllerBrowser, operControllerInsert, operControllerUpdate, operControllerDelete);
  TTipoLancamento = (tipoReceita, tipoDespesa);
  TTotalLancamentos = record
    Receitas : Currency;
    Despesas : Currency;
    Saldo    : Currency;
  end;

  TCallbackProcedureObject = procedure(Sender: TObject) of Object;

implementation

end.
