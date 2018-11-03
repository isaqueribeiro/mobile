unit UMensagem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

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
    procedure DoOK(Sender: TObject);
    procedure DoFechar(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    aConfirmado : Boolean;
  public
    { Public declarations }
    property Confirmado : Boolean read aConfirmado;
  end;

  procedure ExibirMsgErro(aMensagem : String);
  procedure ExibirMsgAlerta(aMensagem : String);
  procedure ExibirMsgSucesso(aMensagem : String);

  function ExibirMsgConfirmacao(aTitulo, aMensagem : String) : Boolean;

implementation

{$R *.fmx}

uses
  UConstantes;

procedure ExibirMsgErro(aMensagem : String);
var
  aForm : TFrmMensagem;
begin
  Application.CreateForm(TFrmMensagem, aForm);
  Application.RealCreateForms;
  try
    with aForm do
    begin
      LabelTitulo.Text := 'ERRO';
      LabelMsg.Text    := Trim(aMensagem);
      ImageMsg.Bitmap  := ImageMsgErro.Bitmap;

      RectangleOK.Visible     := False;
      RectangleFechar.Visible := True;

      RectangleFechar.Align := TAlignLayout.Center;
      ShowModal;
    end;
  finally
    aForm.DisposeOf;
  end;
end;

procedure ExibirMsgAlerta(aMensagem : String);
var
  aForm : TFrmMensagem;
begin
  Application.CreateForm(TFrmMensagem, aForm);
  Application.RealCreateForms;
  try
    with aForm do
    begin
      LabelTitulo.Text := 'ALERTA!';
      LabelMsg.Text    := Trim(aMensagem);
      ImageMsg.Bitmap  := ImageMsgAlerta.Bitmap;

      RectangleOK.Visible     := False;
      RectangleFechar.Visible := True;

      RectangleFechar.Align := TAlignLayout.Center;
      ShowModal;
    end;
  finally
    aForm.DisposeOf;
  end;
end;

procedure ExibirMsgSucesso(aMensagem : String);
var
  aForm : TFrmMensagem;
begin
  Application.CreateForm(TFrmMensagem, aForm);
  Application.RealCreateForms;
  try
    with aForm do
    begin
      LabelTitulo.Text := 'SUCESSO!';
      LabelMsg.Text    := Trim(aMensagem);
      ImageMsg.Bitmap  := ImageMsgAlerta.Bitmap;

      RectangleOK.Visible     := True;
      RectangleFechar.Visible := False;

      RectangleOK.Align := TAlignLayout.Center;
      ShowModal;
    end;
  finally
    aForm.DisposeOf;
  end;
end;

function ExibirMsgConfirmacao(aTitulo, aMensagem : String) : Boolean;
var
  aForm : TFrmMensagem;
begin
  Application.CreateForm(TFrmMensagem, aForm);
  Application.RealCreateForms;
  try
    with aForm do
    begin
      LabelTitulo.Text := AnsiUpperCase(Trim(aTitulo));
      LabelMsg.Text    := Trim(aMensagem);
      ImageMsg.Bitmap  := ImageMsgAlerta.Bitmap;

      LabelOK.Text     := 'SIM';
      LabelFechar.Text := 'NÃO';

      RectangleOK.Visible     := True;
      RectangleFechar.Visible := True;

      ShowModal;
    end;
  finally
    Result := aForm.Confirmado;
    aForm.DisposeOf;
  end;
end;

procedure TFrmMensagem.DoFechar(Sender: TObject);
begin
  aConfirmado := False;
  Self.Close;
end;

procedure TFrmMensagem.DoOK(Sender: TObject);
begin
  aConfirmado := True;
  Self.Close;
end;

procedure TFrmMensagem.FormCreate(Sender: TObject);
begin
  ImageMsgErro.Visible     := False;
  ImageMsgAlerta.Visible   := False;
  ImageMsgSucesso.Visible  := False;
  ImageMsgPergunta.Visible := False;

  RectangleOK.Visible     := False;
  RectangleFechar.Visible := False;

  aConfirmado := False;
end;

end.
