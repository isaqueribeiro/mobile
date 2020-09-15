unit Services.ComplexTypes;

interface

type
  TTipoOperacaoController = (operControllerBrowser, operControllerInsert, operControllerUpdate, operControllerDelete);
  TTipoLancamento = (tipoReceita, tipoDespesa);
  TTotalLancamentos = record
    Receitas : Currency;
    Despesas : Currency;
    Saldo    : Currency;
  end;

implementation

end.
