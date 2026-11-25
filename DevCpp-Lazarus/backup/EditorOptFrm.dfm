object EditorOptForm: TEditorOptForm
  Left = 585
  Top = 165
  BorderStyle = bsDialog
  Caption = 'Editor Options'
  ClientHeight = 492
  ClientWidth = 482
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    482
    492)
  PixelsPerInch = 96
  TextHeight = 17
  object PagesMain: TPageControl
    Left = -1
    Top = -1
    Width = 482
    Height = 455
    ActivePage = tabGeneral
    TabOrder = 0
    OnChange = PagesMainChange
    object tabGeneral: TTabSheet
      Caption = 'General'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      object grpEditorOpts: TGroupBox
        Left = 3
        Top = 3
        Width = 468
        Height = 271
        Caption = '  Editor Options  '
        TabOrder = 0
        object cbFunctionHint: TCheckBox
          Left = 252
          Top = 214
          Width = 213
          Height = 17
          Caption = 'Show function hints'
          TabOrder = 15
        end
        object cbTrimTrailingSpaces: TCheckBox
          Left = 252
          Top = 232
          Width = 213
          Height = 36
          Caption = 'Trim Trailing Spaces'
          TabOrder = 7
        end
        object cbAutoIndent: TCheckBox
          Left = 14
          Top = 26
          Width = 209
          Height = 21
          Caption = 'Auto Indent'
          TabOrder = 0
        end
        object cbAddIndent: TCheckBox
          Left = 14
          Top = 53
          Width = 209
          Height = 22
          Caption = 'Add indent to {} and :'
          TabOrder = 2
        end
        object cbDropFiles: TCheckBox
          Left = 14
          Top = 159
          Width = 248
          Height = 17
          Caption = 'Insert Dropped Files'
          TabOrder = 5
        end
        object cbEHomeKey: TCheckBox
          Left = 252
          Top = 30
          Width = 200
          Height = 17
          Caption = 'Enhance home key'
          TabOrder = 8
        end
        object cbInsertMode: TCheckBox
          Left = 14
          Top = 82
          Width = 209
          Height = 17
          Caption = 'Insert Mode'
          TabOrder = 1
        end
        object cbParserHints: TCheckBox
          Left = 252
          Top = 186
          Width = 213
          Height = 17
          Caption = 'Show editor hints'
          TabOrder = 14
        end
        object cbHalfPage: TCheckBox
          Left = 252
          Top = 127
          Width = 213
          Height = 29
          Caption = 'Half Page Scrolling'
          TabOrder = 12
        end
        object cbGroupUndo: TCheckBox
          Left = 14
          Top = 133
          Width = 209
          Height = 17
          Caption = 'Group Undo'
          TabOrder = 4
        end
        object cbFindText: TCheckBox
          Left = 14
          Top = 108
          Width = 233
          Height = 19
          Caption = 'Find Text at Cursor'
          TabOrder = 3
        end
        object cbPastEOL: TCheckBox
          Left = 253
          Top = 80
          Width = 200
          Height = 17
          Caption = 'Cursor Past EOL'
          TabOrder = 10
        end
        object cbPastEOF: TCheckBox
          Left = 253
          Top = 54
          Width = 200
          Height = 17
          Caption = 'Cursor Past EOF'
          TabOrder = 9
        end
        object cbScrollHint: TCheckBox
          Left = 253
          Top = 159
          Width = 200
          Height = 17
          Caption = 'Scroll Hint'
          TabOrder = 13
        end
        object cbSmartScroll: TCheckBox
          Left = 253
          Top = 106
          Width = 212
          Height = 17
          Caption = 'Scollbars on need'
          TabOrder = 11
        end
        object cbSpecialChars: TCheckBox
          Left = 14
          Top = 186
          Width = 232
          Height = 17
          Caption = 'Show Special Line Chars'
          TabOrder = 6
        end
        object cbUseCodeFold: TCheckBox
          Left = 14
          Top = 212
          Width = 232
          Height = 22
          Caption = 'Show Code Folding on Gutter'
          TabOrder = 16
          OnClick = cbUseCodeFoldClick
        end
        object cbClickCodeFold: TCheckBox
          Left = 30
          Top = 239
          Width = 204
          Height = 17
          Caption = 'Click to Fold/Unfold Code'
          TabOrder = 17
        end
      end
      object grpCaret: TGroupBox
        Left = 3
        Top = 280
        Width = 271
        Height = 124
        Caption = '  Caret  '
        TabOrder = 1
        object lblInsertCaret: TLabel
          Left = 14
          Top = 24
          Width = 80
          Height = 21
          Caption = 'Insert caret:'
        end
        object lblOverCaret: TLabel
          Left = 14
          Top = 55
          Width = 110
          Height = 21
          Caption = 'Overwrite caret:'
        end
        object cboInsertCaret: TComboBox
          Left = 145
          Top = 17
          Width = 117
          Height = 29
          Style = csDropDownList
          TabOrder = 0
          Items.Strings = (
            'Vertical Line'
            'Horizontal Line'
            'Half Block'
            'Block')
        end
        object cboOverwriteCaret: TComboBox
          Left = 145
          Top = 52
          Width = 117
          Height = 29
          Style = csDropDownList
          TabOrder = 1
          Items.Strings = (
            'Vertical Line'
            'Horizontal Line'
            'Half Block'
            'Block')
        end
        object cbMatch: TCheckBox
          Left = 14
          Top = 91
          Width = 229
          Height = 21
          Caption = 'Highlight matching symbols'
          TabOrder = 2
        end
      end
      object grpTabs: TGroupBox
        Left = 280
        Top = 280
        Width = 191
        Height = 124
        Caption = '  Tabs  '
        TabOrder = 2
        object lblTabSize: TLabel
          Left = 22
          Top = 87
          Width = 60
          Height = 21
          Caption = 'Tab Size:'
        end
        object seTabSize: TSpinEdit
          Left = 96
          Top = 87
          Width = 57
          Height = 31
          MaxValue = 64
          MinValue = 0
          TabOrder = 2
          Value = 0
        end
        object cbUseTabs: TCheckBox
          Left = 16
          Top = 28
          Width = 169
          Height = 17
          Caption = 'Use Tab Character'
          TabOrder = 0
        end
        object cbSmartTabs: TCheckBox
          Left = 16
          Top = 51
          Width = 172
          Height = 30
          Caption = 'Smart Tab indent'
          TabOrder = 1
        end
      end
    end
    object tabDisplay: TTabSheet
      Caption = 'Fonts'
      object ScrollHint: TLabel
        Left = 3
        Top = 121
        Width = 473
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 
          'It is also possible to edit text size by using Control+Scroll, j' +
          'ust like in browsers!'
        WordWrap = True
      end
      object grpGutter: TGroupBox
        Left = 3
        Top = 156
        Width = 462
        Height = 185
        Caption = '  Gutter  '
        TabOrder = 1
        DesignSize = (
          462
          185)
        object lblGutterFont: TLabel
          Left = 12
          Top = 95
          Width = 133
          Height = 22
          Anchors = [akLeft, akRight, akBottom]
          AutoSize = False
          Caption = 'Font:'
        end
        object lblGutterWidth: TLabel
          Left = 364
          Top = 24
          Width = 95
          Height = 25
          Anchors = [akLeft, akRight, akBottom]
          AutoSize = False
          Caption = 'Gutter Width'
          WordWrap = True
        end
        object lblGutterFontSize: TLabel
          Left = 368
          Top = 95
          Width = 78
          Height = 25
          Anchors = [akLeft, akRight, akBottom]
          AutoSize = False
          Caption = 'Size'
        end
        object cbLeadZero: TCheckBox
          Left = 175
          Top = 66
          Width = 162
          Height = 23
          Caption = 'Show Leading Zeros'
          TabOrder = 5
        end
        object cbFirstZero: TCheckBox
          Left = 175
          Top = 46
          Width = 162
          Height = 14
          Caption = 'Start at Zero'
          TabOrder = 4
        end
        object cbLineNum: TCheckBox
          Left = 175
          Top = 24
          Width = 162
          Height = 16
          Caption = 'Show Line Numbers'
          TabOrder = 3
          OnClick = cbLineNumClick
        end
        object cbGutterVis: TCheckBox
          Left = 12
          Top = 25
          Width = 145
          Height = 15
          Caption = 'Visible'
          TabOrder = 0
        end
        object cbGutterAuto: TCheckBox
          Left = 12
          Top = 46
          Width = 145
          Height = 15
          Caption = 'Auto Size'
          TabOrder = 1
        end
        object cbGutterFnt: TCheckBox
          Left = 12
          Top = 70
          Width = 145
          Height = 15
          Caption = 'Use Custom Font'
          TabOrder = 2
          OnClick = cbGutterFntClick
        end
        object cboGutterFont: TComboBox
          Left = 12
          Top = 119
          Width = 341
          Height = 66
          AutoComplete = False
          Style = csOwnerDrawVariable
          ItemHeight = 60
          Sorted = True
          TabOrder = 6
          OnDrawItem = cboGutterFontDrawItem
        end
        object edGutterSize: TSpinEdit
          Left = 366
          Top = 119
          Width = 80
          Height = 27
          MaxValue = 999
          MinValue = 1
          TabOrder = 7
          Value = 10
          OnChange = edGutterSizeChange
        end
        object edGutterWidth: TSpinEdit
          Left = 364
          Top = 49
          Width = 80
          Height = 27
          MaxValue = 999
          MinValue = 1
          TabOrder = 8
          Value = 32
        end
      end
      object grpEditorFont: TGroupBox
        Left = 9
        Top = 3
        Width = 456
        Height = 118
        Caption = ' Editor'
        TabOrder = 0
        object lblEditorSize: TLabel
          Left = 359
          Top = 20
          Width = 26
          Height = 17
          Caption = 'Size:'
        end
        object lblEditorFont: TLabel
          Left = 12
          Top = 20
          Width = 73
          Height = 25
          AutoSize = False
          Caption = 'Font:'
        end
        object cboEditorFont: TComboBox
          Left = 12
          Top = 46
          Width = 341
          Height = 66
          AutoComplete = False
          Style = csOwnerDrawVariable
          ItemHeight = 60
          Sorted = True
          TabOrder = 0
          OnChange = cboEditorFontChange
          OnDrawItem = cboEditorFontDrawItem
        end
        object edEditorSize: TSpinEdit
          Left = 359
          Top = 46
          Width = 80
          Height = 27
          MaxValue = 999
          MinValue = 1
          TabOrder = 1
          Value = 10
          OnChange = edEditorSizeChange
        end
      end
      object grpMargin: TGroupBox
        Left = 3
        Top = 347
        Width = 462
        Height = 62
        Caption = '  Right Margin  '
        TabOrder = 2
        object lblMarginWidth: TLabel
          Left = 163
          Top = 29
          Width = 55
          Height = 60
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Width'
        end
        object lblMarginColor: TLabel
          Left = 305
          Top = 29
          Width = 48
          Height = 28
          AutoSize = False
          Caption = 'Color'
        end
        object cpMarginColor: TColorBox
          Left = 357
          Top = 28
          Width = 97
          Height = 22
          DefaultColorColor = cl3DLight
          Style = [cbStandardColors, cbCustomColor, cbPrettyNames]
          TabOrder = 0
        end
        object edMarginWidth: TSpinEdit
          Left = 229
          Top = 26
          Width = 60
          Height = 27
          MaxValue = 0
          MinValue = 0
          TabOrder = 1
          Value = 0
        end
        object cbMarginVis: TCheckBox
          Left = 12
          Top = 32
          Width = 145
          Height = 17
          Caption = 'Show  Right Margin'
          TabOrder = 2
        end
      end
    end
    object tabSyntax: TTabSheet
      Caption = 'Colors'
      object lblForeground: TLabel
        Left = 13
        Top = 225
        Width = 72
        Height = 17
        Caption = 'Foreground:'
      end
      object lblBackground: TLabel
        Left = 13
        Top = 278
        Width = 72
        Height = 17
        Caption = 'Background:'
      end
      object lblSpeed: TLabel
        Left = 18
        Top = 3
        Width = 120
        Height = 17
        Caption = 'Color Speed Setting:'
      end
      object btnSaveSyntax: TSpeedButton
        Left = 18
        Top = 28
        Width = 23
        Height = 23
        Hint = 'Save color theme'
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000012170000121700000000000000000000B5B5B6737274
          BEBEBEE2E2E2E9EAEAEBEBEBEEEFEFEEEEEEECECECECECECECECECEBEBEBE8E8
          E8E7E7E7E9E9E9F4F4F4C2C1C288878A83828243403F5A57579696968B8A8A8D
          8D8C9595959595959797979190904D48473C3735393534858382FFFFFFB8B6B6
          A3A09F7C78774642417E7D7C2C252345403E9191919191919292928C8C8C2E27
          25140D0B140C0A6F6B6AFFFFFFA5A3A2403B38B2AFAE9D9B9B6E6C6C231A1746
          403E9F9F9F9F9F9FA0A0A09897973B3432221A17231A17797473FFFFFFAAA7A6
          180F0C4E4745B8B5B49A98972C25234B4543ACACACACACACADADADA3A2A2423B
          39271F1C231B187A7573FFFFFFAEAAA9261E1A261E1A676361CDCCCC8582805B
          5755ADADADB6B6B6B8B8B8AEADAD47403D29211D271F1C7D7876FFFFFFAFACAB
          2D24212F2723342B28625B59A3A1A08785845C56555A52505B5351544D4A352C
          292E2522312925807B79FFFFFFB0ADAC3329265D534F6C625D665C5788817DAB
          A8A7777372564E4A69605A6B615C6F65605D534F382E2A837D7BFFFFFFB1ADAC
          3D322EBCB0A9E7DDD5E0D5CDDCD2CACFC8C2B6B3B29D9A99B6AFA9DFD5CDE9DF
          D7B3A9A23D3330857F7DFFFFFFB2AEAD433935C3B8B1EAE2DBE3DBD4E3DBD4E3
          DAD4D5CDC8B7B5B49B9897BDB6B1F0E6E0BBB1AB443A37888280FFFFFFB4B0AF
          483E3AC7BEB8EFE8E3E8E1DCE8E1DCE9E2DCEBE3DDD1CCC8C6C5C5BEBCBBE4DD
          D8C1B8B34A3F3B8B8582FFFFFFB6B2B04D433FCCC4BFF5F0ECEEE9E5EEE9E5EE
          E9E5EEE9E5EDE7E3E9E5E1D2CFCEE0DCD8C7BFBA4F44408D8785FFFFFFB7B4B2
          514743D2CBC7FBF7F5F4F0EEF4F0EEF4F0EEF4F0EEF5F1EEF6F2EFF3EFEDFBF7
          F5C9C3BF544945908A88FFFFFFB8B4B3564B47D6D1CEFFFFFFFAF9F8FAF9F8FA
          F9F8FAF9F8FAF9F8FAF8F8FBF9F8FFFFFFCEC9C6564B47918B88FFFFFFC2BEBD
          5A504CDBD6D4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFD3CFCD64595497918FFFFFFFF0EEEECECCCBECEAEAF6F5F5F4F3F3F4F3F3F4
          F3F3F4F3F3F4F3F3F4F3F3F4F3F3F6F5F5EAE9E8D3D0CEE5E4E4}
        ParentShowHint = False
        ShowHint = True
        OnClick = btnSaveSyntaxClick
      end
      object CppEdit: TSynEdit
        Left = 144
        Top = 64
        Width = 329
        Height = 322
        Align = alCustom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        WideFont.Charset = DEFAULT_CHARSET
        WideFont.Color = clWindowText
        WideFont.Height = -11
        WideFont.Name = 'NSimSun'
        WideFont.Style = []
        TabOrder = 3
        CodeFolding.GutterShapeSize = 11
        CodeFolding.CollapsedLineColor = clGrayText
        CodeFolding.FolderBarLinesColor = clGrayText
        CodeFolding.IndentGuidesColor = clGray
        CodeFolding.IndentGuides = True
        CodeFolding.ShowCollapsedLine = False
        CodeFolding.ShowHintMark = True
        UseCodeFolding = False
        ClickCodeFolding = False
        Gutter.AutoSize = True
        Gutter.BorderStyle = gbsNone
        Gutter.DigitCount = 2
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -12
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 4
        Gutter.RightOffset = 21
        Gutter.ShowLineNumbers = True
        Gutter.Width = 32
        Gutter.GradientEndColor = clBackground
        HideSelection = True
        Highlighter = cpp
        Lines.Strings = (
          '/* Sample source code */'
          '#include <stdio.h>'
          ''
          'int main() {'
          '    int i, k, sum, num[20];'
          '    double avrg;'
          '    k = 0;    //comment'
          '    for (i = 0; i < 20; i++) {'
          '        k++;   //active breakpoint'
          '        num[i] = i * i + k;'
          '        sum += num[i];  //breakpoint'
          '    }'
          '    avrg = sum / 20  //error line'
          '    printf("average = %lf", avrg);'
          '    printf("OK!");  //selected text'
          '    return 0;    //current line'
          '}')
        Options = [eoAutoIndent, eoDisableScrollArrows, eoHideShowScrollbars, eoNoCaret, eoNoSelection, eoSmartTabs, eoTrimTrailingSpaces]
        ReadOnly = True
        RightEdge = 0
        ScrollHintFormat = shfTopToBottom
        TabWidth = 4
        WantTabs = True
        OnGutterClick = OnGutterClick
        OnSpecialLineColors = CppEditSpecialLineColors
        OnStatusChange = cppEditStatusChange
        FontSmoothing = fsmNone
        RemovedKeystrokes = <
          item
            Command = ecDeleteLastChar
            ShortCut = 8200
          end
          item
            Command = ecLineBreak
            ShortCut = 8205
          end
          item
            Command = ecContextHelp
            ShortCut = 112
          end>
        AddedKeystrokes = <>
      end
      object ElementList: TListBox
        Left = 8
        Top = 62
        Width = 130
        Height = 157
        ImeName = 'CN'#177'??i(CN'#177'U)'
        IntegralHeight = True
        ItemHeight = 17
        Items.Strings = (
          'Comment'
          'Identifier'
          'Keyword'
          'Number'
          'Background'
          'String'
          'Symbol'
          'WhiteSpace'
          'Directives')
        TabOrder = 0
        OnClick = ElementListClick
      end
      object grpStyle: TGroupBox
        Left = 13
        Top = 331
        Width = 110
        Height = 89
        Caption = '  Style:  '
        TabOrder = 2
        object cbBold: TCheckBox
          Left = 8
          Top = 18
          Width = 100
          Height = 26
          Caption = 'Bold'
          TabOrder = 0
          OnClick = StyleChange
        end
        object cbItalic: TCheckBox
          Left = 8
          Top = 46
          Width = 100
          Height = 17
          Caption = 'Italic'
          TabOrder = 1
          OnClick = StyleChange
        end
        object cbUnderlined: TCheckBox
          Left = 8
          Top = 67
          Width = 100
          Height = 17
          Caption = 'Underlined'
          TabOrder = 2
          OnClick = StyleChange
        end
      end
      object cboQuickColor: TComboBox
        Left = 47
        Top = 26
        Width = 130
        Height = 25
        Style = csDropDownList
        TabOrder = 1
        OnSelect = cboQuickColorSelect
        Items.Strings = (
          'Classic'
          'Classic Plus'
          'Twilight'
          'Ocean'
          'Visual Studio'
          'Borland'
          'Matrix'
          'Obsidian'
          'GSS Hacker'
          'Obvilion'
          'PlasticCodeWrap')
      end
      object edSyntaxExt: TEdit
        Left = 204
        Top = 26
        Width = 264
        Height = 25
        TabOrder = 4
      end
      object cbSyntaxHighlight: TCheckBox
        Left = 204
        Top = 3
        Width = 310
        Height = 20
        Caption = 'Use Syntax Highlighting'
        TabOrder = 5
        OnClick = cbSyntaxHighlightClick
      end
      object cpForeground: TColorBox
        Left = 13
        Top = 250
        Width = 110
        Height = 22
        Style = [cbStandardColors, cbCustomColor, cbPrettyNames]
        TabOrder = 6
        OnChange = StyleChange
      end
      object cpBackground: TColorBox
        Left = 13
        Top = 301
        Width = 110
        Height = 22
        Style = [cbStandardColors, cbCustomColor, cbPrettyNames]
        TabOrder = 7
        OnChange = StyleChange
      end
      object cbHighCurrLine: TCheckBox
        Left = 168
        Top = 386
        Width = 221
        Height = 34
        Caption = 'Highlight Current line'
        TabOrder = 8
      end
    end
    object tabAutosave: TTabSheet
      Caption = 'Auto'
      ImageIndex = 5
      object GroupBox1: TGroupBox
        Left = 3
        Top = 10
        Width = 468
        Height = 90
        TabOrder = 2
        object lblSaveInterval: TLabel
          Left = 292
          Top = 22
          Width = 45
          Height = 17
          Caption = 'Interval:'
        end
        object lblSaveFiles: TLabel
          Left = 14
          Top = 27
          Width = 59
          Height = 17
          Caption = 'Save Files:'
        end
        object lblFileName: TLabel
          Left = 15
          Top = 56
          Width = 58
          Height = 17
          Caption = 'File name:'
        end
        object lblTimeStampExample: TLabel
          Left = 259
          Top = 58
          Width = 52
          Height = 17
          Caption = 'Example:'
        end
        object lblTest: TLabel
          Left = 382
          Top = 58
          Width = 24
          Height = 17
          Caption = 'Test'
          Visible = False
        end
        object seSaveInteval: TSpinEdit
          Left = 363
          Top = 19
          Width = 50
          Height = 27
          MaxValue = 999
          MinValue = 1
          TabOrder = 0
          Value = 10
        end
        object cmbSaveFiles: TComboBox
          Left = 106
          Top = 19
          Width = 147
          Height = 25
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ItemIndex = 0
          ParentFont = False
          TabOrder = 1
          Text = 'Current file'
          Items.Strings = (
            'Current file'
            'All opened files'
            'Whole project')
        end
        object cmbFileName: TComboBox
          Left = 106
          Top = 52
          Width = 147
          Height = 25
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ItemIndex = 0
          ParentFont = False
          TabOrder = 2
          Text = 'Overwrite file'
          OnChange = cmbFileNameChange
          Items.Strings = (
            'Overwrite file'
            'Append UNIX timestamp'
            'Append formatted timestamp')
        end
      end
      object cbAutoSave: TCheckBox
        Left = 17
        Top = 3
        Width = 145
        Height = 18
        Caption = 'Enable autosave'
        TabOrder = 1
        OnClick = cbAutoSaveClick
      end
      object GroupBox2: TGroupBox
        Left = 3
        Top = 116
        Width = 468
        Height = 157
        TabOrder = 3
        object lblCompletionDelay: TLabel
          Left = 15
          Top = 36
          Width = 64
          Height = 17
          Caption = 'Delay (ms):'
        end
        object lblCompletionColor: TLabel
          Left = 14
          Top = 104
          Width = 106
          Height = 17
          Caption = 'Background color:'
        end
        object lblCompletionColor2: TLabel
          Left = 168
          Top = 104
          Width = 61
          Height = 17
          Caption = 'Text color:'
        end
        object lblCompletionColor3: TLabel
          Left = 310
          Top = 104
          Width = 89
          Height = 17
          Caption = 'Highlight color:'
        end
        object seCompletionDelay: TSpinEdit
          Left = 23
          Top = 59
          Width = 56
          Height = 27
          MaxValue = 999
          MinValue = 100
          TabOrder = 0
          Value = 200
        end
        object gbCBEngine: TGroupBox
          Left = 150
          Top = 14
          Width = 304
          Height = 82
          Caption = 'Engine behaviour'
          TabOrder = 1
          object chkCBParseLocalH: TCheckBox
            Left = 8
            Top = 24
            Width = 345
            Height = 21
            Caption = 'Scan #include'#39's local files'
            TabOrder = 0
          end
          object chkCBParseGlobalH: TCheckBox
            Left = 8
            Top = 51
            Width = 345
            Height = 21
            Caption = 'Scan #include'#39's global files '
            TabOrder = 1
          end
        end
        object cpCompletionBackground: TColorBox
          Left = 15
          Top = 127
          Width = 130
          Height = 22
          DefaultColorColor = clWhite
          Style = [cbStandardColors, cbCustomColor, cbPrettyNames]
          TabOrder = 2
        end
        object cpCompletionTextColor: TColorBox
          Left = 168
          Top = 129
          Width = 125
          Height = 22
          DefaultColorColor = clWhite
          Style = [cbStandardColors, cbCustomColor, cbPrettyNames]
          TabOrder = 3
        end
        object cpCompletionHighColor: TColorBox
          Left = 310
          Top = 127
          Width = 123
          Height = 22
          DefaultColorColor = clWhite
          Style = [cbStandardColors, cbCustomColor, cbPrettyNames]
          TabOrder = 4
        end
      end
      object chkEnableCompletion: TCheckBox
        Left = 14
        Top = 106
        Width = 196
        Height = 26
        Caption = 'Enable code-completion'
        TabOrder = 0
        OnClick = chkEnableCompletionClick
      end
      object GroupBox3: TGroupBox
        Left = 3
        Top = 296
        Width = 468
        Height = 113
        TabOrder = 4
        object cbBraces: TCheckBox
          Left = 15
          Top = 16
          Width = 144
          Height = 25
          Caption = 'Braces '#39'{}'#39
          TabOrder = 0
        end
        object cbParenth: TCheckBox
          Left = 169
          Top = 16
          Width = 150
          Height = 25
          Caption = 'Parentheses '#39'()'#39
          TabOrder = 1
        end
        object cbArray: TCheckBox
          Left = 310
          Top = 16
          Width = 157
          Height = 25
          Caption = 'Square braces '#39'[]'#39
          TabOrder = 2
        end
        object cbInclude: TCheckBox
          Left = 14
          Top = 47
          Width = 155
          Height = 25
          Caption = 'Angle brackets '#39'<>'#39
          TabOrder = 3
        end
        object cbSingleQuotes: TCheckBox
          Left = 168
          Top = 50
          Width = 140
          Height = 26
          Caption = 'Single quotes '#39#39#39#39
          TabOrder = 4
        end
        object cbDoubleQuotes: TCheckBox
          Left = 310
          Top = 50
          Width = 161
          Height = 26
          Caption = 'Double quotes '#39'""'#39
          TabOrder = 5
        end
        object cbComments: TCheckBox
          Left = 14
          Top = 78
          Width = 193
          Height = 25
          Caption = 'Multiline comments '#39'/**/'#39
          TabOrder = 6
        end
        object cbDeleteCompleted: TCheckBox
          Left = 237
          Top = 78
          Width = 228
          Height = 25
          Caption = 'Delete symbols as pairs'
          TabOrder = 7
        end
      end
      object cbSymbolComplete: TCheckBox
        Left = 14
        Top = 283
        Width = 203
        Height = 26
        Caption = 'Enable symbol completion'
        TabOrder = 5
        OnClick = cbSymbolCompleteClick
      end
    end
    object tabCPInserts: TTabSheet
      Caption = 'Snippets'
      object lblMacros: TLabel
        Left = 3
        Top = 387
        Width = 47
        Height = 17
        Caption = 'Macros:'
      end
      object btnAdd: TButton
        Left = 210
        Top = 3
        Width = 78
        Height = 24
        Caption = 'Add'
        TabOrder = 0
        OnClick = btnAddClick
      end
      object btnRemove: TButton
        Left = 337
        Top = 3
        Width = 80
        Height = 24
        Caption = 'Remove'
        TabOrder = 1
        OnClick = btnRemoveClick
      end
      object CodeIns: TSynEdit
        Left = -3
        Top = 176
        Width = 469
        Height = 205
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        WideFont.Charset = DEFAULT_CHARSET
        WideFont.Color = clWindowText
        WideFont.Height = -11
        WideFont.Name = 'NSimSun'
        WideFont.Style = []
        TabOrder = 2
        TabStop = False
        CodeFolding.GutterShapeSize = 11
        CodeFolding.CollapsedLineColor = clGrayText
        CodeFolding.FolderBarLinesColor = clGrayText
        CodeFolding.IndentGuidesColor = clGray
        CodeFolding.IndentGuides = True
        CodeFolding.ShowCollapsedLine = False
        CodeFolding.ShowHintMark = True
        UseCodeFolding = False
        ClickCodeFolding = False
        Gutter.AutoSize = True
        Gutter.BorderStyle = gbsNone
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -12
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 4
        Gutter.RightOffset = 21
        Gutter.ShowLineNumbers = True
        Highlighter = cpp
        Options = [eoAutoIndent, eoHideShowScrollbars, eoKeepCaretX, eoSmartTabs, eoTabIndent, eoTrimTrailingSpaces]
        TabWidth = 4
        WantTabs = True
        OnStatusChange = CodeInsStatusChange
        FontSmoothing = fsmNone
        RemovedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 112
          end>
        AddedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 16496
          end>
      end
      object lvCodeIns: TStringGrid
        Left = 3
        Top = 33
        Width = 463
        Height = 137
        ColCount = 3
        DefaultColWidth = 115
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs, goAlwaysShowEditor]
        TabOrder = 3
        OnSelectCell = lvCodeInsSelectCell
        ColWidths = (
          174
          53
          208)
      end
      object Edit1: TEdit
        Left = 85
        Top = 387
        Width = 381
        Height = 25
        TabOrder = 4
        Text = 
          '$PROGRAM$, $COPYRIGHT$, $AUTHOR$, $DATETIME$, $DESCRIPTION$, <DA' +
          'TETIME>, *|*'
      end
    end
    object tabCPDefault: TTabSheet
      Caption = 'Default Insert'
      object cbDefaultCode: TCheckBox
        Left = 10
        Top = 3
        Width = 447
        Height = 30
        Caption = 'Insert Default Code into Empty Projects'
        TabOrder = 0
      end
      object seDefault: TSynEdit
        Left = 3
        Top = 39
        Width = 468
        Height = 370
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        WideFont.Charset = DEFAULT_CHARSET
        WideFont.Color = clWindowText
        WideFont.Height = -11
        WideFont.Name = 'NSimSun'
        WideFont.Style = []
        TabOrder = 1
        TabStop = False
        CodeFolding.GutterShapeSize = 11
        CodeFolding.CollapsedLineColor = clGrayText
        CodeFolding.FolderBarLinesColor = clGrayText
        CodeFolding.IndentGuidesColor = clGray
        CodeFolding.IndentGuides = True
        CodeFolding.ShowCollapsedLine = False
        CodeFolding.ShowHintMark = True
        UseCodeFolding = False
        ClickCodeFolding = False
        Gutter.AutoSize = True
        Gutter.BorderStyle = gbsNone
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -12
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 4
        Gutter.RightOffset = 21
        Gutter.ShowLineNumbers = True
        Highlighter = cpp
        Options = [eoAutoIndent, eoHideShowScrollbars, eoKeepCaretX, eoSmartTabs, eoTabIndent, eoTrimTrailingSpaces]
        TabWidth = 4
        WantTabs = True
        OnStatusChange = CodeInsStatusChange
        FontSmoothing = fsmNone
        RemovedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 112
          end>
        AddedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 16496
          end>
      end
    end
  end
  object btnOk: TBitBtn
    Left = 208
    Top = 460
    Width = 85
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    ModalResult = 1
    NumGlyphs = 2
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TBitBtn
    Left = 298
    Top = 460
    Width = 85
    Height = 25
    Anchors = [akRight, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnHelp: TBitBtn
    Left = 388
    Top = 460
    Width = 85
    Height = 25
    Anchors = [akRight, akBottom]
    Enabled = False
    Kind = bkHelp
    NumGlyphs = 2
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object cpp: TSynCppSyn
    DefaultFilter = 'C++ Files (*.c,*.cpp,*.h,*.hpp)|*.c;*.cpp;*.h;*.hpp'
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 5
    Top = 458
  end
end
