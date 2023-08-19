program appCatalogo;

uses
  System.StartUpCopy,
  FMX.Forms,
  appCatalogo.Views.Default in '..\Views\appCatalogo.Views.Default.pas' {ViewDefault},
  appCatalogo.Views.Principal in 'Views\appCatalogo.Views.Principal.pas' {ViewPrincipal},
  appCatalogo.Views.Catalogo.Cadastro in 'Views\appCatalogo.Views.Catalogo.Cadastro.pas' {ViewCatalogoCadastro},
  appCatalogo.Views.Produto.Lista in 'Views\appCatalogo.Views.Produto.Lista.pas' {ViewProdutoLista},
  appCatalogo.Views.Produto.Cadastro in 'Views\appCatalogo.Views.Produto.Cadastro.pas' {ViewProdutoCadastro};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewPrincipal, ViewPrincipal);
  Application.CreateForm(TViewProdutoLista, ViewProdutoLista);
  Application.CreateForm(TViewProdutoCadastro, ViewProdutoCadastro);
  Application.CreateForm(TViewCatalogoCadastro, ViewCatalogoCadastro);
  Application.Run;
end.
