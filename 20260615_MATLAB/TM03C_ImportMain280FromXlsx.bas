Attribute VB_Name = "TM03C_ImportMain280FromXlsx"
Option Explicit

' TM03C xlsx importer for B2 robust workbooks.
' This module only injects inputs into tm rows 226:505.
' It does NOT run Solver, does NOT call the B2 robust macro, and does NOT
' change the B2 robust calculation modules.

Public Sub TM03C_ImportMain280FromXlsx()
    Const START_ROW As Long = 226
    Const END_ROW As Long = 505
    Const EXPECTED_N As Long = 280
    Const FORMULA_TEMPLATE_ROW As Long = 88
    Const TM_SHEET As String = "tm"
    Const INPUT_SHEET As String = "input"
    Const TABLE_NAME As String = "テーブル2"

    Dim inputPath As Variant
    inputPath = Application.GetOpenFilename( _
        FileFilter:="Excel input (*.xlsx),*.xlsx", _
        Title:="Select TM03C_main280_input_*.xlsx")
    If VarType(inputPath) = vbBoolean Then Exit Sub

    Dim oldScreenUpdating As Boolean
    Dim oldEnableEvents As Boolean
    Dim oldDisplayAlerts As Boolean
    Dim oldCalculation As XlCalculation
    oldScreenUpdating = Application.ScreenUpdating
    oldEnableEvents = Application.EnableEvents
    oldDisplayAlerts = Application.DisplayAlerts
    oldCalculation = Application.Calculation

    On Error GoTo CleanFail
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    Application.DisplayAlerts = False
    Application.Calculation = xlCalculationManual

    Dim destWb As Workbook
    Dim inputWb As Workbook
    Dim wsTm As Worksheet
    Dim wsIn As Worksheet
    Set destWb = ThisWorkbook
    Set wsTm = destWb.Worksheets(TM_SHEET)
    Set inputWb = Workbooks.Open(CStr(inputPath), ReadOnly:=True)
    Set wsIn = inputWb.Worksheets(INPUT_SHEET)

    Dim lastRow As Long
    lastRow = wsIn.Cells(wsIn.Rows.Count, 1).End(xlUp).Row
    If lastRow <> EXPECTED_N + 1 Then
        Err.Raise vbObjectError + 3001, , "Expected 280 input rows plus header, found " & (lastRow - 1)
    End If

    Dim headers As Object
    Set headers = HeaderMap(wsIn)

    Dim firstTarget As Long
    Dim lastTarget As Long
    firstTarget = CLng(wsIn.Cells(2, RequireHeader(headers, "target_row")).Value)
    lastTarget = CLng(wsIn.Cells(lastRow, RequireHeader(headers, "target_row")).Value)
    If firstTarget <> START_ROW Or lastTarget <> END_ROW Then
        Err.Raise vbObjectError + 3002, , "target_row must run from 226 to 505. Found " & firstTarget & " to " & lastTarget
    End If

    Dim data As Variant
    data = wsIn.Range(wsIn.Cells(2, 1), wsIn.Cells(lastRow, wsIn.Cells(1, wsIn.Columns.Count).End(xlToLeft).Column)).Value2

    Dim r As Long
    For r = START_ROW To END_ROW
        wsTm.Range("A" & FORMULA_TEMPLATE_ROW & ":BR" & FORMULA_TEMPLATE_ROW).Copy Destination:=wsTm.Range("A" & r & ":BR" & r)
    Next r
    Application.CutCopyMode = False

    WriteInputColumn wsTm, START_ROW, END_ROW, "A", data, headers, "A_No_TableNo"
    WriteInputColumn wsTm, START_ROW, END_ROW, "B", data, headers, "B_P"
    WriteInputColumn wsTm, START_ROW, END_ROW, "M", data, headers, "M_No"
    WriteInputColumn wsTm, START_ROW, END_ROW, "N", data, headers, "N_G"
    WriteInputColumn wsTm, START_ROW, END_ROW, "Q", data, headers, "Q_DH"
    WriteInputColumn wsTm, START_ROW, END_ROW, "R", data, headers, "R_L_DNB"
    WriteInputColumn wsTm, START_ROW, END_ROW, "S", data, headers, "S_q_in_seed"
    WriteInputColumn wsTm, START_ROW, END_ROW, "T", data, headers, "T_Tin"
    WriteInputColumn wsTm, START_ROW, END_ROW, "V", data, headers, "V_f"
    WriteInputColumn wsTm, START_ROW, END_ROW, "X", data, headers, "X_f_seed"
    WriteInputColumn wsTm, START_ROW, END_ROW, "AC", data, headers, "AC_Tw_seed"
    WriteInputColumn wsTm, START_ROW, END_ROW, "AG", data, headers, "AG_y_star_seed"
    WriteInputColumn wsTm, START_ROW, END_ROW, "AP", data, headers, "AP_UB_seed"
    WriteInputColumn wsTm, START_ROW, END_ROW, "BE", data, headers, "BE_q_M"
    WriteInputColumn wsTm, START_ROW, END_ROW, "BG", data, headers, "BG_F_form"
    WriteInputColumn wsTm, START_ROW, END_ROW, "BH", data, headers, "BH_x_Mes"
    WriteInputColumn wsTm, START_ROW, END_ROW, "BI", data, headers, "BI_A_corr"
    WriteInputColumn wsTm, START_ROW, END_ROW, "BJ", data, headers, "BJ_sigma_corr"
    WriteInputColumn wsTm, START_ROW, END_ROW, "BK", data, headers, "BK_Fcorr"
    WriteInputColumn wsTm, START_ROW, END_ROW, "BQ", data, headers, "BQ_F2"
    WriteInputColumn wsTm, START_ROW, END_ROW, "BR", data, headers, "BR_L"

    Dim tableRange As String
    tableRange = ResizeTable2(wsTm, TABLE_NAME, END_ROW)

    inputWb.Close SaveChanges:=False
    Application.Calculation = oldCalculation
    Application.DisplayAlerts = oldDisplayAlerts
    Application.EnableEvents = oldEnableEvents
    Application.ScreenUpdating = oldScreenUpdating

    Dim msg As String
    msg = "TM03C main280 input import complete." & vbCrLf & _
          "Rows: " & START_ROW & "-" & END_ROW & vbCrLf & _
          "Count: " & EXPECTED_N & vbCrLf & _
          "Table range: " & tableRange & vbCrLf & _
          "Solver was not run. Run AdjustSValue_BracketRobust_TM03B2 by batch next."
    Debug.Print msg
    MsgBox msg, vbInformation, "TM03C Import Main280"
    Exit Sub

