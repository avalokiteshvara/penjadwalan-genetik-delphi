object MainForm: TMainForm
  Left = 375
  Top = 251
  AutoScroll = False
  Caption = 'Thumbnail Viewer'
  ClientHeight = 334
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 14
  object Toolbar: TPanel
    Left = 0
    Top = 0
    Width = 497
    Height = 30
    Align = alTop
    TabOrder = 0
    DesignSize = (
      497
      30)
    object lblFolder: TLabel
      Left = 8
      Top = 8
      Width = 33
      Height = 14
      Caption = 'Folder:'
    end
    object edFolder: TEdit
      Left = 46
      Top = 4
      Width = 372
      Height = 22
      TabStop = False
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 0
    end
    object btnBrowse: TButton
      Left = 420
      Top = 3
      Width = 71
      Height = 22
      Anchors = [akTop, akRight]
      Caption = 'Browse...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 315
    Width = 497
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object lbThumbnails: TListBox
    Left = 0
    Top = 30
    Width = 497
    Height = 285
    Style = lbOwnerDrawFixed
    Align = alClient
    BorderStyle = bsNone
    ItemHeight = 16
    TabOrder = 2
    OnDblClick = lbThumbnailsDblClick
    OnDrawItem = lbThumbnailsDrawItem
  end
  object BackgroundWorker: TBackgroundWorker
    OnWork = BackgroundWorkerWork
    OnWorkComplete = BackgroundWorkerWorkComplete
    OnWorkFeedback = BackgroundWorkerWorkFeedback
    Left = 64
    Top = 64
  end
end
