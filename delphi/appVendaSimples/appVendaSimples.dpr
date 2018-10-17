program appVendaSimples;

uses
  System.StartUpCopy,
  FMX.Forms,
  UInicial in 'src\UInicial.pas' {FrmInicial},
  UConstantes in 'src\UConstantes.pas',
  ULogin in 'src\ULogin.pas' {FrmLogin},
  UDM in 'src\UDM.pas' {DM: TDataModule},
  UPrincipal in 'src\UPrincipal.pas' {FrmPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.Run;
end.
