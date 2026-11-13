function [paretoFront, history] = MOTLBO(problem, popSize, maxGen, seed)
% MOTLBO - Multi-Objective Teaching-Learning-Based Optimization
%
% Integrates: non-dominated sorting, grid-based elite teacher selection
% (PESA-II inspired), Pareto-based superior member selection, and
% adaptive population management.
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    if nargin >= 4 && ~isempty(seed)
        rng(seed, 'twister');
    end

    fprintf('Running MOTLBO...\n');

    TP = 0.05;
    TS = 0.5;
    LS = 0.5;
    TD = 0.5;
    LD = 0.5;
    GS = 5;

    population = initializePopulation(problem, popSize);
    history    = zeros(maxGen, 3);

    for gen = 1:maxGen
        [fronts, ~]     = nonDominatedSorting(population);
        paretoFrontIdx  = fronts{1};

        % --- Teaching Phase ---
        nElite  = max(1, floor(TP * numel(population)));
        teacher = selectTeacherFromPareto(population, paretoFrontIdx, nElite, GS);

        for i = 1:popSize
            newSol = teachingPhase(population{i}, teacher, problem, TS, TD);
            if dominates(newSol, population{i})
                population{i} = newSol;
            elseif ~dominates(population{i}, newSol) && rand < 0.5
                population{i} = newSol;
            end
        end

        % --- Learning Phase ---
        for i = 1:popSize
            peerIdx = randi(popSize);
            if peerIdx == i
                peerIdx = mod(peerIdx, popSize) + 1;
            end

            if ismember(peerIdx, paretoFrontIdx) && ~ismember(i, paretoFrontIdx)
                superior = population{peerIdx};
                inferior = population{i};
            elseif ismember(i, paretoFrontIdx) && ~ismember(peerIdx, paretoFrontIdx)
                superior = population{i};
                inferior = population{peerIdx};
            elseif dominates(population{i}, population{peerIdx})
                superior = population{i};
                inferior = population{peerIdx};
            elseif dominates(population{peerIdx}, population{i})
                superior = population{peerIdx};
                inferior = population{i};
            else
                continue;
            end

            newSol = learningPhase(inferior, superior, problem, LS, LD);
            if dominates(newSol, inferior)
                population{i} = newSol;
            elseif ~dominates(inferior, newSol) && rand < 0.5
                population{i} = newSol;
            end
        end

        population = environmentalSelection(population, popSize);

        Z1v = cellfun(@(s) s.Z1, population);
        Z2v = cellfun(@(s) s.Z2, population);
        history(gen, :) = [min(Z1v), min(Z2v), mean(Z1v + Z2v)];

        if mod(gen, 100) == 0
            fprintf('  Generation %d/%d\n', gen, maxGen);
        end
    end

    [fronts, ~]  = nonDominatedSorting(population);
    paretoFront  = population(fronts{1});
end

% ---------------------------------------------------------------
function teacher = selectTeacherFromPareto(population, frontIdx, nElite, GS)
    eliteIdx = frontIdx(1:min(nElite, numel(frontIdx)));
    n        = numel(eliteIdx);

    if n == 1
        teacher = population{eliteIdx(1)};
        return;
    end

    Z1v = cellfun(@(s) s.Z1, population(eliteIdx));
    Z2v = cellfun(@(s) s.Z2, population(eliteIdx));

    z1min = min(Z1v); z1max = max(Z1v) + 1e-9;
    z2min = min(Z2v); z2max = max(Z2v) + 1e-9;

    cellIdx = zeros(n, 1);
    for k = 1:n
        gi = min(GS, floor((Z1v(k) - z1min) / (z1max - z1min) * GS) + 1);
        gj = min(GS, floor((Z2v(k) - z2min) / (z2max - z2min) * GS) + 1);
        cellIdx(k) = (gi - 1) * GS + gj;
    end

    uniqueCells = unique(cellIdx);
    cellCounts  = arrayfun(@(x) sum(cellIdx == x), uniqueCells);

    weights = zeros(n, 1);
    for k = 1:n
        c = find(uniqueCells == cellIdx(k), 1);
        weights(k) = 1 / cellCounts(c);
    end

    probs   = weights / sum(weights);
    idx     = weightedSample(probs);
    teacher = population{eliteIdx(idx)};
