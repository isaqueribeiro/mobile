object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 485
  Width = 705
  object conn: TFDConnection
    Params.Strings = (
      
        'Database=D:\Projetos\ASS\mobile\trunk\delphi\appVendaSimples\bin' +
        '\Win32\Debug\db\venda_simples.db'
      'LockingMode=Normal'
      'OpenMode=ReadWrite'
      'DriverID=SQLite')
    LoginPrompt = False
    Transaction = trans
    UpdateTransaction = trans
    AfterConnect = connAfterConnect
    Left = 48
    Top = 32
  end
  object drvSQLiteDriver: TFDPhysSQLiteDriverLink
    Left = 48
    Top = 176
  end
  object trans: TFDTransaction
    Connection = conn
    Left = 48
    Top = 80
  end
  object waitCursor: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 48
    Top = 128
  end
  object qrySQL: TFDQuery
    Connection = conn
    Transaction = trans
    UpdateTransaction = trans
    Left = 48
    Top = 232
  end
  object updPedido: TFDUpdateSQL
    Connection = conn
    InsertSQL.Strings = (
      'INSERT INTO TBL_PEDIDO'
      '(ID_PEDIDO, CD_PEDIDO, TP_PEDIDO, ID_CLIENTE, '
      '  DS_CONTATO, DS_OBSERVACAO, DT_PEDIDO, VL_TOTAL, '
      '  VL_DESCONTO, VL_PEDIDO, SN_ATIVO, SN_ENTREGUE, '
      '  SN_SINCRONIZADO, CD_REFERENCIA)'
      
        'VALUES (:NEW_ID_PEDIDO, :NEW_CD_PEDIDO, :NEW_TP_PEDIDO, :NEW_ID_' +
        'CLIENTE, '
      
        '  :NEW_DS_CONTATO, :NEW_DS_OBSERVACAO, :NEW_DT_PEDIDO, :NEW_VL_T' +
        'OTAL, '
      
        '  :NEW_VL_DESCONTO, :NEW_VL_PEDIDO, :NEW_SN_ATIVO, :NEW_SN_ENTRE' +
        'GUE, '
      '  :NEW_SN_SINCRONIZADO, :NEW_CD_REFERENCIA)')
    ModifySQL.Strings = (
      'UPDATE TBL_PEDIDO'
      
        'SET ID_PEDIDO = :NEW_ID_PEDIDO, CD_PEDIDO = :NEW_CD_PEDIDO, TP_P' +
        'EDIDO = :NEW_TP_PEDIDO, '
      '  ID_CLIENTE = :NEW_ID_CLIENTE, DS_CONTATO = :NEW_DS_CONTATO, '
      
        '  DS_OBSERVACAO = :NEW_DS_OBSERVACAO, DT_PEDIDO = :NEW_DT_PEDIDO' +
        ', '
      '  VL_TOTAL = :NEW_VL_TOTAL, VL_DESCONTO = :NEW_VL_DESCONTO, '
      
        '  VL_PEDIDO = :NEW_VL_PEDIDO, SN_ATIVO = :NEW_SN_ATIVO, SN_ENTRE' +
        'GUE = :NEW_SN_ENTREGUE, '
      
        '  SN_SINCRONIZADO = :NEW_SN_SINCRONIZADO, CD_REFERENCIA = :NEW_C' +
        'D_REFERENCIA'
      'WHERE ID_PEDIDO = :OLD_ID_PEDIDO')
    DeleteSQL.Strings = (
      'DELETE FROM TBL_PEDIDO'
      'WHERE ID_PEDIDO = :OLD_ID_PEDIDO')
    FetchRowSQL.Strings = (
      
        'SELECT ID_PEDIDO, CD_PEDIDO, TP_PEDIDO, ID_CLIENTE, DS_CONTATO, ' +
        'DS_OBSERVACAO, '
      
        '  DT_PEDIDO, VL_TOTAL, VL_DESCONTO, VL_PEDIDO, SN_ATIVO, SN_ENTR' +
        'EGUE, '
      '  SN_SINCRONIZADO, CD_REFERENCIA'
      'FROM TBL_PEDIDO'
      'WHERE ID_PEDIDO = :ID_PEDIDO')
    Left = 48
    Top = 336
  end
  object qryPedido: TFDQuery
    Connection = conn
    Transaction = trans
    UpdateTransaction = trans
    UpdateObject = updPedido
    SQL.Strings = (
      'Select'
      '    p.*'
      '  , c.cd_cliente'
      '  , c.nm_cliente'
      '  , c.nr_cpf_cnpj'
      'from tbl_pedido p'
      '  left join tbl_cliente c on (c.id_cliente = p.id_cliente)'
      'where p.cd_pedido = :cd_pedido')
    Left = 48
    Top = 288
    ParamData = <
      item
        Name = 'CD_PEDIDO'
        DataType = ftCurrency
        ParamType = ptInput
        Value = 20000c
      end>
  end
  object rscUsuario: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://localhost:51358/ws_usuario.asmx'
    Params = <>
    RaiseExceptionOn500 = False
    Left = 416
    Top = 184
  end
  object rscFuncoes: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://localhost:51358/ws_funcoes.asmx'
    Params = <>
    RaiseExceptionOn500 = False
    Left = 416
    Top = 128
  end
  object rscCliente: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://localhost:51358/ws_cliente.asmx'
    Params = <>
    RaiseExceptionOn500 = False
    Left = 416
    Top = 232
  end
end