CleanFail:
    On Error Resume Next
    If Not inputWb Is Nothing Then inputWb.Close SaveChanges:=False
    Application.Calculation = oldCalculation
    Application.DisplayAlerts = oldDisplayAlerts
    Application.EnableEvents = oldEnableEvents
    Application.ScreenUpdating = oldScreenUpdating
    MsgBox "TM03C main280 import failed: " & Err.Description, vbCritical, "TM03C Import Main280"
End Sub

Private Function HeaderMap(ByVal ws As Worksheet) As Object
    Dim d As Object
    Set d = CreateObject("Scripting.Dictionary")
    d.CompareMode = vbTextCompare

    Dim lastCol As Long
    lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column

    Dim c As Long
    Dim key As String
    For c = 1 To lastCol
        key = Trim$(CStr(ws.Cells(1, c).Value))
        If Len(key) > 0 Then d(key) = c
    Next c
    Set HeaderMap = d
End Function

Private Function RequireHeader(ByVal headers As Object, ByVal headerName As String) As Long
    If Not headers.Exists(headerName) Then
        Err.Raise vbObjectError + 3100, , "Missing input header: " & headerName
    End If
    RequireHeader = CLng(headers(headerName))
End Function

Private Sub WriteInputColumn(ByVal wsTm As Worksheet, ByVal startRow As Long, ByVal endRow As Long, _
                             ByVal tmColumn As String, ByRef data As Variant, ByVal headers As Object, _
                             ByVal inputHeader As String)
    Dim sourceCol As Long
    sourceCol = RequireHeader(headers, inputHeader)

    Dim n As Long
    n = endRow - startRow + 1

    Dim outArr() As Variant
    ReDim outArr(1 To n, 1 To 1)

    Dim i As Long
    For i = 1 To n
        outArr(i, 1) = data(i, sourceCol)
    Next i

    wsTm.Range(tmColumn & startRow & ":" & tmColumn & endRow).Value = outArr
End Sub

Private Function ResizeTable2(ByVal wsTm As Worksheet, ByVal tableName As String, ByVal endRow As Long) As String
    Dim lo As ListObject
    Set lo = wsTm.ListObjects(tableName)
    lo.Resize wsTm.Range("A1:BR" & endRow)
    ResizeTable2 = lo.Range.Address(False, False)
End Function
