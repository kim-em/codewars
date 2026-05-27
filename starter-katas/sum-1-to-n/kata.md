# Sum 1..n (Lean 4)

**Difficulty:** 7 kyu

You are given the obvious recursive definition of `1 + 2 + ⋯ + n`:

```lean
def sumTo : Nat → Nat
  | 0     => 0
  | n + 1 => (n + 1) + sumTo n
```

Prove Gauss's identity, doubled to stay in `Nat`:

```lean
theorem sumTo_double (n : Nat) : 2 * sumTo n = n * (n + 1)
```

The proof is by induction. The successor case multiplies two binomials, so
`omega` (linear only) isn't enough — you'll need a small `calc` chain using
`Nat.mul_add` / `Nat.mul_comm` to rearrange `(n+1) · (n+2)`.
