unit appCatalogo.Views.Catalogo.Cadastro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, appCatalogo.Views.Default,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Edit;

type
  TViewCatalogoCadastro = class(TViewDefault)
    Label1: TLabel;
    Layout1: TLayout;
    edtNome: TEdit;
    lytBtnSave: TLayout;
    recBrnSave: TRectangle;
    Circle1: TCircle;
    lblEditarLogotipo: TLabel;
    lblBtnSalvar: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewCatalogoCadastro: TViewCatalogoCadastro;

implementation

{$R *.fmx}

end.
