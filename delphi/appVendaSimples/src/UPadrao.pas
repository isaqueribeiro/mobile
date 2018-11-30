unit UPadrao;

interface

uses
  UConstantes,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects, FMX.TabControl, System.Actions, FMX.ActnList,
  FMX.Ani;

type
  TFrmPadrao = class(TForm)
    StyleBook: TStyleBook;
    LayoutFormConsulta: TLayout;
    rectangleTitulo: TRectangle;
    labelTitulo: TLabel;
    imageAdicionar: TImage;
    imageVoltar: TImage;
    LayoutFundo: TLayout;
    RectangleFundo: TRectangle;
    tbsControle: TTabControl;
    tbsConsulta: TTabItem;
    tbsCadastro: TTabItem;
    LayoutBase: TLayout;
    ActionList: TActionList;
    ChangeTabActionConsulta: TChangeTabAction;
    ChangeTabActionCadastro: TChangeTabAction;
    LayoutFormCadastro: TLayout;
    rectangleTituloCadastro: TRectangle;
    labelTituloCadastro: TLabel;
    imageVoltarConsulta: TImage;
    imageSalvarCadastro: TImage;
    FloatAnimationEntrada: TFloatAnimation;
    FloatAnimationSaida: TFloatAnimation;
    procedure FormCreate(Sender: TObject);
    procedure imageVoltarConsultaClick(Sender: TObject);
    procedure imageAdicionarClick(Sender: TObject);
    procedure imageVoltarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ExibirPainelOpacity;
    procedure OcultarPainelOpacity;
  end;

var
  FrmPadrao: TFrmPadrao;

implementation

{$R *.fmx}

procedure TFrmPadrao.ExibirPainelOpacity;
begin
  LayoutFundo.Visible := True;
  LayoutFundo.BringToFront;
end;

procedure TFrmPadrao.OcultarPainelOpacity;
begin
  LayoutFundo.Visible := False;
end;

procedure TFrmPadrao.FormCreate(Sender: TObject);
begin
  RectangleFundo.Opacity  := vlOpacityIcon;
  tbsControle.TabPosition := TTabPosition.None;
  tbsControle.ActiveTab   := tbsConsulta;
  OcultarPainelOpacity;
end;

procedure TFrmPadrao.imageAdicionarClick(Sender: TObject);
begin
  ChangeTabActionCadastro.ExecuteTarget(Sender);
end;

procedure TFrmPadrao.imageVoltarClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmPadrao.imageVoltarConsultaClick(Sender: TObject);
begin
  ChangeTabActionConsulta.ExecuteTarget(Sender);
end;

end.
