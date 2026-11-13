function metrics = computeMetrics(results, problem)
% computeMetrics - Compute HV, IGD, Spread for each algorithm
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1

    refPoint = [1.5, 1.5];

    allFronts = [results.NSGA2; results.SPEA2; results.MOPSO];
    refFront  = extractReferenceFront(allFronts);

    algNames = fieldnames(results);
    metrics  = struct();

    for a = 1:numel(algNames)
        alg    = algNames{a};
        fronts = results.(alg);

        nRuns   = numel(fronts);
        HVv     = zeros(nRuns, 1);
        IGDv    = zeros(nRuns, 1);
        Spreadv = zeros(nRuns, 1);

        for run = 1:nRuns
            pf = fronts{run};
            if isempty(pf)
                HVv(run) = 0; IGDv(run) = Inf; Spreadv(run) = Inf;
                continue;
            end
            Z1 = cellfun(@(s) s.Z1, pf);
            Z2 = cellfun(@(s) s.Z2, pf);
            HVv(run)     = computeHV(Z1, Z2, refPoint);
            IGDv(run)    = computeIGD(Z1, Z2, refFront);
            Spreadv(run) = computeSpread(Z1, Z2);
        end

        metrics.(alg).HV         = mean(HVv);
        metrics.(alg).IGD        = mean(IGDv);
        metrics.(alg).Spread     = mean(Spreadv);
        metrics.(alg).HV_std     = std(HVv);
        metrics.(alg).IGD_std    = std(IGDv);
        metrics.(alg).Spread_std = std(Spreadv);
    end
end