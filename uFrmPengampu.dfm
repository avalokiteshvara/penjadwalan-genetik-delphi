object FrmPengampu: TFrmPengampu
  Left = 557
  Top = 24
  Width = 571
  Height = 640
  Caption = 'FrmPengampu'
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
    Left = 11
    Top = 7
    Width = 544
    Height = 208
    Caption = 'Data Pengampu'
    TabOrder = 0
    object Label1: TLabel
      Left = 26
      Top = 36
      Width = 56
      Height = 19
      Caption = 'Semester'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 255
      Top = 36
      Width = 102
      Height = 19
      Caption = 'Tahun Akademik'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 26
      Top = 75
      Width = 75
      Height = 19
      Caption = 'Mata Kuliah'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 26
      Top = 109
      Width = 39
      Height = 19
      Caption = 'Dosen'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 26
      Top = 149
      Width = 35
      Height = 19
      Caption = 'Kelas'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object cmbSemester: TComboBox
      Left = 122
      Top = 37
      Width = 79
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'GANJIL'
      OnChange = cmbSemesterChange
      Items.Strings = (
        'GANJIL'
        'GENAP')
    end
    object cmbTahunAkademik: TComboBox
      Left = 367
      Top = 35
      Width = 108
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = '2011/2012'
      OnChange = cmbTahunAkademikChange
      Items.Strings = (
        '2011/2012'
        '2012/2013'
        '2013/2014'
        '2014/2015'
        '2015/2016'
        '2016/2017'
        '2017/2018'
        '2018/2019'
        '2019/2020')
    end
    object txtKelas: TEdit
      Left = 120
      Top = 147
      Width = 82
      Height = 21
      TabOrder = 2
      Text = 'txtKelas'
    end
    object btnBaru: TButton
      Left = 119
      Top = 178
      Width = 75
      Height = 25
      Caption = 'Baru'
      TabOrder = 3
      OnClick = btnBaruClick
    end
    object btnBatal: TButton
      Left = 366
      Top = 174
      Width = 75
      Height = 25
      Caption = 'Batal'
      TabOrder = 4
      OnClick = btnBatalClick
    end
    object btnSimpan: TButton
      Left = 448
      Top = 173
      Width = 75
      Height = 25
      Caption = 'Simpan'
      TabOrder = 5
      OnClick = btnSimpanClick
    end
    object cmbMataKuliah: TDBLookupComboBox
      Left = 121
      Top = 75
      Width = 176
      Height = 21
      ListSource = DataSourceCmbMK
      TabOrder = 6
    end
    object cmbDosen: TDBLookupComboBox
      Left = 120
      Top = 109
      Width = 179
      Height = 21
      ListSource = DataSourceDosen
      TabOrder = 7
    end
  end
  object dtGridView: TDBGrid
    Left = 11
    Top = 219
    Width = 544
    Height = 346
    DataSource = DataSource1
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnCellClick = dtGridViewCellClick
    OnKeyDown = dtGridViewKeyDown
  end
  object btn3: TButton
    Left = 468
    Top = 574
    Width = 75
    Height = 25
    Caption = 'Tutup'
    TabOrder = 2
    OnClick = btn3Click
  end
  object mySQLQuery1: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 212
    Top = 272
  end
  object DataSource1: TDataSource
    DataSet = mySQLQuery1
    Left = 138
    Top = 273
  end
  object mySQLQueryCmdMK: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 283
    Top = 135
  end
  object DataSourceCmbMK: TDataSource
    DataSet = mySQLQueryCmdMK
    Left = 234
    Top = 135
  end
  object DataSourceDosen: TDataSource
    DataSet = mySQLQueryDosen
    Left = 347
    Top = 115
  end
  object mySQLQueryDosen: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 396
    Top = 115
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 304
    Top = 224
  end
end
