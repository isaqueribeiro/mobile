unit UPrincipal;

interface

uses
  classes.Constantes,

  System.PushNotification,
  System.JSON,
  FMX.DialogService,
  FMX.VirtualKeyBoard,
  FMX.Platform,
  System.Threading,
  System.Math,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl, FMX.Layouts,
  FMX.Controls.Presentation, FMX.MultiView, FMX.StdCtrls, FMX.Objects, FMX.ListBox, IPPeerClient,
  REST.Backend.PushTypes, Data.Bind.Components, Data.Bind.ObjectScope, REST.Backend.BindSource,
  REST.Backend.PushDevice, FMX.ScrollBox, FMX.Memo;

type
  TFrmPrincipal = class(TForm)
    ScrollBoxForm: TScrollBox;
    LayoutForm: TLayout;
    tabControlForm: TTabControl;
    tbiLogin: TTabItem;
    tbiMenu: TTabItem;
    LayoutMenu: TLayout;
    MultiViewMenu: TMultiView;
    LayoutMViewTop: TLayout;
    LabelUserEmail: TLabel;
    LabelUserName: TLabel;
    RectangleMViewUser: TRectangle;
    CircleUserImage: TCircle;
    LayoutUserImage: TLayout;
    ToolBarMenu: TToolBar;
    BtnMenu: TSpeedButton;
    LayoutMViewOpcoes: TLayout;
    ListBoxMenu: TListBox;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    CARDÁPIO: TListBoxItem;
    ListBoxGroupHeader2: TListBoxGroupHeader;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ImageUser: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ListBoxItem5Click(Sender: TObject);
  private
    { Private declarations }
    aPushService  : TPushService;
    aPushServiceConnection : TPushServiceConnection;

    procedure AtivarPushNotification;
    procedure CarregarPushNotification;
    procedure DoServiceConnectionChange(Sender : TObject; PushChanges : TPushService.TChanges);
    procedure DoReceiveNotificationEvent(Sender : TObject; const ServiceNotification : TPushServiceNotification);
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses
  UDM, UAbout;

procedure TFrmPrincipal.AtivarPushNotification;
begin
  {$IF DEFINED (ANDROID)}
  aPushService  := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.GCM);
  aPushService.AppProps[TPushService.TAppPropNames.GCMAppID] := APP_CODIGO_REMETENTE;

  aPushServiceConnection := TPushServiceConnection.Create(aPushService);
  aPushServiceConnection.OnChange := DoServiceConnectionChange;
  aPushServiceConnection.OnReceiveNotification := DoReceiveNotificationEvent;

  TTask.Run(
    procedure
    begin
      try
        aPushServiceConnection.Active := True;
      except
      end;
    end
  );
  {$ENDIF}
  {$IF DEFINED (IOS)}
  aPushService  := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.APS);
  aPushServiceConnection := TPushServiceConnection.Create(aPushService);
  aPushServiceConnection.OnChange := DoServiceConnectionChange;
  aPushServiceConnection.OnReceiveNotification := DoReceiveNotificationEvent;

  TTask.Run(
    procedure
    begin
      try
        aPushServiceConnection.Active := True;
      except
      end;
    end
  );
  {$ENDIF}
end;

procedure TFrmPrincipal.CarregarPushNotification;
var
  aMessageTitle,
  aMessageText : String;
  aPushData    : TPushData;
  x : Integer;
begin
  // Recuperar notificação quando o APP estiver fechado
  aMessageTitle := EmptyStr;
  aMessageText  := EmptyStr;
  aPushData     := DM.PushEvents.StartupNotification;
  try
    if Assigned(aPushData) then
    begin
      aMessageTitle := 'Notificação';
      aMessageText  := Trim(aPushData.Message);
//      // Está funcionando
//      // IOS
//      if (Trim(DtmDados.PushEvents.StartupNotification.APS.Alert) <> EmptyStr) then
//        for x := 0 to aPushData.Extras.Count - 1 do
//          ; //aValor := aPushData.Extras[x].Key + '=' + aPushData.Extras[x].Value;
//      // ANDROID
//      if (Trim(DtmDados.PushEvents.StartupNotification.GCM.Message) <> EmptyStr) then
//        for x := 0 to aPushData.Extras.Count - 1 do
//          ; //aValor := aPushData.Extras[x].Key + '=' + aPushData.Extras[x].Value;
//
      if (Trim(aMessageText) <> EmptyStr) then
        TDialogService.MessageDialog(aMessageText, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  finally
    aPushData.DisposeOf;
    DM.ClearPush;
  end;
end;

procedure TFrmPrincipal.DoReceiveNotificationEvent(Sender: TObject;
  const ServiceNotification: TPushServiceNotification);
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
      // IOS
      if ServiceNotification.DataKey = 'aps' then
      begin
        if (ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'title') then
          aMessageTitle := Trim(ServiceNotification.DataObject.Pairs[x].JsonValue.Value)
        else
        if (ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'alert') then
          aMessageText := Trim(ServiceNotification.DataObject.Pairs[x].JsonValue.Value);
      end
      else
      // ANDROID
      if ServiceNotification.DataKey = 'gcm' then
      begin
        if (ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'title') then
          aMessageTitle := Trim(ServiceNotification.DataObject.Pairs[x].JsonValue.Value)
        else
        if (ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'message') then
          aMessageText := Trim(ServiceNotification.DataObject.Pairs[x].JsonValue.Value);
      end;
    end;

    if (Trim(aMessageText) <> EmptyStr) then
      DM.AlertNotification(APP_BURGER_HEROES, aMessageTitle, Trim(aMessageText));
  except
    ;
  end;
end;

procedure TFrmPrincipal.DoServiceConnectionChange(Sender: TObject; PushChanges: TPushService.TChanges);
var
  aDispositivoID    ,
  aDispositivoToken : String;
begin
  if (TPushService.TChange.DeviceToken in PushChanges) then
  begin
    aDispositivoID    := aPushService.DeviceTokenValue[TPushService.TDeviceIDNames.DeviceID];
    aDispositivoToken := aPushService.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];
//
//    if (Model.Ativo) and (Model.Id <> GUID_NULL) and (Trim(Model.TokenPush) <> EmptyStr) then
//      GravarTokenID;
  end;
end;

procedure TFrmPrincipal.FormActivate(Sender: TObject);
begin
  CarregarPushNotification;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
var
  aWidth : Single;
begin
  aWidth := Round((Screen.Width / 3) * 2);
  MultiViewMenu.Width := aWidth;
  MultiViewMenu.HideMaster;

  tabControlForm.TabPosition := TTabPosition.None;

  AtivarPushNotification;
end;

procedure TFrmPrincipal.ListBoxItem5Click(Sender: TObject);
begin
  MultiViewMenu.HideMaster;
  Application.CreateForm(TFrmAbout, FrmAbout);
  FrmAbout.Show;
end;

end.
