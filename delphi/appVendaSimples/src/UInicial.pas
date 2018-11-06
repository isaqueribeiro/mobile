unit UInicial;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts;

type
  TFrmInicial = class(TForm)
    layoutWizard: TLayout;
    layoutSlide1: TLayout;
    imageWizard1: TImage;
    labelBemVindo: TLabel;
    labelWizard1: TLabel;
    layoutControle: TLayout;
    labelVoltar: TLabel;
    labelProximo: TLabel;
    layoutStep: TLayout;
    layoutSteps: TLayout;
    circleStep1: TCircle;
    circleStep3: TCircle;
    circleStep2: TCircle;
    layoutSlide2: TLayout;
    imageWizard2: TImage;
    labelOnline: TLabel;
    labelWizard2: TLabel;
    layoutSlide3: TLayout;
    imageWizard3: TImage;
    labelTudoPronto: TLabel;
    labelWizard3: TLabel;
    LayoutFundo: TLayout;
    Layout: TLayout;
    imageAppIcon: TImage;
    labelAppName: TLabel;
    labelAppBemVindo: TLabel;
    StyleBookApp: TStyleBook;
    rectangleTenhoCadastro: TRectangle;
    labelTenhoCadastro: TLabel;
    Rectangle1: TRectangle;
    Label1: TLabel;
    procedure DoVoltarSlide(Sender: TObject);
    procedure DoProximoSlide(Sender: TObject);
    procedure DoLogar(Sender: TObject);
    procedure DoNovaConta(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    aSlide : Smallint;
    procedure ExibriSlide(const aIndice : Smallint);
  public
    { Public declarations }
  end;

var
  FrmInicial: TFrmInicial;

implementation

{$R *.fmx}

uses
  UConstantes,
  UDM, ULogin, app.Funcoes, UPrincipal;

{ TFrmInicial }

procedure TFrmInicial.ExibriSlide(const aIndice : Smallint);
begin
  labelVoltar.Visible  := (aIndice > 1);
  layoutSlide1.Visible := (aIndice = 1);
  layoutSlide2.Visible := (aIndice = 2);
  layoutSlide3.Visible := (aIndice = 3);

  circleStep1.Fill.Color := crCinza; // TAlphaColorF.Create(182, 172, 172, 255); // Cinza
  circleStep2.Fill.Color := crCinza; // TAlphaColorF.Create(182, 172, 172, 255);
  circleStep3.Fill.Color := crCinza; // TAlphaColorF.Create(182, 172, 172, 255);

  Case aIndice of
    1 : circleStep1.Fill.Color := crAzul; // TAlphaColorF.Create(30, 135, 175, 255); // Azul
    2 : circleStep2.Fill.Color := crAzul; // TAlphaColorF.Create(30, 135, 175, 255);
    3 : circleStep3.Fill.Color := crAzul; // TAlphaColorF.Create(30, 135, 175, 255);
  end;
end;

procedure TFrmInicial.FormCreate(Sender: TObject);
begin
  aSlide := 1;
  layoutWizard.Visible := True;
  LayoutFundo.Visible  := False;
end;

procedure TFrmInicial.FormShow(Sender: TObject);
begin
  ExibriSlide(1);
end;

procedure TFrmInicial.DoLogar(Sender: TObject);
begin
//  if EfetuarLogin then
//  begin
//    Self.Hide;
//    CriarForm(TFrmPrincipal, FrmPrincipal);
//  end;
  EfetuarLogin;
end;

procedure TFrmInicial.DoNovaConta(Sender: TObject);
begin
  CadastrarNovaConta;
end;

procedure TFrmInicial.DoProximoSlide(Sender: TObject);
begin
  if (aSlide < 3) then
  begin
    aSlide := (aSlide + 1);
    ExibriSlide(aSlide);
  end
  else
  begin
    layoutWizard.Visible := False;
    LayoutFundo.Visible  := True;
  end;
end;

procedure TFrmInicial.DoVoltarSlide(Sender: TObject);
begin
  if (aSlide > 0) then
  begin
    aSlide := (aSlide - 1);
    ExibriSlide(aSlide);
  end;
end;

end.
