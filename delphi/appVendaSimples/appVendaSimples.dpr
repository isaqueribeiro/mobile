program appVendaSimples;

uses
  System.StartUpCopy,
  FMX.Forms,
  UInicial in 'src\UInicial.pas' {FrmInicial},
  UConstantes in 'src\UConstantes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.Run;
end.
