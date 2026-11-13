function [sol, t] = evaluateSolution(sol, problem)
% evaluateSolution - Compute Z1, Z2, Z3 and feasibility
%
% Returns:
%   sol - updated solution with .Z1, .Z2, .Z3, .feasible
%   t   - I x J x R tensor of processing times (optional second output)
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    I    = problem.NoO;
    J    = problem.NoS;
    R    = problem.Rounds;
    LAP  = problem.LAP;
    Takt = problem.Takt;
    q    = problem.q;
    A    = sol.Assignment;

    % --- Learning dynamics: t(i,j,r) with LAP threshold ---
    t           = zeros(I, J, R);
    t(:, :, 1)  = problem.t0;
    consecutive = zeros(I, J);

    for r = 1:R
        for i = 1:I
            for j = 1:J
                if A(r, j) == i
                    consecutive(i, j) = consecutive(i, j) + 1;
                else
                    consecutive(i, j) = 0;
                end
            end
        end

        if r > 1
            for i = 1:I
                for j = 1:J
                    if consecutive(i, j) >= LAP && A(r, j) == i
                        t(i, j, r) = t(i, j, r-1) - ...
                            (t(i, j, r-1) - problem.tmin(j)) * problem.alpha(i);
                    else
                        t(i, j, r) = t(i, j, r-1);
                    end
                end
            end
        end
    end

    % --- Operators used ---
    opsUsed = unique(A(:));
    W       = numel(opsUsed);

    % --- Z1: Skill recovery (final period, normalized by W*J) ---
    Z1_sum = 0;
    for j = 1:J
        i     = A(R, j);
        denom = problem.t0(i, j) - problem.tmin(j);
        if denom > 1e-9
            Z1_sum = Z1_sum + (t(i, j, R) - problem.tmin(j)) / denom;
        end
    end
    sol.Z1 = Z1_sum / max(W * J, 1);

    % --- Z2: Takt compliance + feasibility (Constraint 21) ---
    Z2_sum       = 0;
    sol.feasible = true;
    for r = 1:R
        cycleTimes = zeros(W, 1);
        for k = 1:W
            i        = opsUsed(k);
            ct       = 0;
            numTasks = 0;
            for j = 1:J
                if A(r, j) == i
                    ct       = ct + t(i, j, r);
                    numTasks = numTasks + 1;
                end
            end
            cycleTimes(k) = ct + q * numTasks;
        end
        cmin   = min(cycleTimes);
        Z2_sum = Z2_sum + (Takt - cmin) / (R * Takt);

        if max(cycleTimes) > Takt + 1e-6
            sol.feasible = false;
        end
    end
    sol.Z2 = max(0, Z2_sum);

    % --- Z3: Monitoring metric ---
    alphaSum = sum(problem.alpha);
    if alphaSum > 0
        sol.Z3 = sum(problem.alpha(setdiff(1:I, opsUsed))) / alphaSum;
    else
        sol.Z3 = 0;
    end
end