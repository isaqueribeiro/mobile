program appFinanceiroSimples;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Incio in 'View.Incio.pas' {FrmInicio},
  View.Login in 'View.Login.pas' {FrmLogin},
  u99Permissions in 'Classes\u99Permissions.pas',
  View.Principal in 'View.Principal.pas' {FrmPrincipal},
  DataModule.Recursos in 'DataModule\DataModule.Recursos.pas' {DMRecursos: TDataModule},
  Classe.ObjetoItemListView in 'Classes\Classe.ObjetoItemListView.pas',
  Classes.ScriptDDL in 'Classes\Classes.ScriptDDL.pas',
  View.Lancamentos in 'View.Lancamentos.pas' {FrmLancamentos},
  View.LancamentoEdicao in 'View.LancamentoEdicao.pas' {FrmLancamentoEdicao},
  View.Categorias in 'View.Categorias.pas' {FrmCategorias},
  View.CategoriaEdicao in 'View.CategoriaEdicao.pas' {FrmCategoriaEdicao},
  DataModule.Conexao in 'DataModule\DataModule.Conexao.pas' {DMConexao: TDataModule},
  Model.Categoria in 'Models\Model.Categoria.pas',
  Controller.Categoria in 'Controllers\Controller.Categoria.pas',
  Services.Utils in 'Services\Services.Utils.pas',
  Services.SmartPoint in 'Services\Services.SmartPoint.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMRecursos, DMRecursos);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmInicio, FrmInicio);
  Application.Run;
end.
