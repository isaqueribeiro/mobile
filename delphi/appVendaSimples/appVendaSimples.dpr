program appVendaSimples;

uses
  System.StartUpCopy,
  Skia,
  FMX.Forms,
  Skia.FMX,
  UInicial in 'src\UInicial.pas' {FrmInicial},
  UConstantes in 'src\UConstantes.pas',
  ULogin in 'src\ULogin.pas' {FrmLogin},
  UDM in 'src\UDM.pas' {DM: TDataModule},
  UPrincipal in 'src\UPrincipal.pas' {FrmPrincipal},
  UMensagem in 'src\UMensagem.pas' {FrmMensagem},
  UPadrao in 'src\UPadrao.pas' {FrmPadrao},
  classes.ScriptDDL in 'src\classes.ScriptDDL.pas',
  app.OpenViewUrl in 'src\app.OpenViewUrl.pas',
  app.Funcoes in 'src\app.Funcoes.pas',
  model.Versao in 'src\model.Versao.pas',
  model.Usuario in 'src\model.Usuario.pas',
  model.Cliente in 'src\model.Cliente.pas',
  model.Loja in 'src\model.Loja.pas',
  model.Notificacao in 'src\model.Notificacao.pas',
  model.Produto in 'src\model.Produto.pas',
  model.Pedido in 'src\model.Pedido.pas',
  model.PedidoItem in 'src\model.PedidoItem.pas',
  dao.Versao in 'src\dao.Versao.pas',
  dao.Usuario in 'src\dao.Usuario.pas',
  dao.Cliente in 'src\dao.Cliente.pas',
  dao.Notificacao in 'src\dao.Notificacao.pas',
  dao.Produto in 'src\dao.Produto.pas',
  dao.Pedido in 'src\dao.Pedido.pas',
  dao.PedidoItem in 'src\dao.PedidoItem.pas',
  dao.Loja in 'src\dao.Loja.pas',
  dao.Configuracao in 'src\dao.Configuracao.pas',
  interfaces.Usuario in 'src\interfaces.Usuario.pas',
  interfaces.Cliente in 'src\interfaces.Cliente.pas',
  interfaces.Produto in 'src\interfaces.Produto.pas',
  interfaces.Pedido in 'src\interfaces.Pedido.pas',
  interfaces.PedidoItem in 'src\interfaces.PedidoItem.pas',
  interfaces.Loja in 'src\interfaces.Loja.pas',
  UProduto in 'src\UProduto.pas' {FrmProduto},
  UPadraoEditar in 'src\UPadraoEditar.pas' {FrmPadraoEditar},
  UPadraoCadastro in 'src\UPadraoCadastro.pas' {FrmPadraoCadastro},
  UCliente in 'src\UCliente.pas' {FrmCliente},
  UPerfil in 'src\UPerfil.pas' {FrmPerfil},
  UCompartilhar in 'src\UCompartilhar.pas' {FrmCompartilhar},
  UPedido in 'src\UPedido.pas' {FrmPedido},
  UPedidoItem in 'src\UPedidoItem.pas' {FrmPedidoItem},
  ULoja in 'src\ULoja.pas' {FrmLoja},
  USincronizar in 'src\USincronizar.pas' {FrmSincronizar},
  u99Permissions in 'src\u99Permissions.pas';

{$R *.res}

begin
  GlobalUseSkia := True;

  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.Run;
end.
