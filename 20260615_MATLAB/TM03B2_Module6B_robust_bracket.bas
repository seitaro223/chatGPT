Attribute VB_Name = "Module6B_TM03B2"
'==================================================================
' TM03B2 : 外側二分探索のロバスト化 (high-bracket 拡張 + 非物理ガード)
'------------------------------------------------------------------
' 既存 Module6.AdjustSValue_BinarySearch_15_Fast_SaveEachRow_LogSheet_Final
' の代替（ドロップイン）。固定上限 q_high=12e6 で解が範囲外になる点
' (例: 高q_M / 高G) を、非物理解に落とさず扱う。
'
' 主な変更:
'   1. 固定二分探索の前に bracket 確認 (q_low/q_high の符号確認)。
'   2. q_high で挟めない場合は q_high を段階拡張 (×EXPAND_FACTOR)。
'   3. Q_HIGH_MAX でも挟めなければ FAIL_BRACKET_HIGH として次行へ。
'   4. q_P<=0 / PM_ratio<=0 / y_star<=0 は成功扱いしない (FAIL_NONPHYSICAL)。
'   5. 失敗理由・最終 q_low/q_high・最終 dq_ratio・Solver 状態を Log に残す。
'   6. 高速化は最小限 (素直な bisection)。まずロジック変更の影響を確認する。
'
' 依存(既存を再利用): FindHeaderCol(Module5), CalcWholeRow(Module7),
'                      frmRowInput, ws_tm, ws_Log, Solver アドイン。
' 実行: マクロ AdjustSValue_BracketRobust_TM03B2 を実行し、frmRowInput に
'       追加した代表点の開始行・終了行を入力する。
'==================================================================
Option Explicit

' ---- tunables ----
Private Const TOL_PCT       As Double = 1#          ' 収束: |dq_ratio%| < 1%
Private Const ITER_LIMIT    As Long = 80            ' bisection 反復上限
Private Const Q_LOW_INIT    As Double = 100000#     ' 1e5  W/m2
Private Const Q_HIGH_INIT   As Double = 12000000#   ' 1.2e7 W/m2 (旧固定上限)
Private Const Q_HIGH_MAX    As Double = 60000000#   ' 6.0e7 W/m2 拡張上限
Private Const EXPAND_FACTOR As Double = 1.5         ' q_high 拡張倍率
Private Const EXPAND_LIMIT  As Long = 20            ' q_high 拡張回数上限

' status 文字列
Private Const ST_OK          As String = "OK"
Private Const ST_BRACKET_HI  As String = "FAIL_BRACKET_HIGH"
Private Const ST_BRACKET_LO  As String = "FAIL_BRACKET_LOW"
Private Const ST_NONPHYS     As String = "FAIL_NONPHYSICAL"
Private Const ST_ITER        As String = "FAIL_ITER_LIMIT"

Public Sub AdjustSValue_BracketRobust_TM03B2()

    Dim ws As Worksheet: Set ws = ws_tm

    ' --- 列番号 (ヘッダ名検索) ---
    Dim COL_f As Long, COL_Tw As Long, COL_ystar As Long, COL_UB As Long
    Dim COL_qin As Long, COL_delta As Long, COL_qP As Long, COL_dqchf As Long
    Dim COL_fb As Long, COL_Twb As Long, COL_yb As Long, COL_UBb As Long
    Dim COL_PM As Long, COL_qPMW As Long, COL_id As Long
    COL_f = FindHeaderCol(ws, "f")
    COL_Tw = FindHeaderCol(ws, "Tw")
    COL_ystar = FindHeaderCol(ws, "y_star")
    COL_UB = FindHeaderCol(ws, "UB")
    COL_qin = FindHeaderCol(ws, "q_in")
    COL_delta = FindHeaderCol(ws, "delta")
    COL_qP = FindHeaderCol(ws, "q_P")
    COL_dqchf = FindHeaderCol(ws, "dq_chf")
    COL_fb = FindHeaderCol(ws, "f_balance")
    COL_Twb = FindHeaderCol(ws, "Tw_balance")
    COL_yb = FindHeaderCol(ws, "y_star_balance")
    COL_UBb = FindHeaderCol(ws, "UB_balance")
    COL_PM = FindHeaderCol(ws, "PM_ratio")
    COL_qPMW = FindHeaderCol(ws, "q_P_MW")
    COL_id = 1   ' A 列 = No_TableNo

    ' --- 行範囲 ---
    Dim startRow As Long, endRow As Long, lastRow As Long
    frmRowInput.Show vbModal
    If Not IsNumeric(frmRowInput.txtStartRow.Value) Or Not IsNumeric(frmRowInput.txtEndRow.Value) Then
        MsgBox "開始行・終了行に数値を入力してください。", vbExclamation: Exit Sub
    End If
    startRow = CLng(frmRowInput.txtStartRow.Value)
    endRow = CLng(frmRowInput.txtEndRow.Value)
    If startRow < 2 Or endRow < startRow Then
        MsgBox "有効な行番号を入力してください。", vbExclamation: Exit Sub
    End If
    lastRow = ws.Cells(ws.Rows.Count, COL_dqchf).End(xlUp).Row
    If endRow > lastRow Then endRow = lastRow

    Call InitRunLog

    Dim prevCalc As XlCalculation
    prevCalc = Application.Calculation
    With Application
        .ScreenUpdating = False
        .EnableEvents = False
        .Calculation = xlCalculationManual
        .DisplayAlerts = False
    End With

    Dim r As Long
    For r = startRow To endRow
        Debug.Print "TM03B2 行 " & r & " 処理中..."
        Call ProcessRow(ws, r, COL_id, COL_f, COL_Tw, COL_ystar, COL_UB, COL_qin, _
                        COL_delta, COL_qP, COL_PM, COL_fb, COL_Twb, COL_yb, COL_UBb)
        If r Mod 25 = 0 Then ws.Parent.Save
    Next r

    ws.Parent.Save

    With Application
        .DisplayAlerts = True
        .Calculation = prevCalc
        .EnableEvents = True
        .ScreenUpdating = True
    End With

    MsgBox "TM03B2 完了 (rows " & startRow & "-" & endRow & ")。Log シートを確認してください。", vbInformation
