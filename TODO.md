# TODO — MATLAB Architecture Alignment

This document tracks the changes required to align the MATLAB implementation of BEAST with the common BEAST architecture.

The MATLAB implementation already follows the core mathematical architecture closely. In particular, the cell-model equations and estimator abstractions correspond well to the architecture specification.

Most of the required work concerns formalizing interfaces, separating responsibilities, and replacing MATLAB-specific discovery and initialization mechanisms.

## Cell Model Interface

* [ ] Add `coerceState(x)` to the abstract `CellModel` interface.

  * Current MATLAB implementations expose equivalent functionality through `CoerceStateCompatibility`.
  * Rename or wrap existing implementations to conform to the common interface.

* [ ] Add `coerceParameters(p)` to the abstract `CellModel` interface.

  * Current MATLAB implementations expose equivalent functionality through `CoerceParsCompatibility`.
  * Rename or wrap existing implementations to conform to the common interface.

* [ ] Standardize the naming convention of cell-model methods.

  * Prefer the architecture names:

    * `coerceState`
    * `coerceParameters`
    * `initialize`
    * `configure`
  * Avoid MATLAB-specific names in the public architecture where possible.

* [ ] Add a standard `name()` method or equivalent model identifier.

  * Current model identification is mostly derived from the MATLAB class name.

* [ ] Expose parameter metadata through `listParameters()`.

  * Current equivalent: `Pnames`.

* [ ] Expose state metadata through `listStates()`.

  * Current equivalent: `Xnames`.

* [ ] Expose configuration requirements through `listConfiguration()`.

  * Current equivalent: `Required`.

* [ ] Consider adding `listInputs()` and `listOutputs()` to the common architecture.

  * MATLAB already provides:

    * `Unames`
    * `Ynames`

* [ ] Decide whether model dimensions should have an explicit API.

  * MATLAB currently provides:

    * `Nx`
    * `Np`
    * `Nu`
    * `Ny`
  * Prefer deriving dimensions from metadata lists if possible, to avoid duplicated information.

## Cell Model Configuration

* [ ] Separate model construction from model configuration.

  The current MATLAB implementation passes configuration directly to constructors, for example:

  ```matlab
  R0A1B1(CellModelData, COV, deltat)
  ```

  The architecture instead defines an explicit configuration phase:

  ```text
  CellModelFactory.create(...)
          |
          v
      CellModel
          |
      configure(...)
          |
      initialize()
  ```

* [ ] Implement `configure(config)` for cell models.

* [ ] Implement `initialize()` with a clearly defined lifecycle.

* [ ] Define which operations belong to `configure()` and which belong to `initialize()`.

  A suggested distinction is:

  ```text
  configure()
      store user/model configuration

  initialize()
      validate configuration
      compute derived quantities
      prepare internal model data
  ```

* [ ] Remove configuration-file loading responsibilities from model creation.

## Cell Model Factory

* [ ] Introduce an explicit `CellModelFactory`.

* [ ] Move model discovery currently implemented by `CellModels.Initialize()` into the factory/registry layer.

* [ ] Implement:

  ```text
  CellModelFactory.create(name)
  CellModelFactory.list()
  ```

* [ ] Replace dynamic construction using `eval`.

* [ ] Separate the responsibilities currently combined by `CellModels.Initialize()`:

  ```text
  model discovery
  configuration loading
  model construction
  model initialization
  ```

* [ ] Consider implementing a registry of available cell models rather than relying directly on MATLAB package introspection.

## Estimator Interface

* [ ] Store the associated `CellModel` in the abstract `Estimator` class.

  Currently concrete estimators independently declare properties such as:

  ```matlab
  objModel
  ```

  The common relationship should instead be defined once by the base class.

* [ ] Standardize the estimator constructor around:

  ```text
  Estimator(cell : CellModel)
  ```

* [ ] Standardize estimator initialization.

  Current MATLAB form:

  ```matlab
  Initialize(x0, p0, uold, yXPold, told)
  ```

  Map this to the common architecture naming and argument conventions.

* [ ] Standardize capitalization of public methods.

  * `Initialize` → `initialize`
  * `Step` → `step`

## Estimator State Ownership

* [ ] Keep estimated state and parameters owned internally by the estimator.

  This is already how the MATLAB implementation behaves.

* [ ] Add standard accessors:

  ```text
  getX()
  getP()
  ```

  Current equivalents are estimator-specific properties such as:

  ```matlab
  xPold
  pPold
  ```

* [ ] Add optional estimator-gain accessors:

  ```text
  getLx()
  getLp()
  ```

  Current equivalents include:

  ```matlab
  Lxold
  Lpold
  ```

* [ ] Add a standardized `name()` method.

  Current equivalent:

  ```matlab
  FilterName
  ```

## Estimator `step()` Signature

* [ ] Review the architecture definition of `Estimator.step()`.

  The MATLAB implementation follows a stateful estimator model:

  ```matlab
  Initialize(x0, p0, u0, y0, t0)
  Step(u, y, t)
  ```

  Since the estimator already owns its current `x` and `p`, these values should normally not be supplied again to every `step()` call.

