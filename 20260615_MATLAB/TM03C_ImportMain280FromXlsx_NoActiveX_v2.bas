Attribute VB_Name = "TM03C_ImportMain280FromXlsx_NoActiveX"
Option Explicit

' TM03C xlsx importer for B2 robust workbooks.
' No Scripting.Dictionary / No CreateObject version.
' This module only injects inputs into tm rows 226:505.
' It does NOT run Solver, does NOT call the B2 robust macro, and does NOT
' change the B2 robust calculation modules.

Private gLastStep As String

Public Sub TM03C_ImportMain280FromXlsx_NoActiveX()
    Const START_ROW As Long = 226
    Const END_ROW As Long = 505
    Const EXPECTED_N As Long = 280
    Const FORMULA_TEMPLATE_ROW As Long = 88
    Const TM_SHEET As String = "tm"
    Const INPUT_SHEET As String = "input"
    Const TABLE_NAME As String = "テーブル2"

    Dim inputPath As Variant
    Dim oldScreenUpdating As Boolean
    Dim oldEnableEvents As Boolean
    Dim oldDisplayAlerts As Boolean
    Dim oldCalculation As XlCalculation
    Dim errNum As Long
    Dim errDesc As String

    On Error GoTo CleanFail

    gLastStep = "STEP 01: before file picker"
    inputPath = Application.GetOpenFilename( _
        FileFilter:="Excel input (*.xlsx),*.xlsx", _
        Title:="Select TM03C_main280_input_*.xlsx")
    If VarType(inputPath) = vbBoolean Then Exit Sub

    gLastStep = "STEP 02: save application settings"
    oldScreenUpdating = Application.ScreenUpdating
    oldEnableEvents = Application.EnableEvents
    oldDisplayAlerts = Application.DisplayAlerts
    oldCalculation = Application.Calculation

    gLastStep = "STEP 03: change application settings"
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    Application.DisplayAlerts = False
    Application.Calculation = xlCalculationManual

    Dim destWb As Workbook
    Dim inputWb As Workbook
    Dim wsTm As Worksheet
    Dim wsIn As Worksheet

    gLastStep = "STEP 04: resolve destination workbook and tm sheet"
    Set destWb = ThisWorkbook
    Set wsTm = destWb.Worksheets(TM_SHEET)

    gLastStep = "STEP 05: open input workbook"
    Set inputWb = Workbooks.Open(CStr(inputPath), ReadOnly:=True)

    gLastStep = "STEP 06: resolve input sheet"
    Set wsIn = inputWb.Worksheets(INPUT_SHEET)

    Dim lastRow As Long
    gLastStep = "STEP 07: check input row count"
    lastRow = wsIn.Cells(wsIn.Rows.Count, 1).End(xlUp).Row
    If lastRow <> EXPECTED_N + 1 Then
        Err.Raise vbObjectError + 3001, , "Expected 280 input rows plus header, found " & (lastRow - 1)
    End If

    Dim colTargetRow As Long
    gLastStep = "STEP 08: find target_row header"
    colTargetRow = RequireHeaderCol(wsIn, "target_row")

    Dim firstTarget As Long
    Dim lastTarget As Long
    gLastStep = "STEP 09: check target row range"
    firstTarget = CLng(wsIn.Cells(2, colTargetRow).Value)
    lastTarget = CLng(wsIn.Cells(lastRow, colTargetRow).Value)
    If firstTarget <> START_ROW Or lastTarget <> END_ROW Then
        Err.Raise vbObjectError + 3002, , "target_row must run from 226 to 505. Found " & firstTarget & " to " & lastTarget
    End If

    Dim lastCol As Long
    Dim data As Variant
    gLastStep = "STEP 10: read input data array"
    lastCol = wsIn.Cells(1, wsIn.Columns.Count).End(xlToLeft).Column
    data = wsIn.Range(wsIn.Cells(2, 1), wsIn.Cells(lastRow, lastCol)).Value2

    Dim r As Long
    gLastStep = "STEP 11: copy formula/template row to target rows"
    For r = START_ROW To END_ROW
        wsTm.Range("A" & FORMULA_TEMPLATE_ROW & ":BR" & FORMULA_TEMPLATE_ROW).Copy Destination:=wsTm.Range("A" & r & ":BR" & r)
    Next r
    Application.CutCopyMode = False

    gLastStep = "STEP 12: write input columns"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "A", data, "A_No_TableNo"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "B", data, "B_P"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "M", data, "M_No"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "N", data, "N_G"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "Q", data, "Q_DH"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "R", data, "R_L_DNB"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "S", data, "S_q_in_seed"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "T", data, "T_Tin"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "V", data, "V_f"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "X", data, "X_f_seed"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "AC", data, "AC_Tw_seed"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "AG", data, "AG_y_star_seed"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "AP", data, "AP_UB_seed"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "BE", data, "BE_q_M"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "BG", data, "BG_F_form"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "BH", data, "BH_x_Mes"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "BI", data, "BI_A_corr"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "BJ", data, "BJ_sigma_corr"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "BK", data, "BK_Fcorr"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "BQ", data, "BQ_F2"
    WriteInputColumn wsTm, wsIn, START_ROW, END_ROW, "BR", data, "BR_L"

    Dim tableRange As String
    gLastStep = "STEP 13: resize テーブル2"
    tableRange = ResizeTable2(wsTm, TABLE_NAME, END_ROW)

    gLastStep = "STEP 14: close input workbook"
    inputWb.Close SaveChanges:=False

    gLastStep = "STEP 15: restore application settings"
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
    errNum = Err.Number
    errDesc = Err.Description

    On Error Resume Next
    If Not inputWb Is Nothing Then inputWb.Close SaveChanges:=False
    Application.Calculation = oldCalculation
    Application.DisplayAlerts = oldDisplayAlerts
    Application.EnableEvents = oldEnableEvents
    Application.ScreenUpdating = oldScreenUpdating

    MsgBox "TM03C main280 import failed:" & vbCrLf & _
           "Err " & CStr(errNum) & ": " & errDesc & vbCrLf & _
           "lastStep=" & gLastStep, _
           vbCritical, "TM03C Import Main280"
End Sub

Private Function HeaderCol(ByVal ws As Worksheet, ByVal headerName As String) As Long
    Dim lastCol As Long
    Dim c As Long
    Dim key As String

    lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
    For c = 1 To lastCol
        key = Trim$(CStr(ws.Cells(1, c).Value))
        If StrComp(key, headerName, vbTextCompare) = 0 Then
            HeaderCol = c
            Exit Function
        End If
    Next c

    HeaderCol = 0
End Function

Private Function RequireHeaderCol(ByVal ws As Worksheet, ByVal headerName As String) As Long
    Dim c As Long
    c = HeaderCol(ws, headerName)
    If c <= 0 Then
        Err.Raise vbObjectError + 3100, , "Missing input header: " & headerName
    End If
    RequireHeaderCol = c
End Function

Private Sub WriteInputColumn(ByVal wsTm As Worksheet, ByVal wsIn As Worksheet, _
                             ByVal startRow As Long, ByVal endRow As Long, _
                             ByVal tmColumn As String, ByRef data As Variant, _
                             ByVal inputHeader As String)
    Dim sourceCol As Long
    sourceCol = RequireHeaderCol(wsIn, inputHeader)

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
