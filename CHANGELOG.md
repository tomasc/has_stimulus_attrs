# Changelog

## [0.5.0](https://github.com/tomasc/has_stimulus_attrs/compare/v0.4.1...v0.5.0) (2026-04-18)

### Bug Fixes

* **Non-mutating prepend pattern**: `prepend___has_stimulus___method` now builds a new Hash via `super().merge(k => v)` instead of mutating the Hash returned by super via `.tap { |d| d[k] = v }`. Required for compatibility with has_dom_attrs ≥ 0.3 (tomasc/has_dom_attrs#2), where `HasDomAttrs#dom_data` returns a shared frozen `EMPTY_HASH` constant to cut allocations. No behavioral change for existing consumers; works against both old-mutable and new-frozen bases.

## [0.4.1](https://github.com/tomasc/has_stimulus_attrs/compare/v0.3.0...v0.4.1) (2025-02-13)

### Bug Fixes

* **Defer Proc controller evaluation to runtime**: Fixed `controller:` option with Proc values in `has_stimulus_action`, `has_stimulus_class`, `has_stimulus_outlet`, `has_stimulus_param`, `has_stimulus_target`, and `has_stimulus_value` — Procs were incorrectly evaluated at class definition time via `instance_exec`, causing failures when referencing instance methods. Controller Procs are now resolved inside runtime lambdas, matching the existing behavior of `has_stimulus_controller`.

## [0.3.0](https://github.com/tomasc/has_stimulus_attrs/compare/v0.2.2...v0.3.0) (2025-01-02)

### Performance

* **Major performance optimizations**: Implemented intelligent memoization for `dom_data` method to prevent expensive Proc re-evaluation on repeated calls
* **Early conditional exit**: Optimized conditional attribute evaluation to skip expensive operations when `:if`/`:unless` conditions fail
* **Controller name caching**: Added instance-level caching for `controller_name` to avoid repeated class method calls
* **Smart cache management**: Added `reset_dom_data_cache!` method for manual cache invalidation when needed

### Features

* **Performance testing**: Added comprehensive performance test suite to validate optimizations and prevent regressions

## [0.2.2](https://github.com/tomasc/has_stimulus_attrs/compare/v0.2.1...v0.2.2) (2025-01-31)

### Features

* allow has_stimulus_action to accept proc ([PR#6](https://github.com/tomasc/has_stimulus_attrs/pull/6))


## [0.2.0](https://github.com/tomasc/has_stimulus_attrs/compare/v0.1.0...v0.2.0) (2023-03-22)

### Features

* allow controller option to accept proc ([1d34ae2](https://github.com/tomasc/has_stimulus_attrs/commit/1d34ae29f283e36aaed3fc56bd43f671c72308bf))