* [ ] Prefer the following common interface:

  ```text
  initialize(
      x0 : Vector,
      p0 : Vector,
      u : Vector,
      yExp : Vector,
      t : float
  )

  step(
      u : Vector,
      yExp : Vector,
      t : float
  )
  ```

* [ ] Avoid having both internal estimator state and externally supplied `x`/`p` in `step()`, as this introduces two possible sources of truth.

## Estimator Factory

* [ ] Introduce an explicit `EstimatorFactory`.

* [ ] Move estimator discovery currently performed in `BEAST_ProcMat.m` into the factory/registry layer.

* [ ] Implement:

  ```text
  EstimatorFactory.create(name, cell)
  EstimatorFactory.list()
  ```

* [ ] Replace estimator creation based on `eval`.

* [ ] Consider using an explicit estimator registry instead of runtime package inspection.

## Estimator Configuration

* [ ] Separate estimator-specific configuration from the physical cell model.

  The MATLAB cell model currently stores covariance matrices and estimator tuning data such as:

  ```matlab
  sxW
  sxV
  spR
  spE
  ```

* [ ] Move estimator-specific covariance and tuning parameters into estimator configuration.

  Target separation:

  ```text
  CellModel configuration
      physical/model parameters
      nominal capacity
      efficiency
      OCV data
      physical constraints

  Estimator configuration
      process covariance
      measurement covariance
      initial covariance
      parameter covariance
      algorithm-specific tuning
  ```

* [ ] Ensure that one `CellModel` instance can be reused by different estimators without containing estimator-specific data.

## Time-Step Handling

* [ ] Clarify the role of `dt` across the architecture.

  MATLAB currently mixes:

  * a timestep stored in the model;
  * a timestep stored in the estimator;
  * `dt` arguments passed to model equations;
  * absolute timestamps passed to `Step()`.

* [ ] Decide whether cell-model equations support variable timestep operation.

  If so, keep:

  ```text
  f0(x, p, u, dt)
  g0(x, p, u, dt)
  f1x(x, p, u, dt)
  ...
  ```

* [ ] Avoid requiring a fixed timestep in the model when `dt` is explicitly supplied to every model evaluation.

* [ ] Define whether `Estimator.step()` receives:

  * absolute time `t`, or
  * timestep `dt`.

* [ ] Define one consistent location responsible for calculating `dt` when timestamps are used.

## MATLAB-Specific Runtime Mechanisms

* [ ] Remove `eval` from cell-model creation.

* [ ] Remove `eval` from estimator creation.

* [ ] Reduce architectural dependence on MATLAB's `what()` package introspection.

* [ ] Introduce explicit registries that can be represented consistently in MATLAB, C++, and Python.

* [ ] Keep runtime discovery as a MATLAB convenience only if it does not become part of the common BEAST architecture.

## Naming and Architecture Consistency

* [ ] Use `BEAST` consistently instead of legacy `BEAST` naming where appropriate for the new implementation.

* [ ] Align MATLAB package and class terminology with the common architecture.

* [ ] Fix the factory naming inconsistency in the architecture files:

  * `CellFactory`
  * `CellModelFactory`

  Select one name consistently; `CellModelFactory` is preferred because it clearly identifies the objects being created.

## Existing Features Already Aligned

The following parts of the MATLAB implementation already correspond closely to the architecture and should be preserved:

* [x] Abstract `CellModel` base class.
* [x] `f0(x,p,u,dt)`.
* [x] `g0(x,p,u,dt)`.
* [x] `f1x(x,p,u,dt)`.
* [x] `f1p(x,p,u,dt)`.
* [x] `g1x(x,p,u,dt)`.
* [x] `g1p(x,p,u,dt)`.
* [x] Concrete cell-model inheritance.
* [x] Abstract `Estimator` base class.
* [x] Concrete estimator inheritance.
* [x] Estimators operate through the abstract cell-model mathematical interface.
* [x] Estimator objects internally maintain estimated states and parameters.
* [x] Concrete cell models already implement state and parameter compatibility/coercion logic.
* [x] Cell models already expose state, parameter, input, and output metadata.
* [x] Runtime mechanisms already exist for discovering available models and estimators, although they should be refactored into explicit factories.

## Suggested Implementation Priority

1. [ ] Formalize the MATLAB `CellModel` interface.
2. [ ] Formalize the MATLAB `Estimator` interface.
3. [ ] Decide and document estimator state ownership and the final `step()` signature.
4. [ ] Introduce `CellModelFactory`.
5. [ ] Introduce `EstimatorFactory`.
6. [ ] Remove `eval`-based construction.
7. [ ] Separate cell-model and estimator configuration.
8. [ ] Clarify the `configure()` / `initialize()` lifecycle.
9. [ ] Standardize timestep handling.
10. [ ] Align metadata APIs and naming with the common BEAST architecture.
11. [ ] Remove remaining MATLAB-specific assumptions from the architecture-facing API.
