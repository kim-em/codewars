-- Key auxiliary lemma: `slowPow` is multiplicative in the exponent.
theorem slowPow_add (a m n : Nat) :
    slowPow a (m + n) = slowPow a m * slowPow a n := by
  induction m with
  | zero =>
    simp [slowPow]
  | succ m ih =>
    show slowPow a (m + 1 + n) = slowPow a (m + 1) * slowPow a n
    have h : m + 1 + n = (m + n) + 1 := by omega
    rw [h]
    show a * slowPow a (m + n) = a * slowPow a m * slowPow a n
    rw [ih, Nat.mul_assoc]

theorem fastPow_eq (a : Nat) (l : List Bool) :
    fastPow a l = slowPow a (bitsToNat l) := by
  induction l with
  | nil => rfl
  | cons b l ih =>
    cases b with
    | false =>
      show fastPow a l * fastPow a l = slowPow a (2 * bitsToNat l)
      rw [ih]
      rw [show 2 * bitsToNat l = bitsToNat l + bitsToNat l from by omega]
      rw [slowPow_add]
    | true =>
      show a * fastPow a l * fastPow a l = slowPow a (2 * bitsToNat l + 1)
      rw [ih]
      rw [show 2 * bitsToNat l + 1 = 1 + (bitsToNat l + bitsToNat l) from by omega]
      rw [slowPow_add, slowPow_add]
      show a * slowPow a (bitsToNat l) * slowPow a (bitsToNat l)
         = slowPow a 1 * (slowPow a (bitsToNat l) * slowPow a (bitsToNat l))
      rw [show slowPow a 1 = a * slowPow a 0 from rfl, show slowPow a 0 = 1 from rfl]
      rw [Nat.mul_one, Nat.mul_assoc]
