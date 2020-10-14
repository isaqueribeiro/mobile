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
    LayoutBtnConfirmar: TLayout;
    LabelConfirmar: TLabel;
    LayoutBtnCancelar: TLayout;
    LabelCancelar: TLabel;
    RectangleConfirmar: TRectangle;
    RectangleCancelar: TRectangle;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AnimationShowViewFinish(Sender: TObject);
    procedure LabelCancelarClick(Sender: TObject);
    procedure LabelConfirmarClick(Sender: TObject);
  strict private
    class var _instance : TViewMensagem;
  private
    { Private declarations }
    FTipo : TTipoMensagem;
    FCallbackProcedureObject : TCallbackProcedureObject;
  public
    { Public declarations }
    class function GetInstance() : IViewMensagem;

    function Tipo(Value : TTipoMensagem) : IViewMensagem;
    function Titulo(Value : String) : IViewMensagem;
    function Mensagem(Value : String) : IViewMensagem;
    function CallbackProcedure(Value : TCallbackProcedureObject) : IViewMensagem;

    procedure &End;
  end;

implementation

uses
  Services.Utils;

{$R *.fmx}

{ TViewMensagem }

function TViewMensagem.CallbackProcedure(Value: TCallbackProcedureObject): IViewMensagem;
begin
  Result := Self;
  FCallbackProcedureObject := Value;
end;

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
  FCallbackProcedureObject := nil;
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

procedure TViewMensagem.LabelCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TViewMensagem.LabelConfirmarClick(Sender: TObject);
begin
  if Assigned(FCallbackProcedureObject) then
    FCallbackProcedureObject(Sender);

  Close;
end;

function TViewMensagem.Mensagem(Value: String): IViewMensagem;
begin
  Result := Self;
  LabelMessage.Text := Value.Trim;
end;

function TViewMensagem.Tipo(Value: TTipoMensagem): IViewMensagem;
begin
  Result := Self;
  FTipo  := Value;

  LayoutBtnConfirmar.Visible := False;
  LayoutBtnCancelar.Visible  := True;

  LayoutBtnConfirmar.Margins.Right := 0;
  LayoutBtnCancelar.Margins.Left   := 0;

  LabelConfirmar.Text  := 'OK';
  LabelCancelar.Text   := 'FECHAR';

  case FTipo of
    TTipoMensagem.tipoMensagemInformacao:
      begin
        LayoutBtnCancelar.Margins.Left := 0;
        TServicesUtils.ResourceImage('icon_message_informe', ImageMessage);
      end;

    TTipoMensagem.tipoMensagemAlerta:
      begin
        TServicesUtils.ResourceImage('icon_message_alert', ImageMessage);
      end;

    TTipoMensagem.tipoMensagemErro:
      begin
        TServicesUtils.ResourceImage('icon_message_error', ImageMessage);
      end;

    TTipoMensagem.tipoMensagemSucesso:
      begin
        TServicesUtils.ResourceImage('icon_message_sucess', ImageMessage);
      end;

    TTipoMensagem.tipoMensagemPergunta:
      begin
        TServicesUtils.ResourceImage('icon_message_question', ImageMessage);
        LayoutBtnConfirmar.Visible     := True;
        LayoutBtnCancelar.Visible      := True;

        LayoutBtnConfirmar.Margins.Right := 140;
        LayoutBtnCancelar.Margins.Left   := 140;

        LabelConfirmar.Text := 'SIM';
        LabelCancelar.Text  := 'NÃO';
      end;
  end;
end;

function TViewMensagem.Titulo(Value: String): IViewMensagem;
begin
  Result := Self;
  LabelTitulo.Text := Value.Trim.ToUpper;
end;

end.
