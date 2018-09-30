program appBurgerHeroes;

uses
  System.StartUpCopy,
  FMX.Forms,
  classes.Constantes in 'src\classes\classes.Constantes.pas',
  UPrincipal in 'src\UPrincipal.pas' {FrmPrincipal},
  UDM in 'src\UDM.pas' {DM: TDataModule},
  UAbout in 'src\UAbout.pas' {FrmAbout},
  UDMService in 'src\UDMService.pas' {DMService: TAndroidService};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
