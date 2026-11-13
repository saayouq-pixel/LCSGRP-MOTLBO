function distances = crowdingDistance(front, population)
% crowdingDistance - Standard NSGA-II crowding distance
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1

    n         = numel(front);
    distances = zeros(n, 1);

    if n <= 2
        distances(:) = Inf;
        return;
    end

    Z1 = zeros(n, 1);
    Z2 = zeros(n, 1);
    for k = 1:n
        Z1(k) = population{front(k)}.Z1;
        Z2(k) = population{front(k)}.Z2;
    end

    [~, idx1] = sort(Z1);
    [~, idx2] = sort(Z2);

    distances(idx1(1))   = Inf;
    distances(idx1(end)) = Inf;
    distances(idx2(1))   = Inf;
    distances(idx2(end)) = Inf;

    r1 = max(Z1) - min(Z1);
    r2 = max(Z2) - min(Z2);

    if r1 > 1e-12
        for k = 2:n-1
            distances(idx1(k)) = distances(idx1(k)) + ...
                (Z1(idx1(k+1)) - Z1(idx1(k-1))) / r1;
        end
    end
    if r2 > 1e-12
        for k = 2:n-1
            distances(idx2(k)) = distances(idx2(k)) + ...
                (Z2(idx2(k+1)) - Z2(idx2(k-1))) / r2;
        end
    end
end