function gbest = selectGbest(archive)
% selectGbest - Roulette-wheel selection from archive (PESA-II style)
%
% Uses manual weightedSample (no Statistics Toolbox dependency).
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    n = numel(archive);
    if n == 0
        gbest = [];
        return;
    elseif n == 1
        gbest = archive{1};
        return;
    end

    cd     = crowdingDistance(1:n, archive);
    finite = cd(~isinf(cd));

    if isempty(finite)
        idx = randi(n);
    else
        cd(isinf(cd)) = max(finite) * 2;
        probs = cd / sum(cd);
        idx   = weightedSample(probs);
    end

    gbest = archive{idx};
end