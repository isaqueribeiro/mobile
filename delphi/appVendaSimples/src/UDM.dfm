object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 290
  Width = 339
  object conn: TFDConnection
    Params.Strings = (
      
        'Database=D:\Projetos\ASS\mobile\trunk\delphi\appVendaSimples\db\' +
        'venda_simples.db'
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 48
    Top = 32
  end
  object drvSQLiteDriver: TFDPhysSQLiteDriverLink
    Left = 48
    Top = 80
  end
end
