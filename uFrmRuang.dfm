object FrmRuang: TFrmRuang
  Left = 476
  Top = 122
  Width = 512
  Height = 516
  Caption = 'Form Ruang'
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
    Top = 12
    Width = 490
    Height = 166
    Caption = 'Data Ruang'
    TabOrder = 0
    object Label1: TLabel
      Left = 20
      Top = 36
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
    object Label2: TLabel
      Left = 20
      Top = 66
      Width = 60
      Height = 19
      Caption = 'Kapasitas'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 21
      Top = 97
      Width = 29
      Height = 19
      Caption = 'Jenis'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object txtNama: TEdit
      Left = 90
      Top = 34
      Width = 249
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object txtKapasitas: TEdit
      Left = 90
      Top = 63
      Width = 46
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object cmbJenis: TComboBox
      Left = 92
      Top = 94
      Width = 145
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ItemHeight = 19
      ItemIndex = 0
      ParentFont = False
      TabOrder = 2
      Text = 'TEORI'
      Items.Strings = (
        'TEORI'
        'LABORATORIUM')
    end
    object btnBaru: TButton
      Left = 91
      Top = 128
      Width = 75
      Height = 25
      Caption = 'Baru'
      TabOrder = 3
      OnClick = btnBaruClick
    end
    object btnBatal: TButton
      Left = 321
      Top = 128
      Width = 75
      Height = 25
      Caption = 'Batal'
      TabOrder = 4
      OnClick = btnBatalClick
    end
    object btnSimpan: TButton
      Left = 407
      Top = 127
      Width = 75
      Height = 25
      Caption = 'Simpan'
      TabOrder = 5
      OnClick = btnSimpanClick
    end
    object btnCari: TButton
      Left = 344
      Top = 32
      Width = 41
      Height = 27
      Caption = 'Cari'
      TabOrder = 6
      OnClick = btnCariClick
    end
  end
  object dtGridView: TDBGrid
    Left = 7
    Top = 182
    Width = 490
    Height = 268
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
    Left = 420
    Top = 458
    Width = 75
    Height = 25
    Caption = 'Tutup'
    TabOrder = 2
    OnClick = btn3Click
  end
  object DataSource1: TDataSource
    DataSet = mySQLQuery1
    Left = 97
    Top = 206
  end
  object mySQLQuery1: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 130
    Top = 206
  end
end
