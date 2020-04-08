unit USincronizar;

interface

uses
  app.Funcoes,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadrao, System.Actions, FMX.ActnList,
  FMX.TabControl, FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmSincronizar = class(TFrmPadrao)
    layoutDados: TLayout;
    layoutCliente: TLayout;
    layoutClienteIcone: TLayout;
    imageCliente: TImage;
    labelCliente: TLabel;
    layoutClienteBarra: TLayout;
    recBarraClienteCinza: TRoundRect;
    recBarraClienteAzul: TRoundRect;
    layoutSincronizar: TLayout;
    rectangleSincronizar: TRectangle;
    labelSincronizar: TLabel;
    procedure FormCreate(Sender: TObject);
  strict private
    { Private declarations }
    class var aInstance : TFrmSincronizar;
  public
    { Public declarations }
    class function GetInstance : TFrmSincronizar;
  end;

  procedure SincronizarDados;

//var
//  FrmSincronizar: TFrmSincronizar;

implementation

{$R *.fmx}

uses
  UConstantes,
  UMensagem;

procedure SincronizarDados;
var
  aForm : TFrmSincronizar;
begin
  aForm := TFrmSincronizar.GetInstance;
  with aForm do
  begin
    tbsControle.ActiveTab := tbsCadastro;
    Show;
  end;
end;

{ TFrmSincronizar }

procedure TFrmSincronizar.FormCreate(Sender: TObject);
begin
  inherited;
  imageCliente.Opacity := (1.0 - vlOpacityIcon);

  recBarraClienteCinza.Fill.Color :=  crCinzaClaro;
  recBarraClienteAzul.Fill.Color  :=  crAzul;

  recBarraClienteAzul.Width   := 1;
  recBarraClienteAzul.Visible := False;
end;

class function TFrmSincronizar.GetInstance: TFrmSincronizar;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmSincronizar, aInstance);
    Application.RealCreateForms;
  end;

  Result := aInstance;
end;

end.
