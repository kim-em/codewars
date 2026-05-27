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
