object main: Tmain
  Left = 319
  Top = 107
  Width = 535
  Height = 481
  Caption = 'DBSlim-SL - Demo 1.0'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = b_initializeClick
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 13
    Top = 15
    Width = 497
    Height = 153
    ColCount = 4
    DefaultRowHeight = 21
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    TabOrder = 0
    OnClick = StringGrid1Click
    ColWidths = (
      117
      131
      88
      154)
  end
  object GroupBox1: TGroupBox
    Left = 13
    Top = 209
    Width = 497
    Height = 105
    Caption = ' Insert Data '
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 21
      Width = 45
      Height = 13
      Caption = 'Firstname'
    end
    object Label2: TLabel
      Left = 135
      Top = 21
      Width = 46
      Height = 13
      Caption = 'Lastname'
    end
    object Label3: TLabel
      Left = 257
      Top = 21
      Width = 42
      Height = 13
      Caption = 'Birthdate'
    end
    object Label4: TLabel
      Left = 351
      Top = 21
      Width = 36
      Height = 13
      Caption = 'Telefon'
    end
    object b_insert: TButton
      Left = 8
      Top = 62
      Width = 105
      Height = 25
      Caption = 'Insert'
      TabOrder = 0
      OnClick = b_insertClick
    end
    object firstname: TEdit
      Left = 8
      Top = 34
      Width = 105
      Height = 21
      TabOrder = 1
    end
    object lastname: TEdit
      Left = 135
      Top = 34
      Width = 105
      Height = 21
      TabOrder = 2
    end
    object birthdate: TEdit
      Left = 256
      Top = 34
      Width = 89
      Height = 21
      TabOrder = 3
      Text = '2006-12-31'
    end
    object telefon: TEdit
      Left = 352
      Top = 34
      Width = 137
      Height = 21
      TabOrder = 4
    end
  end
  object b_delete: TButton
    Left = 21
    Top = 174
    Width = 105
    Height = 25
    Caption = 'Delete Data'
    TabOrder = 2
    OnClick = b_deleteClick
  end
  object GroupBox2: TGroupBox
    Left = 13
    Top = 321
    Width = 497
    Height = 104
    Caption = ' Connection Details '
    TabOrder = 3
    Visible = False
    object Label5: TLabel
      Left = 8
      Top = 21
      Width = 22
      Height = 13
      Caption = 'Host'
    end
    object Label6: TLabel
      Left = 135
      Top = 21
      Width = 46
      Height = 13
      Caption = 'Database'
    end
    object Label7: TLabel
      Left = 257
      Top = 21
      Width = 22
      Height = 13
      Caption = 'User'
    end
    object Label8: TLabel
      Left = 351
      Top = 21
      Width = 46
      Height = 13
      Caption = 'Password'
    end
    object e_host: TEdit
      Left = 8
      Top = 34
      Width = 105
      Height = 21
      TabOrder = 0
      Text = '<database-host>'
    end
    object e_database: TEdit
      Left = 135
      Top = 34
      Width = 105
      Height = 21
      TabOrder = 1
      Text = 'demo'
    end
    object e_user: TEdit
      Left = 256
      Top = 34
      Width = 89
      Height = 21
      TabOrder = 2
      Text = '<database user>'
    end
    object e_password: TEdit
      Left = 352
      Top = 34
      Width = 137
      Height = 21
      TabOrder = 3
      Text = '<your password>'
    end
    object b_initialize: TButton
      Left = 8
      Top = 62
      Width = 105
      Height = 25
      Caption = 'Initialize'
      TabOrder = 4
      OnClick = b_initializeClick
    end
  end
end
