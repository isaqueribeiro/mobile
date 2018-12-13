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
    layoutValorCampo: TLayout;
    labelValorCampo: TLabel;
    lineValorCampo: TLine;
    lytTeclas: TLayout;
    lytTecla8: TLayout;
    lblTecla8: TLabel;
    lytTecla9: TLayout;
    lblTecla9: TLabel;
    lytTecla4: TLayout;
    lblTecla4: TLabel;
    lytTecla5: TLayout;
    lblTecla5: TLabel;
    lytTecla6: TLayout;
    lblTecla6: TLabel;
    lytTecla1: TLayout;
    lblTecla1: TLabel;
    lytTecla2: TLayout;
    lblTecla2: TLabel;
    lytTecla3: TLayout;
    lblTecla3: TLabel;
    lytTecla7: TLayout;
    lblTecla7: TLabel;
    lytTecla00: TLayout;
    lblTecla00: TLabel;
    lytTecla0: TLayout;
    lblTecla0: TLabel;
    lytTeclaBackSpace: TLayout;
    imgTeclaBackSpace: TImage;
    procedure DoTeclaBackSpace(Sender : TObject);
    procedure DoTeclaNumero(Sender : TObject);
    procedure imageVoltarConsultaClick(Sender: TObject);
    procedure imageSalvarEdicaoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure TeclaBackSpace; virtual;
    procedure TeclaNumero(const aValue : String); virtual;

    function DevolverValorEditado : Boolean;
  end;

var
  FrmPadraoEditar: TFrmPadraoEditar;

implementation

{$R *.fmx}

uses
  UMensagem;

function TFrmPadraoEditar.DevolverValorEditado: Boolean;
var
  aObj  : TObject;
  aStr  : String;
  aPost : Boolean;
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
  end
  else
  if layoutValorCampo.Visible then
  begin
    aObj := labelValorCampo.TagObject;
    aStr := Trim(labelValorCampo.Text);

    // Máscara para formatação numérica
    if (Trim(labelValorCampo.TagString) = ',0.00') or (Trim(labelValorCampo.TagString) = ',0') or (Trim(labelValorCampo.TagString) = ',0.##') then
    begin
      aStr := aStr.Replace('.', '', [rfReplaceAll]);
      aStr := FormatFloat(Trim(labelValorCampo.TagString), StrToCurrDef(aStr, 0));
    end;
  end;

  aPost := ((Trim(aStr) <> EmptyStr) and (labelTituloEditar.TagString = '*')) or (labelTituloEditar.TagString = EmptyStr);

  if aPost and (aObj <> nil) then
  begin
    if aObj is TLabel then
    begin
      TLabel(aObj).Text     := aStr;
      TLabel(aObj).TagFloat := 1;
    end
    else
    if aObj is TEdit then
    begin
      TEdit(aObj).Text     := aStr;
      TEdit(aObj).TagFloat := 1;
    end;
  end;

  if (Trim(aStr) = EmptyStr) and (labelTituloEditar.TagString = '*') then
    ExibirMsgAlerta('Esta informação é obrigatória!')
  else
    Result := ( (Trim(aStr) <> EmptyStr) or (aObj <> nil) );
end;

procedure TFrmPadraoEditar.DoTeclaBackSpace(Sender: TObject);
begin
  TeclaBackSpace;
end;

procedure TFrmPadraoEditar.DoTeclaNumero(Sender: TObject);
begin
  TeclaNumero( TLabel(Sender).Text );
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

procedure TFrmPadraoEditar.TeclaBackSpace;
var
  aStr   : String;
  aValor : Currency;
begin
  aStr := Trim(labelValorCampo.Text);
  aStr := aStr.Replace('.', '', [rfReplaceAll]);
  aStr := aStr.Replace(',', '', [rfReplaceAll]);

  if Length(aStr) > 1 then
    aStr := Copy(aStr, 1, Length(aStr) - 1)
  else
    aStr := '0';

  aValor := StrToCurrDef(aStr, 0) / 100;
  labelValorCampo.Text := FormatFloat(labelValorCampo.TagString, aValor);
end;

procedure TFrmPadraoEditar.TeclaNumero(const aValue: String);
var
  aStr   : String;
  aValor : Currency;
begin
  aStr := Trim(labelValorCampo.Text) + Trim(aValue);
  aStr := aStr.Replace('.', '', [rfReplaceAll]);
  aStr := aStr.Replace(',', '', [rfReplaceAll]);

  aValor := StrToCurrDef(aStr, 0) / 100;
  labelValorCampo.Text := FormatFloat(labelValorCampo.TagString, aValor);
end;

end.
