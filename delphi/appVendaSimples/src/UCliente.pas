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
  strict private
    { Private declarations }
    class var aInstance : TFrmCliente;
  public
    { Public declarations }
    class function GetInstance : TFrmCliente;
  end;

  procedure ExibirCadastroCliente;

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

{ TFrmCliente }

class function TFrmCliente.GetInstance: TFrmCliente;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmCliente, aInstance);
    Application.RealCreateForms;
  end;

  Result := aInstance;
end;

end.
