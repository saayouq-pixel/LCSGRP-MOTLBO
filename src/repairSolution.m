function sol = repairSolution(sol, problem, t)
% repairSolution - Repair infeasible solutions (Constraint 21: Takt)
%
% Uses actual processing times t (not t0) to avoid false repair.
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    Takt = problem.Takt;
    R    = problem.Rounds;
    J    = problem.NoS;
    I    = problem.NoO;
    q    = problem.q;

    if nargin < 3 || isempty(t)
        [~, t] = evaluateSolution(sol, problem);
    end

    for r = 1:R
        maxIter = 100;
        for iter = 1:maxIter
            opsUsed = unique(sol.Assignment(r, :));
            nOps    = numel(opsUsed);
            cts     = zeros(nOps, 1);

            for k = 1:nOps
                i     = opsUsed(k);
                tasks = find(sol.Assignment(r, :) == i);
                cts(k) = sum(t(i, tasks, r)) + q * numel(tasks);
            end

            [maxCt, maxIdx] = max(cts);
            if maxCt <= Takt + 1e-6
                break;
            end

            overloaded = opsUsed(maxIdx);
            tasks      = find(sol.Assignment(r, :) == overloaded);
            if numel(tasks) <= 1
                break;
            end

            moved  = false;
            unused = setdiff(1:I, opsUsed);

            for jMove = tasks(end:-1:1)
                for newOp = unused
                    if t(newOp, jMove, r) + q <= Takt
                        sol.Assignment(r, jMove) = newOp;
                        moved = true;
                        break;
                    end
                end
                if moved, break; end

                for k = 1:nOps
                    i2 = opsUsed(k);
                    if i2 == overloaded, continue; end
                    tasks2 = find(sol.Assignment(r, :) == i2);
                    ct2    = sum(t(i2, tasks2, r)) + q * numel(tasks2);
                    if ct2 + t(i2, jMove, r) + q <= Takt
                        sol.Assignment(r, jMove) = i2;
                        moved = true;
                        break;
                    end
                end
                if moved, break; end
            end

            if ~moved, break; end
        end
    end
end