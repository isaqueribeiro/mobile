program appVendaSimples;

uses
  System.StartUpCopy,
  FMX.Forms,
  UInicial in 'src\UInicial.pas' {FrmInicial},
  UConstantes in 'src\UConstantes.pas',
  ULogin in 'src\ULogin.pas' {FrmLogin},
  UDM in 'src\UDM.pas' {DM: TDataModule},
  UPrincipal in 'src\UPrincipal.pas' {FrmPrincipal},
  UMensagem in 'src\UMensagem.pas' {FrmMensagem},
  UPadrao in 'src\UPadrao.pas' {FrmPadrao},
  classes.ScriptDDL in 'src\classes.ScriptDDL.pas',
  app.Funcoes in 'src\app.Funcoes.pas',
  model.Pedido in 'src\model.Pedido.pas',
  model.Cliente in 'src\model.Cliente.pas',
  model.Loja in 'src\model.Loja.pas',
  model.Notificacao in 'src\model.Notificacao.pas',
  model.Produto in 'src\model.Produto.pas',
  dao.Pedido in 'src\dao.Pedido.pas',
  dao.Cliente in 'src\dao.Cliente.pas',
  dao.Notificacao in 'src\dao.Notificacao.pas',
  dao.Produto in 'src\dao.Produto.pas',
  UProduto in 'src\UProduto.pas' {FrmProduto},
  UPadraoEditar in 'src\UPadraoEditar.pas' {FrmPadraoEditar},
  UPadraoCadastro in 'src\UPadraoCadastro.pas' {FrmPadraoCadastro},
  UCliente in 'src\UCliente.pas' {FrmCliente};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.Run;
end.
