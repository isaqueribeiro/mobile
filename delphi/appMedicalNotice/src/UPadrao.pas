unit UPadrao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TFrmPadrao = class(TForm)
    layoutBase: TLayout;
    ScrollBoxForm: TScrollBox;
    LayoutForm: TLayout;
    ToolBar: TToolBar;
    BtnVoltar: TSpeedButton;
    BtnConfirmar: TSpeedButton;
    LabelTitle: TLabel;
    procedure BtnVoltarClick(Sender: TObject);
    procedure BtnConfirmarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure VoltarMenuPrincipal; virtual;
    function Confirmar : Boolean; virtual;
  end;

var
  FrmPadrao: TFrmPadrao;

implementation

uses
    UDados
  , USplash
  , app.Funcoes
  , classes.Constantes;

{$R *.fmx}
{$R *.iPhone55in.fmx IOS}

{ TFrmPadrao }

procedure TFrmPadrao.BtnConfirmarClick(Sender: TObject);
begin
  Confirmar;
end;

procedure TFrmPadrao.BtnVoltarClick(Sender: TObject);
begin
  VoltarMenuPrincipal;
end;

function TFrmPadrao.Confirmar: Boolean;
begin
  Result := False;
end;

procedure TFrmPadrao.VoltarMenuPrincipal;
begin
  ;
end;

end.
