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
  FMX.Layouts, FMX.Controls.Presentation, FMX.DateTimeCtrls;

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
    lytCpfCnpj: TLayout;
    lineCpfCnpj: TLine;
    LabelCpfCnpj: TLabel;
    imgCpfCnpj: TImage;
    lblCpfCnpj: TLabel;
    layoutSenhaCampo: TLayout;
    rectangleSenhaCampo: TRectangle;
    editSenhaCampo: TEdit;
    rectangleConfirmeSenhaCampo: TRectangle;
    editConfirmeSenhaCampo: TEdit;
    lytDadosEmpresa: TLayout;
    LabelDadosEmpresa: TLabel;
    lytRazaoSocial: TLayout;
    lineRazaoSocial: TLine;
    LabelRazaoSocial: TLabel;
    imgRazaoSocial: TImage;
    lblRazaoSocial: TLabel;
    lytFantasia: TLayout;
    lineFantasia: TLine;
    LabelFantasia: TLabel;
    imgFantasia: TImage;
    lblFantasia: TLabel;
    lineDadosEmpresa: TLine;
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
    property Dao : TUsuarioDao read aDao;

    procedure TeclaBackSpace; override;
    procedure TeclaNumero(const aValue : String); override;

    function DevolverValorEditado : Boolean; override;

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
  , UMensagem, dao.Loja;

procedure ExibirPerfilUsuario(Observer : IObservadorUsuario);
var
  aForm : TFrmPerfil;
  emp : TLojaDao;
begin
  aForm := TFrmPerfil.GetInstance();
  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    dao.Load(EmptyStr);

    emp := TLojaDao.GetInstance();
    emp.Load(EmptyStr);

    if (Trim(emp.Model.CpfCnpj) = EmptyStr) then
    begin
      emp.Model.CpfCnpj := dao.Model.Cpf;
      dao.Model.Empresa.CpfCnpj := dao.Model.Cpf;
    end
    else
      dao.Model.Empresa := emp.Model;

    tbsControle.ActiveTab := tbsCadastro;

    labelTituloCadastro.Text      := 'MEU PERFIL';
    labelTituloCadastro.TagString := GUIDToString(Model.ID); // Destinado a guardar o ID guid do registro

    lblDescricao.Text  := IfThen(Trim(Model.Nome)    = EmptyStr, 'Informe aqui seu nome completo', Model.Nome);
    lblCelular.Text    := IfThen(Trim(Model.Celular) = EmptyStr, 'Informe aqui o número do seu celular', Model.Celular);
    lblEmail.Text      := IfThen(Trim(Model.Email)   = EmptyStr, 'Informe aqui seu e-mail', Model.Email);
    lblSenha.TagString := EmptyStr; // Model.Senha;

    lblCPFCnpj.Text     := IfThen(Trim(Model.Empresa.CpfCnpj) = EmptyStr, 'Informe aqui o número do CPF/CNPJ', Model.Empresa.CpfCnpj);
    lblRazaoSocial.Text := IfThen(Trim(Model.Empresa.CpfCnpj) = EmptyStr, 'Informe aqui a razão social da empresa', Model.Empresa.Nome);
    lblFantasia.Text    := IfThen(Trim(Model.Empresa.CpfCnpj) = EmptyStr, 'Informe aqui o nome fantasia da empresa', Model.Empresa.Fantasia);

    lblDescricao.TagFloat := IfThen(Trim(Model.Nome)    = EmptyStr, 0, 1); // Flags: 0 - Sem edição; 1 - Dado editado
    lblCPFCnpj.TagFloat   := IfThen(Trim(Model.Cpf)     = EmptyStr, 0, 1);
    lblCelular.TagFloat   := IfThen(Trim(Model.Celular) = EmptyStr, 0, 1);
    lblEmail.TagFloat     := IfThen(Trim(Model.Email)   = EmptyStr, 0, 1);
    lblSenha.TagFloat     := IfThen(Trim(Model.Senha)   = EmptyStr, 0, 1);

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

