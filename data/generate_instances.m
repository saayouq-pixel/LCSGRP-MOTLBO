
---

## فایل ۶: `data/generate_instances.m`

```matlab
% generate_instances.m
% Generate the 20 problem instances used in the paper and save them
%
% Author: Project Team
% Date:   2026-10-15
% Version: 1.0

clear; clc;

addpath(genpath('..'));

% Instance configurations: [NoO, NoS, Rounds, LAP, Takt]
configs = [
    10, 10, 10, 3, 200;   % Case 1
     7,  7, 15, 3, 130;   % Case 2
    15, 15, 50, 3, 150;   % Case 3
    12, 12, 30, 3, 130;   % Case 4
     8,  8, 24, 3, 130;   % Case 5
    10, 10, 35, 3, 150;   % Case 6
     7,  7, 27, 3, 150;   % Case 7
    10, 10, 30, 3, 150;   % Case 8
    12, 12, 50, 2, 150;   % Case 9
     8,  8, 30, 2, 150;   % Case 10
    12, 12, 40, 3, 150;   % Case 11
    15, 15, 20, 3, 150;   % Case 12
     9,  9, 35, 3, 150;   % Case 13
    12, 12, 33, 3, 150;   % Case 14
     8,  8, 30, 3, 150;   % Case 15
     9,  9, 35, 3, 150;   % Case 16
    12, 12, 40, 2, 150;   % Case 17
     8,  8, 35, 2, 150;   % Case 18
    15, 15, 30, 2, 150;   % Case 19
    20, 20, 40, 2, 200;   % Case 20
];

instances = cell(size(configs, 1), 1);
for i = 1:size(configs, 1)
    rng(i * 1000, 'twister');  % Reproducible instances
    instances{i} = createProblem(configs(i,1), configs(i,2), ...
                                 configs(i,3), configs(i,4), configs(i,5));
    instances{i}.caseId = i;
end

save('problem_instances.mat', 'instances', 'configs');
fprintf('Generated %d instances and saved to problem_instances.mat\n', numel(instances));