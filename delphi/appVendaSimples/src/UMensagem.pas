unit UMensagem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Ani;

type
  TFrmMensagem = class(TForm)
    StyleBookApp: TStyleBook;
    RectangleFundo: TRectangle;
    ImageMsgErro: TImage;
    ImageMsgAlerta: TImage;
    ImageMsgSucesso: TImage;
    ImageMsgPergunta: TImage;
    RectangleMensagem: TRectangle;
    LabelTitulo: TLabel;
    LabelMsg: TLabel;
    ImageMsg: TImage;
    LayoutBotoes: TLayout;
    RectangleOK: TRectangle;
    LabelOK: TLabel;
    RectangleFechar: TRectangle;
    LabelFechar: TLabel;
    LayoutRodape: TLayout;
    floatAnimeEntrada: TFloatAnimation;
    procedure DoOK(Sender: TObject);
    procedure DoFechar(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  strict private
    class var aInstance : TFrmMensagem;
  private
    { Private declarations }
    aConfirmado : Boolean;
  public
    { Public declarations }
    property Confirmado : Boolean read aConfirmado;

    class function GetInstance : TFrmMensagem;
  end;

  procedure ExibirMsgErro(aMensagem : String);
  procedure ExibirMsgAlerta(aMensagem : String);
  procedure ExibirMsgSucesso(aMensagem : String);
  procedure ExibirMsgConfirmacao(aTitulo, aMensagem : String; aEvento : TNotifyEvent);

implementation

{$R *.fmx}

uses
  UConstantes;

procedure ExibirMsgErro(aMensagem : String);
var
  aForm : TFrmMensagem;
begin
  aForm := TFrmMensagem.GetInstance;
  try
    with aForm do
    begin
      RectangleMensagem.Visible := False;

      LabelTitulo.Text := 'ERRO';
      LabelMsg.Text    := Trim(aMensagem);
      ImageMsg.Bitmap  := ImageMsgErro.Bitmap;

      LabelOK.Text     := 'OK';
      LabelFechar.Text := 'FECHAR';

      RectangleOK.Visible     := False;
      RectangleFechar.Visible := True;

      RectangleFechar.Align := TAlignLayout.Center;
      Show;
    end;
  finally
  end;
end;

procedure ExibirMsgAlerta(aMensagem : String);
var
  aForm : TFrmMensagem;
begin
  aForm := TFrmMensagem.GetInstance;
  try
    with aForm do
    begin
      RectangleMensagem.Visible := False;

      LabelTitulo.Text := 'ALERTA!';
      LabelMsg.Text    := Trim(aMensagem);
      ImageMsg.Bitmap  := ImageMsgAlerta.Bitmap;

      LabelOK.Text     := 'OK';
      LabelFechar.Text := 'FECHAR';

      RectangleOK.Visible     := False;
      RectangleFechar.Visible := True;

      RectangleFechar.Align := TAlignLayout.Center;
      Show;
    end;
  finally
  end;
end;

procedure ExibirMsgSucesso(aMensagem : String);
var
  aForm : TFrmMensagem;
begin
  aForm := TFrmMensagem.GetInstance;
  try
    with aForm do
    begin
      RectangleMensagem.Visible := False;

      LabelTitulo.Text := 'SUCESSO!';
      LabelMsg.Text    := Trim(aMensagem);
      ImageMsg.Bitmap  := ImageMsgSucesso.Bitmap;

      LabelOK.Text     := 'OK';
      LabelFechar.Text := 'FECHAR';

      RectangleOK.Visible     := True;
      RectangleFechar.Visible := False;

      LabelOK.OnClick := DoOK;

      RectangleOK.Align := TAlignLayout.Center;
      Show;
    end;
  finally
  end;
end;

procedure ExibirMsgConfirmacao(aTitulo, aMensagem : String; aEvento : TNotifyEvent);
var
  aForm : TFrmMensagem;
begin
  aForm := TFrmMensagem.GetInstance;
  try
    with aForm do
    begin
      RectangleMensagem.Visible := False;

      LabelTitulo.Text := AnsiUpperCase(Trim(aTitulo));
      LabelMsg.Text    := Trim(aMensagem);
      ImageMsg.Bitmap  := ImageMsgPergunta.Bitmap;

      LabelOK.Text     := 'SIM';
      LabelFechar.Text := 'NÃO';

      RectangleOK.Visible     := True;
      RectangleFechar.Visible := True;

      LabelOK.OnClick  := aEvento;

      RectangleOK.Align     := TAlignLayout.Left;
      RectangleFechar.Align := TAlignLayout.Right;

      Show;
    end;
  finally
  end;
end;

procedure TFrmMensagem.DoFechar(Sender: TObject);
begin
  RectangleMensagem.Visible := False;
  aConfirmado := False;
  Self.Close;
end;

procedure TFrmMensagem.DoOK(Sender: TObject);
begin
  RectangleMensagem.Visible := False;
  aConfirmado := True;
  Self.Close;
end;

procedure TFrmMensagem.FormActivate(Sender: TObject);
begin
  RectangleMensagem.Visible := True;
end;

procedure TFrmMensagem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RectangleOK.Visible     := False;
  RectangleFechar.Visible := False;
end;

procedure TFrmMensagem.FormCreate(Sender: TObject);
begin
  RectangleMensagem.Visible := False;

  ImageMsgErro.Visible     := False;
  ImageMsgAlerta.Visible   := False;
  ImageMsgSucesso.Visible  := False;
  ImageMsgPergunta.Visible := False;

  RectangleOK.Visible     := False;
  RectangleFechar.Visible := False;

  aConfirmado := False;
end;

class function TFrmMensagem.GetInstance: TFrmMensagem;
begin
  if not Assigned(aInstance) then
  begin
    Application.CreateForm(TFrmMensagem, aInstance);
    Application.RealCreateForms;
  end;

  aInstance.RectangleMensagem.Visible := False;

  Result := aInstance;
end;

end.
