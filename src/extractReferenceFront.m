function refFront = extractReferenceFront(allFronts)
% extractReferenceFront - Non-dominated front across all solutions
%
% Author: Project Team
% Date:   2026-10-15

    allSol = {};
    for i = 1:numel(allFronts)
        pf = allFronts{i};
        if iscell(pf)
            for j = 1:numel(pf)
                allSol{end+1} = pf{j}; %#ok<AGROW>
            end
        end
    end

    if isempty(allSol)
        refFront = [];
        return;
    end

    [fronts, ~] = nonDominatedSorting(allSol);
    best        = allSol(fronts{1});
    refFront    = zeros(numel(best), 2);
    for i = 1:numel(best)
        refFront(i, :) = [best{i}.Z1, best{i}.Z2];
    end
end