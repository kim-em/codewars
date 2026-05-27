# Kata format

This document describes how to write a Lean 4 kata for the codewars
runner. There are two supported file conventions.

## 1. Codewars convention (recommended for kata authors)

This is the convention compatible with Codewars' existing Lean kata
authoring UI (`Preloaded.lean` / `Solution.lean` / `SolutionTest.lean`),
adapted to Lean 4's stronger trust story.

The author provides three files in the kata working directory:

### `Preloaded.lean` (trusted)

Imports and helper definitions that the kata needs but the user
shouldn't have to re-derive. The runner copies this verbatim into
`ChallengeDeps.lean` inside the comparator workspace; every other
Lean module in the workspace imports it.

For the slim image (the only image currently shipped), `Preloaded.lean`
can import anything in core Lean. Mathlib is not available; Mathlib
support is tracked as future work in `docs/proposal.md`.

### `SolutionTest.lean` (trusted)

The kata's *specification*: top-level `theorem` declarations whose
statements define what the user must prove. Each theorem's body must
be a reference to `Submission.<theorem-name>`. The body is what the
adapter strips and replaces with `by sorry` when constructing the
challenge file the user effectively must close.

Required form:

```lean
import ChallengeDeps

theorem two_plus_two : (2 : Nat) + 2 = 4 := Submission.two_plus_two

theorem add_comm_demo (a b : Nat) : a + b = b + a :=
  Submission.add_comm_demo a b
```

Rules the adapter relies on:

- Each top-level `theorem` declaration starts on a fresh line, with
  no indentation, no `@[...]` attribute, no `protected`/`private`.
- Each theorem's body (the text after `:=`) refers to
  `Submission.<same-name>`. The body may span multiple indented lines.
- A theorem's body ends at the next line starting with `theorem`,
  `def`, `example`, `instance`, `abbrev`, `class`, `structure`,
  `inductive`, `section`, `end`, `namespace`, or end-of-file.
- Comments and blank lines between theorems are preserved.

These rules are mechanical, not stylistic — the adapter parses with a
small regex scanner (`runner/adapter.py`). If you want richer structure
in the spec, use the comparator-direct convention below.

### `Solution.lean` (user-submitted)

The proofs themselves. The runner wraps whatever you write here in
`namespace Submission ... end Submission` so that the names match
the spec.

```lean
theorem two_plus_two : (2 : Nat) + 2 = 4 := rfl

theorem add_comm_demo (a b : Nat) : a + b = b + a := Nat.add_comm a b
```

The user may add helper definitions, lemmas, `open` declarations, etc.
— all of it goes inside the implicit `namespace Submission`.

## 2. Comparator-direct convention

A kata can ship a full comparator workspace directly, skipping the
adapter. This is the format `lean-eval` uses and is more flexible but
requires the author to maintain the `Challenge` / `Solution` /
`Submission` triple by hand. Use this when:

- You want imports/namespacing the adapter doesn't support.
- You're writing tests for the runner itself.

Required files:

| File              | Role                                                   |
|-------------------|--------------------------------------------------------|
| `lakefile.toml`   | `defaultTargets = ["workspace_test"]`. See template.   |
| `lean-toolchain`  | `leanprover/lean4:v4.30.0`.                            |
| `Challenge.lean`  | Theorem statements with `by sorry` bodies.             |
| `Solution.lean`   | Same statements; bodies reference `Submission.<name>`. |
| `Submission.lean` | `namespace Submission ... end Submission`.             |
| `ChallengeDeps.lean` | Shared imports/defs (may be empty).                 |
| `WorkspaceTest.lean` | Tiny exe that spawns comparator. Copy verbatim.     |
| `config.json`     | Comparator config: theorem names, permitted axioms.    |

See `examples/comparator-direct/` for the canonical example.

## How the runner detects mode

`runner/judge` looks at the kata directory:

- `Challenge.lean` + `config.json` present → comparator-direct.
- `SolutionTest.lean` present → codewars convention.
- Neither → infra error, exit code 2.

You can also pass `--mode codewars` or `--mode comparator-direct`
explicitly.

## Permitted axioms

By default the runner permits only the three standard Lean axioms:
`propext`, `Quot.sound`, `Classical.choice`. A user submission whose
proof depends on anything else — including `sorryAx`, `native_decide`,
`Lean.ofReduceBool`, or any axiom the kata author hasn't allowlisted —
is rejected.

To allow additional axioms for a particular kata, edit
`config.json`'s `permitted_axioms` array (comparator-direct mode) or
add a custom config to the codewars-shape directory; the adapter
will respect it if present. (Future work — currently the adapter
generates a fixed list.)

## Things to avoid in kata authoring

- Don't put `sorry`, `axiom`, `unsafe`, or `@[implemented_by]` in
  `Preloaded.lean`/`SolutionTest.lean`. Comparator will reject the
  submission for using those axioms, but the author intent should
  be that the spec is honest about what's proved.
- Don't write theorems whose statements depend on a `def` that
  itself contains `sorry`. lean4export will embed `sorryAx`
  references and the diff comparator runs will fail (see
  `lean-comparator` skill, gotcha #2).
- Don't `import Mathlib` (or any Mathlib submodule) from
  `Preloaded.lean`. The slim runner image doesn't bundle Mathlib;
  the import will fail with an unresolved-module error.
