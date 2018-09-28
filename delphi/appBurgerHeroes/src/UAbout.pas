unit UAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Actions, FMX.ActnList, FMX.StdActns;

type
  TFrmAbout = class(TForm)
    ScrollBoxForm: TScrollBox;
    LayoutForm: TLayout;
    ToolBar: TToolBar;
    SpeedButton1: TSpeedButton;
    LabelAppName: TLabel;
    ActionList: TActionList;
    WindowClose: TWindowClose;
    LayoutBase: TLayout;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAbout: TFrmAbout;

implementation

{$R *.fmx}

end.
