function [paretoFront, history] = SPEA2(problem, popSize, archiveSize, maxGen, seed)
% SPEA2 - Strength Pareto Evolutionary Algorithm 2
%
% Uses shared initialization (Algorithm 1) and repair-based constraint handling.
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    if nargin >= 5 && ~isempty(seed)
        rng(seed, 'twister');
    end

    fprintf('Running SPEA2...\n');
    population = initializePopulation(problem, popSize);
    archive    = {};
    history    = zeros(maxGen, 3);

    for gen = 1:maxGen
        combined = [population; archive];
        N        = numel(combined);

        strength = zeros(N, 1);
        for i = 1:N
            for j = 1:N
                if i ~= j && dominates(combined{i}, combined{j})
                    strength(i) = strength(i) + 1;
                end
            end
        end

        rawFit = zeros(N, 1);
        for i = 1:N
            for j = 1:N
                if i ~= j && dominates(combined{j}, combined{i})
                    rawFit(i) = rawFit(i) + strength(j);
                end
            end
        end

        k       = max(1, floor(sqrt(N)));
        density = zeros(N, 1);
        for i = 1:N
            d = zeros(N, 1);
            for j = 1:N
                if i ~= j
                    d(j) = hypot(combined{i}.Z1 - combined{j}.Z1, ...
                                 combined{i}.Z2 - combined{j}.Z2);
                else
                    d(j) = Inf;
                end
            end
            dSort      = sort(d);
            density(i) = 1 / (dSort(k) + 2);
        end
        fitness = rawFit + density;

        nonDom = find(rawFit == 0);
        if numel(nonDom) <= archiveSize
            archive   = combined(nonDom);
            dominated = setdiff(1:N, nonDom);
            [~, idx]  = sort(fitness(dominated));
            needed    = archiveSize - numel(nonDom);
            if needed > 0
                take = min(needed, numel(idx));
                archive = [archive; combined(dominated(idx(1:take)))]; %#ok<AGROW>
            end
        else
            [~, idx] = sort(fitness(nonDom));
            archive  = combined(nonDom(idx(1:archiveSize)));
        end

        if isempty(archive), archive = population; end

        offspring = cell(popSize, 1);
        for i = 1:popSize
            p1    = randi(numel(archive));
            p2    = randi(numel(archive));
            child = crossover(archive{p1}, archive{p2}, problem);
            child = mutate(child, problem, 0.1);
            if ~child.feasible
                [~, t] = evaluateSolution(child, problem);
                child  = repairSolution(child, problem, t);
                child  = evaluateSolution(child, problem);
            end
            offspring{i} = child;
        end
        population = offspring;

        Z1v = cellfun(@(s) s.Z1, population);
        Z2v = cellfun(@(s) s.Z2, population);
        history(gen, :) = [min(Z1v), min(Z2v), mean(Z1v + Z2v)];
    end

    paretoFront = archive;
end