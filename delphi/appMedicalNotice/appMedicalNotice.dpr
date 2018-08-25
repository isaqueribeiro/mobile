program appMedicalNotice;

uses
  System.StartUpCopy,
  FMX.Forms,
  app.Funcoes in 'src\classes\app.Funcoes.pas',
  classes.Constantes in 'src\classes\classes.Constantes.pas',
  classes.HttpConnect in 'src\classes\classes.HttpConnect.pas',
  classes.ScriptDDL in 'src\classes\classes.ScriptDDL.pas',
  model.Especialidade in 'src\model\model.Especialidade.pas',
  model.Usuario in 'src\model\model.Usuario.pas',
  dao.Especialidade in 'src\dao\dao.Especialidade.pas',
  dao.Usuario in 'src\dao\dao.Usuario.pas',
  UCadastroUsuario in 'src\UCadastroUsuario.pas' {FrmCadastroUsuario},
  ULogin in 'src\ULogin.pas' {FrmLogin},
  UPrincipal in 'src\UPrincipal.pas' {FrmPrincipal},
  UDados in 'src\UDados.pas' {DtmDados: TDataModule},
  USplashUI in 'src\USplashUI.pas' {FrmSplashUI};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDtmDados, DtmDados);
  Application.CreateForm(TFrmSplashUI, FrmSplashUI);
  Application.Run;
end.
