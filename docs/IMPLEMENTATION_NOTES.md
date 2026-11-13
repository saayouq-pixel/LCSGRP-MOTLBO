# Implementation Notes

This document provides technical details about the implementation of the
algorithms for the LCSGRP.

## 1. Common Framework

### 1.1. Solution Representation
Each solution `sol` contains:
- `sol.Assignment` : `R × J` matrix where `Assignment(r,j)` is the operator
  index assigned to workstation `j` in period `r`.
- `sol.Z1`, `sol.Z2`, `sol.Z3` : Objective values.
- `sol.feasible` : Boolean, true if Constraint (21) is satisfied.

### 1.2. Initialization (Algorithm 1)
All algorithms use the **same** initialization:
1. Randomly select `NO ∈ [2, min(I,J)]` operators.
2. Seed each selected operator with one workstation.
3. Fill remaining workstations via adjacency-based allocation
   (preceding / subsequent / facing).
4. Evaluate and repair if infeasible.

### 1.3. Constraint Handling (Repair-Based)
All algorithms use the same repair procedure:
- For each period, identify the operator exceeding Takt.
- Move workstations (from least critical) to unused or less-loaded operators.
- Use **actual** processing times `t(i,j,r)` (not `t0`).

## 2. Algorithm-Specific Notes

### 2.1. MOTLBO
- **Teacher selection**: Top 5% of Pareto front, grid-based roulette wheel.
- **Teaching phase**: Blend current solution with teacher using `TS = 0.5`.
- **Learning phase**: Move toward Pareto-front superior member.
- **Environmental selection**: Non-dominated sorting + crowding distance.

### 2.2. NSGA-II
- **Selection**: Binary tournament based on (rank, crowding distance).
- **Variation**: Uniform period-wise crossover + random mutation.
- **Environmental selection**: Combined parent + offspring sorting.

### 2.3. SPEA2
- **Fitness**: Strength Pareto + k-th nearest neighbor density.
- **Archive**: External archive with size = popSize.
- **Truncation**: Fitness-based for oversized archives.

### 2.4. MOPSO
- **Velocity update**: `v ← w·v + c1·r1 + c2·r2 − 1`
- **Position update**: Sigmoid-based, copying from `pbest` or `gbest`.
- **Personal best**: Updated only for feasible solutions.
- **Global best**: Grid-based roulette wheel from archive.

## 3. Fair Comparison Protocol

| Aspect | All Algorithms |
|--------|----------------|
| Initialization | Algorithm 1 (identical) |
| Constraint handling | Repair-based (identical) |
| Population size | 500 |
| Generations | 1,000 |
| Function evaluations | 500,000 |
| Seeds | Same per run |
| Number of runs | 30 |

## 4. Performance Metrics

- **Hypervolume (HV)**: Reference point = (1.5, 1.5); 2D exact computation.
- **IGD**: Reference front = non-dominated set across all algorithms.
- **Spread (Δ)**: Distribution uniformity along the front.

## 5. Reproducibility

Each run uses `rng(run, 'twister')` at the start of the algorithm.
The same seed is applied to all four algorithms in a given run to
ensure fair comparison of the initial population.

To reproduce results:
```matlab
main_comparison
load('comparisonResults.mat');
% All metadata, seeds, and outputs are stored