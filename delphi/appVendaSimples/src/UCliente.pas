unit UCliente;

interface

uses
  System.StrUtils,
  System.Math,
  System.Generics.Collections,
  model.Cliente,
  dao.Cliente,
  interfaces.Cliente,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmCliente = class(TFrmPadraoCadastro, IClienteObservado)
    LayoutCPF_CNPJ: TLayout;
    LineCPF_CNPJ: TLine;
    LabelCPF_CNPJ: TLabel;
    imgCPF_CNPJ: TImage;
    lblCPF_CNPJ: TLabel;
    lytEndereco: TLayout;
    LineEndereco: TLine;
    LabelEndereco: TLabel;
    imgEndereco: TImage;
    lblEndereco: TLabel;
    lytTelefone: TLayout;
    LineTelefone: TLine;
    LabelTelefone: TLabel;
    imgTelefone: TImage;
    lblTelefone: TLabel;
    lytEmail: TLayout;
    LineEmail: TLine;
    LabelEmail: TLabel;
    imgEmail: TImage;
    lblEmail: TLabel;
    lytObs: TLayout;
    LineObs: TLine;
    LabelObs: TLabel;
    imgObs: TImage;
    lblObs: TLabel;
    procedure DoEditarCampo(Sender: TObject);
    procedure DoSalvarCliente(Sender: TObject);
    procedure DoExcluirCliente(Sender : TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  strict private
    { Private declarations }
    aDao : TClienteDao;
    FObservers : TList<IObservadorCliente>;
    procedure FormatarValorCampo(var aStr : String);
    procedure ExcluirCliente(Sender: TObject);

    class var aInstance : TFrmCliente;
  public
    { Public declarations }
    property Dao : TClienteDao read aDao;

    procedure TeclaBackSpace; override;
    procedure TeclaNumero(const aValue : String); override;

    procedure AdicionarObservador(Observer : IObservadorCliente);
    procedure RemoverObservador(Observer : IObservadorCliente);
    procedure RemoverTodosObservadores;
    procedure Notificar;

    class function GetInstance : TFrmCliente;
  end;

  procedure NovoCadastroCliente(Observer : IObservadorCliente);
  procedure ExibirCadastroCliente(Observer : IObservadorCliente);

//var
//  FrmCliente: TFrmCliente;
//
implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UMensagem;

procedure NovoCadastroCliente(Observer : IObservadorCliente);
var
  aForm : TFrmCliente;
begin
  aForm := TFrmCliente.GetInstance;
  aForm.AdicionarObservador(Observer);

  with aForm do
  begin
    tbsControle.ActiveTab := tbsCadastro;

    labelTituloCadastro.Text      := 'NOVO CLIENTE';
    labelTituloCadastro.TagString := GUIDToString(GUID_NULL); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := 0;                       // Destinado a guardar o CODIGO numérico do registro

    lblCPF_CNPJ.Text  := 'Informe aqui o número de CPF/CNPJ do novo cliente';
    lblDescricao.Text := 'Informe aqui o nome do novo cliente';
    lblEndereco.Text  := 'Informe aqui o endereço do novo cliente';
    lblTelefone.Text  := 'Informe aqui o númeor de telefone do novo cliente';
    lblEmail.Text     := 'Informe aqui o e-mail do novo cliente';
    lblObs.Text       := 'Insira aqui as observações sobre o cliente';

    lblCPF_CNPJ.TagFloat  := 0; // Flags: 0 - Sem edição; 1 - Dado editado
    lblDescricao.TagFloat := 0;
    lblEndereco.TagFloat  := 0;
    lblTelefone.TagFloat  := 0;
    lblEmail.TagFloat     := 0;
    lblObs.TagFloat       := 0;

    lytExcluir.Visible := False;
  end;

  aForm.Show;
end;

procedure ExibirCadastroCliente(Observer : IObservadorCliente);
var
  aForm : TFrmCliente;
begin
  aForm := TFrmCliente.GetInstance;
  aForm.AdicionarObservador(Observer);

  with aForm, dao do
  begin
    tbsControle.ActiveTab := tbsCadastro;

    labelTituloCadastro.Text      := 'CADASTRO CLIENTE';
    labelTituloCadastro.TagString := GUIDToString(Model.ID); // Destinado a guardar o ID guid do registro
    labelTituloCadastro.TagFloat  := Model.Codigo;           // Destinado a guardar o CODIGO numérico do registro

    lblCPF_CNPJ.Text  := Model.CpfCnpj;
    lblDescricao.Text := Model.Nome;
    lblEndereco.Text  := Model.Endereco;
    lblTelefone.Text  := Model.Telefone;
    lblEmail.Text     := Model.Email;
    lblObs.Text       := Model.Observacao;

    lblCPF_CNPJ.TagFloat  := IfThen(Trim(Model.CpfCnpj)    = EmptyStr, 0, 1); // Flags: 0 - Sem edição; 1 - Dado editado
    lblDescricao.TagFloat := IfThen(Trim(Model.Nome)       = EmptyStr, 0, 1);
    lblEndereco.TagFloat  := IfThen(Trim(Model.Endereco)   = EmptyStr, 0, 1);
    lblTelefone.TagFloat  := IfThen(Trim(Model.Telefone)   = EmptyStr, 0, 1);
    lblEmail.TagFloat     := IfThen(Trim(Model.Email)      = EmptyStr, 0, 1);
    lblObs.TagFloat       := IfThen(Trim(Model.Observacao) = EmptyStr, 0, 1);

    lytExcluir.Visible := True;
  end;

  aForm.Show;
end;

{ TFrmCliente }

procedure TFrmCliente.AdicionarObservador(Observer: IObservadorCliente);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

procedure TFrmCliente.DoEditarCampo(Sender: TObject);
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
        layoutValorCampo.Visible    := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelCPF_CNPJ.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        labelValorCampo.Text      := IfThen(lblCPF_CNPJ.TagFloat = 0, EmptyStr, lblCPF_CNPJ.Text);
        labelValorCampo.TagString := 'cpf/cnpj';           // Flag para formatação do valor
        labelValorCampo.TagObject := TObject(lblCPF_CNPJ); // Objeto de origem da informação. O dado editado será devolvido para ele.
      end;

    1 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelDescricao.Text);
        labelTituloEditar.TagString := '*';                // Campo obrigatório

        editEditCampo.Text         := IfThen(lblDescricao.TagFloat = 0, EmptyStr, lblDescricao.Text);
        editEditCampo.MaxLength    := 150;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
        editEditCampo.TextPrompt   := 'Informe aqui o nome completo';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblDescricao);
