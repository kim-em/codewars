theorem isEven_iff_Even (n : Nat) : isEven n = true ↔ Even n := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    match n with
    | 0 =>
      refine ⟨fun _ => ⟨0, rfl⟩, fun _ => rfl⟩
    | 1 =>
      constructor
      · intro h; simp [isEven] at h
      · rintro ⟨k, hk⟩
        omega
    | n + 2 =>
      simp only [isEven]
      constructor
      · intro h
        obtain ⟨k, hk⟩ := (ih n (by omega)).mp h
        exact ⟨k + 1, by omega⟩
      · rintro ⟨k, hk⟩
        match k, hk with
        | 0,      hk => omega
        | k' + 1, hk =>
          have hn : n = 2 * k' := by omega
          exact (ih n (by omega)).mpr ⟨k', hn⟩
