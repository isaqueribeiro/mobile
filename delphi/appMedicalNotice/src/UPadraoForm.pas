unit UPadraoForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TFrmPadraoForm = class(TForm)
    layoutBase: TLayout;
    ScrollBoxForm: TScrollBox;
    LayoutForm: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean;
      const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean;
      const Bounds: TRect);
  private
    { Private declarations }
    FWBounds        : TRectF;
    FNeedOffSet     ,
    FActivateLoaded : Boolean;
  public
    { Public declarations }
    procedure CalcContentBounds(Sender : TObject; var ContentBounds : TRectF);
    procedure RestorePosition;
    procedure UpdatePosition;

    procedure VoltarMenuPrincipal; virtual;
    function Confirmar : Boolean; virtual;
  end;

var
  FrmPadraoForm: TFrmPadraoForm;

implementation

uses
    UDados
  , USplash
  , app.Funcoes
  , classes.Constantes;

{ TFrmPadrao }

procedure TFrmPadraoForm.CalcContentBounds(Sender: TObject; var ContentBounds: TRectF);
begin
  if (FNeedOffSet and (FWBounds.Top > 0)) then
    ContentBounds.Bottom := Max(ContentBounds.Bottom, 2 * ClientHeight - FWBounds.Top);
end;

function TFrmPadraoForm.Confirmar: Boolean;
begin
  Result := False;
end;

procedure TFrmPadraoForm.FormCreate(Sender: TObject);
begin
  ScrollBoxForm.OnCalcContentBounds := CalcContentBounds;
end;

procedure TFrmPadraoForm.FormFocusChanged(Sender: TObject);
begin
  UpdatePosition;
end;

procedure TFrmPadraoForm.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean;
  const Bounds: TRect);
begin
  FWBounds.Create(0, 0, 0, 0);
  FNeedOffSet := False;
  RestorePosition;
end;

procedure TFrmPadraoForm.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean;
  const Bounds: TRect);
begin
  FWBounds := TRectF.Create(Bounds);
  FWBounds.TopLeft     := ScreenToClient(FWBounds.TopLeft);
  FWBounds.BottomRight := ScreenToClient(FWBounds.BottomRight);
  UpdatePosition;
end;

procedure TFrmPadraoForm.RestorePosition;
begin
  ScrollBoxForm.ViewportPosition := PointF(ScrollBoxForm.ViewportPosition.X, 0);
  LayoutForm.Align := TAlignLayout.Client;
  ScrollBoxForm.RealignContent;
end;

procedure TFrmPadraoForm.UpdatePosition;
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

procedure TFrmPadraoForm.VoltarMenuPrincipal;
begin
  ;
end;

end.
