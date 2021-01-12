unit View.Compromissos;

interface

uses
  Classe.ObjetoItemListView,
  Services.ComplexTypes,
  Views.Interfaces.Observers,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.Objects;

type
  TFrmCompromissos = class(TForm)
    ImgSemImage: TImage;
    LayoutTool: TLayout;
    LabelTitulo: TLabel;
    ImageFechar: TImage;
    LayoutMes: TLayout;
    ImageVoltarMes: TImage;
    ImageProximoMes: TImage;
    RectangleMes: TRectangle;
    LabelMes: TLabel;
    LayoutResumo: TLayout;
    RectangleResumo: TRectangle;
    ImageAdicionar: TImage;
    LayoutReceber: TLayout;
    lblValorReceber: TLabel;
    LabelReceber: TLabel;
    LayoutPagar: TLayout;
    lblValorPagar: TLabel;
    LabelPagar: TLabel;
    LayoutSaldo: TLayout;
    lblValorSaldo: TLabel;
    LabelSaldo: TLabel;
    LayoutBody: TLayout;
    LayoutCalendar: TLayout;
    procedure DefinirMesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImageFecharClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  strict private
    class var _instance : TFrmCompromissos;
  private
    { Private declarations }
    FTipo : TTipoCompromisso;
    FDataFiltro : TDateTime;
    FRecarregar : Boolean;

    procedure CarregarCompromissos(aLimparLista : Boolean);
    procedure InicializarComponentes;
  public
    { Public declarations }
    class function GetInstance(const ATipo : TTipoCompromisso) : TFrmCompromissos;
    class function Instanciado : Boolean;
  end;

implementation

uses
    DataModule.Recursos
  , Services.Utils
  , System.DateUtils
  , Services.MessageDialog;

{$R *.fmx}

{ TFrmCompromissos }

procedure TFrmCompromissos.CarregarCompromissos(aLimparLista: Boolean);
begin
  ;
end;

procedure TFrmCompromissos.DefinirMesClick(Sender: TObject);
var
  aIncremento : Integer;
begin
  aIncremento   := TFmxObject(Sender).Tag;
  FDataFiltro   := IncMonth(FDataFiltro, aIncremento);
  LabelMes.Text := TServicesUtils.MonthName(FDataFiltro).ToUpper + '/' + YearOf(FDataFiltro).ToString;

  CarregarCompromissos(True);
end;

procedure TFrmCompromissos.FormActivate(Sender: TObject);
begin
  InicializarComponentes;
end;

procedure TFrmCompromissos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FRecarregar := True;
end;

procedure TFrmCompromissos.FormCreate(Sender: TObject);
begin
  ImgSemImage.Visible := False;
  FDataFiltro := Date;
  FRecarregar := True;
end;

procedure TFrmCompromissos.FormShow(Sender: TObject);
begin
  if FRecarregar then
    DefinirMesClick(Self);
end;

class function TFrmCompromissos.GetInstance(const ATipo: TTipoCompromisso): TFrmCompromissos;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmCompromissos, _instance);

  _instance.FTipo := ATipo;
  Result := _instance;
end;

procedure TFrmCompromissos.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmCompromissos.InicializarComponentes;
begin
  case FTipo of
    TTipoCompromisso.tipoCompromissoAReceber : LabelTitulo.Text := 'Contas A Receber';
    TTipoCompromisso.tipoCompromissoAPagar   : LabelTitulo.Text := 'Contas A Pagar';
  end;

  LayoutReceber.Visible := (FTipo = TTipoCompromisso.tipoCompromissoAReceber);
  LayoutPagar.Visible   := (FTipo = TTipoCompromisso.tipoCompromissoAPagar);
  LayoutSaldo.Visible   := False;

  if LayoutReceber.Visible and (not LayoutSaldo.Visible) then
    LayoutReceber.Margins.Right := 10
  else
    LayoutReceber.Margins.Right := 0;

  if LayoutPagar.Visible and (not LayoutSaldo.Visible) then
    LayoutPagar.Margins.Right := 10
  else
    LayoutPagar.Margins.Right := 0;
end;

class function TFrmCompromissos.Instanciado: Boolean;
begin
  Result := Assigned(_instance);
end;

end.
