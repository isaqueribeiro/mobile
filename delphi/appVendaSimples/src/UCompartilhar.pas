unit UCompartilhar;

interface

uses
  app.Funcoes,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadrao, System.Actions,
  FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmCompartilhar = class(TFrmPadrao)
    layoutOpcoes: TLayout;
    layoutIcones: TLayout;
    imageWhasApp: TImage;
    labelWhasApp: TLabel;
    imageEmail: TImage;
    labelEmail: TLabel;
    labelOpcoes: TLabel;
    procedure imageWhasAppClick(Sender: TObject);
    procedure imageEmailClick(Sender: TObject);
  strict private
    { Private declarations }
    class var aInstance : TFrmCompartilhar;
  public
    { Public declarations }
    class function GetInstance : TFrmCompartilhar;
  end;

  procedure CompartilharApp;

//var
//  FrmCompartilhar: TFrmCompartilhar;

implementation

{$R *.fmx}

uses UMensagem;

procedure CompartilharApp;
var
  aForm : TFrmCompartilhar;
begin
  aForm := TFrmCompartilhar.GetInstance;
  with aForm do
  begin
    tbsControle.ActiveTab := tbsCadastro;
    Show;
  end;
end;

{ TFrmCompartilhar }

class function TFrmCompartilhar.GetInstance: TFrmCompartilhar;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmCompartilhar, aInstance);
    Application.RealCreateForms;
  end;

  Result := aInstance;
end;

procedure TFrmCompartilhar.imageEmailClick(Sender: TObject);
var
  aMsg : String;
begin
  try
    aMsg := 'Recomendo o aplicativo Pedido Simples para você: http://www.pedidesimples.com.br/indique';
    SendEmail('', 'Recomento este App', aMsg);
  except
    On E : Exception do
      ExibirMsgErro(E.Message);
  end;
end;

procedure TFrmCompartilhar.imageWhasAppClick(Sender: TObject);
var
  aMsg : String;
begin
  try
    aMsg := 'Recomendo o aplicativo Pedido Simples para você: http://www.pedidesimples.com.br/indique';
    CallWhasApp('whatsapp://send?text=', aMsg);
  except
    On E : Exception do
      ExibirMsgErro(E.Message);
  end;
end;

end.
