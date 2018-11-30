unit UPadraoEditar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UPadrao, System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.ScrollBox, FMX.Memo;

type
  TFrmPadraoEditar = class(TFrmPadrao)
    tbsEditar: TTabItem;
    LayoutFormEditar: TLayout;
    rectangleTituloEditar: TRectangle;
    labelTituloEditar: TLabel;
    imageVoltarCasdatro: TImage;
    imageSalvarEdicao: TImage;
    layoutEditCampo: TLayout;
    rectangleEditCampo: TRectangle;
    editEditCampo: TEdit;
    layoutMemoCampo: TLayout;
    rectangleMemoCampo: TRectangle;
    mmMemoCampo: TMemo;
    procedure imageVoltarConsultaClick(Sender: TObject);
    procedure imageSalvarEdicaoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function DevolverValorEditado : Boolean;
  end;

var
  FrmPadraoEditar: TFrmPadraoEditar;

implementation

{$R *.fmx}

function TFrmPadraoEditar.DevolverValorEditado: Boolean;
var
  aObj : TObject;
  aStr : String;
begin
  aObj := nil;
  aStr := EmptyStr;
  if layoutEditCampo.Visible then
  begin
    aObj := editEditCampo.TagObject;
    aStr := Trim(editEditCampo.Text);
    if (Trim(editEditCampo.TagString) <> EmptyStr) then  // Máscara para formatação numérica
    begin
      aStr := aStr.Replace('.', '', [rfReplaceAll]);
      aStr := FormatFloat(Trim(editEditCampo.TagString), StrToCurrDef(aStr, 0));
    end;
  end
  else
  if layoutMemoCampo.Visible then
  begin
    aObj := mmMemoCampo.TagObject;
    aStr := Trim(mmMemoCampo.Text);
  end;

  if (aObj <> nil) then
  begin
    if aObj is TLabel then
      TLabel(aObj).Text := aStr
    else
    if aObj is TEdit then
      TEdit(aObj).Text := aStr;
  end;

  Result := ( (Trim(aStr) <> EmptyStr) or (aObj <> nil) );
end;

procedure TFrmPadraoEditar.imageSalvarEdicaoClick(Sender: TObject);
begin
  if DevolverValorEditado then
    ChangeTabActionCadastro.ExecuteTarget(Sender);
end;

procedure TFrmPadraoEditar.imageVoltarConsultaClick(Sender: TObject);
begin
  ChangeTabActionCadastro.ExecuteTarget(Sender);
end;

end.
