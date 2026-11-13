function d = dominates(sol1, sol2)
% dominates - Pareto dominance in minimization (Z1, Z2)
%
% Author: Project Team
% Date:   2026-10-15

    d = (sol1.Z1 <= sol2.Z1) && (sol1.Z2 <= sol2.Z2) && ...
        (sol1.Z1 <  sol2.Z1 || sol1.Z2 < sol2.Z2);
end