%% H52Q-QA-02: バンドル108/161/164の実験基準x_eqとNFI-COBRA Xlocの比較
% 作成日: 2026-06-22
%
% 目的:
%   西田さん側の認識 = NFI報告書に記載されたCOBRA-EN出力 Xloc
%   櫻井側の認識     = 実験CHF条件から計算した熱平衡クオリティ
%   として、両者をケースごとに横並び比較する。
%
% 入力:
%   1) H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx
%      - tm_F1_108 / tm_F1_161 / tm_F1_164 を使用
%      - x_Mes列を「実験基準x_eq」として扱う
%        ※現在のcurrent_bundleでは noF1/F1でx_Mesは同じ値
%
%   2) NFI_Xloc_from_NFK_TT_26001_report_v1.csv
%      - NFI報告書 表3.2-3〜3.2-5 から抽出したXloc
%      - Xloc_NFI_COBRAを「COBRA基準x_eq」として扱う
%
% 出力:
%   QA02_bundle_xeq_definition_compare_v1.xlsx
%   run_report_QA02_bundle_xeq_definition_compare_v1.md
%   fig_QA02_01_xeq_expBasis_vs_NFI_Xloc.png
%   fig_QA02_02_delta_xeq_by_case.png
%   fig_QA02_03_xeq_distribution_by_test.png
%
% 注意:
%   このスクリプトは補正式を作らない。
%   クオリティ定義の棚卸しと、認識ズレの確認だけを行う。

clear; clc;

%% ===== 0. 設定 =====
cfg.bundleWorkbook = 'H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx';
cfg.nfiCsv         = 'NFI_Xloc_from_NFK_TT_26001_report_v1.csv';
cfg.outputDir      = ['QA02_bundle_xeq_compare_' datestr(now,'yyyymmdd_HHMMSS')];
cfg.outputXlsx     = 'QA02_bundle_xeq_definition_compare_v1.xlsx';
cfg.outputReport   = 'run_report_QA02_bundle_xeq_definition_compare_v1.md';

cfg.tests = [108 161 164];

if ~exist(cfg.outputDir,'dir')
    mkdir(cfg.outputDir);
end

copyfile(cfg.nfiCsv, fullfile(cfg.outputDir, cfg.nfiCsv));

%% ===== 1. 入力確認 =====
assert(isfile(cfg.bundleWorkbook), 'current_bundle_input workbookが見つかりません: %s', cfg.bundleWorkbook);
assert(isfile(cfg.nfiCsv), 'NFI Xloc CSVが見つかりません: %s', cfg.nfiCsv);

%% ===== 2. NFI報告書Xlocの読み込み =====
NFI = readtable_preserve(cfg.nfiCsv);

% 期待列: test, case_no, Xloc_NFI_COBRA, DNBR_NFI, Elev_m, P_MPa, ...
NFI.test    = double(NFI.test);
NFI.case_no = double(NFI.case_no);
NFI.join_key = make_join_key(NFI.test, NFI.case_no);

% 念のため、同一test/case_noの重複をチェック
[uk, ~, ic] = unique(NFI.join_key);
counts = accumarray(ic, 1);
if any(counts > 1)
    warning('NFI CSVに重複キーがあります。先頭値を使います。');
    [~, ia] = unique(NFI.join_key, 'stable');
    NFI = NFI(ia,:);
end

%% ===== 3. current_bundleの読み込み =====
ALL = table();

