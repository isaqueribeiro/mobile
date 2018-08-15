object DtmDados: TDtmDados
  OldCreateOrder = False
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
end
