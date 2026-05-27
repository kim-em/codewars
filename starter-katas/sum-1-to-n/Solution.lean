theorem sumTo_double (n : Nat) : 2 * sumTo n = n * (n + 1) := by
  induction n with
  | zero => simp [sumTo]
  | succ n ih =>
    show 2 * ((n + 1) + sumTo n) = (n + 1) * (n + 2)
    calc 2 * ((n + 1) + sumTo n)
        = 2 * (n + 1) + 2 * sumTo n := Nat.mul_add 2 (n + 1) (sumTo n)
      _ = 2 * (n + 1) + n * (n + 1) := by rw [ih]
      _ = (n + 1) * 2 + (n + 1) * n := by
          rw [Nat.mul_comm 2 (n + 1), Nat.mul_comm n (n + 1)]
      _ = (n + 1) * (2 + n)         := by rw [← Nat.mul_add]
      _ = (n + 1) * (n + 2)         := by rw [Nat.add_comm 2 n]
