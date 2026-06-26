Attribute VB_Name = "Module6C_TM03B3a"
'==================================================================
' TM03B3a : No ActiveX / NoForm robust runner (Err 429 回避・B1b 12点試験版)
'------------------------------------------------------------------
' TM03B2 (Module6B_TM03B2) の robust bracket 探索を維持しつつ、280点
' 分割実行に耐える運用機能を追加:
'   - Excel 設定の確実な cleanup (エラー終了時も復帰)
'   - 行単位 fail-and-continue (1点失敗で全体停止しない)
'   - 機械判定可能な per-row status (OK / FAIL_* / SKIPPED)
'   - TM03_run_summary シート (1行1レコード)
'   - Log モード切替 (LOG_DETAIL / LOG_SUMMARY_ONLY)
'   - 保存頻度 (SAVE_EVERY_N_ROWS)
'
' 依存(既存を再利用): FindHeaderCol(Module5), CalcWholeRow(Module7),
'                      ws_tm, ws_Log, Solver アドイン。
' 実行: AdjustSValue_RobustRunner_TM03B3a_NoForm を実行する。
'       行範囲は START_ROW=226 / END_ROW=237 に固定。frmRowInput は使わない。
'
' 注意: 旧 Module6 / Module6B_TM03B2 は残す。本モジュールは別名のため
'       衝突しない。内側 Solver / 数式 / UDF / 固定定数 / 物理式は不変。
'==================================================================
Option Explicit

' ===== 運用設定 (TM03B3) =====
Private Const LOG_DETAIL       As Boolean = True    ' True: BRACKET/BISECT 反復を ws_Log に出す
Private Const LOG_SUMMARY_ONLY As Boolean = False   ' True: 詳細 Log を抑制 (summary のみ)
Private Const SAVE_EVERY_N_ROWS As Long = 10        ' N 行ごとに保存 (0=途中保存しない)
Private Const START_ROW As Long = 226                ' TM03B3a B1b 12点固定開始行
Private Const END_ROW   As Long = 237                ' TM03B3a B1b 12点固定終了行

' ===== robust bracket 設定 (TM03B2 から維持) =====
Private Const TOL_PCT       As Double = 1#
Private Const ITER_LIMIT    As Long = 80
Private Const Q_LOW_INIT    As Double = 100000#     ' 1.0e5
Private Const Q_HIGH_INIT   As Double = 12000000#   ' 1.2e7
Private Const Q_HIGH_MAX    As Double = 60000000#   ' 6.0e7
Private Const EXPAND_FACTOR As Double = 1.5
Private Const EXPAND_LIMIT  As Long = 20

' ===== status コード =====
Private Const ST_OK         As String = "OK"
Private Const ST_BRACKET_HI As String = "FAIL_BRACKET_HIGH"
Private Const ST_BRACKET_LO As String = "FAIL_BRACKET_LOW"
Private Const ST_NONPHYS    As String = "FAIL_NONPHYSICAL"
Private Const ST_SOLVER     As String = "FAIL_SOLVER"
Private Const ST_FORMULA    As String = "FAIL_FORMULA"
Private Const ST_RUNTIME    As String = "FAIL_RUNTIME"
Private Const ST_SKIPPED    As String = "SKIPPED"

Private Const SUMMARY_SHEET As String = "TM03_run_summary"
Private Const DEBUG_SHEET   As String = "TM03_debug_trace"

' ===== 1行結果 =====
Private Type TRowResult
    RowNo As Long
    id As String
    status As String
    qM As Double
    qin As Double
    qP As Double
    pm As Double
    dq As Double
    qlow As Double
    qhigh As Double
    nExpand As Long
    nBisect As Long
    sMax As Long
    fFinal As Double
    TwFinal As Double
    yFinal As Double
    UBFinal As Double
    Tsub As Double
    xMes As Double
    Pmpa As Double
    Gv As Double
    DHmm As Double
    Lm As Double
    Fform As Double
    Fcorr As Double
    errMsg As String
    elapsed As Double
    lastStep As String
