unit UPerfil;

interface

uses
  System.StrUtils,
  System.Math,
  System.Generics.Collections,
  model.Usuario,
  dao.Usuario,
  interfaces.Usuario,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation;

type
  TFrmPerfil = class(TFrmPadraoCadastro)
    lytEmail: TLayout;
    lineEmail: TLine;
    LabelEmail: TLabel;
    imgEmail: TImage;
    lblEmail: TLabel;
    lytSenha: TLayout;
    lineSenha: TLine;
    LabelSenha: TLabel;
    imgSenha: TImage;
    lblSenha: TLabel;
    lytCelular: TLayout;
    lineCelular: TLine;
    LabelCelular: TLabel;
    imgCelular: TImage;
    lblCelular: TLabel;
    lytCpf: TLayout;
    lineCpf: TLine;
    LabelCpf: TLabel;
    imgCpf: TImage;
    lblCpf: TLabel;
    procedure DoEditarCampo(Sender: TObject);
    procedure DoSalvarPerfil(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  strict private
    { Private declarations }
    aDao : TUsuarioDao;
    FObservers : TList<IObservadorUsuario>;
    procedure FormatarValorCampo(var aStr : String);
    class var aInstance : TFrmPerfil;
  public
    { Public declarations }

    procedure TeclaBackSpace; override;
    procedure TeclaNumero(const aValue : String); override;

    procedure AdicionarObservador(Observer : IObservadorUsuario);
    procedure RemoverObservador(Observer : IObservadorUsuario);
    procedure RemoverTodosObservadores;
    procedure Notificar;

    class function GetInstance : TFrmPerfil;
  end;

  procedure ExibirPerfilUsuario(Observer : IObservadorUsuario);

//var
//  FrmPerfil: TFrmPerfil;
//
implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UMensagem;

procedure ExibirPerfilUsuario(Observer : IObservadorUsuario);
var
  aForm : TFrmPerfil;
begin
  aForm := TFrmPerfil.GetInstance;
  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab := tbsCadastro;

    labelTituloCadastro.Text      := 'MEU PERFIL';
    labelTituloCadastro.TagString := GUIDToString(Model.ID); // Destinado a guardar o ID guid do registro
//    labelTituloCadastro.TagFloat  := Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro
//
//    lblCPF_CNPJ.Text  := Model.CpfCnpj;
//    lblDescricao.Text := Model.Nome;
//    lblEndereco.Text  := Model.Endereco;
//    lblTelefone.Text  := Model.Telefone;
//    lblEmail.Text     := Model.Email;
//    lblObs.Text       := Model.Observacao;
//
//    lblCPF_CNPJ.TagFloat  := IfThen(Trim(Model.CpfCnpj)    = EmptyStr, 0, 1); // Flags: 0 - Sem edição; 1 - Dado editado
//    lblDescricao.TagFloat := IfThen(Trim(Model.Nome)       = EmptyStr, 0, 1);
//    lblEndereco.TagFloat  := IfThen(Trim(Model.Endereco)   = EmptyStr, 0, 1);
//    lblTelefone.TagFloat  := IfThen(Trim(Model.Telefone)   = EmptyStr, 0, 1);
//    lblEmail.TagFloat     := IfThen(Trim(Model.Email)      = EmptyStr, 0, 1);
//    lblObs.TagFloat       := IfThen(Trim(Model.Observacao) = EmptyStr, 0, 1);
//
    lytExcluir.Visible := False;
  end;

  aForm.Show;
end;

{ TFrmPerfil }

procedure TFrmPerfil.AdicionarObservador(Observer: IObservadorUsuario);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

procedure TFrmPerfil.DoEditarCampo(Sender: TObject);
var
  aTag : Integer;
begin
  // Propriedade TAG é usada para armazenar as sequencia dos campos no formulário
  if (Sender is TLabel) then
    aTag := TLabel(Sender).Tag
  else
  if (Sender is TImage) then
    aTag := TImage(Sender).Tag
  else
    aTag := 0;

  layoutEditCampo.Visible  := False;
  layoutMemoCampo.Visible  := False;
  layoutValorCampo.Visible := False;

  Case aTag of
    0 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelDescricao.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        editEditCampo.Text         := IfThen(lblDescricao.TagFloat = 0, EmptyStr, lblDescricao.Text);
        editEditCampo.MaxLength    := 100;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
        editEditCampo.Password     := False;
        editEditCampo.TextPrompt   := 'Informe aqui seu nome completo';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblDescricao);
      end;

    1 :
      begin
        layoutValorCampo.Visible    := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelCpf.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        labelValorCampo.Text      := IfThen(lblCpf.TagFloat = 0, EmptyStr, lblCpf.Text);
        labelValorCampo.TagString := 'cpf/cnpj';           // Flag para formatação do valor
        labelValorCampo.TagObject := TObject(lblCpf);      // Objeto de origem da informação. O dado editado será devolvido para ele.
      end;

    2 :
      begin
        layoutValorCampo.Visible    := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelCelular.Text);
        labelTituloEditar.TagString := EmptyStr;

        labelValorCampo.Text      := IfThen(lblCelular.TagFloat = 0, EmptyStr, lblCelular.Text);
        labelValorCampo.TagString := 'fone';               // Flag para formatação do valor
        labelValorCampo.TagObject := TObject(lblCelular);
      end;

    3 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelEmail.Text);
        labelTituloEditar.TagString := EmptyStr;

        editEditCampo.Text         := IfThen(lblEmail.TagFloat = 0, EmptyStr, lblEmail.Text);
        editEditCampo.MaxLength    := 150;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.EmailAddress;
        editEditCampo.Password     := False;
        editEditCampo.TextPrompt   := 'Informe aqui seu e-mail';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblEmail);
      end;

    4 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelSenha.Text);
        labelTituloEditar.TagString := EmptyStr;

        editEditCampo.Text         := IfThen(lblSenha.TagFloat = 0, EmptyStr, lblSenha.TagString);
        editEditCampo.MaxLength    := 100;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
        editEditCampo.Password     := True;
        editEditCampo.TextPrompt   := 'Informe aqui sua senha';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblSenha);
      end;
  end;

  ChangeTabActionEditar.ExecuteTarget(Sender);
