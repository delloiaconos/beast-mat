# BEAST MATLAB

**MATLAB implementation of BEAST — Battery Estimation Algorithms and Simulation Toolkit**

`beast-mat` contains the MATLAB implementation of the BEAST battery modelling
and estimation framework and preserves the software lineage from which the
modern BEAST project evolved.

For the general project introduction, history, battery-model documentation, and
links to the other implementations, see the main
[BEAST repository](https://github.com/delloiaconos/beast.git).

## About this implementation

The MATLAB code originates from the academic work that preceded the current
BEAST C++ and Python repositories. It provides an important reference for the
battery models, state estimators, parameter estimators, simulations, and
numerical experiments developed during that work.

This repository is useful for:

- reproducing the original MATLAB simulations and algorithms;
- understanding the historical implementation of BEAST models and estimators;
- validating newer C++ and Python implementations against the MATLAB results;
- experimenting with the algorithms directly in MATLAB;
- preserving research code and its evolution.

The MATLAB repository should be treated as an implementation in its own right,
but also as a reference point for cross-validation across the BEAST project
family.

## Scope

The project focuses on battery equivalent-circuit modelling and estimation
algorithms used in Battery Management Systems, including State of Charge and
battery-parameter estimation.

When porting or comparing an algorithm, numerical equivalence should be checked
explicitly rather than assuming that similarly named implementations are
identical.

## MATLAB usage

Clone the repository and add the required BEAST directories to the MATLAB path
before running the desired scripts or simulations.

The exact entry points and required datasets depend on the model or estimator
being used. Implementation-specific usage notes and examples should be kept in
this repository alongside the MATLAB code.

## Academic origin

The MATLAB implementation originates from work developed for the Bachelor's
Degree Thesis in Electronic Engineering:

> **Hardware/Software Co-Design di uno stimatore dello stato di batterie agli ioni di litio**  
> Salvatore Dello Iacono, Università degli Studi di Salerno, academic year
> 2012–2013.

The shared project history and acknowledgements are maintained in the main
[BEAST repository](https://github.com/delloiaconos/beast.git).

## License

See [`LICENSE`](LICENSE) for the license terms that apply to `beast-mat`.
