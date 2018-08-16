program appMedicalNotice;

uses
  System.StartUpCopy,
  FMX.Forms,
  USplash in 'src\USplash.pas' {FrmSplash},
  UDados in 'src\UDados.pas' {DtmDados: TDataModule},
  model.Especialidade in 'src\model\model.Especialidade.pas',
  dao.Especialidade in 'src\dao\dao.Especialidade.pas',
  classes.HttpConnect in 'src\classes\classes.HttpConnect.pas',
  classes.Constantes in 'src\classes\classes.Constantes.pas',
  classes.ScriptDDL in 'src\classes\classes.ScriptDDL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'App Medical Notice';
  Application.CreateForm(TDtmDados, DtmDados);
  Application.CreateForm(TFrmSplash, FrmSplash);
  Application.Run;
end.
