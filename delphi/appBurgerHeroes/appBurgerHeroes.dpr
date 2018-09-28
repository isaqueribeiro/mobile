program appBurgerHeroes;

uses
  System.StartUpCopy,
  FMX.Forms,
  UPrincipal in 'src\UPrincipal.pas' {FrmPrincipal},
  classes.Constantes in 'src\classes\classes.Constantes.pas',
  UDM in 'src\UDM.pas' {DM: TDataModule},
  UAbout in 'src\UAbout.pas' {FrmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
