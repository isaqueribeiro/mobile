unit ULogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation, FMX.Edit,
  System.Math, System.Actions, FMX.ActnList, FMX.StdActns;

type
  TFrmLogin = class(TForm)
    layoutBase: TLayout;
    LayoutLogin: TLayout;
    BtnEfetuarLogin: TButton;
    EditLogin: TEdit;
    EditSenha: TEdit;
    ImageLogoEntidade: TImage;
    LabelLogin: TLabel;
    LabelSenha: TLabel;
    LabelTitleLogin: TLabel;
    LabelVersion: TLabel;
    ToolBarLogin: TToolBar;
    LayoutTopo: TLayout;
    ImageLogoApp: TImage;
    ScrollBoxForm: TScrollBox;
    LayoutForm: TLayout;
    LabelAlerta: TLabel;
    procedure OcultarAlerta(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditLoginKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure EditSenhaKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormFocusChanged(Sender: TObject);
  private
    { Private declarations }
    FWBounds    : TRectF;
    FNeedOffSet : Boolean;
  public
    { Public declarations }
    procedure CalcContentBounds(Sender : TObject; var ContentBounds : TRectF);
    procedure RestorePosition;
    procedure UpdatePosition;
  end;

var
  FrmLogin: TFrmLogin;

implementation

uses
    UDados
  , classes.HttpConnect
  , classes.Constantes;

{$R *.fmx}
{$R *.iPhone55in.fmx IOS}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.NmXhdpiPh.fmx ANDROID}

procedure TFrmLogin.CalcContentBounds(Sender: TObject;
  var ContentBounds: TRectF);
begin
  if (FNeedOffSet and (FWBounds.Top > 0)) then
  begin
    ContentBounds.Bottom := Max(ContentBounds.Bottom, 2 * ClientHeight - FWBounds.Top);
  end;
end;

procedure TFrmLogin.EditLoginKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkReturn) then
    EditSenha.SetFocus;
end;

procedure TFrmLogin.EditSenhaKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkReturn) then
    BtnEfetuarLogin.SetFocus;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  LabelVersion.Text := 'Versão ' + VERSION_NAME;
  ScrollBoxForm.OnCalcContentBounds := CalcContentBounds;
end;

procedure TFrmLogin.FormFocusChanged(Sender: TObject);
begin
  UpdatePosition;
end;

procedure TFrmLogin.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FWBounds.Create(0, 0, 0, 0);
  FNeedOffSet := False;
  RestorePosition;
end;

procedure TFrmLogin.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FWBounds := TRectF.Create(Bounds);
  FWBounds.TopLeft     := ScreenToClient(FWBounds.TopLeft);
  FWBounds.BottomRight := ScreenToClient(FWBounds.BottomRight);
  UpdatePosition;
end;

procedure TFrmLogin.OcultarAlerta(Sender: TObject);
begin
  LabelAlerta.Visible := False;
end;

procedure TFrmLogin.RestorePosition;
begin
  ScrollBoxForm.ViewportPosition := PointF(ScrollBoxForm.ViewportPosition.X, 0);
  LayoutForm.Align := TAlignLayout.Client;
  ScrollBoxForm.RealignContent;
end;

procedure TFrmLogin.UpdatePosition;
var
  LFocused   : TControl;
  LFocusRect : TRectF;
begin
  FNeedOffSet := False;
  if Assigned(Focused) then
  begin
    LFocused   := TControl(Focused.GetObject);
    LFocusRect := LFocused.AbsoluteRect;
    LFocusRect.Offset(ScrollBoxForm.ViewportPosition);

    if (LFocusRect.IntersectsWith(TRectF.Create(FWBounds)) and (LFocusRect.Bottom > FWBounds.Top)) then
    begin
      FNeedOffSet := True;
      LayoutForm.Align := TAlignLayout.Horizontal;
      ScrollBoxForm.RealignContent;
      Application.ProcessMessages;
      ScrollBoxForm.ViewportPosition := PointF(ScrollBoxForm.ViewportPosition.X, LFocusRect.Bottom - FWBounds.Top);
    end;
  end;

  if not FNeedOffSet then
    RestorePosition;
end;

end.
