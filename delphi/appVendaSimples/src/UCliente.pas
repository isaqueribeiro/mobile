unit UCliente;

interface

uses
  System.StrUtils,
  model.Cliente,
  dao.Cliente,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoCadastro,
  System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmCliente = class(TFrmPadraoCadastro)
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

    procedure FormActivate(Sender: TObject);
  strict private
    { Private declarations }
    aDao : TClienteDao;
    procedure FormatarValorCampo(var aStr : String);

    class var aInstance : TFrmCliente;
  public
    { Public declarations }
    property Dao : TClienteDao read aDao;

    procedure TeclaBackSpace; override;
    procedure TeclaNumero(const aValue : String); override;

    class function GetInstance : TFrmCliente;
  end;

  procedure ExibirCadastroCliente;
  procedure NovoCadastroCliente;

//var
//  FrmCliente: TFrmCliente;
//
implementation

{$R *.fmx}

uses app.Funcoes;

procedure ExibirCadastroCliente;
var
  aForm : TFrmCliente;
begin
  aForm := TFrmCliente.GetInstance;
  aForm.Show;
end;

procedure NovoCadastroCliente;
var
  aForm : TFrmCliente;
begin
  aForm := TFrmCliente.GetInstance;

  with aForm do
  begin
    labelTituloCadastro.Text      := 'NOVO CLIENTE';
    labelTituloCadastro.TagString := GUIDToString(GUID_NULL);
    labelTituloCadastro.TagFloat  := 0;

    lblCPF_CNPJ.Text  := 'Informe aqui o número de CPF/CNPJ do novo cliente';
    lblDescricao.Text := 'Informe aqui o nome do novo cliente';
    lblEndereco.Text  := 'Informe aqui o endereço do novo cliente';
    lblTelefone.Text  := 'Informe aqui o númeor de telefone do novo cliente';
    lblEmail.Text     := 'Informe aqui o e-mail do novo cliente';
    lblObs.Text       := 'Insira aqui as observações sobre o cliente';

    lblCPF_CNPJ.TagFloat  := 0;
    lblDescricao.TagFloat := 0;
    lblEndereco.TagFloat  := 0;
    lblTelefone.TagFloat  := 0;
    lblEmail.TagFloat     := 0;
    lblObs.TagFloat       := 0;

    lytExcluir.Visible := False;
  end;

  aForm.Show;
end;

{ TFrmCliente }

procedure TFrmCliente.DoEditarCampo(Sender: TObject);
var
  aTag : Integer;
begin
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
        labelTituloEditar.TagString := '*'; // Campo obrigatório

        labelValorCampo.Text      := IfThen(lblCPF_CNPJ.TagFloat = 0, EmptyStr, lblCPF_CNPJ.Text);
        labelValorCampo.TagString := 'cpf/cnpj';
        labelValorCampo.TagObject := TObject(lblCPF_CNPJ);
      end;

    1 :
      begin
        layoutEditCampo.Visible     := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelDescricao.Text);
        labelTituloEditar.TagString := '*'; // Campo obrigatório

        editEditCampo.Text         := IfThen(lblDescricao.TagFloat = 0, EmptyStr, lblDescricao.Text);
        editEditCampo.MaxLength    := 150;
        editEditCampo.TextAlign    := TTextAlign.Leading;
        editEditCampo.KeyboardType := TVirtualKeyboardType.Default;
        editEditCampo.TextPrompt   := 'Informe aqui o nome completo';
        editEditCampo.TagString    := EmptyStr;
        editEditCampo.TagObject    := TObject(lblDescricao);
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
      end;

    3 :
      begin
        layoutValorCampo.Visible    := True;
        labelTituloEditar.Text      := AnsiUpperCase(LabelTelefone.Text);
        labelTituloEditar.TagString := EmptyStr;

        labelValorCampo.Text      := IfThen(lblTelefone.TagFloat = 0, EmptyStr, lblTelefone.Text);
        labelValorCampo.TagString := 'fone';
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
      end;
  end;

  ChangeTabActionEditar.ExecuteTarget(Sender);
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
      aStr := FormatarTexto('(99)99999-9999;0', aStr)
    else
      aStr := FormatarTexto('(99)9999-9999;0', aStr);
  end;

  labelValorCampo.Text := aStr;
end;

class function TFrmCliente.GetInstance: TFrmCliente;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmCliente, aInstance);
    Application.RealCreateForms;
  end;

  aInstance.aDao := TClienteDao.GetInstance;

  Result := aInstance;
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
