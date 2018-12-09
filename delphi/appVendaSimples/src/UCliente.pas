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
    procedure FormActivate(Sender: TObject);
  strict private
    { Private declarations }
    aDao : TClienteDao;
    class var aInstance : TFrmCliente;
  public
    { Public declarations }
    property Dao : TClienteDao read aDao;

    class function GetInstance : TFrmCliente;
  end;

  procedure ExibirCadastroCliente;
  procedure NovoCadastroCliente;

//var
//  FrmCliente: TFrmCliente;
//
implementation

{$R *.fmx}

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

    lytExcluir.Visible := False;
  end;

  aForm.Show;
end;

{ TFrmCliente }

procedure TFrmCliente.FormActivate(Sender: TObject);
begin
  inherited;
  lytExcluir.Visible := (Trim(labelTituloCadastro.TagString) <> EmptyStr) and (labelTituloCadastro.TagString <> GUIDToString(GUID_NULL));
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

end.
