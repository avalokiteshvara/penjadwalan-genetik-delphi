object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 476
  Top = 282
  Height = 271
  Width = 478
  object mySQLDatabase1: TmySQLDatabase
    ConnectOptions = []
    Params.Strings = (
      'Port=3306'
      'TIMEOUT=30')
    Left = 24
    Top = 16
  end
  object mySQLQuery1: TmySQLQuery
    Database = mySQLDatabase1
    Left = 120
    Top = 16
  end
  object mySQLTable1: TmySQLTable
    Database = mySQLDatabase1
    Left = 200
    Top = 24
  end
  object mySQLQuery2: TmySQLQuery
    Left = 280
    Top = 24
  end
end