for it = 1:numel(cfg.tests)
    testNo = cfg.tests(it);
    sheetF1 = sprintf('tm_F1_%d', testNo);
    sheetNoF1 = sprintf('tm_%d', testNo);

    T1 = readtable_preserve(cfg.bundleWorkbook, sheetF1);
    T0 = readtable_preserve(cfg.bundleWorkbook, sheetNoF1);

    % F1側を主表にする
    B = table();
    B.test = repmat(testNo, height(T1), 1);
    B.source_sheet = repmat(string(sheetF1), height(T1), 1);

    noTable = string(get_col(T1, {'No_TableNo'}));
    B.No_TableNo = noTable;
    B.case_no = parse_case_no(noTable);
    B.case_label = compose('WH_%d_%02d.in', B.test, B.case_no);
    B.join_key = make_join_key(B.test, B.case_no);

    % 櫻井側: 実験CHF条件から計算した熱平衡クオリティとして、current_bundleのx_Mesを採用
    B.xeq_expBasis = double(get_col(T1, {'x_Mes','xeq','x_eq'}));

    % 参考量
    B.P_MPa_current    = double(get_col(T1, {'P'})) ./ 1.0e6;
    B.G_current        = double(get_col(T1, {'G'}));
    B.qM_MWm2_current  = double(get_col(T1, {'q_M'})) ./ 1.0e6;
    B.qP_F1_MWm2       = double(get_col(T1, {'q_P_MW','q_P'}));
    if max(B.qP_F1_MWm2,[],'omitnan') > 100
        B.qP_F1_MWm2 = B.qP_F1_MWm2 ./ 1.0e6;
    end
    B.PM_F1_current    = double(get_col(T1, {'PM_ratio'}));
    B.Tsub_K           = double(get_col(T1, {'Tsub'}));
    B.Fcorr            = double(get_col(T1, {'Fcorr'}));
    B.F_form           = double(get_col(T1, {'F_form'}));
    B.L_DNB_m          = double(get_col(T1, {'L_DNB'}));
    B.L_m              = double(get_col(T1, {'L'}));
    B.DH_m             = double(get_col(T1, {'DH'}));
    B.zDNB_over_DH     = B.L_DNB_m ./ B.DH_m;
    B.zDNB_over_L      = B.L_DNB_m ./ B.L_m;
    B.L_over_DH        = B.L_m ./ B.DH_m;

    % noF1側のPMも付ける。行順が同じ想定だが、念のためNo_TableNoで確認。
    noTable0 = string(get_col(T0, {'No_TableNo'}));
    if height(T0) == height(T1) && all(noTable0 == noTable)
        B.PM_noF1_current = double(get_col(T0, {'PM_ratio'}));
        B.qP_noF1_MWm2 = double(get_col(T0, {'q_P_MW','q_P'}));
        if max(B.qP_noF1_MWm2,[],'omitnan') > 100
            B.qP_noF1_MWm2 = B.qP_noF1_MWm2 ./ 1.0e6;
        end
    else
        warning('%s と %s の行対応が一致しません。noF1列はNaNにします。', sheetF1, sheetNoF1);
        B.PM_noF1_current = nan(height(T1),1);
        B.qP_noF1_MWm2 = nan(height(T1),1);
    end

    ALL = [ALL; B]; %#ok<AGROW>
end

%% ===== 4. NFI Xlocと結合 =====
C = outerjoin(ALL, NFI, ...
    'Keys','join_key', ...
    'MergeKeys',true, ...
    'Type','left', ...
    'LeftVariables', ALL.Properties.VariableNames, ...
    'RightVariables', {'case','Xloc_NFI_COBRA','DNBR_NFI','Elev_m','P_MPa','G_kgm2s','Qloc_MWm2','Qpred_MWm2','ch','rod','El'});

% 整理列
C.NFI_case = string(C.case);
C.delta_xeq_exp_minus_NFI = C.xeq_expBasis - C.Xloc_NFI_COBRA;
C.abs_delta_xeq = abs(C.delta_xeq_exp_minus_NFI);
C.NFI_minus_exp = C.Xloc_NFI_COBRA - C.xeq_expBasis;
C.xeq_band_exp = classify_xeq(C.xeq_expBasis);
C.xeq_band_NFI = classify_xeq(C.Xloc_NFI_COBRA);

% 主要列を先頭に並べる
front = {'test','case_no','case_label','No_TableNo', ...
    'xeq_expBasis','Xloc_NFI_COBRA','delta_xeq_exp_minus_NFI','abs_delta_xeq', ...
    'xeq_band_exp','xeq_band_NFI', ...
    'PM_F1_current','PM_noF1_current','DNBR_NFI', ...
    'qM_MWm2_current','qP_F1_MWm2','Qloc_MWm2','Qpred_MWm2', ...
    'P_MPa_current','P_MPa','G_current','G_kgm2s', ...
    'Tsub_K','F_form','Fcorr','L_DNB_m','Elev_m','zDNB_over_DH','zDNB_over_L','L_over_DH'};
C = movevars(C, intersect(front, C.Properties.VariableNames, 'stable'), 'Before', 1);

