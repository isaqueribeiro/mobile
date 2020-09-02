unit Views.Mensagem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Ani;

type
  TViewMensagem = class(TForm)
    RectangleBodyView: TRectangle;
    Layout: TLayout;
    RectangleBodyMessage: TRectangle;
    AnimationShowView: TFloatAnimation;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AnimationShowViewFinish(Sender: TObject);
  strict private
    class var _instance : TViewMensagem;
  private
    { Private declarations }
  public
    { Public declarations }
    class function GetInstance() : TViewMensagem;

    function Informe(aTitulo, aMensagem : String) : TViewMensagem;
  end;

//var
//  ViewMensagem: TViewMensagem;
//
implementation

{$R *.fmx}

{ TViewMensagem }

procedure TViewMensagem.AnimationShowViewFinish(Sender: TObject);
begin
  Layout.AnimateFloat('Opacity', 1, 0.2, TAnimationType.&In, TInterpolationType.Circular);
end;

procedure TViewMensagem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  _instance := nil;
end;

procedure TViewMensagem.FormCreate(Sender: TObject);
begin
  Layout.Opacity := 0;
end;

procedure TViewMensagem.FormShow(Sender: TObject);
begin
  AnimationShowView.Start;
end;

class function TViewMensagem.GetInstance: TViewMensagem;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TViewMensagem, _instance);

  Result := _instance;
end;

function TViewMensagem.Informe(aTitulo, aMensagem: String): TViewMensagem;
begin
  Result := Self;
end;

end.
