unit UPadraoEditar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UPadrao, System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.ScrollBox, FMX.Memo, FMX.DateTimeCtrls;

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
    layoutDataCampo: TLayout;
    rectangleDataCampo: TRectangle;
    editDateCampo: TDateEdit;
    procedure DoTeclaBackSpace(Sender : TObject);
    procedure DoTeclaNumero(Sender : TObject);
    procedure imageVoltarConsultaClick(Sender: TObject);
    procedure imageSalvarEdicaoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure TeclaBackSpace; virtual;
    procedure TeclaNumero(const aValue : String); virtual;

    function DevolverValorEditado : Boolean; virtual;
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
  aPwd  ,
  aPost : Boolean;
begin
  aObj := nil;
  aStr := EmptyStr;
  aPwd := False;
  if layoutEditCampo.Visible then
  begin
    aObj := editEditCampo.TagObject;
    aStr := Trim(editEditCampo.Text);
    aPwd := editEditCampo.Password;
    if (Trim(editEditCampo.TagString) <> EmptyStr) then  // M�scara para formata��o num�rica
    begin
      aStr := aStr.Replace('.', '', [rfReplaceAll]);
      aStr := FormatFloat(Trim(editEditCampo.TagString), StrToCurrDef(aStr, 0));
    end;
  end
  else
  if layoutDataCampo.Visible then
  begin
    aObj := editDateCampo.TagObject;
    aStr := FormatDateTime('dd/mm/yyyy', editDateCampo.DateTime);
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

    // M�scara para formata��o num�rica
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
    ExibirMsgAlerta('Esta informa��o � obrigat�ria!')
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

procedure TFrmPadraoEditar.FormCreate(Sender: TObject);
begin
  inherited;
  layoutEditCampo.Visible  := False;
  layoutDataCampo.Visible  := False;
  layoutMemoCampo.Visible  := False;
  layoutValorCampo.Visible := False;
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

  if (Trim(labelValorCampo.TagString) = ',0.00') or (Trim(labelValorCampo.TagString) = ',0.##') then
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

  if (Trim(labelValorCampo.TagString) = ',0.00') or (Trim(labelValorCampo.TagString) = ',0.##') then
    aValor := StrToCurrDef(aStr, 0) / 100;

  labelValorCampo.Text := FormatFloat(labelValorCampo.TagString, aValor);
end;

end.