end

% ---------------------------------------------------------------
function newSol = teachingPhase(current, teacher, problem, TS, TD)
    R = problem.Rounds;
    J = problem.NoS;
    I = problem.NoO;

    TF = rand * 2;
    curOps   = unique(current.Assignment(:));
    teachOps = unique(teacher.Assignment(:));
    NO_new   = round(numel(curOps) + TF * (numel(teachOps) - numel(curOps)));
    NO_new   = max(2, min(NO_new, min(I, J)));

    newSol = current;

    if rand < TS
        nCopy    = round(TD * NO_new);
        copyOps  = teachOps(randperm(numel(teachOps), min(nCopy, numel(teachOps))));
        fillPool = setdiff(1:I, copyOps);
        nFill    = NO_new - numel(copyOps);
        if nFill > 0 && numel(fillPool) >= nFill
            fillOps = fillPool(randperm(numel(fillPool), nFill));
        else
            fillOps = fillPool;
        end
        selectedOps = unique([copyOps, fillOps]);
    else
        selectedOps = randperm(I, NO_new);
    end

    for r = 1:R
        for j = 1:J
            if rand < TS
                newSol.Assignment(r, j) = teacher.Assignment(r, j);
            else
                newSol.Assignment(r, j) = selectedOps(randi(numel(selectedOps)));
            end
        end
    end

    newSol = evaluateSolution(newSol, problem);
    if ~newSol.feasible
        [~, t]  = evaluateSolution(newSol, problem);
        newSol  = repairSolution(newSol, problem, t);
        newSol  = evaluateSolution(newSol, problem);
    end
end

% ---------------------------------------------------------------
function newSol = learningPhase(inferior, superior, problem, LS, LD)
    R = problem.Rounds;
    J = problem.NoS;
    I = problem.NoO;

    infOps = unique(inferior.Assignment(:));
    supOps = unique(superior.Assignment(:));

    LF     = rand * 2;
    NO_new = round(numel(supOps) + LF * (numel(supOps) - numel(infOps)));
    NO_new = max(2, min(NO_new, min(I, J)));

    newSol = inferior;

    if rand < LS
        nCopy    = round(LD * NO_new);
        copyOps  = supOps(randperm(numel(supOps), min(nCopy, numel(supOps))));
        fillPool = setdiff(infOps, copyOps);
        nFill    = NO_new - numel(copyOps);
        if nFill > 0 && numel(fillPool) >= nFill
            fillOps = fillPool(randperm(numel(fillPool), nFill));
        else
            fillOps = fillPool;
        end
        selectedOps = unique([copyOps, fillOps]);
    else
        selectedOps = infOps;
    end

    for r = 1:R
        for j = 1:J
            if rand < LS
                newSol.Assignment(r, j) = superior.Assignment(r, j);
            else
                newSol.Assignment(r, j) = selectedOps(randi(numel(selectedOps)));
            end
        end
    end

    newSol = evaluateSolution(newSol, problem);
    if ~newSol.feasible
        [~, t]  = evaluateSolution(newSol, problem);
        newSol  = repairSolution(newSol, problem, t);
        newSol  = evaluateSolution(newSol, problem);
    end
end

% ---------------------------------------------------------------
function population = environmentalSelection(population, popSize)
    if numel(population) <= popSize
        return;
    end

    [fronts, ~] = nonDominatedSorting(population);

    newPop = cell(0, 1);
    for f = 1:numel(fronts)
        if numel(newPop) + numel(fronts{f}) <= popSize
            newPop = [newPop; population(fronts{f})]; %#ok<AGROW>
        else
            cd = crowdingDistance(fronts{f}, population);
            [~, idx]  = sort(cd, 'descend');
            remaining = popSize - numel(newPop);
            newPop    = [newPop; population(fronts{f}(idx(1:remaining)))]; %#ok<AGROW>
            break;
        end
    end
    population = newPop;
end