unit ULogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation, FMX.Edit,
  System.Actions, FMX.ActnList, FMX.StdActns;

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
    procedure FormCreate(Sender: TObject);
    procedure EditLoginKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure EditSenhaKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
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
end;

end.
