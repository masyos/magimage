object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 300
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 337
    Height = 281
    Align = alClient
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 281
    Width = 337
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitLeft = 56
    ExplicitTop = 264
    ExplicitWidth = 0
  end
  object MainMenu1: TMainMenu
    Left = 56
    Top = 48
    object File1: TMenuItem
      Caption = #12501#12449#12452#12523'(&F)'
      object Open1: TMenuItem
        Caption = #38283#12367'(&O)...'
        OnClick = Open1Click
      end
      object SaveAs1: TMenuItem
        Caption = #21517#21069#12434#20184#12369#12390#20445#23384'(&A)...'
        OnClick = SaveAs1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = #32066#20102'(&X)'
        OnClick = Exit1Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 152
    Top = 152
  end
  object SaveDialog1: TSaveDialog
    Left = 136
    Top = 216
  end
end
