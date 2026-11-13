# LCSGRP-MOTLBO: Multi-Objective Optimization for Lean Cell Workforce Allocation

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)

## Overview

This repository contains the MATLAB implementation of a fair comparison
between the proposed **MOTLBO** (Multi-Objective Teaching-Learning-Based
Optimization) and three benchmark algorithms — **NSGA-II**, **SPEA2**, and
**MOPSO** — for solving the **Lean Cell Skill Gap Recovery Problem
(LCSGRP)**.

LCSGRP is a bi-objective, multi-period optimization problem that models
operator skill recovery as a threshold-based process dependent on
assignment continuity (Learning Acquisition Period, LAP).

## Fair Comparison Protocol

To ensure a fair comparison, all algorithms share:

| Component | Value |
|-----------|-------|
| Initialization | Algorithm 1 (random, constraint-aware) |
| Constraint handling | Repair-based |
| Population size | 500 |
| Generations | 1,000 |
| Function evaluations | 500,000 |
| Number of runs | 30 |
| Random seed per run | Identical across algorithms |

## Requirements

- **MATLAB R2020a** or later (no additional toolboxes required)
- Verified on MATLAB R2023a, Windows 11 Pro, Intel Core i7-12700K, 32 GB RAM
- Expected runtime: ~10 minutes per algorithm per instance (full 30 runs)

## Quick Start

```matlab
% Add source path
addpath(genpath('src'));

% Create a small test instance
problem = createProblem(5, 5, 6, 2, 150);  % (NoO, NoS, Rounds, LAP, Takt)

% Run MOTLBO
[paretoFront, history] = MOTLBO(problem, 50, 100, 1);

% Inspect Pareto front
for i = 1:numel(paretoFront)
    fprintf('Z1=%.4f  Z2=%.4f  Feasible=%d\n', ...
        paretoFront{i}.Z1, paretoFront{i}.Z2, paretoFront{i}.feasible);
end