function [paretoFront, history] = NSGA2(problem, popSize, maxGen, seed)
% NSGA2 - Non-dominated Sorting Genetic Algorithm II
%
% Uses shared initialization (Algorithm 1) and repair-based constraint handling.
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    if nargin >= 4 && ~isempty(seed)
        rng(seed, 'twister');
    end

    fprintf('Running NSGA-II...\n');
    population = initializePopulation(problem, popSize);
    history    = zeros(maxGen, 3);

    for gen = 1:maxGen
        [fronts, ranks] = nonDominatedSorting(population);

        crowdDist = zeros(popSize, 1);
        for f = 1:numel(fronts)
            cd = crowdingDistance(fronts{f}, population);
            crowdDist(fronts{f}) = cd;
        end

        offspring = cell(popSize, 1);
        for i = 1:popSize
            p1    = tournamentSelection(ranks, crowdDist);
            p2    = tournamentSelection(ranks, crowdDist);
            child = crossover(population{p1}, population{p2}, problem);
            child = mutate(child, problem, 0.1);
            if ~child.feasible
                [~, t] = evaluateSolution(child, problem);
                child  = repairSolution(child, problem, t);
                child  = evaluateSolution(child, problem);
            end
            offspring{i} = child;
        end

        combined     = [population; offspring];
        [fronts2, ~] = nonDominatedSorting(combined);

        newPop = cell(0, 1);
        for f = 1:numel(fronts2)
            if numel(newPop) + numel(fronts2{f}) <= popSize
                newPop = [newPop; combined(fronts2{f})]; %#ok<AGROW>
            else
                cd = crowdingDistance(fronts2{f}, combined);
                [~, idx]  = sort(cd, 'descend');
                remaining = popSize - numel(newPop);
                newPop    = [newPop; combined(fronts2{f}(idx(1:remaining)))]; %#ok<AGROW>
                break;
            end
        end
        population = newPop;

        Z1v = cellfun(@(s) s.Z1, population);
        Z2v = cellfun(@(s) s.Z2, population);
        history(gen, :) = [min(Z1v), min(Z2v), mean(Z1v + Z2v)];
    end

    [fronts, ~] = nonDominatedSorting(population);
    paretoFront = population(fronts{1});
end

function idx = tournamentSelection(ranks, crowdDist)
    n  = numel(ranks);
    i1 = randi(n); i2 = randi(n);
    if ranks(i1) < ranks(i2)
        idx = i1;
    elseif ranks(i1) > ranks(i2)
        idx = i2;
    else
        if crowdDist(i1) >= crowdDist(i2)
            idx = i1;
        else
            idx = i2;
        end
    end
end