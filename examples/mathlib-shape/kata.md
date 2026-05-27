# Cosine and Finset Range (Lean 4 + Mathlib)

Prove these two basic Mathlib facts.

```lean
theorem cos_zero_eq_one : Real.cos 0 = 1 := by sorry

theorem range_card_demo (n : Nat) : (Finset.range n).card = n := by sorry
```

Each is a single lemma application from Mathlib's library. This kata
requires the `codewars-lean4:mathlib` runner variant.
