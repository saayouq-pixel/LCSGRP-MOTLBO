function hv = computeHV(Z1, Z2, refPoint)
% computeHV - 2D Hypervolume indicator
%
% Author: Project Team
% Date:   2026-10-15

    pts = [Z1(:), Z2(:)];
    pts = pts(all(pts < refPoint, 2), :);
    if isempty(pts), hv = 0; return; end

    [s1, idx] = sort(pts(:, 1));
    s2        = pts(idx, 2);

    hv       = 0;
    prevZ2   = refPoint(2);
    for i = 1:size(s1, 1)
        if s2(i) < prevZ2
            hv     = hv + (refPoint(1) - s1(i)) * (prevZ2 - s2(i));
            prevZ2 = s2(i);
        end
    end
end