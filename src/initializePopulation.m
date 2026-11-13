function population = initializePopulation(problem, popSize)
% initializePopulation - Shared initialization for ALL algorithms
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1

    population = cell(popSize, 1);
    for i = 1:popSize
        population{i} = createSolutionAlgorithm1(problem);
    end
end