unit DataModule.Base;

interface

uses
  System.SysUtils, System.Classes,

  FireDAC.Phys, FireDAC.Phys.Intf,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
  FireDAC.Phys.MSSQLDef, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.FMXUI.Wait, FireDAC.Comp.Client, Data.DB;

type
  TDataModuleBase = class(TDataModule)
    FConn: TFDConnection;
    FBDriverLink: TFDPhysFBDriverLink;
    FDTransaction: TFDTransaction;
    MSSQLDriverLink: TFDPhysMSSQLDriverLink;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModuleBase: TDataModuleBase;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