End Type

' 列番号 (モジュール内共有)
Private cF&, cTw&, cY&, cUB&, cQin&, cDelta&, cQP&, cDqchf&
Private cFb&, cTwb&, cYb&, cUBb&, cPM&, cqM&, cTsub&, cXm&, cP&, cG&, cDH&, cL&, cFform&, cFcorr&
Private gLastStep As String
Private gCurrentRow As Long
Private gTraceReady As Boolean

Public Sub AdjustSValue_RobustRunner_TM03B3a_NoForm()

    Dim ws As Worksheet
    Dim runID As String: runID = Format(Now, "yyyymmdd_hhnnss")
    Dim startRow As Long, endRow As Long, lastRow As Long
    Dim sv_screen As Boolean, sv_events As Boolean, sv_alerts As Boolean
    Dim sv_calc As XlCalculation, sv_displayStatus As Boolean, sv_statusBar As Variant
    Dim okCount As Long, failCount As Long
    Dim r As Long, res As TRowResult, okFlag As Boolean

    On Error GoTo CleanFail

    SetStep "STEP 01: macro entered", 0

    Set ws = ws_tm
    SetStep "STEP 02: workbook/sheets resolved", 0

    ' ---- 列番号 ----
    cF = FindHeaderCol(ws, "f"): cTw = FindHeaderCol(ws, "Tw"): cY = FindHeaderCol(ws, "y_star")
    cUB = FindHeaderCol(ws, "UB"): cQin = FindHeaderCol(ws, "q_in"): cDelta = FindHeaderCol(ws, "delta")
    cQP = FindHeaderCol(ws, "q_P"): cDqchf = FindHeaderCol(ws, "dq_chf")
    cFb = FindHeaderCol(ws, "f_balance"): cTwb = FindHeaderCol(ws, "Tw_balance")
    cYb = FindHeaderCol(ws, "y_star_balance"): cUBb = FindHeaderCol(ws, "UB_balance")
    cPM = FindHeaderCol(ws, "PM_ratio"): cqM = FindHeaderCol(ws, "q_M"): cTsub = FindHeaderCol(ws, "Tsub")
    cXm = FindHeaderCol(ws, "x_Mes"): cP = FindHeaderCol(ws, "P"): cG = FindHeaderCol(ws, "G")
    cDH = FindHeaderCol(ws, "DH"): cL = FindHeaderCol(ws, "L_DNB")
    cFform = FindHeaderCol(ws, "F_form"): cFcorr = FindHeaderCol(ws, "Fcorr")
    SetStep "STEP 03: columns resolved", 0

    startRow = START_ROW
    endRow = END_ROW
    lastRow = ws.Cells(ws.Rows.Count, cDqchf).End(xlUp).Row
    If endRow > lastRow Then endRow = lastRow
    If startRow < 2 Or endRow < startRow Then Err.Raise vbObjectError + 603, , "Invalid fixed row range: " & startRow & "-" & endRow

    ' ---- Excel 設定を保存 ----
    sv_screen = Application.ScreenUpdating
    sv_events = Application.EnableEvents
    sv_alerts = Application.DisplayAlerts
    sv_calc = Application.Calculation
    sv_displayStatus = Application.DisplayStatusBar
    sv_statusBar = Application.StatusBar
    SetStep "STEP 04: app settings saved", 0

    With Application
        .ScreenUpdating = False
        .EnableEvents = False
        .DisplayAlerts = False
        .Calculation = xlCalculationManual
        .DisplayStatusBar = True
    End With
    SetStep "STEP 05: app settings changed", 0

    SetStep "STEP 06: before EnsureSummarySheet", 0
    Call EnsureSummarySheet
    SetStep "STEP 07: after EnsureSummarySheet", 0

    Call EnsureDebugTrace(runID)
    TraceStep runID, gLastStep, 0, "debug trace initialized"

    SetStep "STEP 08: before InitDetailLog", 0
    Call InitDetailLog
    SetStep "STEP 09: after InitDetailLog", 0

    okCount = 0: failCount = 0
    SetStep "STEP 10: before row loop", 0
    For r = startRow To endRow
        Application.StatusBar = "TM03B3a [" & runID & "] 行 " & r & " / " & endRow & _
                                "  (OK=" & okCount & " FAIL=" & failCount & ")"
        SetStep "STEP 11: before ProcessRowSafe", r
        okFlag = ProcessRowSafe(ws, r, res)
        SetStep "STEP 12: after ProcessRowSafe", r
        If Len(res.lastStep) = 0 Then res.lastStep = gLastStep
        Call WriteSummaryRow(runID, res)
        If res.status = ST_OK Then okCount = okCount + 1 Else failCount = failCount + 1
        If SAVE_EVERY_N_ROWS > 0 Then
            If (r - startRow + 1) Mod SAVE_EVERY_N_ROWS = 0 Then ws.Parent.Save
        End If
    Next r

    ws.Parent.Save

    SetStep "STEP 15: before RestoreApp", 0
    Call RestoreApp(sv_screen, sv_events, sv_alerts, sv_calc, sv_displayStatus, sv_statusBar)
    SetStep "STEP 16: normal end", 0
    MsgBox "TM03B3a 完了 [" & runID & "]  rows " & startRow & "-" & endRow & _
           vbCrLf & "OK=" & okCount & "  FAIL=" & failCount & vbCrLf & _
           "TM03_run_summary / TM03_debug_trace を確認してください。", vbInformation
    Exit Sub

