-- User-submitted proofs. Wrapped in `namespace Submission ... end Submission`.

theorem cos_zero_eq_one : Real.cos 0 = 1 := Real.cos_zero

theorem range_card_demo (n : Nat) : (Finset.range n).card = n :=
  Finset.card_range n