End Sub

'------------------------------------------------------------------
' 1行処理: bracket 拡張 -> bisection -> 物理ガード -> Log
'------------------------------------------------------------------
Private Sub ProcessRow(ws As Worksheet, r As Long, COL_id As Long, _
        COL_f As Long, COL_Tw As Long, COL_ystar As Long, COL_UB As Long, _
        COL_qin As Long, COL_delta As Long, COL_qP As Long, COL_PM As Long, _
        COL_fb As Long, COL_Twb As Long, COL_yb As Long, COL_UBb As Long)

    Dim id As String: id = CStr(ws.Cells(r, COL_id).Value)

    ' --- f を1回求解 (流れ条件依存。q_in に依らない) ---
    ws.Cells(r, COL_f).Value = 0.01
    ws.Cells(r, COL_ystar).Value = 0.00001
    ws.Cells(r, COL_UB).Value = 1#
    Call CalcWholeRow(ws, r)
    Dim sres_f As Long
    sres_f = SolveZero(ws, r, COL_fb, COL_f)

    ' --- 評価用変数 ---
    Dim qP As Double, dlt As Double, ystar As Double, pm As Double
    Dim physical As Boolean, tooHigh As Boolean, sMax As Long
    Dim dq As Double

    Dim qLow As Double, qHigh As Double
    qLow = Q_LOW_INIT
    qHigh = Q_HIGH_INIT

    ' --- bracket 確認: q_low ---
    Call EvalRowAtQin(ws, r, qLow, COL_qin, COL_Tw, COL_ystar, COL_UB, _
            COL_Twb, COL_yb, COL_UBb, COL_qP, COL_delta, COL_PM, _
            qP, dlt, ystar, pm, tooHigh, physical, sMax)
    dq = DqRatio(qP, qLow)
    Call AppendLog(r, id, "BRACKET", 0, qLow, qHigh, qLow, qP, dlt, ystar, pm, dq, sMax, "", "q_low eval")

    If tooHigh Then
        ' 解が q_low より下 -> 想定外。低側へは拡張しない方針。記録して終了。
        Call AppendLog(r, id, "SUMMARY", 0, qLow, qHigh, qLow, qP, dlt, ystar, pm, dq, sMax, ST_BRACKET_LO, _
            "q_low(=1e5) で既に too_high。root が下限未満。")
        Exit Sub
    End If

    ' --- bracket 確認 + 拡張: q_high ---
    Dim nExp As Long: nExp = 0
    Call EvalRowAtQin(ws, r, qHigh, COL_qin, COL_Tw, COL_ystar, COL_UB, _
            COL_Twb, COL_yb, COL_UBb, COL_qP, COL_delta, COL_PM, _
            qP, dlt, ystar, pm, tooHigh, physical, sMax)
    dq = DqRatio(qP, qHigh)
    Call AppendLog(r, id, "BRACKET", 0, qLow, qHigh, qHigh, qP, dlt, ystar, pm, dq, sMax, "", "q_high eval (init)")

    Do While (Not tooHigh) And (qHigh < Q_HIGH_MAX) And (nExp < EXPAND_LIMIT)
        nExp = nExp + 1
        qHigh = MinD(qHigh * EXPAND_FACTOR, Q_HIGH_MAX)
        Call EvalRowAtQin(ws, r, qHigh, COL_qin, COL_Tw, COL_ystar, COL_UB, _
                COL_Twb, COL_yb, COL_UBb, COL_qP, COL_delta, COL_PM, _
                qP, dlt, ystar, pm, tooHigh, physical, sMax)
        dq = DqRatio(qP, qHigh)
        Call AppendLog(r, id, "BRACKET", nExp, qLow, qHigh, qHigh, qP, dlt, ystar, pm, dq, sMax, "", _
            "q_high expand #" & nExp)
    Loop

    If Not tooHigh Then
        ' 最大上限でも挟めない -> FAIL_BRACKET_HIGH。非物理解は採用しない。
        Call AppendLog(r, id, "SUMMARY", nExp, qLow, qHigh, qHigh, qP, dlt, ystar, pm, dq, sMax, ST_BRACKET_HI, _
            "Q_HIGH_MAX=" & Format(Q_HIGH_MAX, "0.#E+0") & " でも bracket できず (拡張 " & nExp & " 回)。")
        Exit Sub
    End If

    ' --- bisection ([qLow=too_low, qHigh=too_high]) ---
    Dim it As Long, m As Double
    Dim bestM As Double, bestDq As Double, bestQP As Double, bestPM As Double, bestY As Double, bestDlt As Double
    Dim bestS As Long, haveBest As Boolean
    haveBest = False
    bestDq = 1E+300
    Dim converged As Boolean: converged = False

    For it = 1 To ITER_LIMIT
        m = (qLow + qHigh) / 2#
        Call EvalRowAtQin(ws, r, m, COL_qin, COL_Tw, COL_ystar, COL_UB, _
                COL_Twb, COL_yb, COL_UBb, COL_qP, COL_delta, COL_PM, _
                qP, dlt, ystar, pm, tooHigh, physical, sMax)
        dq = DqRatio(qP, m)
        Call AppendLog(r, id, "BISECT", it, qLow, qHigh, m, qP, dlt, ystar, pm, dq, sMax, "", "")

        ' 物理点の最良(min|dq|)を保持
        If physical And (Abs(dq) < Abs(bestDq)) Then
            bestDq = dq: bestM = m: bestQP = qP: bestPM = pm: bestY = ystar: bestDlt = dlt
            bestS = sMax: haveBest = True
        End If

        If physical And (Abs(dq) < TOL_PCT) Then
            converged = True
            Exit For
        End If

        If tooHigh Then
            qHigh = m
        Else
            qLow = m
        End If
    Next it

    ' --- 最良点で確定再計算 (行を整合状態に残す) ---
    If haveBest Then
        Call EvalRowAtQin(ws, r, bestM, COL_qin, COL_Tw, COL_ystar, COL_UB, _
                COL_Twb, COL_yb, COL_UBb, COL_qP, COL_delta, COL_PM, _
                qP, dlt, ystar, pm, tooHigh, physical, sMax)
        dq = DqRatio(qP, bestM)
    End If

    ' --- 物理ガード + status 判定 ---
    Dim status As String, note As String
    If (qP <= 0#) Or (pm <= 0#) Or (ystar <= 0#) Then
        status = ST_NONPHYS
        note = "非物理解 (qP=" & Format(qP, "0.000E+0") & ", PM=" & Format(pm, "0.000") & _
               ", y_star=" & Format(ystar, "0.000E+0") & ")"
    ElseIf converged Then
        status = ST_OK
        note = "収束 (|dq_ratio|<" & TOL_PCT & "%)"
    Else
        status = ST_ITER
        note = "反復上限 (" & ITER_LIMIT & ") 内に収束せず。最良 |dq_ratio|=" & Format(Abs(bestDq), "0.000") & "%"
    End If

    Call AppendLog(r, id, "SUMMARY", it, qLow, qHigh, IIf(haveBest, bestM, m), qP, dlt, ystar, pm, dq, sMax, status, _
        note & "  (f_solver=" & sres_f & ")")
End Sub

'------------------------------------------------------------------
' q_in を与えて1行を評価 (Tw/y_star/UB を内側 Solver で求解し q_P 等を返す)
'   tooHigh = physical かつ (q_P - q_in) > 0   ' root が当該 q_in より下
'   physical = (delta >= 0)
'------------------------------------------------------------------
Private Sub EvalRowAtQin(ws As Worksheet, r As Long, qin As Double, _
        COL_qin As Long, COL_Tw As Long, COL_ystar As Long, COL_UB As Long, _
        COL_Twb As Long, COL_yb As Long, COL_UBb As Long, _
        COL_qP As Long, COL_delta As Long, COL_PM As Long, _
        ByRef qP As Double, ByRef dlt As Double, ByRef ystar As Double, ByRef pm As Double, _
        ByRef tooHigh As Boolean, ByRef physical As Boolean, ByRef sMax As Long)

    ws.Cells(r, COL_qin).Value = qin
    ws.Cells(r, COL_Tw).Value = 600
    ws.Cells(r, COL_ystar).Value = 0.00001
    ws.Cells(r, COL_UB).Value = 1#
    Call CalcWholeRow(ws, r)

    Dim s1 As Long, s2 As Long, s3 As Long
    s1 = SolveZero(ws, r, COL_Twb, COL_Tw)
    s2 = SolveZero(ws, r, COL_yb, COL_ystar)
    s3 = SolveZero(ws, r, COL_UBb, COL_UB)
    ws.Rows(r).Calculate

    qP = ToNum(ws.Cells(r, COL_qP).Value)
    dlt = ToNum(ws.Cells(r, COL_delta).Value)
    ystar = ToNum(ws.Cells(r, COL_ystar).Value)
    pm = ToNum(ws.Cells(r, COL_PM).Value)

    physical = (dlt >= 0#)
    tooHigh = physical And ((qP - qin) > 0#)
    sMax = Max3(s1, s2, s3)
End Sub

'------------------------------------------------------------------
' Solver ラッパ (結果コードを返す)
'------------------------------------------------------------------
Private Function SolveZero(ws As Worksheet, r As Long, setCol As Long, byCol As Long) As Long
    SolverReset
    SolverOk SetCell:=ws.Cells(r, setCol).Address(True, True), _
             MaxMinVal:=3, ValueOf:=0, _
             ByChange:=ws.Cells(r, byCol).Address(True, True), _
             Engine:=1, EngineDesc:="GRG Nonlinear"
    SolverOptions AssumeNonNeg:=False
    On Error Resume Next
    SolveZero = SolverSolve(UserFinish:=True)
    If Err.Number <> 0 Then SolveZero = 999  ' Solver 例外
    On Error GoTo 0
End Function

'------------------------------------------------------------------
' Log (ws_Log) : 反復履歴 + SUMMARY 行
'------------------------------------------------------------------
Private Sub InitRunLog()
    With ws_Log
        .Cells.Clear
        .Cells(1, 1).Value = "RowNo"
        .Cells(1, 2).Value = "No_TableNo"
        .Cells(1, 3).Value = "phase"
        .Cells(1, 4).Value = "iter"
        .Cells(1, 5).Value = "q_low"
        .Cells(1, 6).Value = "q_high"
        .Cells(1, 7).Value = "q_in"
        .Cells(1, 8).Value = "q_P"
        .Cells(1, 9).Value = "delta"
        .Cells(1, 10).Value = "y_star"
        .Cells(1, 11).Value = "PM_ratio"
        .Cells(1, 12).Value = "dq_ratio_pct"
        .Cells(1, 13).Value = "solver_max_code"
        .Cells(1, 14).Value = "status"
        .Cells(1, 15).Value = "note"
    End With
End Sub

Private Sub AppendLog(rowNo As Long, id As String, phase As String, it As Long, _
        qLow As Double, qHigh As Double, qin As Double, qP As Double, dlt As Double, _
        ystar As Double, pm As Double, dq As Double, sMax As Long, status As String, note As String)
    Dim nr As Long
    With ws_Log
        nr = .Cells(.Rows.Count, 1).End(xlUp).Row + 1
        .Cells(nr, 1).Value = rowNo
        .Cells(nr, 2).Value = id
        .Cells(nr, 3).Value = phase
        .Cells(nr, 4).Value = it
        .Cells(nr, 5).Value = qLow
        .Cells(nr, 6).Value = qHigh
        .Cells(nr, 7).Value = qin
        .Cells(nr, 8).Value = qP
        .Cells(nr, 9).Value = dlt
        .Cells(nr, 10).Value = ystar
        .Cells(nr, 11).Value = pm
        .Cells(nr, 12).Value = dq
        .Cells(nr, 13).Value = sMax
        .Cells(nr, 14).Value = status
        .Cells(nr, 15).Value = note
    End With
End Sub

'------------------------------------------------------------------
' ユーティリティ
'------------------------------------------------------------------
Private Function DqRatio(qP As Double, qin As Double) As Double
    If qin <> 0# Then
        DqRatio = 100# * (qP - qin) / qin
    Else
        DqRatio = 100# * (qP - qin)
    End If
End Function

Private Function ToNum(v As Variant) As Double
    If IsError(v) Then
        ToNum = -1E+308   ' #VALUE!/#NUM! 等は非物理扱いの番兵
    ElseIf IsNumeric(v) Then
        ToNum = CDbl(v)
    Else
        ToNum = -1E+308
    End If
End Function

Private Function MinD(a As Double, b As Double) As Double
    MinD = IIf(a < b, a, b)
End Function

Private Function Max3(a As Long, b As Long, c As Long) As Long
    Dim m As Long
    m = a
    If b > m Then m = b
    If c > m Then m = c
    Max3 = m
End Function
