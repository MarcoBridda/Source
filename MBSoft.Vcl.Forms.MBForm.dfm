object MBForm: TMBForm
  Left = 0
  Top = 0
  Caption = 'MBForm'
  ClientHeight = 281
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object TrayIcon: TTrayIcon
    OnDblClick = TrayIconDblClick
    Left = 40
    Top = 24
  end
  object AppEvents: TApplicationEvents
    OnIdle = AppEventsIdle
    OnMinimize = AppEventsMinimize
    Left = 40
    Top = 96
  end
end
