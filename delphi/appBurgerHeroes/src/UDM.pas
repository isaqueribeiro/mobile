unit UDM;

interface

uses
  FMX.Dialogs,
  FMX.DialogService,
  System.UITypes,

  System.SysUtils, System.Classes, System.Notification, IPPeerClient, REST.Backend.PushTypes, System.JSON,
  REST.Backend.EMSPushDevice, System.PushNotification, REST.Backend.EMSProvider, Data.Bind.Components,
  Data.Bind.ObjectScope, REST.Backend.BindSource, REST.Backend.PushDevice;

type
  TDM = class(TDataModule)
    NotificationCenter: TNotificationCenter;
    PushEvents: TPushEvents;
    EMSProvider: TEMSProvider;
    procedure DataModuleCreate(Sender: TObject);
    procedure PushEventsPushReceived(Sender: TObject; const AData: TPushData);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AlertNotification(const aName, aTitle, aMessage : String);
    procedure ClearPush;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses
  classes.Constantes;

{$R *.dfm}

{ TDM }

procedure TDM.AlertNotification(const aName, aTitle, aMessage: String);
var
  aNotificacao : TNotification;
begin
  if NotificationCenter.Supported then
  begin
    aNotificacao := NotificationCenter.CreateNotification;
    try
      aNotificacao.Name        := aName;
      aNotificacao.Title       := aTitle;
      aNotificacao.AlertBody   := aMessage;
      aNotificacao.Number      := (NotificationCenter.ApplicationIconBadgeNumber + 1);
      aNotificacao.EnableSound := True;
      NotificationCenter.PresentNotification(aNotificacao);
    finally
      aNotificacao.DisposeOf;
    end;
  end;
end;

procedure TDM.ClearPush;
begin
  ;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  EMSProvider.AndroidPush.GCMAppID := APP_CODIGO_REMETENTE;
  TThread.queue(nil,
    procedure
    begin
      PushEvents.AutoActivate := True;
    end);
end;

procedure TDM.PushEventsPushReceived(Sender: TObject; const AData: TPushData);
begin
  TThread.queue(nil,
    procedure
    begin
      TDialogService.MessageDialog(AData.Message, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end);
end;

end.
