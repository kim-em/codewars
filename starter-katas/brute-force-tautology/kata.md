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

- The backwards direction (`⊇`) is the easy one — every list in
  `allAssignments` produces a particular `Nat → Bool` via `asFun`, so any
  universally-quantified statement specialises trivially.
- For the forwards direction (`⊆`), the central lemma is that `eval e`
  doesn't care about `v k` for `k ≥ maxVar e`. Prove this by induction on
  the structure of `e`.
- You will also need to construct, for every `v : Nat → Bool`, a list in
  `allAssignments (maxVar e)` whose `asFun` agrees with `v` on
  `[0, maxVar e)`. Define an `encode` helper and prove both that it lands
  in `allAssignments` and that its `asFun` reproduces `v`.