CleanFail:
    Dim em As String: em = "Err " & Err.Number & ": " & Err.Description
    On Error Resume Next
    Call RestoreApp(sv_screen, sv_events, sv_alerts, sv_calc, sv_displayStatus, sv_statusBar)
    On Error GoTo 0
    MsgBox "TM03B3a 致命的エラーで中断 [" & runID & "]" & vbCrLf & _
           em & vbCrLf & _
           "lastStep=" & gLastStep & vbCrLf & _
           "currentRow=" & CStr(gCurrentRow), vbCritical
End Sub

'------------------------------------------------------------------
' 1行を安全に処理 (内部で完結。例外を投げず status を返す)
'------------------------------------------------------------------
Private Function ProcessRowSafe(ws As Worksheet, r As Long, ByRef res As TRowResult) As Boolean
    Dim t0 As Double: t0 = Timer
    ' 結果初期化
    res.RowNo = r: res.id = "": res.status = ""
    res.qM = 0: res.qin = 0: res.qP = 0: res.pm = 0: res.dq = 0
    res.qlow = 0: res.qhigh = 0: res.nExpand = 0: res.nBisect = 0: res.sMax = 0
    res.fFinal = 0: res.TwFinal = 0: res.yFinal = 0: res.UBFinal = 0
    res.Tsub = 0: res.xMes = 0: res.Pmpa = 0: res.Gv = 0: res.DHmm = 0: res.Lm = 0
    res.Fform = 0: res.Fcorr = 0: res.errMsg = "": res.elapsed = 0: res.lastStep = gLastStep

    On Error GoTo RowFail

    res.id = CStr(ws.Cells(r, 1).Value)
    If Len(Trim(res.id)) = 0 Then
        res.status = ST_SKIPPED: res.errMsg = "No_TableNo 空"
        res.elapsed = Timer - t0: ProcessRowSafe = False: Exit Function
    End If

    ' ---- f を1回求解 ----
    ws.Cells(r, cF).Value = 0.01
    ws.Cells(r, cY).Value = 0.00001
    ws.Cells(r, cUB).Value = 1#
    Call CalcWholeRow(ws, r)
    Dim sres_f As Long: sres_f = SolveZero(ws, r, cFb, cF)

    Dim qP#, dlt#, ystar#, pm#, isErr As Boolean, physical As Boolean, tooHigh As Boolean, sMax&
    Dim qLow#, qHigh#, dq#
    qLow = Q_LOW_INIT: qHigh = Q_HIGH_INIT

    ' ---- bracket: q_low ----
    Call EvalRowAtQin(ws, r, qLow, qP, dlt, ystar, pm, tooHigh, physical, isErr, sMax)
    If isErr Then GoTo MarkFormula
    dq = DqRatio(qP, qLow)
    If LogOn() Then Call AppendDetail(r, res.id, "BRACKET", 0, qLow, qHigh, qLow, qP, dlt, ystar, pm, dq, sMax)

    If tooHigh Then
        res.status = ST_BRACKET_LO: res.errMsg = "q_low(1e5)で既にtoo_high。root<下限"
        GoTo Finalize
    End If

    ' ---- bracket: q_high + 拡張 ----
    Dim nExp As Long: nExp = 0
    Call EvalRowAtQin(ws, r, qHigh, qP, dlt, ystar, pm, tooHigh, physical, isErr, sMax)
    If isErr Then GoTo MarkFormula
    dq = DqRatio(qP, qHigh)
    If LogOn() Then Call AppendDetail(r, res.id, "BRACKET", 0, qLow, qHigh, qHigh, qP, dlt, ystar, pm, dq, sMax)

    Do While (Not tooHigh) And (qHigh < Q_HIGH_MAX) And (nExp < EXPAND_LIMIT)
        nExp = nExp + 1
        qHigh = MinD(qHigh * EXPAND_FACTOR, Q_HIGH_MAX)
        Call EvalRowAtQin(ws, r, qHigh, qP, dlt, ystar, pm, tooHigh, physical, isErr, sMax)
        If isErr Then GoTo MarkFormula
        dq = DqRatio(qP, qHigh)
        If LogOn() Then Call AppendDetail(r, res.id, "BRACKET", nExp, qLow, qHigh, qHigh, qP, dlt, ystar, pm, dq, sMax)
    Loop
    res.nExpand = nExp

    If Not tooHigh Then
        res.status = ST_BRACKET_HI
        res.errMsg = "Q_HIGH_MAX=" & Format(Q_HIGH_MAX, "0.#E+0") & " でも bracket 不能 (拡張" & nExp & "回)"
        GoTo Finalize
    End If

    ' ---- bisection ----
    Dim it As Long, m#, bestM#, bestDq#, haveBest As Boolean, converged As Boolean, nBis As Long
    bestDq = 1E+300: haveBest = False: converged = False: nBis = 0
    For it = 1 To ITER_LIMIT
        nBis = nBis + 1
        m = (qLow + qHigh) / 2#
        Call EvalRowAtQin(ws, r, m, qP, dlt, ystar, pm, tooHigh, physical, isErr, sMax)
        If isErr Then GoTo MarkFormula
        dq = DqRatio(qP, m)
        If LogOn() Then Call AppendDetail(r, res.id, "BISECT", it, qLow, qHigh, m, qP, dlt, ystar, pm, dq, sMax)
        If physical And (Abs(dq) < Abs(bestDq)) Then
            bestDq = dq: bestM = m: haveBest = True
        End If
        If physical And (Abs(dq) < TOL_PCT) Then converged = True: Exit For
        If tooHigh Then qHigh = m Else qLow = m
    Next it
    res.nBisect = nBis

    ' ---- 最良点で確定再計算 ----
    If haveBest Then
        Call EvalRowAtQin(ws, r, bestM, qP, dlt, ystar, pm, tooHigh, physical, isErr, sMax)
        If isErr Then GoTo MarkFormula
        dq = DqRatio(qP, bestM)
    End If

    ' ---- status 判定 (物理ガード + solver) ----
    If (qP <= 0#) Or (pm <= 0#) Or (ystar <= 0#) Then
        res.status = ST_NONPHYS
        res.errMsg = "非物理 (qP=" & Format(qP, "0.00E+0") & " PM=" & Format(pm, "0.000") & _
                     " y*=" & Format(ystar, "0.00E+0") & ")"
    ElseIf sMax >= 900 Then
        res.status = ST_SOLVER: res.errMsg = "Solver 例外 (code " & sMax & ")"
    ElseIf converged Then
        res.status = ST_OK
        If sMax > 2 Then res.errMsg = "OK だが solver code " & sMax
    Else
        res.status = ST_RUNTIME    ' 収束せず (反復上限)
        res.errMsg = "反復上限内に未収束。最良|dq|=" & Format(Abs(bestDq), "0.000") & "%"
    End If

Finalize:
    res.qlow = qLow: res.qhigh = qHigh: res.sMax = sMax
    res.qin = ws.Cells(r, cQin).Value
    res.qP = qP: res.pm = pm: res.dq = dq
    res.fFinal = ToNum(ws.Cells(r, cF).Value)
    res.TwFinal = ToNum(ws.Cells(r, cTw).Value)
    res.yFinal = ystar: res.UBFinal = ToNum(ws.Cells(r, cUB).Value)
    Call ReadInputs(ws, r, res)
    res.elapsed = Timer - t0
    res.lastStep = gLastStep
    If LogOn() Then Call AppendSummaryToLog(res)
    ProcessRowSafe = (res.status = ST_OK)
    Exit Function

MarkFormula:
    res.status = ST_FORMULA: res.errMsg = "数式エラー (#VALUE!/#NUM! 等)"
    res.qlow = qLow: res.qhigh = qHigh
    Call ReadInputs(ws, r, res)
    res.elapsed = Timer - t0
    res.lastStep = gLastStep
    ProcessRowSafe = False
    Exit Function

RowFail:
    res.status = ST_RUNTIME
    res.errMsg = "Err " & Err.Number & ": " & Err.Description
    On Error Resume Next
    Call ReadInputs(ws, r, res)
    res.elapsed = Timer - t0
    res.lastStep = gLastStep
    On Error GoTo 0
    ProcessRowSafe = False
End Function

'------------------------------------------------------------------
' q_in 評価 (TM03B2 と同じ。isErr を追加で返す)
'------------------------------------------------------------------
Private Sub EvalRowAtQin(ws As Worksheet, r As Long, qin As Double, _
        ByRef qP As Double, ByRef dlt As Double, ByRef ystar As Double, ByRef pm As Double, _
        ByRef tooHigh As Boolean, ByRef physical As Boolean, ByRef isErr As Boolean, ByRef sMax As Long)

    ws.Cells(r, cQin).Value = qin
    ws.Cells(r, cTw).Value = 600
    ws.Cells(r, cY).Value = 0.00001
    ws.Cells(r, cUB).Value = 1#
    Call CalcWholeRow(ws, r)

    Dim s1&, s2&, s3&
    s1 = SolveZero(ws, r, cTwb, cTw)
    s2 = SolveZero(ws, r, cYb, cY)
    s3 = SolveZero(ws, r, cUBb, cUB)
    ws.Rows(r).Calculate

    isErr = IsError(ws.Cells(r, cQP).Value) Or IsError(ws.Cells(r, cDelta).Value) _
            Or IsError(ws.Cells(r, cY).Value) Or IsError(ws.Cells(r, cPM).Value)
    qP = ToNum(ws.Cells(r, cQP).Value)
    dlt = ToNum(ws.Cells(r, cDelta).Value)
    ystar = ToNum(ws.Cells(r, cY).Value)
    pm = ToNum(ws.Cells(r, cPM).Value)
    physical = (Not isErr) And (dlt >= 0#)
    tooHigh = physical And ((qP - qin) > 0#)
    sMax = Max3(s1, s2, s3)
End Sub

Private Sub ReadInputs(ws As Worksheet, r As Long, ByRef res As TRowResult)
    res.qM = ToNum(ws.Cells(r, cqM).Value)
    res.Tsub = ToNum(ws.Cells(r, cTsub).Value)
    res.xMes = ToNum(ws.Cells(r, cXm).Value)
    res.Pmpa = ToNum(ws.Cells(r, cP).Value) / 1000000#
    res.Gv = ToNum(ws.Cells(r, cG).Value)
    res.DHmm = ToNum(ws.Cells(r, cDH).Value) * 1000#
    res.Lm = ToNum(ws.Cells(r, cL).Value)
    res.Fform = ToNum(ws.Cells(r, cFform).Value)
    res.Fcorr = ToNum(ws.Cells(r, cFcorr).Value)
End Sub

'------------------------------------------------------------------
' Solver ラッパ (例外時 999)
'------------------------------------------------------------------
Private Function SolveZero(ws As Worksheet, r As Long, setCol As Long, byCol As Long) As Long
    On Error GoTo SErr
    SetStep "STEP 13: before SolverReset", r
    SolverReset
    SolverOk SetCell:=ws.Cells(r, setCol).Address(True, True), _
             MaxMinVal:=3, ValueOf:=0, _
             ByChange:=ws.Cells(r, byCol).Address(True, True), _
             Engine:=1, EngineDesc:="GRG Nonlinear"
    SolverOptions AssumeNonNeg:=False
    SolveZero = SolverSolve(UserFinish:=True)
    SetStep "STEP 14: after SolverSolve", r
    Exit Function
SErr:
    SolveZero = 999
End Function

'------------------------------------------------------------------
' summary シート
'------------------------------------------------------------------
Private Sub EnsureSummarySheet()
    Dim sh As Worksheet
    On Error Resume Next
    Set sh = ThisWorkbook.Worksheets(SUMMARY_SHEET)
    On Error GoTo 0
    If sh Is Nothing Then
        Set sh = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        sh.Name = SUMMARY_SHEET
    Else
        sh.Cells.Clear
    End If
    Dim hdr As Variant, i As Long
    hdr = Array("RunID", "Timestamp", "RowNo", "No_TableNo", "TableNo", "ExptNo", "Status", _
        "q_M_MWm2", "q_in_final_MWm2", "q_P_final_MWm2", "PM_ratio", "dq_ratio_pct", _
        "q_low_final_MWm2", "q_high_final_MWm2", "n_expand", "n_bisect", "solver_max_code", _
        "f_final", "Tw_final", "y_star_final", "UB_final", "Tsub", "x_Mes", "P_MPa", "G", _
        "DH_mm", "L_DNB_m", "F_form", "Fcorr", "error_message", "elapsed_sec", "lastStep")
    For i = 0 To UBound(hdr)
        sh.Cells(1, i + 1).Value = hdr(i)
    Next i
    sh.Rows(1).Font.Bold = True
End Sub

Private Sub WriteSummaryRow(runID As String, ByRef res As TRowResult)
    Dim sh As Worksheet: Set sh = ThisWorkbook.Worksheets(SUMMARY_SHEET)
    Dim nr As Long: nr = sh.Cells(sh.Rows.Count, 1).End(xlUp).Row + 1
    Dim tno As String, eno As String, p As Long
    p = InStrRev(res.id, "_")
    If p > 0 Then eno = Left(res.id, p - 1): tno = Mid(res.id, p + 1) Else eno = res.id: tno = ""
    With sh
        .Cells(nr, 1).Value = runID
        .Cells(nr, 2).Value = Format(Now, "yyyy-mm-dd hh:nn:ss")
        .Cells(nr, 3).Value = res.RowNo
        .Cells(nr, 4).Value = res.id
        .Cells(nr, 5).Value = tno
        .Cells(nr, 6).Value = eno
        .Cells(nr, 7).Value = res.status
        .Cells(nr, 8).Value = SafeMW(res.qM)
        .Cells(nr, 9).Value = SafeMW(res.qin)
        .Cells(nr, 10).Value = SafeMW(res.qP)
        .Cells(nr, 11).Value = res.pm
        .Cells(nr, 12).Value = res.dq
        .Cells(nr, 13).Value = SafeMW(res.qlow)
        .Cells(nr, 14).Value = SafeMW(res.qhigh)
        .Cells(nr, 15).Value = res.nExpand
        .Cells(nr, 16).Value = res.nBisect
        .Cells(nr, 17).Value = res.sMax
        .Cells(nr, 18).Value = res.fFinal
        .Cells(nr, 19).Value = res.TwFinal
        .Cells(nr, 20).Value = res.yFinal
        .Cells(nr, 21).Value = res.UBFinal
        .Cells(nr, 22).Value = res.Tsub
        .Cells(nr, 23).Value = res.xMes
        .Cells(nr, 24).Value = res.Pmpa
        .Cells(nr, 25).Value = res.Gv
        .Cells(nr, 26).Value = res.DHmm
        .Cells(nr, 27).Value = res.Lm
        .Cells(nr, 28).Value = res.Fform
        .Cells(nr, 29).Value = res.Fcorr
        .Cells(nr, 30).Value = res.errMsg
        .Cells(nr, 31).Value = res.elapsed
        .Cells(nr, 32).Value = res.lastStep
    End With
End Sub

'------------------------------------------------------------------
' detail Log (ws_Log) : LOG_DETAIL かつ Not LOG_SUMMARY_ONLY のとき
'------------------------------------------------------------------
Private Function LogOn() As Boolean
    LogOn = LOG_DETAIL And (Not LOG_SUMMARY_ONLY)
End Function

Private Sub InitDetailLog()
    If Not LogOn() Then Exit Sub
    With ws_Log
        .Cells.Clear
        .Cells(1, 1).Value = "RowNo": .Cells(1, 2).Value = "No_TableNo": .Cells(1, 3).Value = "phase"
        .Cells(1, 4).Value = "iter": .Cells(1, 5).Value = "q_low": .Cells(1, 6).Value = "q_high"
        .Cells(1, 7).Value = "q_in": .Cells(1, 8).Value = "q_P": .Cells(1, 9).Value = "delta"
        .Cells(1, 10).Value = "y_star": .Cells(1, 11).Value = "PM_ratio": .Cells(1, 12).Value = "dq_ratio_pct"
        .Cells(1, 13).Value = "solver_max_code": .Cells(1, 14).Value = "status": .Cells(1, 15).Value = "note"
        .Rows(1).Font.Bold = True
    End With
End Sub

Private Sub AppendDetail(rowNo As Long, id As String, phase As String, it As Long, _
        qLow As Double, qHigh As Double, qin As Double, qP As Double, dlt As Double, _
        ystar As Double, pm As Double, dq As Double, sMax As Long)
    Dim nr As Long
    With ws_Log
        nr = .Cells(.Rows.Count, 1).End(xlUp).Row + 1
        .Cells(nr, 1).Value = rowNo: .Cells(nr, 2).Value = id: .Cells(nr, 3).Value = phase
        .Cells(nr, 4).Value = it: .Cells(nr, 5).Value = qLow: .Cells(nr, 6).Value = qHigh
        .Cells(nr, 7).Value = qin: .Cells(nr, 8).Value = qP: .Cells(nr, 9).Value = dlt
        .Cells(nr, 10).Value = ystar: .Cells(nr, 11).Value = pm: .Cells(nr, 12).Value = dq
        .Cells(nr, 13).Value = sMax
    End With
End Sub

Private Sub AppendSummaryToLog(ByRef res As TRowResult)
    Dim nr As Long
    With ws_Log
        nr = .Cells(.Rows.Count, 1).End(xlUp).Row + 1
        .Cells(nr, 1).Value = res.RowNo: .Cells(nr, 2).Value = res.id: .Cells(nr, 3).Value = "SUMMARY"
        .Cells(nr, 5).Value = res.qlow: .Cells(nr, 6).Value = res.qhigh: .Cells(nr, 7).Value = res.qin
        .Cells(nr, 8).Value = res.qP: .Cells(nr, 11).Value = res.pm: .Cells(nr, 12).Value = res.dq
        .Cells(nr, 13).Value = res.sMax: .Cells(nr, 14).Value = res.status: .Cells(nr, 15).Value = res.errMsg
    End With
End Sub


Private Sub SetStep(stepName As String, rowNo As Long)
    gLastStep = stepName
    gCurrentRow = rowNo
    TraceStep "", stepName, rowNo, ""
End Sub

Private Sub EnsureDebugTrace(runID As String)
    Dim sh As Worksheet
    Set sh = Nothing
    On Error Resume Next
    Set sh = ThisWorkbook.Worksheets(DEBUG_SHEET)
    On Error GoTo 0
    If sh Is Nothing Then
        Set sh = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        sh.Name = DEBUG_SHEET
    Else
        sh.Cells.Clear
    End If
    sh.Cells(1, 1).Value = "RunID"
    sh.Cells(1, 2).Value = "Timestamp"
    sh.Cells(1, 3).Value = "RowNo"
    sh.Cells(1, 4).Value = "lastStep"
    sh.Cells(1, 5).Value = "note"
    sh.Rows(1).Font.Bold = True
    gTraceReady = True
    TraceStep runID, "STEP 07: after EnsureSummarySheet", 0, "trace sheet ready"
End Sub

Private Sub TraceStep(runID As String, stepName As String, rowNo As Long, note As String)
    If Not gTraceReady Then Exit Sub
    On Error Resume Next
    Dim sh As Worksheet, nr As Long
    Set sh = ThisWorkbook.Worksheets(DEBUG_SHEET)
    nr = sh.Cells(sh.Rows.Count, 1).End(xlUp).Row + 1
    sh.Cells(nr, 1).Value = runID
    sh.Cells(nr, 2).Value = Format(Now, "yyyy-mm-dd hh:nn:ss")
    sh.Cells(nr, 3).Value = rowNo
    sh.Cells(nr, 4).Value = stepName
    sh.Cells(nr, 5).Value = note
    On Error GoTo 0
End Sub

'------------------------------------------------------------------
' ユーティリティ
'------------------------------------------------------------------
Private Sub RestoreApp(scr As Boolean, ev As Boolean, al As Boolean, ca As XlCalculation, displayStatus As Boolean, statusBarValue As Variant)
    On Error Resume Next
    Application.Calculation = ca
    Application.DisplayAlerts = al
    Application.EnableEvents = ev
    Application.ScreenUpdating = scr
    Application.DisplayStatusBar = displayStatus
    If VarType(statusBarValue) = vbBoolean Then
        Application.StatusBar = False
    Else
        Application.StatusBar = statusBarValue
    End If
    On Error GoTo 0
End Sub

Private Function DqRatio(qP As Double, qin As Double) As Double
    If qin <> 0# Then DqRatio = 100# * (qP - qin) / qin Else DqRatio = 100# * (qP - qin)
End Function

Private Function ToNum(v As Variant) As Double
    If IsError(v) Then
        ToNum = -1E+308
    ElseIf IsNumeric(v) Then
        ToNum = CDbl(v)
    Else
        ToNum = -1E+308
    End If
End Function

Private Function SafeMW(v As Double) As Variant
    If v <= -1E+307 Then SafeMW = "" Else SafeMW = v / 1000000#
End Function

Private Function MinD(a As Double, b As Double) As Double
    MinD = IIf(a < b, a, b)
End Function

Private Function Max3(a As Long, b As Long, c As Long) As Long
    Dim m As Long: m = a
    If b > m Then m = b
    If c > m Then m = c
    Max3 = m
End Function
