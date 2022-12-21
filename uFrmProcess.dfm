object FrmProcess: TFrmProcess
  Left = 274
  Top = 54
  Width = 874
  Height = 597
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblPosition: TLabel
    Left = 568
    Top = 16
    Width = 7
    Height = 13
    Caption = '#'
  end
  object lblRata2Fitness: TLabel
    Left = 568
    Top = 520
    Width = 72
    Height = 13
    Caption = 'lblRata2Fitness'
  end
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 553
    Height = 505
    Caption = 'Build Jadwal'
    TabOrder = 0
    object lbl1: TLabel
      Left = 16
      Top = 48
      Width = 81
      Height = 13
      Caption = 'Tahun Akademik'
    end
    object lbl2: TLabel
      Left = 16
      Top = 80
      Width = 44
      Height = 13
      Caption = 'Semester'
    end
    object lbl3: TLabel
      Left = 16
      Top = 112
      Width = 76
      Height = 13
      Caption = 'Jumlah Populasi'
    end
    object lbl4: TLabel
      Left = 304
      Top = 40
      Width = 104
      Height = 13
      Caption = 'Probabilitas Crossover'
    end
    object lbl5: TLabel
      Left = 304
      Top = 72
      Width = 88
      Height = 13
      Caption = 'Probabilitas Mutasi'
    end
    object lbl6: TLabel
      Left = 304
      Top = 104
      Width = 28
      Height = 13
      Caption = 'Iterasi'
    end
    object txtJumlahPopulasi: TEdit
      Left = 120
      Top = 104
      Width = 73
      Height = 21
      TabOrder = 0
    end
    object numCrossover: TSpinEdit
      Left = 416
      Top = 40
      Width = 73
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object numMutasi: TSpinEdit
      Left = 416
      Top = 70
      Width = 73
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
    object dtGridView: TDBGrid
      Left = 16
      Top = 168
      Width = 521
      Height = 329
      DataSource = DataSource1
      TabOrder = 3
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
    end
    object btnStop: TButton
      Left = 305
      Top = 128
      Width = 99
      Height = 25
      Caption = 'STOP'
      Enabled = False
      TabOrder = 4
      OnClick = btnStopClick
    end
    object btnProses: TButton
      Left = 416
      Top = 128
      Width = 75
      Height = 25
      Caption = 'PROSES'
      TabOrder = 5
      OnClick = btnProsesClick
    end
    object txtIterasi: TEdit
      Left = 416
      Top = 96
      Width = 73
      Height = 21
      TabOrder = 6
    end
    object cmbSemester: TComboBox
      Left = 120
      Top = 72
      Width = 145
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 7
      Text = 'GANJIL'
      Items.Strings = (
        'GANJIL'
        'GENAP')
    end
    object cmbTahunAkademik: TComboBox
      Left = 120
      Top = 40
      Width = 145
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 8
      Text = '2011/2012'
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
  end
  object lv: TListView
    Left = 568
    Top = 32
    Width = 288
    Height = 481
    Columns = <
      item
        Caption = 'Individu Ke -'
        Width = 80
      end
      item
        Caption = 'Fitness'
        Width = 200
      end>
    TabOrder = 1
    ViewStyle = vsReport
  end
  object btn3: TButton
    Left = 775
    Top = 520
    Width = 75
    Height = 25
    Caption = 'Tutup'
    TabOrder = 2
    OnClick = btn3Click
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 520
    Width = 225
    Height = 7
    TabOrder = 3
  end
  object worker: TBackgroundWorker
    OnWork = workerWork
    OnWorkComplete = workerWorkComplete
    OnWorkProgress = workerWorkProgress
    OnWorkFeedback = workerWorkFeedback
    Left = 72
    Top = 24
  end
  object DataSource1: TDataSource
    DataSet = mySQLQuery1
    Left = 48
    Top = 144
  end
  object mySQLQuery1: TmySQLQuery
    Database = DM.mySQLDatabase1
    Left = 88
    Top = 144
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 305
    Top = 224
  end
end
