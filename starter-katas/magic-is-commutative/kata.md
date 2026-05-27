# Magic is Commutative (Lean 4)

**Difficulty:** 6 kyu

A binary operation `f : α → α → α` is *magical* if for all `x` and `y`:

- `f (f x y) y = x`  *(left identity-ish)*
- `f y (f y x) = x`  *(right identity-ish)*

Prove that every magical operation is commutative.

```lean
theorem magic_is_commutative {α : Type} (f : α → α → α) (hm : IsMagical f) :
    ∀ x y, f x y = f y x
```

This is a port of an existing Lean 3 Codewars kata (6 kyu). The puzzle comes
from an exercise in *Introduction to Algebra* by Aleksei Ivanovich Kostrikin.

There is no induction here — the proof is a short chain of three rewrites
using `hm.left` and `hm.right`. Each step substitutes one identity inside
another.

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
