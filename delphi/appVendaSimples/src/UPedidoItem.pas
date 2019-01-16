unit UPedidoItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UPadraoCadastro, System.Actions, FMX.ActnList, FMX.TabControl, FMX.Ani,
  FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation;

type
  TFrmPedidoItem = class(TFrmPadraoCadastro)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPedidoItem: TFrmPedidoItem;

implementation

{$R *.fmx}

uses
    app.Funcoes
  , UConstantes
  , UMensagem;

end.
