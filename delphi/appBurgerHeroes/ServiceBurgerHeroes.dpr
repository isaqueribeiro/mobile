program ServiceBurgerHeroes;

uses
  System.Android.ServiceApplication,
  classes.Constantes in 'src\classes\classes.Constantes.pas',
  UDMService in 'src\UDMService.pas' {DMService: TAndroidService};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMService, DMService);
  Application.Run;
end.
