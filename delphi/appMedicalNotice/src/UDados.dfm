object DtmDados: TDtmDados
  OldCreateOrder = False
  OnCreate = DataModuleCreate
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
  object qrySQL: TFDQuery
    Connection = cnnConexao
    Transaction = FDTransaction
    UpdateTransaction = FDTransaction
    Left = 96
    Top = 248
  end
  object RESTClientUsuario: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    BaseURL = 'http://servicos.hab.org.br/medicalNotice/json'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 272
    Top = 216
  end
  object RESTRequestUsuario: TRESTRequest
    Client = RESTClientUsuario
    Params = <
      item
        Kind = pkURLSEGMENT
        name = 'hash'
        Options = [poAutoCreated]
      end>
    Resource = 'app_usuario_dao.php?hash={hash}'
    Response = RESTResponseUsuario
    SynchronizedEvents = False
    Left = 272
    Top = 264
  end
  object RESTResponseUsuario: TRESTResponse
    Left = 272
    Top = 312
  end
  object RESTClientEspecialidade: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    BaseURL = 'http://servicos.hab.org.br/medicalNotice/json'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 408
    Top = 48
  end
  object RESTRequestEspecialidade: TRESTRequest
    Client = RESTClientEspecialidade
    Params = <
      item
        Kind = pkURLSEGMENT
        name = 'hash'
        Options = [poAutoCreated]
      end>
    Resource = 'app_especialidade_dao.php?hash={hash}'
    Response = RESTResponseEspecialidade
    SynchronizedEvents = False
    Left = 408
    Top = 96
  end
  object RESTResponseEspecialidade: TRESTResponse
    ContentType = 'application/json'
    Left = 408
    Top = 144
  end
  object RESTClient1: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    BaseURL = 'http://servicos.hab.org.br/medicalNotice/json'
    ContentType = 'application/x-www-form-urlencoded'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 72
    Top = 344
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Method = rmPOST
    Params = <
      item
        name = 'id_usuario'
        Value = 'xxxxxxx'
      end
      item
        name = 'cd_usuario'
        Value = 'edgar_sobrinho'
      end
      item
        name = 'ds_email'
        Value = 'isaque.ribeiro@outlook.com'
      end>
    Resource = 
      'app_usuario_dao.php?hash=0e52625351643889a564a8270f56c76e&id_aca' +
      'o=saveUser'
    Response = RESTResponse1
    SynchronizedEvents = False
    Left = 80
    Top = 352
  end
  object RESTResponse1: TRESTResponse
    ContentType = 'application/json'
    Left = 88
    Top = 360
  end
end
