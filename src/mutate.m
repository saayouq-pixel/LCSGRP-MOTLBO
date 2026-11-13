function mutant = mutate(sol, problem, mutationRate)
% mutate - Random reassignment of workstations with repair
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    mutant = sol;
    R = problem.Rounds;
    J = problem.NoS;
    I = problem.NoO;

    for r = 1:R
        for j = 1:J
            if rand < mutationRate
                mutant.Assignment(r, j) = randi(I);
            end
        end
    end

    mutant = evaluateSolution(mutant, problem);
    if ~mutant.feasible
        [~, t] = evaluateSolution(mutant, problem);
        mutant  = repairSolution(mutant, problem, t);
        mutant  = evaluateSolution(mutant, problem);
    end
end