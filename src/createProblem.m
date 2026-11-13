function problem = createProblem(NoO, NoS, Rounds, LAP, Takt)
% createProblem - Initialize LCSGRP problem instance
%
% Author: Project Team
% Date:   2026-10-15
% Version: 2.1 (Validator-approved)

    problem.NoO    = NoO;
    problem.NoS    = NoS;
    problem.Rounds = Rounds;
    problem.LAP    = LAP;
    problem.Takt   = Takt;

    % Initial processing times t0(i,j) ~ U[50, 150]
    problem.t0 = 50 + 100 * rand(NoO, NoS);

    % Theoretical minimum times tmin(j) ~ U[20, 50]
    problem.tmin = 20 + 30 * rand(1, NoS);

    % Learning slopes alpha(i) ~ U[0.1, 0.5]
    problem.alpha = 0.1 + 0.4 * rand(NoO, 1);

    % Movement time between workstations
    problem.q = 2;
end