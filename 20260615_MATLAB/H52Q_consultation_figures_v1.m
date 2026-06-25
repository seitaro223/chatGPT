%% H52Q_consultation_figures_v1.m
% 相談用Word資料に入れる図を作成するためのMATLABスクリプト
%
% 出力図：
%   図1: 現行F1とTsubの関係
%   図2: 単管Table9-12とバンドル108/161/164のL/D-Tsub関係（概念整理）
%   図3: 単管・バンドルのL/Dオーダー比較
%
% 注意：
%   このスクリプトは「相談資料用の説明図」を作るためのものです。
%   表1で使う概数・ログで確認した代表値を用いています。
%   厳密な全点プロット版が必要な場合は、Excel入力ブックから列を読み取る版を別途作成してください。
%
% F1_fixed:
%   F1 = 1 + 0.053 * exp(-(Tsub - 40)^2 / 5625)

clear; clc; close all;

%% Settings
A     = 0.053;
T0    = 40;
sigma = 5625;

ts = datestr(now, 'yyyymmdd_HHMMSS');
outDir = ['H52Q_consult_figures_' ts];
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Font settings for Japanese labels
fontName = 'Yu Gothic';
set(groot, 'defaultAxesFontName', fontName);
set(groot, 'defaultTextFontName', fontName);
set(groot, 'defaultLegendFontName', fontName);

%% =========================================================
% Figure 1: F1 vs Tsub
% =========================================================
Tsub = linspace(0, 350, 1000);
F1 = 1 + A .* exp(-((Tsub - T0).^2) ./ sigma);

% Representative points used in the explanation
repName = {'F1中心 40 K', 'Table10代表 50-60 K', 'F1有効域上限目安 80 K', ...
           'Table11 long 約319 K', 'Table12 long 約328 K'};
repTsub = [40, 55, 80, 319, 328];
repF1   = 1 + A .* exp(-((repTsub - T0).^2) ./ sigma);

fig = figure('Color','w','Position',[100 100 980 620]);
hold on; box on; grid on;

% Effective and stuck guide areas
yl = [0.995 1.058];
patch([20 80 80 20], [yl(1) yl(1) yl(2) yl(2)], [0.90 0.95 1.00], ...
    'EdgeColor','none', 'FaceAlpha',0.45, 'DisplayName','F1が効きやすい目安');
patch([250 350 350 250], [yl(1) yl(1) yl(2) yl(2)], [0.95 0.95 0.95], ...
    'EdgeColor','none', 'FaceAlpha',0.55, 'DisplayName','F1ほぼ張り付き領域');

plot(Tsub, F1, 'LineWidth', 2.4, 'Color',[0 0.25 0.70], 'DisplayName','F1(Tsub)');
yline(1.0, '--', 'F1=1', 'LineWidth',1.2, 'Color',[0.25 0.25 0.25], 'LabelHorizontalAlignment','left');
xline(40, ':', '40 K', 'LineWidth',1.2, 'Color',[0.30 0.30 0.30]);
xline(300, ':', '300 K級', 'LineWidth',1.2, 'Color',[0.55 0.20 0.20]);

scatter(repTsub, repF1, 58, 'filled', 'MarkerFaceColor',[0.85 0.20 0.15], ...
    'MarkerEdgeColor','w', 'DisplayName','代表点');

for i = 1:numel(repTsub)
    if repTsub(i) < 100
        dx = 5; dy = 0.002;
    else
        dx = -80; dy = 0.004 + 0.002*(i-4);
    end
    text(repTsub(i)+dx, repF1(i)+dy, repName{i}, 'FontSize',10, 'Color',[0.15 0.15 0.15]);
end

xlabel('入口サブクール度 Tsub [K]');
ylabel('現行F1補正係数 [-]');
title('図1　現行F1とTsubの関係');
subtitle('F1は40 K付近で最大となり、大Tsub側ではほぼ1に張り付く');
xlim([0 350]);
ylim(yl);
legend('Location','northeast');
set(gca, 'FontSize',11);

saveFig(fig, fullfile(outDir, 'fig01_F1_vs_Tsub'));

%% =========================================================
% Figure 2: L/D and Tsub relation map
% =========================================================
% Consultation-level representative values from the working interpretation.
% Table11/12 long Tsub are based on log summaries around 319 K and 328 K.
caseName = {'Table9 低〜中L/D', 'Table9 大L/D側', ...
            'Table10', ...
            'Table11 低〜中L/D', 'Table11 大L/D', ...
            'Table12 低〜中L/D', 'Table12 大L/D'};
caseTable = {'T9','T9','T10','T11','T11','T12','T12'};
LD_rep   = [70, 350, 70, 70, 350, 70, 350];
Tsub_rep = [100, 300, 55, 100, 319, 105, 328];

fig = figure('Color','w','Position',[100 100 980 650]);
hold on; box on; grid on;

% Shade F1-effective Tsub band and high-Tsub region
patch([0 400 400 0], [20 20 80 80], [0.90 0.95 1.00], ...
    'EdgeColor','none','FaceAlpha',0.45, 'DisplayName','Tsub 20〜80 K：F1が効きやすい目安');
