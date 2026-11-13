function igd = computeIGD(Z1, Z2, refFront)
% computeIGD - Inverted Generational Distance
%
% Author: Project Team
% Date:   2026-10-15

    if isempty(refFront), igd = Inf; return; end
    d = zeros(size(refFront, 1), 1);
    for i = 1:size(refFront, 1)
        d(i) = min(hypot(Z1 - refFront(i,1), Z2 - refFront(i,2)));
    end
    igd = mean(d);
end