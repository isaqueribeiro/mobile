object DtmDados: TDtmDados
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 432
  Width = 560
  object FdBase: TFDManager
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Left = 96
    Top = 48
  end
  object FdSQLiteDriver: TFDPhysSQLiteDriverLink
    Left = 96
    Top = 96
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 96
    Top = 144
  end
  object RESTClient1: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    AcceptEncoding = 'identity'
    BaseURL = 
      'http://servicos.hab.org.br/medicalNotice/json/app_especialidade_' +
      'dao.php'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 352
    Top = 256
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <>
    Resource = 'key=abc'
    Response = RESTResponse1
    SynchronizedEvents = False
    Left = 352
    Top = 304
  end
  object RESTResponse1: TRESTResponse
    ContentType = 'application/json'
    Left = 352
    Top = 352
  end
end
