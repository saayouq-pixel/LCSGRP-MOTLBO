function sol = createSolutionAlgorithm1(problem)
% createSolutionAlgorithm1 - Algorithm 1: Initial Operator Allocation
%
% Used identically by ALL algorithms (MOTLBO, NSGA-II, SPEA2, MOPSO).
% No shuffle: adjacency logic is preserved.
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    R = problem.Rounds;
    J = problem.NoS;
    I = problem.NoO;

    NO          = randi([2, min(I, J)]);
    selectedOps = randperm(I, NO);

    sol.Assignment = zeros(R, J);

    for r = 1:R
        assignment = zeros(1, J);

        seedIdx = randperm(J, NO);
        assignment(seedIdx) = selectedOps;

        remaining = setdiff(1:J, seedIdx);
        for j = remaining
            direction = randi(3);
            switch direction
                case 1
                    src = max(1, j - 1);
                case 2
                    src = min(J, j + 1);
                case 3
                    src = J + 1 - j;
                    if src < 1 || src > J
                        src = seedIdx(randi(NO));
                    end
            end
            if assignment(src) == 0
                src = seedIdx(randi(NO));
            end
            assignment(j) = assignment(src);
        end

        % NO shuffle — preserves adjacency logic
        sol.Assignment(r, :) = assignment;
    end

    sol = evaluateSolution(sol, problem);
    if ~sol.feasible
        [~, t] = evaluateSolution(sol, problem);
        sol    = repairSolution(sol, problem, t);
        sol    = evaluateSolution(sol, problem);
    end
end