unit UPadraoCadastro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, UPadraoEditar, System.Actions,
  FMX.ActnList, FMX.TabControl, FMX.Ani, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmPadraoCadastro = class(TFrmPadraoEditar)
    ScrollBoxCadastro: TScrollBox;
    lytDescricao: TLayout;
    lineDescricao: TLine;
    LabelDescricao: TLabel;
    imgDescricao: TImage;
    lblDescricao: TLabel;
    lytExcluir: TLayout;
    lineExcluir: TLine;
    imgExcluir: TImage;
    lblExcluir: TLabel;
    ChangeTabActionEditar: TChangeTabAction;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPadraoCadastro: TFrmPadraoCadastro;

implementation

{$R *.fmx}

procedure TFrmPadraoCadastro.FormCreate(Sender: TObject);
begin
  inherited;
  tbsControle.ActiveTab       := tbsCadastro;
  imageVoltarConsulta.OnClick := imageVoltarClick;
  lytExcluir.Visible          := False;
  labelValorCampo.TagString   := ',0.00';
end;

end.
