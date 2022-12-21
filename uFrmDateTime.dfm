object FrmDateTime: TFrmDateTime
  Left = 322
  Top = 40
  Width = 716
  Height = 561
  Caption = 'FrmDateTime'
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
    Left = 8
    Top = 0
    Width = 337
    Height = 487
    Caption = 'GroupBox1'
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 40
      Width = 35
      Height = 19
      Caption = 'Kode'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 16
      Top = 80
      Width = 37
      Height = 19
      Caption = 'Nama'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object txtKodeHari: TEdit
      Left = 72
      Top = 40
      Width = 121
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object txtNamaHari: TEdit
      Left = 72
      Top = 80
      Width = 249
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object btnBaruHari: TButton
      Left = 8
      Top = 137
      Width = 75
      Height = 25
      Caption = 'Baru'
      TabOrder = 2
      OnClick = btnBaruHariClick
    end
    object btnBatalHari: TButton
      Left = 166
      Top = 137
      Width = 75
      Height = 25
      Caption = 'Batal'
      TabOrder = 3
      OnClick = btnBatalHariClick
    end
    object btnSimpanHari: TButton
      Left = 246
      Top = 137
      Width = 75
      Height = 25
      Caption = 'Simpan'
      TabOrder = 4
      OnClick = btnSimpanHariClick
    end
    object dtGridViewHari: TDBGrid
      Left = 8
      Top = 172
      Width = 320
      Height = 305
      DataSource = DataSource1
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 5
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnCellClick = dtGridViewHariCellClick
      OnKeyDown = dtGridViewHariKeyDown
    end
  end
  object GroupBox2: TGroupBox
    Left = 360
    Top = 0
    Width = 337
    Height = 488
    Caption = 'GroupBox1'
    TabOrder = 1
    object Label3: TLabel
      Left = 16
      Top = 40
      Width = 35
      Height = 19
      Caption = 'Kode'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 16
      Top = 80
      Width = 37
      Height = 19
      Caption = 'Nama'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 72
      Top = 112
      Width = 95
      Height = 13
      Caption = 'format : 00:00-00:00'
    end
    object txtKodeJam: TEdit
      Left = 72
      Top = 40
      Width = 121
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object txtRangeJam: TEdit
      Left = 72
      Top = 80
      Width = 249
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Text = '00:00-00:00'
    end
    object btnBaruJam: TButton
      Left = 8
      Top = 141
      Width = 75
      Height = 25
      Caption = 'Baru'
      TabOrder = 2
      OnClick = btnBaruJamClick
    end
    object btnBatalJam: TButton
      Left = 166
      Top = 141
      Width = 75
      Height = 25
      Caption = 'Batal'
      TabOrder = 3
      OnClick = btnBatalJamClick
    end
    object btnSimpanJam: TButton
      Left = 246
      Top = 141
      Width = 75
      Height = 25
      Caption = 'Simpan'
      TabOrder = 4
      OnClick = btnSimpanJamClick
    end
    object dtGridViewJam: TDBGrid
      Left = 8
      Top = 175
      Width = 320
      Height = 303
      DataSource = DataSource2
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 5
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnCellClick = dtGridViewJamCellClick
      OnKeyDown = dtGridViewJamKeyDown
    end
  end
  object btn3: TButton
    Left = 623
    Top = 497
    Width = 75
    Height = 25
    Caption = 'Tutup'
    TabOrder = 2
    OnClick = btn3Click
  end
  object DataSource1: TDataSource
    DataSet = mySQLQueryHari
    Left = 96
    Top = 136
  end
  object mySQLQueryHari: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 128
    Top = 136
  end
  object DataSource2: TDataSource
    DataSet = mySQLQueryJam
    Left = 456
    Top = 136
  end
  object mySQLQueryJam: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 488
    Top = 136
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 305
    Top = 224
  end
end
