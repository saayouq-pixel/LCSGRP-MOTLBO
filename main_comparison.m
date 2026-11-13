% main_comparison.m
% Fair comparison of MOTLBO with NSGA-II, SPEA2, MOPSO
%
% All algorithms share: Algorithm 1 initialization + repair-based handling
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved: datetime instead of datestr)

clear; clc; close all;

addpath(genpath('src'));

%% Problem setup
problem = createProblem(10, 10, 10, 3, 200);

popSize = 500;
maxGen  = 1000;
numRuns = 30;

%% Algorithm list
algorithms = {'MOTLBO', 'NSGA2', 'SPEA2', 'MOPSO'};
nAlgs      = numel(algorithms);

%% Storage
results = struct();
for a = 1:nAlgs
    results.(algorithms{a}) = cell(numRuns, 1);
end

%% Metadata
metadata               = struct();
metadata.timestamp     = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
metadata.matlabVer     = version;
metadata.computer      = computer;
metadata.problem       = problem;
metadata.popSize       = popSize;
metadata.maxGen        = maxGen;
metadata.numRuns       = numRuns;
metadata.seeds         = 1:numRuns;

%% Independent runs
for run = 1:numRuns
    fprintf('\n========== Run %d/%d ==========\n', run, numRuns);
    seed = run;

    for a = 1:nAlgs
        algName = algorithms{a};
        try
            switch algName
                case 'MOTLBO'
                    [pf, ~] = MOTLBO(problem, popSize, maxGen, seed);
                case 'NSGA2'
                    [pf, ~] = NSGA2(problem, popSize, maxGen, seed);
                case 'SPEA2'
                    [pf, ~] = SPEA2(problem, popSize, popSize, maxGen, seed);
                case 'MOPSO'
                    [pf, ~] = MOPSO(problem, popSize, maxGen, seed);
            end
            results.(algName){run} = pf;
        catch ME
            warning('Run %d, %s failed: %s', run, algName, ME.message);
            results.(algName){run} = [];
        end
    end
end

%% Metrics
fprintf('\n========== Computing Metrics ==========\n');
try
    metrics = computeMetrics(results, problem);
catch ME
    warning('Metrics computation failed: %s', ME.message);
    metrics = struct();
end

%% Report
fprintf('\n========== Performance Metrics (Avg over %d runs) ==========\n', numRuns);
fprintf('%-10s | HV (std)          | IGD (std)         | Spread (std)\n', 'Algorithm');
fprintf('%s\n', repmat('-', 1, 75));

for a = 1:nAlgs
    algName = algorithms{a};
    if isfield(metrics, algName)
        m = metrics.(algName);
        fprintf('%-10s | %.4f (%.4f)   | %.4f (%.4f)   | %.4f (%.4f)\n', ...
            algName, m.HV, m.HV_std, m.IGD, m.IGD_std, m.Spread, m.Spread_std);
    end
end

%% Save
save('comparisonResults.mat', 'results', 'metrics', 'problem', 'metadata');
fprintf('\nResults saved to comparisonResults.mat\n');