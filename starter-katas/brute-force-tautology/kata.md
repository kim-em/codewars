# Brute-Force Tautology Checker (Lean 4)

**Difficulty:** 4 kyu

You are given a small Boolean-expression language and a brute-force
tautology checker that enumerates every assignment to the expression's
variables.

```lean
inductive BoolExpr : Type
  | var : Nat → BoolExpr
  | not : BoolExpr → BoolExpr
  | and : BoolExpr → BoolExpr → BoolExpr
  | or  : BoolExpr → BoolExpr → BoolExpr

def eval     : BoolExpr → (Nat → Bool) → Bool         -- standard semantics
def maxVar   : BoolExpr → Nat                         -- one past the highest var index
def asFun    : List Bool → Nat → Bool                 -- list-indexed lookup, false past end
def allAssignments : Nat → List (List Bool)           -- 2^n lists of length n
def isTautology (e : BoolExpr) : Bool :=
  (allAssignments (maxVar e)).all (fun l => eval e (asFun l))
```

Prove that the checker is correct in both directions:

```lean
theorem isTautology_correct (e : BoolExpr) :
    isTautology e = true ↔ ∀ v : Nat → Bool, eval e v = true
```

## Hints

- The right-to-left direction (∀v → tautology) is the easy one — every list
  in `allAssignments` produces a particular `Nat → Bool` via `asFun`, so a
  universally-quantified premise specialises trivially.
- For the left-to-right direction (tautology → ∀v), the central lemma is
  that `eval e` doesn't care about `v k` for `k ≥ maxVar e`. Prove this by
  induction on the structure of `e`.
- You will also need to construct, for every `v : Nat → Bool`, a list in
  `allAssignments (maxVar e)` whose `asFun` agrees with `v` on
  `[0, maxVar e)`. Define an `encode` helper and prove both that it lands
  in `allAssignments` and that its `asFun` reproduces `v`. The proof that
  it lands in `allAssignments` will use `List.mem_flatMap`.
- `simp [isTautology, List.all_eq_true]` unfolds the brute-force loop into
  a `∀ l ∈ allAssignments _, ...` shape that's easier to manipulate.

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
