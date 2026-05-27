# de Morgan (Lean 4)

**Difficulty:** 7 kyu

Prove the classical de Morgan equivalence:

```lean
theorem not_and_iff_not_or_not (p q : Prop) : ¬(p ∧ q) ↔ ¬p ∨ ¬q
```

The reverse direction is constructive. The forward direction requires
classical reasoning — `by_cases hp : p` splits on whether `p` holds, which
is the natural move here.

The runner permits the standard axioms `propext`, `Quot.sound`, and
`Classical.choice`. With those allowed, classical case splits like
`by_cases hp : p` and `Classical.em` are available to you.

---

### Lean 4 runner notes

- Edit only `Solution.lean`. The runner wraps your file in
  `namespace Submission ... end Submission`, so don't write the namespace
  yourself.
- Define the theorem name *exactly* as it appears in the spec.
- Permitted axioms: `propext`, `Quot.sound`, `Classical.choice`. `sorry`,
  `admit`, and computational axioms (`native_decide`) are rejected.
- Core Lean 4 only — no Mathlib. See
  [the solver guide](../../docs/solver-guide.md) for the full FAQ and a
  local-development workflow.
