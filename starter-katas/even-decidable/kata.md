# Decidable Evenness (Lean 4)

**Difficulty:** 5 kyu

You are given two views of evenness on `Nat`: an existential predicate, and
a computable boolean function that peels off pairs of `+1`s.

```lean
def Even   (n : Nat) : Prop := ∃ k, n = 2 * k
def isEven : Nat → Bool
  | 0     => true
  | 1     => false
  | n + 2 => isEven n
```

Prove the two agree:

```lean
theorem isEven_iff_Even (n : Nat) : isEven n = true ↔ Even n
```

## Hints

- Plain `induction n` only gives you `n` and `n+1` as cases; `isEven`
  recurses on `n+2`. Strong induction (`induction n using Nat.strongRecOn
  with | ind n ih => ...`) lets you apply the IH to `n` from inside the
  `n+2` branch.
- For the reverse direction: `rintro ⟨k, hk⟩` destructs the existential.
  You'll then need to `cases k with | zero => ... | succ k' => ...` since
  the `k = 0` case is contradictory for `n + 2`.
- Throughout, `omega` closes the linear-arithmetic side goals.

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
