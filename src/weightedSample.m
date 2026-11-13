function idx = weightedSample(weights)
% weightedSample - Manual weighted sampling without Statistics Toolbox
%
% Author: Project Team
% Date:   2026-10-15
% Version: 1.0 (Validator-recommended: replaces randsample)

    weights = weights(:)';
    n       = numel(weights);

    if n == 0
        error('weightedSample: empty weights');
    end

    if any(weights < 0)
        error('weightedSample: negative weights');
    end

    total = sum(weights);
    if total <= 0
        idx = randi(n);
        return;
    end

    cumW = cumsum(weights);
    r    = rand * total;
    idx  = find(cumW >= r, 1, 'first');

    if isempty(idx)
        idx = n;
    end
end