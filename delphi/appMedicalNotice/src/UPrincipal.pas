unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.TabControl, System.Actions, FMX.ActnList, FMX.Objects,
  FMX.MultiView;

type
  TFrmPrincipal = class(TForm)
    layoutBase: TLayout;
    TabControlPrincipal: TTabControl;
    TabPrincipal: TTabItem;
    TabDetalhe: TTabItem;
    ToolBarForm: TToolBar;
    BtnVoltar: TSpeedButton;
    ActionListPrincipal: TActionList;
    acChangeTabAction: TChangeTabAction;
    LabelTitleDetalhe: TLabel;
    acPreviousTabAction: TPreviousTabAction;
    MultiViewMenu: TMultiView;
    LayoutFoto: TLayout;
    ToolBarPrincipal: TToolBar;
    BtnMenu: TSpeedButton;
    BtnRefresh: TSpeedButton;
    LabelTitlePrincipal: TLabel;
    LayoutUser: TLayout;
    LabelUserName: TLabel;
    LabelUserEmail: TLabel;
    ImageUser: TImage;
    LayoutImage: TLayout;
    CircleImage: TCircle;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  TabControlPrincipal.ActiveTab := TabPrincipal;
end;

end.
