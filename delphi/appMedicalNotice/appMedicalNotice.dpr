program appMedicalNotice;

uses
  System.StartUpCopy,
  FMX.Forms,
  USplash in 'src\USplash.pas' {FrmSplash},
  UDados in 'src\UDados.pas' {DtmDados: TDataModule},
  app.Funcoes in 'src\classes\app.Funcoes.pas',
  model.Especialidade in 'src\model\model.Especialidade.pas',
  model.Usuario in 'src\model\model.Usuario.pas',
  dao.Especialidade in 'src\dao\dao.Especialidade.pas',
  classes.HttpConnect in 'src\classes\classes.HttpConnect.pas',
  classes.Constantes in 'src\classes\classes.Constantes.pas',
  classes.ScriptDDL in 'src\classes\classes.ScriptDDL.pas',
  ULogin in 'src\ULogin.pas' {FrmLogin},
  UCadastroUsuario in 'src\UCadastroUsuario.pas' {FrmCadastroUsuario},
  UPrincipal in 'src\UPrincipal.pas' {FrmPrincipal},
  dao.Usuario in 'src\dao\dao.Usuario.pas',
  UPadrao in 'src\UPadrao.pas' {FrmPadrao};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'App Medical Notice';
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TDtmDados, DtmDados);
  Application.CreateForm(TFrmSplash, FrmSplash);
  Application.Run;
end.
