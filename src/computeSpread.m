function spread = computeSpread(Z1, Z2)
% computeSpread - Spread (Delta) metric
%
% Author: Project Team
% Date:   2026-10-15

    n = numel(Z1);
    if n < 2, spread = Inf; return; end
    pts    = sortrows([Z1(:), Z2(:)], 1);
    dists  = zeros(n-1, 1);
    for i = 1:n-1
        dists(i) = hypot(pts(i+1,1)-pts(i,1), pts(i+1,2)-pts(i,2));
    end
    dMean = mean(dists);
    if dMean < 1e-12
        spread = Inf;
    else
        spread = sum(abs(dists - dMean)) / ((n-1) * dMean);
    end
end