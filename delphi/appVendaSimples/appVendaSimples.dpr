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
  classes.ScriptDDL in 'src\classes.ScriptDDL.pas',
  app.Funcoes in 'src\app.Funcoes.pas',
  model.Pedido in 'src\model.Pedido.pas',
  model.Cliente in 'src\model.Cliente.pas',
  dao.Pedido in 'src\dao.Pedido.pas',
  model.Loja in 'src\model.Loja.pas',
  dao.Cliente in 'src\dao.Cliente.pas',
  model.Notificacao in 'src\model.Notificacao.pas',
  dao.Notificacao in 'src\dao.Notificacao.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.Run;
end.
