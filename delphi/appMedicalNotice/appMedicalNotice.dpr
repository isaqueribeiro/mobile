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
  UPadrao in 'src\UPadrao.pas' {FrmPadrao},
  UPrincipal in 'src\UPrincipal.pas' {FrmPrincipal},
  UDados in 'src\UDados.pas' {DtmDados: TDataModule},
  USplash in 'src\USplash.pas' {FrmSplash};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDtmDados, DtmDados);
  Application.CreateForm(TFrmSplash, FrmSplash);
  Application.Run;
end.
