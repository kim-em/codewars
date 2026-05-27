-- Generalised lemma: the accumulator is added to the direct sum.
theorem sumTailHelper_eq (l : List Nat) (acc : Nat) :
    sumTailHelper l acc = acc + sumDirect l := by
  induction l generalizing acc with
  | nil =>
    simp [sumTailHelper, sumDirect]
  | cons x l ih =>
    show sumTailHelper l (acc + x) = acc + (x + sumDirect l)
    rw [ih (acc + x)]
    omega

theorem sumTail_eq_sumDirect (l : List Nat) : sumTail l = sumDirect l := by
  show sumTailHelper l 0 = sumDirect l
  rw [sumTailHelper_eq]
  omega
