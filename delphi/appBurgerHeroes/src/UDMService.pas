unit UDMService;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Android.Service,

  FMX.Types,
  System.Threading,
  System.PushNotification,
  System.JSON,
//  System.Notification,

  IPPeerClient, AndroidApi.JNI.GraphicsContentViewText, Androidapi.JNI.Os;

type
  TDMService = class(TAndroidService)
    function AndroidServiceStartCommand(const Sender: TObject; const Intent: JIntent; Flags,
      StartId: Integer): Integer;
  private
    { Private declarations }
    aPush  : TPushService;
    aPushConnection : TPushServiceConnection;
    procedure DoServiceConnectionChange(Sender : TObject; PushChanges : TPushService.TChanges);
    procedure DoReceiveNotificationEvent(Sender : TObject; const ServiceNotification : TPushServiceNotification);
  public
    { Public declarations }
//    procedure AtivarPushNotification;
//    procedure AlertNotification(const aName, aTitle, aMessage : String);
  end;

var
  DMService: TDMService;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Androidapi.JNI.App, classes.Constantes;

//procedure TDMService.AlertNotification(const aName, aTitle, aMessage: String);
//var
//  aNotificacao : TNotification;
//begin
//  if NotificationCenter.Supported then
//  begin
//    aNotificacao := NotificationCenter.CreateNotification;
//    try
//      aNotificacao.Name        := aName;
//      aNotificacao.Title       := aTitle;
//      aNotificacao.AlertBody   := aMessage;
//      aNotificacao.Number      := (NotificationCenter.ApplicationIconBadgeNumber + 1);
//      aNotificacao.EnableSound := True;
//      NotificationCenter.PresentNotification(aNotificacao);
//    finally
//      aNotificacao.DisposeOf;
//    end;
//  end;
//end;

function TDMService.AndroidServiceStartCommand(const Sender: TObject; const Intent: JIntent; Flags,
  StartId: Integer): Integer;
begin
//  TTask.Run(
//    procedure
//    begin
//      try
//        aPush  := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.GCM);
//        aPush.AppProps[TPushService.TAppPropNames.GCMAppID] := APP_CODIGO_REMETENTE;
//
//        aPushConnection := TPushServiceConnection.Create(aPush);
//        aPushConnection.OnChange := DoServiceConnectionChange;
//        aPushConnection.OnReceiveNotification := DoReceiveNotificationEvent;
//      except
//      end;
//    end
//  );
//
  Result := TJService.JavaClass.START_STICKY; // Manterá o Serviço Executando
end;

//procedure TDMService.AtivarPushNotification;
//begin
//  aPush  := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.GCM);
//  aPush.AppProps[TPushService.TAppPropNames.GCMAppID] := APP_CODIGO_REMETENTE;
//
//  aPushConnection := TPushServiceConnection.Create(aPush);
//  aPushConnection.OnChange := DoServiceConnectionChange;
//  aPushConnection.OnReceiveNotification := DoReceiveNotificationEvent;
//
//  TTask.Run(
//    procedure
//    begin
//      try
//        aPushConnection.Active := True;
//      except
//      end;
//    end
//  );
//end;
//
procedure TDMService.DoReceiveNotificationEvent(Sender: TObject;
  const ServiceNotification: TPushServiceNotification);
begin
  TThread.queue(nil,
    procedure
    var
      aMessageTitle,
      aMessageText ,
      aJsonText    : String;
      x    : Integer;
      Obj  : TJSONObject;
      Pair : TJSONPair;
    begin
      // Recuperar notificação quando o APP estiver aberto
      try
        aMessageText := EmptyStr;
        aJsonText    := ServiceNotification.DataObject.ToJSON;

        for x := 0 to ServiceNotification.DataObject.Count - 1 do
        begin
          if (ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'title') then
            aMessageTitle := Trim(ServiceNotification.DataObject.Pairs[x].JsonValue.Value)
          else
          if (ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'message') then
            aMessageText := Trim(ServiceNotification.DataObject.Pairs[x].JsonValue.Value);
        end;
    //
    //    if (Trim(aMessageText) <> EmptyStr) then
    //      AlertNotification(SERVICE_BURGER_HEROES, aMessageTitle, Trim(aMessageText));
      except
        ;
      end;
    end);
end;

procedure TDMService.DoServiceConnectionChange(Sender: TObject; PushChanges: TPushService.TChanges);
begin
  TThread.queue(nil,
    procedure
    var
      aDispositivoID    ,
      aDispositivoToken : String;
    begin
      if (TPushService.TChange.DeviceToken in PushChanges) then
      begin
        aDispositivoID    := aPush.DeviceTokenValue[TPushService.TDeviceIDNames.DeviceID];
        aDispositivoToken := aPush.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];
      end;
    end);
end;

end.
