object DMConexao: TDMConexao
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 274
  Width = 412
  object Conn: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    BeforeConnect = ConnBeforeConnect
    Left = 136
    Top = 120
  end
  object Qry: TFDQuery
    Connection = Conn
    Left = 136
    Top = 168
  end
end
