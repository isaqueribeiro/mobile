program appCarteiraCliente;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainUI in 'src\MainUI.pas' {FrmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
