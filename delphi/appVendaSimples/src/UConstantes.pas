unit UConstantes;

interface

Type
  TTipoCliente = (tcPessoaFisica, tcPessoaJuridica);
  TTipoLoja = TTipoCliente;
  TTipoPedido = (tpOrcamento, tpPedido);

const
  cnsNameDB     = 'venda_simples.db';
  crCinza       = $FFB6ACAC;
  crCinzaEscuro = $FF746B6B;
  crAzul        = $FF1E87AF;
  vlOpacityIcon = 0.3;

  EMPTY_DATE = '30/12/1899';

implementation

end.