function TFrmPerfil.DevolverValorEditado: Boolean;
var
  aObj  : TObject;
  aStr  : String;
  aPwd  ,
  aPost : Boolean;
begin
  if not layoutSenhaCampo.Visible then
    Result := inherited
  else
  begin
    aObj := editSenhaCampo.TagObject;
    aStr := Trim(editSenhaCampo.Text);
    aPwd := editSenhaCampo.Password;

    aPost := ((Trim(aStr) <> EmptyStr) and (labelTituloEditar.TagString = '*')) or (labelTituloEditar.TagString = EmptyStr);

    if aPost and (aObj <> nil) then
    begin
      if aObj is TLabel then
      begin
        if aPwd then
          TLabel(aObj).TagString := aStr // Senha na propriedade "TagString"
        else
          TLabel(aObj).Text := aStr;

        TLabel(aObj).TagFloat := 1;
      end
      else
      if aObj is TEdit then
      begin
        if aPwd then
          TEdit(aObj).TagString := aStr  // Senha na propriedade "TagString"
        else
          TEdit(aObj).Text := aStr;

        TEdit(aObj).TagFloat := 1;
      end;
    end;

    if (Trim(aStr) = EmptyStr) and (labelTituloEditar.TagString = '*') then
      ExibirMsgAlerta('Esta informação é obrigatória!')
    else
    if (Trim(aStr) <> Trim(editConfirmeSenhaCampo.Text)) then
      ExibirMsgAlerta('Senha não confere!' + #13 + 'Informe novamente.')
    else
      Result := ( (Trim(aStr) <> EmptyStr) or (aObj <> nil) );
  end;
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
  layoutSenhaCampo.Visible := False;
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
        labelTituloEditar.Text      := AnsiUpperCase(LabelCpfCnpj.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        labelValorCampo.Text      := IfThen(lblCpfCnpj.TagFloat = 0, EmptyStr, lblCpfCnpj.Text);
        labelValorCampo.TagString := 'cpf/cnpj';           // Flag para formatação do valor
        labelValorCampo.TagObject := TObject(lblCpfCnpj);  // Objeto de origem da informação. O dado editado será devolvido para ele.
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
        labelTituloEditar.TagString := '*';                // Campo obrigatório

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
//        layoutEditCampo.Visible     := True;
//        labelTituloEditar.Text      := AnsiUpperCase(LabelSenha.Text);
//        labelTituloEditar.TagString := '*';                // Campo obrigatório
//
//        editEditCampo.Text         := IfThen(lblSenha.TagFloat = 0, EmptyStr, lblSenha.TagString);
//        editEditCampo.MaxLength    := 100;
//        editEditCampo.TextAlign    := TTextAlign.Leading;
//        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
//        editEditCampo.Password     := True;                // Flag informando que o campo é para "senha"
//        editEditCampo.TextPrompt   := 'Informe aqui sua senha';
//        editEditCampo.TagString    := EmptyStr;
//        editEditCampo.TagObject    := TObject(lblSenha);
        layoutSenhaCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelSenha.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        editSenhaCampo.Text       := IfThen(lblSenha.TagFloat = 0, EmptyStr, lblSenha.TagString);
        editSenhaCampo.MaxLength  := 100;
        editSenhaCampo.TagString  := EmptyStr;
        editSenhaCampo.TagObject  := TObject(lblSenha);

        editConfirmeSenhaCampo.Text       := IfThen(lblSenha.TagFloat = 0, EmptyStr, lblSenha.TagString);
        editConfirmeSenhaCampo.MaxLength  := 100;
      end;

    5 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelRazaoSocial.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        editEditCampo.Text         := IfThen(lblRazaoSocial.TagFloat = 0, EmptyStr, lblRazaoSocial.Text);
        editEditCampo.MaxLength    := 250;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
        editEditCampo.Password     := False;
        editEditCampo.TextPrompt   := 'Informe aqui a razão social da empresa';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblRazaoSocial);
      end;

    6 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelFantasia.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        editEditCampo.Text         := IfThen(lblFantasia.TagFloat = 0, EmptyStr, lblFantasia.Text);
        editEditCampo.MaxLength    := 150;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
        editEditCampo.Password     := False;
        editEditCampo.TextPrompt   := 'Informe aqui o nome fantasia da empresa';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblFantasia);
      end;
  end;

  ChangeTabActionEditar.ExecuteTarget(Sender);
