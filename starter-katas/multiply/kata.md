# Recursive Multiplication (Lean 4)

**Difficulty:** 7 kyu

You are given a recursive definition of multiplication on `Nat`:

```lean
def multiply : Nat → Nat → Nat
  | 0,     _ => 0
  | n + 1, m => m + multiply n m
```

Prove that it agrees with `Nat.*`.

## What you must provide

In your `Solution.lean`, prove:

```lean
theorem multiply_correct (a b : Nat) : multiply a b = a * b
```

The proof is by induction on `a`. You will likely need `Nat.succ_mul` and
`Nat.add_comm`.

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
