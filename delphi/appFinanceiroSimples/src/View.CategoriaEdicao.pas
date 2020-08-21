unit View.CategoriaEdicao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.Edit, FMX.ListBox;

type
  TFrmCategoriaEdicao = class(TForm)
    LayoutTool: TLayout;
    LabelTitulo: TLabel;
    ImageFechar: TImage;
    ImageSalvar: TImage;
    LayoutDescricao: TLayout;
    LabelDescricao: TLabel;
    edtDescricao: TEdit;
    LineDescricao: TLine;
    LayoutValor: TLayout;
    LabelIcone: TLabel;
    ListBoxIcone: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    ListBoxItem13: TListBoxItem;
    ListBoxItem14: TListBoxItem;
    ListBoxItem15: TListBoxItem;
    ListBoxItem16: TListBoxItem;
    Image1: TImage;
    ImgSelecao: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ImageFecharClick(Sender: TObject);
    procedure SelecionarIcone(Sender: TObject);
  strict private
    class var _instance : TFrmCategoriaEdicao;
  private
    { Private declarations }
  public
    { Public declarations }
    class function GetInstance() : TFrmCategoriaEdicao;
  end;

//var
//  FrmCategoriaEdicao: TFrmCategoriaEdicao;

implementation

{$R *.fmx}

uses
  DataModule.Recursos;

{ TFrmCategoriaEdicao }

procedure TFrmCategoriaEdicao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action    := TCloseAction.caFree;
  _instance := nil;
end;

procedure TFrmCategoriaEdicao.FormCreate(Sender: TObject);
begin
  ListBoxIcone.Columns := Trunc(LabelIcone.Width / 80);
end;

procedure TFrmCategoriaEdicao.FormResize(Sender: TObject);
begin
  ListBoxIcone.Columns := Trunc(LabelIcone.Width / 80);
end;

class function TFrmCategoriaEdicao.GetInstance: TFrmCategoriaEdicao;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmCategoriaEdicao, _instance);

  Result := _instance;
end;

procedure TFrmCategoriaEdicao.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFrmCategoriaEdicao.SelecionarIcone(Sender: TObject);
begin
  if Sender is TImage then
  begin
    ImgSelecao.AnimateFloatWait('Opacity', 0, 0.2, TAnimationType.Out, TInterpolationType.Circular);
    ImgSelecao.Parent := TImage(Sender).Parent;
    ImgSelecao.AnimateFloatWait('Opacity', 0.3, 0.2, TAnimationType.&In, TInterpolationType.Circular);

    ShowMessage( TListBoxItem(ImgSelecao.Parent).Index.ToString );
  end;
end;

end.