end;

procedure TFrmPerfil.DoSalvarPerfil(Sender: TObject);
var
  ins : Boolean;
  inf : Extended;
  emp : TLojaDao;
begin
  try
    inf :=
      lblDescricao.TagFloat   +
      lblCPFCnpj.TagFloat     +
      lblCelular.TagFloat     +
      lblEmail.TagFloat       +
      lblSenha.TagFloat       +
      lblRazaoSocial.TagFloat +
      lblFantasia.TagFloat;

    if (inf = 0) then
      ExibirMsgAlerta('Sem dados informados!')
    else
    if (lblDescricao.TagFloat = 0) or (Trim(lblDescricao.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe seu nome completo!')
    else
    if (lblCPFCnpj.TagFloat = 1) and ((not StrIsCPF(lblCPFCnpj.Text)) and (not StrIsCNPJ(lblCPFCnpj.Text))) then
      ExibirMsgAlerta('Número de CPF/CNPJ inválido!')
    else
    if (lblEmail.TagFloat = 0) or (Trim(lblEmail.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe seu e-mail!')
    else
    if (lblCpfCnpj.TagFloat = 0) or (Trim(lblCpfCnpj.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe o CPF/CNPJ da empresa!')
    else
    if (lblRazaoSocial.TagFloat = 0) or (Trim(lblRazaoSocial.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe a Razão Social da empresa!')
    else
    if (lblFantasia.TagFloat = 0) or (Trim(lblFantasia.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe o Nome Fantasia da empresa!')
    else
    begin
      dao.Model.ID      := StringToGUID(labelTituloCadastro.TagString);
      dao.Model.Nome    := IfThen(lblDescricao.TagFloat = 0, EmptyStr, lblDescricao.Text);
      dao.Model.Celular := IfThen(lblCelular.TagFloat   = 0, EmptyStr, lblCelular.Text);
      dao.Model.Email   := IfThen(lblEmail.TagFloat     = 0, EmptyStr, lblEmail.Text);
      dao.Model.Senha   := IfThen(lblSenha.TagFloat     = 0, EmptyStr, lblSenha.TagString);

      if (lblCpfCnpj.TagFloat = 1) and StrIsCPF(lblCPFCnpj.Text) then
        dao.Model.Cpf := lblCpfCnpj.Text;

      dao.Model.Empresa.Nome     := IfThen(lblRazaoSocial.TagFloat = 0, EmptyStr, lblRazaoSocial.Text);
      dao.Model.Empresa.Fantasia := IfThen(lblFantasia.TagFloat = 0, EmptyStr, lblFantasia.Text);
      dao.Model.Empresa.CpfCnpj  := IfThen(lblCpfCnpj.TagFloat = 0, EmptyStr, lblCpfCnpj.Text);  // Postar dados na classe caso ele tenha sido editado

      ins := (dao.Model.ID = GUID_NULL);

      if ins then
        dao.Insert()
      else
        dao.Update();

      emp := TLojaDao.GetInstance();
      emp.Model := dao.Model.Empresa;

      Self.Notificar;
      Self.Close;
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar salvar o cliente.' + #13 + E.Message);
  end;
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

  aInstance.aDao := TUsuarioDao.GetInstance();

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