//
//        editEditCampo.SetFocus;
//        editEditCampo.SelStart := Length(editEditCampo.Text);
      end;

    2 :
      begin
        layoutMemoCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelEndereco.Text);
        labelTituloEditar.TagString := EmptyStr;

        mmMemoCampo.Text         := IfThen(lblEndereco.TagFloat = 0, EmptyStr, lblEndereco.Text);
        mmMemoCampo.MaxLength    := 500;
        mmMemoCampo.TextAlign    := TTextAlign.Leading;
        mmMemoCampo.KeyboardType := TVirtualKeyboardType.Default;
        mmMemoCampo.TagString    := EmptyStr;
        mmMemoCampo.TagObject    := TObject(lblEndereco);
//
//        mmMemoCampo.SetFocus;
//        mmMemoCampo.SelStart := Length(mmMemoCampo.Text);
      end;

    3 :
      begin
        layoutValorCampo.Visible    := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelTelefone.Text);
        labelTituloEditar.TagString := EmptyStr;

        labelValorCampo.Text      := IfThen(lblTelefone.TagFloat = 0, EmptyStr, lblTelefone.Text);
        labelValorCampo.TagString := 'fone';               // Flag para formatação do valor
        labelValorCampo.TagObject := TObject(lblTelefone);
      end;

    4 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelEmail.Text);
        labelTituloEditar.TagString := EmptyStr;

        editEditCampo.Text         := IfThen(lblEmail.TagFloat = 0, EmptyStr, lblEmail.Text);
        editEditCampo.MaxLength    := 150;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.EmailAddress;
        editEditCampo.TextPrompt   := 'Informe aqui o e-mail';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblEmail);
//
//        editEditCampo.SetFocus;
//        editEditCampo.SelStart := Length(editEditCampo.Text);
      end;

    5 :
      begin
        layoutMemoCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelObs.Text);
        labelTituloEditar.TagString := EmptyStr;

        mmMemoCampo.Text         := IfThen(lblObs.TagFloat = 0, EmptyStr, lblObs.Text);
        mmMemoCampo.MaxLength    := 500;
        mmMemoCampo.TextAlign    := TTextAlign.Leading;
        mmMemoCampo.KeyboardType := TVirtualKeyboardType.Default;
        mmMemoCampo.TagString    := EmptyStr;
        mmMemoCampo.TagObject    := TObject(lblObs);
//
//        mmMemoCampo.SetFocus;
//        mmMemoCampo.SelStart := Length(mmMemoCampo.Text);
      end;
  end;

  ChangeTabActionEditar.ExecuteTarget(Sender);
end;

procedure TFrmCliente.DoExcluirCliente(Sender: TObject);
begin
  ExibirMsgConfirmacao('Excluir', 'Deseja excluir o cliente selecionado?', ExcluirCliente);
end;

procedure TFrmCliente.DoSalvarCliente(Sender: TObject);
var
  ins : Boolean;
  inf : Extended;
