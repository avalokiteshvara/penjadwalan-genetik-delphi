object FrmMain: TFrmMain
  Left = 415
  Top = 122
  Width = 766
  Height = 480
  Caption = 'FrmMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu1: TMainMenu
    Left = 463
    Top = 80
    object Aplikasi1: TMenuItem
      Caption = 'Aplikasi'
      object Keluar1: TMenuItem
        Caption = 'Keluar'
        OnClick = Keluar1Click
      end
    end
    object Data1: TMenuItem
      Caption = 'Data'
      object Dosen1: TMenuItem
        Caption = 'Dosen'
        OnClick = Dosen1Click
      end
      object MataKuliah1: TMenuItem
        Caption = 'Mata Kuliah'
        OnClick = MataKuliah1Click
      end
      object Ruang1: TMenuItem
        Caption = 'Ruang'
        OnClick = Ruang1Click
      end
      object HariJam1: TMenuItem
        Caption = 'Hari && Jam'
        OnClick = HariJam1Click
      end
      object WaktuTidakBersedia1: TMenuItem
        Caption = 'Waktu Tidak Bersedia'
        OnClick = WaktuTidakBersedia1Click
      end
    end
    object Pengampu1: TMenuItem
      Caption = 'Pengampu'
      OnClick = Pengampu1Click
    end
    object ProsesPenjadwalan1: TMenuItem
      Caption = 'Proses Penjadwalan'
      OnClick = ProsesPenjadwalan1Click
    end
  end
end
