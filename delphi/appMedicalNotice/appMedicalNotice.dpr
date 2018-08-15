program appMedicalNotice;

uses
  System.StartUpCopy,
  FMX.Forms,
  USplash in 'src\USplash.pas' {FrmSplash},
  UDados in 'src\UDados.pas' {DtmDados: TDataModule},
  model.Especialidade in 'src\model\model.Especialidade.pas',
  dao.Especialidade in 'src\dao\dao.Especialidade.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDtmDados, DtmDados);
  Application.CreateForm(TFrmSplash, FrmSplash);
  Application.Run;
end.
