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
  Views.Interfaces.Observers in 'Views\Interfaces\Views.Interfaces.Observers.pas',
  Views.Mensagem in 'Views\Views.Mensagem.pas' {ViewMensagem},
  Views.Interfaces.Mensagem in 'Views\Interfaces\Views.Interfaces.Mensagem.pas',
  Model.Lancamento in 'Models\Model.Lancamento.pas',
  Controller.Lancamento in 'Controllers\Controller.Lancamento.pas',
  Controllers.Interfaces.Observers in 'Controllers\Interfaces\Controllers.Interfaces.Observers.pas',
  Services.ComplexTypes in 'Services\Services.ComplexTypes.pas',
  Services.Format in 'Services\Services.Format.pas',
  Services.Utils in 'Services\Services.Utils.pas',
  Services.SmartPoint in 'Services\Services.SmartPoint.pas',
  Services.MessageDialog in 'Services\Services.MessageDialog.pas',
  Model.Usuario in 'Models\Model.Usuario.pas',
  Controller.Usuario in 'Controllers\Controller.Usuario.pas',
  Services.Hash in 'Services\Services.Hash.pas',
  View.CategoriaSelecao in 'View.CategoriaSelecao.pas' {FrmCategoriaSelecao},
  Model.Compromisso in 'Models\Model.Compromisso.pas',
  Controller.Compromisso in 'Controllers\Controller.Compromisso.pas',
  View.Compromissos in 'View.Compromissos.pas' {FrmCompromissos};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMRecursos, DMRecursos);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmInicio, FrmInicio);
  Application.Run;
end.
