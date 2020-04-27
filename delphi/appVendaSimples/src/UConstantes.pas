unit UConstantes;

interface

Type
  TTipoCliente = (tcPessoaFisica, tcPessoaJuridica);
  TTipoOperacaoDao = (toBrowser, toIncluir, toEditar, toExcluir, toIncluido, toEditado, toExcluido);
  TTipoLoja = TTipoCliente;
  TTipoPedido = (tpOrcamento, tpPedido);

  TDataHoraServer = record
    Data : String;
    Hora : String;
    DataHora : String;
  end;

const
  VERSION_CODE = 1;
  VERSION_NAME = '1.0.0';

  cnsNameDB     = 'venda_simples.db';
  crBranco      = $FFFFFFFF;
  crVermelho    = $FFE25E5E;
  crCinza       = $FFB6ACAC;
  crCinzaClaro  = $FFD4CFCF;
  crCinzaEscuro = $FF746B6B;
  crAzul        = $FF1E87AF;
  vlOpacityIcon = 0.3;

  EMPTY_DATE  = '30/12/1899';
  KEY_ENCRIPT = 'TheLordIsGod';

  FLAG_SIM = 'S';
  FLAG_NAO = 'N';

  URL_ROOT    = 'http://localhost:51358';
  URL_FUNCOES = '/ws_funcoes.asmx';
  URL_USUARIO = '/ws_usuario.asmx';
  URL_CLIENTE = '/ws_cliente.asmx';
  URL_PRODUTO = '/ws_produto.asmx';
  URL_PEDIDO  = '/ws_pedido.asmx';

implementation

end.
