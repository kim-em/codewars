theorem multiply_correct (a b : Nat) : multiply a b = a * b := by
  induction a with
  | zero => simp [multiply]
  | succ n ih => simp [multiply, ih, Nat.succ_mul, Nat.add_comm]