%% ===== 5. サマリ集計 =====
SUM = table();
for it = 1:numel(cfg.tests)
    testNo = cfg.tests(it);
    S = C(C.test == testNo,:);
    row = table();
    row.test = testNo;
    row.N = height(S);
    row.mean_xeq_expBasis = mean(S.xeq_expBasis,'omitnan');
    row.mean_Xloc_NFI_COBRA = mean(S.Xloc_NFI_COBRA,'omitnan');
    row.mean_delta_exp_minus_NFI = mean(S.delta_xeq_exp_minus_NFI,'omitnan');
    row.median_delta_exp_minus_NFI = median(S.delta_xeq_exp_minus_NFI,'omitnan');
    row.max_abs_delta_xeq = max(S.abs_delta_xeq,[],'omitnan');
    row.frac_exp_xeq_le_0 = mean(S.xeq_expBasis <= 0,'omitnan');
    row.frac_NFI_Xloc_le_0 = mean(S.Xloc_NFI_COBRA <= 0,'omitnan');
    row.frac_exp_xeq_gt_0p1 = mean(S.xeq_expBasis > 0.1,'omitnan');
    row.frac_NFI_Xloc_gt_0p1 = mean(S.Xloc_NFI_COBRA > 0.1,'omitnan');
    row.mean_PM_F1_current = mean(S.PM_F1_current,'omitnan');
    row.mean_DNBR_NFI = mean(S.DNBR_NFI,'omitnan');
    SUM = [SUM; row]; %#ok<AGROW>
end

%% ===== 6. 出力 =====
outXlsx = fullfile(cfg.outputDir, cfg.outputXlsx);
if isfile(outXlsx); delete(outXlsx); end
writetable(C, outXlsx, 'Sheet','case_compare');
writetable(SUM, outXlsx, 'Sheet','summary_by_test');
writetable(NFI, outXlsx, 'Sheet','NFI_Xloc_source');

%% ===== 7. 図の作成 =====
make_fig_01_scatter(C, fullfile(cfg.outputDir,'fig_QA02_01_xeq_expBasis_vs_NFI_Xloc.png'));
make_fig_02_delta(C, fullfile(cfg.outputDir,'fig_QA02_02_delta_xeq_by_case.png'));
make_fig_03_distribution(C, fullfile(cfg.outputDir,'fig_QA02_03_xeq_distribution_by_test.png'));

%% ===== 8. レポート作成 =====
write_report(fullfile(cfg.outputDir,cfg.outputReport), cfg, C, SUM);

%% ===== 9. 完了表示 =====
fprintf('\n=== H52Q-QA02 完了 ===\n');
fprintf('出力フォルダ: %s\n', cfg.outputDir);
fprintf('比較表: %s\n', outXlsx);
fprintf('レポート: %s\n', fullfile(cfg.outputDir,cfg.outputReport));
fprintf('図: fig_QA02_01〜03 PNG\n');

%% ===== ローカル関数 =====
function T = readtable_preserve(file, sheet)
    if nargin < 2
        opts = detectImportOptions(file, 'VariableNamingRule','preserve');
    else
        opts = detectImportOptions(file, 'Sheet',sheet, 'VariableNamingRule','preserve');
    end
    if nargin < 2
        T = readtable(file, opts);
    else
        T = readtable(file, opts, 'Sheet',sheet);
    end
end

function x = get_col(T, candidates)
    names = string(T.Properties.VariableNames);
    for i = 1:numel(candidates)
        cand = string(candidates{i});
        idx = find(strcmp(names, cand), 1);
        if ~isempty(idx)
            x = T.(names(idx));
            return;
        end
    end
    % 大文字小文字・記号ゆれを少し吸収
    normNames = normalize_name(names);
    for i = 1:numel(candidates)
        cand = normalize_name(string(candidates{i}));
        idx = find(strcmp(normNames, cand), 1);
        if ~isempty(idx)
            x = T.(names(idx));
            return;
        end
    end
    error('列が見つかりません。候補: %s / 利用可能列: %s', strjoin(string(candidates), ', '), strjoin(names, ', '));
end

function y = normalize_name(x)
    y = lower(regexprep(string(x), '[^a-zA-Z0-9一-龠ぁ-んァ-ン_]', ''));
end

