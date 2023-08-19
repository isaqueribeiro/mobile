object DataModuleBase: TDataModuleBase
  OldCreateOrder = False
  Height = 412
  Width = 575
  object FConn: TFDConnection
    Left = 48
    Top = 48
  end
  object FBDriverLink: TFDPhysFBDriverLink
    Left = 48
    Top = 144
  end
  object FDTransaction: TFDTransaction
    Connection = FConn
    Left = 48
    Top = 96
  end
  object MSSQLDriverLink: TFDPhysMSSQLDriverLink
    Left = 48
    Top = 192
  end
end
