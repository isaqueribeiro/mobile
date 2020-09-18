unit View.LancamentoEdicao;

interface

uses
  Classe.ObjetoItemListView,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Edit, FMX.DateTimeCtrls;

type
  TFrmLancamentoEdicao = class(TForm)
    LayoutTool: TLayout;
    ImageFechar: TImage;
    ImageSalvar: TImage;
    LayoutBototes: TLayout;
    RectangleBotoes: TRectangle;
    ImageExcluir: TImage;
    LabelTitulo: TLabel;
    VertScrollBox: TVertScrollBox;
    LayoutDescricao: TLayout;
    LabelDescricao: TLabel;
    edtDescricao: TEdit;
    LineDescricao: TLine;
    LayoutValor: TLayout;
    LabelValor: TLabel;
    edtValor: TEdit;
    LineValor: TLine;
    LayoutCategoria: TLayout;
    LabelCategoria: TLabel;
    edtCategoria: TEdit;
    LineCategoria: TLine;
    LayoutData: TLayout;
    LabelData: TLabel;
    LineData: TLine;
    ImageSelecionarCategoria: TImage;
    LayoutInformeData: TLayout;
    edtData: TDateEdit;
    ImageCategoria: TImage;
    ImgSemImage: TImage;
    ImageHoje: TImage;
    LabelHoje: TLabel;
    ImageOntem: TImage;
    LabelOntem: TLabel;
    LayoutTipo: TLayout;
    LabelTipo: TLabel;
    LineTipo: TLine;
    ImageTipoReceita: TImage;
    LabelTipoReceita: TLabel;
    ImageTipoDespesa: TImage;
    LabelTipoDespesa: TLabel;
    ImgMarcado: TImage;
    ImgDesmarcado: TImage;
    procedure ImageFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  strict private
    class var _instance : TFrmLancamentoEdicao;
  private
    { Private declarations }
  public
    { Public declarations }
    class function GetInstance() : TFrmLancamentoEdicao;
  end;

//var
//  FrmLancamentoEdicao: TFrmLancamentoEdicao;
//
implementation

{$R *.fmx}

uses
  DataModule.Recursos;

{ TFrmLancamentoEdicao }

procedure TFrmLancamentoEdicao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action    := TCloseAction.caFree;
  _instance := nil;
end;

procedure TFrmLancamentoEdicao.FormCreate(Sender: TObject);
begin
  ImgSemImage.Visible   := False;
  ImgMarcado.Visible    := False;
  ImgDesmarcado.Visible := False;
end;

class function TFrmLancamentoEdicao.GetInstance: TFrmLancamentoEdicao;
begin
  if not Assigned(_instance) then
    Application.CreateForm(TFrmLancamentoEdicao, _instance);

  Result := _instance;
end;

procedure TFrmLancamentoEdicao.ImageFecharClick(Sender: TObject);
begin
  Self.Close;
end;

end.