function case_no = parse_case_no(noTable)
    case_no = nan(numel(noTable),1);
    for i = 1:numel(noTable)
        tok = regexp(noTable(i), '^(\d+)_', 'tokens', 'once');
        if ~isempty(tok)
            case_no(i) = str2double(tok{1});
        end
    end
end

function key = make_join_key(test, case_no)
    key = compose('%d_%02d', double(test), double(case_no));
end

function band = classify_xeq(x)
    band = strings(numel(x),1);
    for i = 1:numel(x)
        if isnan(x(i))
            band(i) = "missing";
        elseif x(i) <= 0
            band(i) = "x <= 0";
        elseif x(i) <= 0.05
            band(i) = "0 < x <= 0.05";
        elseif x(i) <= 0.10
            band(i) = "0.05 < x <= 0.10";
        elseif x(i) <= 0.20
            band(i) = "0.10 < x <= 0.20";
        else
            band(i) = "x > 0.20";
        end
    end
end

function make_fig_01_scatter(C, outPng)
    figure('Color','w','Position',[100 100 760 620]); hold on; grid on; box on;
    tests = unique(C.test(:))';
    markers = {'o','s','^'};
    for k = 1:numel(tests)
        S = C(C.test == tests(k),:);
        scatter(S.xeq_expBasis, S.Xloc_NFI_COBRA, 50, markers{min(k,numel(markers))}, 'filled', ...
            'DisplayName', sprintf('Test %d', tests(k)));
    end
    lims = [min([C.xeq_expBasis; C.Xloc_NFI_COBRA],[],'omitnan') max([C.xeq_expBasis; C.Xloc_NFI_COBRA],[],'omitnan')];
    pad = 0.05 * range(lims);
    if pad == 0 || isnan(pad); pad = 0.01; end
    lims = lims + [-pad pad];
    plot(lims, lims, 'k--', 'HandleVisibility','off');
    xlim(lims); ylim(lims);
    xlabel('実験基準 x_{eq}  current\_bundle x\_Mes');
    ylabel('NFI COBRA Xloc');
    title('実験基準x_{eq} と NFI COBRA Xloc の比較');
    legend('Location','best');
    exportgraphics(gcf, outPng, 'Resolution', 200);
    close(gcf);
end

function make_fig_02_delta(C, outPng)
    figure('Color','w','Position',[100 100 900 560]); hold on; grid on; box on;
    tests = unique(C.test(:))';
    markers = {'o','s','^'};
    for k = 1:numel(tests)
        S = C(C.test == tests(k),:);
        scatter(S.case_no, S.delta_xeq_exp_minus_NFI, 50, markers{min(k,numel(markers))}, 'filled', ...
            'DisplayName', sprintf('Test %d', tests(k)));
    end
    yline(0,'k--','HandleVisibility','off');
    xlabel('Case number');
    ylabel('x_{eq,expBasis} - Xloc_{NFI}');
    title('クオリティ定義差のケース別分布');
    legend('Location','best');
    exportgraphics(gcf, outPng, 'Resolution', 200);
    close(gcf);
end

function make_fig_03_distribution(C, outPng)
    figure('Color','w','Position',[100 100 860 560]);
    tests = unique(C.test(:))';
    x = []; y = []; g = [];
    for k = 1:numel(tests)
        S = C(C.test == tests(k),:);
        x = [x; S.xeq_expBasis; S.Xloc_NFI_COBRA]; %#ok<AGROW>
        y = [y; repmat(2*k-1,height(S),1); repmat(2*k,height(S),1)]; %#ok<AGROW>
        g = [g; repmat("exp",height(S),1); repmat("NFI",height(S),1)]; %#ok<AGROW>
    end
    % boxchartが使えない環境も想定して散布＋平均線で表示
    hold on; grid on; box on;
    jitter = (rand(size(y))-0.5)*0.20;
    scatter(y+jitter, x, 28, 'filled');
    for k = 1:numel(tests)
        idx1 = y == 2*k-1;
        idx2 = y == 2*k;
        plot([2*k-1-0.25,2*k-1+0.25], repmat(mean(x(idx1),'omitnan'),1,2), 'k-', 'LineWidth',2);
        plot([2*k-0.25,2*k+0.25], repmat(mean(x(idx2),'omitnan'),1,2), 'k-', 'LineWidth',2);
    end
    xticks(1:2*numel(tests));
    xticklabels(compose('%d exp', repelem(tests,2)));
    labs = strings(1,2*numel(tests));
    for k = 1:numel(tests)
        labs(2*k-1) = sprintf('%d exp', tests(k));
        labs(2*k)   = sprintf('%d NFI', tests(k));
    end
    xticklabels(labs);
    xtickangle(30);
    ylabel('x_{eq} or Xloc');
    title('試験別のクオリティ分布：実験基準 vs NFI COBRA');
    exportgraphics(gcf, outPng, 'Resolution', 200);
    close(gcf);