end;

procedure TFrmPerfil.DoSalvarPerfil(Sender: TObject);
begin
  ;
end;

procedure TFrmPerfil.FormActivate(Sender: TObject);
begin
  inherited;
  lytExcluir.Visible := False;
end;

procedure TFrmPerfil.FormatarValorCampo(var aStr: String);
begin
  if (labelValorCampo.TagString = 'cpf/cnpj') then
  begin
    if (Length(aStr) > 11) then
      aStr := FormatarTexto('99.999.999/9999-99;0', aStr)
    else
      aStr := FormatarTexto('999.999.999-99;0', aStr);
  end
  else
  if (labelValorCampo.TagString = 'fone') then
  begin
    if (Length(aStr) > 10) then
      aStr := FormatarTexto('(99) 99999-9999;0', aStr)
    else
      aStr := FormatarTexto('(99) 9999-9999;0', aStr);
  end;

  labelValorCampo.Text := aStr;
end;

procedure TFrmPerfil.FormCreate(Sender: TObject);
begin
  inherited;
  FObservers := TList<IObservadorUsuario>.Create;
end;

class function TFrmPerfil.GetInstance: TFrmPerfil;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmPerfil, aInstance);
    Application.RealCreateForms;
  end;

  if not Assigned(aInstance.FObservers) then
    aInstance.FObservers := TList<IObservadorUsuario>.Create;

  aInstance.aDao := TUsuarioDao.GetInstance;

  Result := aInstance;
end;

procedure TFrmPerfil.Notificar;
var
  Observer : IObservadorUsuario;
begin
  for Observer in FObservers do
     Observer.AtualizarUsuario;
end;

procedure TFrmPerfil.RemoverObservador(Observer: IObservadorUsuario);
begin
  FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmPerfil.RemoverTodosObservadores;
var
  Observer : IObservadorUsuario;
begin
  for Observer in FObservers do
    FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmPerfil.TeclaBackSpace;
var
  aStr : String;
begin
  aStr := Trim(labelValorCampo.Text);
  aStr := aStr.Replace('(', '', [rfReplaceAll]);
  aStr := aStr.Replace(')', '', [rfReplaceAll]);
  aStr := aStr.Replace('.', '', [rfReplaceAll]);
  aStr := aStr.Replace('-', '', [rfReplaceAll]);
  aStr := aStr.Replace('/', '', [rfReplaceAll]);
  aStr := aStr.Replace(' ', '', [rfReplaceAll]);

  if Length(aStr) > 1 then
    aStr := Copy(aStr, 1, Length(aStr) - 1)
  else
    aStr := '';

  FormatarValorCampo(aStr);
end;

procedure TFrmPerfil.TeclaNumero(const aValue: String);
var
  aStr   : String;
  aValor : Currency;
begin
  if (labelValorCampo.TagString = ',0.00') then
    inherited
  else
  begin
    aStr := Trim(labelValorCampo.Text) + Trim(aValue);
    aStr := aStr.Replace('(', '', [rfReplaceAll]);
    aStr := aStr.Replace(')', '', [rfReplaceAll]);
    aStr := aStr.Replace('.', '', [rfReplaceAll]);
    aStr := aStr.Replace('-', '', [rfReplaceAll]);
    aStr := aStr.Replace('/', '', [rfReplaceAll]);
    aStr := aStr.Replace(' ', '', [rfReplaceAll]);

    FormatarValorCampo(aStr);
  end;
end;

end.
