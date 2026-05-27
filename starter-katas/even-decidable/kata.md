# Decidable Evenness (Lean 4)

**Difficulty:** 6 kyu

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

- Plain `Nat.rec` only gives you `n` and `n+1` as cases; `isEven` recurses
  on `n+2`. Use `Nat.strongRecOn` (`induction n using Nat.strongRecOn`) so
  you can apply the IH to `n` from inside the `n+2` branch.
- The reverse direction needs `k ≥ 1` to subtract — case-split on `k`.
