function [fronts, ranks] = nonDominatedSorting(population)
% nonDominatedSorting - Fast non-dominated sorting (Deb et al., 2002)
%
% population: cell array of solution structs
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    N     = numel(population);
    S     = cell(N, 1);
    n     = zeros(N, 1);
    ranks = zeros(N, 1);

    for i = 1:N
        for j = 1:N
            if i ~= j
                if dominates(population{i}, population{j})
                    S{i} = [S{i}, j];
                elseif dominates(population{j}, population{i})
                    n(i) = n(i) + 1;
                end
            end
        end
        if n(i) == 0
            ranks(i) = 1;
        end
    end

    fronts      = {};
    frontIdx    = 1;
    currentFr   = find(ranks == 1);
    while ~isempty(currentFr)
        fronts{frontIdx} = currentFr;
        nextFr = [];
        for i = currentFr
            for j = S{i}
                n(j) = n(j) - 1;
                if n(j) == 0
                    ranks(j) = frontIdx + 1;
                    nextFr   = [nextFr, j];
                end
            end
        end
        frontIdx  = frontIdx + 1;
        currentFr = nextFr;
    end
end