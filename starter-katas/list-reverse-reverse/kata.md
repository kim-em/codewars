# Reverse Twice (Lean 4)

**Difficulty:** 7 kyu

A direct list reverse, defined by structural recursion:

```lean
def myReverse {α : Type} : List α → List α
  | []      => []
  | a :: l  => myReverse l ++ [a]
```

Prove that reversing twice is the identity.

## What you must provide

In your `Solution.lean`, prove:

```lean
theorem myReverse_myReverse {α : Type} (l : List α) :
    myReverse (myReverse l) = l
```

You will need a helper lemma about `myReverse` distributing over `++` in the
opposite order: `myReverse (l₁ ++ l₂) = myReverse l₂ ++ myReverse l₁`.

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
