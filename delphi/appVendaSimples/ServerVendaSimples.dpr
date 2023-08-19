program ServerVendaSimples;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Principal in 'server\View.Principal.pas' {ViewPrincipal},
  DataModule.Base in 'server\DataModule\DataModule.Base.pas' {DataModuleBase: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDataModuleBase, DataModuleBase);
  Application.CreateForm(TViewPrincipal, ViewPrincipal);
  Application.Run;
end.