patch([0 400 400 0], [250 250 350 350], [0.95 0.95 0.95], ...
    'EdgeColor','none','FaceAlpha',0.55, 'DisplayName','大Tsub：F1ほぼ張り付き');

% Bundle L/D order reference
xline(150, '--', '108バンドル目安', 'LineWidth',1.4, 'Color',[0.20 0.55 0.20], ...
    'LabelVerticalAlignment','bottom', 'LabelHorizontalAlignment','left');
xline(350, '--', '161/164バンドル目安', 'LineWidth',1.4, 'Color',[0.55 0.20 0.20], ...
    'LabelVerticalAlignment','bottom', 'LabelHorizontalAlignment','left');

% Plot by table
plotByTable(LD_rep, Tsub_rep, caseTable, 'T9',  [0.20 0.40 0.80], 'o');
plotByTable(LD_rep, Tsub_rep, caseTable, 'T10', [0.10 0.55 0.20], 's');
plotByTable(LD_rep, Tsub_rep, caseTable, 'T11', [0.85 0.45 0.10], '^');
plotByTable(LD_rep, Tsub_rep, caseTable, 'T12', [0.75 0.15 0.15], 'd');

for i = 1:numel(caseName)
    text(LD_rep(i)+7, Tsub_rep(i)+5, caseName{i}, 'FontSize',9, 'Color',[0.15 0.15 0.15]);
end

xlabel('L/Dの目安 [-]');
ylabel('Tsubの目安 [K]');
title('図2　L/Dを大きくするとTsubも大きくなる問題');
subtitle('大L/Dデータは有用だが、Table11/12では大Tsubとなり現行F1がほぼ効かない');
xlim([0 400]);
ylim([0 350]);
legend('Location','northwest');
set(gca, 'FontSize',11);

saveFig(fig, fullfile(outDir, 'fig02_LD_Tsub_map'));

%% =========================================================
% Figure 3: L/D order comparison
% =========================================================
label = {'Table10', 'Table9', 'Table11', 'Table12', '108 bundle', '161/164 bundle'};
lo = [60, 60, 60, 60, 150, 350];
hi = [80, 350, 350, 350, 190, 360];
n = numel(label);

y = n:-1:1;
fig = figure('Color','w','Position',[100 100 980 560]);
hold on; box on; grid on;

for i = 1:n
    if contains(label{i}, 'bundle')
        col = [0.20 0.50 0.20];
        lw = 5;
    elseif strcmp(label{i}, 'Table10')
        col = [0.10 0.45 0.75];
        lw = 5;
    else
        col = [0.80 0.35 0.10];
        lw = 5;
    end
    plot([lo(i) hi(i)], [y(i) y(i)], '-', 'LineWidth',lw, 'Color',col);
    plot(lo(i), y(i), 'o', 'MarkerFaceColor',col, 'MarkerEdgeColor','w', 'MarkerSize',8);
    plot(hi(i), y(i), 'o', 'MarkerFaceColor',col, 'MarkerEdgeColor','w', 'MarkerSize',8);
    if lo(i) == hi(i)
        txt = sprintf('%.0f', lo(i));
    else
        txt = sprintf('%.0f〜%.0f', lo(i), hi(i));
    end
    text(hi(i)+8, y(i), txt, 'VerticalAlignment','middle', 'FontSize',10, 'Color',[0.15 0.15 0.15]);
end

xline(150, '--', '108目安', 'LineWidth',1.2, 'Color',[0.25 0.55 0.25]);
xline(350, '--', '161/164目安', 'LineWidth',1.2, 'Color',[0.55 0.20 0.20]);

set(gca, 'YTick', y, 'YTickLabel', label, 'YDir','normal');
xlabel('L/DまたはL/DHの目安 [-]');
title('図3　単管データとバンドルデータのL/Dオーダー比較');
subtitle('Table10だけでは大L/D側を確認できない。Table11/12は大L/Dを含むが大Tsubと交絡する');
xlim([0 410]);
ylim([0.4 n+0.6]);
set(gca, 'FontSize',11);

saveFig(fig, fullfile(outDir, 'fig03_LD_coverage'));

%% Finish
fprintf('\nDONE. Figures saved in: %s\n', outDir);
fprintf('  fig01_F1_vs_Tsub.png\n');
fprintf('  fig02_LD_Tsub_map.png\n');
fprintf('  fig03_LD_coverage.png\n');

%% Local functions
function saveFig(fig, basePath)
    % Save PNG for Word and PDF for vector backup.
    pngPath = [basePath '.png'];
    pdfPath = [basePath '.pdf'];
    try
        exportgraphics(fig, pngPath, 'Resolution', 300);
        exportgraphics(fig, pdfPath, 'ContentType','vector');
    catch
        print(fig, pngPath, '-dpng', '-r300');
        try
            print(fig, pdfPath, '-dpdf', '-painters');
        catch
            % ignore pdf failure on older environments
        end
    end
end

function plotByTable(LD, Tsub, tbl, target, color, marker)
    idx = strcmp(tbl, target);
    scatter(LD(idx), Tsub(idx), 80, marker, 'filled', ...
        'MarkerFaceColor', color, 'MarkerEdgeColor','w', 'DisplayName', target);
end
