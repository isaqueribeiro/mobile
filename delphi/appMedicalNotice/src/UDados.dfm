object DtmDados: TDtmDados
  OldCreateOrder = False
  Height = 432
  Width = 560
  object FdSQLiteDriver: TFDPhysSQLiteDriverLink
    Left = 96
    Top = 144
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 96
    Top = 192
  end
  object RESTClientGET: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    AcceptEncoding = 'identity'
    BaseURL = 'http://servicos.hab.org.br/medicalNotice/json'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 464
    Top = 40
  end
  object RESTRequestGET: TRESTRequest
    Client = RESTClientGET
    Params = <>
    Resource = 'app_especialidade_dao.php?key=abc'
    Response = RESTResponseGET
    SynchronizedEvents = False
    Left = 464
    Top = 88
  end
  object RESTResponseGET: TRESTResponse
    Left = 464
    Top = 136
  end
  object cnnConexao: TFDConnection
    Params.Strings = (
      'Database=D:\db\mobile\medical_notice.db'
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Transaction = FDTransaction
    UpdateTransaction = FDTransaction
    AfterConnect = cnnConexaoAfterConnect
    BeforeConnect = cnnConexaoBeforeConnect
    Left = 96
    Top = 40
  end
  object FDTransaction: TFDTransaction
    Connection = cnnConexao
    Left = 96
    Top = 88
  end
  object RESTClientPOST: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    AcceptEncoding = 'identity'
    BaseURL = 'http://servicos.hab.org.br/medicalNotice/json'
    ContentType = 'application/x-www-form-urlencoded'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 376
    Top = 40
  end
  object RESTRequestPOST: TRESTRequest
    Client = RESTClientPOST
    Method = rmPOST
    Params = <>
    Resource = 'app_especialidade_dao.php'
    Response = RESTResponsePOST
    SynchronizedEvents = False
    Left = 376
    Top = 88
  end
  object RESTResponsePOST: TRESTResponse
    ContentType = 'application/json'
    Left = 376
    Top = 136
  end
  object qrySQL: TFDQuery
    Connection = cnnConexao
    Transaction = FDTransaction
    UpdateTransaction = FDTransaction
    Left = 96
    Top = 248
  end
end