begin
  try
    inf :=
      lblCPF_CNPJ.TagFloat  +
      lblDescricao.TagFloat +
      lblEndereco.TagFloat  +
      lblTelefone.TagFloat  +
      lblEmail.TagFloat     +
      lblObs.TagFloat;

    if (inf = 0) then
      ExibirMsgAlerta('Sem dados informados!')
    else
    if (lblCPF_CNPJ.TagFloat = 0) or (Trim(lblCPF_CNPJ.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe o número de CPF/CNPJ!')
    else
    if (lblDescricao.TagFloat = 0) or (Trim(lblDescricao.Text) = EmptyStr) then
      ExibirMsgAlerta('Informe o nome completo!')
    else
    if (not StrIsCPF(lblCPF_CNPJ.Text)) and (not StrIsCNPJ(lblCPF_CNPJ.Text)) then
      ExibirMsgAlerta('Número de CPF/CNPJ inválido!')
    else
    begin
      dao.Model.ID        := StringToGUID(labelTituloCadastro.TagString);
      dao.Model.Codigo    := labelTituloCadastro.TagFloat;

      if StrIsCNPJ(lblCPF_CNPJ.Text) then
        dao.Model.Tipo := TTipoCliente.tcPessoaJuridica
      else
        dao.Model.Tipo := TTipoCliente.tcPessoaFisica;

      dao.Model.CpfCnpj    := IfThen(lblCPF_CNPJ.TagFloat  = 0, EmptyStr, lblCPF_CNPJ.Text);  // Postar dados na classe caso ele tenha sido editado
      dao.Model.Nome       := IfThen(lblDescricao.TagFloat = 0, EmptyStr, lblDescricao.Text);
      dao.Model.Endereco   := IfThen(lblEndereco.TagFloat  = 0, EmptyStr, lblEndereco.Text);
      dao.Model.Telefone   := IfThen(lblTelefone.TagFloat  = 0, EmptyStr, lblTelefone.Text);
      dao.Model.Email      := IfThen(lblEmail.TagFloat     = 0, EmptyStr, lblEmail.Text);
      dao.Model.Observacao := IfThen(lblObs.TagFloat       = 0, EmptyStr, lblObs.Text);

      ins := (dao.Model.ID = GUID_NULL);

      if ins then
        dao.Insert()
      else
        dao.Update();

      Self.Notificar;
      Self.Close;
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar salvar o cliente.' + #13 + E.Message);
  end;
end;

procedure TFrmCliente.ExcluirCliente(Sender: TObject);
var
  msg : TFrmMensagem;
begin
  try
    msg := TFrmMensagem.GetInstance;
    if Assigned(dao.Model) then
    begin
      msg.Close;
      if dao.PodeExcluir then
      begin
        dao.Delete();

        Self.Notificar;
        Self.Close;
      end
      else
        ExibirMsgAlerta('Cliente não pode ser excluído por está sendo usado em pedidos');
    end;
  except
    On E : Exception do
      ExibirMsgErro('Erro ao tentar excluir o cliente.' + #13 + E.Message);
  end;
end;

procedure TFrmCliente.FormActivate(Sender: TObject);
begin
  inherited;
  lytExcluir.Visible := (Trim(labelTituloCadastro.TagString) <> EmptyStr) and (labelTituloCadastro.TagString <> GUIDToString(GUID_NULL));
end;

procedure TFrmCliente.FormatarValorCampo(var aStr : String);
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

procedure TFrmCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  RemoverTodosObservadores;
end;

procedure TFrmCliente.FormCreate(Sender: TObject);
begin
  inherited;
  FObservers := TList<IObservadorCliente>.Create;
end;

class function TFrmCliente.GetInstance: TFrmCliente;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmCliente, aInstance);
    Application.RealCreateForms;
  end;

  if not Assigned(aInstance.FObservers) then
    aInstance.FObservers := TList<IObservadorCliente>.Create;

  aInstance.aDao := TClienteDao.GetInstance;

  Result := aInstance;
end;

procedure TFrmCliente.Notificar;
var
  Observer : IObservadorCliente;
begin
  for Observer in FObservers do
     Observer.AtualizarCliente;
end;

procedure TFrmCliente.RemoverObservador(Observer: IObservadorCliente);
begin
  FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmCliente.RemoverTodosObservadores;
var
  I : Integer;
//var
//  Observer : IObservadorCliente;
begin
  for I := 0 to (FObservers.Count - 1) do
    FObservers.Delete(I);
//  for Observer in FObservers do
//    FObservers.Delete(FObservers.IndexOf(Observer));
end;

procedure TFrmCliente.TeclaBackSpace;
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

procedure TFrmCliente.TeclaNumero(const aValue: String);
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
