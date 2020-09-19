unit Views.Mensagem;

interface

uses
  Views.Interfaces.Mensagem,
  Services.ComplexTypes,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Ani;

type
  TViewMensagem = class(TForm, IViewMensagem)
    RectangleBodyView: TRectangle;
    Layout: TLayout;
    RectangleBodyMessage: TRectangle;
    AnimationShowView: TFloatAnimation;
    AnimationShowMessage: TFloatAnimation;
    LabelTitulo: TLabel;
    LayoutBotoes: TLayout;
    ImageMessage: TImage;
    LabelMessage: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AnimationShowViewFinish(Sender: TObject);
  strict private
    class var _instance : TViewMensagem;
  private
    { Private declarations }
    FTipo : TTipoMensagem;
  public
    { Public declarations }
    class function GetInstance() : IViewMensagem;

    function Titulo(Value : String) : IViewMensagem;
    function Mensagem(Value : String) : IViewMensagem;
    function Tipo(Value : TTipoMensagem) : IViewMensagem;

    procedure &End;
  end;

implementation

{$R *.fmx}

{ TViewMensagem }

procedure TViewMensagem.&End;
begin
  Self.Show;
end;

procedure TViewMensagem.AnimationShowViewFinish(Sender: TObject);
begin
  AnimationShowMessage.Start;
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

class function TViewMensagem.GetInstance: IViewMensagem;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TViewMensagem, _instance);

  Result := _instance;
end;

function TViewMensagem.Mensagem(Value: String): IViewMensagem;
begin
  Result := Self;
  LabelMessage.Text := Value.Trim.ToUpper;
end;

function TViewMensagem.Tipo(Value: TTipoMensagem): IViewMensagem;
begin
  Result := Self;
  FTipo  := Value;
end;

function TViewMensagem.Titulo(Value: String): IViewMensagem;
begin
  Result := Self;
  LabelTitulo.Text := Value.Trim.ToUpper;
end;

end.