end

function write_report(reportPath, cfg, C, SUM)
    fid = fopen(reportPath, 'w');
    assert(fid > 0, 'レポートを書き込めません: %s', reportPath);
    cleaner = onCleanup(@() fclose(fid));

    fprintf(fid, '# H52Q-QA-02 バンドル108/161/164のx_eq定義比較\n\n');
    fprintf(fid, '## 目的\n\n');
    fprintf(fid, '- 西田さん側の認識：NFI報告書に記載されたCOBRA-EN出力 `Xloc`。\n');
    fprintf(fid, '- 櫻井側の認識：実験CHF条件から計算した熱平衡クオリティ。\n');
    fprintf(fid, '- 両者をケースごとに横並びにし、108/161/164のクオリティ帯の見え方が変わるか確認する。\n\n');

    fprintf(fid, '## 入力\n\n');
    fprintf(fid, '- current bundle workbook: `%s`\n', cfg.bundleWorkbook);
    fprintf(fid, '- NFI Xloc csv: `%s`\n\n', cfg.nfiCsv);

    fprintf(fid, '## 定義\n\n');
    fprintf(fid, '- `xeq_expBasis`: current_bundleの `x_Mes` 列。実験CHF条件から計算した熱平衡クオリティとして扱う。\n');
    fprintf(fid, '- `Xloc_NFI_COBRA`: NFI報告書の表3.2-3〜3.2-5に記載された、最小DNBR位置の局所熱平衡クオリティ。\n');
    fprintf(fid, '- `delta_xeq_exp_minus_NFI = xeq_expBasis - Xloc_NFI_COBRA`。\n\n');

    fprintf(fid, '## 試験別サマリ\n\n');
    fprintf(fid, '| test | N | mean xeq_expBasis | mean Xloc_NFI | mean delta | median delta | max abs delta | frac exp x<=0 | frac NFI x<=0 |\n');
    fprintf(fid, '|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n');
    for i = 1:height(SUM)
        fprintf(fid, '| %d | %d | %.5f | %.5f | %.5f | %.5f | %.5f | %.3f | %.3f |\n', ...
            SUM.test(i), SUM.N(i), SUM.mean_xeq_expBasis(i), SUM.mean_Xloc_NFI_COBRA(i), ...
            SUM.mean_delta_exp_minus_NFI(i), SUM.median_delta_exp_minus_NFI(i), SUM.max_abs_delta_xeq(i), ...
            SUM.frac_exp_xeq_le_0(i), SUM.frac_NFI_Xloc_le_0(i));
    end
    fprintf(fid, '\n');

    fprintf(fid, '## 読み方\n\n');
    fprintf(fid, '1. `xeq_expBasis` と `Xloc_NFI_COBRA` が同程度なら、両者は同じクオリティ帯を見ている。\n');
    fprintf(fid, '2. `Xloc_NFI_COBRA` が大きく正側、`xeq_expBasis` が負側〜0近傍なら、NFI側の「高クオリティ」という認識はCOBRA最小DNBR位置に依存している可能性がある。\n');
    fprintf(fid, '3. L/DやDNB位置の議論に入る前に、どちらのクオリティ定義を横軸にしているかを明示する。\n');
    fprintf(fid, '4. このrunでは補正式を作らない。クオリティ定義の棚卸しだけを行う。\n\n');

    fprintf(fid, '## 出力\n\n');
    fprintf(fid, '- `QA02_bundle_xeq_definition_compare_v1.xlsx`\n');
    fprintf(fid, '- `fig_QA02_01_xeq_expBasis_vs_NFI_Xloc.png`\n');
    fprintf(fid, '- `fig_QA02_02_delta_xeq_by_case.png`\n');
    fprintf(fid, '- `fig_QA02_03_xeq_distribution_by_test.png`\n');
end
