object FrmMataKuliah: TFrmMataKuliah
  Left = 431
  Top = 139
  Width = 526
  Height = 506
  Caption = 'FrmMataKuliah'
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
    Top = 8
    Width = 497
    Height = 233
    Caption = 'GroupBox1'
    TabOrder = 0
    object Label1: TLabel
      Left = 32
      Top = 33
      Width = 44
      Height = 19
      Caption = 'KODE'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 32
      Top = 73
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
    object Label3: TLabel
      Left = 33
      Top = 109
      Width = 30
      Height = 19
      Caption = 'SKS'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 202
      Top = 107
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
    object Label5: TLabel
      Left = 32
      Top = 138
      Width = 53
      Height = 19
      Caption = 'Kategori'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object txtKode: TEdit
      Left = 120
      Top = 32
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
    object txtNama: TEdit
      Left = 120
      Top = 72
      Width = 210
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object txtSKS: TEdit
      Left = 120
      Top = 104
      Width = 61
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object txtSemester: TEdit
      Left = 273
      Top = 106
      Width = 59
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object cmbKategori: TComboBox
      Left = 120
      Top = 139
      Width = 145
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = 'TEORI'
      Items.Strings = (
        'TEORI'
        'PRAKTIKUM')
    end
    object btnBaru: TButton
      Left = 8
      Top = 200
      Width = 75
      Height = 25
      Caption = 'Baru'
      TabOrder = 5
      OnClick = btnBaruClick
    end
    object btnBatal: TButton
      Left = 336
      Top = 200
      Width = 75
      Height = 25
      Caption = 'Batal'
      TabOrder = 6
      OnClick = btnBatalClick
    end
    object btnSimpan: TButton
      Left = 415
      Top = 200
      Width = 75
      Height = 25
      Caption = 'Simpan'
      TabOrder = 7
      OnClick = btnSimpanClick
    end
  end
  object dtGridView: TDBGrid
    Left = 8
    Top = 248
    Width = 497
    Height = 193
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
  object btnTutup: TButton
    Left = 428
    Top = 446
    Width = 75
    Height = 25
    Caption = 'Tutup'
    TabOrder = 2
    OnClick = btnTutupClick
  end
  object mySQLQuery1: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 135
    Top = 192
  end
  object DataSource1: TDataSource
    DataSet = mySQLQuery1
    Left = 168
    Top = 194
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 304
    Top = 224
  end
end
