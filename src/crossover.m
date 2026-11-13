function child = crossover(parent1, parent2, problem)
% crossover - Uniform period-wise crossover with repair
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved: adds repair)

    child = parent1;
    R     = problem.Rounds;

    for r = 1:R
        if rand < 0.5
            child.Assignment(r, :) = parent2.Assignment(r, :);
        end
    end

    child = evaluateSolution(child, problem);
    if ~child.feasible
        [~, t] = evaluateSolution(child, problem);
        child  = repairSolution(child, problem, t);
        child  = evaluateSolution(child, problem);
    end
end