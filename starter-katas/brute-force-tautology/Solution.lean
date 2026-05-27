-- Project an arbitrary `v : Nat → Bool` to a `List Bool` of length `n`.
def encode (v : Nat → Bool) : Nat → List Bool
  | 0     => []
  | n + 1 => v 0 :: encode (fun k => v (k + 1)) n

-- `asFun (encode v n) k = v k` for any `k < n`.
theorem asFun_encode (v : Nat → Bool) (n k : Nat) (h : k < n) :
    asFun (encode v n) k = v k := by
  induction n generalizing v k with
  | zero => omega
  | succ n ih =>
    cases k with
    | zero => simp [encode, asFun]
    | succ k' =>
      simp only [encode, asFun]
      exact ih (fun k => v (k + 1)) k' (by omega)

-- `encode v n` is one of the `2 ^ n` assignments.
theorem encode_mem (v : Nat → Bool) (n : Nat) :
    encode v n ∈ allAssignments n := by
  induction n generalizing v with
  | zero => simp [encode, allAssignments]
  | succ n ih =>
    simp only [encode, allAssignments, List.mem_flatMap]
    refine ⟨encode (fun k => v (k + 1)) n, ih _, ?_⟩
    cases v 0 <;> simp

-- `eval e` only depends on `v`'s values at variables `< maxVar e`.
theorem eval_congr (e : BoolExpr) (v w : Nat → Bool)
    (h : ∀ k, k < maxVar e → v k = w k) : eval e v = eval e w := by
  induction e with
  | var n      => exact h n (by simp [maxVar])
  | not e ih   => simp only [eval, ih h]
  | and a b iha ihb =>
    have ha : ∀ k, k < maxVar a → v k = w k :=
      fun k hk => h k (by simp [maxVar]; omega)
    have hb : ∀ k, k < maxVar b → v k = w k :=
      fun k hk => h k (by simp [maxVar]; omega)
    simp only [eval, iha ha, ihb hb]
  | or a b iha ihb =>
    have ha : ∀ k, k < maxVar a → v k = w k :=
      fun k hk => h k (by simp [maxVar]; omega)
    have hb : ∀ k, k < maxVar b → v k = w k :=
      fun k hk => h k (by simp [maxVar]; omega)
    simp only [eval, iha ha, ihb hb]

theorem isTautology_correct (e : BoolExpr) :
    isTautology e = true ↔ ∀ v : Nat → Bool, eval e v = true := by
  constructor
  · intro hT v
    have hall : ∀ l ∈ allAssignments (maxVar e), eval e (asFun l) = true := by
      simpa [isTautology, List.all_eq_true] using hT
    have he : eval e (asFun (encode v (maxVar e))) = true :=
      hall _ (encode_mem v (maxVar e))
    have : eval e v = eval e (asFun (encode v (maxVar e))) := by
      apply eval_congr
      intro k hk
      rw [asFun_encode v (maxVar e) k hk]
    rw [this, he]
  · intro hAll
    simp [isTautology, List.all_eq_true]
    intro l _hl
    exact hAll _
