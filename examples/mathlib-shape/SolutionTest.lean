import ChallengeDeps

-- Trusted theorem statements. Each body refers to `Submission.<name>`;
-- the adapter rewrites bodies to `by sorry` for Challenge.lean.

theorem cos_zero_eq_one : Real.cos 0 = 1 := Submission.cos_zero_eq_one

theorem range_card_demo (n : Nat) : (Finset.range n).card = n :=
  Submission.range_card_demo n
