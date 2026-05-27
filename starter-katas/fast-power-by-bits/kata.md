# Fast Exponentiation by Bits (Lean 4)

**Difficulty:** 4 kyu

You are given two ways to compute `a^n`. The slow one multiplies `a` by
itself `n` times. The fast one squares-and-multiplies, with the exponent
given as a low-bit-first list of booleans.

```lean
def slowPow  (a : Nat) : Nat → Nat
def fastPow  (a : Nat) : List Bool → Nat
def bitsToNat : List Bool → Nat
```

Prove the two agree:

```lean
theorem fastPow_eq (a : Nat) (l : List Bool) :
    fastPow a l = slowPow a (bitsToNat l)
```

## Hints

- You'll need an auxiliary lemma `slowPow a (m + n) = slowPow a m * slowPow a n`.
  Prove this by induction on `m`, using `Nat.mul_assoc`.
- The main proof is induction on `l` with a `cases` on the leading bit. In
  each non-empty case, rewrite `2 * k` (or `2 * k + 1`) as `k + k` (or
  `1 + (k + k)`) so you can apply the lemma.
- Lean's `omega` handles the linear arithmetic on exponents; the
  multiplicative reasoning has to be done explicitly with `Nat.mul_assoc`,
  `Nat.mul_one`, etc.
