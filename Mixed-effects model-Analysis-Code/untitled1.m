%% =====================================================
% Mixed-effects modelling of stiffness–displacement relationships across single-cell measurements.
%
% Purpose:This script performs linear mixed-effects regression for nested datasets in which multiple measurements
% originate from individual cells and biological replicates.
%
% Model:
%   stiffness ~ displacement
%              + (1|Replicate)
%              + (1|Replicate:CellID)
%
% Input:
%   Excel file containing stiffness-displacement measurements.  
%
% Required columns:
%   Replicate
%   CellID
%   displacement
%   stiffness
%
% Output: Statistical summary and publication-quality 
%         regression plots for each sheet.
%% =====================================================

clear
clc
close all

%  Import dataset  

fileName = 'noncancer cell.xlsx';
sheetNames = {'prometaphase','metaphase'};

% Iterate through each dataset (sheet)

for s = 1:length(sheetNames)

    sheet = sheetNames{s};

   
   %% -------------------------------------------------
    % Load dataset
    %
    % Each row corresponds to a single measurement.
    %
    % Replicate:
    %   biological/experimental replicate
    %
    % CellID:
    %   cell identifier within a replicate
    %
    % This hierarchical structure allows mixed-effects
    % modelling of nested measurements.
    %% ---
    T = readtable(fileName, 'Sheet', sheet);

    names = T.Properties.VariableNames;
    dispVar  = names{contains(lower(names), 'disp')};
    stiffVar = names{contains(lower(names), 'stiff')};

    T.Replicate = categorical(T.Replicate);
    T.CellID    = categorical(T.CellID);

    xData = T.(dispVar);
    yData = T.(stiffVar);

     %% -------------------------------------------------
    % Linear mixed-effects model
    %
    % Model structure:
    %
    % stiffness ~ displacement
    %            + (1|Replicate)
    %            + (1|Replicate:CellID)
    %
    % Fixed effect:
    %   Population-level relationship between
    %   displacement and stiffness.
    %
    % Random effects:
    %   Replicate-specific intercept
    %   Cell-specific intercept nested within
    %   each replicate
    %
    % This model evaluates whether stiffness changes
    % systematically with displacement while accounting
    % for biological variability.
    %% -------------------------------------------------
    formula = sprintf('%s ~ %s + (1|Replicate) + (1|Replicate:CellID)', ...
                      stiffVar, dispVar);

    lme = fitlme(T, formula);

    %% -------------------------------------------------
    % Extract fixed-effect estimates
    %% -------------------------------------------------

    coefTable = lme.Coefficients;
    beta0 = coefTable.Estimate(1);
    beta1 = coefTable.Estimate(2);
    pValue = coefTable.pValue(2);
    CI = coefCI(lme);
    slopeCI = CI(2,:);

    %% -----------------------------
    % Plotting
    %% -----------------------------
    fig = figure('Color','w');   % white background
    fig.Position(3) = 800;   % width
    fig.Position(4) = 600;   % height
    hold on

    % Scatter Plot Drawing (Filled red )
    scatter(xData, yData, 80, 'filled', ...
            'MarkerFaceColor', [0.8 0 0], ...
            'MarkerEdgeColor', 'none');

    %% -----------------------------
    % If p ≤ 0.05, plot the regression line along with its confidence band
    %% -----------------------------
    if pValue <= 0.05
        xfit = linspace(min(xData), max(xData), 200)';

        Xnew = table( ...
            xfit, ...
            repmat(T.Replicate(1), length(xfit), 1), ...
            repmat(T.CellID(1), length(xfit), 1), ...
            'VariableNames', {dispVar, 'Replicate', 'CellID'} ...
        );

        [y_pred, y_ci] = predict(lme, Xnew, ...
                                 'Conditional', false, ...
                                 'Prediction', 'curve');

        fill([xfit; flipud(xfit)], ...
             [y_ci(:,1); flipud(y_ci(:,2))], ...
             [1 0.8 0.8], ...
             'EdgeColor', 'none', ...
             'FaceAlpha', 0.4);

        plot(xfit, y_pred, 'Color', [0.8 0 0], 'LineWidth', 3)
    end

    %% -----------------------------
    % Axis settings
    %% -----------------------------
    xlabel(dispVar, 'FontSize', 12)
    ylabel(stiffVar, 'FontSize', 12)
    title(sheet, 'FontSize', 14)

    ax = gca;
    ax.Box = 'off';
    ax.XAxisLocation = 'bottom';
    ax.YAxisLocation = 'left';
    grid off

    % Left axis: 0–1000, major tick = 200, minor tick = 100
    ax.YLim = [0 1000];
    ax.YTick = 0:200:1000;
    ax.YMinorTick = 'on';
    ax.YAxis.MinorTickValues = 0:100:1000;

    % Bottom axis: -400–1200, major tick = 200, minor tick = 100
    ax.XLim = [-400 1200];
    ax.XTick = -400:200:1200;
    ax.XMinorTick = 'on';
    ax.XAxis.MinorTickValues = -400:100:1200;
    ax.TickDir = 'out';

    %% -----------------------------
    % Text annotation 
    %% -----------------------------
    txt = sprintf(['y = %.3f + %.3fx\n' ...
                   '95%% CI = [%.3f, %.3f]\n' ...
                   'p = %.3g'], ...
                   beta0, beta1, slopeCI(1), slopeCI(2), pValue);

    text(ax.XLim(1) + 20, 950, txt, ...
         'FontSize', 11, 'BackgroundColor', 'w');

    legend off

    %% -----------------------------
    % Export figures
    %% -----------------------------
    % 1. PNG
    saveas(fig, [sheet '_MixedModel_final.png']);

    % 2. PDF
    print(fig, [sheet '_MixedModel_final.pdf'], '-dpdf');


end
