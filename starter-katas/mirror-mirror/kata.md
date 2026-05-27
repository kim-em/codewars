# Mirror, Mirror (Lean 4)

**Difficulty:** 7 kyu

You are given a binary tree type and a `mirror` operation that swaps the
children of every node:

```lean
inductive Tree (α : Type) : Type
  | leaf : Tree α
  | node : α → Tree α → Tree α → Tree α

def mirror {α : Type} : Tree α → Tree α
  | .leaf       => .leaf
  | .node x l r => .node x (mirror r) (mirror l)
```

Prove that `mirror` is its own inverse.

```lean
theorem mirror_mirror {α : Type} (t : Tree α) : mirror (mirror t) = t
```

The proof is structural induction on `t`. Note that the recursive case has
two children, so the induction principle gives you two induction hypotheses.

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
