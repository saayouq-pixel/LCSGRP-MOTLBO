function [paretoFront, history] = MOPSO(problem, popSize, maxGen, seed)
% MOPSO - Multi-Objective Particle Swarm Optimization (Discrete Adaptation)
%
% Uses shared initialization (Algorithm 1) and repair-based constraint handling.
% Position update is sigmoid-based, copying from pbest or gbest.
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    if nargin >= 4 && ~isempty(seed)
        rng(seed, 'twister');
    end

    fprintf('Running MOPSO...\n');
    swarm    = initializePopulation(problem, popSize);
    pbest    = swarm;
    velocity = zeros(popSize, problem.Rounds * problem.NoS);

    archive     = {};
    archiveSize = 500;

    w  = 0.4;
    c1 = 1.5;
    c2 = 1.5;

    history = zeros(maxGen, 3);

    for gen = 1:maxGen
        allSol      = [swarm; archive];
        [fronts, ~] = nonDominatedSorting(allSol);
        archive     = allSol(fronts{1});

        if numel(archive) > archiveSize
            cd     = crowdingDistance(1:numel(archive), archive);
            finite = cd(~isinf(cd));
            if ~isempty(finite)
                cd(isinf(cd)) = max(finite) * 2;
            end
            [~, idx] = sort(cd, 'descend');
            archive  = archive(idx(1:archiveSize));
        end

        if isempty(archive)
            archive = swarm;
        end
        gbest = selectGbest(archive);

        for i = 1:popSize
            for d = 1:size(velocity, 2)
                r1 = rand; r2 = rand;
                velocity(i, d) = w * velocity(i, d) + c1 * r1 + c2 * r2 - 1;
            end

            newSol = swarm{i};
            for r = 1:problem.Rounds
                for j = 1:problem.NoS
                    d    = (r - 1) * problem.NoS + j;
                    prob = 1 / (1 + exp(-velocity(i, d)));
                    if rand < prob
                        if rand < 0.5
                            newSol.Assignment(r, j) = pbest{i}.Assignment(r, j);
                        else
                            newSol.Assignment(r, j) = gbest.Assignment(r, j);
                        end
                    elseif rand < 0.1
                        newSol.Assignment(r, j) = randi(problem.NoO);
                    end
                end
            end

            newSol = evaluateSolution(newSol, problem);
            if ~newSol.feasible
                [~, t]  = evaluateSolution(newSol, problem);
                newSol  = repairSolution(newSol, problem, t);
                newSol  = evaluateSolution(newSol, problem);
            end

            if newSol.feasible
                if dominates(newSol, pbest{i})
                    pbest{i} = newSol;
                    swarm{i} = newSol;
                elseif ~dominates(pbest{i}, newSol) && rand < 0.5
                    pbest{i} = newSol;
                    swarm{i} = newSol;
                end
            end
        end

        Z1v = cellfun(@(s) s.Z1, swarm);
        Z2v = cellfun(@(s) s.Z2, swarm);
        history(gen, :) = [min(Z1v), min(Z2v), mean(Z1v + Z2v)];
    end

    paretoFront = archive;
end