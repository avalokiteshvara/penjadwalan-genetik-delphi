object FrmWaktuTidakBersedia: TFrmWaktuTidakBersedia
  Left = 844
  Top = 81
  Width = 369
  Height = 560
  Caption = 'FrmWaktuTidakBersedia'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 5
    Top = 5
    Width = 352
    Height = 101
    Caption = 'Data Dosen Tidak Bersedia'
    TabOrder = 0
    object Label1: TLabel
      Left = 19
      Top = 42
      Width = 80
      Height = 19
      Caption = 'Nama Dosen'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object btnSimpan: TButton
      Left = 243
      Top = 66
      Width = 75
      Height = 25
      Caption = 'Simpan'
      TabOrder = 0
      OnClick = btnSimpanClick
    end
    object cmbDosen: TMyDBLookupComboBox
      Left = 120
      Top = 41
      Width = 196
      Height = 21
      ListSource = DataSourceDosen
      TabOrder = 1
      OnChange = cmbDosenChange
    end
  end
  object lv: TListView
    Left = 9
    Top = 110
    Width = 346
    Height = 376
    Checkboxes = True
    Columns = <
      item
        Width = 20
      end
      item
        Caption = 'Hari'
        Width = 100
      end
      item
        Caption = 'Jam'
        Width = 100
      end
      item
        Caption = 'KodeHari'
        Width = 0
      end
      item
        Caption = 'KodeJam'
        Width = 0
      end>
    GridLines = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object btn3: TButton
    Left = 273
    Top = 499
    Width = 75
    Height = 25
    Caption = 'Tutup'
    TabOrder = 2
    OnClick = btn3Click
  end
  object mySQLQueryDosen: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 229
    Top = 16
  end
  object DataSourceDosen: TDataSource
    DataSet = mySQLQueryDosen
    Left = 265
    Top = 17
  end
  object mySQLQueryHari: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 67
    Top = 280
  end
  object mySQLQueryJam: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 147
    Top = 270
  end
  object mySQLQueryTidakBersedia: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 143
    Top = 304
  end
end
