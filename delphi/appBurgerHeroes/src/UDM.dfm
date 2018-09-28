object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 262
  Width = 355
  object NotificationCenter: TNotificationCenter
    Left = 80
    Top = 72
  end
  object PushEvents: TPushEvents
    Provider = EMSProvider
    AutoActivate = False
    AutoRegisterDevice = False
    OnPushReceived = PushEventsPushReceived
    Left = 80
    Top = 168
  end
  object EMSProvider: TEMSProvider
    ApiVersion = '1'
    URLPort = 0
    Left = 80
    Top = 120
  end
end
